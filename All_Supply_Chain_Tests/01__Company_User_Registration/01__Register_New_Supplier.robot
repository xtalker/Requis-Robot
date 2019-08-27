*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Common_Keywords.robot
Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Email_Keywords.robot

Suite Setup     Open browser and start
Suite Teardown  Close All Browsers

Force Tags      critical  Priority-V1  upload


*** Variables ***


*** Test Cases ***

Register a new company and admin user
    [Setup]     Run keywords
    ...    Create and save unique data  ${company_1.admin.email}
    ...      ${company_1.user1.email}    ${company_1.user2.email}
    ...      ${company_1.user3.email}    ${company_1.user4.email}
    ...  AND
    ...    Delete Emails

    Given I see the home page
    Then I can register a new admin user and company  ${company_1}  ${UNIQUE_COMPANY}  ${UNIQUE_ADMIN}
    #and The global admin receives an email notification of the new company and user  ${UNIQUE_ADMIN}


Review and approve a new company
    [Setup]  Delete Emails
    [Teardown]  Logout

    Given I'm logged in as  ${GLOBAL_ADMIN_USER}  ${GLOBAL_ADMIN_PASSWORD}
    When I'm at the global admin dashboard, review company registrations page
    Then I can reject a new company
      and The user gets an email notification:  Registration Rejected  ${UNIQUE_ADMIN}  none
    Then I can require more info from a new company
      and The user gets an email notification:  Registration needs more info  ${UNIQUE_ADMIN}  login
    Then I can approve a new company and set the transaction fee
      and The user gets an email notification:  Registration Accepted  ${UNIQUE_ADMIN}  login


Register another company for the vendor look-up test
    [Setup]  Delete Emails

    Given I see the home page
    Then I can register a new admin user and company  ${company_2}
    ...  ${company_2.base_company_name}-${UNIQUE_ID}
    ...  requistest+${company_2.base_company_name}-${UNIQUE_ID}@gmail.com


*** Keywords ***


The user gets an email notification:
    [Documentation]  Added for verbal test case clarity
    [Arguments]      ${subject}  ${receiver}  ${link}
    [Tags]           local

    Run keyword  Verify an email notification:  ${subject}  ${receiver}  ${Email_user}


I can register a new admin user and company
    [Documentation]  Setup a new admin user and register a new company
    [Tags]           local
    [Arguments]  ${company_data}  ${company_name}  ${company_admin_email}

    Click Link     link:New Company Registration
    Wait until page contains  We require all companies to register with some basic information

    # Register new company admin user
    Input text  name:user[company_name]            ${company_name}
    Input text  name:user[contact_name]            ${company_data.contact_name_1}
    Input text  name:user[contact_email]           ${company_admin_email}
    Input text  name:user[telephone]               ${company_data.phone}
    Select from list by value  name:user[country]  ${company_data.country}
    Input text  name:user[state]                   ${company_data.state}
    Input text  name:user[password]                ${company_data.admin.password}
    Input text  name:user[password_confirmation]   ${company_data.admin.password}
    Click element  name:user[accepted_tos]

    Click element   name:commit
    Wait until page contains element  class:alert-success  timeout=30
    Page should contain  Thanks for registering to use Requis. You should receive a confirmation email in the next 5 minutes from noreply@requis.com.

    # Wait for email with registration link, then go to it
    ${links}  Run keyword  Wait For Latest Email and Get Link  ${Email_host}  ${Email_user}
    ...  ${Email_passwd}  Email Confirmation
    ${confirm_link}=  Get matches  ${links}  *confirm_email
    Go to  ${confirm_link[0]}

    Wait until page contains element   class=alert-success  timeout=30
    Page should contain  Successfully confirmed your email.

    Wait until page contains  Welcome, ${company_admin_email}!  timeout=30

    Page should contain  Thank you for submitting to register to Requis.  timeout=30
    Page should contain  This will take 48 hours for us to process.


I can reject a new company
    [Tags]          local

    Click the review link   ${UNIQUE_COMPANY}  review
    Wait until page contains  Admin Review: "${UNIQUE_COMPANY}"

    Click element  id:approve-reject-tab
    Page should contain  Use the radio buttons to approve, require more information, or reject

    Click element  class:qa-review-reject-radio   # Reject radio button
    Click element  class:qa-review-submit-btn     # Submit

    Wait Until Page Contains Element  class:alert-success
    Page should contain  All set, thanks for updating company registration

    # Go to the "Rejected" list
    Wait until page contains    Review - Company Registration Forms
    Click element  id:rejected-tab
    Page should contain element  tag:h3  Rejected
    Page should contain   Company: ${UNIQUE_COMPANY}


