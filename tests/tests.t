int testCount = 0;


void fn test_int_Assignments() {
    int a = 23;
    assert(a, 23);
    testCount = testCount + 1;
};


void fn test_str_Assignments() {
    str a = "Hello";
    assert(a, "Hello");
    testCount = testCount + 1;
};


void fn test_float_Assignments() {
    float a = 23.5;
    assert(a, 23.5);
    testCount = testCount + 1;
};


void fn test_bool_Assignments() {
    bool a = false;
    assert(a, false);
    testCount = testCount + 1;
};


void fn test_int_Reassignments() {
    int a = 23;
    a = 12;
    assert(a, 12);
    testCount = testCount + 1;
};


void fn test_fn_declaration_with_params() {
    void fn test(int a, str b) {
        print(a, b);
    };
    testCount = testCount + 1;
};


void fn test_fn_call_with_params_available_in_scope() {
    void fn test(int a, str b) {
        a;
        b;
    };
    test();
    testCount = testCount + 1;
};


// Running tests
test_int_Assignments();
test_str_Assignments();
test_float_Assignments();
test_bool_Assignments();
test_int_Reassignments();
test_fn_declaration_with_params();
// test_fn_call_with_params_available_in_scope();

// Printing results
print("Run ", testCount, " tests successfully");
