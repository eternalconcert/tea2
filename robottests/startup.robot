*** Settings ***
Documentation    Theses test cases are intended to check various situations during
...              the start prpcess of the Tea interpreter.
Library     Process

*** Test Cases ***

No params
    ${result}  Given tea has been called without paramters
    Then the result should be  "No file or command specified"  ${result}

File does not exists
    ${result}  Given tea has been called with paramters: notExisting.t
    Then the result should be  "tea: /notExisting.t: No such file or directory"  ${result}


*** Keywords ***

Tea has been called without paramters
    ${ret}  run process    ./tea
    [Return]  ${ret.stdout}

Tea has been called with paramters: ${paramters}
    ${ret}  run process  ./tea  ${paramters}
    [Return]  ${ret.stdout}

Then the result should be
    [Arguments]     ${Expected}     ${Current}
    Should be equal  ${Expected}     "${Current}"
