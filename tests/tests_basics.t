int testCount = 0;


void fn test_multiline_comment() {
    int a = 23;
    /* This
    is
    a
    comment */
    assert(a, 23);
    testCount = testCount + 1;
};


void fn test_int_assignments() {
    int a = 23;
    assert(a, 23);
    testCount = testCount + 1;
};


void fn test_str_assignments() {
    str a = "Hello";
    assert(a, "Hello");
    testCount = testCount + 1;
};


void fn test_float_assignments() {
    float a = 23.5;
    assert(a, 23.5);
    testCount = testCount + 1;
};


void fn test_bool_assignments() {
    bool a = false;
    assert(a, false);
    testCount = testCount + 1;
};


void fn test_int_reassignments() {
    int a = 23;
    assert(a, 23);
    a = 12;
    assert(a, 12);
    testCount = testCount + 1;
};


void fn test_scoped_reassignment() {
    int a = 23;
    assert(a, 23);
    if (true) {
        a = 12;
    };
    assert(a, 12);
    testCount = testCount + 1;
};

void fn test_else_block() {
    int a = 23;
    if (false) {
        a = 12;
    } else {
        a = 5;
    };
    assert(a, 5);
    testCount = testCount + 1;
};


void fn test_fn_declaration_with_params() {
    void fn test(int a, str b) {
        assert(a, 5);
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
    assert(sysarg_1, "tests/tests_basics.t");
    testCount = testCount + 1;
};

void fn test_sysargs_index_ident() {
    int i = 0;

    str sysarg_0 = SYSARGS[i];
    assert(sysarg_0, "./tea");

    i = 1;
    str sysarg_1 = SYSARGS[i];
    assert(sysarg_1, "tests/tests_basics.t");
    testCount = testCount + 1;
};

void fn test_read_file() {
    str result = read("tests/file.txt");
    assert(result, "hello world");
    testCount = testCount + 1;
};

void fn test_read_file_ident() {
    str path = "tests/file.txt";
    str result = read(path);
    assert(result, "hello world");
    testCount = testCount + 1;
};

void fn test_system_exec_failure_with_ident() {
    str command = "test1234";
    cmd(command);
    int rc = LRC;
    assert(rc, 127);
    testCount = testCount + 1;
};

void fn test_return() {
    int fn func() {
        return 1;
    };
    int a = func();
    assert(a, 1);
    testCount = testCount + 1;
};

void fn test_system_exec_success() {
    cmd("ls");
    int rc = LRC;
    assert(rc, 0);
    testCount = testCount + 1;
};

// Running tests
test_multiline_comment();
test_int_assignments();
test_str_assignments();
test_float_assignments();
test_bool_assignments();
test_int_reassignments();
test_scoped_reassignment();
test_else_block();
test_fn_declaration_with_params();
test_fn_call_with_params_available_in_scope();
test_sysargs();
test_sysargs_index_ident();
test_read_file();
test_read_file_ident();
test_system_exec_failure_with_ident();
test_return();
test_system_exec_success(); // Causes succeeding tests to fail

// Printing results
print("Run ", testCount, " tests successfully (test_basics.t)");
