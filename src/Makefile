info:
	@echo Tutorial at: https://www.deezer.com/en/album/42333411

parser:
	lex patterns.l
	yacc -d grammar.y
	gcc -c lex.yy.c -o lex.yy.o
	g++ lex.yy.o y.tab.c -o parser

clean:
	rm parser lex.yy.c y.tab.c y.tab.h lex.yy.o
