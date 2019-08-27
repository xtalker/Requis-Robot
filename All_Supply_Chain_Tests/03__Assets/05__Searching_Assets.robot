*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Common_Keywords.robot

Library         String
Library         Collections

# Asset related test data
Variables       ${EXECDIR}/All_Supply_Chain_Tests/Project_Test_Data/unique_asset_test_data.yaml

Suite Setup     Open browser and start
#Suite Setup     If no previous failure, open the browser and start
Suite Teardown  Close All Browsers

#Force Tags      skip

*** Variables ***

${SINGLE_ASSET_NAME}=        ${asset_group3[0]["name"]}

# Asset table colum indexs
${ASSET_NAME_COL}=           2
${ASSET_MODEL_COL}           4
${ASSET_CONDITION_COL}       6
${ASSET_QUAN_COL}=           8
${ASSET_LOCATION_COL}=       12


*** Test Cases ***

Search for assets by keyword

    Given I'm a buyer logged in as:  ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    And Search for assets/packages with this keyword:  iPhones


Search for assets with multiple search parameters

    Given I'm a buyer logged in as:  ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    And I'm at the Marketplace - Search page
    When I search for assets/packages with these parameters:  US  Instrumentation
      ...  Open box - like new  ${UNIQUE_ID}
    Then I should find only assets that match this keyword:  ${UNIQUE_ID}
    And I should find only assets that match this filter:  LOCATION   US
    And I should find only assets that match this filter:  MODEL      Round
    And I should find only assets that match this filter:  CONDITION  Open box - like new


*** Keywords ***

I search for assets/packages with these parameters:
    [Documentation]  Search for assets with the passed params
    [Arguments]     ${country}=none     ${category}=none
    ...             ${condition}=none   ${keyword}=none
    ...             ${type}=assets
    [Tags]          local

    # Set the search type
    Click element   xpath://div[starts-with(@class, 'MuiSelect-select-')]
    Run keyword if  $type == 'packages'
    ...    Click element   xpath://li[contains(text(), \'Packages\')]
    ...  ELSE
    ...    Click element   xpath://li[contains(text(), \'Assets\')]

    # Enter search params
    Run keyword if  $keyword != 'none'  Input Text  class:ais-SearchBox-input    ${keyword}
    Run keyword if  $keyword != 'none'  Press key  class:ais-SearchBox-input  \\13

    Click button  Table
    Wait until page contains  Tile

    Click button  Filter
    Wait until page contains  Refinements

    # Setting a filter search param causes the filter to be partially highlighted making it impossible(?) to find
    #Input Text  id:facet-search-country      ${country}
    Run keyword if  $country != 'none'  Set this filter  ${country}
    Run keyword if  $category != 'none'  Set this filter  ${category}
    Run keyword if  $condition != 'none'  Set this filter  ${condition}

    # Close the filter panel (with the button next to the "clear filter" button)
    Click element  xpath://div[contains(@class,'ais-ClearRefinements')]/following-sibling::button

    #Sleep  2 s  reason=Waiting for search

Set this filter
    [Documentation]  Find the filter, check it
    [Arguments]     ${filter}
    [Tags]          local

    #${filter}=  Convert to lowercase  ${filter}

    # Define the highlighted checkbox xpath for this filter
    ${filter_checkbox}=  Set variable  //span[contains(@class,'ais-RefinementList-labelText')][contains(text(),\'${filter}\')]

    # Make sure its visible and highlighted
    Wait until page contains element  xpath:${filter_checkbox}  timeout=20

    Click element  xpath:${filter_checkbox}

    # Wait for filter to be listed on top of the main page
    Wait until page contains element  xpath://span[starts-with(@class, 'MuiChip-label-')][contains(text(),\'${filter}\')]


I should find only assets that match this keyword:
    [Documentation]  Check each table row for this filtered data
    [Arguments]     ${keyword}
    [Tags]          local

    ${keyword}=  Convert to string  ${keyword}

    # Verify results table has no extra, unexpected results
    ${table_row_xpath}=  Set Variable  //tr[contains(@id,'MUIDataTableBodyRow-')]
    ${row_count}=  Run Keyword  Get element count  xpath:${table_row_xpath}
    # There is some delay waiting for the search to complete here
    Should be true  $row_count > 0  msg=Couldn't find any table rows!

    # Verify each row of search results contains the keyword
    : FOR  ${row}  IN RANGE  0  ${row_count}
    \  ${asset_row}=   Get text  xpath:${table_row_xpath}
    \  Should contain   ${asset_row}  ${keyword}  ignore_case=True
    \  ...  msg=Filter: couldn't find keyword data: ${keyword} in ${asset_row}


