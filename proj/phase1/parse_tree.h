#ifndef _PARSE_TREE_H
#define _PARSE_TREE_H

#include <stdio.h>

#define bool short
#define true 1
#define false 0

extern char *yytext;

typedef struct Node
{
    int lineno;
    char *name;

    struct Node *left;
    struct Node *right;

    union
    {
        int int_value;
        float float_value;
        char *string_value;
    };
    char *value_view;

    bool is_leaf;

} Node;

Node *new_interior_node(char *, int, ...);
Node *new_leaf_node(char *, int);
void print_tree(Node *, int, FILE *);

#endif