*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/RFQ_Support.robot

Suite Setup     If no previous failure, open the browser and start
Suite Teardown  Close All Browsers

#Force Tags      skip


*** Variables ***

# File names
${RFQ_EMAIL_CSV_LIST}   ${company_1["company_contacts"]["group_3"]}
#@{RFQ_CONTACTS_LIST}    ${company_apple["admin_user"]}  ${company_microsoft["admin_user"]}
${RFQ_ADDRESS_LIST}     ${company_1["company_contacts"]["group_2"]}
${RFQ_EMAIL_CSV_FILE}   ${RFQ_DATA_DIR}/RFQ_email_addresses.csv

# CSV Headers
${EMAIL_HEADER}=    Contact Name,Email

# RFQ vendors table column indexes
${EMAIL_ADDRESS_COL}    2
${EMAIL_NAME_COL}       3
${EMAIL_ACTIONS_COL}    4


*** Test Cases ***

Invite vendors from an uploaded CSV list for an RFQ
    [Setup]     Create a temporary CSV file from test data and delete emails
    ...  ${RFQ_EMAIL_CSV_FILE}  ${EMAIL_HEADER}  ${RFQ_EMAIL_CSV_LIST}
    [Teardown]  Remove file   ${RFQ_EMAIL_CSV_FILE}

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can add vendors from an uploaded CSV list for this RFQ:  ${RFQ_1.rfq_name}
    ...  ${RFQ_EMAIL_CSV_FILE}  ${RFQ_EMAIL_CSV_LIST}
    And I can verify that the timeline shows only these steps as completed:  team  docs  vendors


Invite vendors from company contacts
    [Setup]  Delete all bidder notifications

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can add vendors from company contacts for this RFQ:  ${RFQ_1.rfq_name}  Apple  Microsoft


Invite vendors from a list of email addresses

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can add vendors from a list of addresses for this RFQ:  ${RFQ_1.rfq_name}  @{RFQ_ADDRESS_LIST}


Verify the list of invited vendors

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can verify the bidders list for this RFQ:  ${RFQ_1.rfq_name}


Approve and send the RFQ to vendors
    [Setup]     Delete emails

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can approve and send this RFQ to vendors:  ${RFQ_1.rfq_name}
    And I can verify that the timeline shows only these steps as completed:
    ...  team  docs  vendors  approve  send

    Given I'm logged in as  ${company_apple.admin_user}  ${company_apple.admin_password}
    Then Verify that this notification exists:  Someone requested your participation on RFQ: ${RFQ_1.rfq_name}

    Given I'm logged in as  ${company_microsoft["admin_user"]}  ${company_microsoft["admin_password"]}
    Then Verify that this notification exists:  Someone requested your participation on RFQ: ${RFQ_1.rfq_name}


*** Keywords ***

Delete all bidder notifications
    [Tags]          local

    Run keyword  I'm logged in as  ${company_apple["admin_user"]}  ${company_apple["admin_password"]}
    Run keyword  Delete all notifications

    Run keyword  I'm logged in as  ${company_microsoft["admin_user"]}  ${company_microsoft["admin_password"]}
    Run keyword  Delete all notifications


I can approve and send this RFQ to vendors:
    [Documentation]  Approve the rfq, send to vendors and verify emails
    [Tags]          local
    [Arguments]     ${rfq_name}

    Run Keyword  Find this RFQ in the table and select it:  ${rfq_name}

    # Approve the RFQ and send to all vendors in the list
    # Click the "approve/send" (thunbs-up) button and wait for it to disappear
    Click element  class:qa-approve-send-btn
    Wait until element is visible   class:alert-success  timeout=120
    Page should contain  Successfully sent RFQ to Vendors  timeout=120
    Wait until page does not contain element  class:qa-approve-send-btn  timeout=120

    # For each email address in the vendor list, check for an email message
    : FOR  ${email}  IN  @{ALL_VENDORS}
    \  ${details}=  Get latest email details for this recipient:  ${email}
    \
    \  # Subject should be:
    \  Should match    ${details[0]}  RFQ Bid Participation Requested
    \
    \  # Message body should contain:
    \  #Should contain  ${details[2]}  ${ROOT_URL}/signup
    \  Should contain  ${details[2]}  ${UNIQUE_COMPANY}


