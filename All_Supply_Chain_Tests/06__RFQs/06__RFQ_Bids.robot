*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/RFQ_Support.robot

Suite Setup     If no previous failure, open the browser and start
Suite Teardown  Close All Browsers

#Force Tags      skip


*** Variables ***

# RFQ name for these tests
${test_RFQ_name}=   ${RFQ_1["rfq_name"]}

# File names
${bid1_data_csv}    ${RFQ_DATA_DIR}/bid1_data.csv
${bid2_data_csv}    ${RFQ_DATA_DIR}/bid2_data.csv
${comm_docs}  ${RFQ_DATA_DIR}/RFQ_additional_docs/Test-document-2.doc
${tech_docs}  ${RFQ_DATA_DIR}/RFQ_additional_docs/Test-document-4.pdf

# Bid CSV Header
${BID_HEADER}=    Item Number,Commodity / Tag,Description,Total Qty,Unit,Delivery Site,Delivery Time (weeks),Unit Price,Total Price,Currency,Remarks

# Bid items table column indexes
${BID_ITEM_COMMODITY_COL}  2
${BID_ITEM_DESCR_COL}      3
${BID_ITEM_QUAN_COL}       4
${BID_ITEM_SITE_COL}       6
${BID_ITEM_TIME_COL}       7
${BID_ITEM_PRICE_COL}      8
${BID_ITEM_TOTAL_COL}      9
${BID_ITEM_CURRENCY_COL}   10
${BID_ITEM_REMARKS_COL}    11

# Bid tab table columns
${BID-TAB_EMAIL_COL}       1
${BID-TAB_RESPONSE_COL}    5

*** Test Cases ***

A vendor can upload a bid CSV file and documents for an RFQ
    [Setup]     Create temporary CSV bid file  ${RFQ_BID_1}  ${bid1_data_csv}
    [Teardown]  Remove file  ${bid1_data_csv}

    Given I'm logged in as  ${company_apple["admin_user"]}  ${company_apple["admin_password"]}
    When I'm at the Vendor - RFQs page
    Then I can upload this CSV file and these document files to this RFQ:  ${bid1_data_csv}  ${comm_docs}
      ...  ${tech_docs}  ${test_RFQ_name}
      and I can view and verify the uploaded data for this bid:  ${RFQ_ITEM_LIST}  ${RFQ_BID_1}


Another vendor can upload a bid CSV file and documents for the same RFQ
    [Setup]     Create temporary CSV bid file  ${RFQ_BID_2}  ${bid2_data_csv}
    [Teardown]  Remove file  ${bid2_data_csv}

    Given I'm logged in as  ${company_microsoft["admin_user"]}  ${company_microsoft["admin_password"]}
    When I'm at the Vendor - RFQs page
    Then I can upload this CSV file and these document files to this RFQ:  ${bid2_data_csv}  ${comm_docs}
      ...  ${tech_docs}  ${test_RFQ_name}
      and I can view and verify the uploaded data for this bid:  ${RFQ_ITEM_LIST}  ${RFQ_BID_2}


Both bids are displayed in the Bids tab

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    And I can find this RFQ and open the 'Bids' tab:  ${test_RFQ_name}
    Then I see that there is a bid in the table from this email, with this response:
    ...  ${company_apple["admin_user"]}  Bid Submitted
    And I see that there is a bid in the table from this email, with this response:
    ...  ${company_microsoft["admin_user"]}  Bid Submitted


*** Keywords ***

I can find this RFQ and open the 'Bids' tab:
    [Tags]          local
    [Arguments]     ${rfq_name}

    Find this RFQ in the table and select it:  ${test_RFQ_name}

    Click element  class:qa-bids-tab
    Wait until page contains  Compare RFQ Bids


I see that there is a bid in the table from this email, with this response:
    [Tags]          local
    [Arguments]     ${email}  ${response_column}

    # Find this email in the table and verify the response
    ${table_xpath}=  Set variable  //table[contains(@class,'qa-bid-response-table')]

    ${row}  ${col} =  Find string in table  ${email}
    ...  Couldn't find ${email} in "Bids tab" table  anchor=${table_xpath}

    ${cell}=  Get table cell  xpath:${table_xpath}  ${row+1}  ${BID-TAB_RESPONSE_COL}
    Should be equal  ${cell}  ${response_column}


