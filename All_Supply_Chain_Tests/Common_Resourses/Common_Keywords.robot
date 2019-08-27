*** Settings ***
# Resource file with global common settings and reusable project-wide stuff

Library    ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Python_methods.py
Resource   ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Navigational_Keywords.robot
Resource   ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Global_Variables.robot

Library    OperatingSystem
Library    String
Library    Collections
Library    Process
Library    DateTime

           # run_on_failure: Debug, Nothing or Capture Page Screenshot (default)
Library    SeleniumLibrary   run_on_failure=Capture Page Screenshot  timeout=10.0

Library    ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Selenium_Extensions.py
Library    DebugLibrary
Library    String

# Test data
Variables  ${DYN_TEST_DATA_FILE}        #  Changes on each new test run
Variables  ${EXECDIR}/All_Supply_Chain_Tests/Project_Test_Data/admin_test_data.yaml


*** Variables ***

# Changeable from command line (--variable NAME:value)
${BROWSER}   ${THIS_BROWSER}
${ROOT_URL}  ${THIS_URL}

*** Keywords ***
#(See also Navigational_Keywords.robot)

Verify that this notification exists:
    [Tags]       common
    [Arguments]  ${expected_notif}

    ${retries}=      Set variable  3
    ${retry_sleep}=  Set variable  3

    ${notif_button_xpath}=  Set variable  //div[contains(@id,'mainNav')]/ul/div[contains(@id,'Notifications-react-component')]
    ${notif_items_xpath}=   Set variable  //li[contains(text(),'Notifications')]//parent::ul/li

    ${notif_item_count}=  Get element count  xpath:${notif_items_xpath}

    # Wait for a while for the notification if none are avail, reloading page each time
    : FOR  ${loop}  IN RANGE  1  ${retries}
    \  Reload page
    \  # Click the notifications icon
    \  Click element  xpath:${notif_button_xpath}
    \  ${notif_item}=   Get text  xpath:${notif_items_xpath}\[2\]
    \  Exit for loop if  $notif_item != 'No current notifications'
    \  Console log  Waiting for notification: attempt ${loop}/${retries}
    \  Sleep  ${retry_sleep} seconds  reason=Waiting for next page reload

    # Update the count
    Sleep  2 seconds  reason=Make sure notification is visible
    ${notif_item_count}=  Get element count  xpath:${notif_items_xpath}

    # Check each notification (Not sure why but xpath contains(text()) didn't work here?)
    : FOR  ${notif}  IN RANGE  1  ${notif_item_count}
    \  ${notif_item}=   Get text  ${notif_items_xpath}\[${notif}\]
    \  Exit for loop if  $notif_item == $expected_notif

    Should contain  ${notif_item}  ${expected_notif}  msg=Couldn't find notification!


Delete all notifications
    [Tags]          common

    ${notif_button_xpath}=  Set variable  //div[contains(@id,'mainNav')]/ul/div[contains(@id,'Notifications-react-component')]
    ${notif_items_xpath}=  Set variable  //li[contains(text(),'Notifications')]//parent::ul/li

    # Click the notifications icon
    Click element  xpath:${notif_button_xpath}
    Wait until page contains  Notifications
    ${notif}=  Get text  xpath:${notif_items_xpath}\[2\]

    # Press ESC to remove the notification box (otherwise, can't use search box)
    Run keyword if  $notif == 'No current notifications'  Press keys  None  ESC
    Return from keyword if  $notif == 'No current notifications'

    Click element  xpath://li[contains(text(),'Clear All Notification')]
    Wait until page does not contain element  xpath://li[contains(text(),'Notifications')]


Add banking info if required
    [Tags]          common

    # Add banking info if required
    ${cnt}=  Get element count  class:qa-bank-info-btn
    Run keyword if  $cnt > 0  Enter banking info:  123456  7890123


Enter banking info:
    [Tags]          common
    [Arguments]     ${account_num}  ${routing_num}

    Click button  class:qa-bank-info-btn
    Wait until page contains  Bank Details

    Input text  class: qa-bank-acct-input  ${account_num}
    Input text  class: qa-bank-route-input  ${routing_num}
    Click element  class:qa-send-bank-info-btn

    Wait Until Page Contains Element  class:alert-success
    Page should contain  Bank info Updated
    Sleep  1 s  reason=So alert is visible
    # Click the alert close button
    Click button  class:qa-alert-close-btn


Get the date and time
    [Documentation]  Get a date/time in a timezone with an increment
    # First used to test `Auctions`
    [Tags]          common
    #               (optional: local or UTC only)   (optional: like: '+ 1 minutes')
    [Arguments]     ${timezone}=local   ${increment}=+ 0 seconds

    ${time}=  Get current Date  ${timezone}  ${increment}  #result_format=%Y-%m-%d %I:%M %p
    # result_format=%Y-%m-%d %I:%M %p  (2019-05-15 07:59 PM)
    #Console log  Time: ${time}

    [Return]  ${time}


