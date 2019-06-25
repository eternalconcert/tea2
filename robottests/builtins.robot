*** Settings ***
Documentation    Theses test cases are intended to check various situations during
...              the start prpcess of the Tea interpreter.
Resource           common.robot

*** Test Cases ***
Print string
    ${result}  Given tea has been called with inline command: 'print("hello world");'
    Then the result should be  "hello world"  ${result}

Print without param
    ${result}  Given tea has been called with inline command: 'print();'
    Then the result should be  ""  ${result}

Print blank
    ${result}  Given tea has been called with inline command: 'print("");'
    Then the result should be  ""  ${result}

Command
    ${result}  Given tea has been called with inline command: 'cmd("echo hello world");'
    Then the result should be  "hello world"  ${result}

Command without param
    ${result}  Given tea has been called with inline command: 'cmd();'
    Then the result should be  ""  ${result}

Command blank
    ${result}  Given tea has been called with inline command: 'cmd("");'
    Then the result should be  ""  ${result}

*** Keywords ***
Tea has been called with inline command: ${command}
    ${ret}  run process  ./tea -c ${command}  shell=True
    [Return]  ${ret.stdout}
