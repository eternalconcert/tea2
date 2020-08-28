int testCount = 0;


void fn test_eq() {
    bool result = false;

    if (2 == 2) {
      result = true;
    };
    assert(result, true);
    testCount = testCount + 1;
};

void fn test_gt() {
    bool result = false;

    if (2 >= 2) {
      result = true;
    };
    assert(result, true);
    testCount = testCount + 1;
};

void fn test_gte() {
    bool result = false;

    if (3 >= 2) {
      result = true;
    };
    assert(result, true);
    testCount = testCount + 1;
};

// Running tests
test_eq();
test_gt();
test_gte();

// Printing results
print("Run ", testCount, " tests successfully (test_conditions.t)");
