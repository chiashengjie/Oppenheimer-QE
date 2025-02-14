*** Settings ***
Resource    ../Variables/GeneralVariables.resource

*** Keywords ***
Setup Configuration
    Set Selenium Timeout    1 minute
    Set Selenium Speed    0.75 seconds
    Open Browser    ${MainPageURL}    ${BROWSERMODECHROME}
    Maximize Browser Window

Teardown Configuration
    Close Browser

Click Refresh Tax Relief Button
    Click Element    ${REFRESHTAXBUTTON}

Initiate GET Request
    [Arguments]    ${SessionName}    ${APISubURL}
    Create Session    ${SessionName}    ${MainPageURL}
    ${response}=    GET On Session    ${SessionName}    ${APISubURL}
    Log To Console    ${EMPTY}
    Log To Console    == Response Debug ==
    Log To Console    Request Status Code: ${response.status_code}
    Log To Console    Request JSON Response Body: ${response.content}

Initiate POST Request
    [Arguments]    ${SessionName}    ${APISubURL}
    Create Session    ${SessionName}    ${MainPageURL}
    ${header}=    Create Dictionary   Content-Type=application/json
    ${response}=    POST On Session    ${SessionName}    ${APISubURL}    headers=${header}
    [Return]    ${response}
    Log To Console    ${EMPTY}
    Log To Console    == Response Debug ==
    Log To Console    Request Status Code: ${response.status_code}
    Log To Console    Request JSON Response Body: ${response.content}

Initiate POST Request With Parameters
    [Arguments]    ${SessionName}    ${APISubURL}    ${body}
    Create Session    ${SessionName}    ${MAINPAGEURL}
    ${header}=    Create Dictionary   Content-Type=application/json
    ${response}=    POST On Session    ${SessionName}    ${APISubURL}    headers=${header}    json=${body}
    [Return]    ${response}
    Log To Console    ${EMPTY}
    Log To Console    == Response Debug ==
    Log To Console    Request Status Code: ${response.status_code}
    Log To Console    Request JSON Response Body: ${response.content}

Clean Rake Database
    ${response}=    Initiate POST Request    RAKE DATABASE    calculator/rakeDatabase
    Should Be Equal As Strings    ${response.status_code}    200
    Should Be Equal As Strings    ${response.content}    Successfully raked DB
    Reload Page

Insert Hero Details via Insert API
    [Arguments]    ${natid}=${DEFAULT_HERO[0]}    ${name}=${DEFAULT_HERO[1]}    ${gender}=${DEFAULT_HERO[2]}    ${birthday}=${DEFAULT_HERO[3]}    ${salary}=${DEFAULT_HERO[4]}    ${tax}=${DEFAULT_HERO[5]}
    ${body}=    Create Dictionary    natid=${natid}    name=${name}    gender=${gender}    birthday=${birthday}    salary=${salary}    tax=${tax}
    ${response}=    Initiate POST Request With Parameters   Post Tax Relief    calculator/insert    ${body}
    Should Be Equal As Strings    ${response.status_code}    202
    Should Be Equal As Strings    ${response.content}    Alright
    Click Refresh Tax Relief Button
    Wait Until Element Contains    ${TAXRELIEFTEXT}    Total Tax Relieves

Insert Single Hero Details via InsertMultiple API
    [Arguments]    ${body}
    ${bodylist}=    Create List    ${body}
    ${response}=    Initiate POST Request With Parameters   Post Tax Relief List    calculator/insertMultiple    ${bodyList}
    Should Be Equal As Strings    ${response.status_code}    202
    Should Be Equal As Strings    ${response.content}    Alright
    Click Refresh Tax Relief Button
    Wait Until Element Contains    ${TAXRELIEFTEXT}    Total Tax Relieves

Insert Multiple Hero Details via InsertMultiple API
    [Arguments]    ${body1}    ${body2}    ${body3}    ${body4}     ${body5}
    ${bodylist}=    Create List    ${body1}    ${body2}    ${body3}    ${body4}     ${body5}
    ${response}=    Initiate POST Request With Parameters   Post Tax Relief List    calculator/insertMultiple    ${bodyList}
    Should Be Equal As Strings    ${response.status_code}    202
    Should Be Equal As Strings    ${response.content}    Alright
    Click Refresh Tax Relief Button
    Wait Until Element Contains    ${TAXRELIEFTEXT}    Total Tax Relieves

Insert Multiple Random Hero Details via API
    [Arguments]  ${count}
    Initiate POST Request    INSERT RANDOM LIST    calculator/insertRandomToDatabaseForNoReason?count=${count}
    Should Be Equal As Strings    ${response.status_code}    200
    Click Refresh Tax Relief Button
    Wait Until Element Contains    ${TAXRELIEFTEXT}    Total Tax Relieves

