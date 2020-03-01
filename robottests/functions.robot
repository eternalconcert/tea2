*** Settings ***
Documentation    Some basic tests for functions.
Resource           common.resource

*** Test Cases ***
Declare function
    [Tags]    functions
    ${command}    Catenate    '
        ...    VOID FN test() {
        ...        print("Should not appear");
        ...    };'
    ${result}  Given tea has been called with inline command: ${command}
    Then the return code should be  "0"  ${result.rc}

Declare function with params
    [Tags]    functions
    ${command}    Catenate    '
        ...    VOID FN test(INT a, STR b) {
        ...    };'
    ${result}  Given tea has been called with inline command: ${command}
    Then the return code should be  "0"  ${result.rc}

Symbols of formal parameterare available in the function
    [Tags]    functions
    ${command}    Catenate    '
        ...    VOID FN test(INT a) {
        ...        a;
        ...    };
        ...    test(23);'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "UnassignedIdentifierError: a"  ${result.stdout}
    Then the return code should be  "5"  ${result.rc}

Run function once
    [Tags]    functions
    ${command}    Catenate    '
        ...    VOID FN test() {
        ...        print("Should appear");
        ...    };
        ...    test(); '
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "Should appear"  ${result.stdout}
    Then the return code should be  "0"  ${result.rc}

Run function twice
    [Tags]    functions
    ${command}    Catenate    '
        ...    VOID FN test() {
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
#         ...    VOID FN test(INT a, STR b) {
#         ...        print(a, b);
#         ...    };
#         ...    test(23, "hello");'
#     ${result}  Given tea has been called with inline command: ${command}
#     Then the result should be  "23hello"  ${result.stdout}
#     Then the return code should be  "0"  ${result.rc}
