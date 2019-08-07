CPPSOURCES = $(shell find src/ -name "*.cpp")

tea:
	lex src/patterns.l
	yacc -d src/grammar.y # --verbose
	g++ lex.yy.c y.tab.c $(CPPSOURCES) -o tea -lfl

run:
	./tea test.t

clean:
	find . -name "*.o" -delete
	rm tea lex.yy.c y.tab.c y.tab.h

.PHONY: tea
