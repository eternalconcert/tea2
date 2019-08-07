*** Settings ***
Documentation    Inline comments and block comments should be ignored.
Resource           common.resource

*** Test Cases ***
Inline comments
    [Tags]    comments
    ${result}  Given tea has been called with inline command: 'print(1); // Some stuff'
    Then the result should be  "1"  ${result}
