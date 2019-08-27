*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Common_Keywords.robot

Suite Setup     If no previous failure, open the browser and start
Suite Teardown  Close All Browsers

Force Tags      Priority-V1


*** Variables ***

${company_name_col}     1


*** Test Cases ***

# Use seeded company data for these tests since it's already set up with assets at this point

Admin user can make company's screen name public

    Given I'm logged in as  ${company_apple.admin_user}  ${company_apple.admin_password}
    When I'm at the Administration - Company Settings page
    and I change the screen name to:  ${company_apple.base_company_name}
    Then I can see this company name on this asset when logged in as:
    ...  ${company_apple.base_company_name}  iPhones  ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}


Admin user can make company's screen name private

    Given I'm logged in as  ${company_apple.admin_user}  ${company_apple.admin_password}
    When I'm at the Administration - Company Settings page
    and I change the screen name to:  Private Company
    Then I can see this company name on this asset when logged in as:
    ...  Private Company  iPhones  ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}


# Note: see also `Preview` test in `Create and List Packages' suite
Admin user can allow displaying assets to preview users

    Given I'm logged in as  ${company_apple.admin_user}  ${company_apple.admin_password}
    When I'm at the Administration - Company Settings page
    and I change 'Display assets to logged out users' to:  disabled
    Then As a preview user I can verify that this asset is in this state:  iPhones  visible


Admin user does not allow displaying assets to preview users

    Given I'm logged in as  ${company_apple.admin_user}  ${company_apple.admin_password}
    When I'm at the Administration - Company Settings page
    and I change 'Display assets to logged out users' to:  enabled
    Then As a preview user I can verify that this asset is in this state:  iPhones  invisible

# Admin user can invite company contacts

#     Given I'm logged in as  ${company_apple.admin_user}  ${company_apple.admin_password}
#     When I'm at the Administration - Company Contacts page
#     Then I can invite new contacts

*** Keywords ***

I change 'Display assets to logged out users' to:
    [Documentation]  Change the state of the display "Opt Out"
    [Tags]          local
    [Arguments]     ${state}

    Run keyword if  $state == 'enabled'  Select checkbox  class:qa-opt-out  ELSE
    ...  Unselect checkbox  class:qa-opt-out

    Click element  name:commit
    Page should contain element  class=alert-success  Company info updated successfully


As a preview user I can verify that this asset is in this state:
    [Documentation]  Verify assets are or aren't visible to a logged out user
    [Tags]          local
    [Arguments]     ${asset_name}  ${state}

    # A 'preview' user is any user that isn't logged in
    Logout
    Wait until page contains  Preview the latest assets on Requis
    Click link                Preview Assets
    Wait until page contains  Register to start buying

    # Search for this asset on the preview screen
    Input Text  class:ais-SearchBox-input  ${asset_name}
    Press key   class:ais-SearchBox-input  \\13
    Sleep  2 s  reason=Waiting for search
    ${search_count}=  Get element count  class:ais-InfiniteHits-item
    # Verify only one search match
    Should be equal as numbers  ${search_count}  1  msg=More than 1 search result found!

    Run keyword if  $state == 'visible'  Wait until page contains  ${asset_name}  ELSE
    ...  Page should not contain  ${asset_name}

    Go to  ${ROOT_URL}
    Wait until page contains  Preview the latest assets on Requis


I'm at the Administration - Company Settings page
    [Documentation]  Navigate to this page
    [Tags]          local

    Go to   ${ROOT URL}/company/edit
    Wait until page contains  Company Info


I change the screen name to:
    [Documentation]  Change the company's screen name
    [Tags]          local
    [Arguments]     ${screen_name}

    Select from list by value  id:company_screen_name  ${screen_name}

    Click element  name:commit
    Page should contain element  class=alert-success  Company info updated successfully


I can see this company name on this asset when logged in as:
    [Documentation]  Verify this user sees assets with the correct screen name
    [Tags]          local
    [Arguments]     ${screen_name}  ${asset_name}  ${user}  ${password}

    I'm logged in as  ${user}  ${password}
    #I'm at the Requis Marketplace - Asset Records page

    Search for assets/packages with this keyword:  ${asset_name}

    Wait until page contains  Product Details:
    Page should contain  Seller: ${screen_name}




