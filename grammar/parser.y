// source: https://www.ucamco.com/files/downloads/file_en/415/the-gerber-parsing-expression-grammar_en.ebnf?79d8bb116dd0168c5b920615a89297a7

%{

#include <iostream>
#include <iomanip>

#include <stdio.h>
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
    float float_val;
    char string_val[100];
    char sym;
    //node_t* expr_ptr;
};

%type<int_val> factor

%token <int_val> COORDINATE_DIGITS;

/* POSITIVE_INTEGER */
%token <int_val> INTEGER_NUMBER SIGNED_INTEGER_NUMBER DECIMAL_NUMBER
%token <float_val> UNSIGNED_DECIMAL_NUMBER;

%token <string_val> APERTURE_IDENT APERTURE_IDENT_MOVE APERTURE_IDENT_SEGMENT APERTURE_IDENT_FLASH;
%token <string_val> USER_NAME FIELD NAME STRING

%token <sym> END_OF_FILE
%token <sym> PERCENT ASTERISK ASTERISK_PERCENT
%token <sym> DOT_PART DOT_FILEFUNCTION DOT_FILEPOLARITY DOT_SAMECOORDINATES DOT_CREATIONDATE DOT_GENERATIONSOFTWARE DOT_PROJECTID DOT_MD5
%token <sym> DOT_APERFUNCTION DOT_DRILLTOLERANCE DOT_FLASHTEXT
%token <sym> DOT_N DOT_P DOT_C DOT_CROT DOT_CMFR DOT_CMPN DOT_CVAL DOT_CMNT DOT_CFTP DOT_CPGN DOT_CPGD DOT_CHGT DOT_CLBN DOT_CLBD DOT_CSUP
%token <sym> G04_COMMENT COMMENT HASHTAG_COMMENT
%token <sym> AD_TOK TF_TOK TA_TOK TO_TOK AM_TOK C LP_TOK DARK CLEAR LM_TOK LR_TOK LS_TOK
%token <sym> NEW_LINE
%token <sym> DOT COLON COMMA OPENING_BRACKET CLOSING_BRACKET EQUALS DOLLAR_SIGN
%token <sym> INTERPOLATION_LINEAR INTERPOLATION_CW_CIRCULAR INTERPOLATION_CCW_CIRCULAR INTERPOLATION_BEFORE_FIRST_CIRCULAR_COMPAT
%token <sym> POLARITY_CLEAR POLARITY_DARK
%token <sym> ADD_SUB_OPERATOR MUL_DIV_OPERATOR

/* Deprecated Commands */
%token <sym> REGION_STATEMENT_START REGION_STATEMENT_END SELECT_APERTURE SET_COORD_FMT_ABSOLUTE SET_COORD_FMT_INCREMENTAL SET_UNIT_INCH SET_UNIT_MM PROGRAM_STOP

%token <sym> AM_ZERO AM_ONE AM_TWENTY AM_TWENTY_ONE

%%

start_symbol
    : statements M02
    ;

M02
    : END_OF_FILE '*' { std::cout << "[PARSER] M02 END_OF_FILE" << std::endl; }
    ;

/*
comment
    : HASHTAG_COMMENT
    ;
*/

statements
    : statement
    | statements statement
    ;

statement
    : single_statement { std::cout << "single_statement" << std::endl; }
    | compound_statement
    ;

single_statement
    : operation { std::cout << "[PARSER] single_statement.operation" << std::endl; }
    | interpolation_state_command { std::cout << "[PARSER] single_statement.interpolation_state_command" << std::endl; }
    | Dnn { std::cout << "[PARSER] single_statement.Dnn" << std::endl; }
    | G04 { std::cout << "[PARSER] single_statement.G04" << std::endl; }
    | attribute_command { std::cout << "[PARSER] single_statement.attribute_command" << std::endl; }
    | AD { std::cout << "[PARSER] single_statement.AD" << std::endl; }
    | AM { std::cout << "[PARSER] single_statement.AM" << std::endl; }
    | coordinate_command { std::cout << "[PARSER] single_statement.coordinate_command" << std::endl; }
    | transformation_state_command { std::cout << "[PARSER] single_statement.transformation_state_command" << std::endl; }
    | deprecated { std::cout << "[PARSER] single_statement.deprecated" << std::endl; }
    ;

