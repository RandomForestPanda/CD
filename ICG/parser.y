%{
    #include "quad_generation.c"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define YYSTYPE char*
    #define MAX_LABELS 100  // Maximum depth for label stack

    void yyerror(char* s);                                          
    int yylex();                                                   
    extern int yylineno;                                            

    FILE* icg_quad_file;
    int temp_no = 1;
    int label_no = 1;                                              
    char* label_stack[MAX_LABELS];                                  
    int stack_top = -1;                                            

    char* new_label();                                              
    void push_label(char* label);                                   // Push label to stack
    char* pop_label();                                              // Pop label from stack
%}

%token T_ID T_NUM T_IF T_ELSE T_WHILE T_DO T_EQ T_NEQ T_GEQ T_LEQ T_AND T_OR


%nonassoc T_IF
%nonassoc T_ELSE


%start START

%%
START : STMT_LIST { 
                    printf("Valid syntax\n");
                    while (stack_top >= 0) {
                        quad_code_gen(pop_label(), NULL, "label", NULL);
                    }
                    YYACCEPT;
                  };

STMT_LIST : STMT
          | STMT_LIST STMT
          ;

STMT : IF_STMT
     | WHILE_STMT
     | DO_WHILE_STMT
     | ASSGN ';'
     | BLOCK
     ;

BLOCK : '{' STMT_LIST '}'
      | '{' '}'
      ;

IF_STMT : T_IF '(' CONDITION ')' 
        {
            char* cond = $3;
            char* label_false = new_label();
            char* label_end = new_label();
            quad_code_gen(label_false, cond, "if", NULL);    
            quad_code_gen(label_end, NULL, "goto", NULL);    
            quad_code_gen(label_false, NULL, "label", NULL); 
            push_label(label_end);                           
        }
        BLOCK 
        {
            char* label_end = pop_label();                   
            quad_code_gen(label_end, NULL, "label", NULL);   
        }
        ELSE_OPT
        ;

ELSE_OPT : 
         | T_ELSE BLOCK
         ;

WHILE_STMT : T_WHILE 
           {
               char* label_start = new_label();
               quad_code_gen(label_start, NULL, "label", NULL);
               push_label(label_start);
           }
           '(' CONDITION ')'
           {
               char* cond = $4;
               char* label_end = new_label();
               quad_code_gen(label_end, cond, "if", NULL);
               push_label(label_end);
           }
           BLOCK
           {
               char* label_end = pop_label();
               char* label_start = pop_label();
               quad_code_gen(label_start, NULL, "goto", NULL);
               quad_code_gen(label_end, NULL, "label", NULL);
           }
           ;

DO_WHILE_STMT : T_DO 
              {
                  char* label_start = new_label();
                  quad_code_gen(label_start, NULL, "label", NULL);
                  push_label(label_start);
              }
              BLOCK T_WHILE '(' CONDITION ')' ';'
              {
                  char* cond = $6;
                  char* label_start = pop_label();
                  quad_code_gen(label_start, cond, "if goto", NULL);
              }
              ;

CONDITION : REL_EXPR    { $$ = $1; }
          | LOGICAL_EXPR { $$ = $1; }
          ;

REL_EXPR : E '>' E      { $$ = new_temp(); quad_code_gen($$, $1, ">", $3); }
         | E '<' E      { $$ = new_temp(); quad_code_gen($$, $1, "<", $3); }
         | E T_EQ E     { $$ = new_temp(); quad_code_gen($$, $1, "==", $3); }
         | E T_NEQ E    { $$ = new_temp(); quad_code_gen($$, $1, "!=", $3); }
         | E T_GEQ E    { $$ = new_temp(); quad_code_gen($$, $1, ">=", $3); }
         | E T_LEQ E    { $$ = new_temp(); quad_code_gen($$, $1, "<=", $3); }
         ;

LOGICAL_EXPR : REL_EXPR T_AND REL_EXPR  { $$ = new_temp(); quad_code_gen($$, $1, "&&", $3); }
             | REL_EXPR T_OR REL_EXPR   { $$ = new_temp(); quad_code_gen($$, $1, "||", $3); }
             | '!' REL_EXPR             { $$ = new_temp(); quad_code_gen($$, $2, "!", NULL); }
             | '(' LOGICAL_EXPR ')'     { $$ = $2; }
             ;

ASSGN : T_ID '=' E     { quad_code_gen($1, $3, "=", NULL); }
      ;

E : E '+' T           { $$ = new_temp(); quad_code_gen($$, $1, "+", $3); }
  | E '-' T           { $$ = new_temp(); quad_code_gen($$, $1, "-", $3); }
  | T
  ;

T : T '*' F           { $$ = new_temp(); quad_code_gen($$, $1, "*", $3); }
  | T '/' F           { $$ = new_temp(); quad_code_gen($$, $1, "/", $3); }
  | F
  ;

F : '(' E ')'         { $$ = $2; }
  | T_ID              { $$ = $1; }
  | T_NUM             { $$ = $1; }
  ;

%%


void yyerror(char* s)
{
    printf("Error: %s at %d\n", s, yylineno);
}


int main(int argc, char* argv[])
{
    icg_quad_file = fopen("icg_quad.txt", "w");
    if (!icg_quad_file) {
        perror("Could not open output file");
        return 1;
    }
    yyparse();
    fclose(icg_quad_file);
    return 0;
}


char* new_label()
{
    char* label = (char*)malloc(sizeof(char) * 10);
    sprintf(label, "L%d", label_no++);
    return label;
}


void push_label(char* label)
{
    if (stack_top < MAX_LABELS - 1) {
        label_stack[++stack_top] = label;
    } else {
        yyerror("Label stack overflow");
    }
}


char* pop_label()
{
    if (stack_top >= 0) {
        return label_stack[stack_top--];
    } else {
        yyerror("Label stack underflow");
        return NULL;
    }
}