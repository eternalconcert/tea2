*** Settings ***
Documentation    Some basic tests for functions.
Resource           common.resource

*** Test Cases ***
Declare function
    [Tags]    functions
    ${command}    Catenate    '
        ...    INT FN test() {
        ...        print("Should not appear");
        ...    };
        ...    print("check point"); '
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "check point"  ${result}

Run function once
    [Tags]    functions
    ${command}    Catenate    '
        ...    INT FN test() {
        ...        print("Should appear");
        ...    };
        ...    test(); '
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "Should appear"  ${result}

Run function twice
    [Tags]    functions
    ${command}    Catenate    '
        ...    INT FN test() {
        ...        print("Should appear twice when called twice");
        ...    };
        ...    test();
        ...    test(); '
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "Should appear twice when called twice\nShould appear twice when called twice"  ${result}
