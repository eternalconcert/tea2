BUILDNO ?= 0
CPPSOURCES = $(shell find src/ -name "*.cpp")
# Bison: GCC -Wfree-nonheap-object is a false positive (YYSTACK_FREE guarded by yyss != yyssa).
TEA_CXXFLAGS = -Wno-free-nonheap-object

parser:
	lex src/patterns.l
	bison -d -o y.tab.c src/grammar.y

tea: clean parser
	g++ $(TEA_CXXFLAGS) lex.yy.c y.tab.c $(CPPSOURCES) -o tea --static -D BUILDNO=$(BUILDNO)

mac-tea: parser
	clang++ $(TEA_CXXFLAGS) lex.yy.c y.tab.c $(CPPSOURCES) -o tea -D BUILDNO=$(BUILDNO) -D MACOS

test: clean parser
	g++ $(TEA_CXXFLAGS) lex.yy.c y.tab.c $(CPPSOURCES) -fprofile-arcs -ftest-coverage -o tea --static -D BUILDNO=$(BUILDNO)
	./tea tests/tests_basics.t
	./tea tests/tests_imports.t
	./tea tests/tests_functions.t
	./tea tests/tests_operations.t
	./tea tests/tests_comparisons.t
	./tea tests/tests_conditions.t
	./tea tests/tests_loops.t
	./tea tests/tests_precedence.t
	./tea tests/tests_break_continue.t
	./tea tests/tests_dicts.t
	./tea tests/tests_json.t
	./tea tests/tests_cast.t
	mkdir -p coverage
	mv *.gcda coverage
	mv *.gcno coverage
	lcov -c --directory coverage -o coverage/main_coverage.info --exclude "*tea2/lex.yy.c" --exclude "*src/exceptions.h" --exclude "*tea2/y.tab.c" --exclude "/usr/*"
	genhtml coverage/main_coverage.info --output-directory coverage/out

win-tea: parser
	x86_64-w64-mingw32-g++ $(TEA_CXXFLAGS) lex.yy.c y.tab.c $(CPPSOURCES) -o tea.exe --static

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
