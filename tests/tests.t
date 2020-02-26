INT testCount = 0;


VOID FN test_INT_Assignments() {
    INT a = 23;
    assert(a, 23);
    testCount = testCount + 1;
};


VOID FN test_STR_Assignments() {
    STR a = "Hello";
    assert(a, "Hello");
    testCount = testCount + 1;
};


VOID FN test_FLOAT_Assignments() {
    FLOAT a = 23.5;
    assert(a, 23.5);
    testCount = testCount + 1;
};


VOID FN test_BOOL_Assignments() {
    BOOL a = false;
    assert(a, false);
    testCount = testCount + 1;
};


VOID FN test_INT_Reassignments() {
    INT a = 23;
    a = 12;
    assert(a, 12);
    testCount = testCount + 1;
};


// Running tests
test_INT_Assignments();
test_STR_Assignments();
test_FLOAT_Assignments();
test_BOOL_Assignments();
test_INT_Reassignments();

// Printing results
print("Run ", testCount, " tests successfully");
