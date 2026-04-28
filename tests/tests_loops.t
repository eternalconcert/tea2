int testCount = 0;


void fn test_while_loop_value_change_count() {
    int a = 10;
    while (a > 0) {
      a = a - 1;
    };
    assert(a, 0);
    testCount = testCount + 1;
};

void fn test_while_loop_re_evaluates_body_expressions() {
    int i = 0;
    int sum = 0;
    while (i < 10) {
      sum = sum + i;
      i = i + 1;
    };
    assert(sum, 45);
    testCount = testCount + 1;
};


// Running tests
test_while_loop_value_change_count();
test_while_loop_re_evaluates_body_expressions();

// Printing results
print("Run ", testCount, " tests successfully (test_loops.t)");
