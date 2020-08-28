int testCount = 0;


void fn test_int_addition() {
    int result = 1 + 1;
    assert(result, 2);
    testCount = testCount + 1;
};

void fn test_int_substraction() {
    int result = 10 - 2;
    assert(result, 8);
    testCount = testCount + 1;
};

void fn test_int_substraction_negative_result() {
    int result = 10 - 100;
    assert(result, -90);
    testCount = testCount + 1;
};

void fn test_int_multiplication() {
    int result = 10 * 5;
    assert(result, 50);
    testCount = testCount + 1;
};

void fn test_int_division() {
    int result = 10 / 5;
    assert(result, 2);
    testCount = testCount + 1;
};

void fn test_int_negative_multiplication() {
    int result = 10 * -5;
    assert(result, -50);
    testCount = testCount + 1;
};

void fn test_float_addition() {
    float result = 1.0 + 1.0;
    assert(result, 2.0);
    testCount = testCount + 1;
};

void fn test_float_substraction() {
    float result = 10.0 - 2.0;
    assert(result, 8.0);
    testCount = testCount + 1;
};

void fn test_float_substraction_negative_result() {
    float result = 10.0 - 100.0;
    assert(result, -90.0);
    testCount = testCount + 1;
};

void fn test_float_multiplication() {
    float result = 10.0 * 5.0;
    assert(result, 50.0);
    testCount = testCount + 1;
};

void fn test_float_division() {
    float result = 10.0 / 5.0;
    assert(result, 2.0);
    testCount = testCount + 1;
};

void fn test_float_negative_multiplication() {
    float result = 10 * -5.0;
    assert(result, -50.0);
    testCount = testCount + 1;
};

void fn test_str_addition() {
    str result = "hello " + "world";
    assert(result, "hello world");
    testCount = testCount + 1;
};

void fn test_str_substraction() {
    str result = "hello world" - 6;
    assert(result, "hello");
    testCount = testCount + 1;
};

void fn test_int_mod() {
    int result = 10 % 3;
    assert(result, 1);
    testCount = testCount + 1;
};

// Running tests
test_int_addition();
test_int_substraction();
test_int_substraction_negative_result();
test_int_multiplication();
test_int_division();
test_int_negative_multiplication();
test_float_addition();
test_float_substraction();
test_float_substraction_negative_result();
test_float_multiplication();
test_float_division();
test_float_negative_multiplication();

test_str_addition();
test_str_substraction();
test_int_mod();

// Printing results
print("Run ", testCount, " tests successfully (test_operations.t)");