Update a field in the database
    [Documentation]  Update a field in the DB with new data using `psql`
    # First used to test `Auctions`
    [Tags]          common
    [Arguments]     ${db_name}  ${db_username}  ${table_name}  ${field_name}  ${field_data}  ${where_clause}

    # Create the psql command line required to make the change
    ${cmd}=  Set variable  psql -U ${db_username} -d ${db_name} -c "Update ${table_name}
    ${cmd}=  Catenate  ${cmd}  SET ${field_name}=${field_data} WHERE ${where_clause}"

    Console log  Running PSQL command: ${cmd}

    ${result}=  Run process  ${cmd}  shell=True

    Run keyword if  $result.rc == 0
    ...    Console log  Result: Success!
    ...  ELSE
    ...    Console log  Result: ${result.stderr}

    [Return]  ${result}


Search for assets/packages with this keyword:
    [Documentation]  Search for assets with the passed keyword, navigate to top asset, return count of results
    [Arguments]     ${keyword}  ${type}=asset_record
    [Tags]          common

    ${top_search_xpath}=  Set variable  //form/div/input
    Page should contain element  xpath:${top_search_xpath}

    Input text  xpath:${top_search_xpath}  ${keyword}
    Wait until page contains  See All Results for
    Wait until page contains  ${keyword}  timeout=15

    # Get a count of results
    ${search_results}=  Set variable  //li[contains(@id, 'react-autowhatever')]
    ${count}=  Run Keyword  Get element count  ${search_results}

    # Click top search result
    ${top_result_xpath}=  Set variable  ${search_results}\[1\]
    Wait until page contains element  xpath:${top_result_xpath}  error=Couldn't find keyword search results for '${keyword}'
    Sleep  2 s  # List appears but then reorders?
    Click element  xpath:${top_result_xpath}

    # Check for the appropriate page text based on the type of results expected
    Run keyword if  $type == 'not_listed'
    ...   Wait until page contains  Package is no longer listed

    Run keyword if  $type == 'asset_record'
    ...   Wait until page contains  Product Details:

    Run keyword if  $type == 'package'
    ...   Wait until page contains  Assets in Package:

    Run keyword if  $type != 'not_listed'
    ...   Wait until page contains  ${keyword}

    [return]  ${count}


Find string in table
    [Documentation]  Find a string, report error and capture screenshot if not found
    [Tags]          common
    [Arguments]     ${string}  ${error_msg}=Couldn't find string in table  ${anchor}=//table

    ${row}  ${col} =  Locate table string  ${string}  ${anchor}
    Run keyword if  $row == $None  capture page screenshot
    Should not be equal  ${row}  ${None}  msg=${error_msg}

    [Return]  ${row}  ${col}


I can see these assets in the Sell - Manage Assets page as:
    [Documentation]  Verify that all the asset names in the test data are in the manage - assets table
    [Tags]          common
    [Arguments]     @{asset_group}

    Go to   ${ROOT_URL}/sell/asset_records
    Wait until page contains   Manage Assets

    : FOR   ${asset}  IN  @{asset_group}
    # Convert spaces to underscores in the asset name and use it to match the class name.  Class name defined in:
    #   _row.html.erb, '<td class="p-1 qa-asset-name-<%= asset_record.name ? asset_record.name.tr(" ", "_") : "none" %>">'
    \  ${asset_name}    Replace string using regexp    ${asset["name"]}  \ \  \_\
    \  ${asset_class}   Set variable                   qa-asset-name-${asset_name}
    #\  Console Log    CLASS: ${asset_class}
    \  Page should contain element  class:${asset_class}


Verify a link:
    [Documentation]  Verify a link with link text, link url, link destination page text
    [Arguments]     ${link_text}  ${link_url}  ${page_text}=none
    [Tags]          common

    Page should contain link     link:${link_text}
    Page should contain element  xpath=//a[@href='${link_url}']

    # Click Link                link:${link_text}
    # Wait Until Page Contains  ${link_page text}
    # Go Back


Verify an email notification:
    [Documentation]  Verify an emailed notification
    # 'link' parameter should be string 'none' to skip link test
    [Arguments]     ${subject}  ${receiver}  ${sender}  ${link}=none
    [Tags]          common

   ${email_links}  Run keyword  Wait for latest email with this subject, to this user, get link:
   ...  ${subject}  ${receiver}

   Run keyword if  '${link}' != 'none'  Should contain match  ${email_links}  ${ROOT_URL}/${link}

   # Note: the below doesn't work if 2 emails are received at about the same time
   # ${email_details}=  Run Keyword  Get latest email details
   # Should Contain    ${email_details[0]}  ${subject}
   # Should Contain    ${email_details[1]}  ${receiver}
   # Should Contain    ${email_details[2]}  ${sender}


Initial check
    Log to console  INITIAL CHECK!


If no previous failure, open the browser and start
    [Tags]   common
    Run Keyword If      '${PREV_TEST_STATUS}' == 'FAIL'  Fatal error  msg=Stopping due to previous test failure
    Run Keyword         Open browser and start


