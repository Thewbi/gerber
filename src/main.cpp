#include <iostream>
#include <fstream>

#include <windows.h>

#include "constants.h"
#include "parser.h"

extern FILE* yyin;
extern int yy_flex_debug;
extern int yydebug;

int main(int argc, char **argv)
{
    // std::cout << "test" << std::endl;

    // TODO: preprocess file! Parser TF commands manually! They are to irregular and since flex does not support non-greedy matching easily this is a complete mess.

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        printf("Cannot open '%s'. Aborting.\n", argv[1]);
    }

    // debug flex
    yy_flex_debug = 0;

    // debug bison
    yydebug = 0;

    yyparse();

    return 0;
}