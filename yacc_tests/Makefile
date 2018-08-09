info:
	@echo Tutorial at: https://www.deezer.com/en/album/42333411

all:
	lex example.l
	yacc -d example.y
	gcc -c lex.yy.c -o lex.yy.o
	g++ lex.yy.o y.tab.c -o example



clean:
	rm example lex.yy.c y.tab.c y.tab.h lex.yy.o
