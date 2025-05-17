#include "ast_node.h"

void initialize_ast_node(struct ASTNode* ast_node) {
    ast_node->node_type = UNKNOWN_AST_NODE_TYPE;
    ast_node->used = 0;
    ast_node->parent = 0;
    for (int i = 0; i < AST_NODE_CHILDREN_LENGTH; i++) {
        ast_node->children[i] = 0;
    }
    ast_node->int_val = 0;
    memset(ast_node->name, 0, AST_NODE_NAME_LENGTH);
}

struct ASTNode* new_ast_node(struct ASTNode* pool) {

    //printf("new_ast_node - A\n");

    for (int i = 0; i < AST_NODE_POOL_SIZE; i++) {

        //printf("new_ast_node - B\n");

        //struct ASTNode* node = (struct ASTNode*) pool[i];
        struct ASTNode* node = &pool[i];
        if (node->used) {
            continue;
        }

        printf("found: %d\n", i);

        initialize_ast_node(node);
        node->used = 1;

        return node;
    }

    printf("[new_ast_node] error, no space for nodes left! AST_NODE_POOL_SIZE: %d\n", AST_NODE_POOL_SIZE);

    return 0;
}

int add_child_ast_node(struct ASTNode* parent, struct ASTNode* child) {

    //printf("add_child_ast_node - A\n");

    int i = 0;

    // look for the first empty element in the parent's 'children' array
    for (i = 0; i < AST_NODE_CHILDREN_LENGTH; i++) {

        // // DEBUG
        // if (parent->children[i] == 0) {
        //     printf("null\n");
        // } else {
        //     if (parent->children[i]->used == 0) {
        //         printf("not used\n");
        //     }
        // }

        if ((parent->children[i] == 0) || (parent->children[i]->used == 0)) {
            break;
        }
    }
    if (i >= AST_NODE_CHILDREN_LENGTH) {

        printf(" error, no space for children left! - A\n");

        // error, no space for children left!
        return 1;
    }

    printf("add_child_ast_node %d at index %d\n", child, i);

    parent->children[i] = child;
    child->parent = parent;

    return 0;
}

int child_count_ast_node(struct ASTNode* parent) {

    //printf("child_count_ast_node - A\n");

    int i = 0;
    for (i = 0; i < AST_NODE_CHILDREN_LENGTH; i++) {

        if (parent->children[i] == 0 || parent->children[i]->used == 0) {

            //printf("child_count_ast_node - B\n");
            return i;
        }
    }

    //printf("child_count_ast_node - C\n");

    return AST_NODE_CHILDREN_LENGTH;
}

void output_ast_node(struct ASTNode* node, int indent) {

    if (node == 0) {
        return;
    }

    for (int i = 0; i < indent; i++) {
        printf("  ");
    }

    printf("node id: %d, type: %d, name: %s, int_val: %2.6f\n", node->id, node->node_type, node->name, node->int_val);

    for (int i = 0; i < AST_NODE_CHILDREN_LENGTH; i++) {
        output_ast_node(node->children[i], indent + 1);
    }
}