#include "yyerror_ow.h"

void yyerror_ow(FILE *file_out, yyerror_type type, int lineno)
{
    char *msg;
    switch (type)
    {
    case MISS_RC:
        msg = "Error type B at Line %d: Missing closing curly braces  \'}\'\n";
        break;
    case MISS_LC:
        msg = "Error type B at Line %d: Missing left curly braces  \'{\'\n";
        break;
    case MISS_RB:
        msg = "Error type B at Line %d: Missing closing bracket \']\'\n";
        break;
    case MISS_LB:
        msg = "Error type B at Line %d: Missing left bracket \'[\'\n";
        break;
    case MISS_RP:
        msg = "Error type B at Line %d: Missing closing parenthesis \')\'\n";
        break;
    case MISS_LP:
        msg = "Error type B at Line %d: Missing left parenthesis \'(\'\n";
        break;
    case MISS_SPEC:
        msg = "Error type B at Line %d: Missing specifier\n";
        break;
    case MISS_SEMI:
        msg = "Error type B at Line %d: Missing semicolon \';\'\n";
        break;
    case MISS_COMMA:
        msg = "Error type B at Line %d: Missing COMMA \',\'\n";
        break;
    }
    fprintf(file_out, msg, lineno);
}
