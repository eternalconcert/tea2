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
    assert(a, 23, "custom assert message");
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

void fn test_write_file() {
    write("/tmp/tea_write_test.txt", "hello tea");
    str result = read("/tmp/tea_write_test.txt");
    assert(result, "hello tea");
    testCount = testCount + 1;
};

void fn test_write_file_ident() {
    str path = "/tmp/tea_write_test_ident.txt";
    str content = "hello from variables";
    write(path, content);
    str result = read(path);
    assert(result, content);
    testCount = testCount + 1;
};

void fn test_split() {
    array result = split("hello,tea,world", ",");
    assert(result, ["hello", "tea", "world"]);
    assert(result[0], "hello");
    int index = 2;
    assert(result[index], "world");
    int offset = -1;
    assert(result[index] + offset, "world-1");
    testCount = testCount + 1;
};

void fn test_str_index() {
    str text = "hello";
    assert(text[0], "h");
    int index = 4;
    assert(text[index], "o");
    testCount = testCount + 1;
};

str fn test_get_substring(str invalue, int startIndex, int endIndex) {
    str result = "";
    int i = startIndex;
    while (i < endIndex) {
        result = result + invalue[i];
        i = i + 1;
    };
    return result;
};

void fn test_str_index_in_expression() {
    assert(test_get_substring("hello world", 0, 5), "hello");
    testCount = testCount + 1;
};

void fn test_str_find() {
    assert(find("hello hello", "lo"), [3, 9]);
    assert(find("hello", "x"), []);
    assert(find("aaaa", "aa"), [0, 1, 2]);
    testCount = testCount + 1;
};

void fn test_str_len() {
    assert(len("hello"), 5);
    str text = "tea";
    assert(len(text), 3);
    assert(len(""), 0);
    assert(len(["hello", "tea", "world"]), 3);
    array parts = split("a,b,c", ",");
    assert(len(parts), 3);
    int startIndex = 2;
    assert(startIndex + len(text), 5);
    testCount = testCount + 1;
};

void fn test_system_exec_failure_with_ident() {
    str command = "test1234";
    cmd(command);
    int rc = LRC;
    assert(rc, 32512);
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
test_sysargs();
test_sysargs_index_ident();
test_read_file();
test_read_file_ident();
test_write_file();
test_write_file_ident();
test_split();
test_str_index();
test_str_index_in_expression();
test_str_find();
test_str_len();
test_system_exec_success(); // Causes succeeding tests to fail

// Printing results
print("Run ", testCount, " tests successfully (test_basics.t)");
