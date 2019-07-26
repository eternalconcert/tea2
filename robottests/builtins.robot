*** Settings ***
Documentation    Theses test cases are intended to check various situations during
...              the start prpcess of the Tea interpreter.
Resource           common.robot

*** Test Cases ***
Print string
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print("hello world");'
    Then the result should be  "hello world"  ${result}

Print concatenated strings
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print("hello", "world");'
    Then the result should be  "helloworld"  ${result}

Print single integer
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(12);'
    Then the result should be  "12"  ${result}

Print negative integer
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(-5);'
    Then the result should be  "-5"  ${result}

Print concatenated negative an positive integer
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(-50);'
    Then the result should be  "-50"  ${result}

Print signed postive integer
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(+5);'
    Then the result should be  "5"  ${result}

Print concatenated integers
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(12, 34);'
    Then the result should be  "1234"  ${result}

Print single float
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(1.2);'
    Then the result should be  "1.200000"  ${result}

Print negative float
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(-23.0);'
    Then the result should be  "-23.000000"  ${result}

Print concatenated negative and positive float
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(-23.0, 123);'
    Then the result should be  "-23.000000123"  ${result}

Print concatenated floats
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(1.2, 3.4);'
    Then the result should be  "1.2000003.400000"  ${result}

Print boolean
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(false);'
    Then the result should be  "false"  ${result}

Print concatenated booleans
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(true, false, true);'
    Then the result should be  "truefalsetrue"  ${result}

Print concatenated mixed type
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print(true, "hello", 1, 2.3);'
    Then the result should be  "truehello12.300000"  ${result}

Print without param
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print();'
    Then the result should be  ""  ${result}

Print blank
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print("");'
    Then the result should be  ""  ${result}

Print concatendated blank
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print("", "");'
    Then the result should be  ""  ${result}

Print concatendated blank with string
    [Tags]    printing
    ${result}  Given tea has been called with inline command: 'print("", "hello");'
    Then the result should be  "hello"  ${result}

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
