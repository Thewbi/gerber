#ifndef __SVG
#define __SVG

#include "ast_node.h"

void selectApertureToSVG(struct ASTNode * rootNode, struct ASTNode * ast_node_ptr);

void drawApertureToSVG(struct ASTNode * rootNode, struct ASTNode * ast_node_ptr);

#endif