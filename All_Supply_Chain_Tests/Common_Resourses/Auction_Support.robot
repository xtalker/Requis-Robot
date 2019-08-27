# Support resources and variables for auction tests
*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Common_Keywords.robot
Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Email_Keywords.robot
Variables       ${EXECDIR}/All_Supply_Chain_Tests/Project_Test_Data/unique_asset_test_data.yaml


*** Variables ***

# Auctionable Items
${ASSET1}            ${asset_group5[0]}
${PACKAGE1}          Asset Group 6-${UNIQUE_ID}
${AUCTION_ITEM_ID}  none

# Users, etc.
${SENDER}              ${Email_user}
${SELLER}              ${UNIQUE_USER1}
${Apple_buyer}         ${company_apple.user2_email}
${Apple_buyer_PASSWD}  ${company_apple.user2_password}
${MS_buyer}            ${company_microsoft.user2_email}
${MS_buyer_PASSWD}     ${company_microsoft.user2_password}

# Buyer bid record table columns
${BUYER_NAME_COL}          1
${BUYER_COUNTRY_COL}       2
${BUYER_END_TIME_COL}      3
${BUYER_STATUS_COL}        4
${BUYER_HIGH_BIDDER_COL}   7
${BUYER_ACTION_COL}        8

# Seller bid record table columns
${SELLER_BID_COUNT_COL}    3
${SELLER_HIGH_BID_COL}     5
${SELLER_HIGH_BIDDER_COL}  6
${SELLER_END_TIME_COL}     7
${SELLER_STATUS_COL}       8
${SELLER_RESERVE_COL}      9
${SELLER_ACTIONS_COL}      10

# Lots table columns
${LOT_SELECT_COL}          1
${LOT_NAME_COL}            2

# Auction table columns
${AUCTION_NAME_COL}        1


*** Keywords ***

I can accept the highest bid for this auction:
    [Tags]          local
    [Arguments]     ${item_name}  ${winning_bid}

    Go to  ${ROOT_URL}/sell/bids
    Wait until page contains  Bids Received Summary

    # Find this item in the table
    ${row}  ${col} =  Find string in table  ${item_name}  Couldn't find ${item_name} in table

    Table cell should contain  xpath://table  ${row+1}  ${SELLER_HIGH_BID_COL}  ${winning_bid}
    Table cell should contain  xpath://table  ${row+1}  ${SELLER_STATUS_COL}    Ended
    Table cell should contain  xpath://table  ${row+1}  ${SELLER_ACTIONS_COL}   ACCEPT HIGHEST BID
    Click link  xpath://table/tbody/tr[${row}]/td[${SELLER_ACTIONS_COL}]/a

    ${message}=  Handle alert  action=LEAVE
    Should contain  ${message}  Confirm your agreement to sell
    Should contain  ${message}  ${item_name}
    Handle alert  action=ACCEPT

    Wait until element is visible   class=alert-success
    Page should contain  Success! Accepted highest bid of

    Table cell should contain  xpath://table  ${row+1}  ${SELLER_ACTIONS_COL}  Asset is sold


I can see the auction has ended and I can no longer bid
    [Tags]          local

    Reload page
    Page should contain  This auction has ended.
    Page should not contain  Place Bid


The auction for this item ends with this time offset:
    [Tags]          local
    [Arguments]     ${item_name}  ${date_offset}  ${type}=asset_record

    # Get/save the item id
    Search for assets/packages with this keyword:  ${item_name}  ${type}
    ${url}=  Get location
    ${item_id}  Fetch from right  ${url}  /
    Set suite variable  ${AUCTION_ITEM_ID}  ${item_id}
    # Make sure the auction id is set
    Should not be equal as strings  ${AUCTION_ITEM_ID}  none  msg=Auction id not set (${AUCTION_ITEM_ID})

    # Change the `due_date` field for this auction in the DB to be past due
    ${time}=  Get the date and time  UTC  ${date_offset}
    ${result}=  Update a field in the database  ${DATABASE_NAME}  ${DATABASE_USER}  auctions
    ...  end_datetime  '${time}'  auctionable_id=${AUCTION_ITEM_ID}
    Should be equal as strings  ${result.rc}  0  msg=There was a problem forcing the auction to end