I can view and verify the uploaded data for this bid:
    [Tags]          local
    [Arguments]     ${item_data}  ${bid_data}

    Click link  Submitted Bid
    Wait until page contains   Itemized Prices

    # Verify the bid items table
    ${table_xpath}=  Set variable  //table[contains(@class,'qa-bid-item-table')]

    # Find each item in test data in the "Itemized Prices" list
    : FOR  ${item}  IN  @{item_data}
    \  ${item_num}=  Set variable  ${item["item_number"]}
    \  ${item_num}=  Convert to integer  ${item_num}
    \
    \  ${row}  ${col} =  Find string in table  ${item["description"]}
    \  ...  Couldn't find ${item["description"]} in "Itemized Prices" table  anchor=${table_xpath}
    \
    \  # Verify item data
    \  ${cell}=  Get table cell  xpath:${table_xpath}  ${row+1}  ${BID_ITEM_DESCR_COL}
    \  Should be equal           ${cell}                         ${item["description"]}
    \
    \  ${cell}=  Get table cell  xpath:${table_xpath}  ${row+1}  ${BID_ITEM_COMMODITY_COL}
    \  Should be equal           ${cell}                         ${item["commodity-tag"]}
    \
    \  ${cell}=  Get table cell  xpath:${table_xpath}  ${row+1}  ${BID_ITEM_QUAN_COL}
    \  Should be equal as numbers  ${cell}                       ${item["quantity"]}
    \
    \  ${cell}=  Get table cell  xpath:${table_xpath}  ${row+1}  ${BID_ITEM_SITE_COL}
    \  Should be equal           ${cell}                         ${item["delivery_site"]}
    \
    \  # Bid data, find the bid item with the same item number
    \  ${bid}=  Look up related bid data  ${bid_data}  ${item["item_number"]}
    \
    \  # Verify bid data
    \  ${cell}=  Get table cell  xpath:${table_xpath}  ${row+1}  ${BID_ITEM_TIME_COL}
    \  Should be equal as numbers  ${cell}                       ${bid["bid_delivery_time"]}
    \
    \  ${cell}=  Get table cell  xpath:${table_xpath}  ${row+1}  ${BID_ITEM_PRICE_COL}
    \  Should be equal   ${cell}                       ${bid["bid_unit_price"]}
    \
    \  ${cell}=  Get table cell  xpath:${table_xpath}  ${row+1}  ${BID_ITEM_TOTAL_COL}
    \  Should be equal   ${cell}                       ${bid["bid_total_price"]}
    \
    \  ${cell}=  Get table cell  xpath:${table_xpath}  ${row+1}  ${BID_ITEM_CURRENCY_COL}
    \  Should be equal           ${cell}                         ${bid["bid_currency"]}
    \
    \  ${cell}=  Get table cell  xpath:${table_xpath}  ${row+1}  ${BID_ITEM_REMARKS_COL}
    \  Should be equal           ${cell}                         ${bid["bid_remarks"]}


Look up related bid data
    [Tags]          local
    [Arguments]     ${bid_data}  ${item_num}

    : FOR  ${bid}  IN  @{bid_data}
    \  Return from keyword if  $bid["item_number"] == $item_num  ${bid}

    [Return]  ERROR: Bid not found!


I can upload this CSV file and these document files to this RFQ:
    [Tags]          local
    [Arguments]     ${bid_csv_file}  ${comm_docs_file}  ${tech_docs_file}  ${rfq_name}

    Run Keyword  Find this RFQ in the table and select it:  ${rfq_name}

    # Click the Submit Bid tab
    Click link  Submitted Bid
    Wait until page contains   Submit New Bid

    CLick link  Submit New Bid
    Wait until page contains   Submit Your Bid

    Choose file   name:rfq_bid[item_prices_attachment]        ${bid_csv_file}
    Choose file   name:rfq_bid_commercial_docs[attachment][]  ${comm_docs_file}
    Choose file   name:rfq_bid_technical_docs[attachment][]   ${tech_docs_file}
    Click button  class:qa-submit-bid-btn

    Wait until element is visible   class=alert-success  timeout=60
    Wait until page contains   Successfully created bid


Create temporary CSV bid file
    [Tags]          local
    [Arguments]     ${bid_test_data}  ${bid_csv_file}

    # 'Create bid CSV' is a python script in "Python_methods.py"
    ${result}=  Create bid CSV  ${bid_csv_file}  ${RFQ_ITEM_LIST}  ${bid_test_data}  ${BID_HEADER}
    Should contain  ${result}  DONE


Remove bid CSV files
    [Tags]          local
    [Arguments]     ${bid_csv_file}

    Remove file  ${bid_csv_file}
