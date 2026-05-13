str output = cmd("TEA_MAX_CALL_DEPTH=8 ./tea tests/imports/recursion_limit_subject.t; echo $?");
array lines = split(output, "\n");

assert(regexTest(output, "RuntimeError: maximum function call depth exceeded"), true);
assert(lines[len(lines) - 2], "3");

print("tests_recursion_limit.t ok\n");