deprecated
    : SELECT_APERTURE APERTURE_IDENT '*' { std::cout << "deprecated.SELECT_APERTURE(G54)" << std::endl; }
    | SET_UNIT_INCH APERTURE_IDENT_MOVE '*' { std::cout << "deprecated.SET_UNIT_INCH(G70)" << std::endl; }
    | SET_UNIT_MM APERTURE_IDENT_MOVE '*' { std::cout << "deprecated.SET_UNIT_MM(G71)" << std::endl; }
    | SET_COORD_FMT_ABSOLUTE '*' { std::cout << "deprecated.SET_COORD_FMT_ABSOLUTE(G90)" << std::endl; }
    | SET_COORD_FMT_INCREMENTAL '*' { std::cout << "deprecated.SET_COORD_FMT_INCREMENTAL(G91)" << std::endl; }
    | PROGRAM_STOP '*' { std::cout << "deprecated.PROGRAM_STOP" << std::endl; }
    ;

compound_statement
    : region_statement
//    | SR_statement
//    | AB_statement
    ;

coordinate_command
    : FS { std::cout << "[PARSER] coordinate_command" << std::endl; }
    | MO
    ;

operation
    : D01 { std::cout << "[PARSER] operation.D01" << std::endl; }
    | D02 { std::cout << "[PARSER] operation.D02" << std::endl; }
    | D03 { std::cout << "[PARSER] operation.D03" << std::endl; }
    ;

interpolation_state_command
    : G01
    | G02
    | G03
    | G75
    ;

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

D01_Y
    : Y_C APERTURE_IDENT_SEGMENT '*'
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
*/

D02
    : D02_X { std::cout << "D02_X" << std::endl; }
    | D02_Y { std::cout << "D02_Y" << std::endl; }
    | D02_X_Y { std::cout << "D02_X_Y" << std::endl; }
    ;

D02_Y
    : Y_C APERTURE_IDENT_MOVE '*'
    ;

D02_X
    : X_C APERTURE_IDENT_MOVE '*'
    ;

D02_X_Y
    : X_C Y_C APERTURE_IDENT_MOVE '*'
    ;

/*
D03
    : X_Y_PREFIX APERTURE_IDENT_FLASH { std::cout << "D03" << std::endl; } '*' { std::cout << "*" << std::endl; }
    ;
    */

D03
    : D03_X { std::cout << "D03_X" << std::endl; }
    | D03_Y { std::cout << "D03_Y" << std::endl; }
    | D03_X_Y { std::cout << "D03_X_Y" << std::endl; }
    ;

D03_Y
    : Y_C APERTURE_IDENT_FLASH '*'
    ;

D03_X
    : X_C APERTURE_IDENT_FLASH '*'
    ;

D03_X_Y
    : X_C Y_C APERTURE_IDENT_FLASH '*' { std::cout << "D03_X_Y" << std::endl; }
    ;

X_C
    : 'X' INTEGER_NUMBER { std::cout << "X_C" << std::endl; }
    ;

/*
Y_C
    : 'Y' INTEGER_NUMBER { std::cout << "Y_C" << std::endl; }
    ;
*/

Y_C
    : 'Y' SIGNED_INTEGER_NUMBER { std::cout << "Y_C" << std::endl; }
    ;

/*
X_Y_PREFIX
    : 'X' { std::cout << "X=" << std::endl; } INTEGER_NUMBER 'Y' { std::cout << "Y=" << std::endl; } INTEGER_NUMBER
    ;
*/

/* G01 and deprecated combined syntax (spec page 190) */
G01
    : INTERPOLATION_LINEAR '*' { std::cout << "INTERPOLATION_LINEAR" << std::endl; }
    | INTERPOLATION_LINEAR D01_X_Y { std::cout << "DEPRECATED INTERPOLATION_LINEAR D01_X_Y" << std::endl; }
    | INTERPOLATION_LINEAR D02_X_Y { std::cout << "DEPRECATED INTERPOLATION_LINEAR D02_X_Y" << std::endl; }
    | INTERPOLATION_LINEAR D03_X_Y { std::cout << "DEPRECATED INTERPOLATION_LINEAR D03_X_Y" << std::endl; }
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

Dnn
    : APERTURE_IDENT '*' { std::cout << "Dnn" << std::endl; }
    ;

G04
    : G04_COMMENT { std::cout << "G04_COMMENT" << std::endl; }
    ;

/*
M02 = ('M02') '*';
*/

LP
    : LP_TOK CLEAR ASTERISK_PERCENT { std::cout << "LP.CLEAR" << std::endl; }
    | LP_TOK DARK ASTERISK_PERCENT { std::cout << "LP.DARK" << std::endl; }
    ;