Open browser and start
    [Tags]   common

    Set selenium speed  ${SELENIUM_SPEED}

    Open Browser        ${ROOT_URL}  ${BROWSER}
    Set window size     ${BROWSER_WINDOW_WIDTH}  ${BROWSER_WINDOW_HEIGHT}

    # Dismis the "Drift Robot", doesn't stay gone for the rest of the current session?
    # ${drift_widget}=  Get element count  id:drift-widget
    # Run keyword if  ${drift_widget} > 0  Dismiss the Drift Robot chat popup


I see the home page
    [Documentation]  Verify that the root/home page is displayed
    [Tags]           common

    Wait until page contains   Preview the latest assets on Requis
    Page should contain link   link:New Company Registration


I'm logged in as
    [Arguments]      ${userid}  ${passwd}
    [Tags]           common
    [Documentation]  Logout if not logged in as passed user, then log back in as passed user

    # See if already logged in, if so sets global ${CURRENT_LOGGED_IN_USER}
    ${status}=  Get element count  class:qa-current-user
    Run Keyword If  ${status} > 0
    ...    Get the currently logged in user
    ...  ELSE
    ...    Set global variable  ${CURRENT_LOGGED_IN_USER}  ${NONE}

    # Return quickly if already logged in as desired user
    #Run keyword if  $userid == $CURRENT_LOGGED_IN_USER  Console log  ALREADY LOGGED IN AS: ${userid}
    Return from keyword if  $userid == $CURRENT_LOGGED_IN_USER

    # Otherwise, logut and then login as desired user
    Run Keyword If  ${status} > 0  Logout
    Run Keyword If  ${status} > 0  Wait until page contains  Welcome, please sign in  timeout=30

    Input Text      id=email        ${userid}
    Input Text      id=password     ${passwd}
    Click Button    name=commit

    # Get past the onboarding Screen if present
    ${onboarding}=  Get element count  class:qa-onboard-done-btn
    Run keyword if  ${onboarding} > 0  Click element  class:qa-onboard-done-btn

    # Verify that we're logged in as this user
    Wait Until Page Contains  What Do You Want To Do Today?

    # Make sure logged in userid is displayed when clicking the user logo
    Click element  class:qa-current-user
    Wait until page contains  ${userid}  timeout=10  error=Logging in: No user name when clicking user logo
    Sleep  1 second
    Click element  class:qa-current-user


Get the currently logged in user
    [Documentation]  determines who's logged in and save that email in a global var
    [Tags]           common

    ${current_user}=  get element attribute  xpath://a[contains(@class,'qa-current-user')]//img  data-user-email
    Set global variable  ${CURRENT_LOGGED_IN_USER}  ${current_user}


Dismiss the Drift Robot chat popup
    [Documentation]  Dismiss the Drift Robot (check that it exists before calling this keyword)
    [tags]  common

    Console log  Dismiss the Drift!

    Wait until page contains element  id:drift-widget
    Select frame    id:drift-widget
        Wait until page contains element  class:CHAT
        Click element   class:CHAT
        Wait until page contains element  class:DISMISS
        Click element   class:DISMISS
    Unselect frame


I'm a seller logged in as:
    [Arguments]      ${userid}       ${passwd}
    [Tags]           common
    [Documentation]  Log in as a seller

    Run keyword  I'm logged in as    ${userid}  ${passwd}


I'm a buyer logged in as:
    [Arguments]      ${userid}       ${passwd}
    [Tags]           common
    [Documentation]  Log in as a buyer

    Run keyword  I'm logged in as    ${userid}  ${passwd}


I'm a company admin logged in as:
    [Documentation]  Log in as a company admin
    [Arguments]     ${userid}        ${passwd}
    [Tags]          common

    Run keyword  I'm logged in as    ${userid}  ${passwd}


Console Log
    [Tags]   common
    [Arguments]     ${message}
    log to console       ${\n}Log mesg: ${message}


Page should contain class
    # This seems to be required for some class names that can't be located the easy way
    # Caution: Use this only when an element has a class name unique to that element
    [Tags]   common
    [Arguments]  ${class}

    Page should contain element   xpath://*[contains(@class,${class})]


Save dynamic test data to file:
    [Arguments]     ${file}
    [Tags]          common

    Console log  "Saving dynamic test data to: "${file}, ADMIN: ${UNIQUE_ADMIN}
    # Store the unique vars in a file for future ref
    Create file     ${file}  """ Note: this file is generated by the 'Save dynamic test data to file' keyword in the 'Add_New_Users' suite"""${\n}
    Append to file  ${file}  UNIQUE_ID = ${UNIQUE_ID}${\n}
    Append to file  ${file}  UNIQUE_KEY = '${UNIQUE_KEY}'${\n}
    Append to file  ${file}  UNIQUE_ADMIN = '${UNIQUE_ADMIN}'${\n}
    Append to file  ${file}  UNIQUE_USER1 = '${UNIQUE_USER1}'${\n}
    Append to file  ${file}  UNIQUE_USER2 = '${UNIQUE_USER2}'${\n}
    Append to file  ${file}  UNIQUE_USER3 = '${UNIQUE_USER3}'${\n}
    Append to file  ${file}  UNIQUE_USER4 = '${UNIQUE_USER4}'${\n}
    Append to file  ${file}  UNIQUE_COMPANY = '${UNIQUE_COMPANY}'${\n}

