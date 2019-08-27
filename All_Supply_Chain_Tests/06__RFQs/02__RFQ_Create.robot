*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/RFQ_Support.robot

Suite Setup     Open browser and start
Suite Teardown  Close All Browsers

#Force Tags      skip

*** Variables ***


*** Test Cases ***

Create and view a new RFQ

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can create a new RFQ with this test data:  ${RFQ_1}
      and I can view and verify the data in this RFQ:  ${RFQ_1}
      and I can verify the progress timeline steps are all in this state:  undone


Create and view another new RFQ

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can create a new RFQ with this test data:  ${RFQ_2}
      and I can view and verify the data in this RFQ:  ${RFQ_2}


Edit and view an existing RFQ

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can edit this RFQ with this test data:  ${RFQ_2.rfq_name}  ${RFQ_3}
      and I can view and verify the data in this RFQ:  ${RFQ_3}


Delete an existing RFQ

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can delete this RFQ:  ${RFQ_3.rfq_name}


*** Keywords ***

I can delete this RFQ:
    [Documentation]  Delete this RFQ and verify it's gone
    [Tags]          local
    [Arguments]     ${rfq_name}

    # Find this RFQ in the table and click `delete rfq`
    ${row}  ${col} =  Find string in table  ${rfq_name}  Couldn't find ${rfq_name} in table
    ${rfq_actions_xpath} =  Set variable  //tbody/tr[${row}]/td[${RFQ_ACTIONS_COL}]
    Set focus to element  xpath: ${rfq_actions_xpath}
    Click link  xpath:${rfq_actions_xpath}//a[contains(@class,'qa-rfq-delete')]

    Wait until element is visible   class=alert-success
    Page should contain  Successfully deleted RFQ

    Page should not contain  ${rfq_name}


Get todays date with this offset:
    [Documentation]  Get todays date, add a +/- offset (ex: = 1 days), format and return
    #   Ex: input date format: 2018-02-01,  App date format: Feb. 02, 2018
    [Tags]          local
    [Arguments]     ${offset}

    ${date_now}=  Get current date  increment=${offset}

    ${new_format}=  Convert Date  ${date_now}  result_format=%b. %d, %Y

    [return]        ${new_format}

I can edit this RFQ with this test data:
    [Documentation]  Edit a RFQ with test data
    [Tags]          local
    [Arguments]     ${rfq_name}  ${rfq_test_data}

    # Find this RFQ in the table and click `edit rfq`
    ${row}  ${col} =  Find string in table  ${rfq_name}  Couldn't find ${rfq_name} in table
    ${rfq_actions_xpath} =  Set variable  //tbody/tr[${row}]/td[${RFQ_ACTIONS_COL}]
    Set focus to element  xpath: ${rfq_actions_xpath}
    Click link  xpath:${rfq_actions_xpath}//a[contains(@class,'qa-rfq-edit')]
    Wait until page contains  Edit RFQ

    # Get data from the assoc project in test data
    Set test variable  ${proj_name}  ${${rfq_test_data.project}\['name'\]}

    Select from list by value  name:rfq[status]      ${rfq_test_data.status}
    Select from list by label  name:rfq[project_id]  ${proj_name}

    Input text  name:rfq[name]             ${rfq_test_data.rfq_name}
    Input text  name:rfq[rfq_number]       ${rfq_test_data.number}
    Input text  name:rfq[description]      ${rfq_test_data.description}

    ${date}=  Get todays date with this offset:  ${rfq_test_data['issue_date']}
    Input text  name:rfq[issue_date]       ${date}
    ${date}=  Get todays date with this offset:  ${rfq_test_data['due_date']}
    Input text  name:rfq[due_date]         ${date}

    Input text  name:rfq[initiator]        ${rfq_test_data['initiator']}

    Click element  name:commit
    Wait until element is visible   class=alert-success
    Wait until page contains  Successfully updated RFQ


I can view and verify the data in this RFQ:
    [Documentation]  View and verify a RFQ with test data
    [Tags]          local
    [Arguments]     ${rfq_test_data}

    I'm at the Buy - RFQs page

    Run keyword  Find this RFQ in the table and select it:  ${rfq_test_data.rfq_name}

    # Get data from the assoc project in test data
    Set test variable  ${proj_name}  ${${rfq_test_data.project}\['name'\]}
    Set test variable  ${proj_number}  ${${rfq_test_data.project}\['number'\]}
    Set test variable  ${proj_jobsite}  ${${rfq_test_data.project}\['jobsite'\]}

    Page should contain    ${proj_name}
    Page should contain    ${rfq_test_data.rfq_name}
    Page should contain    Status: ${rfq_test_data.status}
    Page should contain    RFQ Created:

    ${date}=  Get todays date with this offset:  ${rfq_test_data.issue_date}
    Page should contain    RFQ Issue Date: ${date}
    ${date}=  Get todays date with this offset:  ${rfq_test_data.due_date}
    Page should contain    RFQ Due Date:  ${date} - 12:00 AM

    Page should contain    ${rfq_test_data.description}
    Page should contain    RFQ Number: ${rfq_test_data.number}
    Page should contain    ${rfq_test_data.rfq_name}
    Page should contain    Project Number: ${proj_number}
    Page should contain    Project Jobsite: ${proj_jobsite}
    Page should contain    Initiator: ${rfq_test_data.initiator}


I can create a new RFQ with this test data:
    [Documentation]  Create a new RFQ with test data
    [Tags]          local
    [Arguments]     ${rfq_test_data}

    Click link  Create a New RFQ
    Wait until page contains  New RFQ

    # Get data from the assoc project in test data
    Set test variable  ${proj_name}  ${${rfq_test_data.project}\['name'\]}

    Select from list by value  name:rfq[status]      ${rfq_test_data.status}
    #Select from list by label  id:rfq_project_id  ${rfq_test_data['project']}
    Select from list by label  name:rfq[project_id]  ${proj_name}

    Input text  name:rfq[name]             ${rfq_test_data.rfq_name}
    Input text  name:rfq[rfq_number]       ${rfq_test_data.number}
    Input text  name:rfq[description]      ${rfq_test_data.description}

    ${date}=  Get todays date with this offset:  ${rfq_test_data.issue_date}
    Input text  name:rfq[issue_date]       ${date}
    ${date}=  Get todays date with this offset:  ${rfq_test_data.due_date}
    Input text  name:rfq[due_date]         ${date}

    Input text  name:rfq[initiator]        ${rfq_test_data.initiator}

    Click element  name:commit
    Wait until element is visible   class=alert-success
    Page should contain  Successfully created New RFQ
    Wait until page contains  ${rfq_test_data.rfq_name}