Check UI Tax Relief Funds
    [Arguments]    ${TotalReliefFunds}    ${TotalNoOfHeroes}
    Element Should Contain    ${NATIDFIRSTENTRYXPATH}    $$$$$$$
    Element Should Contain    ${CHECKTOTALRELIEFXPATH}    £${TotalReliefFunds} will be dispensed to ${TotalNoOfHeroes} Working Class Hero/s

Check UI Tax Dispense to Working Class Hero
    [Arguments]    ${TotalNoOfHeroes}
    Element Should Contain    ${NATIDFIRSTENTRYXPATH}    $$$$$$$
    Element Should Contain    ${CHECKTOTALRELIEFXPATH}    will be dispensed to ${TotalNoOfHeroes} Working Class Hero/s

Calculate Rough Age from Birthday
    [Arguments]    ${birthday}
    ${BirthdayRange}=    Get Substring    ${birthday}    -4
    ${RoughAgeGroup}=    Evaluate    2021 - ${birthdayrange}
    [Return]    ${RoughAgeGroup}
    Log To Console    ${EMPTY}
    Log To Console    Check for Birthday Year: ${BirthdayRange}
    Log To Console    Check for Rough Age Group: ${RoughAgeGroup}

Check Age Group
    [Arguments]    ${birthday}
    ${RoughAgeGroup}=    Calculate Rough Age from Birthday    ${birthday}
    ${AgeGroupVariable}=    Set Variable If
    ...    ${RoughAgeGroup} <= 18      1
    ...    ${RoughAgeGroup} <= 35      0.8
    ...    ${RoughAgeGroup} <= 50      0.5
    ...    ${RoughAgeGroup} <= 75      0.367
    ...    ${RoughAgeGroup} >= 76      0.05
    [Return]    ${AgeGroupVariable}
    Log To Console    ${EMPTY}
    Log To Console    Check for Tax Relief Variable (Age Group): ${AgeGroupVariable}

Calculate Gender Bonus
    [Arguments]    ${gender}
    ${CheckGender}=    Catenate    SEPARATOR=    '    ${gender}    '
    Log to Console    Gender: ${CheckGender}
    ${GenderBonus}=    Set Variable If
    ...    ${CheckGender} == '${GENDERMALE}'    0
    ...    ${CheckGender} == '${GENDERFEMALE}'    500
    [Return]    ${GenderBonus}
    Log To Console    ${EMPTY}
    Log To Console    Gender Bonus: ${GenderBonus}

Check Tax Relief Funds
    [Arguments]    ${taxreliefrunds}
    ${FinalTaxReliefFunds}=    Set Variable If
    ...        ${taxreliefrunds} < 0    0
    ...    0 <= ${taxreliefrunds} <= 50    50
    ...        ${taxreliefrunds} > 50    ${taxreliefrunds}
    [Return]    ${FinalTaxReliefFunds}
    Log To Console    ${EMPTY}
    Log To Console    Final Tax Relief Funds: ${FinalTaxReliefFunds}

Calculate Tax Relief Funds
    [Arguments]    ${gender}    ${birthday}    ${salary}    ${tax}
    ${TaxReliefVariable}=    Check Age Group    ${birthday}
    ${GenderBonus}=    Calculate Gender Bonus    ${gender}
    ${CalculateTaxRelief}=    Evaluate    ((${salary} - ${tax}) * ${TaxReliefVariable}) + ${GenderBonus}
    ${CheckTaxRelief}=    Check Tax Relief Funds    ${CalculateTaxRelief}
    ${ConvertTaxReliefToInt}=    Convert To Integer    ${CheckTaxRelief}
    ${FinalTaxReliefAmount}=    Evaluate    "%.2f" % ${ConvertTaxReliefToInt}
    Log To Console    ${EMPTY}
    Log To Console    Check if Tax Relief is corrected distributed: ${CheckTaxRelief}
    Log To Console    Convert Tax Relief Amount to Integer: ${ConvertTaxReliefToInt}
    Log To Console    Final Tax Relief Amount: ${FinalTaxReliefAmount}
    [Return]    ${FinalTaxReliefAmount}

Get CSS Property Value
    [Arguments]    ${locator}    ${attribute}
    ${CSSxPath}=         Get WebElement    ${locator}
    ${AttributeProperty}=    Call Method       ${CSSxPath}    value_of_css_property    ${attribute}
    [Return]     ${AttributeProperty}
    Log To Console    ${AttributeProperty}