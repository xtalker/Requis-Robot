*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Common_Keywords.robot
Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Email_Keywords.robot

# Asset related test data
Variables       ${EXECDIR}/All_Supply_Chain_Tests/Project_Test_Data/unique_asset_test_data.yaml

Suite Setup     Open browser and start
Suite Teardown  Close All Browsers

Force Tags      critical  Priority-V1


*** Variables ***

# Contact list table column indexs
${company_name_col}     2
${company_status_col}   3
${manage_col}           3
${approve-reject_col}   3

# Approve/Reject indexs
${approve_index}        1
${reject_index}         2

# More contacts
${BUYER_USER3}           ${company_microsoft.user3_email}
${BUYER_USER3_PASSWORD}  ${company_microsoft.user3_password}
${BUYER_USER4}           ${company_microsoft.user4_email}
${BUYER_USER4_PASSWORD}  ${company_microsoft.user4_password}

*** Test Cases ***


Invite a registered company contact that is then removed
    [Setup]  Delete Emails

    Given I'm a company admin logged in as:  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Administration - Company Contacts page
    Then I can invite this registered company users to connect:  ${SELLER_COMPANY}  ${SELLER_USER_EMAIL}
    And this company shows in the contact list as:  ${SELLER_COMPANY}  Pending
    And this company is then removed from the list:  ${SELLER_COMPANY}  CLOSE_BROWSER

    Given I click on the emailed link in message with this subject:  ${SELLER_USER_EMAIL}
    ...  Requis platform user would like to connect
    And I'm logged in as this invited contact:  ${SELLER_USER_EMAIL}  ${SELLER_PASSWD}
    Then I should see this many invites of this type:  0  Pending


Invite a registered company contact that then accepts
    [Setup]  Delete Emails

    Given I'm a company admin logged in as:  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Administration - Company Contacts page
    Then I can invite this registered company users to connect:  ${SELLER_COMPANY}  ${SELLER_USER_EMAIL}
    And this company shows in the contact list as:  ${SELLER_COMPANY}  Pending

    Given I click on the emailed link in message with this subject:  ${SELLER_USER_EMAIL}
    ...  Requis platform user would like to connect
    And I'm logged in as this invited contact:  ${SELLER_USER_EMAIL}  ${SELLER_PASSWD}
    Then I should see this many invites of this type:  1  Pending
    And I can approve/reject the invitation from this company:  approve  ${UNIQUE_COMPANY}

    Given I'm a company admin logged in as:  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Administration - Company Contacts page
    And this company shows in the contact list as:  ${SELLER_COMPANY}  Approved


Invite a registered company contact that then rejects
    [Setup]  Delete Emails

    Given I'm a company admin logged in as:  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Administration - Company Contacts page
    Then I can invite this registered company users to connect:  ${BUYER_COMPANY}  ${BUYER_USER_EMAIL}
    And this company shows in the contact list as:  ${BUYER_COMPANY}  Pending

    Given I click on the emailed link in message with this subject:  ${BUYER_USER_EMAIL}
    ...  Requis platform user would like to connect
    And I'm logged in as this invited contact:  ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    # One invite is already pending due to seeded data
    Then I should see this many invites of this type:  2  Pending
    And I can approve/reject the invitation from this company:  reject  ${UNIQUE_COMPANY}

    Given I'm a company admin logged in as:  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Administration - Company Contacts page
    And this company shows in the contact list as:  ${BUYER_COMPANY}  Rejected
      and this company is then removed from the list:  ${BUYER_COMPANY}  none


Invite multiple registered company contacts
    [Setup]  Delete Emails

    Given I'm a company admin logged in as:  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Administration - Company Contacts page
    Then I can invite this registered company users to connect:  ${BUYER_COMPANY}
    ...   ${BUYER_USER3},${BUYER_USER4}
    And this company shows in the contact list as:  ${BUYER_COMPANY}  Pending

    Given I click on the emailed link in message with this subject:  ${BUYER_USER3}
    ...  Requis platform user would like to connect
    And I'm logged in as this invited contact:  ${BUYER_USER3}  ${BUYER_USER3_PASSWORD}
    Then I should see this many invites of this type:  2  Pending
    And I can approve/reject the invitation from this company:  approve  ${UNIQUE_COMPANY}


