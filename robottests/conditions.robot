*** Settings ***
Documentation    Ef-Else operators etc.
Resource           common.resource

*** Test Cases ***
Test if template
    [Tags]    conditions
    [Template]    For the condition ${condition} the result should be ${expected}
    1 > 2                            "not met"
    -1 > 2                           "not met"
    -1 < 2                           "met"
    100 > -1000                      "met"
    -100 > -1000                     "met"
    true > false                     "met"
    "hello" > "world"                "not met"
    "hello" >= "world"               "not met"
    "hello" == "world"               "not met"
    "hello" != "world"               "met"
    1.0 == 1                         "met"
    1 == 1.0                         "met"
    1 == "1"                         "met"
    1 and true                       "met"
    1 and false                      "not met"
    true && "hello"                  "met"
    false and "world"                "not met"
    true & 1 && 1 and "hello"        "met"
    true & 0 && 1 and "hello"        "not met"
    1 or true                        "met"
    1 or false                       "met"
    true || "hello"                  "met"
    false || "world"                 "met"
    true | 1 || 1 or "hello"         "met"
    true | 0 | 1 or "hello"          "met"
    false | 0 | 0 or ""              "not met"
    1                                "met"
    2                                "met"
    1.0                              "met"
    2.0                              "met"
    -1 + 3                           "met"
    100 - 99.0                       "met"
    "test"                           "met"
    ""                               "not met"
    0                                "not met"
    -1                               "not met"
    12 - 100                         "not met"
    -0.1                             "not met"


*** Keywords ***
For the condition ${condition} the result should be ${expected}
    ${command}    Catenate
    ...    'if (${condition}) {
    ...            print("met");
    ...        } else {
    ...            print("not met");
    ...        };'
    ${result}  Given tea has been called with inline command: ${command}
    Then the result should be    ${expected}    ${result}
