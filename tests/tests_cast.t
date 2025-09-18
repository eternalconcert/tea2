int testCount = 0;


void fn test_str_to_int() {
    str orig = "1";
    cast(orig, int);
    assert(orig + 1, 2);
    testCount = testCount + 1;
};

void fn test_int_to_str() {
    int orig = 1;
    cast(orig, str);
    assert(orig + "A", "1A");
    testCount = testCount + 1;
};

// Running tests
test_str_to_int();
test_int_to_str();

// Printing results
print("Run ", testCount, " tests successfully (test_cast.t)");
