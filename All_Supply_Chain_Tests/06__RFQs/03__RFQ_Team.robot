*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/RFQ_Support.robot

Suite Setup     If no previous failure, open the browser and start
Suite Teardown  Close All Browsers

#Force Tags      skip

*** Variables ***

# RFQ name to test
${RFQ_NAME}             ${RFQ_1["rfq_name"]}

# RFQ team member alias' to registered users
${MANAGER}              ${company_1.user1}    # UNIQUE_USER1, Bert
${MANAGER_EMAIL}        ${UNIQUE_USER1}
${BUYER}                ${company_1.user2}    # UNIQUE_USER2, Mary
${BUYER_EMAIL}          ${UNIQUE_USER2}
${COMM_REVIEWER}        ${company_1.user3}    # UNIQUE_USER3, Sammy
${COMM_REVIEWER_EMAIL}  ${UNIQUE_USER3}
${TECH_REVIEWER}        ${company_1.user4}    # UNIQUE_USER4, Herb
${TECH_REVIEWER_EMAIL}  ${UNIQUE_USER4}

# Tab names
@{ALL_TABS}  agenda  materials  comm-docs  tech-docs  vendors


*** Test Cases ***

Set RFQ team members

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can set the team members for this RFQ:  ${RFQ_1.rfq_name}  ${MANAGER.name}
    ...  ${BUYER.name}  ${COMM_REVIEWER.name}  ${TECH_REVIEWER.name}
    And I can verify that the timeline shows only these steps as completed:  team


Buyer and Manager team members can see all documents

    Given I'm logged in as  ${MANAGER_EMAIL}  ${MANAGER.password}
    When I'm at the Buy - RFQs page
    Then Find this RFQ in the table and select it:  ${RFQ_NAME}
    And I can verify that this user has access to only these tabs:
    ...  agenda  materials  comm-docs  tech-docs  vendors

    Given I'm logged in as  ${BUYER_EMAIL}  ${BUYER.password}
    When I'm at the Buy - RFQs page
    Then Find this RFQ in the table and select it:  ${RFQ_NAME}
    And I can verify that this user has access to only these tabs:
    ...  agenda  materials  comm-docs  tech-docs  vendors


Reviewer team members can only see documents related to their role

    Given I'm logged in as  ${COMM_REVIEWER_EMAIL}  ${COMM_REVIEWER.password}
    When I'm at the Buy - RFQs page
    Then Find this RFQ in the table and select it:  ${RFQ_NAME}
    And I can verify that this user has access to only these tabs:  agenda  comm-docs

    Given I'm logged in as  ${TECH_REVIEWER_EMAIL}  ${TECH_REVIEWER.password}
    When I'm at the Buy - RFQs page
    Then Find this RFQ in the table and select it:  ${RFQ_NAME}
    And I can verify that this user has access to only these tabs:  agenda  tech-docs


*** Keywords ***

I can verify that this user has access to only these tabs:
    [Tags]          local
    [Arguments]     @{tabs}

    : FOR  ${tab}  IN  @{ALL_TABS}
    \  # Determine the tab class
    \  ${tab_class}=  Set variable  no-class-name
    \  ${tab_class}=  Set variable if
    \  ...  $tab == 'agenda'     qa-rfq-agenda-tab
    \  ...  $tab == 'materials'  qa-deliv-items-tab
    \  ...  $tab == 'comm-docs'  qa-comm-docs-tab
    \  ...  $tab == 'tech-docs'  qa-tech-docs-tab
    \  ...  $tab == 'vendors'    qa-vendors-tab
    \
    \  # Test if tab exists on page
    \  Run keyword if  $tab in $tabs
    \  ...    Page should contain element  class:${tab_class}  message=Expected tab: ${tab} not found!
    \  ...  ELSE
    \  ...    Page should not contain element  class:${tab_class}  message=Tab: ${tab} NOT expected!


Find team member and select it
    [Documentation]  Find a name in the team list and select it (since list contains name and email)
    [Tags]          local
    [Arguments]     ${list_class}  ${find_name}

    ${index} =    Set Variable    ${0}

    # Get an array of all selectable names
    ${name_list}=  Get list items  class:${list_class}
    ${len}=  Get length  ${name_list}

    # Find the index of the desired name
    :FOR  ${name}  IN  @{name_list}
    \  ${match}=  Evaluate  $find_name in $name
    \  Exit for loop if  $match == True
    \  ${index} =  Set variable  ${index + 1}

    Should be true  $index < $len  msg=${find_name} not found in select list

    # Select that name by index
    ${index}=  Convert to string  ${index}
    Select from list by index  class:${list_class}  ${index}


I can set the team members for this RFQ:
    [Documentation]  Set all the team members for this rfq
    [Tags]          local
    [Arguments]     ${rfq_name}  ${manager}  ${buyer}  ${comm_reviewer}  ${tech_reviewer}

    Run Keyword  Find this RFQ in the table and select it:  ${rfq_name}

    Run keyword  Find team member and select it  qa-buyer-role-selector                ${buyer}
    Run keyword  Find team member and select it  qa-procurement-manager-role-selector  ${manager}
    Run keyword  Find team member and select it  qa-commercial-reviewer-role-selector  ${comm_reviewer}
    Run keyword  Find team member and select it  qa-technical-reviewer-role-selector   ${tech_reviewer}

    Click element  class:qa-save-team-btn
    Wait until page contains  Add RFQ User Role

