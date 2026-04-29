int testCount = 0;

void fn test_mul_before_add() {
    int r = 1 + 2 * 3;
    assert(r, 7);
    testCount = testCount + 1;
};

void fn test_mul_before_sub() {
    int r = 10 - 2 * 3;
    assert(r, 4);
    testCount = testCount + 1;
};

void fn test_cmp_before_and() {
    bool r = 1 == 1 and 2 == 2;
    assert(r, true);
    testCount = testCount + 1;
};

void fn test_and_before_or() {
    bool r = false or true and false;
    assert(r, false);
    testCount = testCount + 1;
};

void fn test_and_short_circuit() {
    int calls = 0;
    bool fn side() {
        calls = calls + 1;
        return true;
    };
    bool r = false and side();
    assert(r, false);
    assert(calls, 0);
    testCount = testCount + 1;
};

test_mul_before_add();
test_mul_before_sub();
test_cmp_before_and();
test_and_before_or();
test_and_short_circuit();

print("Run ", testCount, " tests successfully (tests_precedence.t)");
