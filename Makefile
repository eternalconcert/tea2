CPPSOURCES = $(shell find src/ -name "*.cpp")

parser:
	lex src/patterns.l
	yacc -d src/grammar.y # --verbose

tea: clean parser
	g++ lex.yy.c y.tab.c $(CPPSOURCES) -o tea --static

test: clean parser
	g++ lex.yy.c y.tab.c $(CPPSOURCES) -fprofile-arcs -ftest-coverage -o tea --static
	./tea tests/tests_basics.t
	./tea tests/tests_operations.t
	./tea tests/tests_comparisons.t
	./tea tests/tests_conditions.t
	mkdir -p coverage
	mv *.gcda coverage
	mv *.gcno coverage
	lcov -c --directory coverage -o coverage/main_coverage.info --exclude "*tea2/lex.yy.c" --exclude "*src/exceptions.h" --exclude "*tea2/y.tab.c" --exclude "/usr/*"
	genhtml coverage/main_coverage.info --output-directory coverage/out

win-tea: parser
	x86_64-w64-mingw32-g++ lex.yy.c y.tab.c $(CPPSOURCES) -o tea.exe --static

run:
	./tea test.t

clean:
	find . -name "*.o" -delete
	find . -name "*.gcda" -delete
	find . -name "*.gcno" -delete
	rm -rf tea tea.exe lex.yy.c y.tab.c y.tab.h coverage

robot-test:
	pythonenv/bin/robot robottests
	./tea tests/tests.t

.PHONY: tea
