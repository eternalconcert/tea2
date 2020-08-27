CPPSOURCES = $(shell find src/ -name "*.cpp")

parser:
	lex src/patterns.l
	yacc -d src/grammar.y # --verbose

tea: clean parser
	g++ lex.yy.c y.tab.c $(CPPSOURCES) -o tea --static

test: clean parser
	g++ lex.yy.c y.tab.c $(CPPSOURCES) -fprofile-arcs -ftest-coverage -o tea --static
	./tea tests/tests.t
	mkdir -p coverage
	mv *.gcda coverage
	mv *.gcno coverage
	lcov -c --directory coverage --output-file coverage/main_coverage.info
	genhtml coverage/main_coverage.info --output-directory coverage/out
	firefox coverage/out/index.html

win-tea: parser
	x86_64-w64-mingw32-g++ lex.yy.c y.tab.c $(CPPSOURCES) -o tea.exe --static

run:
	./tea test.t

clean:
	find . -name "*.o" -delete
	rm -rf tea tea.exe lex.yy.c y.tab.c y.tab.h coverage

robot-test:
	pythonenv/bin/robot robottests
	./tea tests/tests.t

.PHONY: tea
