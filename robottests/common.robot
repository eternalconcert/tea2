*** Settings ***
Library     Process

*** Keywords ***
Tea has been called with paramters: ${paramters}
    ${ret}  run process  ./tea  ${paramters}
    [Return]  ${ret.stdout}

Then the result should be
    [Arguments]     ${Expected}     ${Current}
    Should be equal  ${Expected}     "${Current}"
