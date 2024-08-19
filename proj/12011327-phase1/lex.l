%{
    #include "parse_tree.h"
    #include "syntax.tab.h"

    #define NEW_LEAF_NODE(NAME)    { \
        yylval.node = new_leaf_node(#NAME, yylineno); \
        return NAME; \
    }
    
    extern FILE* file_out;
%}
%option yylineno

    /* comment */
%x COMMENT

    /* keywords */
TYPE    "int"|"float"|"char"
STRUCT  "struct"
IF      "if"
ELSE    "else"
WHILE   "while"
RETURN  "return"
DOT     "."
SEMI    ";"
COMMA   ","
ASSIGN  "="
LT      "<"
LE      "<="
GT      ">"
GE      ">="
NE      "!="
EQ      "=="
PLUS    "+"
MINUS   "-"
MUL     "*"
DIV     "/"
AND     "&&"
OR      "||"
NOT     "!"
LP      "("
RP      ")"
LB      "["
RB      "]"
LC      "{"
RC      "}"

    /* integer in 32-bits (decimal or hexadecimal) */
INT                 [+-]?([0-9]+|0x[0-9a-fA-F]+)
WRONG_HEX_INT       [+-]?0x[0-9a-zA-Z]+

    /*  floating point number (only dot-form) */
FLOAT               [-+]?(([0-9]+\.?[0-9]*)|([0-9]*\.?[0-9]+))

    /*  single character (printable or hex-form) */
CHAR                '(([ -~])|(\\x[0-9a-fA-F]{2}))'
WRONG_HEX_CHAR      '\\x[0-9a-zA-Z]*'

    /* valid identifier */
ID                  [_a-zA-Z][_a-zA-Z0-9]*
WRONG_ID            [0-9][_a-zA-Z0-9]*

%%
    /* keywords */
{TYPE}     NEW_LEAF_NODE(TYPE); 
{STRUCT}   NEW_LEAF_NODE(STRUCT); 
{IF}       NEW_LEAF_NODE(IF); 
{ELSE}     NEW_LEAF_NODE(ELSE); 
{WHILE}    NEW_LEAF_NODE(WHILE); 
{RETURN}   NEW_LEAF_NODE(RETURN); 

    /* data type */
{INT}      NEW_LEAF_NODE(INT); 
{WRONG_HEX_INT} { 
    fprintf(file_out, "Error type A at Line %d: Mysterious lexeme %s\n", yylineno, yytext);
    NEW_LEAF_NODE(ERROR);
}
{FLOAT}    NEW_LEAF_NODE(FLOAT); 
{CHAR}     NEW_LEAF_NODE(CHAR); 
{WRONG_HEX_CHAR} {
    fprintf(file_out, "Error type A at Line %d: Mysterious lexeme %s\n", yylineno, yytext);
    NEW_LEAF_NODE(ERROR);
}
{ID}       NEW_LEAF_NODE(ID); 
{WRONG_ID} {
    fprintf(file_out, "Error type A at Line %d: Identifier starts with digits %s\n", yylineno, yytext);
    NEW_LEAF_NODE(ERROR);
}

    /* separator */
{DOT}      NEW_LEAF_NODE(DOT); 
{SEMI}     NEW_LEAF_NODE(SEMI); 
{COMMA}    NEW_LEAF_NODE(COMMA); 
{LP}       NEW_LEAF_NODE(LP); 
{RP}       NEW_LEAF_NODE(RP); 
{LB}       NEW_LEAF_NODE(LB);
{RB}       NEW_LEAF_NODE(RB); 
{LC}       NEW_LEAF_NODE(LC); 
{RC}       NEW_LEAF_NODE(RC); 

    /* operator */
{ASSIGN}   NEW_LEAF_NODE(ASSIGN); 
{LT}       NEW_LEAF_NODE(LT); 
{LE}       NEW_LEAF_NODE(LE); 
{GT}       NEW_LEAF_NODE(GT); 
{GE}       NEW_LEAF_NODE(GE); 
{NE}       NEW_LEAF_NODE(NE); 
{EQ}       NEW_LEAF_NODE(EQ); 
{PLUS}     NEW_LEAF_NODE(PLUS); 
{MINUS}    NEW_LEAF_NODE(MINUS); 
{MUL}      NEW_LEAF_NODE(MUL); 
{DIV}      NEW_LEAF_NODE(DIV); 
{AND}      NEW_LEAF_NODE(AND); 
{OR}       NEW_LEAF_NODE(OR); 
{NOT}      NEW_LEAF_NODE(NOT); 

    /* comments */
"//" { char c; while((c=input()) != '\n'); };
<INITIAL>{
"/*"  BEGIN(COMMENT);
}
<COMMENT>{
"*/"      BEGIN(INITIAL);
[^*\n]+   /* eat anything that's not a '*' or EOL */
"*"       /* eat the lonely '*' */
\n        ;
}

    /* whitespace */
[\t\r\n ]+ ;
. {
    fprintf(file_out, "Error type A at Line %d: Mysterious lexeme %s\n", yylineno, yytext);
    NEW_LEAF_NODE(ERROR);
}
%%
