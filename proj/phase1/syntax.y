%{
    #include "parse_tree.h"
    #include "yyerror_ow.h"
    #include "lex.yy.c"
    void yyerror(const char*);

    FILE* file_out = NULL;
    int errors = 0;

    #define PRINT_ERROR(type) { \
        ++errors; \
        yyerror_ow(file_out, type, yylineno); \
    }
%}

%union {
    Node* node;
}

%token <node> INT     // integer in 32-bits (decimal or hexadecimal)
%token <node> FLOAT   // floating point number (only dot-form)
%token <node> CHAR    // single character (printable or hex-form)
%token <node> ID      // identifier
%token <node> TYPE    // int | float | char
%token <node> STRUCT  // struct
%token <node> IF      // if
%token <node> ELSE    // else
%token <node> WHILE   // while
%token <node> RETURN  // return
%token <node> DOT     // .
%token <node> SEMI    // ;
%token <node> COMMA   // ,
%token <node> ASSIGN  // =
%token <node> LT      // <
%token <node> LE      // <=
%token <node> GT      // >
%token <node> GE      // >=
%token <node> NE      // !=
%token <node> EQ      // ==
%token <node> PLUS    // +
%token <node> MINUS   // -
%token <node> MUL     // *
%token <node> DIV     // /
%token <node> AND     // &&
%token <node> OR      // ||
%token <node> NOT     // !
%token <node> LP      // (
%token <node> RP      // )
%token <node> LB      // [
%token <node> RB      // ]
%token <node> LC      // {
%token <node> RC      // }
%token <node> ERROR   // Lexical error

%type <node> Program ExtDefList ExtDef ExtDecList;
%type <node> Specifier StructSpecifier;
%type <node> VarDec FunDec VarList ParamDec;
%type <node> CompSt StmtList Stmt;
%type <node> DefList Def DecList Dec;
%type <node> Exp Args;

%right ASSIGN
%right NOT

%left OR
%left AND
%left LT LE GT GE NE EQ
%left PLUS MINUS
%left MUL DIV
%left COMMA DOT

%nonassoc LP RP LB RB LC RC
%nonassoc SEMI
%nonassoc ELSE

%%
    /* high-level definition */
Program: ExtDefList { 
        $$ = new_interior_node("Program", 1, $1);
        if (errors == 0) print_tree($$, 0, file_out);
    }
    ;
ExtDefList: ExtDef ExtDefList { $$ = new_interior_node("ExtDefList", 2, $1, $2); } 
    | { $$ = new_interior_node("Epsilon", -1); }
    ;
ExtDef: Specifier ExtDecList SEMI { $$ = new_interior_node("ExtDef", 3, $1, $2, $3); }
    | Specifier SEMI { $$ = new_interior_node("ExtDef", 2, $1, $2); }
    | Specifier FunDec CompSt { $$ = new_interior_node("ExtDef", 3, $1, $2, $3); }
    | Specifier error {
        $$ = new_interior_node("ExtDef", 1, $1);
        PRINT_ERROR(MISS_SEMI);
    }
    | Specifier ExtDecList error {
        $$ = new_interior_node("ExtDef", 2, $1, $2);
        PRINT_ERROR(MISS_SEMI);
    }
    | error SEMI {
        ++errors;
    }
    ;
ExtDecList: VarDec { $$ = new_interior_node("ExtDecList", 1, $1); }
    | VarDec COMMA ExtDecList { $$ = new_interior_node("ExtDecList", 3, $1, $2, $3); }
    | VarDec ExtDecList error {
        $$ = new_interior_node("ExtDecList", 2, $1, $2);
        PRINT_ERROR(MISS_COMMA);
    }
    ;

    /* specifier */
Specifier: TYPE { $$ = new_interior_node("Specifier", 1, $1); }
    | StructSpecifier { $$ = new_interior_node("Specifier", 1, $1); }
    ;
StructSpecifier: STRUCT ID LC DefList RC { $$ = new_interior_node("StructSpecifier", 5, $1, $2, $3, $4, $5); }
    | STRUCT ID { $$ = new_interior_node("StructSpecifier", 2, $1, $2); }
    | STRUCT ID LC DefList error {
        $$ = new_interior_node("StructSpecifier", 4, $1, $2, $3, $4);
        PRINT_ERROR(MISS_RC);
    }
    ;

    /* declarator */
VarDec: ID { $$ = new_interior_node("VarDec", 1, $1); }
    | ERROR { $$ = new_interior_node("VarDec", 1, $1); ++errors; }
    | VarDec LB INT RB { $$ = new_interior_node("VarDec", 4, $1, $2, $3, $4); }
    ;
FunDec: ID LP VarList RP { $$ = new_interior_node("FunDec", 4, $1, $2, $3, $4); }
    | ID LP RP { $$ = new_interior_node("FunDec", 3, $1, $2, $3); }
    | ID LP VarList error {
        $$ = new_interior_node("FunDec", 3, $1, $2, $3);
        PRINT_ERROR(MISS_RP);
    }
    | ID LP error {
        $$ = new_interior_node("FunDec", 2, $1, $2);
        PRINT_ERROR(MISS_RP);
    }
    ;
VarList: ParamDec COMMA VarList { $$ = new_interior_node("VarList", 3, $1, $2, $3); }
    | ParamDec { $$ = new_interior_node("VarList", 1, $1); }
    | ParamDec VarList error {
        $$ = new_interior_node("VarList", 2, $1, $2);
        PRINT_ERROR(MISS_COMMA);
    }
    ;
