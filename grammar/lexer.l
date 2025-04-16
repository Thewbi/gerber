%{

#include <stdio.h>
#include <cstdint>

#include "parser.h"

%}

%option yylineno
%option noyywrap
%option warn nodefault
%option debug

%x INSIDE_TF INSIDE_AD

%%

"//".* { /* DO NOTHING */ /* lex/flex, . won't match a newline. */ printf("CommentText: %s\n", yytext); }

"." { return DOT; }
":" { return COLON; }
<INSIDE_TF>"," { printf("[LEXER] COMMA\n"); return COMMA; }
<INSIDE_AD>"," { printf("[LEXER] COMMA\n"); return COMMA; }
<INSIDE_TF>"*%" { printf("[LEXER] ASTERISK_PERCENT\n"); BEGIN(INITIAL); return ASTERISK_PERCENT; }
<INSIDE_AD>"*%" { printf("[LEXER] ASTERISK_PERCENT\n"); BEGIN(INITIAL); return ASTERISK_PERCENT; }

"%AD" { printf("[LEXER] PERCENT AD_TOK\n"); BEGIN(INSIDE_AD); return AD_TOK; }
"%TF" { printf("[LEXER] PERCENT TF_TOK\n"); BEGIN(INSIDE_TF); return TF_TOK; }

<INSIDE_AD>"C"     { printf("[LEXER] C\n"); return C; }

[1-6][56] { yylval.int_val = atoi(yytext); return COORDINATE_DIGITS; }

[0-9]+ { printf("INTEGER_NUMBER\n"); yylval.int_val = atoi(yytext); return INTEGER_NUMBER; }

<INSIDE_AD>[+|-]?((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { /*printf("DECIMAL_NUMBER\n");*/ yylval.int_val = atoi(yytext); return DECIMAL_NUMBER; }

<INSIDE_TF>"\.Part" { return DOT_PART; }
<INSIDE_TF>"\.FileFunction" { return DOT_FILEFUNCTION; }
<INSIDE_TF>"\.FilePolarity" { return DOT_FILEPOLARITY; }
<INSIDE_TF>"\.SameCoordinates" { return DOT_SAMECOORDINATES; }
<INSIDE_TF>"\.CreationDate" { return DOT_CREATIONDATE; }
<INSIDE_TF>"\.GenerationSoftware" { return DOT_GENERATIONSOFTWARE; }
<INSIDE_TF>"\.ProjectId" { return DOT_PROJECTID; }
<INSIDE_TF>"\.MD5" { return DOT_MD5; }

<INSIDE_TF>"\.AperFunction" { return DOT_APERFUNCTION; }
<INSIDE_TF>"\.DrillTolerance" { return DOT_DRILLTOLERANCE; }
<INSIDE_TF>"\.FlashText" { return DOT_FLASHTEXT; }

<INSIDE_TF>"\.N" { return DOT_N; }
<INSIDE_TF>"\.P" { return DOT_P; }
<INSIDE_TF>"\.C" { return DOT_C; }
<INSIDE_TF>"\.CRot" { return DOT_CROT; }
<INSIDE_TF>"\.CMfr" { return DOT_CMFR; }
<INSIDE_TF>"\.CMPN" { return DOT_CMPN; }
<INSIDE_TF>"\.CVal" { return DOT_CVAL; }
<INSIDE_TF>"\.CMnt" { return DOT_CMNT; }
<INSIDE_TF>"\.CFtp" { return DOT_CFTP; }
<INSIDE_TF>"\.CPgN" { return DOT_CPGN; }
<INSIDE_TF>"\.CPgD" { return DOT_CPGD; }
<INSIDE_TF>"\.CHgt" { return DOT_CHGT; }
<INSIDE_TF>"\.CLbN" { return DOT_CLBN; }
<INSIDE_TF>"\.CLbD" { return DOT_CLBD; }
<INSIDE_TF>"\.CSup" { return DOT_CSUP; }

"G01" { return INTERPOLATION_LINEAR; }
"G02" { return INTERPOLATION_CW_CIRCULAR; }
"G03" { return INTERPOLATION_CCW_CIRCULAR; }
"G75" { return INTERPOLATION_BEFORE_FIRST_CIRCULAR_COMPAT; }

"D01" { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT_SEGMENT; }
"D02" { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT_MOVE; }
"D03" { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT_FLASH; }
<INSIDE_AD>"D"[0-9][0-9]+ { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT; }

<INSIDE_TF>[^%'\*',]+ { printf("FIELD: %s\n", yytext); return FIELD; }
<INSIDE_TF>[_0-9a-zA-Z$][_a-zA-Z0-9]* { printf("USER_NAME: %s\n", yytext); return USER_NAME; }

(\r\n|\n) { }
[ \t]+ { }

"G04"[^"*"]*"*" { return G04_COMMENT; }

<<EOF>> { static int once = 0; once++; if (once) { return EOF; } else { return '\n'; } }

. { /*printf("yytext\n");*/ return *yytext; }

%%

/*
"(" { return OPENING_BRACKET; }
")" { return CLOSING_BRACKET; }
*/
/* [^("%""\*"",""\.")]+ { printf("FIELD: %s\n", yytext); return FIELD; } */
/* /* Modification made here: USER_NAME cannot contain \. Otherwise the greedy flexer will convert TF.FilePolarity,Negative into a USER_NAME! */
/* [_0-9a-zA-Z$][_a-zA-Z0-9]* { /* Modification made here: USER_NAME cannot contain \. Otherwise the greedy flexer will convert TF.FilePolarity,Negative into a USER_NAME! printf("USER_NAME: %s\n", yytext); return USER_NAME; } */

/* [_0-9a-zA-Z$][\._a-zA-Z0-9]* { printf("USER_NAME: %s\n", yytext); return USER_NAME; } */
/* [+|-]?((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { yylval.int_val = atoi(yytext); return DECIMAL_NUMBER; } */
/* "G04"[^"*"]*"*" { return COMMENT; } */
/* [^"*"]*"*" { return COMMENT; } */
/* "G04" { return COMMENT_START; } */
/* //"#".*   {  } */
/* <<EOF>>	{ return EOF; } */
/* "#"[^(\r\n|\n)]*(\r\n|\n) { printf("# comment\n"); return HASHTAG_COMMENT; } */
/* "#"[^(\r\n|\n)]* { printf("# comment\n"); return HASHTAG_COMMENT; } */
/* (\r\n|\n) { printf("NEW_LINE\n"); return NEW_LINE; } */
/* (\r\n|\n) { } */