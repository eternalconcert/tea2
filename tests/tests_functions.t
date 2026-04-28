int testCount = 0;


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


void fn test_fn_return_with_params_from_nested_scope() {
    int fn add(int a, int b) {
        return a + b;
    };

    int x = 1;
    while (x <= 10) {
        x = add(x, x);
    };
    assert(x, 16);
    testCount = testCount + 1;
};


void fn test_fn_return_without_params() {
    int fn answer() {
        return 42;
    };

    int result = answer();
    assert(result, 42);
    testCount = testCount + 1;
};


void fn test_fn_return_str_with_param() {
    str fn greet(str name) {
        return "hello " + name;
    };

    str greeting = greet("tea");
    assert(greeting, "hello tea");
    testCount = testCount + 1;
};


void fn test_fn_call_as_argument() {
    int fn double(int value) {
        return value * 2;
    };

    int fn add(int a, int b) {
        return a + b;
    };

    int result = add(double(3), 4);
    assert(result, 10);
    testCount = testCount + 1;
};


void fn test_fn_return_from_if_else_branch() {
    str fn combine(str a, str b, bool separator) {
        if (separator) {
            return a + " " + b;
        }
        else {
            return a + b;
        };
    };

    assert(combine("hello", "world", true), "hello world");
    assert(combine("hello", "world", false), "helloworld");
    testCount = testCount + 1;
};


// Running tests
test_fn_declaration_with_params();
test_fn_call_with_params_available_in_scope();
test_fn_return_with_params_from_nested_scope();
test_fn_return_without_params();
test_fn_return_str_with_param();
test_fn_call_as_argument();
test_fn_return_from_if_else_branch();

// Printing results
print("Run ", testCount, " tests successfully (test_functions.t)");
