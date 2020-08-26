*** Settings ***
Documentation    Theses test cases are intended to check the printing function
Resource           common.resource

*** Test Cases ***
Print string
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print("hello world");'
    Then the result should be  "hello world"  ${result.stdout}

Print concatenated strings
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print("hello", "world");'
    Then the result should be  "helloworld"  ${result.stdout}

Print single integer
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(12);'
    Then the result should be  "12"  ${result.stdout}

Print negative integer
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(-5);'
    Then the result should be  "-5"  ${result.stdout}

Print concatenated negative an positive integer
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(-50);'
    Then the result should be  "-50"  ${result.stdout}

Print signed postive integer
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(+5);'
    Then the result should be  "5"  ${result.stdout}

Print concatenated integers
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(12, 34);'
    Then the result should be  "1234"  ${result.stdout}

Print single float
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(1.2);'
    Then the result should be  "1.200000"  ${result.stdout}

Print negative float
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(-23.0);'
    Then the result should be  "-23.000000"  ${result.stdout}

Print concatenated negative and positive float
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(-23.0, 123);'
    Then the result should be  "-23.000000123"  ${result.stdout}

Print concatenated floats
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(1.2, 3.4);'
    Then the result should be  "1.2000003.400000"  ${result.stdout}

Print boolean
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(false);'
    Then the result should be  "false"  ${result.stdout}

Print concatenated booleans
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(true, false, true);'
    Then the result should be  "truefalsetrue"  ${result.stdout}

Print concatenated mixed type
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(true, "hello", 1, 2.3);'
    Then the result should be  "truehello12.300000"  ${result.stdout}

Print without param
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(1); print(); print(1);'
    Then the result should be  "1\n\n1"  ${result.stdout}

Print blank
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print("");'
    Then the result should be  ""  ${result.stdout}

Print concatendated blank
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print("", "");'
    Then the result should be  ""  ${result.stdout}

Print concatendated blank with string
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print("", "hello");'
    Then the result should be  "hello"  ${result.stdout}

Print simple expression
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(1 + 1);'
    Then the result should be  "2"  ${result.stdout}

Print simple expression with three operants
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(1 + 1 - 1);'
    Then the result should be  "1"  ${result.stdout}

Print expression with mixed operants
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(1 + "a");'
    Then the result should be  "1a"  ${result.stdout}

Print expression with mixed operants reverse
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print("a" + 1);'
    Then the result should be  "a1"  ${result.stdout}

Print expression and other arguments
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(1 - 2, "hello" + " world", "!");'
    Then the result should be  "-1hello world!"  ${result.stdout}

Print variable
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'str hello = "Hello world!"; print(hello);'
    Then the result should be  "Hello world!"  ${result.stdout}

Print variable as expression operant
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'int a = 12; print(a * "x");'
    Then the result should be  "xxxxxxxxxxxx"  ${result.stdout}

Print multiple variables
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'int a = 4; int b = 2; print(a, b);'
    Then the result should be  "42"  ${result.stdout}
