%{

#include <stdio.h>
#include <cstdint>

//#include <node.h>
#include "parser.h"

%}

%option yylineno
%option noyywrap
%option warn nodefault

%%

"."     { return DOT; }
":"     { return COLON; }
","     { return COMMA; }
"("     { return OPENING_BRACKET; }
")"     { return CLOSING_BRACKET; }

[1-6][56]  { yylval.int_val = atoi(yytext); return COORDINATE_DIGITS; }

(\r\n|\n) { /*printf("NEW_LINE\n");*/ return NEW_LINE; }

[ \t]+	{ }

<<EOF>>	{ return EOF; }

.       { return *yytext; }


%%