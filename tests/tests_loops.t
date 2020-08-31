int testCount = 0;


void fn test_while_loop_value_change_count() {
    int a = 10;
    while (a > 0) {
      a = a - 1;
    };
    assert(a, 0);
    testCount = testCount + 1;
};


// Running tests
test_while_loop_value_change_count();

// Printing results
print("Run ", testCount, " tests successfully (test_loops.t)");