LM
    : LM_TOK 'N' ASTERISK_PERCENT
    | LM_TOK 'X''Y' ASTERISK_PERCENT
    | LM_TOK 'Y' ASTERISK_PERCENT
    | LM_TOK 'X' ASTERISK_PERCENT
    ;

LR
    : LR_TOK UNSIGNED_DECIMAL_NUMBER ASTERISK_PERCENT
    ;

LS
    : LS_TOK UNSIGNED_DECIMAL_NUMBER ASTERISK_PERCENT
    ;

AD
    : AD_TOK APERTURE_IDENT template_call ASTERISK_PERCENT { std::cout << "[Parser] AD Rule" << std::endl; };
    ;

//#aperture_shape = name [',' decimal {'X' decimal}*];

template_call
   : C fst_par { std::cout << "[Parser] template_call Rule" << std::endl; };
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

//# Macro Definition
//#-------------------

AM
    : AM_TOK macro_name macro_body PERCENT { std::cout << "[Parser] AM Rule" << std::endl; }
    ;

macro_name
    : NAME ASTERISK { std::cout << "[Parser] macro_name Rule" << std::endl; }
    ;

macro_body
    : in_macro_block
    | macro_body in_macro_block
    ;

in_macro_block
    : primitive
    | variable_definition
    ;

variable_definition
    : macro_variable EQUALS expression ASTERISK
    ;

macro_variable
    : DOLLAR_SIGN UNSIGNED_DECIMAL_NUMBER
    ;

primitive
    : AM_ZERO STRING ASTERISK { std::cout << "[Parser] primitive-0 Rule" << std::endl; }
    | AM_ONE par par par par ASTERISK { std::cout << "[Parser] primitive-1/1 Rule" << std::endl; }
    | AM_ONE par par par par par ASTERISK { std::cout << "[Parser] primitive-1/2 Rule" << std::endl; }
    | AM_TWENTY par { std::cout << "[Parser] PAR-1 value=" << $1 << std::endl; } par par par par par par ASTERISK { std::cout << "[Parser] primitive-20 Rule" << std::endl; }
    | AM_TWENTY_ONE par par par par par par ASTERISK
    | '4' par par par par primitive_four_list par ASTERISK
    | '5' par par par par par par ASTERISK
    | '7' par par par par par par ASTERISK
    ;

primitive_four_list
    : primitive_four_list primitive_four
    | primitive_four
    ;

primitive_four
    : par par
    ;

par
    : COMMA expression
    ;



//# Compound statements

region_statement
    : G36 contour_list G37 { std::cout << "[Parser] region_statement Rule" << std::endl; }
    ;

contour_list
    : contour_list contour
    | contour
    ;

contour
    : D02 d01_list
    | D02 interpolation_state_command_list
    ;

d01_list
    : d01_list D01
    | D01
    ;

interpolation_state_command_list
    : interpolation_state_command_list interpolation_state_command
    | interpolation_state_command
    ;

G36
    : REGION_STATEMENT_START '*'
    ;

G37
    : REGION_STATEMENT_END '*'
    ;

/*
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

*/

//# Attribute commands
//#-------------------

TF
    : TF_TOK TF_atts ASTERISK_PERCENT
    ;

TA
    : TA_TOK TA_atts ASTERISK_PERCENT
    ;

TO
    : TO_TOK TO_atts ASTERISK_PERCENT
    ;

TD
    : '%' 'T''D' all_atts '*''%'
    ;

TF_atts
    : DOT_PART                  nxt_field { std::cout << "[PARSER] DOT_PART" << std::endl; }
    | DOT_FILEFUNCTION          nxt_fields { std::cout << "[PARSER] DOT_FILEFUNCTION" << std::endl; }
    | DOT_FILEPOLARITY          nxt_field { std::cout << "[PARSER] DOT_FILEPOLARITY" << std::endl; }
    | DOT_SAMECOORDINATES                   { std::cout << "[PARSER] DOT_SAMECOORDINATES 0" << std::endl; }
    | DOT_SAMECOORDINATES       nxt_field   { std::cout << "[PARSER] DOT_SAMECOORDINATES 1" << std::endl; }
    | DOT_CREATIONDATE          nxt_field   { std::cout << "[PARSER] DOT_CREATIONDATE" << std::endl; }
    | DOT_GENERATIONSOFTWARE    nxt_field nxt_field { std::cout << "[PARSER] DOT_GENERATIONSOFTWARE 2" << std::endl; }
    | DOT_GENERATIONSOFTWARE    nxt_field nxt_field nxt_field { std::cout << "[PARSER] DOT_GENERATIONSOFTWARE 3" << std::endl; }
    | DOT_PROJECTID             nxt_field nxt_field nxt_field   { std::cout << "[PARSER] DOT_PROJECTID" << std::endl; }
    | DOT_MD5                   nxt_field   { std::cout << "[PARSER] DOT_MD5" << std::endl; }
    | USER_NAME { std::cout << "[PARSER] USER_NAME" << std::endl; }
    ;

