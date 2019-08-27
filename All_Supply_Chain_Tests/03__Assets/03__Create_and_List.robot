*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Common_Keywords.robot

# Asset related test data
Variables       ${EXECDIR}/All_Supply_Chain_Tests/Project_Test_Data/unique_asset_test_data.yaml

Suite Setup     If no previous failure, open the browser and start
Suite Teardown  Close All Browsers

Force Tags      critical

*** Variables ***

${TEST_ASSET}                   ${asset_group3[0]["name"]}
${asset_table select_col}       1
${asset_table_status_col}       6
${package_table_select_col}     1
${package_table_edit_col}       2
${package_table_status_col}     3
${preview_min_assets}           40


*** Test Cases ***


Create a listed package with a group of assets

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Sell - Asset Records page
    Then I can create a new package for this group of assets as:  ${asset_group1}  Asset Group 1-${UNIQUE_ID}  2000
    And I can list this package as:  Asset Group 1-${UNIQUE_ID}

    Given I'm a buyer logged in as:   ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    I can see this package in the packages panel as:  Asset Group 1-${UNIQUE_ID}


Create a second listed package with a group of assets

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Sell - Asset Records page
    Then I can create a new package for this group of assets as:  ${asset_group2}  Asset Group 2-${UNIQUE_ID}  2600
    And I can list this package as:  Asset Group 2-${UNIQUE_ID}

    Given I'm a buyer logged in as:   ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    I can see this package in the packages panel as:  Asset Group 2-${UNIQUE_ID}


Create a third listed package with a group of assets

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Sell - Asset Records page
    Then I can create a new package for this group of assets as:  ${asset_group4}  Asset Group 4-${UNIQUE_ID}  200
    And I can list this package as:  Asset Group 4-${UNIQUE_ID}

    Given I'm a buyer logged in as:   ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    I can see this package in the packages panel as:  Asset Group 4-${UNIQUE_ID}

List an individual assets for 'Buy Now'

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Sell - Asset Records page
    Then I can set this asset's sales method to 'buy now':  ${TEST_ASSET}


List individual assets

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Sell - Asset Records page
    Then I can list individual assets in:  ${asset_group3}

    Given I'm a buyer logged in as:   ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    I can see these assets in the assets table:  ${asset_group3}


List auction individual assets

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Sell - Asset Records page
    Then I can list auction assets in:  ${asset_group5}


List auction packages

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Sell - Asset Records page
    Then I can create a new package for this group of assets as:  ${asset_group6}
    ...  Asset Group 6-${UNIQUE_ID}  200
    Then I can list this asset group as a package auction:  Asset Group 6-${UNIQUE_ID}
    ...  ${asset_group6_auction_params}


Asset preview

    Given I'm not logged in and can see the home page
    Then I can preview the latest assets


Backup Requis database for debug purposes
    [Teardown]  Run keyword if test failed  log to console  -FAILED:\n ${result.stderr}

    ${result}=  Run process  rake qa_backup  shell=True

    Should be equal as strings  ${result.rc}  0


*** Keywords ***

