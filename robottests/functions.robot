*** Settings ***
Documentation    Some basic tests for functions.
Resource           common.resource

*** Test Cases ***
Declare function
    [Tags]    functions
    ${command}    Catenate    '
        ...    void fn test() {
        ...        print("Should not appear");
        ...    };'
    ${result}  Given tea has been called with inline command: ${command}
    Then the return code should be  "0"  ${result.rc}

Declare function with params
    [Tags]    functions
    ${command}    Catenate    '
        ...    void fn test(int a, str b) {
        ...    };'
    ${result}  Given tea has been called with inline command: ${command}
    Then the return code should be  "0"  ${result.rc}

Too less parameters to function
    [Tags]    functions
    ${command}    Catenate    '
        ...    void fn test(int a) {
        ...        a;
        ...    };
        ...    test();'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "ParameterError: "Not enough arguments supplied"  ${result.stdout}
    Then the return code should be  "8"  ${result.rc}

Run function once
    [Tags]    functions
    ${command}    Catenate    '
        ...    void fn test() {
        ...        print("Should appear");
        ...    };
        ...    test(); '
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "Should appear"  ${result.stdout}
    Then the return code should be  "0"  ${result.rc}

Run function twice
    [Tags]    functions
    ${command}    Catenate    '
        ...    void fn test() {
        ...        print("Should appear twice when called twice");
        ...    };
        ...    test();
        ...    test(); '
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "Should appear twice when called twice\nShould appear twice when called twice"  ${result.stdout}
    Then the return code should be  "0"  ${result.rc}


# Function call with params available in inner scop
#     [Tags]    functions
#     ${command}    Catenate    '
#         ...    void fn test(int a, str b) {
#         ...        print(a, b);
#         ...    };
#         ...    test(23, "hello");'
#     ${result}  Given tea has been called with inline command: ${command}
#     Then the result should be  "23hello"  ${result.stdout}
#     Then the return code should be  "0"  ${result.rc}
