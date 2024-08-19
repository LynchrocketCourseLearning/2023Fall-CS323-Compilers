CC=gcc
FLEX=flex
YACC=bison

.PHONY: splc
splc: syntax.y lex.l parse_tree.c parse_tree.h
	@mkdir bin
	touch bin/splc
	@chmod +x bin/splc
	$(YACC) -t -d syntax.y
	$(FLEX) lex.l
	$(CC) syntax.tab.c parse_tree.c yyerror_ow.c -o bin/splc -ll $(CFLAGS)
clean:
	@rm -rf bin/
	@rm -f *.yy.* *.tab.* splc