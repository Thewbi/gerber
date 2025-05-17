#include <iostream>
#include <fstream>

#include <windows.h>

#include "constants.h"
#include "ast_node.h"
#include "svg.h"
#include "parser.h"

extern FILE* yyin;
extern int yy_flex_debug;
extern int yydebug;

struct ASTNode * current_ast_node;
struct ASTNode pool[AST_NODE_POOL_SIZE];

int idx;
struct ASTNode * stack[10];

void walkASTTree(ASTNode * rootNode, ASTNode * astNode) {

    for (int i = 0; i < AST_NODE_CHILDREN_LENGTH; i++)
    {
        ASTNode * ast_node_ptr = astNode->children[i];
        if (ast_node_ptr == nullptr) {
            continue;
        }

        switch (ast_node_ptr->node_type) {

            // internal state changes, a new aperture is selected
            case APERTURE_SELECT_FLASH_NODE_TYPE:
                selectApertureToSVG(rootNode, ast_node_ptr);
                walkASTTree(rootNode, ast_node_ptr);
                break;

            // flashing means to draw an aperture
            case APERTURE_IDENT_FLASH_NODE_TYPE:
                drawApertureToSVG(rootNode, ast_node_ptr);
                break;
        }
    }
}

int main(int argc, char **argv)
{
    // std::cout << "test" << std::endl;

    // TODO: preprocess file! Parser TF commands manually! They are to irregular and since flex does not support non-greedy matching easily this is a complete mess.

    int i = 0;
    for (i = 0; i < AST_NODE_POOL_SIZE; i++) {
        initialize_ast_node(&pool[i]);
        pool[i].id = i+1;
    }
    idx = 0;
    for (i = 0; i < 10; i++) {
        stack[i] = 0;
    }

    // root node
    ASTNode* root_node = new_ast_node(pool);
    root_node->node_type = ROOT_AST_NODE_TYPE;

    memcpy(root_node->name, "root", strlen("root"));

    // root is initially the current node
    current_ast_node = root_node;

    //printf("root has %d child(ren) \n", child_count_ast_node(root_node));

    //initialize_ast_node(current_ast_node);

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        printf("Cannot open '%s'. Aborting.\n", argv[1]);
    }

    // debug flex
    yy_flex_debug = 0;

    // debug bison
    yydebug = 0;

    printf("Parsing ...\n");

    yyparse();

    printf("Parsing done.\n");

    //printf("root used: %d \n", root_node->used);
    //printf("root has %d child(ren) \n", child_count_ast_node(root_node));

    // DEBUG
    output_ast_node(root_node, 0);

    walkASTTree(root_node, root_node);

    return 0;
}