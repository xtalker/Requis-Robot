*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Auction_Support.robot

Suite Setup     Open browser and start
Suite Teardown  Close All Browsers

Force Tags      skip


*** Variables ***

# See Common_Resourses/Auction_Support.robot

*** Test Cases ***

The Apple_buyer bids less than the starting bid on a package

    Given I'm a buyer logged in as:  ${Apple_buyer}  ${Apple_buyer_PASSWD}
    Then Search for assets/packages with this keyword:  ${PACKAGE1}  package
    And I can place this bid on this item and see this alert:  ${PACKAGE1}
    ...  1  Bid must be higher than starting bid  package


The Apple_buyer places a valid bid on a package
    [Setup]  Delete Emails

    Given I'm a buyer logged in as:  ${Apple_buyer}  ${Apple_buyer_PASSWD}
    Then Search for assets/packages with this keyword:  ${PACKAGE1}  package
    And I can place this bid on this item and see this alert:  ${PACKAGE1}
    ...  10000  Success! You are the highest bidder  package
    And Verify an email notification:  New bid placed on ${PACKAGE1}.  ${SELLER}  ${SENDER}  sell/bids

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    Then Verify that this notification exists:  Someone placed a bid on ${PACKAGE1}


The MS_buyer places a redundant bid on a package

    Given I'm a buyer logged in as:  ${MS_buyer}  ${MS_buyer_PASSWD}
    Then Search for assets/packages with this keyword:  ${PACKAGE1}  package
    And I can place this bid on this item and see this alert:  ${PACKAGE1}
    ...  10000  Bid must be higher than current bid  package


The MS_buyer places a valid bid on a package
    [Setup]  Delete Emails

    Given I'm a buyer logged in as:  ${MS_buyer}  ${MS_buyer_PASSWD}
    Then Search for assets/packages with this keyword:  ${PACKAGE1}  package
    And I can place this bid on this item and see this alert:  ${PACKAGE1}
    ...  10001  Success! You are the highest bidder  package
    And Verify an email notification:  New bid placed on ${PACKAGE1}  ${SELLER}  ${SENDER}  sell/bids
    And Verify an email notification:  You have been outbid on ${PACKAGE1}!  ${Apple_buyer}  ${SENDER}
    ...  procure/asset_records/${AUCTION_ITEM_ID}

    Given I'm a buyer logged in as:  ${Apple_buyer}  ${Apple_buyer_PASSWD}
    Then Verify that this notification exists:  Someone outbid you on ${PACKAGE1}

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    Then Verify that this notification exists:  Someone placed a bid on ${PACKAGE1}


The buyers can see the bid history for this package

    Given I'm a buyer logged in as:  ${Apple_buyer}  ${Apple_buyer_PASSWD}
    Then I can verify that the current bid data for this item:  ${PACKAGE1}  No

    Given I'm a buyer logged in as:  ${MS_buyer}  ${MS_buyer_PASSWD}
    Then I can verify that the current bid data for this item:  ${PACKAGE1}  Yes


The auction ends and buyers can no longer bid on this package

    Given I'm a buyer logged in as:  ${Apple_buyer}  ${Apple_buyer_PASSWD}
    And The auction for this item ends with this time offset:  ${PACKAGE1}  - 1 min  package
    #And Search for assets/packages with this keyword:  ${PACKAGE1}
    Then I can see the auction has ended and I can no longer bid


The seller can accept the highest bid for this package, buyers gets email notifications
    [Setup]  Delete Emails

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    Then I can accept the highest bid for this auction:  ${PACKAGE1}  USD 10,001.00
    And Verify that this notification exists:  Someone won an item you were auctioning: ${PACKAGE1}
    And Verify an email notification:  You have been outbid on an Auction that has ended
    ...  ${Apple_buyer}  ${SENDER}
    And Verify an email notification:  You have won the Auction on ${PACKAGE1}!  ${MS_buyer}
    ...  ${SENDER}  sales?view_state=purchases

    Given I'm a buyer logged in as:  ${Apple_buyer}  ${Apple_buyer_PASSWD}
    Then Verify that this notification exists:  ended the auction you were outbid on

    Given I'm a buyer logged in as:  ${MS_buyer}  ${MS_buyer_PASSWD}
    Then Verify that this notification exists:  ended the auction you were bidding on, you had the winning bid


The package is no longer listed

    Given I'm a buyer logged in as:  ${Apple_buyer}  ${Apple_buyer_PASSWD}
    Go to  ${ROOT_URL}/procure/asset_records/${AUCTION_ITEM_ID}
    Wait until page contains  Asset is no longer Listed


# The buyer can see this auction in his Completed Puchases list (/sales?view_state=purchases)
# The buyer can see the transaction record for this completed auction
# The buyer can see the invoice for this completed auction (with link from trans. record)
# The seller can see this auction in the 'completed sales' list


*** Keywords ***

# See Common_Resourses/Auction_Support.robot