I can verify that the current bid data for this item:
    [Tags]          local
    [Arguments]     ${item_name}  ${high_bidder}

    Go to  ${ROOT_URL}/procure/requis_marketplace/asset_records/bids
    Wait until page contains  Current Bid Summary

    # Find this item in the table
    ${row}  ${col} =  Find string in table  ${item_name}  Couldn't find ${item_name} in table
    ${row}=  Set variable  ${row+1}
    ${status_xpath}=  Set variable  //tr[${row-1}]/td[${BUYER_HIGH_BIDDER_COL}]

    # Set the xpath for the highest bidder status
    ${bid_status}=  Set variable if  $high_bidder == 'Yes'
    ...  ${status_xpath}/i[contains(@class,'fa-check')]  # High bidder (green check)
    ...  ${status_xpath}/i[contains(@class,'fa-times')]  # Not high bidder (red X)

    # Verify highest bidder status
    Element should be visible  xpath:${bid_status}


I can place this bid on this item and see this alert:
    [Tags]          local
    [Arguments]     ${item_name}  ${bid_amount}  ${alert_mesg}  ${type}=asset_record

    # Make sure we're on the item record detail page
    Run keyword if  $type == 'asset_record'
    ...    Wait until page contains  Product Details:
    ...  ELSE
    ...    Wait until page contains  Assets in Package:

    # Save the id of this item
    ${url}=  Get location
    ${item_id}  Fetch from right  ${url}  /
    Set suite variable  ${AUCTION_ITEM_ID}  ${item_id}

    Run keyword  Add banking info if required

    # Verify current bid count

    # Place a bid
    Input text  class:qa-bid-amount-input  ${bid_amount}
    Click button  class:qa-place-bid-btn
    Wait until page contains  ${alert_mesg}

    # Increment the bid count for this item


# I can add/verify these lots to this auction
#     [Tags]          local
#     [Arguments]     ${lot1_name}  ${lot2_name}  ${auction_name}

#     # Add lots to auction
#     Run keyword  Find this lot in the table and select it:  ${lot1_name}
#     Run keyword  Find this lot in the table and select it:  ${lot2_name}
#     Click element  class:qa-actions-btn
#     Wait until page contains  Add to Auction

#     Select from list by label  name:bulk_edit_auction_id  ${auction_name}
#     Click element  class:qa-update-btn
#     Wait until element is visible   class=alert-success
#     Page should contain  Lot added to auction

#     # Verify the auction now contains these lots
#     Run keyword  I'm at the Sell - Manage Auctions page
#     Find this auction or lot in the table and select it:  ${auction_name}  auction
#     Page should contain  ${lot1_name}
#     Page should contain  ${lot2_name}



# Find this lot in the table and select it:
#     [Tags]          local
#     [Arguments]     ${name}

#     ${row}  ${col} =  Find string in table  ${name}  Couldn't find lot: ${name} in table

#     ${select_xpath} =  Set variable  //tbody/tr[${row}]/td[${LOT_SELECT_COL}]
#     Set focus to element  xpath: ${select_xpath}
#     Click element  xpath:${select_xpath}//input



# Find this auction or lot in the table and select it:
#     [Tags]          local
#     [Arguments]     ${name}  ${type}

#     ${row}  ${col} =  Find string in table  ${name}  Couldn't find auction/lot: ${name} in table

#     ${column}=  Set variable if
#     ...  $type == 'auction'  ${AUCTION_NAME_COL}
#     ...  $type == 'lot'     ${LOT_NAME_COL}

#     ${name_xpath} =  Set variable  //tbody/tr[${row}]/td[${column}]
#     Set focus to element  xpath: ${name_xpath}
#     Click link  xpath:${name_xpath}//a

#     Run keyword if  $type == 'auction'  Wait until page contains  Auction Details
#     #Run keyword if  $name == 'lot'      Wait until page contains  Lot Details

#     Page should contain  ${name}