I can list this asset group as a package auction:
    [Documentation]  List all the assets in this group as a package auction
    [Arguments]     ${package_name}  ${params}
    [Tags]          local

    Go to   ${ROOT URL}/packages
    Wait until page contains  Manage Packages

    # Set up this package for an auction sale
    ${row}  ${col} =  Find string in table  ${package_name}  Couldn't find ${package_name} in table
    ${package_select_xpath} =  Set variable  //tbody/tr[${row}]/td[${package_table_edit_col}]
    Click element  xpath:${package_select_xpath}
    Wait until page contains  Edit Package

    ${start_date_xpath}  Set variable  //input[contains(@class,'qa-start-date')][contains(@type,'text')]
    ${end_date_xpath}    Set variable  //input[contains(@class,'qa-end-date')][contains(@type,'text')]

    Execute Javascript  window.scrollBy(0, 1200)  # Scroll to bottom
    Click element  id:sale-method-auction
    Wait until page contains  Start Date

    ${time}=    Get the date and time  UTC  ${params.auction_start_date}
    Input text  xpath:${start_date_xpath}  ${time}
    Press key  xpath:${start_date_xpath}  \\13  # This validates/normalizes the date entered
    ${time}=    Get the date and time  UTC  ${params.auction_end_date}
    Input text  xpath:${end_date_xpath}    ${time}
    Press key  xpath:${end_date_xpath}  \\13

    Input text  id:package_auction_attributes_start_price  ${params.starting_bid}
    Input text  id:package_auction_attributes_reserve_price  ${params.reserve_price}

    Click element  name:commit
    Wait Until Page Contains Element  class:alert-success
    Page should contain  Successfully updated

    # List the package
    Run keyword  I'm at the Manage - Packages page
    ${row}  ${col} =  Find string in table  ${package_name}  Couldn't find ${package_name} in table
    ${package_select_xpath} =  Set variable  //tbody/tr[${row}]/td[${package_table_select_col}]/input
    Set focus to element  xpath:${package_select_xpath}
    Click element  xpath:${package_select_xpath}
    Click element  class:qa-list-pkg-btn

    # Listing confirmation, verify current sale fee for this company (set when a new company is approved)
    Wait until page contains  Listing Confirmation
    ${fee}=  Convert to string  ${company_1.sale_fee}
    Page should contain  I accept to pay the ${fee} % commission upon sale of goods and confirm that my seller terms are up to date.
    Click element  class:qa-agree-list-pkg-btn


I can set this asset's sales method to 'buy now':
    [Tags]          local
    [Arguments]     ${asset_name}

    ${row}  ${col} =  Find string in table  ${asset_name}  Couldn't find ${asset_name} in table
    ${asset_select_xpath} =  Set variable  //tbody/tr[${row}]/td[${asset_table_status_col}]
    Click element  xpath:${asset_select_xpath}
    Wait until page contains  Edit Asset Record

    Execute Javascript  window.scrollBy(0, 1200)  # scroll to bottom
    Click element  class:qa-allow-offers
    Wait until element is visible  class:qa-enable-buy-now
    Click element  class:qa-enable-buy-now

    Click element  name:commit
    Wait Until Page Contains Element  class:alert-success
    Page should contain  Asset Record has been updated


I can list auction assets in:
    [Documentation]  List all the assets in this group
    [Arguments]     ${asset_group}
    [Tags]          local

    # The start/end dates have two inputs with the same classes (but one is hidden)
    ${start_date_xpath}  Set variable  //input[contains(@class,'qa-start-date')][contains(@type,'text')]
    ${end_date_xpath}    Set variable  //input[contains(@class,'qa-end-date')][contains(@type,'text')]

    # Select each asset in group and set auction params
    : FOR   ${asset}  IN  @{asset_group}
    \  ${row}  ${col} =  Find string in table  ${asset["name"]}  Couldn't find ${asset["name"]} in table
    \  ${asset_select_xpath} =  Set variable  //tbody/tr[${row}]/td[${asset_table_status_col}]
    \  Set focus to element  xpath:${asset_select_xpath}
    \  Click element  xpath:${asset_select_xpath}
    \  Wait until page contains  Edit Asset Record
    \
    \  Click element  id:sale-method-auction
    \  Execute Javascript  window.scrollBy(0, 1200)  # Scroll to bottom
    \  Wait until page contains  Start Date
    \
    \  ${time}=    Get the date and time  UTC  ${asset['auction_start_date']}
    \  Input text  xpath:${start_date_xpath}  ${time}
    \  Press key  xpath:${start_date_xpath}  \\13  # This validates/normalizes the date entered
    \  ${time}=    Get the date and time  UTC  ${asset['auction_end_date']}
    \  Input text  xpath:${end_date_xpath}    ${time}
    \  Press key  xpath:${end_date_xpath}  \\13
    \
    \  Input text  id:asset_record_auction_attributes_start_price  ${asset['starting_bid']}
    \  Input text  id:asset_record_auction_attributes_reserve_price  ${asset['reserve_price']}
    \
    \  Click element  name:commit
    \  Wait Until Page Contains Element  class:alert-success
    \  Page should contain  Asset Record has been updated
    \  Go back

    Run keyword  Select all assets in asset group:  ${asset_group}
    Scroll to the top of the page
    Click element  class:qa-list-btn

    # Listing confirmation, verify current sale fee for this company (set when a new company is approved)
    Wait until page contains  Listing Confirmation
    ${fee}=  Convert to string  ${company_1.sale_fee}
    Page should contain  I accept to pay the ${fee} % commission upon sale of goods and confirm that my seller terms are up to date.
    Click element  class:qa-agree-to-list-asset-btn

    Verify listing status for each asset in group:  ${asset_group}


