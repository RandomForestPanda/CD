%{
	// Name: Shreyanshu    SRN: PES1UG22CS578
	#include "abstract_syntax_tree.c"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	void yyerror(char* s); 		// error handling function
	int yylex(); 			// declare the function performing lexical analysis
	extern int yylineno; 		// track the line number
%}
%union	// union to allow nodes to store return different datatypes
{
	char* text;
	expression_node* exp_node;
}
%token <text> T_ID T_NUM
%token T_IF T_ELSE T_WHILE T_DO T_AND T_OR T_EQ T_NEQ T_GEQ T_LEQ
%type <exp_node> E T F ASSGN START STMT STMT_LIST BLOCK CONDITION IF_STMT WHILE_STMT DO_WHILE_STMT REL_EXPR LOGICAL_EXPR
/* specify start symbol */
%start START
%%
START : STMT	{ display_exp_tree($1); printf("\nValid syntax\n"); YYACCEPT;}
	;

STMT : IF_STMT
     | WHILE_STMT
     | DO_WHILE_STMT
     | ASSGN ';'	{ $$ = $1; }
     | BLOCK
     ;

BLOCK : '{' STMT_LIST '}'	{ $$ = $2; }
      | '{' '}'		{ $$ = NULL; }
      ;

STMT_LIST : STMT		{ $$ = $1; }
         | STMT_LIST STMT	{ $$ = init_exp_node("seq", $1, $2); }
         ;

IF_STMT : T_IF '(' CONDITION ')' BLOCK T_ELSE BLOCK
        { $$ = init_exp_node("if-else", $3, init_exp_node("seq", $5, $7)); }
        | T_IF '(' CONDITION ')' BLOCK
        { $$ = init_exp_node("if", $3, $5); }
        ;
WHILE_STMT : T_WHILE '(' CONDITION ')' BLOCK	
           { $$ = init_exp_node("while", $3, $5); }
           ;

DO_WHILE_STMT : T_DO BLOCK T_WHILE '(' CONDITION ')' ';'	
              { $$ = init_exp_node("do-while", $5, $2); }
              ;

CONDITION : REL_EXPR
          | LOGICAL_EXPR
          ;

REL_EXPR : E '>' E	{ $$ = init_exp_node(">", $1, $3); }
         | E '<' E	{ $$ = init_exp_node("<", $1, $3); }
         | E T_EQ E	{ $$ = init_exp_node("==", $1, $3); }
         | E T_NEQ E	{ $$ = init_exp_node("!=", $1, $3); }
         | E T_GEQ E	{ $$ = init_exp_node(">=", $1, $3); }
         | E T_LEQ E	{ $$ = init_exp_node("<=", $1, $3); }
         ;

LOGICAL_EXPR : REL_EXPR T_AND REL_EXPR	{ $$ = init_exp_node("&&", $1, $3); }
             | REL_EXPR T_OR REL_EXPR	{ $$ = init_exp_node("||", $1, $3); }
             | '!' REL_EXPR		{ $$ = init_exp_node("!", $2, NULL); }
             | '(' LOGICAL_EXPR ')'	{ $$ = $2; }
             ;

/* Grammar for assignment */
ASSGN : T_ID '=' E 	{ $$ = init_exp_node("=", init_exp_node($1, NULL, NULL), $3); }
	;

/* Expression Grammar */
E : E '+' T 	{ $$ = init_exp_node("+", $1, $3); }
  | E '-' T 	{ $$ = init_exp_node("-", $1, $3); }
  | T 	
  ;
	
T : T '*' F 	{ $$ = init_exp_node("*", $1, $3); }
  | T '/' F 	{ $$ = init_exp_node("/", $1, $3); }
  | F 
  ;

F : '(' E ')'	{ $$ = $2; }
  | T_ID	{ $$ = init_exp_node($1, NULL, NULL); }
  | T_NUM	{ $$ = init_exp_node($1, NULL, NULL); }
  ;
%%
/* error handling function */
void yyerror(char* s)
{
	printf("Error :%s at %d \n",s,yylineno);
}
/* main function - calls the yyparse() function which will in turn drive yylex() as well */
int main(int argc, char* argv[])
{
	yyparse();
	return 0;
}
