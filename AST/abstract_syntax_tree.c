#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "abstract_syntax_tree.h"

expression_node* init_exp_node(char* val, expression_node* left, expression_node* right)
{
    expression_node* node = (expression_node*)malloc(sizeof(struct expression_node));
    node->val = strdup(val);
    node->left = left;
    node->right = right;
    return node;
}

void display_exp_tree(expression_node* exp_node)
{
    if (exp_node == NULL) return;
    printf("%s ", exp_node->val);
    display_exp_tree(exp_node->left);
    display_exp_tree(exp_node->right);
}