Attempt to invite a non-registered company contact

    Given I'm a company admin logged in as:  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Administration - Company Contacts page
    Then I can attempt to invite this unregistered company user to connect:  requistest@gmail.com
    And I get this error message:  Something went wrong. No contacts added


*** Keywords ***

I get this error message:
    [Documentation]  Verify that this error message is visible
    [Arguments]     ${error_message}
    [Tags]          local

    Page should contain element  class=alert-info  ${error_message}  timeout=30


I can attempt to invite this unregistered company user to connect:
    [Documentation]  Verify that unregistered users can't connect
    [Arguments]     ${user_email}
    [Tags]          local

    Click element   class:qa-add-contact-btn
    Wait until page contains   Enter email of company members to add as contacts
    Input text  id:company_contact_emails  ${user_email}
    Click element   class:qa-send-requests-btn


I can approve/reject the invitation from this company:
    [Documentation]  Approve or reject a contact invitation
    [Arguments]     ${type}  ${company_name}
    [Tags]          local

    ${row}  ${col} =  Find string in table  ${company_name}  Couldn't find ${company_name} in table

    ${tab}=  Set variable if  $type == 'approve'  Approved  Rejected

    Run keyword if  $type == 'approve'
    ...  Click link  xpath://table/tbody/tr[${row}]/td[${approve-reject_col}]/a[${approve_index}]

    Run keyword if  $type == 'reject'
    ...  Click link  xpath://table/tbody/tr[${row}]/td[${approve-reject_col}]/a[${reject_index}]

    Wait until page contains   ${tab} (1)

    Logout


I should see this many invites of this type:
    [Documentation]  Verify the number of invites in this tab type
    [Arguments]     ${count}  ${type}
    [Tags]          local

    Page should contain  ${type} (${count})


And I'm logged in as this invited contact:
    [Documentation]  Log in as an invited contact
    [Arguments]     ${user_email}  ${password}
    [Tags]          local

    Input Text      id=email        ${user_email}
    Input Text      id=password     ${password}
    Click Button    name=commit

    Wait until page contains  Company Contact Invites


I click on the emailed link in message with this subject:
    [Documentation]  Click the 'here' link in the email with this subject
    [Arguments]     ${user_email}  ${subject}
    [Tags]          local

    ${links}  Run keyword  Wait for latest email with this subject, to this user, get link:  ${subject}  ${user_email}

    ${contact_link}=  Get matches  ${links}  *company_contact_invites*

    Open browser  ${contact_link[0]}  ${THIS_BROWSER}
    Wait until page contains  Forgot password?


this company is then removed from the list:
    [Documentation]  Remove company contact invite
    [Arguments]     ${company_name}  ${browser}
    [Tags]          local

    ${row}  ${col} =  Find string in table  ${company_name}  Couldn't find ${company_name} in table

    # Click the remove link for this company
    Click link  xpath://table/tbody/tr[${row}]/td[${manage_col}]/a

    Alert should be present  text=Are you sure you want to remove ${company_name} as an contact?

    Wait until keyword succeeds  5 x  1 s  Wait until element is not visible  xpath://table/tbody/tr[${row}]/td[${manage_col}]/a

    Run keyword if  $browser == 'CLOSE_BROWSER'  Close browser  ELSE  Sleep  2


I can invite this registered company users to connect:
    [Documentation]  Invite a user as a company contact
    [Arguments]     ${company_name}  ${user_emails}
    [Tags]          local

    # Verify we're on the right page
    ${verify_url}  Get Location
    Should match  ${verify_url}  ${ROOT URL}/administration/company_contacts

    Click element   class:qa-add-contact-btn
    Wait until page contains   Enter email of company members to add as contacts
    Input text  id:company_contact_emails  ${user_emails}
    Click element   class:qa-send-requests-btn
    Wait until page contains  ${company_name}


this company shows in the contact list as:
    [Documentation]  Verify company status in contact list
    [Arguments]     ${company_name}  ${status}
    [Tags]          local

    Wait until page contains  ${company_name}
    ${row}  ${col} =  Find string in table  ${company_name}  Couldn't find ${company_name} in table
    ${cell_text}=  Get table cell  xpath://table  ${row+1}  ${company_status_col}
    Should contain  ${cell_text}  ${status}

