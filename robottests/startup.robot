*** Settings ***
Documentation    Theses test cases are intended to check various situations during
...              the start prpcess of the Tea interpreter.
Resource           common.robot

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
