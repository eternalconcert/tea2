BUILDNO ?= 0
CPPSOURCES = $(shell find src/ -name "*.cpp")
# Bison: GCC -Wfree-nonheap-object is a false positive (YYSTACK_FREE guarded by yyss != yyssa).
TEA_CXXFLAGS = -Wno-free-nonheap-object
TEST_FILES = tests/tests_basics.t tests/tests_imports.t tests/tests_functions.t tests/tests_operations.t tests/tests_comparisons.t tests/tests_conditions.t tests/tests_loops.t tests/tests_precedence.t tests/tests_break_continue.t tests/tests_dicts.t tests/tests_json.t tests/tests_cast.t

init-code: stdlib/sys.t
	bash generate_init_code.sh

parser: init-code
	lex src/patterns.l
	bison -d -o y.tab.c src/grammar.y

parser-mac: init-code
	lex src/patterns.l
	/opt/homebrew/opt/bison/bin/bison -d -o y.tab.c src/grammar.y

tea: clean parser
	g++ $(TEA_CXXFLAGS) lex.yy.c y.tab.c $(CPPSOURCES) -o tea --static -D BUILDNO=$(BUILDNO)

mac-tea: clean parser-mac
	clang++ $(TEA_CXXFLAGS) -std=c++17 -Wno-deprecated -Wno-switch lex.yy.c y.tab.c $(CPPSOURCES) -o tea -D BUILDNO=$(BUILDNO) -D MACOS

test: clean build-test run-tests coverage
	@echo "Test coverage completed"

mac-test: clean build-mac-test run-tests coverage
	@echo "Mac test coverage completed"

build-test: parser
	g++ $(TEA_CXXFLAGS) lex.yy.c y.tab.c $(CPPSOURCES) -fprofile-arcs -ftest-coverage -o tea --static -D BUILDNO=$(BUILDNO)

build-mac-test: parser-mac
	clang++ $(TEA_CXXFLAGS) -std=c++17 -Wno-deprecated -Wno-switch lex.yy.c y.tab.c $(CPPSOURCES) -fprofile-arcs -ftest-coverage -o tea -D BUILDNO=$(BUILDNO) -D MACOS

run-tests:
	./tea common/testrunner.t

coverage:
	mkdir -p coverage
	mv *.gcda coverage 2>/dev/null || true
	mv *.gcno coverage 2>/dev/null || true
	@if command -v lcov >/dev/null 2>&1; then \
		lcov -c --directory coverage -o coverage/main_coverage.info --exclude "*tea2/lex.yy.c" --exclude "*src/exceptions.h" --exclude "*tea2/y.tab.c" --exclude "/usr/*" --ignore-errors unsupported,inconsistent; \
		genhtml coverage/main_coverage.info --output-directory coverage/out --ignore-errors unsupported,missing; \
		echo "✓ Coverage report generated in coverage/out/index.html"; \
	else \
		echo "⚠️  lcov not found. Install with: brew install lcov (on macOS) or apt-get install lcov (on Linux)"; \
	fi

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

.PHONY: tea parser parser-mac mac-tea test mac-test build-test build-mac-test run-tests coverage clean robot-test run
