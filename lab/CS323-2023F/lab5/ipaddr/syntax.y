%{
    #define YYSTYPE char *
    #include "lex.yy.c"
    int yyerror(char* s);
%}

%token X
%token DOT
%token COLON

%%

// please design a grammar for the valid ip addresses and provide necessary semantic actions for production rules

Print: /* to allow empty input */
    | Ipv4 { printf(($1 == "1") ? "ipv4\n" : "Invalid\n"); }
    | Ipv6 { printf(($1 == "1") ? "ipv6\n" : "Invalid\n"); }
    | Ipv4 DOT X { printf("Invalid\n"); }
    | Ipv6 COLON X { printf("Invalid\n"); } 
    ;
Ipv4: X DOT X DOT X DOT X {
        YYSTYPE xs[] = {$1, $3, $5, $7};
        $$ = "1";
        for(int j = 0; j < 4; ++j) {
            YYSTYPE x = xs[j];
            int x_len = strlen(x);
            // check length
            if(x_len < 1 || x_len > 3) {
                $$ = "0";
                break;
            }
            // check leading zero
            if(x_len > 1 && x[0] == '0') {
                $$ = "0";
                break;
            }
            int num = 0;
            if(x_len == 1) {
                num = x[0] - '0';
            } else if(x_len == 2) {
                num = (x[0] - '0') * 10 + (x[1] - '0');
            } else {
                num = (x[0] - '0') * 100 + (x[1] - '0') * 10 + (x[2] - '0');
            }
            if(num < 0 || num > 255) {
                $$ = "0";
                break;
            }
        }
    }
    ;
Ipv6: X COLON X COLON X COLON X COLON X COLON X COLON X COLON X {
        YYSTYPE xs[] = {$1, $3, $5, $7, $9, $11, $13, $15};
        $$ = "1";
        for(int j = 0; j < 8; ++j) {
            YYSTYPE x = xs[j];
            int x_len = strlen(x);
            // check length
            if(x_len < 1 || x_len > 4){
                $$ = "0";
                break;
            }
            // check leading zero
            if(x[0] == '0'){
                int cnt = 0;
                for(int i = 0; i < x_len; ++i) {
                    if(x[i] == '0') {
                        cnt++;
                    }
                }
                if(cnt < x_len){
                    $$ = "0";
                    break;
                }
            }
            // check digit and letter
            for(int i = 0; i < x_len; ++i) {
                if((x[i] < '0' || x[i] > '9') 
                    && (x[i] < 'a' || x[i] > 'f') 
                    && (x[i] < 'A' || x[i] > 'F')) {
                    $$ = "0";
                    break;
                }
            }
            if($$ == "0") {
                break;
            }
        }
    }
    ;
;

%%

int yyerror(char* s) {
    fprintf(stderr, "%s\n", "Invalid");
    return 1;
}
int main() {
    yyparse();
}
