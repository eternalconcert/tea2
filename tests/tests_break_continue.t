int testCount = 0;

void fn test_while_break() {
    int i = 0;
    while (i < 10) {
        i = i + 1;
        if (i == 3) {
            break;
        };
    };
    assert(i, 3);
    testCount = testCount + 1;
};

void fn test_while_continue() {
    int sum = 0;
    int i = 0;
    while (i < 5) {
        i = i + 1;
        if (i == 2) {
            continue;
        };
        sum = sum + i;
    };
    assert(sum, 13);
    testCount = testCount + 1;
};

void fn test_for_break() {
    int k = 0;
    for (int j = 0; j < 10; j = j + 1) {
        k = k + 1;
        if (j == 4) {
            break;
        };
    };
    assert(k, 5);
    testCount = testCount + 1;
};

void fn test_for_continue() {
    int sum = 0;
    for (int j = 0; j < 5; j = j + 1) {
        if (j == 2) {
            continue;
        };
        sum = sum + j;
    };
    assert(sum, 8);
    testCount = testCount + 1;
};

test_while_break();
test_while_continue();
test_for_break();
test_for_continue();

print("Run ", testCount, " tests successfully (tests_break_continue.t)");
