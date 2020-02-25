INT testCount = 0;


VOID FN test_INT_Assignments() {
    INT a = 23;
    assert(a, 23);
    testCount = testCount + 1;
};


VOID FN test_STR_Assignments() {
    STR b = "Hello";
    assert(b, "Hello");
    testCount = testCount + 1;
};


VOID FN test_FLOAT_Assignments() {
    FLOAT c = 23.5;
    assert(c, 23.5);
    testCount = testCount + 1;
};


VOID FN test_BOOL_Assignments() {
    BOOL d = false;
    assert(d, false);
    testCount = testCount + 1;
};


VOID FN test_INT_Reassignments() {
    INT e = 23;
    e = 12;
    assert(e, 12);
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
