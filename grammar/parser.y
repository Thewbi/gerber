// source: https://www.ucamco.com/files/downloads/file_en/415/the-gerber-parsing-expression-grammar_en.ebnf?79d8bb116dd0168c5b920615a89297a7

%{

#include <iostream>
#include <iomanip>
#include <string>

#include <stdio.h>
#include <cstdint>

#include "constants.h"

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
    char string_val[STRING_BUFFER_LENGTH];
    char sym;
};

/* -------------- Define return types for rules --------------------------- */
%type<int_val> factor
%type <int_val> x_c y_c


/* -------------- Define types for token ---------------------------------- */

%token <int_val> COORDINATE_DIGITS;

/* POSITIVE_INTEGER */
%token <int_val> INTEGER_NUMBER SIGNED_INTEGER_NUMBER

%token <float_val> UNSIGNED_DECIMAL_NUMBER DECIMAL_NUMBER

%token <string_val> APERTURE_IDENT APERTURE_IDENT_MOVE APERTURE_IDENT_SEGMENT APERTURE_IDENT_FLASH
%token <string_val> USER_NAME FIELD NAME STRING
%token <string_val> AD_NAME

%token <sym> END_OF_FILE
%token <sym> PERCENT ASTERISK ASTERISK_PERCENT
%token <sym> DOT_PART DOT_FILEFUNCTION DOT_FILEPOLARITY DOT_SAMECOORDINATES DOT_CREATIONDATE DOT_GENERATIONSOFTWARE DOT_PROJECTID DOT_MD5
%token <sym> DOT_APERFUNCTION DOT_DRILLTOLERANCE DOT_FLASHTEXT
%token <sym> DOT_N DOT_P DOT_C DOT_CROT DOT_CMFR DOT_CMPN DOT_CVAL DOT_CMNT DOT_CFTP DOT_CPGN DOT_CPGD DOT_CHGT DOT_CLBN DOT_CLBD DOT_CSUP
%token <sym> G04_COMMENT COMMENT HASHTAG_COMMENT
%token <sym> AB_TOK AD_TOK AD_X TF_TOK TA_TOK TO_TOK TD_TOK AM_TOK C LP_TOK DARK CLEAR LM_TOK LR_TOK LS_TOK SR_TOK END_SR_TOK
%token <sym> NEW_LINE
%token <sym> DOT COLON COMMA OPENING_BRACKET CLOSING_BRACKET EQUALS DOLLAR_SIGN
%token <sym> INTERPOLATION_LINEAR INTERPOLATION_CW_CIRCULAR INTERPOLATION_CCW_CIRCULAR INTERPOLATION_BEFORE_FIRST_CIRCULAR_COMPAT
%token <sym> POLARITY_CLEAR POLARITY_DARK
%token <sym> ADD_SUB_OPERATOR MUL_DIV_OPERATOR

/* Deprecated Commands */
%token <sym> REGION_STATEMENT_START REGION_STATEMENT_END SELECT_APERTURE SET_COORD_FMT_ABSOLUTE SET_COORD_FMT_INCREMENTAL SET_UNIT_INCH SET_UNIT_MM PROGRAM_STOP IMAGE_POLARITY IMAGE_NAME

%token <sym> AM_ZERO AM_ONE AM_TWENTY AM_TWENTY_ONE AM_FOUR AM_FIVE AM_SEVEN

%token <sym> SR_X_INTEGER_NUMBER SR_Y_INTEGER_NUMBER SR_I_INTEGER_NUMBER SR_J_INTEGER_NUMBER SR_ASTERISK_PERCENT

%token <sym> AB_X_INTEGER_NUMBER AB_Y_INTEGER_NUMBER AB_I_INTEGER_NUMBER AB_J_INTEGER_NUMBER AB_ASTERISK_PERCENT

%%

start_symbol
    : statements M02
    ;

M02
    : END_OF_FILE '*' { /* std::cout << "[PARSER] M02 END_OF_FILE" << std::endl; */ }
    ;

statements
    : statement
    | statements statement
    ;

statement
    : single_statement { /* std::cout << "[PARSER] single_statement" << std::endl; */ }
    | compound_statement
    ;

