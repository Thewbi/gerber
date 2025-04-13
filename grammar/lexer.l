%{

#include <stdio.h>
#include <cstdint>

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

"AD" { /*printf("AD_TOK\n");*/ return AD_TOK; }

[1-6][56] { yylval.int_val = atoi(yytext); return COORDINATE_DIGITS; }

[0-9]+ { /**/printf("INTEGER_NUMBER\n"); yylval.int_val = atoi(yytext); return INTEGER_NUMBER; }

[+|-]?((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { /*printf("DECIMAL_NUMBER\n");*/ yylval.int_val = atoi(yytext); return DECIMAL_NUMBER; }

"D01" { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT_SEGMENT; }
"D02" { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT_MOVE; }
"D03" { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT_FLASH; }
"D"[0-9][0-9]+ { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT; }

(\r\n|\n) { /*printf("NEW_LINE\n");*/ return NEW_LINE; }

[ \t]+	{ }

"#".*   { /* DO NOTHING */ }

<<EOF>>	{ return EOF; }

.       { return *yytext; }

%%

/*
/* [+|-]?((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { yylval.int_val = atoi(yytext); return DECIMAL_NUMBER; } */