CPPSOURCES = $(shell find src/ -name "*.cpp")

parser:
	lex src/patterns.l
	yacc -d src/grammar.y # --verbose

tea: clean parser
	g++ lex.yy.c y.tab.c $(CPPSOURCES) -o tea --static

win-tea: parser
	x86_64-w64-mingw32-g++ lex.yy.c y.tab.c $(CPPSOURCES) -o tea.exe --static

run:
	./tea test.t

clean:
	find . -name "*.o" -delete
	rm -f tea tea.exe lex.yy.c y.tab.c y.tab.h

.PHONY: tea
