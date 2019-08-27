*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/RFQ_Support.robot

Suite Setup     If no previous failure, open the browser and start
Suite Teardown  Close All Browsers

#Force Tags      skip


*** Variables ***

# RFQ name for these tests
${test_RFQ_name}=         ${RFQ_1["rfq_name"]}

# Bid response table column indexes
${BID_RESPONSE_COL}        5
${BID_COMPLIANT_COL}       6
${BID_ACTIONS_COL}         8

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

# Bidders
${bidder_2}         ${company_microsoft["admin_user"]}
${bidder_2_passwd}  ${company_microsoft["admin_password"]}
${bidder_1}         ${company_apple["admin_user"]}
${bidder_1_passwd}  ${company_apple["admin_password"]}

${item_test_data}            ${RFQ_ITEM_LIST}
${response_table_xpath}      //table[contains(@class,'qa-bid-response-table')]
${itemized_bid_table_xpath}  //table[contains(@class,'qa-itemized-bid-table')]
${non-compliant_remark}      We are so sorry but your RFQ is totally non-complaint


*** Test Cases ***

Review and compare bids after RFQ due date

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then Change the due date of this RFQ to past due  ${test_RFQ_name}  - 1 day
    Then I can verify that this vendor submitted this bid for this RFQ:  ${bidder_1}
        ...  ${RFQ_BID_1}  ${test_RFQ_name}
    And I can verify that this vendor submitted this bid for this RFQ:  ${bidder_2}
        ...  ${RFQ_BID_2}  ${test_RFQ_name}
    And I can verify that this vendor is in the comparison chart for this RFQ:  ${company_apple}      ${test_RFQ_name}
    And I can verify that this vendor is in the comparison chart for this RFQ:  ${company_microsoft}  ${test_RFQ_name}
    Then Find this RFQ in the table and select it:  ${test_RFQ_name}
    And I can verify that the timeline shows only these steps as completed:
    ...  team  docs  vendors  approve  send  wait


Review a bid and reject it as non-compliant
    [Setup]  Delete Emails

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can mark this bidder's bid for this RFQ as non-compliant  ${bidder_1}
      ...  ${test_RFQ_name}  ${non-compliant_remark}
    And I can verify that the non-compliant bidder is notified  ${bidder_1}  ${bidder_1_passwd}  ${test_RFQ_name}


*** Keywords ***

I can verify that the non-compliant bidder is notified
    [Tags]          local
    [Arguments]     ${bidder_email}  ${bidder_password}  ${bid_name}

    ${details}=  Get latest email details for this recipient:  ${bidder_ email}

    # Subject should be:
    Should match  ${details[0]}  Your Bid has been marked Non-Compliant

    # Message body should contain:
    Should contain  ${details[2]}  ${non-compliant_remark}
    Should contain  ${details[2]}  ${UNIQUE_COMPANY}

    # Check for a user notification
    Run keyword  I'm logged in as  ${bidder_email}  ${bidder_password}
    Run keyword  Verify that this notification exists:  Someone marked bid as non-compliant


I can mark this bidder's bid for this RFQ as non-compliant
    [Tags]          local
    [Arguments]     ${bidder}  ${rfq_name}  ${remarks}

    Run Keyword  Find this RFQ in the table and select it:  ${rfq_name}

    # Click the Bids tab
    Click link  Bids
    Wait until page contains   Compare RFQ Bids

    # Find this bidder in the table and then view/verify response
    ${row}  ${col} =  Find string in table  ${bidder}  Couldn't find ${bidder} in the bids table
    ...  anchor=${response_table_xpath}
    ${bidder_row_xpath} =  Set variable  ${response_table_xpath}/tbody/tr[${row}]
    Set focus to element  xpath: ${bidder_row_xpath}

    # Click the non-compliant link for this bidder
    Click link  xpath:${bidder_row_xpath}/td[${BID_ACTIONS_COL}]/a
    Wait until page contains  Mark as Non-Compliant

    Input text  class:qa-remarks-txt  ${remarks}
    Click element  class:qa-non-compliant-btn

    Wait Until Page Contains Element  class:alert-success  timeout=60
    Page should contain  Successfully notified vendor that the bid is non-compliant

    # Verify that this bid now shows as non-compliant in the bid table
    ${cell}=  Get table cell  xpath:${response_table_xpath}  ${row+1}  ${BID_COMPLIANT_COL}
    Should be equal  ${cell}  Non-Compliant


I can verify that this vendor is in the comparison chart for this RFQ:
    [Tags]          local
    [Arguments]     ${company}  ${rfq_name}

    Run Keyword  Find this RFQ in the table and select it:  ${rfq_name}

    # Click the Bids tab
    Click link  Bids
    Wait until page contains   Compare RFQ Bids
    Click link  Compare RFQ Bids
    Wait until page contains   Compare Bids

    Page should contain  ${company_apple["base_company_name"]}
    Page should contain  ${company_apple["admin_user"]}

    # Go back to the RFQ page
    Run keyword  I'm at the Buy - RFQs page


Change the due date of this RFQ to past due
    [Tags]          local
    [Arguments]     ${rfq_name}  ${date_offset}

    Run keyword  I'm at the Buy - RFQs page
    Run Keyword  Find this RFQ in the table and select it:  ${rfq_name}

    # Save the id of this rfq
    ${url}=  Get location
    ${rfq_id}  Fetch from right  ${url}  /

    # Can't see bid response until after due date.
    # Change the `due_date` field for this RFQ in the DB to be past due
    ${time}=  Get the date and time  UTC  ${date_offset}
    ${result}=  Update a field in the database  ${DATABASE_NAME}  ${DATABASE_USER}  rfqs
    ...  due_date  '${time}'  id=${rfq_id}
    Should be equal as strings  ${result.rc}  0

    Run keyword  I'm at the Buy - RFQs page


I can verify that this vendor submitted this bid for this RFQ:
    [Tags]          local
    [Arguments]     ${bidder}  ${bid}  ${rfq_name}

    Run Keyword  Find this RFQ in the table and select it:  ${rfq_name}

    # Click the Bids tab
    Click link  Bids
    Wait until page contains   Compare RFQ Bids

    # Find this bidder in the table and then view/verify response
    ${row}  ${col} =  Find string in table  ${bidder}  Couldn't find ${bidder} in the bids table
    ...  anchor=${response_table_xpath}
    ${bidder_row_xpath} =  Set variable  ${response_table_xpath}/tbody/tr[${row}]
    Set focus to element  xpath: ${bidder_row_xpath}

    Click link  xpath:${bidder_row_xpath}/td[${BID_RESPONSE_COL}]/a
    Wait until page contains  Itemized Bid
    Run keyword  I can view and verify the itemized data for this bid response:  ${bid}

    # Go back to the RFQ page
    Run keyword  I'm at the Buy - RFQs page


I can view and verify the itemized data for this bid response:
    [Tags]          local
    [Arguments]     ${bid_data}

    # Verify the bid items table
    ${table_xpath}=  Set variable  //table[contains(@class,'qa-itemized-bid-table')]

    # Find each item in test data in the "Itemized Prices" list
    : FOR  ${item}  IN  @{item_test_data}
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
    \  ${temp}=  Remove string  ${bid["bid_unit_price"]}  $  ,
    \  Should contain  ${temp}  ${cell}
    \
    \  ${cell}=  Get table cell  xpath:${table_xpath}  ${row+1}  ${BID_ITEM_TOTAL_COL}
    \  ${temp}=  Remove string  ${bid["bid_total_price"]}  $  ,
    \  Should contain  ${temp}  ${cell}
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

