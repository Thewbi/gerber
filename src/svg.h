#ifndef __SVG
#define __SVG

#include "ast_node.h"

/**
 * This function prints rectangular appertures only!
 * The output format is SVG (Scalable Vector Graphics).
 */
void outputSolderMaskToSVG(struct ASTNode * rootNode);

void walkASTTreeToSVG(struct ASTNode * rootNode, struct ASTNode * astNode);

void selectApertureToSVG(struct ASTNode * rootNode, struct ASTNode * ast_node_ptr);

void drawApertureToSVG(struct ASTNode * rootNode, struct ASTNode * ast_node_ptr);

#endif