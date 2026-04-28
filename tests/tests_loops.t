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

void fn test_for_loop_sum() {
    int sum = 0;
    for (int i = 0; i < 10; i = i + 1) {
        sum = sum + i;
    };
    assert(sum, 45);
    testCount = testCount + 1;
};

void fn test_for_loop_without_init_and_post() {
    int i = 0;
    int sum = 0;
    for (; i < 10; ) {
        sum = sum + i;
        i = i + 1;
    };
    assert(sum, 45);
    testCount = testCount + 1;
};


// Running tests
test_while_loop_value_change_count();
test_while_loop_re_evaluates_body_expressions();
test_for_loop_sum();
test_for_loop_without_init_and_post();

// Printing results
print("Run ", testCount, " tests successfully (test_loops.t)");
