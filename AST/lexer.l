%{
    #define YYSTYPE char*
    #include <unistd.h>
    #include "y.tab.h"
    #include <stdio.h>
    extern void yyerror(const char *); // declare the error handling function
%}
/* Regular definitions */
digit	[0-9]
letter	[a-zA-Z]
id	{letter}({letter}|{digit})*
digits	{digit}+
opFraction	(\.{digits})?
opExponent	([Ee][+-]?{digits})?
number	{digits}{opFraction}{opExponent}
%option yylineno
%%
\/\/(.*) ; // ignore comments
[\t\n ] ; // ignore whitespaces
"("		{return *yytext;}
")"		{return *yytext;}
"{"		{return *yytext;}
"}"		{return *yytext;}
"."         	{return *yytext;}
","         	{return *yytext;}
"*"         	{return *yytext;}
"+"         	{return *yytext;}
";"         	{return *yytext;}
"-"         	{return *yytext;}
"/"         	{return *yytext;}
"="         	{return *yytext;}
">"         	{return *yytext;}
"<"         	{return *yytext;}
"&&"        	{return T_AND;}
"||"        	{return T_OR;}
"!"         	{return *yytext;}
"=="        	{return T_EQ;}
"!="        	{return T_NEQ;}
">="        	{return T_GEQ;}
"<="        	{return T_LEQ;}
"if"        	{return T_IF;}
"else"      	{return T_ELSE;}
"while"     	{return T_WHILE;}
"do"        	{return T_DO;}
{number}	{
			yylval = strdup(yytext);  //stores the value of the number to be used later for symbol table insertion
			return T_NUM;
		}
{id}        	{
			yylval = strdup(yytext); //stores the identifier to be used later for symbol table insertion
			return T_ID;
		}
.		{} // anything else => ignore
%%
