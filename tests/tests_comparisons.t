int testCount = 0;


void fn test_equality_str() {
    bool result = "hello" == "hello";
    assert(result, true);
    testCount = testCount + 1;
};

void fn test_equality_str_ident() {
    str a = "hello";
    bool result = "hello" == a;
    assert(result, true);
    testCount = testCount + 1;
};

void fn test_equality_str_ident_reverse() {
    str a = "hello";
    bool result = a == "hello";
    assert(result, true);
    testCount = testCount + 1;
};

void fn test_equality_int() {
    bool result = 23 == 23;
    assert(result, true);
    testCount = testCount + 1;
};

void fn test_equality_int_ident() {
    int a = 23;
    bool result = a == 23;
    assert(result, true);
    testCount = testCount + 1;
};

void fn test_equality_int_ident_reverse() {
    int a = 23;
    bool result = 23 == a;
    assert(result, true);
    testCount = testCount + 1;
};



void fn test_equality_boolean() {
    bool a = true;
    bool result = true == a;
    assert(result, true);
    testCount = testCount + 1;
};

// Running tests
test_equality_str();
test_equality_str_ident();
test_equality_int();
test_equality_int_ident();
test_equality_int_ident_reverse();

test_equality_boolean();
// Printing results
print("Run ", testCount, " tests successfully (test_comparisons.t)");
