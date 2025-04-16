%{

#include <stdio.h>
#include <cstdint>

#include "parser.h"

%}

%option yylineno
%option noyywrap
%option warn nodefault

%%

"//".* { /* DO NOTHING */ /* lex/flex, . won't match a newline. */ printf("CommentText: %s\n", yytext); }

"." { return DOT; }
":" { return COLON; }
"," { return COMMA; }
"(" { return OPENING_BRACKET; }
")" { return CLOSING_BRACKET; }

"AD" { /*printf("AD_TOK\n");*/ return AD_TOK; }
"TF" { printf("TF_TOK\n"); return TF_TOK; }

[1-6][56] { yylval.int_val = atoi(yytext); return COORDINATE_DIGITS; }

[0-9]+ { printf("INTEGER_NUMBER\n"); yylval.int_val = atoi(yytext); return INTEGER_NUMBER; }

[+|-]?((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { /*printf("DECIMAL_NUMBER\n");*/ yylval.int_val = atoi(yytext); return DECIMAL_NUMBER; }

"\.Part" { return DOT_PART; }
"\.FileFunction" { return DOT_FILEFUNCTION; }
"\.FilePolarity" { return DOT_FILEPOLARITY; }
"\.SameCoordinates" { return DOT_SAMECOORDINATES; }
"\.CreationDate" { return DOT_CREATIONDATE; }
"\.GenerationSoftware" { return DOT_GENERATIONSOFTWARE; }
"\.ProjectId" { return DOT_PROJECTID; }
"\.MD5" { return DOT_MD5; }

"\.AperFunction" { return DOT_APERFUNCTION; }
"\.DrillTolerance" { return DOT_DRILLTOLERANCE; }
"\.FlashText" { return DOT_FLASHTEXT; }

"\.N" { return DOT_N; }
"\.P" { return DOT_P; }
"\.C" { return DOT_C; }
"\.CRot" { return DOT_CROT; }
"\.CMfr" { return DOT_CMFR; }
"\.CMPN" { return DOT_CMPN; }
"\.CVal" { return DOT_CVAL; }
"\.CMnt" { return DOT_CMNT; }
"\.CFtp" { return DOT_CFTP; }
"\.CPgN" { return DOT_CPGN; }
"\.CPgD" { return DOT_CPGD; }
"\.CHgt" { return DOT_CHGT; }
"\.CLbN" { return DOT_CLBN; }
"\.CLbD" { return DOT_CLBD; }
"\.CSup" { return DOT_CSUP; }

"G01" { return INTERPOLATION_LINEAR; }
"G02" { return INTERPOLATION_CW_CIRCULAR; }
"G03" { return INTERPOLATION_CCW_CIRCULAR; }
"G75" { return INTERPOLATION_BEFORE_FIRST_CIRCULAR_COMPAT; }

"D01" { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT_SEGMENT; }
"D02" { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT_MOVE; }
"D03" { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT_FLASH; }
"D"[0-9][0-9]+ { /*printf("APERTURE_IDENT\n"); yylval.int_val = atoi(yytext);*/ return APERTURE_IDENT; }

(\r\n|\n) { }
[ \t]+ { }

"G04"[^"*"]*"*" { return G04_COMMENT; }

<<EOF>> { static int once = 0; once++; if (once) { return EOF; } else { return '\n'; } }

. { /*printf("yytext\n");*/ return *yytext; }

%%

/* [^("%""\*"",""\.")]+ { printf("FIELD: %s\n", yytext); return FIELD; } */
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