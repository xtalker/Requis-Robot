*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Common_Keywords.robot
Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Email_Keywords.robot

Suite Setup     Open browser and start
Suite Teardown  Close All Browsers

Force Tags      Priority-V1


*** Variables ***


*** Test Cases ***

Reset the admin users password
    [Setup]  Delete Emails

    Given I'm not logged in and can see the forgot password link
    Then I can reset my password for this user to:         ${GLOBAL_ADMIN_USER}  newpassword
    and I can now log in as this user with this password:  ${GLOBAL_ADMIN_USER}  newpassword


Reset the admin users password back to match the test data
    [Setup]  Delete Emails

    Given I'm not logged in and can see the forgot password link
    Then I can reset my password for this user to:         ${GLOBAL_ADMIN_USER}  ${GLOBAL_ADMIN_PASSWORD}
    and I can now log in as this user with this password:  ${GLOBAL_ADMIN_USER}  ${GLOBAL_ADMIN_PASSWORD}


Reset a regular users password
    [Setup]  Delete Emails

    Given I'm not logged in and can see the forgot password link
    Then I can reset my password for this user to:         ${BUYER_USER_EMAIL}  newpassword
    and I can now log in as this user with this password:  ${BUYER_USER_EMAIL}  newpassword


Reset a regular users password back to match the test data
    [Setup]  Delete Emails

    Given I'm not logged in and can see the forgot password link
    Then I can reset my password for this user to:         ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    and I can now log in as this user with this password:  ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}


*** Keywords ***

I can now log in as this user with this password:
    [Documentation]  Log in with the newly reset password
    [Tags]        local
    [Arguments]   ${user_email}  ${password}

    I'm logged in as  ${user_email}  ${password}


I can reset my password for this user to:
    [Documentation]  Reset the password for this user
    [Tags]        local
    [Arguments]   ${user_email}  ${password}

    Click link  link:Forgot password?
    Wait until page contains  Forgot password
    Input text  id:password_reset_email  ${user_email}
    Click element  name:commit
    Wait until page contains element  class=alert-success
    Page should contain               Email sent with password reset instructions

    # Wait for email with password reset link, then go to it
    ${links}  Run keyword  Wait For Latest Email and Get Link  ${Email_host}  ${Email_user}
    ...  ${Email_passwd}  Password Reset
    ${passwd_reset_link}=  Get matches  ${links}  *password_resets*

    Go to    ${passwd_reset_link[0]}
    Page should contain  Reset password
    Input text  name:user[password]  ${password}
    Input text  name:user[password_confirmation]  ${password}
    Click element  name:commit
    Wait until page contains element  class=alert-success
    Page should contain               Password has been reset


I'm not logged in and can see the forgot password link
    [Documentation]  Log out if logged in and verify the "Forgot password?" link
    [Tags]          local

    Go to  ${ROOT URL}

    ${status}=  Get element count  class:qa-current-user
    # Determine if a user is already logged in, if so, logout
    Run Keyword If  ${status} > 0  Logout

    Page should contain link  link:Forgot password?
