// source: https://www.ucamco.com/files/downloads/file_en/415/the-gerber-parsing-expression-grammar_en.ebnf?79d8bb116dd0168c5b920615a89297a7

%{

#include <iostream>

#include <stdio.h>
//#include <cstring>
#include <cstdint>

#define YYDEBUG 1
#define YYERROR_VERBOSE 1

extern int yylineno;

//-- Lexer prototype required by bison, aka getNextToken()
int yylex();
int yyerror(const char *p) { printf("yyerror() - Error! '%s' | Line: %d \n", p, yylineno); return 1; }

%}

%locations

%union {
    uint32_t int_val;
    char string_val[100];
    char sym;
    //node_t* expr_ptr;
};

%token <int_val> COORDINATE_DIGITS;
%token <int_val> INTEGER_NUMBER DECIMAL_NUMBER;
%token <string_val> APERTURE_IDENT APERTURE_IDENT_MOVE APERTURE_IDENT_SEGMENT APERTURE_IDENT_FLASH;

%token <sym> G04_COMMENT COMMENT HASHTAG_COMMENT
%token <sym> AD_TOK
%token <sym> NEW_LINE
%token <sym> DOT COLON COMMA OPENING_BRACKET CLOSING_BRACKET
%token <sym> INTERPOLATION_LINEAR INTERPOLATION_CW_CIRCULAR INTERPOLATION_CCW_CIRCULAR INTERPOLATION_BEFORE_FIRST_CIRCULAR_COMPAT

%%

start_symbol
    : statements
    ;

statements
    : statement
    | hash_tag_comments
    | statements NEW_LINE statement
    | statements NEW_LINE hash_tag_comments
    ;

hash_tag_comments
    : HASHTAG_COMMENT
    | hash_tag_comments HASHTAG_COMMENT
    ;

statement
    : single_statement { std::cout << "single_statement" << std::endl; }
//    | compound_statement
    ;

single_statement
    :
    operation { std::cout << "operation" << std::endl; }
    | interpolation_state_command { std::cout << "interpolation_state_command" << std::endl; }
    | Dnn
    | G04
//    | attribute_command
    | AD
//    | AM
    | coordinate_command
//    | transformation_state_command
    ;

/* compound_statement
    : region_statement
    | SR_statement
    | AB_statement
    ; */

coordinate_command
    : FS
    | MO
    ;

operation
    : D01 { std::cout << "operation.D01" << std::endl; }
    /* | D02 { std::cout << "operation.D02" << std::endl; }
    | D03 { std::cout << "operation.D03" << std::endl; } */
    ;

interpolation_state_command
    : G01
    | G02
    | G03
    | G75
    ;
/*
transformation_state_command
    : LP
    | LM
    | LR
    | LS
    ;

attribute_command
    : TO
    | TD
    | TA
    | TF
    ;
*/

//# Graphics commands
//#------------------

FS
    : '%' 'F''S' 'L''A' 'X' COORDINATE_DIGITS 'Y' COORDINATE_DIGITS '*''%' { std::cout << "FS " << $7 << " " << $9 << std::endl; }
    ;
MO
    : '%' 'M''O''M''M' '*''%' { std::cout << "MOMM" << std::endl; };
    | '%' 'M''O''I''N' '*''%' { std::cout << "MOIN" << std::endl; };
    ;

D01_X_I_J
    : X_C I_C J_C APERTURE_IDENT_SEGMENT '*'
    ;

D01_Y_I_J
    : Y_C I_C J_C APERTURE_IDENT_SEGMENT '*'
    ;

D01_X_Y_I_J
    : X_C Y_C I_C J_C APERTURE_IDENT_SEGMENT '*'
    ;

D01_X_Y
    : X_C Y_C APERTURE_IDENT_SEGMENT '*'
    ;

D01_X
    : X_C APERTURE_IDENT_SEGMENT '*'
    ;

X_C
    : 'X' INTEGER_NUMBER
    ;

D01_Y
    : Y_C APERTURE_IDENT_SEGMENT '*'
    ;

Y_C
    : 'Y' INTEGER_NUMBER
    ;

D01_X
    : X_C APERTURE_IDENT_SEGMENT '*'
    ;