I can require more info from a new company
    [Tags]          local

    # Find the company in the 'rejected' table and click the review link
    Click the review link   ${UNIQUE_COMPANY}  rejected
    Wait until page contains  Admin Review: "${UNIQUE_COMPANY}"

    Click element  id:approve-reject-tab
    Page should contain  Use the radio buttons to approve, require more information, or reject

    # Hit the "requires more info" button
    Click element  class:qa-review-moreinfo-radio   # 'Requires more info' radio button
    Click element  class:qa-review-submit-btn       # Submit

    Wait Until Page Contains Element  class:alert-success
    Page should contain  All set, thanks for updating company registration
    Wait until page contains    Review - Company Registration Forms


I can approve a new company and set the transaction fee
    [Tags]          local

    # Find the company in the 'requires more info' table and click the review link
    Click element  id:requires-more-info-tab
    Wait until page contains  Review - Company Registration Forms
    Click the review link   ${UNIQUE_COMPANY}  more-info
    Wait until page contains  Admin Review: "${UNIQUE_COMPANY}"

    Click element  id:approve-reject-tab
    Page should contain  Use the radio buttons to approve, require more information, or reject

    # Hit the "Approve" button
    Click element  class:qa-review-approve-radio   # 'Requires more info' radio button
    Click element  class:qa-review-submit-btn       # Submit

    Wait Until Page Contains Element  class:alert-success
    Page should contain  All set, thanks for updating company registration
    Wait until page contains    Review - Company Registration Forms

    # Set the transaction fee
    Click element  id:approved-tab
    Wait until page contains  Review - Company Registration Forms
    Click the review link   ${UNIQUE_COMPANY}  approved
    Wait until page contains  Admin Review: "${UNIQUE_COMPANY}"

    Click element  id:edit-tab
    Wait until page contains  Edit Registration Information for:

    # Set the transaction fee
    ${fee_string}=  Convert to string  ${company_1.sale_fee}
    Input text  name:company_registration_form[sale_transaction_fee]  ${fee_string}
    Click element   class:qa-update-transaction-fee
    Wait Until Page Contains Element  class:alert-success
    Page should contain  All set, thanks for updating company registration
    Wait until page contains    Review - Company Registration Forms


Click the review link
    [Documentation]  Click the 'review' link associated with a company name on the 'Review - Company Registration Forms' page
    [Arguments]      ${company}  ${type}
    [Tags]          local

    ${review_class}  Set variable  qa-${type}-${company}

    Sleep  1
    Click link  class:${review_class}
    Page should contain  Admin Review: "${company}"


The global admin receives an email notification of the new company and user
   [Documentation]  Verify that the global admin gets email notificaion of new company/admin user
   [Tags]          local
   [Arguments]     ${user_email}

   ${admin_links}  Run keyword  Wait For Latest Email and Get Link  ${Email_host}  ${Email_user}
   ...     ${Email_passwd}  New User and Company Registration Form Pending

   Should Contain    ${admin_links[0]}  ${ROOT_URL}/global_admins/company_registration_forms
   Should Contain    ${admin_links[1]}  https://supplychain.requis.com/login


Create and save unique data
    [Documentation]  Increment the index and use it to create unique user names (this is stored in a file bewtween runs)
    [Arguments]     ${admin}  ${user1}  ${user2}  ${user3}  ${user4}
    [Tags]          local

    # Increment the unique id index to make the user email addresses unique, make these global for use throughout
    Set Global Variable  ${UNIQUE_ID}        ${UNIQUE_ID+1}
    Console log  Current unique user index: ${UNIQUE_ID}

    ${split_str}        split string  ${admin}  @
    Set Global Variable  ${UNIQUE_ADMIN}     @{split_str}[0]+${UNIQUE_ID}@@{split_str}[1]

    ${split_str}        split string  ${user1}  @
    Set Global Variable  ${UNIQUE_USER1}     @{split_str}[0]-${UNIQUE_ID}@@{split_str}[1]

    ${split_str}        split string  ${user2}  @
    Set Global Variable  ${UNIQUE_USER2}     @{split_str}[0]-${UNIQUE_ID}@@{split_str}[1]

    ${split_str}        split string  ${user3}  @
    Set Global Variable  ${UNIQUE_USER3}     @{split_str}[0]-${UNIQUE_ID}@@{split_str}[1]

    ${split_str}        split string  ${user4}  @
    Set Global Variable  ${UNIQUE_USER4}     @{split_str}[0]-${UNIQUE_ID}@@{split_str}[1]

    Set Global Variable  ${UNIQUE_COMPANY}   ${company_1.base_company_name}-${UNIQUE_ID}

    Set Global Variable  ${UNIQUE_KEY}  none

    Save dynamic test data to file:   ${DYN_TEST_DATA_FILE}

    ${result}  Run keyword  Make test data unique
    ...  ${ASSET_TEMPLATE_FILE}  ${ASSET_DATA_FILE}  ${UNIQUE_ID}
    Should be equal  ${result}  DONE
