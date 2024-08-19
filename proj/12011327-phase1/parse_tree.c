#include "parse_tree.h"
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

Node *new_interior_node(char *name, int cnt, ...)
{
    // current node
    Node *node = (Node *)malloc(sizeof(Node));
    node->name = name;
    node->left = NULL;
    node->right = NULL;
    node->is_leaf = false;

    if (cnt < 0)
        return node;

    // child node
    va_list childs;
    va_start(childs, cnt);
    Node *child = va_arg(childs, Node *);
    node->left = child;
    node->lineno = child->lineno;
    for (int i = 0; i < cnt - 1; ++i)
    {
        child->right = va_arg(childs, Node *);
        child = child->right;
    }

    va_end(childs);
    return node;
}

Node *new_leaf_node(char *name, int lineno)
{
    // current node
    Node *node = (Node *)malloc(sizeof(Node));
    node->lineno = lineno;
    node->name = name;
    node->left = NULL;
    node->right = NULL;
    node->is_leaf = true;

    if (!strcmp(name, "INT"))
        node->int_value = atoi(yytext);
    else if (!strcmp(name, "FLOAT"))
        node->float_value = atof(yytext);
    else
    {
        node->string_value = (char *)malloc(sizeof(char) * strlen(yytext));
        strcpy(node->string_value, yytext);
    }
    node->value_view = (char *)malloc(sizeof(char) * strlen(yytext));
    strcpy(node->value_view, yytext);
    return node;
}

void print_tree(Node *tree, int indent, FILE *file_out)
{
    if (tree == NULL)
        return;
    if (strcmp(tree->name, "Epsilon"))
    {
        if (indent > 0)
            fprintf(file_out, "%*c", indent * 2, ' ');

        fprintf(file_out, "%s", tree->name);

        if (tree->lineno == -1)
        {
            fprintf(file_out, "\n");
            return;
        }

        if (tree->is_leaf)
            fprintf(file_out, ": %s\n", tree->value_view);
        else
            fprintf(file_out, " (%d)\n", tree->lineno);
    }

    print_tree(tree->left, indent + 1, file_out);
    print_tree(tree->right, indent, file_out);
}