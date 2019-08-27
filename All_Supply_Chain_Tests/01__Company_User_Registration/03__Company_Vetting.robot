*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Common_Keywords.robot
Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Email_Keywords.robot

Suite Setup     Open browser and start
Suite Teardown  Close All Browsers

Force Tags      skip


*** Variables ***


*** Test Cases ***

Look up a new company

    Given I'm logged in as  ${GLOBAL_ADMIN_USER}  ${GLOBAL_ADMIN_PASSWORD}
    When I'm at the global admin dashboard, review company registrations page
    And I click the review link for:  google-${UNIQUE_ID}
    Then I can lookup this company with D&B:  google
    And I get at least this many results that contain this company:  5  GOOGLE LLC


*** Keywords ***

I get at least this many results that contain this company:
    [Documentation]  Verify the B&B lookup results by count and string
    [Arguments]      ${count}  ${company_name}
    [Tags]          local

    # Get the match count and compare
    ${match_cnt}=  Get element count  class:qa-result-card
    Page should contain  Match Count: ${match_cnt}
    Should be true  ${match_cnt} >= ${count}


I can lookup this company with D&B:
    [Documentation]  Click the lookup link on the company review page
    [Arguments]      ${company}
    [Tags]          local

    #Click element  class:qa-review-validate-btn
    #Wait until page contains  Select attributes you would like to send to Dun & Bradstreet

    # Select lookup attributes
    Select checkbox  name:dnb[name]
    Select checkbox  name:dnb[countryISOAlpha2Code]
    Click button     class:qa-duns-modal-button
    Wait until page contains  Company Under Review: ${company}


I click the review link for:
    [Documentation]  Click the 'review' link associated with a company name on the 'Review - Company Registration Forms' page
    [Arguments]      ${company}
    [Tags]          local

    Click link  class:qa-review-${company}
    Wait until page contains  Admin Review: "${company}"

    Click element  id:verify-tab
    Wait until page contains  Send selected info to DnB