ParamDec: Specifier VarDec { $$ = new_interior_node("ParamDec", 2, $1, $2); }
    ;

    /* statement */
CompSt: LC DefList StmtList RC { $$ = new_interior_node("CompSt", 4, $1, $2, $3, $4); }
    ;
StmtList: Stmt StmtList { $$ = new_interior_node("StmtList", 2, $1, $2); }     
    | { $$ = new_interior_node("Epsilon", -1); }
    ;
Stmt: Exp SEMI { $$ = new_interior_node("Stmt", 2, $1, $2); }
    | CompSt { $$ = new_interior_node("Stmt", 1, $1); }
    | RETURN Exp SEMI { $$ = new_interior_node("Stmt", 3, $1, $2, $3); }
    | IF LP Exp RP Stmt { $$ = new_interior_node("Stmt", 5, $1, $2, $3, $4, $5); }
    | IF LP Exp RP Stmt ELSE Stmt { $$ = new_interior_node("Stmt", 7, $1, $2, $3, $4, $5, $6, $7); }
    | WHILE LP Exp RP Stmt { $$ = new_interior_node("Stmt", 5, $1, $2, $3, $4, $5); }
    | Exp error {
        $$ = new_interior_node("Stmt", 1, $1);
        PRINT_ERROR(MISS_SEMI);
    }
    | RETURN Exp error {
        $$ = new_interior_node("Stmt", 2, $1, $2);
        PRINT_ERROR(MISS_SEMI);
    }
    | IF LP Exp error Stmt { 
        $$ = new_interior_node("Stmt", 4, $1, $2, $3, $5);
        PRINT_ERROR(MISS_RP);
    }
    | WHILE LP Exp error Stmt {
        $$ = new_interior_node("Stmt", 3, $1, $2, $3, $5);
        PRINT_ERROR(MISS_RP);
    }
    ;

    /* local definition */
DefList: Def DefList { $$ = new_interior_node("DefList", 2, $1, $2); }    
    | { $$ = new_interior_node("Epsilon", -1); }
    ;
Def: Specifier DecList SEMI { $$ = new_interior_node("Def", 3, $1, $2, $3); }
    | Specifier DecList error {
        $$ = new_interior_node("Def", 2, $1, $2);
        PRINT_ERROR(MISS_SEMI);
    }
    | error DecList SEMI {
        $$ = new_interior_node("Def", 2, $2, $3);
        PRINT_ERROR(MISS_SPEC);
    }
    ;
DecList: Dec { $$ = new_interior_node("DecList", 1, $1); }
    | Dec COMMA DecList { $$ = new_interior_node("DecList", 3, $1, $2, $3); }
    ;
Dec: VarDec { $$ = new_interior_node("Dec", 1, $1); }
    | VarDec ASSIGN Exp { $$ = new_interior_node("Dec", 3, $1, $2, $3); }
    ;

/* Expression */
Exp: Exp ASSIGN Exp { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | Exp AND Exp { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | Exp OR Exp { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | Exp LT Exp { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | Exp LE Exp { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | Exp GT Exp { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | Exp GE Exp { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | Exp NE Exp { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | Exp EQ Exp { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | Exp PLUS Exp { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | Exp MINUS Exp { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | Exp MUL Exp { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | Exp DIV Exp { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | LP Exp RP { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | MINUS Exp { $$ = new_interior_node("Exp", 2, $1, $2); }
    | NOT Exp { $$ = new_interior_node("Exp", 2, $1, $2); }
    | ID LP Args RP { $$ = new_interior_node("Exp", 4, $1, $2, $3, $4); }
    | ID LP RP { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | Exp LB Exp RB { $$ = new_interior_node("Exp", 4, $1, $2, $3, $4); }
    | Exp DOT ID { $$ = new_interior_node("Exp", 3, $1, $2, $3); }
    | ID { $$ = new_interior_node("Exp", 1, $1); }
    | INT { $$ = new_interior_node("Exp", 1, $1); }
    | FLOAT { $$ = new_interior_node("Exp", 1, $1); }
    | CHAR { $$ = new_interior_node("Exp", 1, $1); }
    | Exp ERROR Exp { $$ = new_interior_node("Exp", 3, $1, $2, $3); ++errors; }
    | ERROR { $$ = new_interior_node("Exp", 1, $1); ++errors; }
    | LP Exp error {
        $$ = new_interior_node("Exp", 2, $1, $2);
        PRINT_ERROR(MISS_RP);
    }
    | ID LP Args error {
        $$ = new_interior_node("Exp", 3, $1, $2, $3); 
        PRINT_ERROR(MISS_RP);
    }
    | ID LP error {
        $$ = new_interior_node("Exp", 3, $1, $2);
        PRINT_ERROR(MISS_RP);
    }
    ;
Args: Exp COMMA Args { $$ = new_interior_node("Args", 3, $1, $2, $3); }
    | Exp { $$ = new_interior_node("Args", 1, $1); }
    ;

%%
void yyerror (const char *s)
{
  #ifdef VERBOSE
  fprintf (stderr, "ERROR: Line %d, %s \"%s\"\n", yylineno, s, yytext);
  #endif
}

int main (int argc, char **argv)
{
    int len = strlen(argv[1]);
    char* tmp = (char *)malloc(sizeof(char) * len);
    strcpy(tmp, argv[1]);
    strcpy(tmp + len - 3, "out");
    file_out = fopen(tmp, "w");
    printf("%s\n", tmp);

    yyin = fopen(argv[1], "r");
    yyparse();
    
    fclose(file_out);
}