single_statement
    : operation { /* std::cout << "[PARSER] single_statement.operation" << std::endl; */ }
    | interpolation_state_command { /* std::cout << "[PARSER] single_statement.interpolation_state_command" << std::endl; */ }
    | Dnn { /* std::cout << "[PARSER] single_statement.Dnn" << std::endl; */ }
    | G04 { /* std::cout << "[PARSER] single_statement.G04" << std::endl; */ }
    | attribute_command { /* std::cout << "[PARSER] single_statement.attribute_command" << std::endl; */ }
    | AD { /* std::cout << "[PARSER] single_statement.AD" << std::endl; */ }
    | AM { /* std::cout << "[PARSER] single_statement.AM" << std::endl; */ }
    | coordinate_command { /* std::cout << "[PARSER] single_statement.coordinate_command" << std::endl; */ }
    | transformation_state_command { /* std::cout << "[PARSER] single_statement.transformation_state_command" << std::endl; */ }
    | deprecated { /* std::cout << "[PARSER] single_statement.deprecated" << std::endl; */ }
    ;

deprecated
    : SELECT_APERTURE APERTURE_IDENT '*' { /* std::cout << "deprecated.SELECT_APERTURE(G54)" << std::endl; */ }
    | SET_UNIT_INCH APERTURE_IDENT_MOVE '*' { /* std::cout << "deprecated.SET_UNIT_INCH(G70)" << std::endl; */ }
    | SET_UNIT_MM APERTURE_IDENT_MOVE '*' { /* std::cout << "deprecated.SET_UNIT_MM(G71)" << std::endl; */ }
    | SET_COORD_FMT_ABSOLUTE '*' { /* std::cout << "deprecated.SET_COORD_FMT_ABSOLUTE(G90)" << std::endl; */ }
    | SET_COORD_FMT_INCREMENTAL '*' { /* std::cout << "deprecated.SET_COORD_FMT_INCREMENTAL(G91)" << std::endl; */ }
    | PROGRAM_STOP '*' { /* std::cout << "deprecated.PROGRAM_STOP" << std::endl; */ }
    | '%' IMAGE_POLARITY pos_neg '*''%' { /* std::cout << "deprecated.IMAGE_POLARITY" << std::endl; */ }
    | '%' IMAGE_NAME '*''%' { /* std::cout << "deprecated.IMAGE_NAME" << std::endl; */ }
    ;

pos_neg
    : 'P''O''S'
    | 'N''E''G'
    ;

compound_statement
    : region_statement
    | SR_statement
    | AB_statement
    ;

coordinate_command
    : FS { /* std::cout << "[PARSER] coordinate_command" << std::endl; */ }
    | MO
    ;

operation
    : D01 { /* std::cout << "[PARSER] operation.D01" << std::endl; */ }
    | D02 { /* std::cout << "[PARSER] operation.D02" << std::endl; */ }
    | D03 { /* std::cout << "[PARSER] operation.D03" << std::endl; */ }
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
    : '%' 'F''S' 'L''A' 'X' COORDINATE_DIGITS 'Y' COORDINATE_DIGITS '*''%' { /* std::cout << "FS " << $7 << " " << $9 << std::endl; */ }
    ;

MO
    : '%' 'M''O''M''M' '*''%' { /* std::cout << "[PARSER] MOMM" << std::endl; */ };
    | '%' 'M''O''I''N' '*''%' { /* std::cout << "[PARSER] MOIN" << std::endl; */ };
    ;

D01_X_I_J
    : x_c I_C J_C APERTURE_IDENT_SEGMENT '*'
    ;

D01_Y_I_J
    : y_c I_C J_C APERTURE_IDENT_SEGMENT '*'
    ;

D01_X_Y_I_J
    : x_c y_c I_C J_C APERTURE_IDENT_SEGMENT '*'
    ;

D01_X_Y
    : x_c y_c APERTURE_IDENT_SEGMENT '*'
    ;

D01_X
    : x_c APERTURE_IDENT_SEGMENT '*'
    ;

D01_Y
    : y_c APERTURE_IDENT_SEGMENT '*'
    ;

D01_I_J
    : I_C J_C APERTURE_IDENT_SEGMENT '*'
    ;

I_C
    : 'I' SIGNED_INTEGER_NUMBER
    | 'I' INTEGER_NUMBER
    ;

J_C
    : 'J' SIGNED_INTEGER_NUMBER
    | 'J' INTEGER_NUMBER
    ;