I can preview the latest assets
    [Documentation]  Verify the 'Preview Now' function
    [Tags]          local

    # At login screen
    Wait until page contains element  class:qa-preview-btn
    Click element                class:qa-preview-btn
    Wait until page contains     Search & Preview Assets on Requis
    Page should contain element  class:ais-SearchBox-input

    # Count assets
    ${asset_count}=  Get element count  class:ais-InfiniteHits-item

    # Should be ALL assets (test data plus pre-seeded), make this dynamic?
    Console log  Asset preview contains ${asset_count} assets
    Run keyword if  ${asset_count} < ${preview_min_assets}  Fail
    ...  msg=Search found less than the minimum number of assets (Found: ${asset_count}, min: ${preview_min_assets})

    # Search for an asset
    Input Text  class:ais-SearchBox-input  ${TEST_ASSET}
    Press key   class:ais-SearchBox-input  \\13
    Sleep  2 s  reason=Waiting for search
    ${search_count}=  Get element count  class:ais-InfiniteHits-item
    Should be true  ${search_count}  msg=Couldn't find "${TEST_ASSET}" in the search results

    # Verify an asset's details can be accessed
    Set focus to element  xpath://span[contains(text(),'Preview')]
    Click element  xpath://span[contains(text(),'Preview')]

    Wait until page contains  Get More Information
    Page should contain  ${TEST_ASSET}

    # "Get more information" should pop up a registration form
    Click button  Get More Information
    Wait Until Page Contains  We're Looking Forward to Talking!
    Sleep  1
    Click button  Close

    #Scroll to the top of the page
    Sleep  1
    Wait Until Page Contains     Register to start buying
    Click link                   link:REGISTER NOW!
    Location should be           ${ROOT URL}/signup


I'm not logged in and can see the home page
    [Documentation]  Log out if logged in
    [Tags]          local

    Go to  ${ROOT URL}

    ${status}=  Get element count  class:qa-current-user
    # Determine if a user is already logged in, if so, logout
    Run Keyword If  ${status} > 0  Logout

    I see the home page


I can see these assets in the assets table:
    [Documentation]  Verify the assets in this group are listed
    [Arguments]     ${asset_group}
    [Tags]          local

    Go to  ${ROOT_URL}/search
    Wait until page contains  Search Results

    # This takes too way long, need to use `Search` here
    : FOR   ${asset}  IN  @{asset_group}
    #\  Console log  Checking: ${asset["name"]}
    #\  Table should contain  xpath://table  ${asset["name"]}
    \  ${count}=  Search for assets/packages with this keyword:  ${asset["name"]}
    \  Should be true  ${count}  msg=Couldn't find "${asset["name"]}" in the search results


I can list individual assets in:
    [Documentation]  List all the assets in this group
    [Arguments]     ${asset_group}
    [Tags]          local

    Run keyword  Select all assets in asset group:  ${asset_group}
    Scroll to the top of the page
    Click element  class:qa-list-btn

    # Listing confirmation, verify current sale fee for this company (set when a new company is approved)
    Wait until page contains  Listing Confirmation
    ${fee}=  Convert to string  ${company_1.sale_fee}
    Page should contain  I accept to pay the ${fee} % commission upon sale of goods and confirm that my seller terms are up to date.
    Click element  class:qa-agree-to-list-asset-btn

    Verify listing status for each asset in group:  ${asset_group}


