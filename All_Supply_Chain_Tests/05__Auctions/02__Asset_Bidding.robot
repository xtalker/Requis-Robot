*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Auction_Support.robot

Suite Setup     Open browser and start
Suite Teardown  Close All Browsers

Force Tags      skip


*** Variables ***

# See Common_Resourses/Auction_Support.robot

*** Test Cases ***

The Apple_buyer bids less than the starting bid on an asset

    Given I'm a buyer logged in as:  ${Apple_buyer}  ${Apple_buyer_PASSWD}
    Then Search for assets/packages with this keyword:  ${ASSET1['name']}
    And I can place this bid on this item and see this alert:  ${ASSET1['name']}
    ...  1  Bid must be higher than starting bid


The Apple_buyer places a valid bid on an asset
    [Setup]  Delete Emails

    Given I'm a buyer logged in as:  ${Apple_buyer}  ${Apple_buyer_PASSWD}
    And Delete all notifications
    Then Search for assets/packages with this keyword:  ${ASSET1['name']}
    And I can place this bid on this item and see this alert:  ${ASSET1['name']}
    ...  1000  Success! You are the highest bidder
    And Verify an email notification:  New bid placed on ${ASSET1['name']}.  ${SELLER}  ${SENDER}  sell/bids

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    Then Verify that this notification exists:  Someone placed a bid on ${ASSET1['name']}


The MS_buyer places a redundant bid on an asset

    Given I'm a buyer logged in as:  ${MS_buyer}  ${MS_buyer_PASSWD}
    Then Search for assets/packages with this keyword:  ${ASSET1['name']}
    And I can place this bid on this item and see this alert:  ${ASSET1['name']}
    ...  1000  Bid must be higher than current bid


The MS_buyer places a valid bid on an asset
    [Setup]  Delete Emails

    Given I'm a buyer logged in as:  ${MS_buyer}  ${MS_buyer_PASSWD}
    Then Search for assets/packages with this keyword:  ${ASSET1['name']}
    And I can place this bid on this item and see this alert:  ${ASSET1['name']}
    ...  1001  Success! You are the highest bidder
    And Verify an email notification:  New bid placed on ${ASSET1['name']}  ${SELLER}  ${SENDER}  sell/bids
    And Verify an email notification:  You have been outbid on ${ASSET1['name']}!  ${Apple_buyer}  ${SENDER}
    ...  procure/asset_records/${AUCTION_ITEM_ID}

    Given I'm a buyer logged in as:  ${Apple_buyer}  ${Apple_buyer_PASSWD}
    Then Verify that this notification exists:  Someone outbid you on ${ASSET1['name']}

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    Then Verify that this notification exists:  Someone placed a bid on ${ASSET1['name']}


The buyers can see the bid history for this asset

    Given I'm a buyer logged in as:  ${Apple_buyer}  ${Apple_buyer_PASSWD}
    Then I can verify that the current bid data for this item:  ${ASSET1['name']}  No

    Given I'm a buyer logged in as:  ${MS_buyer}  ${MS_buyer_PASSWD}
    Then I can verify that the current bid data for this item:  ${ASSET1['name']}  Yes


The auction ends and buyers can no longer bid on this asset

    Given I'm a buyer logged in as:  ${Apple_buyer}  ${Apple_buyer_PASSWD}
    And The auction for this item ends with this time offset:  ${ASSET1['name']}  - 1 min
    #And Search for assets/packages with this keyword:  ${ASSET1['name']}
    Then I can see the auction has ended and I can no longer bid


The seller can accept the highest bid for this asset, buyers gets email notifications
    [Setup]  Delete Emails

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    Then I can accept the highest bid for this auction:  ${ASSET1['name']}  USD 1,001.00
    And Verify that this notification exists:  Someone won an item you were auctioning: ${ASSET1['name']}
    And Verify an email notification:  You have been outbid on an Auction that has ended
    ...  ${Apple_buyer}  ${SENDER}
    And Verify an email notification:  You have won the Auction on ${ASSET1['name']}!  ${MS_buyer}
    ...  ${SENDER}  sales?view_state=purchases

    Given I'm a buyer logged in as:  ${Apple_buyer}  ${Apple_buyer_PASSWD}
    Then Verify that this notification exists:  ended the auction you were outbid on

    Given I'm a buyer logged in as:  ${MS_buyer}  ${MS_buyer_PASSWD}
    Then Verify that this notification exists:  ended the auction you were bidding on, you had the winning bid


The asset is no longer listed

    Given I'm a buyer logged in as:  ${Apple_buyer}  ${Apple_buyer_PASSWD}
    Go to  ${ROOT_URL}/procure/asset_records/${AUCTION_ITEM_ID}
    Wait until page contains  Asset is no longer Listed
    # Wait until page contains  This auction has ended


# The buyer can see this auction in his Completed Puchases list (/sales?view_state=purchases)
# The buyer can see the transaction record for this completed auction
# The buyer can see the invoice for this completed auction (with link from trans. record)
# The seller can see this auction in the 'completed sales' list


# Add marketplace lots to an auction

#     Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
#     When I'm at the Sell - Lots page
#     Then I can add/verify these lots to this auction  ${lots[0]['name']}  ${lots[1]['name']}  ${auctions[0]['name']}


*** Keywords ***

# See Common_Resourses/Auction_Support.robot
