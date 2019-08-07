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

No scope violation access for constants
    [Tags]    scope
    ${command}    Catenate    '
        ...    if (true) {
        ...        CONST INT d = 23;
        ...    };
        ...    print(d);'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be  "23"  ${result}
