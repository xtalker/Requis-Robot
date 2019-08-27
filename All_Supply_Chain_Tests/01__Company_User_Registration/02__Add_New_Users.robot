*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Common_Keywords.robot
Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Email_Keywords.robot

Library         String

Suite Setup     If no previous failure, open the browser and start
Suite Teardown  Close All Browsers

Force Tags      critical  Priority-V1  upload

*** Variables ***


*** Test Cases ***

Invite new non-admin users

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the 'manage members' page and click 'Add New Member'
    Then I can invite new members to join
        #and I can invite new members via CSV upload


New users can log in with the link in emailed invitations

    Given I receive an emailed invitation with password
    Then I can setup a password for:   ${UNIQUE_USER1}  ${USER1_NAME}  ${USER1_PASSWD}  ${user1_link}
      and I can setup a password for:  ${UNIQUE_USER2}  ${USER2_NAME}  ${USER2_PASSWD}  ${user2_link}
      and I can setup a password for:  ${UNIQUE_USER3}  ${USER3_NAME}  ${USER3_PASSWD}  ${user3_link}
      and I can setup a password for:  ${UNIQUE_USER4}  ${USER4_NAME}  ${USER4_PASSWD}  ${user4_link}


# Note: Onboarding task list went away with the user dashboard (3/19) but could come back?
# New users can see the list of onboarding tasks on first login

#     Given I log in for the first time as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
#     Then I can see and verify the onboarding task list
#       and I don't see the onboarding task list when I login again:  ${UNIQUE_USER1}  ${USER1_PASSWD}


*** Keywords ***

I don't see the onboarding task list when I login again:
    [Arguments]      ${userid}  ${passwd}
    [Tags]           local
    [Documentation]  Logout, verify onboarding panel isn't present

    Logout

    Wait until page contains  WELCOME
    Input Text      id=email        ${userid}
    Input Text      id=password     ${passwd}
    Click Button    name=commit
    Wait until page contains  Dashboard

    Page should not contain  Welcome to Requis. Let's get you set up on the platform


I log in for the first time as:
    [Arguments]      ${userid}  ${passwd}
    [Tags]           local
    [Documentation]  Logout if already logged in then log back in as specific user

    # Determine if a user is already logged in, if so, logout
    ${status}=  Get element count  class:qa-current-user
    Run Keyword If  ${status} > 0  Logout

    Input Text      id=email        ${userid}
    Input Text      id=password     ${passwd}
    Click Button    name=commit

    Wait until page contains  Dashboard


I can see and verify the onboarding task list
    [Tags]           local
    [Documentation]  Verify the onboarding task list is presented and all links work

    Page should contain  Welcome to Requis. Let's get you set up on the platform

    Verify a link:  Finish setting up company profile         /company/edit
    Verify a link:  Add company employees                     /company/members
    Verify a link:  Create company teams                      /teams
    Verify a link:  Upload company assets                     /sell/menu
    Verify a link:  List assets on your marketplace           /sell/asset_records
    Verify a link:  Explore other marketplaces to buy assets  /procure/private_marketplaces
    Verify a link:  Make an offer on interested assets        /offers

    Click element  class:qa-onboard-done-btn


I'm at the Manage API keys page
    [Tags]           local

    Go To                ${ROOT URL}/company/api_keys
    Page should contain  Manage API Keys


I'm at the 'manage members' page and click 'Add New Member'
    [Documentation]  Click this button on the company/members page
    [Tags]           local

    Go To                ${ROOT URL}/company/members
    Wait until page contains  ${UNIQUE_ADMIN}
    Click link           Add New Member


I can invite new members to join
    [Documentation]  Enter new member emails list and click "Add"
    [Tags]           local

    Delete Emails

    Input text      id:members_emails  ${UNIQUE_USER1},${UNIQUE_USER2},${UNIQUE_USER3},${UNIQUE_USER4}
    Click element   name:commit   # 'Add' button

    # Verify that all users are now in the list with the correct icon and add/remove links
    Wait until page contains   Add New Member  timeout=60

    Page should contain link   ${UNIQUE_USER1}
    Page should contain class  'qa-${UNIQUE_USER1}-not-admin-flag'

    Page should contain link   ${UNIQUE_USER2}
    Page should contain class  'qa-${UNIQUE_USER2}-not-admin-flag'

    Page should contain link   ${UNIQUE_USER3}
    Page should contain class  'qa-${UNIQUE_USER3}-not-admin-flag'

    Page should contain link   ${UNIQUE_USER4}
    Page should contain class  'qa-${UNIQUE_USER4}-not-admin-flag'

    Page should contain link   ${UNIQUE_ADMIN}
    Page should contain class  'qa-${UNIQUE_ADMIN}-admin-flag'
    #Page should contain class  'qa-${UNIQUE_ADMIN}-remove-admin'


I receive an emailed invitation with password
    [Documentation]  Wait for email and save the link and password
    [Tags]           local

   ${user1_link}  Run keyword  Wait For Latest Email For A User, Get Link  ${Email_host}  ${UNIQUE_USER1}
   ...      ${Email_passwd}

   ${user2_link}  Run keyword  Wait For Latest Email For A User, Get Link  ${Email_host}  ${UNIQUE_USER2}
   ...      ${Email_passwd}

   ${user3_link}  Run keyword  Wait For Latest Email For A User, Get Link  ${Email_host}  ${UNIQUE_USER3}
   ...      ${Email_passwd}

   ${user4_link}  Run keyword  Wait For Latest Email For A User, Get Link  ${Email_host}  ${UNIQUE_USER4}
   ...      ${Email_passwd}

   # Make these test level variables so they are visible throughout the test case
   ${user1_link}     Set test variable  ${user1_link}
   ${user2_link}     Set test variable  ${user2_link}
   ${user3_link}     Set test variable  ${user3_link}
   ${user4_link}     Set test variable  ${user4_link}


I can setup a password for:
    [Documentation]  Verify user can log in with emailed link and password
    [Tags]           local
    [Arguments]      ${userid}  ${name}  ${passwd}  ${link}

    Logout
    Go to                         ${link}
    Wait Until Page Contains Element  class:alert-success
    Page should contain  Successfully confirmed your email.
    Page should contain  Setup Your Account

    # Parse out the users first/last name
    ${split_str}        split string  ${name}
    ${first_name} =     Set variable  ${split_str[0]}
    ${last_name} =      Set variable  ${split_str[1]}


    Input text     name:user[first_name]             ${first_name}
    Input text     name:user[last_name]              ${last_name}
    Input text     name:user[new_password]           ${passwd}
    Input text     name:user[password_confirmation]  ${passwd}
    Click element  name:commit

    Wait Until Page Contains Element  class:alert-success
    Page should contain  Your account has successfully been setup!

    # Make sure userid shows up
    Set focus to element  class:qa-current-user
    # No idea why "mouse over" stopped working here!
    Mouse down  class:qa-current-user
    Mouse up    class:qa-current-user
    Wait until page contains       ${userid}

    # Set the user auto signout time
    Go to  ${ROOT_URL}/profile/settings
    Wait until page contains  Profile Settings
    Input text      id:user_setting_auto_sign_out_limit  ${USER_SIGNOUT_TIME}
    Click element   name:commit
    Wait until page contains  Successfully updated settings