X_C
    : 'X' INTEGER_NUMBER
    ;

D01_I_J
    : I_C J_C APERTURE_IDENT_SEGMENT '*'
    ;

I_C
    : 'I' INTEGER_NUMBER
    ;

J_C
    : 'J' INTEGER_NUMBER
    ;

D01
    : D01_X { std::cout << "D01_X" << std::endl; }
    | D01_Y { std::cout << "D01_Y" << std::endl; }
    | D01_X_Y { std::cout << "D01_X_Y" << std::endl; }
    | D01_I_J { std::cout << "D01_I_J" << std::endl; }
    | D01_X_I_J { std::cout << "D01_X_I_J" << std::endl; }
    | D01_Y_I_J { std::cout << "D01_Y_I_J" << std::endl; }
    | D01_X_Y_I_J { std::cout << "D01_X_Y_I_J" << std::endl; }
    ;

/*
D01 = (['X' integer] ['Y' integer] ['I' integer 'J' integer] 'D01') '*';

D01
    : 'I' { std::cout << "I=" << std::endl; } INTEGER_NUMBER { std::cout << "INTEGER_NUMBER" << std::endl; } 'J' { std::cout << "J=" << std::endl; } INTEGER_NUMBER { std::cout << "INTEGER_NUMBER" << std::endl; } APERTURE_IDENT_SEGMENT '*'
    | X_Y_PREFIX { std::cout << "X_Y_PREFIX" << std::endl; } APERTURE_IDENT_SEGMENT '*'
    | X_Y_PREFIX { std::cout << "X_Y_PREFIX" << std::endl; } 'I' INTEGER_NUMBER 'J' INTEGER_NUMBER APERTURE_IDENT_SEGMENT '*'
    ;

D02
    : X_Y_PREFIX APERTURE_IDENT_MOVE '*'
    ;

D03
    : X_Y_PREFIX APERTURE_IDENT_FLASH { std::cout << "D03" << std::endl; } '*' { std::cout << "*" << std::endl; }
    ;
    */

X_Y_PREFIX
    : 'X' { std::cout << "X=" << std::endl; } INTEGER_NUMBER 'Y' { std::cout << "Y=" << std::endl; } INTEGER_NUMBER
    ;

G01
    : INTERPOLATION_LINEAR '*' { std::cout << "INTERPOLATION_LINEAR" << std::endl; }
    ;

G02
    : INTERPOLATION_CW_CIRCULAR '*' { std::cout << "INTERPOLATION_CW_CIRCULAR" << std::endl; }
    ;

G03
    : INTERPOLATION_CCW_CIRCULAR '*' { std::cout << "INTERPOLATION_CCW_CIRCULAR" << std::endl; }
    ;

G75
    : INTERPOLATION_BEFORE_FIRST_CIRCULAR_COMPAT '*' { std::cout << "INTERPOLATION_BEFORE_FIRST_CIRCULAR_COMPAT" << std::endl; }
    ;

Dnn : APERTURE_IDENT '*' { std::cout << "Dnn" << std::endl; };

G04 :
    G04_COMMENT { std::cout << "G04_COMMENT" << std::endl; };
    ;
/*
M02 = ('M02') '*';

LP = '%' ('LP' ('C'|'D')) '*%';
LM = '%' ('LM' ('N'|'XY'|'Y'|'X')) '*%';
LR = '%' ('LR' decimal) '*%';
LS = '%' ('LS' decimal) '*%';
*/

AD
    : '%' AD_TOK APERTURE_IDENT template_call '*''%' { std::cout << "AD" << std::endl; };
    ;

//#aperture_shape = name [',' decimal {'X' decimal}*];

template_call
   : 'C' fst_par
   //| 'C' fst_par nxt_par
   //| 'R' fst_par nxt_par [nxt_par]
   //| 'O' fst_par nxt_par [nxt_par]
   //| 'P' fst_par nxt_par [nxt_par [nxt_par]]
   //| !(('C'|'R'|'O'|'P')(','|'*')) name [fst_par {nxt_par}*]
   ;

fst_par
    : COMMA DECIMAL_NUMBER
    ;

nxt_par
    : 'X' DECIMAL_NUMBER
    ;