D01
    : D01_X { /* std::cout << "[PARSER] D01_X" << std::endl; */ }
    | D01_Y { /* std::cout << "[PARSER] D01_Y" << std::endl; */ }
    | D01_X_Y { /* std::cout << "[PARSER] D01_X_Y" << std::endl; */ }
    | D01_I_J { /* std::cout << "[PARSER] D01_I_J" << std::endl; */ }
    | D01_X_I_J { /* std::cout << "[PARSER] D01_X_I_J" << std::endl; */ }
    | D01_Y_I_J { /* std::cout << "[PARSER] D01_Y_I_J" << std::endl; */ }
    | D01_X_Y_I_J { /* std::cout << "[PARSER] D01_X_Y_I_J" << std::endl; */ }
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
    : D02_X { /* std::cout << "[PARSER] D02_X" << std::endl; */ }
    | D02_Y { /* std::cout << "[PARSER] D02_Y" << std::endl; */ }
    | D02_X_Y { /* std::cout << "[PARSER] D02_X_Y" << std::endl; */ }
    ;

D02_Y
    : y_c APERTURE_IDENT_MOVE '*'
    ;

D02_X
    : x_c APERTURE_IDENT_MOVE '*'
    ;

D02_X_Y
    : x_c y_c APERTURE_IDENT_MOVE '*'
    ;

/*
D03
    : X_Y_PREFIX APERTURE_IDENT_FLASH { std::cout << "D03" << std::endl; } '*' { std::cout << "*" << std::endl; }
    ;
    */

D03
    : D03_X { /* std::cout << "[PARSER] D03_X rule" << std::endl; */ }
    | D03_Y { /* std::cout << "[PARSER] D03_Y rule" << std::endl; */ }
    | D03_X_Y { /* std::cout << "[PARSER] D03_X_Y rule" << std::endl; */ }
    ;

D03_Y
    : y_c APERTURE_IDENT_FLASH '*'
    ;

D03_X
    : x_c APERTURE_IDENT_FLASH '*'
    ;

D03_X_Y
    : x_c y_c APERTURE_IDENT_FLASH '*' {
        std::cout << "[PARSER] D03_X_Y rule - APERTURE_IDENT_FLASH (D03): X: " << $1 << " Y: " << $2 << std::endl;
    }
    ;

x_c
    : 'X' SIGNED_INTEGER_NUMBER { /* std::cout << "[PARSER] x_c rule" << std::endl; */ $$ = $2; }
    | 'X' INTEGER_NUMBER { /* std::cout << "[PARSER] x_c rule" << std::endl;*/ $$ = $2; }
    ;

/*
y_c
    : 'Y' INTEGER_NUMBER { std::cout << "y_c" << std::endl; }
    ;
*/

y_c
    : 'Y' SIGNED_INTEGER_NUMBER { /*std::cout << "y_c" << std::endl;*/ $$ = $2; }
    | 'Y' INTEGER_NUMBER { /*std::cout << "y_c" << std::endl;*/ $$ = $2; }
    ;

/*
X_Y_PREFIX
    : 'X' { std::cout << "X=" << std::endl; } INTEGER_NUMBER 'Y' { std::cout << "Y=" << std::endl; } INTEGER_NUMBER
    ;
*/

/* G01 and deprecated combined syntax (spec page 190) */
G01
    : INTERPOLATION_LINEAR '*' { /* std::cout << "[PARSER] INTERPOLATION_LINEAR Rule" << std::endl; */ }
    | INTERPOLATION_LINEAR D01_X_Y { /* std::cout << "[PARSER] DEPRECATED INTERPOLATION_LINEAR D01_X_Y Rule" << std::endl; */ }
    | INTERPOLATION_LINEAR D02_X_Y { /* std::cout << "[PARSER] DEPRECATED INTERPOLATION_LINEAR D02_X_Y Rule" << std::endl; */ }
    | INTERPOLATION_LINEAR D03_X_Y { /* std::cout << "[PARSER] DEPRECATED INTERPOLATION_LINEAR D03_X_Y Rule" << std::endl; */ }
    ;

G02
    : INTERPOLATION_CW_CIRCULAR '*' { /* std::cout << "[PARSER] INTERPOLATION_CW_CIRCULAR Rule" << std::endl; */ }
    ;

G03
    : INTERPOLATION_CCW_CIRCULAR '*' { /* std::cout << "[PARSER] INTERPOLATION_CCW_CIRCULAR Rule" << std::endl; */ }
    ;