I should find only assets that match this filter:
    [Documentation]  Check each table row for this filtered data
    [Arguments]     ${filter_type}  ${filter_data}
    [Tags]          local


    # Verify results table has no extra, unexpected results
    ${table_row_xpath}=  Set Variable  //tr[contains(@id,'MUIDataTableBodyRow-')]
    ${row_count}=  Run Keyword  Get element count  xpath:${table_row_xpath}

    Should be true  $row_count > 0  msg=Couldn't find any table rows!

    : FOR  ${row}  IN RANGE  0  ${row_count}
    \  ${asset_name}=   Get text  xpath://tbody/tr[${row+1}]/td[${ASSET_NAME_COL}]
    \  ${asset_data}=   Get text  xpath://tbody/tr[${row+1}]/td[${ASSET_${filter_type}_COL}]
    \  Should be equal  ${asset_data}  ${filter_data}  mesg=Filter: ${filter_type}, '${filter_data}'' didn't match for asset: ${asset_name}


I should find only assets with this category:
    [Documentation]  Check each table row for this category
    [Arguments]     ${category}
    [Tags]          local

    # Verify results table has no extra, unexpected results
    ${row_count}=  Run Keyword  Get element count  xpath://tr

    : FOR  ${row}  IN RANGE  1  ${row_count}
    \  ${asset_category}=  Get text  xpath://table//tr[${row}]/td[${asset_category_col}][contains(@class,'qa-category')]
    \  Should match  ${category}  ${asset_category}  msg=Category: ${asset_category} not expected in search results in row ${row}


I should find only assets with this condition:
    [Documentation]  Check each table row for this condition
    [Arguments]     ${condition}
    [Tags]          local

    # Verify results table has no extra, unexpected results
    ${row_count}=  Run Keyword  Get element count  xpath://tr

    : FOR  ${row}  IN RANGE  1  ${row_count}
    \  ${asset_condition}=  Get text  xpath://table//tr[${row}]/td[${asset_cond_col}]
    \  Should match  ${condition}  ${asset_condition}  msg=Condition: ${asset_condition} not expected in search results in row ${row}


I clear the search form
    [Tags]          local

    Click element  class:qa-clear-btn


I get at least this many assets:
    [Documentation]  Check the search results for a count of assets found
    [Arguments]     ${minimum_asset_count}
    [Tags]          local

    ${minimum_asset_count}=  Convert to integer  ${minimum_asset_count}
    ${row_count}=    Run Keyword  Get element count  xpath://tr
    Run keyword if  ${row_count-1} < ${minimum_asset_count}  Fail  msg=Expected at least ${minimum_asset_count} in search results


I should find only these assets in the search results:
    [Documentation]  Check each table row for each asset name (without the ID-* portion)
    [Arguments]     @{assets}
    [Tags]          local

    ${names}=  Create list  ${EMPTY}

    # Verify all the passed assets are in the results table
    : FOR  ${asset}  IN  @{assets}
    #\  Console log  Verifying_1: ${asset["name"]}
    \  Run keyword if  $assets[0] != None  Page should contain link  link:${asset["name"]}  msg=${asset["name"]} not found in search results
    #  Create a list with just the asset names
    \  Run keyword if  $assets[0] != None  Append to list  ${names}  ${asset["name"]}

    # Verify results table has no extra, unexpected results
    ${row_count}=  Run Keyword  Get element count  xpath://tr
    : FOR  ${row}  IN RANGE  1  ${row_count}
    \  ${asset_with_id}=  Get text  xpath://table//tr[${row}]/td[${asset_name_col}]//a
    # Remove ` ID-*` from asset name
    \  ${asset_name_only}=  Remove string using regexp  ${asset_with_id}  ${SPACE}ID-.*
    #\  Console log  Verifying_2: ${asset_name_only}
    \  Should contain match  ${names}  ${asset_name_only}*  msg=${asset_name_only}* not expected in search results