I can create a new package for this group of assets as:
    [Documentation]  Add all of the assets in this group to a package
    [Arguments]     ${asset_group}  ${package_name}  ${buy_now_amount}
    [Tags]          local

    Run keyword  Select all assets in asset group:  ${asset_group}

    Scroll to the top of the page
    Click element  class:qa-actions-btn
    Wait until page contains  Actions
    Click element  class:qa-create-package
    Click element  class:qa-update-btn

    Wait Until Page Contains Element  class:alert-success
    Page should contain  Successfully created a new package
    Sleep  1 s  reason=So alert is visible
    Click button  class:qa-alert-close-btn

    Click link  Edit Package
    Wait until page contains  Edit Package - Assets in

    Input text  id:package_name  ${package_name}
    # Set package currency to the currency of the first asset in the package
    Select from list by value  id:package_currency  ${asset_group[0]['currency']}
    Select from list by value  name:package[condition]  Used
    Click element  class:qa-allow-offers
    Wait until page contains  Buy Now Amount

    Input text  name:package[buy_now_amount]  ${buy_now_amount}
    Click element  class:qa-enable-buy-now
    Input text  name:package[seller_terms]  These are the seller terms for ${package_name}

    Scroll to the top of the page
    Click element  class:qa-save-btn
    Wait until page contains  Successfully updated!


I can list this package as:
    [Documentation]  Find the package in the package list and then list it
    [Arguments]     ${package_name}  ${method}='request_price'
    [Tags]          local

    Go to   ${ROOT URL}/packages
    Wait until page contains  Manage Packages

    # Find this package by name in the package table, select and edit it
    ${row}  ${col} =  Find string in table  ${package_name}  Couldn't find ${package_name} in table
    ${package_select_xpath} =  Set variable  //tbody/tr[${row}]/td[${package_table_select_col}]/input
    ${package_edit_xpath} =  Set variable  //tbody/tr[${row}]/td[${package_table_edit_col}]/input
    Set focus to element  xpath:${package_select_xpath}
    Click element  xpath:${package_select_xpath}

    # List this package
    Run keyword if  ${row} > 8  Execute Javascript  window.scrollBy(0, 150)
    Click element  class:qa-list-pkg-btn

    # Listing confirmation, verify current sale fee for this company (set when a new company is approved)
    Wait until page contains  Listing Confirmation
    ${fee}=  Convert to string  ${company_1.sale_fee}
    Page should contain  I accept to pay the ${fee} % commission upon sale of goods and confirm that my seller terms are up to date.
    Click element  class:qa-agree-list-pkg-btn

    # Verify package status changes to 'Listed'
    Wait until keyword succeeds  3x  1s  Table cell should contain  xpath://table  ${row+1}
    ...  ${package_table_status_col}  Listed


I can see this package in the packages panel as:
    [Documentation]  Verify that this package shows in the Packages panel
    [Arguments]     ${package_name}
    [Tags]          local

    Go to   ${ROOT URL}/search?view=1
    Wait until page contains  Search Results

    # Xpath that contains a single package name
    ${results_xpath}=  Set variable  //div[contains(@class,'ais-InfiniteHits')]/ul/li//span

    Page should contain element  xpath:${results_xpath}\[contains(text(),\'${package_name}\')\]


Select all assets in asset group:
    [Documentation]  Click the select checkbox for a group of assets
    [Arguments]     ${asset_group}
    [Tags]          local

    # Select each asset in group
    : FOR   ${asset}  IN  @{asset_group}
    #\  Console Log    ASSET: ${asset["name"]}
    \  ${row}  ${col} =  Find string in table  ${asset["name"]}  Couldn't find ${asset["name"]} in table
    \  ${asset_select_xpath} =  Set variable  //tbody/tr[${row}]/td[${asset_table_select_col}]/input
    \  Set focus to element  xpath:${asset_select_xpath}
    \  Wait until page contains element  xpath:${asset_select_xpath}  timeout=30
    #  Scroll down so "Help button isn't in the way if on a row not near the top
    \  Run keyword if  '${row}' > '4'  Execute Javascript  window.scrollBy(0, 150)
    #\  Run keyword if  '${row}' > '4'  Console log  row: ${row}
    \
    \  Click element  xpath:${asset_select_xpath}


Verify listing status for each asset in group:
    [Documentation]  Check the listing status for a group of assets
    [Arguments]     ${asset_group}
    [Tags]          local

    Sleep  1  # The below seems to fail with: "StaleElementReferenceException: Message: The element reference of <td> is stale;"
    : FOR   ${asset}  IN  @{asset_group}
    #\  Console Log    ASSET: ${asset["name"]}
    \  ${row}  ${col} =    Find string in table  ${asset["name"]}
    \  Table cell should contain  xpath://table  ${row+1}  ${asset_table_status_col}  Listed


