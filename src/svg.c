#include "svg.h"

struct ASTNode * currently_selected_aperture = 0;

void selectApertureToSVG(struct ASTNode * root_node, struct ASTNode * ast_node_ptr) {

    // DEBUG
    //printf("Selecting aperture. id: %d, name: %s\n", ast_node_ptr->id, ast_node_ptr->name);

    int found = 0;
    for (int i = 0; i < AST_NODE_CHILDREN_LENGTH; i++)
    {
        struct ASTNode * temp_ast_node_ptr = root_node->children[i];
        if (temp_ast_node_ptr == 0) {
            continue;
        }

        switch (temp_ast_node_ptr->node_type) {

            case APERTURE_DEFINITION_AST_NODE_TYPE:
                if (strcmp(temp_ast_node_ptr->name, ast_node_ptr->name) == 0) {
                    currently_selected_aperture = temp_ast_node_ptr;
                    found = 1;
                }
                break;
        }

        if (found) {
            break;
        }

    }

    // // DEBUG
    // if (found) {
    //     printf("id: %d, Children: %d\n", currently_selected_aperture->id, child_count_ast_node(currently_selected_aperture));
    // } else {
    //     printf("Cannot find aperture: %s\n", ast_node_ptr->name);
    // }

}

void drawApertureToSVG(struct ASTNode * rootNode, struct ASTNode * ast_node_ptr) {

    //printf("Flash x: %f, y: %f\n", ast_node_ptr->children[0]->int_val, ast_node_ptr->children[1]->int_val);

    //printf("Selected aperture: id: %d name: %s\n", currently_selected_aperture->id, currently_selected_aperture->name);
    //printf("Flash width: %f, height: %f\n", currently_selected_aperture->children[1]->int_val, currently_selected_aperture->children[2]->int_val);

    // for solder mask gerber files, only rectangular apertures are output
    if (strcmp(currently_selected_aperture->children[0]->name, "R") == 0) {

        // DEBUG
        //output_ast_node(ast_node_ptr, 0);

        float center_x = (ast_node_ptr->children[0]->int_val / 10000.0f);
        float center_y = (ast_node_ptr->children[1]->int_val / 10000.0f);

        // retrieve the currently selected aperture.

        // retrieve the width and the height
        float width = currently_selected_aperture->children[1]->int_val;
        float height = currently_selected_aperture->children[2]->int_val;

        // compute width_half = width / 2.0f
        float width_half = width / 2.0f;
        // compute width_half = height / 2.0f
        float height_half = height / 2.0f;

        // compute x = center_x - width_half;
        float x = center_x - width_half;
        // compute y = center_y - height_half;
        float y = center_y - height_half;

        // convert x, y, width, height to formatted value

        // print x, y, width, height
        //printf("Rectangle: x: %f, y: %f, width: %f, height: %f\n", x, y, width, height);

        float y_temp = y;

        // gerber has the origin in the bottom left corner
        // svg has the origin in the top left corner
        int flip_at_x_axis = 1;
        if (flip_at_x_axis) {
            y_temp = ((y*-1.0f - height) + 25.f);
        }

        printf("  <rect style=\"fill:#000000;stroke-width:0.264583\" x=\"%f\" y=\"%f\" width=\"%f\" height=\"%f\" />\n",
            x, y_temp, width, height);
    }
}

void outputSolderMaskToSVG(struct ASTNode * root_node) {

        printf("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n");

        printf("<svg ");
        printf("width=\"210mm\" ");
        printf("height=\"297mm\" ");
        printf("viewBox=\"0 0 210 297\" ");
        printf("version=\"1.1\" ");
        printf("id=\"svg1\" ");
        printf("xmlns=\"http://www.w3.org/2000/svg\" ");
        printf("xmlns:svg=\"http://www.w3.org/2000/svg\">\n");

        walkASTTreeToSVG(root_node, root_node);

        printf("</svg>\n");
    }

void walkASTTreeToSVG(struct ASTNode * root_node, struct ASTNode * astNode) {

    for (int i = 0; i < AST_NODE_CHILDREN_LENGTH; i++)
    {
        struct ASTNode * ast_node_ptr = astNode->children[i];
        if (ast_node_ptr == 0) {
            continue;
        }

        switch (ast_node_ptr->node_type) {

            // internal state changes, a new aperture is selected
            case APERTURE_SELECT_FLASH_NODE_TYPE:
                selectApertureToSVG(root_node, ast_node_ptr);
                walkASTTreeToSVG(root_node, ast_node_ptr);
                break;

            // flashing means to draw an aperture
            case APERTURE_IDENT_FLASH_NODE_TYPE:
                drawApertureToSVG(root_node, ast_node_ptr);
                break;
        }
    }
}