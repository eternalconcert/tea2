*** Settings ***
Documentation    Some basic tests for scoping.
Resource           common.resource

*** Test Cases ***
Same scoped access
    [Tags]    scope
    ${command}    Catenate    '
        ...    if (true) {
        ...        int a = 5;
        ...        print(a);
        ...    }; '
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "5"  ${result.stdout}
    And the return code should be  "0"  ${result.rc}

Parent scoped access
    [Tags]    scope
    ${command}    Catenate    '
        ...    int b = 23;
        ...    if (true) {
        ...        print(b);
        ...    }; '
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "23"  ${result.stdout}
    And the return code should be  "0"  ${result.rc}

Scope violation access
    [Tags]    scope
    ${command}    Catenate    '
        ...    if (true) {
        ...        int c = 23;
        ...    };
        ...    print(c);'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "UnknownIdentifierError: c"  ${result.stdout}
    And the return code should be  "4"  ${result.rc}

Scope violation in assignment
    [Tags]    scope
    ${command}    Catenate    '
        ...    if (true) {
        ...        int d = 23;
        ...    };
        ...    d = 5;'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "UnknownIdentifierError: d"  ${result.stdout}
    And the return code should be  "4"  ${result.rc}

No scope violation in assignment
    [Tags]    scope
    ${command}    Catenate    '
        ...    str d = "hello";
        ...    d = "world!";
        ...    print(d);'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "world!"  ${result.stdout}
    And the return code should be  "0"  ${result.rc}

Variable assignment after function declaration and function call leads to UnknownIdentifierError
    [Tags]    scope
    ${command}    Catenate    '
    ...    void fn test() {
    ...        print(a);
    ...    };
    ...    test();
    ...    int a = 1;'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "UnknownIdentifierError: a"  ${result.stdout}
    And the return code should be  "4"  ${result.rc}
