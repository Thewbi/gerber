/**
 * MODIFICATIONS:
 * - the type POSITIVE_INTEGER is not used. Instead a UNSIGNED_DECIMAL_NUMBER is lexed
 * - in the AD rule, the name after a APERTURE_IDENT token has been modified.
 *   The name is not allowed to start with D or C because, flex only knows how
 *   to perform greedy matching and without this constraint flex will match
 *   <D10RoundRect> instead of <D10><RoundRect>
 *
 * COMMENTS
 * IF you want to add comments in the token section of this lexer file,
 * do not forget to indent the start of the comment by a tab or whitespace!
 */

%{

#include <stdio.h>
#include <cstdint>
#include <cstring>

#include "constants.h"
#include "ast_node.h"
#include "parser.h"

%}

%option yylineno
%option noyywrap
%option warn nodefault
%option debug

%x INSIDE_TF INSIDE_TA INSIDE_TD INSIDE_TO INSIDE_AD INSIDE_AM INSIDE_AM_ZERO INSIDE_AM_ONE INSIDE_AM_TWENTY INSIDE_AM_TWENTY_ONE INSIDE_AM_FOUR INSIDE_AM_FIVE INSIDE_AM_SEVEN INSIDE_LP INSIDE_LM INSIDE_LR INSIDE_LS INSIDE_SR INSIDE_AB

%%

"//".* { /* DO NOTHING */ /* lex/flex, . won't match a newline. */ /*printf("CommentText: %s\n", yytext);*/ }

"." { return DOT; }
":" { return COLON; }
<INSIDE_TF>"," { /*printf("[LEXER] <INSIDE_TF> COMMA\n");*/ return COMMA; }
<INSIDE_TA>"," { /*printf("[LEXER] <INSIDE_TA> COMMA\n");*/ return COMMA; }
<INSIDE_TO>"," { /*printf("[LEXER] <INSIDE_TO> COMMA\n");*/ return COMMA; }

<INSIDE_TF>"*%" { /*printf("[LEXER] <INSIDE_TF> ASTERISK_PERCENT\n");*/ BEGIN(INITIAL); return ASTERISK_PERCENT; }
<INSIDE_TA>"*%" { /*printf("[LEXER] <INSIDE_TA> ASTERISK_PERCENT\n");*/ BEGIN(INITIAL); return ASTERISK_PERCENT; }
<INSIDE_TO>"*%" { /*printf("[LEXER] <INSIDE_TO> ASTERISK_PERCENT\n");*/ BEGIN(INITIAL); return ASTERISK_PERCENT; }

"%AB" { /*printf("[LEXER] <INITIAL> PERCENT AB_TOK\n");*/ BEGIN(INSIDE_AB); return AB_TOK; }
"%AM" { /*printf("[LEXER] <INITIAL> PERCENT AM_TOK\n");*/ BEGIN(INSIDE_AM); return AM_TOK; }
"%AD" { /*printf("[LEXER] <INITIAL> PERCENT AD_TOK\n");*/ BEGIN(INSIDE_AD); return AD_TOK; }
"%TF" { /*printf("[LEXER] <INITIAL> PERCENT TF_TOK\n");*/ BEGIN(INSIDE_TF); return TF_TOK; }
"%TA" { /*printf("[LEXER] <INITIAL> PERCENT TA_TOK\n");*/ BEGIN(INSIDE_TA); return TA_TOK; }
"%TD" { /*printf("[LEXER] <INITIAL> PERCENT TD_TOK\n");*/ BEGIN(INSIDE_TD); return TD_TOK; }
"%TO" { /*printf("[LEXER] <INITIAL> PERCENT TO_TOK\n");*/ BEGIN(INSIDE_TO); return TO_TOK; }

"%LP" { /*printf("[LEXER] <INITIAL> PERCENT LP_TOK\n");*/ BEGIN(INSIDE_LP); return LP_TOK; }
"%LM" { /*printf("[LEXER] <INITIAL> PERCENT LM_TOK\n");*/ BEGIN(INSIDE_LM); return LM_TOK; }
"%LR" { /*printf("[LEXER] <INITIAL> PERCENT LR_TOK\n");*/ BEGIN(INSIDE_LR); return LR_TOK; }
"%LS" { /*printf("[LEXER] <INITIAL> PERCENT LS_TOK\n");*/ BEGIN(INSIDE_LS); return LS_TOK; }

