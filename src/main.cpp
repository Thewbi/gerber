#include <iostream>
#include <fstream>

#include <windows.h>

#include "parser.h"

extern FILE* yyin;
extern int yy_flex_debug;
extern int yydebug;

int main(int argc, char **argv)
{
    // std::cout << "test" << std::endl;

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        printf("Cannot open '%s'. Aborting.\n", argv[1]);
    }

    yy_flex_debug = 0;
    yydebug = 0;

    yyparse();

    return 0;
}