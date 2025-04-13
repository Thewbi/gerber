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
    //char string_val[100];
    char sym;
    //node_t* expr_ptr;
};

%token <int_val> COORDINATE_DIGITS;

%token <sym> NEW_LINE
%token <sym> DOT COLON COMMA OPENING_BRACKET CLOSING_BRACKET

%%

start_symbol
    : statements
    ;

statements
    : statement
    | statements statement
    ;

statement
    : single_statement
//    | compound_statement
    ;

single_statement
    :
//    operation
//    | interpolation_state_command
//    | Dnn
//    | G04
//    | attribute_command
//    | AD
//    | AM
    //|
    coordinate_command
//    | transformation_state_command
    ;

/* compound_statement
    : region_statement
    | SR_statement
    | AB_statement
    ; */

coordinate_command
    : FS
//    | MO
    ;

/* operation
    : D01
    | D02
    | D03
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
*/

//# Graphics commands
//#------------------

FS : '%' 'F''S' 'L''A' 'X' COORDINATE_DIGITS 'Y' COORDINATE_DIGITS '*''%' { std::cout << "FS " << $7 << " " << $9 << std::endl; };
/* #coordinate_digits = /[1-6][56]/;
MO = '%' ('MO' ('MM'|'IN')) '*%';

D01 = (['X' integer] ['Y' integer] ['I' integer 'J' integer] 'D01') '*';
D02 = (['X' integer] ['Y' integer] 'D02') '*';
D03 = (['X' integer] ['Y' integer] 'D03') '*';

G01 = ('G01') '*';
G02 = ('G02') '*';
G03 = ('G03') '*';
G75 = ('G75') '*';

Dnn = (aperture_ident) '*';

G04 = ('G04' string) '*';

M02 = ('M02') '*';

LP = '%' ('LP' ('C'|'D')) '*%';
LM = '%' ('LM' ('N'|'XY'|'Y'|'X')) '*%';
LR = '%' ('LR' decimal) '*%';
LS = '%' ('LS' decimal) '*%';

AD = '%' ('AD' aperture_ident template_call) '*%';

//#aperture_shape = name [',' decimal {'X' decimal}*];

template_call =
   | 'C' fst_par [nxt_par]
   | 'R' fst_par nxt_par [nxt_par]
   | 'O' fst_par nxt_par [nxt_par]
   | 'P' fst_par nxt_par [nxt_par [nxt_par]]
   | !(('C'|'R'|'O'|'P')(','|'*')) name [fst_par {nxt_par}*]
   ;
fst_par = ',' (decimal);
nxt_par = 'X' (decimal);

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