TA_atts
    : DOT_APERFUNCTION          nxt_fields
    | DOT_DRILLTOLERANCE        nxt_field nxt_field
    | DOT_FLASHTEXT             nxt_fields
    | USER_NAME                 nxt_fields
    ;

TO_atts
    : DOT_N                     nxt_field nxt_fields { std::cout << "[PARSER] TO_atts DOT_N" << std::endl; }
    | DOT_P                     nxt_field nxt_field { std::cout << "[PARSER] TO_atts DOT_P 1" << std::endl; }
    | DOT_P                     nxt_field nxt_field nxt_field { std::cout << "[PARSER] TO_atts DOT_P 2" << std::endl; }
    | DOT_C                     nxt_field { std::cout << "[PARSER] TO_atts DOT_C" << std::endl; }
    | DOT_CROT                  nxt_field { std::cout << "[PARSER] TO_atts DOT_CROT" << std::endl; }
    | DOT_CMFR                  nxt_field { std::cout << "[PARSER] TO_atts DOT_CMFR" << std::endl; }
    | DOT_CMPN                  nxt_field { std::cout << "[PARSER] TO_atts DOT_CMPN" << std::endl; }
    | DOT_CVAL                  nxt_field { std::cout << "[PARSER] TO_atts DOT_CVAL" << std::endl; }
    | DOT_CMNT                  nxt_field { std::cout << "[PARSER] TO_atts DOT_CMNT" << std::endl; }
    | DOT_CFTP                  nxt_field { std::cout << "[PARSER] TO_atts DOT_CFTP" << std::endl; }
    | DOT_CPGN                  nxt_field { std::cout << "[PARSER] TO_atts DOT_CPGN" << std::endl; }
    | DOT_CPGD                  nxt_field { std::cout << "[PARSER] TO_atts DOT_CPGD" << std::endl; }
    | DOT_CHGT                  nxt_field { std::cout << "[PARSER] TO_atts DOT_CHGT" << std::endl; }
    | DOT_CLBN                  nxt_field { std::cout << "[PARSER] TO_atts DOT_CLBN" << std::endl; }
    | DOT_CLBD                  nxt_field { std::cout << "[PARSER] TO_atts DOT_CLBD" << std::endl; }
    | DOT_CSUP                  double_nextfield_list { std::cout << "[PARSER] TO_atts DOT_CSUP" << std::endl; }
    | USER_NAME                 nextfield_list { std::cout << "[PARSER] TO_atts USER_NAME" << std::endl; }
    ;

nextfield_list
    : nxt_field
    | nextfield_list nxt_field
    ;

double_nextfield_list
    : nxt_field nxt_field
    | double_nextfield_list nxt_field nxt_field
    ;

all_atts
    : TF_atts
    | TA_atts
    | TO_atts
    ;

nxt_field
    : COMMA FIELD
    ;

nxt_fields
    : nxt_field
    | nxt_fields nxt_field
    ;

//# Expressions
//#------------

expression
    : add_sub_term_list
    | term
    ;

add_sub_term_list
    : term ADD_SUB_OPERATOR add_sub_term_list
    | term
    ;

term
    : term MUL_DIV_OPERATOR factor
    | factor
    ;

/*
factor
    : '(' '~' expression ')'
    | macro_variable
    | UNSIGNED_DECIMAL_NUMBER
    ;
*/

/* https://stackoverflow.com/questions/52807994/implementing-multiple-return-types-in-bison-semantic-rules */
factor
    : macro_variable { std::cout << "[Parser] factor.macro_variable Rule" << std::endl; }
    | UNSIGNED_DECIMAL_NUMBER { std::cout << "[Parser] factor value=" << std::setprecision(10) << $1 << std::endl; $$ = $1; }
    ;

/*
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