/*

AM = '%' ('AM' macro_name macro_body) '%';

macro_name = name '*';

macro_body = {in_macro_block}+;

in_macro_block =
    | primitive
    | variable_definition
    ;

variable_definition = (macro_variable '=' expression) '*';

macro_variable = '$' positive_integer;

primitive =
    |('0'  string) '*'
    |('1'  par par par par [par]) '*'
    |('20' par par par par par par par) '*'
    |('21' par par par par par par) '*'
    |('4'  par par par par {par par}+ par) '*'
    |('5'  par par par par par par) '*'
    |('7'  par par par par par par) '*'
    ;

par = ',' (expression);

//# Compound statements

region_statement = G36 {contour}+ G37;
contour =          D02 {D01|interpolation_state_command}*;
G36 = ('G36') '*';
G37 = ('G37') '*';

AB_statement = AB_open {in_block_statement}* AB_close;
AB_open  =     '%' ('AB' aperture_ident) '*%';
AB_close =     '%' ('AB') '*%';

SR_statement = SR_open {in_block_statement}* SR_close;
SR_open =      '%' ('SR' 'X' positive_integer 'Y' positive_integer 'I' decimal 'J' decimal) '*%';
SR_close =     '%' ('SR') '*%';

in_block_statement =
    |single_statement
    |region_statement
    |AB_statement
    ;


//# Attribute commands
//#-------------------

TF = '%' ('TF' TF_atts) '*%';
TA = '%' ('TA' TA_atts) '*%';
TO = '%' ('TO' TO_atts) '*%';
TD = '%' ('TD' [all_atts]) '*%';

TF_atts =
    |'.Part'                nxt_field
    |'.FileFunction'       {nxt_field}*
    |'.FilePolarity'        nxt_field
    |'.SameCoordinates'    [nxt_field]
    |'.CreationDate'        nxt_field
    |'.GenerationSoftware'  nxt_field nxt_field [nxt_field]
    |'.ProjectId'           nxt_field nxt_field  nxt_field
    |'.MD5'                 nxt_field
    |user_name
    ;
TA_atts =
    |'.AperFunction'   {nxt_field}*
    |'.DrillTolerance'  nxt_field   nxt_field
    |'.FlashText'      {nxt_field}*
    |user_name         {nxt_field}*
    ;
TO_atts =
    |'.N'     nxt_field   {nxt_field}*
    |'.P'     nxt_field    nxt_field   [nxt_field]
    |'.C'     nxt_field
    |'.CRot'  nxt_field
    |'.CMfr'  nxt_field
    |'.CMPN'  nxt_field
    |'.CVal'  nxt_field
    |'.CMnt'  nxt_field
    |'.CFtp'  nxt_field
    |'.CPgN'  nxt_field
    |'.CPgD'  nxt_field
    |'.CHgt'  nxt_field
    |'.CLbN'  nxt_field
    |'.CLbD'  nxt_field
    |'.CSup'  nxt_field nxt_field {nxt_field nxt_field}*
    |user_name {nxt_field}*
    ;
all_atts =
    |TF_atts
    |TA_atts
    |TO_atts
    ;
nxt_field = ',' field;

//# Expressions
//#------------

expression =
    |{addsub_operator term}+
    |expression addsub_operator term
    |term
    ;
term =
    |term muldiv_operator factor
    |factor
    ;
factor =
    | '(' ~ expression ')'
    |macro_variable
    |unsigned_decimal
    ;

//# Tokens, by regex
//#-----------------

addsub_operator = /[+-]/;
muldiv_operator = /[x\/]/;

unsigned_integer =       /[0-9]+/;
positive_integer =       /[0-9]*[1-9][0-9]* /;
integer          =  /[+-]?[0-9]+/;
unsigned_decimal =      /((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+))/;
decimal          = /[+-]?((([0-9]+)(\.[0-9]*)?)|(\.[0-9]+))/;

aperture_ident = /D[0-9]{2,}/;

name      = /[._a-zA-Z$][._a-zA-Z0-9]* /;
user_name =  /[_a-zA-Z$][._a-zA-Z0-9]* /; # Cannot start with a dot
string    = /[^%*]* /; # All characters except * %
field     = /[^%*,]* /; # All characters except * % ,
*/
%%