"%SR" { /*printf("[LEXER] <INITIAL> PERCENT SR_TOK\n");*/ BEGIN(INSIDE_SR); return SR_TOK; }
"%SR*%" { /*printf("[LEXER] <INITIAL> END_SR_TOK\n");*/ BEGIN(INITIAL); return END_SR_TOK; }

<INSIDE_LP>"*%" { /*printf("[LEXER] ASTERISK_PERCENT\n");*/ BEGIN(INITIAL); return ASTERISK_PERCENT; }
<INSIDE_LP>"D" { /*printf("[LEXER] D\n");*/ return DARK; }
<INSIDE_LP>"C" { /*printf("[LEXER] C\n");*/ return CLEAR; }
<INSIDE_LM>"*%" { /*printf("[LEXER] ASTERISK_PERCENT\n");*/ BEGIN(INITIAL); return ASTERISK_PERCENT; }
<INSIDE_LR>"*%" { /*printf("[LEXER] ASTERISK_PERCENT\n");*/ BEGIN(INITIAL); return ASTERISK_PERCENT; }
<INSIDE_LR>((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { /*printf("[LEXER] UNSIGNED_DECIMAL_NUMBER\n");*/ yylval.float_val = atof(yytext); return UNSIGNED_DECIMAL_NUMBER; }
<INSIDE_LS>"*%" { /*printf("[LEXER] ASTERISK_PERCENT\n");*/ BEGIN(INITIAL); return ASTERISK_PERCENT; }
<INSIDE_LS>((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { yylval.float_val = atof(yytext); /*printf("[LEXER] UNSIGNED_DECIMAL_NUMBER%d\n", yylval.float_val);*/ return UNSIGNED_DECIMAL_NUMBER; }

    /*
    [1-6][56] { yylval.int_val = atoi(yytext); return COORDINATE_DIGITS; }
    */
[1-6][3456] { yylval.int_val = atoi(yytext); return COORDINATE_DIGITS; }

[0-9]+ { /*printf("[LEXER] INTEGER_NUMBER\n");*/ yylval.int_val = atoi(yytext); return INTEGER_NUMBER; }
[+|-][0-9]+ { /*printf("[LEXER] SIGNED_INTEGER_NUMBER\n");*/ yylval.int_val = atoi(yytext); return SIGNED_INTEGER_NUMBER; }

[+|-] { /*printf("[LEXER] ADD_SUB_OPERATOR\n");*/ return ADD_SUB_OPERATOR; }
[x|\/] { /*printf("[LEXER] MUL_DIV_OPERATOR\n");*/ return MUL_DIV_OPERATOR; }

<INSIDE_AD>"," { /*printf("[LEXER] <INSIDE_AD> COMMA\n");*/ return COMMA; }
<INSIDE_AD>"X" { /*printf("[LEXER] <INSIDE_AD> AD_X\n");*/ return AD_X; }
<INSIDE_AD>"*%" { /*printf("[LEXER] <INSIDE_AD> ASTERISK_PERCENT\n");*/ BEGIN(INITIAL); return ASTERISK_PERCENT; }
<INSIDE_AD>"C" { /*printf("[LEXER] <INSIDE_AD> C\n");*/ return C; }
<INSIDE_AD>[+|-]?((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { /*printf("[LEXER] <INSIDE_AD> DECIMAL_NUMBER\n");*/ yylval.float_val = atof(yytext); return DECIMAL_NUMBER; }
<INSIDE_AD>"D"[0-9][0-9]+ {
    /*printf("[LEXER] <INSIDE_AD> APERTURE_IDENT: %s\n", yytext);*/
    std::memset(yylval.string_val, 0, STRING_BUFFER_LENGTH);
    std::memcpy(yylval.string_val, yytext, std::strlen(yytext));
    //printf("[LEXER] <INSIDE_AD> APERTURE_IDENT: %s\n", yylval.string_val);

    return APERTURE_IDENT;
}
<INSIDE_AD>[\._a-zA-BE-WY-Z$][\._a-zA-Z0-9]* {
    /*printf("[LEXER] <INSIDE_AD> NAME: %s\n", yytext);*/
    std::memset(yylval.string_val, 0, STRING_BUFFER_LENGTH);
    std::memcpy(yylval.string_val, yytext, std::strlen(yytext));

    return AD_NAME;
}

((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { /*printf("[LEXER] UNSIGNED_DECIMAL_NUMBER\n");*/ yylval.int_val = atoi(yytext); return UNSIGNED_DECIMAL_NUMBER; }

<INSIDE_TF>"\.Part" { return DOT_PART; }
<INSIDE_TF>"\.FileFunction" { return DOT_FILEFUNCTION; }
<INSIDE_TF>"\.FilePolarity" { return DOT_FILEPOLARITY; }
<INSIDE_TF>"\.SameCoordinates" { return DOT_SAMECOORDINATES; }
<INSIDE_TF>"\.CreationDate" { return DOT_CREATIONDATE; }
<INSIDE_TF>"\.GenerationSoftware" { return DOT_GENERATIONSOFTWARE; }
<INSIDE_TF>"\.ProjectId" { return DOT_PROJECTID; }
<INSIDE_TF>"\.MD5" { return DOT_MD5; }

<INSIDE_TA>"\.AperFunction" { return DOT_APERFUNCTION; }
<INSIDE_TA>"\.DrillTolerance" { return DOT_DRILLTOLERANCE; }
<INSIDE_TA>"\.FlashText" { return DOT_FLASHTEXT; }

<INSIDE_TD>"*%" { /* printf("[LEXER] <INSIDE_TD> ASTERISK_PERCENT\n"); */ BEGIN(INITIAL); return ASTERISK_PERCENT; }

<INSIDE_TO>"\.N" { return DOT_N; }
<INSIDE_TO>"\.P" { return DOT_P; }
<INSIDE_TO>"\.C" { return DOT_C; }
<INSIDE_TO>"\.CRot" { return DOT_CROT; }
<INSIDE_TO>"\.CMfr" { return DOT_CMFR; }
<INSIDE_TO>"\.CMPN" { return DOT_CMPN; }
<INSIDE_TO>"\.CVal" { return DOT_CVAL; }
<INSIDE_TO>"\.CMnt" { return DOT_CMNT; }
<INSIDE_TO>"\.CFtp" { return DOT_CFTP; }
<INSIDE_TO>"\.CPgN" { return DOT_CPGN; }
<INSIDE_TO>"\.CPgD" { return DOT_CPGD; }
<INSIDE_TO>"\.CHgt" { return DOT_CHGT; }
<INSIDE_TO>"\.CLbN" { return DOT_CLBN; }
<INSIDE_TO>"\.CLbD" { return DOT_CLBD; }
<INSIDE_TO>"\.CSup" { return DOT_CSUP; }

"M02" { return END_OF_FILE; }

"G01" { return INTERPOLATION_LINEAR; }
"G02" { return INTERPOLATION_CW_CIRCULAR; }
"G03" { return INTERPOLATION_CCW_CIRCULAR; }
"G75" { return INTERPOLATION_BEFORE_FIRST_CIRCULAR_COMPAT; }

    /* Set polarity to clear or dark
"LPC" { return POLARITY_CLEAR; }
"LPD" { return POLARITY_DARK; }*/

    /* 8.1 Deprecated Commands */

"M00" { return PROGRAM_STOP; }
"IP" { return IMAGE_POLARITY; }
"IN"[^"*"]* { return IMAGE_NAME; }

"G36" { return REGION_STATEMENT_START; }
"G37" { return REGION_STATEMENT_END; }
"G54" { return SELECT_APERTURE; }
"G70" { return SET_UNIT_INCH; }
"G71" { return SET_UNIT_MM; }
"G90" { return SET_COORD_FMT_ABSOLUTE; }
"G91" { return SET_COORD_FMT_INCREMENTAL; }

"D01" { /*printf("APERTURE_IDENT\n"); */ yylval.int_val = atoi(yytext); return APERTURE_IDENT_SEGMENT; }
"D02" { /*printf("APERTURE_IDENT\n"); */ yylval.int_val = atoi(yytext); return APERTURE_IDENT_MOVE; }
"D03" { /*printf("APERTURE_IDENT\n"); */ yylval.int_val = atoi(yytext); return APERTURE_IDENT_FLASH; }

"D"[0-9][0-9]+ {
    /*yylval.int_val = atoi(yytext);*/

    std::memset(yylval.string_val, 0, STRING_BUFFER_LENGTH);
    std::memcpy(yylval.string_val, yytext, std::strlen(yytext));
    /*printf("[LEXER] APERTURE_IDENT: %s\n", yytext);*/

    return APERTURE_IDENT;
}

<INSIDE_TF>[^%'\*',]+ { /* printf("[LEXER] FIELD: %s\n", yytext); */ return FIELD; }
<INSIDE_TA>[^%'\*',]+ { /* printf("[LEXER] FIELD: %s\n", yytext); */ return FIELD; }
<INSIDE_TO>[^%'\*',]+ { /* printf("[LEXER] FIELD: %s\n", yytext); */ return FIELD; }

<INSIDE_TF>[_0-9a-zA-Z$][_a-zA-Z0-9]* { /* printf("[LEXER] USER_NAME: %s\n", yytext); */ return USER_NAME; }
<INSIDE_TA>[_0-9a-zA-Z$][_a-zA-Z0-9]* { /* printf("[LEXER] USER_NAME: %s\n", yytext); */ return USER_NAME; }
<INSIDE_TO>[_0-9a-zA-Z$][_a-zA-Z0-9]* { /* printf("[LEXER] USER_NAME: %s\n", yytext); */ return USER_NAME; }

<INSIDE_AM>"//".* { /* DO NOTHING */ }
<INSIDE_AM>"," { /* printf("[LEXER] COMMA\n"); */ return COMMA; }
<INSIDE_AM>"%" { /* printf("[LEXER] PERCENT\n"); */ BEGIN(INITIAL); return PERCENT; }
<INSIDE_AM>['\*'] { /* printf("[LEXER] ASTERISK\n"); */ return ASTERISK; }
<INSIDE_AM>"=" { /* printf("[LEXER] EQUALS\n"); */ return EQUALS; }
<INSIDE_AM>"$" { /* printf("[LEXER] DOLLAR_SIGN\n"); */ return DOLLAR_SIGN; }
<INSIDE_AM>[\._a-zA-Z$][\._a-zA-Z0-9]* { /* printf("[LEXER Mode:AM] NAME: %s\n", yytext); */ return NAME; }
<INSIDE_AM>"0" { /* printf("Comment: 0: %s\n", yytext); */ BEGIN(INSIDE_AM_ZERO); return AM_ZERO; }
<INSIDE_AM>"1" { /* printf("Circle: 1: %s\n", yytext); */ BEGIN(INSIDE_AM_ONE); return AM_ONE; }
<INSIDE_AM>"20" { /* printf("Vector Line: 20: %s\n", yytext); */ BEGIN(INSIDE_AM_TWENTY); return AM_TWENTY; }
<INSIDE_AM>"21" { /* printf("Center Line: 21: %s\n", yytext); */ BEGIN(INSIDE_AM_TWENTY_ONE); return AM_TWENTY_ONE; }
<INSIDE_AM>"4" { /* printf("Outline: 4: %s\n", yytext); */ BEGIN(INSIDE_AM_FOUR); return AM_FOUR; }
<INSIDE_AM>"5" { /* printf("Polygon: 5: %s\n", yytext); */ BEGIN(INSIDE_AM_FIVE); return AM_FIVE; }
<INSIDE_AM>"7" { /* printf("Thermal: 7: %s\n", yytext); */ BEGIN(INSIDE_AM_SEVEN); return AM_SEVEN; }
<INSIDE_AM>(\r\n|\n) { }
<INSIDE_AM>[ \t]+ { }

<INSIDE_AM_ZERO>[^%'\*']+ { /*printf("[LEXER] STRING: \"%s\"\n", yytext);*/ return STRING; }
<INSIDE_AM_ZERO>['\*'] { /*printf("[LEXER] ASTERISK: \"%s\"\n", yytext);*/ BEGIN(INSIDE_AM); return ASTERISK; }

<INSIDE_AM_ONE>"%" { /*printf("[LEXER] PERCENT\n");*/ return PERCENT; }
<INSIDE_AM_ONE>['\*'] { /*printf("[LEXER] ASTERISK: \"%s\"\n", yytext);*/ BEGIN(INSIDE_AM); return ASTERISK; }
<INSIDE_AM_ONE>"//".* { /* DO NOTHING */ /* lex/flex, . won't match a newline. */ /*printf("CommentText: %s\n", yytext);*/ }
<INSIDE_AM_ONE>"," { /*printf("[LEXER] COMMA\n");*/ return COMMA; }
<INSIDE_AM_ONE>[+|-] { /*printf("[LEXER] ADD_SUB_OPERATOR\n");*/ return ADD_SUB_OPERATOR; }
<INSIDE_AM_ONE>[x|\/] { /*printf("[LEXER] MUL_DIV_OPERATOR\n");*/ return MUL_DIV_OPERATOR; }
<INSIDE_AM_ONE>((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { yylval.float_val = atof(yytext); /*printf("[LEXER] UNSIGNED_DECIMAL_NUMBER - %s - %f\n", yytext, yylval.float_val);*/ return UNSIGNED_DECIMAL_NUMBER; }
<INSIDE_AM_ONE>"$" { /*printf("[LEXER] DOLLAR_SIGN\n");*/ return DOLLAR_SIGN; }

<INSIDE_AM_TWENTY>"%" { /*printf("[LEXER] PERCENT\n");*/ return PERCENT; }
<INSIDE_AM_TWENTY>['\*'] { /*printf("[LEXER] ASTERISK: \"%s\"\n", yytext);*/ BEGIN(INSIDE_AM); return ASTERISK; }
<INSIDE_AM_TWENTY>"//".* { /* DO NOTHING */ /* lex/flex, . won't match a newline. */ /*printf("CommentText: %s\n", yytext);*/ }
<INSIDE_AM_TWENTY>"," { /*printf("[LEXER] COMMA\n");*/ return COMMA; }
<INSIDE_AM_TWENTY>[+|-] { /*printf("[LEXER] ADD_SUB_OPERATOR\n");*/ return ADD_SUB_OPERATOR; }
<INSIDE_AM_TWENTY>[x|\/] { /*printf("[LEXER] MUL_DIV_OPERATOR\n");*/ return MUL_DIV_OPERATOR; }
<INSIDE_AM_TWENTY>((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { yylval.float_val = atof(yytext); /*printf("[LEXER] UNSIGNED_DECIMAL_NUMBER - %s - %f\n", yytext, yylval.float_val);*/ return UNSIGNED_DECIMAL_NUMBER; }
<INSIDE_AM_TWENTY>"$" { /*printf("[LEXER] DOLLAR_SIGN\n"); return DOLLAR_SIGN; }

<INSIDE_AM_TWENTY_ONE>"%" { /*printf("[LEXER] PERCENT\n");*/ return PERCENT; }
<INSIDE_AM_TWENTY_ONE>['\*'] { /*printf("[LEXER] ASTERISK: \"%s\"\n", yytext);*/ BEGIN(INSIDE_AM); return ASTERISK; }
<INSIDE_AM_TWENTY_ONE>"//".* { /* DO NOTHING */ /* lex/flex, . won't match a newline. */ /*printf("CommentText: %s\n", yytext);*/ }
<INSIDE_AM_TWENTY_ONE>"," { /*printf("[LEXER] COMMA\n");*/ return COMMA; }
<INSIDE_AM_TWENTY_ONE>[+|-] { /*printf("[LEXER] ADD_SUB_OPERATOR\n");*/ return ADD_SUB_OPERATOR; }
<INSIDE_AM_TWENTY_ONE>[x|\/] { /*printf("[LEXER] MUL_DIV_OPERATOR\n");*/ return MUL_DIV_OPERATOR; }
<INSIDE_AM_TWENTY_ONE>((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { yylval.float_val = atof(yytext); /*printf("[LEXER] UNSIGNED_DECIMAL_NUMBER - %s - %f\n", yytext, yylval.float_val);*/ return UNSIGNED_DECIMAL_NUMBER; }
<INSIDE_AM_TWENTY_ONE>"$" { /*printf("[LEXER] DOLLAR_SIGN\n");*/ return DOLLAR_SIGN; }

<INSIDE_AM_FOUR>"%" { /*printf("[LEXER] <INSIDE_AM_FOUR> PERCENT\n");*/ return PERCENT; }
<INSIDE_AM_FOUR>['\*'] { /*printf("[LEXER] <INSIDE_AM_FOUR> ASTERISK: \"%s\"\n", yytext);*/ BEGIN(INSIDE_AM); return ASTERISK; }
<INSIDE_AM_FOUR>"//".* { /* DO NOTHING */ /* lex/flex, . won't match a newline. */ /*printf("CommentText: %s\n", yytext);*/ }
<INSIDE_AM_FOUR>"," { /*printf("[LEXER] <INSIDE_AM_FOUR> COMMA\n");*/ return COMMA; }
<INSIDE_AM_FOUR>[+|-]?((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { /*printf("[LEXER] <INSIDE_AM_FOUR> DECIMAL_NUMBER\n");*/ yylval.float_val = atof(yytext); return DECIMAL_NUMBER; }
<INSIDE_AM_FOUR>((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { yylval.float_val = atof(yytext); /*printf("[LEXER] <INSIDE_AM_FOUR> UNSIGNED_DECIMAL_NUMBER - %s - %f\n", yytext, yylval.float_val);*/ return UNSIGNED_DECIMAL_NUMBER; }
<INSIDE_AM_FOUR>[+|-] { /*printf("[LEXER] <INSIDE_AM_FOUR> ADD_SUB_OPERATOR\n");*/ return ADD_SUB_OPERATOR; }
<INSIDE_AM_FOUR>[x|\/] { /*printf("[LEXER] <INSIDE_AM_FOUR> MUL_DIV_OPERATOR\n");*/ return MUL_DIV_OPERATOR; }
<INSIDE_AM_FOUR>"$" { /*printf("[LEXER] <INSIDE_AM_FOUR> DOLLAR_SIGN\n");*/ return DOLLAR_SIGN; }
<INSIDE_AM_FOUR>(\r\n|\n) { }
<INSIDE_AM_FOUR>[ \t]+ { }

<INSIDE_AM_FIVE>"%" { /*printf("[LEXER] <INSIDE_AM_FIVE> PERCENT\n");*/ return PERCENT; }
<INSIDE_AM_FIVE>['\*'] { /*printf("[LEXER] <INSIDE_AM_FIVE> ASTERISK: \"%s\"\n", yytext);*/ BEGIN(INSIDE_AM); return ASTERISK; }
<INSIDE_AM_FIVE>"//".* { /* DO NOTHING */ /* lex/flex, . won't match a newline. */ /*printf("CommentText: %s\n", yytext);*/ }
<INSIDE_AM_FIVE>"," { /*printf("[LEXER] <INSIDE_AM_FIVE> COMMA\n");*/ return COMMA; }
<INSIDE_AM_FIVE>[+|-]?((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { /*printf("[LEXER] <INSIDE_AM_FIVE> DECIMAL_NUMBER\n");*/ yylval.float_val = atof(yytext); return DECIMAL_NUMBER; }
<INSIDE_AM_FIVE>((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { yylval.float_val = atof(yytext); /*printf("[LEXER] <INSIDE_AM_FIVE> UNSIGNED_DECIMAL_NUMBER - %s - %f\n", yytext, yylval.float_val);*/ return UNSIGNED_DECIMAL_NUMBER; }
<INSIDE_AM_FIVE>[+|-] { /*printf("[LEXER] <INSIDE_AM_FIVE> ADD_SUB_OPERATOR\n");*/ return ADD_SUB_OPERATOR; }
<INSIDE_AM_FIVE>[x|\/] { /*printf("[LEXER] <INSIDE_AM_FIVE> MUL_DIV_OPERATOR\n");*/ return MUL_DIV_OPERATOR; }
<INSIDE_AM_FIVE>"$" { /*printf("[LEXER] <INSIDE_AM_FIVE> DOLLAR_SIGN\n");*/ return DOLLAR_SIGN; }
<INSIDE_AM_FIVE>(\r\n|\n) { }
<INSIDE_AM_FIVE>[ \t]+ { }

<INSIDE_AM_SEVEN>"%" { /*printf("[LEXER] <INSIDE_AM_SEVEN> PERCENT\n");*/ return PERCENT; }
<INSIDE_AM_SEVEN>['\*'] { /*printf("[LEXER] <INSIDE_AM_SEVEN> ASTERISK: \"%s\"\n", yytext);*/ BEGIN(INSIDE_AM); return ASTERISK; }
<INSIDE_AM_SEVEN>"//".* { /* DO NOTHING */ /* lex/flex, . won't match a newline. */ /*printf("CommentText: %s\n", yytext);*/ }
<INSIDE_AM_SEVEN>"," { /*printf("[LEXER] <INSIDE_AM_SEVEN> COMMA\n");*/ return COMMA; }
<INSIDE_AM_SEVEN>[+|-]?((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { /*printf("[LEXER] <INSIDE_AM_FOUR> DECIMAL_NUMBER\n");*/ yylval.float_val = atof(yytext); return DECIMAL_NUMBER; }
<INSIDE_AM_SEVEN>((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { yylval.float_val = atof(yytext); /*printf("[LEXER] <INSIDE_AM_FOUR> UNSIGNED_DECIMAL_NUMBER - %s - %f\n", yytext, yylval.float_val);*/ return UNSIGNED_DECIMAL_NUMBER; }
<INSIDE_AM_SEVEN>[+|-] { /*printf("[LEXER] <INSIDE_AM_SEVEN> ADD_SUB_OPERATOR\n");*/ return ADD_SUB_OPERATOR; }
<INSIDE_AM_SEVEN>[x|\/] { /*printf("[LEXER] <INSIDE_AM_SEVEN> MUL_DIV_OPERATOR\n");*/ return MUL_DIV_OPERATOR; }
<INSIDE_AM_SEVEN>((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { yylval.float_val = atof(yytext); /*printf("[LEXER] <INSIDE_AM_SEVEN> UNSIGNED_DECIMAL_NUMBER - %s - %f\n", yytext, yylval.float_val);*/ return UNSIGNED_DECIMAL_NUMBER; }
<INSIDE_AM_SEVEN>"$" { /*printf("[LEXER] <INSIDE_AM_SEVEN> DOLLAR_SIGN\n");*/ return DOLLAR_SIGN; }
<INSIDE_AM_SEVEN>(\r\n|\n) { }
<INSIDE_AM_SEVEN>[ \t]+ { }

    /*
    <INSIDE_SR>"%SR*%" { printf("[LEXER] END_SR_TOK\n"); BEGIN(INITIAL); return END_SR_TOK; }

    <INSIDE_SR>['\*'] { printf("[LEXER] ASTERISK: \"%s\"\n", yytext); return ASTERISK; }
    <INSIDE_SR>"//".* { printf("CommentText: %s\n", yytext); }
    <INSIDE_SR>"," { printf("[LEXER] COMMA\n"); return COMMA; }
    <INSIDE_SR>[+|-] { printf("[LEXER] ADD_SUB_OPERATOR\n"); return ADD_SUB_OPERATOR; }
    <INSIDE_SR>[x|\/] { printf("[LEXER] MUL_DIV_OPERATOR\n"); return MUL_DIV_OPERATOR; }
    <INSIDE_SR>((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+)) { yylval.float_val = atof(yytext); printf("[LEXER] UNSIGNED_DECIMAL_NUMBER - %s - %f\n", yytext, yylval.float_val); return UNSIGNED_DECIMAL_NUMBER; }
    */
<INSIDE_SR>("X"[0-9]+) { /*printf("[LEXER] <INSIDE_SR> X INTEGER_NUMBER\n");*/ /*yylval.int_val = atoi(yytext);*/ return SR_X_INTEGER_NUMBER; }
<INSIDE_SR>("Y"[0-9]+) { /*printf("[LEXER] <INSIDE_SR> Y INTEGER_NUMBER\n");*/ /*yylval.int_val = atoi(yytext);*/ return SR_Y_INTEGER_NUMBER; }
<INSIDE_SR>("I"[0-9]+) { /*printf("[LEXER] <INSIDE_SR> I INTEGER_NUMBER\n");*/ /*yylval.int_val = atoi(yytext);*/ return SR_I_INTEGER_NUMBER; }
<INSIDE_SR>("J"[0-9]+) { /*printf("[LEXER] <INSIDE_SR> J INTEGER_NUMBER\n");*/ /*yylval.int_val = atoi(yytext);*/ return SR_J_INTEGER_NUMBER; }
<INSIDE_SR>("*%") { /*printf("[LEXER] <INSIDE_SR> ASTERISK PERCENT\n");*/ /*yylval.int_val = atoi(yytext);*/ BEGIN(INITIAL); return SR_ASTERISK_PERCENT; }
    /*
    <INSIDE_SR>"$" { printf("[LEXER] DOLLAR_SIGN\n"); return DOLLAR_SIGN; }
    */

<INSIDE_AB>("X"[0-9]+) { /*printf("[LEXER] <INSIDE_AB> X INTEGER_NUMBER\n");*/ /*yylval.int_val = atoi(yytext);*/ return AB_X_INTEGER_NUMBER; }
<INSIDE_AB>("Y"[0-9]+) { /*printf("[LEXER] <INSIDE_AB> Y INTEGER_NUMBER\n");*/ /*yylval.int_val = atoi(yytext);*/ return AB_Y_INTEGER_NUMBER; }
<INSIDE_AB>("I"[0-9]+) { /*printf("[LEXER] <INSIDE_AB> I INTEGER_NUMBER\n");*/ /*yylval.int_val = atoi(yytext);*/ return AB_I_INTEGER_NUMBER; }
<INSIDE_AB>("J"[0-9]+) { /*printf("[LEXER] <INSIDE_AB> J INTEGER_NUMBER\n");*/ /*yylval.int_val = atoi(yytext);*/ return AB_J_INTEGER_NUMBER; }
<INSIDE_AB>("*%") { /*printf("[LEXER] <INSIDE_AB> ASTERISK PERCENT\n");*/ /*yylval.int_val = atoi(yytext);*/ BEGIN(INITIAL); return AB_ASTERISK_PERCENT; }
<INSIDE_AB>"D"[0-9][0-9]+ {
    /*yylval.int_val = atoi(yytext);*/
    std::memset(yylval.string_val, 0, STRING_BUFFER_LENGTH);
    std::memcpy(yylval.string_val, yytext, std::strlen(yytext));
    //printf("[LEXER] <INSIDE_AB> APERTURE_IDENT: %s\n", yylval.string_val);
    /*printf("[LEXER] <INSIDE_AB> APERTURE_IDENT: %s\n", yytext);*/
    return APERTURE_IDENT;
}

(\r\n|\n) { }
[ \t]+ { }

"G04"[^"*"]*"*" { /*printf("[LEXER] G04 Comment: \"%s\"\n", yytext);*/ return G04_COMMENT; }

<<EOF>> { static int once = 0; once++; if (once) { return EOF; } else { return '\n'; } }

. { /*printf("yytext\n");*/ return *yytext; }

%%

/* [0-9]*[1-9][0-9]* { printf("[LEXER] POSITIVE_INTEGER\n"); yylval.int_val = atoi(yytext); return POSITIVE_INTEGER; } */
/* <INSIDE_AM_ONE>[0-9]*[1-9][0-9]* { printf("[LEXER] POSITIVE_INTEGER\n"); yylval.int_val = atoi(yytext); return POSITIVE_INTEGER; } */
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