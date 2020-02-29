*** Settings ***
Library     Process

*** Keywords ***
Tea has been called with paramters: ${paramters}
    ${ret}  run process  ./tea  ${paramters}
    [Return]  ${ret.stdout}

The result should be
    [Arguments]     ${Expected}     ${Current}
    Should be equal    ${Expected}     "${Current}"

The return code should be
    [Arguments]     ${Expected}     ${Current}
    Should be equal as strings    ${Expected}     "${Current}"

Tea has been called with inline command: ${command}
    ${ret}  run process  ./tea -c ${command}  shell=True
    [Return]  ${ret}
