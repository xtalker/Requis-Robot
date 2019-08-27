*** Settings ***
# Resource file with IMAP (Gmail) email access related reusable stuff
#

Library         ImapLibrary

*** Variables ***

# Gmail account used for testing
# Requis SMTP setup for QA env is in: "requis-2.0/config/environments/qa.rb"
${Email_host}       imap.gmail.com
${Email_user}       requistest@gmail.com
${Email_passwd}     1q2w!Q@W

${Default_timeout}  60

*** Keywords ***

Delete Emails
    # Deletes all emails using the default email host & user
    [Tags]          email_access

    # Not working?  See: https://github.com/rickypc/robotframework-imaplibrary/pull/13
    #    I couldn't get this fix via pip and had to add it manually

    Open Mailbox  host=${Email_host}    user=${Email_user}    password=${Email_passwd}  folder=inbox
    Delete All Emails
    Close Mailbox


Wait for latest email with this subject, to this user, get link:
    # Returns the first link found in the last email received with a particular subject
    [Arguments]     ${subject}  ${recipient}
    [Tags]          email_access

    Open Mailbox  host=${Email_host}    user=${Email_user}    password=${Email_passwd}

    Console Log           Waiting for gmail message to: ${recipient} with subject: ${subject}
    ${latest_email} =     Wait For Email  subject=${subject}  recipient=${recipient}  timeout=${Default_timeout}
    ${links} =             Get Links From Email  ${latest_email}

    Close Mailbox

    [Return]    ${links}


Wait For Latest Email and Get Link
    # Returns the first link found in the last email received with a particular subject
    [Arguments]     ${host}  ${user}  ${passwd}  ${subject}
    [Tags]          email_access

    Open Mailbox  host=${host}    user=${user}    password=${passwd}

    Console Log           Waiting for gmail message with subject: ${subject}
    ${latest_email} =     Wait For Email  subject=${subject}  timeout=${Default_timeout}
    ${link} =             Get Links From Email  ${latest_email}
    #Log to console        Done!

    Close Mailbox

    [Return]    ${link}


Wait For Latest Email For A User, Get Link
    # Returns the first link found in the last email received for a particular user
    [Arguments]     ${host}  ${user}  ${passwd}
    [Tags]          email_access

    Open Mailbox  host=${host}    user=${user}    password=${passwd}

    Console Log           Waiting for gmail message with registration link and password...
    ${latest_email} =     Wait For Email    recipient=${user}  timeout=${Default_timeout}
    ${link} =             Get Links From Email  ${latest_email}
    #Console Log           Done!

    Close Mailbox

    [Return]    ${link[0]}


Get latest email details
    # Returns list with Subject:, To: and From: for the last email received
    [Tags]  email_access

    Open Mailbox  host=${Email_host}    user=${Email_user}    password=${Email_passwd}
    ${latest_email} =     Wait For Email    sender=${Email_user}  timeout=${Default_timeout}

    walk multipart email  ${latest_email}
    ${subject}=     get multipart field  Subject
    ${receiver}=    get multipart field  To
    ${sender}=      get multipart field  From
    @{details}=     Create List  ${subject}  ${receiver}  ${sender}

    #Console Log  Details: @{details}
    [Return]  @{details}


Get latest email details for this recipient:
    # Returns list with Subject:, From: and message Body for the last email received
    [Arguments]     ${recipient}
    [Tags]  email_access

    Open Mailbox  host=${Email_host}    user=${Email_user}    password=${Email_passwd}
    ${latest_email} =     Wait For Email    recipient=${recipient}  timeout=${Default_timeout}
    ${parts} =    Walk Multipart Email  ${latest_email}

    Console Log  Waiting for a gmail message to ${recipient} ...

    ${subject}=     get multipart field  Subject
    ${sender}=      get multipart field  From

    :FOR  ${part}  IN RANGE  ${parts}
    \     Walk Multipart Email    ${latest_email}
    \     ${content-type} =    Get Multipart Content Type
    \     Continue For Loop If    '${content-type}' != 'text/html'
    \     ${message_body}=    Get Multipart Payload    decode=True
    #\     Console Log     BODY: ${payload}
    Close Mailbox

    @{details}=     Create List  ${subject}  ${sender}  ${message_body}

    #Console Log  Details: @{details}
    [Return]  @{details}

Get multipart messages
    # This is an attempt to get "new admin has registered" message from a multipart bounced message
    # NOT WORKING!
    [Arguments]     ${host}  ${user}  ${passwd}
    Open Mailbox  host=${host}    user=${user}    password=${passwd}

    Console Log           Waiting for a multipart message...
    #Console Log           to: ${user}

    ${latest_email} =  Wait For Email    subject=Delivery Status Notification (Failure)  timeout=${Default_timeout}
    Console Log     LATEST: ${latest_email}
    ${links} =      Get Links From Email  ${latest_email}
    Console Log     LINKS: ${links}
    ${matches} =    Get Matches From Email  ${latest_email}  A new company admin has registered
    Console Log     MATCHES: ${matches}

#    ${parts} =    Walk Multipart Email  ${latest_email}
#    :FOR    ${i}    IN RANGE    ${parts}
#    \       Walk Multipart Email    ${latest_email}
#    \       ${fields} =     Get multipart field names
#    \       Console Log     FIELDS: ${fields}
#    \       ${type} =       Get Multipart Content Type
#    \       Console Log     i: ${i}, TYPE: ${type}
##exit for loop    \       Continue For Loop If    '${type}' != 'text/html'
#    \       ${payload} =    Get Multipart Payload   decode=true
#    \       Console Log     PAYLOAD: ${payload}


    Close Mailbox

