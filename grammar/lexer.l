%{

#include <stdio.h>
#include <cstdint>

#include "parser.h"

%}

%option yylineno
%option noyywrap
%option warn nodefault

%%

"#"[^(\r\n|\n)]* { printf("# comment\n"); return HASHTAG_COMMENT; }

"."     { return DOT; }
":"     { return COLON; }
","     { return COMMA; }
"("     { return OPENING_BRACKET; }
")"     { return CLOSING_BRACKET; }

"AD" { /*printf("AD_TOK\n");*/ return AD_TOK; }

[1-6][56] { yylval.int_val = atoi(yytext); return COORDINATE_DIGITS; }

[0-9]+ { printf("INTEGER_NUMBER\n"); yylval.int_val = atoi(yytext); return INTEGER_NUMBER; }

[+|-]?((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { /*printf("DECIMAL_NUMBER\n");*/ yylval.int_val = atoi(yytext); return DECIMAL_NUMBER; }

"G01" { return INTERPOLATION_LINEAR; }
"G02" { return INTERPOLATION_CW_CIRCULAR; }
"G03" { return INTERPOLATION_CCW_CIRCULAR; }
"G75" { return INTERPOLATION_BEFORE_FIRST_CIRCULAR_COMPAT; }

"D01" { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT_SEGMENT; }
"D02" { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT_MOVE; }
"D03" { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT_FLASH; }
"D"[0-9][0-9]+ { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT; }

(\r\n|\n) { /*printf("NEW_LINE\n");*/ return NEW_LINE; }

[ \t]+	{ }

"G04"[^"*"]*"*" { return G04_COMMENT; }

<<EOF>> { static int once = 0; once++; if (once) { return EOF; } else { return '\n'; } }

. { /*printf("yytext\n");*/ return *yytext; }

%%

/* [+|-]?((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { yylval.int_val = atoi(yytext); return DECIMAL_NUMBER; } */
/* "G04"[^"*"]*"*" { return COMMENT; } */
/* [^"*"]*"*" { return COMMENT; } */
/* "G04" { return COMMENT_START; } */
/* //"#".*   {  } */
/* <<EOF>>	{ return EOF; } */
/* "#"[^(\r\n|\n)]*(\r\n|\n) { printf("# comment\n"); return HASHTAG_COMMENT; } */