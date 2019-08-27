*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Common_Keywords.robot

Suite Setup     Open browser and start
Suite Teardown  Close All Browsers

#Force Tags      critical   Priority-V1  upload

*** Variables ***


*** Test Cases ***

Admin user can create and save API keys

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Manage API keys page
    Then I can create a new API key:     SAVED_API_KEY-${UNIQUE_ID}
      and Save that key for future use:  ${TEST_KEY}
      and I can create a new API key:    UNSAVED_API_KEY-${UNIQUE_ID}


Admin user can delete an API key

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Manage API keys page
    Then I can delete an API key:     UNSAVED_API_KEY-${UNIQUE_ID}


*** Keywords ***

I can delete an API key:
    [Arguments]      ${key_name}
    [Tags]           local

    Page should contain       Delete Key

    # Find this key name in the table and get path to `Delete`
    ${row}  ${col} =     Find string in table  ${key_name}  Couldn't find this string in the table

    # Click `Delete`
    Click element  xpath://tbody/tr[${row}]/td[4]
    Alert should be present  text=Are you sure you want to remove this key?
    Wait until page does not contain  ${key_name}


Save that key for future use:
    [Arguments]      ${key}
    [Tags]           local

    Set global variable  ${UNIQUE_KEY}  ${key}
    Save dynamic test data to file:   ${DYN_TEST_DATA_FILE}


I can create a new API key:
    [Arguments]      ${key_name}
    [Tags]           local

    Page should contain       Generate New Key
    Click link                Generate New Key
    Wait until page contains  Create New API Key

    Input Text      id=api_key_description  ${key_name}
    Click Button    name=commit
    Wait Until Page Contains   Manage API Keys

    # Get key from the table
    ${row}  ${col} =  Find string in table  ${key_name}  Couldn't find this string in the table

    ${key}=  Get text  xpath://tbody/tr[${row}]/td[2]

    Set test variable  ${TEST_KEY}  ${key}

