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
    assert(a, 23);
    a = 12;
    assert(a, 12);
    testCount = testCount + 1;
};


void fn test_scoped_Reassignment() {
    int a = 23;
    assert(a, 23);
    if (true) {
        a = 12;
    };
    assert(a, 12);
    testCount = testCount + 1;
};


void fn test_fn_declaration_with_params() {
    void fn test(int a, str b) {
        assert(a, 23);
        assert(b, "hello");
    };

    test(5, "hello");
    testCount = testCount + 1;
};


void fn test_fn_call_with_params_available_in_scope() {
    void fn test(int a, str b) {
        a = a + 1;
        assert(a, 6);
        b = b + " world";
        assert(b, "hello world");
    };
    test(5, "hello");
    testCount = testCount + 1;
};


void fn test_sysargs() {
    str sysarg_0 = SYSARGS[0];
    assert(sysarg_0, "./tea");
    str sysarg_1 = SYSARGS[1];
    assert(sysarg_1, "tests/tests.t");
    testCount = testCount + 1;
};

void fn test_sysargs_index_ident() {
    int i = 0;

    str sysarg_0 = SYSARGS[i];
    assert(sysarg_0, "./tea");

    i = 1;
    str sysarg_1 = SYSARGS[i];
    assert(sysarg_1, "tests/tests.t");
    testCount = testCount + 1;
};

// Running tests
test_int_Assignments();
test_str_Assignments();
test_float_Assignments();
test_bool_Assignments();
test_int_Reassignments();
test_scoped_Reassignment();
test_fn_declaration_with_params();
test_fn_call_with_params_available_in_scope();
test_sysargs();
test_sysargs_index_ident();

// Printing results
print("Run ", testCount, " tests successfully");
