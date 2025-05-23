#ifndef __AST_NODE
#define __AST_NODE

#include <stdio.h>
#include <string.h>

#define AST_NODE_CHILDREN_LENGTH 1000
#define AST_NODE_NAME_LENGTH 100
#define AST_NODE_POOL_SIZE 2000

#define UNKNOWN_AST_NODE_TYPE 0
#define ROOT_AST_NODE_TYPE 1
#define APERTURE_DEFINITION_AST_NODE_TYPE 2
#define APERTURE_IDENT_FLASH_NODE_TYPE 3
#define APERTURE_SELECT_FLASH_NODE_TYPE 4
#define D1_SET_POINT_NODE_TYPE 5
#define D2_SET_POINT_NODE_TYPE 6

struct ASTNode {

    int id;

    int node_type;

    int used;

    struct ASTNode * parent;

    struct ASTNode * children[AST_NODE_CHILDREN_LENGTH];

    float int_val;

    char name[AST_NODE_NAME_LENGTH];

};

void initialize_ast_node(struct ASTNode* ast_node);

struct ASTNode* new_ast_node(struct ASTNode* pool);

int add_child_ast_node(struct ASTNode* parent, struct ASTNode* child);

int child_count_ast_node(struct ASTNode* parent);

void output_ast_node(struct ASTNode* node, int indent);

#endif