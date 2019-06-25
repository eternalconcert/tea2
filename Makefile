info:
	@echo Tutorial at: https://www.deezer.com/en/album/42333411

tea:
	lex src/patterns.l
	yacc -d src/grammar.y
	gcc -c lex.yy.c -o lex.yy.o
	g++ lex.yy.o y.tab.c -o tea

pythonenv:
	virtualenv --python=python3 pythonenv
	pythonenv/bin/pip install robotframework

robottests:
	pythonenv/bin/robot robottests

clean:
	rm parser lex.yy.c y.tab.c y.tab.h lex.yy.o

.PHONY: tea robottests
