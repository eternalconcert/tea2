*** Settings ***
Documentation    Some basic tests for scoping.
Resource           common.resource

*** Test Cases ***
Same scoped access
    [Tags]    scope
    ${command}    Catenate    '
        ...    if (true) {
        ...        INT a = 5;
        ...        print(a);
        ...    }; '
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "5"  ${result}

Parent scoped access
    [Tags]    scope
    ${command}    Catenate    '
        ...    INT b = 23;
        ...    if (true) {
        ...        print(b);
        ...    }; '
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "23"  ${result}

Scope violation access
    [Tags]    scope
    ${command}    Catenate    '
        ...    if (true) {
        ...        INT c = 23;
        ...    };
        ...    print(c);'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "UnknownIdentifierError: c"  ${result}

Scope violation in assignment
    [Tags]    scope
    ${command}    Catenate    '
        ...    if (true) {
        ...        INT d = 23;
        ...    };
        ...    d = 5;'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "UnknownIdentifierError: d"  ${result}

No scope violation in assignment
    [Tags]    scope
    ${command}    Catenate    '
        ...    STR d = "hello";
        ...    d = "world!";
        ...    print(d);'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "world!"  ${result}

No const violation by redefining variables
    [Tags]    scope
    ${command}    Catenate    '
        ...    STR d = "hello";
        ...    d = "world!";
        ...    print(d);'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "world!"  ${result}

No const violation by redefining variables and using as parameter
    [Tags]    scope    bug
    [Documentation]    This case has been found after month. The first print() causes the problem.
    ${command}    Catenate    '
        ...    STR d = "hello";
        ...    d;
        ...    STR d = "world!";
        ...    print(d);'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "world!"  ${result}

No scope violation access for constants
    [Tags]    scope
    ${command}    Catenate    '
        ...    if (true) {
        ...        CONST INT d = 23;
        ...    };
        ...    print(d);'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "23"  ${result}

Const violation by reassigning value to constant
    [Tags]    scope
    ${command}    Catenate    '
        ...    CONST INT d = 1;
        ...    d = 2;'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "ConstError: d"  ${result}

Const violation by assigning constant to identifier in use
    [Tags]    scope
    ${command}    Catenate    '
    ...    INT b = 2;
    ...    CONST INT b = 1;'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "ConstError: Identifier already in use as constant"  ${result}
