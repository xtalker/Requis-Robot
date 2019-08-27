*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Common_Keywords.robot

Library         String
Library         OperatingSystem

# Asset related test data
Variables       ${EXECDIR}/All_Supply_Chain_Tests/Project_Test_Data/unique_asset_test_data.yaml

Suite Setup     If no previous failure, open the browser and start
Suite Teardown  Close All Browsers

Force Tags      critical

*** Variables ***

${asset_data_yaml}  ${EXECDIR}/All_Supply_Chain_Tests/Project_Test_Data/asset_test_data.yaml
${asset_data_csv}   ${EXECDIR}/All_Supply_Chain_Tests/Project_Test_Data/asset_test_data.csv

# Upload history table column indexes
${HISTORY_TABLE_CNT_COL}  4


*** Test Cases ***

Seller uploads the first group of assets for a package listing

    [Setup]     Create a temporary CSV file from test data assets   ${asset_data_csv}  ${asset_group1}
    #[Teardown]  Remove file   ${asset_data_csv}

    Given I'm logged in as  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Sell - Upload page
    Then I can upload these assets from a CSV file as  Asset Group 1-${UNIQUE_ID}
       and I can verify the pop-up matches assets in this group:  @{asset_group1}
       and I can see these assets in the Sell - Manage Assets page as:  @{asset_group1}


Seller uploads a second group of assets for individual listings

    [Setup]     Create a temporary CSV file from test data assets   ${asset_data_csv}  ${asset_group2}
    #[Teardown]  Remove file   ${asset_data_csv}

    Given I'm logged in as  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Sell - Upload page
    Then I can upload these assets from a CSV file as  Asset Group 2-${UNIQUE_ID}
       and I can verify the pop-up matches assets in this group:  @{asset_group2}
       and I can see these assets in the Sell - Manage Assets page as:  @{asset_group2}


Seller uploads a third group of assets for a package listing

    [Setup]     Create a temporary CSV file from test data assets   ${asset_data_csv}  ${asset_group3}
    #[Teardown]  Remove file   ${asset_data_csv}

    Given I'm logged in as  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Sell - Upload page
    Then I can upload these assets from a CSV file as  Asset Group 3-${UNIQUE_ID}
       and I can verify the pop-up matches assets in this group:  @{asset_group3}
       and I can see these assets in the Sell - Manage Assets page as:  @{asset_group3}


Seller uploads a fourth group of assets for a package listing

    [Setup]     Create a temporary CSV file from test data assets   ${asset_data_csv}  ${asset_group4}
    #[Teardown]  Remove file   ${asset_data_csv}

    Given I'm logged in as  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Sell - Upload page
    Then I can upload these assets from a CSV file as  Asset Group 4-${UNIQUE_ID}
       and I can verify the pop-up matches assets in this group:  @{asset_group4}
       and I can see these assets in the Sell - Manage Assets page as:  @{asset_group4}


Seller uploads a fifth group of assets for auction listing

    [Setup]     Create a temporary CSV file from test data assets   ${asset_data_csv}  ${asset_group5}
    #[Teardown]  Remove file   ${asset_data_csv}

    Given I'm logged in as  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Sell - Upload page
    Then I can upload these assets from a CSV file as  Asset Group 5-${UNIQUE_ID}
       and I can verify the pop-up matches assets in this group:  @{asset_group5}
       and I can see these assets in the Sell - Manage Assets page as:  @{asset_group5}


Seller uploads a sixth group of assets for package auction listing

    [Setup]     Create a temporary CSV file from test data assets   ${asset_data_csv}  ${asset_group6}
    #[Teardown]  Remove file   ${asset_data_csv}

    Given I'm logged in as  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Sell - Upload page
    Then I can upload these assets from a CSV file as  Asset Group 6-${UNIQUE_ID}
       and I can verify the pop-up matches assets in this group:  @{asset_group6}
       and I can see these assets in the Sell - Manage Assets page as:  @{asset_group6}


The asset table should include links to assets
    I'm logged in as  ${UNIQUE_USER1}  ${USER1_PASSWD}
    Go to   ${ROOT_URL}/sell/asset_records

    ${row}  ${col} =  Find string in table  ${asset_group3[0]["name"]}  Couldn't find ${asset_group3[0]["name"]} in table
    #Console Log    Found ${asset_group3[0]["name"]} in row: ${row}, col: ${col}
    # Create the xpath to the asset link based on the row/col (not sure why col+1?)
    ${asset_link_xpath}=  Set variable  //tbody/tr[${row}]/td[${col} + 1]

    Set focus to element  xpath:${asset_link_xpath}
    #Sleep  1
    Click element  xpath:${asset_link_xpath}

    Wait until page contains   Edit Asset Record
    #Page should contain   ${asset_group3[0]["name"]}
    # Not sure why the asset name couldn't be found with the above?
    Page should contain element  xpath://input[contains(@value, '${asset_group3[0]["name"]}')]