I can verify the bidders list for this RFQ:
    [Documentation]  Verify upload CSV email addresses
    [Tags]          local
    [Arguments]     ${rfq_name}

    ${ALL_VENDORS}=  Create list
    Set suite variable  ${ALL_VENDORS}

    # Gather all vendor emails into one list
    : FOR  ${contact}  IN  @{RFQ_EMAIL_CSV_LIST}
    \  Append to list  ${all_vendors}  ${contact["email"]}

    : FOR  ${contact}  IN  @{RFQ_ADDRESS_LIST}
    \  Append to list  ${all_vendors}  ${contact["email"]}

    #: FOR  ${contact}  IN  @{RFQ_CONTACTS_LIST}
    #\  Append to list  ${all_vendors}  ${contact}

    Run Keyword  Find this RFQ in the table and select it:  ${rfq_name}

    # Click the vendors tab
    Click link  Vendors
    Wait until page contains  RFQ Vendors

    ${table_anchor}=  Set Variable  //table[contains(@class,'qa-email-table')]

    # For each vendor email in the test data, compare with the vendor list
    : FOR  ${email}  IN  @{ALL_VENDORS}
    \  # Find the row in the table with this doc
    \  ${row}  ${col} =  Find string in table  ${email}  anchor=${table_anchor}  error_msg=Couldn't find ${email} in table
    \  # Verify each column in this row
    \  ${row_anchor}=  Set variable  ${table_anchor}//tbody/tr[${row}]
    \  ${txt}=  Get text  ${row_anchor}/td[${EMAIL_ADDRESS_COL}]
    \  Should be equal as strings  ${txt}  ${email}
    \  ${txt}=  Get text  ${row_anchor}/td[${EMAIL_ADDRESS_COL}]
    \  Should be equal as strings  ${txt}  ${email}


I can add vendors from a list of addresses for this RFQ:
    [Documentation]  Send bid invitations to list of email addresses
    [Tags]          local
    [Arguments]     ${rfq_name}  @{addresses}

    # Go back to RFQs list
    I'm at the Buy - RFQs page

    Run Keyword  Find this RFQ in the table and select it:  ${rfq_name}

    # Click the vendors tab
    Click link  Vendors
    Wait until page contains  RFQ Vendors
    Click link  Add More Vendors
    Wait until page contains  Select RFQ Vendors

    ${address_list}=  Set variable  ${EMPTY}

    :FOR  ${address}  IN  @{addresses}
    \  ${address_list}=  Catenate  ${address_list}  ${address['email']},

    Input text  id:rfq_contacts  ${address_list}
    Click button  name:commit
    ${count}=  Get length  ${addresses}
    Wait until element is visible   class=alert-success  timeout=60
    Wait until page contains  Successfully added ${count} Vendors  timeout=60


I can add vendors from company contacts for this RFQ:
    [Documentation]  Send bid invitations to the company contacts
    [Tags]          local
    [Arguments]     ${rfq_name}  @{companies}

    # Go back to RFQs list
    I'm at the Buy - RFQs page

    Run Keyword  Find this RFQ in the table and select it:  ${rfq_name}

    # Click the vendors tab
    Click link  Vendors
    Wait until page contains  RFQ Vendors
    Click link  Add More Vendors
    Wait until page contains  Select RFQ Vendors

    #  Select companies in the contacts list
    :FOR  ${company}  IN  @{companies}
    # The label element follows the checkbox element on the same level
    \  select checkbox  xpath://*[@id="company_contact_"][following-sibling::label[text()='${company}']]

    Click button  name:commit
    ${count}=  Get length  ${companies}
    Wait until element is visible   class=alert-success  timeout=60
    Wait until page contains  Successfully added ${count} Vendors  timeout=60


# I can verify that all the emails for this RFQ were sent:
#     [Documentation]  Verify mail sent to CSV email addresses
#     [Tags]          local
#     [Arguments]     @{test_data}

#     # For each email address in the test data, check for an email message
#     : FOR  ${email}  IN  @{test_data}
#     \
#     \  ${details}=  Get latest email details for this recipient:  ${email}
#     \
#     \  # Subject should be:
#     \  Should match    ${details[0]}  RFQ Bid Participation Requested
#     \  # Message body should contain:
#     \  #Should contain  ${details[2]}  ${ROOT_URL}/signup
#     \  Should contain  ${details[2]}  ${UNIQUE_COMPANY}


I can add vendors from an uploaded CSV list for this RFQ:
    [Documentation]  Upload email address CSV file
    [Tags]          local
    [Arguments]     ${rfq_name}  ${csv_file}  ${test_data}

    # Go back to RFQs list
    I'm at the Buy - RFQs page

    Run Keyword  Find this RFQ in the table and select it:  ${rfq_name}

    # Click the vendors tab
    Click link  Vendors
    Wait until page contains  You haven't selected any vendors yet!
    Click link  Select Vendors for RFQ
    Wait until page contains  Select RFQ Vendors

    Choose file   id:rfq_contact_attachment   ${RFQ_EMAIL_CSV_FILE}
    Click button  name:commit

    ${count}=  Get length  ${test_data}
    Wait until element is visible   class=alert-success  timeout=60
    Wait until page contains  Successfully added ${count} RFQ Vendors  timeout=60


Create a temporary CSV file from test data and delete emails
    [Tags]          local
    [Arguments]     ${csv_file}  ${header}  @{test_data_group}

    # 'Create CSV' is a python script in "Python_methods.py"
    ${result} =     run keyword   Create CSV  ${csv_file}  @{test_data_group}  ${header}
    Should contain  ${result}  DONE

    Delete Emails