G75
    : INTERPOLATION_BEFORE_FIRST_CIRCULAR_COMPAT '*' { /* std::cout << "[PARSER] INTERPOLATION_BEFORE_FIRST_CIRCULAR_COMPAT Rule" << std::endl; */ }
    ;

Dnn
    : APERTURE_IDENT '*' { /**/ std::cout << "[PARSER] Dnn Rule: APERTURE_IDENT: " << $1 << std::endl;  }
    ;

G04
    : G04_COMMENT { /* std::cout << "[PARSER] G04_COMMENT Rule" << std::endl; */ }
    ;

LP
    : LP_TOK CLEAR ASTERISK_PERCENT { /* std::cout << "[PARSER] LP.CLEAR Rule" << std::endl; */ }
    | LP_TOK DARK ASTERISK_PERCENT { /* std::cout << "[PARSER] LP.DARK Rule" << std::endl; */ }
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
    : AD_TOK APERTURE_IDENT template_call ASTERISK_PERCENT {
        /* std::cout << "[Parser] AD Rule. Identifier: " << std::string($2.string_val) << std::endl; */
        //std::cout << $2 << std::endl;
        std::cout << "Identifier: " << $2 << std::endl;
        //printf("xy %s\n", $2);
    }
    | AD_TOK APERTURE_IDENT aperture_shape ASTERISK_PERCENT {
        /* std::cout << "[Parser] AD Rule. Identifier: " << std::string($2.string_val) << std::endl; */
        std::cout << "Identifier: " << $2 << std::endl;
        //printf("yx %s\n", $2);
    }
    ;

aperture_shape
    : AD_NAME COMMA decimal_pair_list {
        std::cout << "AD_NAME: " << $1 << std::endl;
    }
    ;

decimal_pair_list
    : decimal_pair AD_X decimal_pair_list
    | decimal_pair
    ;

decimal_pair
    :  DECIMAL_NUMBER { /**/ std::cout << "[Parser] AD.decimal_pair Rule = decimal " << $1 << std::endl;  }
    ;

template_call
    : C fst_par { /**/ std::cout << "[Parser] template_call Rule - C" << std::endl;  }
    //| 'C' fst_par nxt_par
    //| 'R' fst_par nxt_par [nxt_par]
    //| 'O' fst_par nxt_par [nxt_par]
    //| 'P' fst_par nxt_par [nxt_par [nxt_par]]
    //| !(('C'|'R'|'O'|'P')(','|'*')) name [fst_par {nxt_par}*]
    ;

fst_par
    : COMMA DECIMAL_NUMBER { /**/ std::cout << "[Parser] fst_par " << $2 << std::endl;  }
    ;

    /*
    nxt_par_list
        : nxt_par nxt_par_list
        | nxt_par
        ;
    */

nxt_par
    : 'X' DECIMAL_NUMBER
    ;

//# Macro Definition
//#-------------------

// AM for Aperture Macro (Spec. Page 55)
AM
    : AM_TOK macro_name macro_body PERCENT { /* std::cout << "[Parser] AM Rule" << std::endl; */ }
    ;

// Name of the aperture macro. The name must be unique, it
// cannot be reused for another macro. See 3.4.5 for the syntax
// rules.
macro_name
    : NAME ASTERISK { /* std::cout << "[Parser] macro_name Rule" << std::endl; */ }
    ;

// The macro body contains the primitives generating the image
// and the calculation of their parameters.
macro_body
    : in_macro_block
    | macro_body in_macro_block
    ;

in_macro_block
    : primitive
    | variable_definition
    ;

// $n=<Arithmetic expression>. An arithmetic expression may
// use arithmetic operators (described later), constants and
// variables $m defined previously.
variable_definition
    : macro_variable EQUALS expression ASTERISK
    ;

macro_variable
    : DOLLAR_SIGN UNSIGNED_DECIMAL_NUMBER
    ;