Verify the upload history page shows all uploads

    Given I'm logged in as  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Sell - Upload History page
    Then I can verify the upload history page contains these asset group numbers:  1  2  3  4


*** Keywords ***

I can verify the pop-up matches assets in this group:
    [Documentation]  Verify that the 'Current Successful Uploads' popup is correct
    [Tags]          local
    [Arguments]     @{asset_group}

    Wait until page contains  Current Successful Uploads

    # Verify that all assets in the group are displayed
    : FOR   ${asset}  IN  @{asset_group}
    # Convert spaces to underscores in the asset name and use it to match the class name.  Class name defined in:
    #   _row.html.erb, '<td class="p-1 qa-asset-name-<%= asset_record.name ? asset_record.name.tr(" ", "_") : "none" %>">'
    \  ${asset_name}    Replace string using regexp    ${asset["name"]}  \ \  \_\
    \  ${asset_class}   Set variable                   qa-asset-name-${asset_name}
    \  Page should contain element  class:${asset_class}

    Click element  class:qa-close-btn
    Alert should be present  text=Are you sure you want to leave without listing?

    Sleep  3 seconds  reason=To avoid a known 500 error bug (#81) here


I can verify the upload history page contains these asset group numbers:
    [Documentation]  Verify that the upload history page shows these uploads
    [Tags]          local
    [Arguments]     @{asset_groups}

    : FOR  ${asset_group_num}  IN  @{asset_groups}
    \  # Get the asset group test data with this number
    \  ${this_asset_group}=  Get variable value  ${asset_group${asset_group_num}}
    \
    \  # Check for the asset group name related to this number
    \  ${asset_group_name}=  Set variable  Asset Group ${asset_group_num}-${UNIQUE_ID}
    \  Page should contain  ${asset_group_name}
    \
    \  # Find this asset group name in the table and verify the records count matches the test data
    \  ${row}  ${col} =  Find string in table  ${asset_group_name}  Couldn't find ${asset_group_name} in table
    \  ${table_cnt}=   Get table cell  class:qa-upload-history-tbl  ${row+1}  ${HISTORY_TABLE_CNT_COL}
    \  ${record_cnt}=  Get length  ${this_asset_group}
    \  Should be equal as integers  ${table_cnt}  ${record_cnt}
    \  ...  msg=Expected ${asset_group_name} to have ${record_cnt} records, but table had ${table_cnt}


I'm at the Sell - Upload page
    [Documentation]  Navigate to this page
    [Tags]          local

    Go to  ${ROOT URL}/sell/bulk_uploads/new
    Wait until element contains  tag:H3  Create bulk upload


I can upload these assets from a CSV file as
    [Documentation]  Select file and upload
    [Tags]          local
    [Arguments]     ${description}

    Input Text    id=description  ${description}
    Choose file   id:attachment   ${asset_data_csv}
    Click button  class:qa-upload-btn
    Wait until page contains   Current Successful Uploads  timeout=30
    # Click link    class:qa-close-btn

    # Alert should be present  text=Are you sure you want to leave without listing?


Create a temporary CSV file from test data assets
    [Tags]          local
    [Arguments]     ${csv_file}  @{asset_group}

    # Create the header (this must be done in a keyword to use `catenate`)
    ${asset_header}=  catenate  SEPARATOR=
    ...  * Category,Subcategory,Manufacturer,Manufacturer Model,Manufacturer SKU,
    ...  * Quantity,* Units,* Condition,Size1,Size2,Original Purchase Price,
    ...  * Currency,* Country,* Name,* Description,Images,Certifications,Catalogs,
    ...  Specifications,Minimum Offer,Buy Now Amount,Lead time (weeks),Shipping Weight,
    ...  Shipping Dimensions,Packaged (yes/no),Hazmat,MSDS Docs,Spare Part,Custom Field 1,
    ...  Custom Field 2

    # 'Create CSV' is a python script: Create_CSV_From_YAML.py
    ${result} =     run keyword   Create CSV  ${csv_file}  @{asset_group}  ${asset_header}
    Should contain  ${result}  DONE


