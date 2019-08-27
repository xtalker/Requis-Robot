*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/RFQ_Support.robot

Suite Setup     Open browser and start
Suite Teardown  Close All Browsers

#Force Tags      skip

*** Variables ***

# RFQ table column indexes
${PROJ_NAME_COL}=        1
${PROJ_NUM_COL}=         2
${PROJ_SITE_COL}=        3
${PROJ_ACTIONS_COL}=     4

*** Test Cases ***

Create and view new RFQ projects

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - Projects page
    Then I can create and view a new RFQ project with this test data:  ${PROJECT_1}
    And I can create and view a new RFQ project with this test data:   ${PROJECT_2}
    And I can create and view a new RFQ project with this test data:   ${PROJECT_3}
    And I can create and view a new RFQ project with this test data:   ${PROJECT_4}


Edit and view an existing RFQ project

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - Projects page
    Then I can edit and view this RFQ project with this test data:  ${PROJECT_4.name}  ${PROJECT_5}


Delete an existing RFQ project

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - Projects page
    Then I can delete this RFQ project:  ${PROJECT_5.name}


*** Keywords ***

I can delete this RFQ project:
    [Documentation]  Delete an RFQ project
    [Tags]          local
    [Arguments]     ${project_name}

    # Find this RFQ in the table and click `delete rfq`
    ${row}  ${col} =  Find string in table  ${project_name}  Couldn't find ${project_name} in table
    ${actions_xpath} =  Set variable  //tbody/tr[${row}]/td[${PROJ_ACTIONS_COL}]
    Set focus to element  xpath: ${actions_xpath}
    Click link  xpath:${actions_xpath}//a[contains(@class,'qa-proj-delete')]

    Wait until element is visible   class=alert-success
    Page should contain  Successfully deleted project

    Page should not contain  ${project_name}


I can edit and view this RFQ project with this test data:
    [Documentation]  View and verify a RFQ project with test data
    [Tags]          local
    [Arguments]     ${project_to_edit}  ${project_test_data}

    I'm at the Buy - Projects page
    # Find this RFQ in the table and click `view rfq`
    ${row}  ${col} =  Find string in table  ${project_to_edit}  Couldn't find ${project_to_edit} in table
    ${actions_xpath} =  Set variable  //tbody/tr[${row}]/td[${PROJ_ACTIONS_COL}]
    Set focus to element  xpath: ${actions_xpath}
    Click link  xpath:${actions_xpath}//a[contains(@class,'qa-proj-edit')]

    Wait until page contains  Edit Project

    Input text  name:project[name]         ${project_test_data.name}
    Input text  name:project[number]       ${project_test_data.number}
    Input text  name:project[jobsite]      ${project_test_data.jobsite}

    Click element  name:commit
    Wait until element is visible   class=alert-success
    Page should contain  Successfully updated project

    Wait until page contains  ${project_test_data.name}
    Page should contain       ${project_test_data.number}
    Page should contain       ${project_test_data.jobsite}


I can create and view a new RFQ project with this test data:
    [Documentation]  Create a new RFQ project with test data
    [Tags]          local
    [Arguments]     ${project_test_data}

    Click link  Create a New Project
    Wait until page contains  New Project

    Input text  name:project[name]         ${project_test_data.name}
    Input text  name:project[number]       ${project_test_data.number}
    Input text  name:project[jobsite]      ${project_test_data.jobsite}

    Click element  name:commit
    Wait until element is visible   class=alert-success
    Page should contain  Successfully created a new project

    Wait until page contains  ${project_test_data.name}
    Page should contain       ${project_test_data.number}
    Page should contain       ${project_test_data.jobsite}