// A primitive is a basic shape to create the macro. It includes
// primitive code identifying the primitive and primitive-specific
// parameters (e.g. center of a circle). See 4.5.1. The primitives
// are positioned in a coordinates system whose origin is the
// origin of the resulting apertures.
primitive
    : AM_ZERO STRING ASTERISK { std::cout << "[Parser] primitive-0 Rule" << std::endl; }
    | AM_ONE par par par par ASTERISK { std::cout << "[Parser] primitive-1/1 Rule" << std::endl; }
    | AM_ONE par par par par par ASTERISK { std::cout << "[Parser] primitive-1/2 Rule" << std::endl; }
    | AM_TWENTY par { std::cout << "[Parser] PAR-1 value=" << $1 << std::endl; } par par par par par par ASTERISK { std::cout << "[Parser] primitive-20 Rule" << std::endl; }
    | AM_TWENTY_ONE par par par par par par ASTERISK { std::cout << "[Parser] primitive-21 Rule" << std::endl; }
    | AM_FOUR par par par par primitive_four_list par ASTERISK { std::cout << "[Parser] primitive-4 Rule" << std::endl; }
    | AM_FIVE par par par par par par ASTERISK { std::cout << "[Parser] primitive-5 Rule" << std::endl; }
    | AM_SEVEN par par par par par par ASTERISK { std::cout << "[Parser] primitive-7 Rule" << std::endl; }
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

// A code specifying the primitive (e.g. polygon).
//primitive_code
//    :
//    ;

// Parameter can be a decimal number (e.g. 0.050), a variable
// (e.g. $1) or an arithmetic expression based on numbers and
// variables. The actual value is calculated as explained in
// 4.5.4.3.
parameter
    :
    ;

//# Compound statements

region_statement
    : G36 contour_list G37 { /*std::cout << "[Parser] region_statement Rule" << std::endl;*/ }
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

AB_statement
    : AB_open in_block_statement_list AB_close
    ;

AB_open
    : AB_TOK APERTURE_IDENT AB_ASTERISK_PERCENT { /*std::cout << "[Parser] AB_open Rule, aperture_ident = " << $2 << std::endl;*/ }
    ;

AB_close
    : AB_TOK AB_ASTERISK_PERCENT
    ;

SR_statement
    : SR_open in_block_statement_list SR_close
    ;

SR_open
    : SR_TOK SR_X_INTEGER_NUMBER SR_Y_INTEGER_NUMBER SR_I_INTEGER_NUMBER SR_J_INTEGER_NUMBER SR_ASTERISK_PERCENT {
        /*std::cout << "[Parser] SR_open Rule" << std::endl;*/
    }
    ;

SR_close
    : END_SR_TOK { /* std::cout << "[Parser] SR_close Rule" << std::endl; */ }
    ;

in_block_statement_list
    : in_block_statement_list in_block_statement
    | in_block_statement
    ;

in_block_statement
    : single_statement
    | region_statement
    | AB_statement
    ;

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
    : TD_TOK ASTERISK_PERCENT
    | TD_TOK all_atts ASTERISK_PERCENT
    ;

TF_atts
    : DOT_PART                  nxt_field { std::cout << "[PARSER] DOT_PART" << std::endl; }
    | DOT_FILEFUNCTION          nxt_fields { std::cout << "[PARSER] DOT_FILEFUNCTION" << std::endl; }
    | DOT_FILEPOLARITY          nxt_field { std::cout << "[PARSER] DOT_FILEPOLARITY" << std::endl; }
    | DOT_SAMECOORDINATES { std::cout << "[PARSER] DOT_SAMECOORDINATES 0" << std::endl; }
    | DOT_SAMECOORDINATES       nxt_field { std::cout << "[PARSER] DOT_SAMECOORDINATES 1" << std::endl; }
    | DOT_CREATIONDATE          nxt_field { std::cout << "[PARSER] DOT_CREATIONDATE" << std::endl; }
    | DOT_GENERATIONSOFTWARE    nxt_field nxt_field { std::cout << "[PARSER] DOT_GENERATIONSOFTWARE 2" << std::endl; }
    | DOT_GENERATIONSOFTWARE    nxt_field nxt_field nxt_field { std::cout << "[PARSER] DOT_GENERATIONSOFTWARE 3" << std::endl; }
    | DOT_PROJECTID             nxt_field nxt_field nxt_field { std::cout << "[PARSER] DOT_PROJECTID" << std::endl; }
    | DOT_MD5                   nxt_field { std::cout << "[PARSER] DOT_MD5" << std::endl; }
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
    | DECIMAL_NUMBER { std::cout << "[Parser] factor value=" << std::setprecision(10) << $1 << std::endl; $$ = $1; }
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