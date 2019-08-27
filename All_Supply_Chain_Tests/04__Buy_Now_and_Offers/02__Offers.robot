*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Common_Keywords.robot
Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Email_Keywords.robot
Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Invoice_Keywords.robot

Library         String
Library         Collections

# Asset related test data
Variables       ${EXECDIR}/All_Supply_Chain_Tests/Project_Test_Data/unique_asset_test_data.yaml

Suite Setup     Open browser and start
Suite Teardown  Close All Browsers

#Force Tags      critical


*** Variables ***

${initial_package_quans}     none
${final_package_quans}       none
${single_asset_name}=        ${asset_group3[0]["name"]}

# Table column indexs
${asset_name_col}=           1
${asset_make_offer_col}=     8

${package_name_col}=         1
${package_make_offer_col}=   6

${pending_status_col}=       1
${pending_price_col}=        4
${pending_seller_col}=       5

${offers_status_col}=        1
${offers_price_col}=         3

${custom_offer_quan_col}=    1

${package_asset_name_col}=   3
${package_asset_quan_col}=   4


*** Test Cases ***

Make an offer on a package that is then rejected
    [Setup]     Delete Emails

    Given I'm a buyer logged in as:   ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    When I'm at the Requis Marketplace - Packages page
    Then I can make an offer on the package:  Asset Group 2-${UNIQUE_ID}  1000

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Offers - Received page and click this tab:  pending-offers-tab
    Then I receive an emailed notification of the offer status:  Offer received on one of your listings
      ...  ${UNIQUE_USER1}  offers
      and I can see and reject the offer for this asset or package:  Asset Group 2-${UNIQUE_ID}  $1,000.00

    Given I'm a buyer logged in as:   ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    When I'm at the Offers - Made page and click this tab:  rejected-offers-tab
    Then I receive an emailed notification of the offer status:  Your offer has been rejected
     ...  ${BUYER_USER_EMAIL}  offers?view_state=made
      and I can verify that the offer for this asset or package was rejected:  Asset Group 2-${UNIQUE_ID}  $1,000.00


Make an offer on an asset that is then rejected
    [Setup]  Delete Emails

    Given I'm a buyer logged in as:   ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    #When I'm at the Sell - Buy Asset Records page
    When I'm at the Marketplace - Search page
    Then I can make an offer on this asset:  ${single_asset_name}  1000  1

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Offers - Received page and click this tab:  pending-offers-tab
    Then I receive an emailed notification of the offer status:   Offer received on one of your listings
      ...  ${UNIQUE_USER1}  offers
      and I can see and reject the offer for this asset or package:  ${single_asset_name}  1,000.00

    Given I'm a buyer logged in as:   ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    When I'm at the Offers - Made page and click this tab:  rejected-offers-tab
    Then I receive an emailed notification of the offer status:  Your offer has been rejected
     ...  ${BUYER_USER_EMAIL}  offers?view_state=made
      and I can verify that the offer for this asset or package was rejected:  ${single_asset_name}  1,000.00


Make an offer on a package that is then accepted
    [Setup]     Delete Emails

    Given I'm a buyer logged in as:   ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    When I'm at the Requis Marketplace - Packages page
    Then I can make an offer on the package:  Asset Group 2-${UNIQUE_ID}  2000

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Offers - Received page and click this tab:  pending-offers-tab
    Then I receive an emailed notification of the offer status:   Offer received on one of your listings
      ...  ${UNIQUE_USER1}  offers
      and I can see and accept the offer for this asset or package:  Asset Group 2-${UNIQUE_ID}  $2,000.00

    Given I'm a buyer logged in as:   ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    When I'm at the Offers - Made page and click this tab:  accepted-offers-tab
    Then I receive an emailed notification of the offer status:  Purchase Invoice #3
    ...  ${BUYER_USER_EMAIL}
      and I can verify that the offer for this asset or package was accepted:  Asset Group 2-${UNIQUE_ID}  $2,000.00
      # Issue# 66
      # Remove this test until "Completed Purchases" screen shows the asset/package name again
      #  and I see an invoice for the sale of this package:
      # ...  ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}  Buy now  Asset Group 2-${UNIQUE_ID}  ${UNIQUE_USER1}  ${asset_group2}


Make on offer on an asset that is then accepted
    [Setup]  Delete Emails

    Given I'm a buyer logged in as:   ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    When I'm at the Marketplace - Search page
    Then I can make an offer on this asset:  ${single_asset_name}  2000  1

    Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
    When I'm at the Offers - Received page and click this tab:  pending-offers-tab
    Then I receive an emailed notification of the offer status:   Offer received on one of your listings
      ...  ${UNIQUE_USER1}    offers
      and I can see and accept the offer for this asset or package:  ${single_asset_name}  2,000.00

    Given I'm a buyer logged in as:   ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    When I'm at the Offers - Made page and click this tab:  accepted-offers-tab
    Then I receive an emailed notification of the offer status:  Purchase Invoice #4
    ...  ${BUYER_USER_EMAIL}
      and I can verify that the offer for this asset or package was accepted:  ${single_asset_name}  2,000.00

      # Remove this test until "Completed Purchases" screen shows the asset/package name again
      # The below will enable test scripting, but this is a huge usability issue IMO!
      # After purchase, store the sales rec# from the url, this is the transaction record (/sales/5/receipt)
      # Use that to ref the invoice: (/sales/5/invoice) receipt: (/sales/5/receipt) checklist: (/sales/5/checklist)
      # also: Issue# 66
      # and I see an invoice for the sale of this asset:
      # ...  ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}  Buy now  ${single_asset_name}  2  ${UNIQUE_USER1}

# No more custom offers per Derek 5/22/19
#
# Make a custom offer on a package
#     [Setup]  Run Keywords  Delete Emails  AND
#     ...  I Record asset quantities in a package:  initial  Asset Group 4-${UNIQUE_ID}

#     Given I'm a buyer logged in as:   ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
#     When I'm at the Requis Marketplace - Packages page
#     Then I can make a custom offer on this package:  Asset Group 4-${UNIQUE_ID}
#       and The custom offer includes:   ${asset_group4[0]["name"]}  1
#       and The custom offer includes:   ${asset_group4[2]["name"]}  2
#       and I submit this custom offer for:  25

#     Given I'm a seller logged in as:  ${UNIQUE_USER1}  ${USER1_PASSWD}
#     When I'm at the Offers - Received page and click this tab:  pending-offers-tab
#     Then I receive an emailed notification of the offer status:   Offer received on one of your listings
#      ...  ${UNIQUE_USER1}    offers
#       and I can see and accept the offer for this asset or package:  Custom Offer  25.00

#     Given I'm a buyer logged in as:   ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
#     When I'm at the Offers - Made page and click this tab:  accepted-offers-tab
#     Then I receive an emailed notification of the offer status:  Purchase Invoice #5
#    ...  ${BUYER_USER_EMAIL}
#       and I can verify that the offer for this asset or package was accepted:  Custom Offer  $25.00
#       and I Record asset quantities in a package:  final  Asset Group 4-${UNIQUE_ID}
#       and I verify the quantities have been adjusted for this asset:  ${asset_group4[0]["name"]}  1
#       and I verify the quantities have been adjusted for this asset:  ${asset_group4[2]["name"]}  2


*** Keywords ***

I receive an emailed notification of the offer status:
    [Arguments]     ${subject}  ${receiver}  ${link}=none
    [Tags]          local

    ${email_links}  Run keyword  Wait for latest email with this subject, to this user, get link:
    ...  ${subject}  ${receiver}

    Run keyword if  $link != 'none'  Should contain match  ${email_links}  ${ROOT_URL}/${link}


I can verify that the offer for this asset or package was rejected:
    [Documentation]  Added for verbal test case clarity
    [Arguments]     ${item_name}  ${offer_price}
    [Tags]          local

    Run Keyword  Verify the offer status for this asset or package:  ${item_name}  ${offer_price}  rejected


I can verify that the offer for this asset or package was accepted:
    [Documentation]  Added for verbal test case clarity
    [Arguments]     ${item_name}  ${offer_price}
    [Tags]          local

    Run Keyword  Verify the offer status for this asset or package:  ${item_name}  ${offer_price}  accepted


I can see and reject the offer for this asset or package:
    [Documentation]  Added for verbal test case clarity
    [Arguments]     ${item_name}  ${offer_price}
    [Tags]          local

    Run Keyword  Verify pending offer then accept or reject it:  ${item_name}  ${offer_price}  reject


I can see and accept the offer for this asset or package:
    [Documentation]  Added for verbal test case clarity
    [Arguments]     ${item_name}  ${offer_price}
    [Tags]          local

    Run Keyword  Verify pending offer then accept or reject it:  ${item_name}  ${offer_price}  accept


I verify the quantities have been adjusted for this asset:
    [Documentation]  Verify initial vs. final quantities for this asset
    [Arguments]     ${asset_name}  ${quantity_sold}
    [Tags]          local

    ${initial_quan}=  Get from dictionary  ${initial_package_quans}  ${asset_name}
    ${final_quan}=    Get from dictionary  ${final_package_quans}    ${asset_name}
    Should be true    ${final_quan}  == ${initial_quan} - ${quantity_sold}


I can make an offer on the package:
    [Documentation]  Find this package and offer this price
    [Arguments]     ${package_name}  ${offer_price}
    [Tags]          local

    # Search for this package
    ${count}=  Search for assets/packages with this keyword:  ${package_name}  package
    Should be true  ${count}  msg=Couldn't find "${package_name}" in the search results

    Run keyword  Add banking info if required

    # Enter an offer price and click the 'Make Offer' button
    Input text  class:qa-make-offer-amount  ${offer_price}
    Click element  class:qa-make-offer-btn

    # Verify the offer confirmation screen
    Wait until page contains  Offers Made
    Page should contain  ${package_name}


I can make an offer on this asset:
    [Documentation]  Make an offer on this asset
    [Arguments]     ${asset_name}  ${offer_price}  ${offer_quan}
    [Tags]          local

    # Search for this asset
    ${count}=  Search for assets/packages with this keyword:  ${asset_name}  asset_record
    Should be true  ${count}  msg=Couldn't find "${asset_name}" in the search results

    Run keyword  Add banking info if required

    # Make Offer
    Input text  id:quantity  ${offer_quan}
    ${offer_price}=  Remove string  ${offer_price}  $
    Input text  id:made_offer_amount    ${offer_price}

    Set focus to element  class:qa-make-offer-btn
    Click element  class:qa-make-offer-btn
    Wait Until Page Contains Element  class:alert-success
    Page should contain  Success! Offer created


Verify the offer status for this asset or package:
    [Documentation]  Verify the offer has been rejected for this package
    [Arguments]     ${item_name}  ${offer_price}  ${action}
    [Tags]          local

    # Find the row with this package in the 'Offers' table
    ${table_anchor}=  Set variable  //div[@id=\"${action}-offers\"]

    # Wait until table is populated with this item
    Wait until page contains   ${item_name}

    # Fails intermittently even though the above passes?
    ${row}  ${col}=  Find string in table  ${item_name}
    ...  ${item_name} not found ${action} table  anchor=${table_anchor}

    # Verify the offer status
    ${action}  Evaluate  "${action}".title()  # Capitalize the action name
    ${status_xpath}=  Set variable  ${table_anchor}//tbody/tr[${row}]/td[${offers_status_col}]
    Element should contain  xpath:${status_xpath}  ${action}

    # Verify the offer price
    ${price_xpath} =  Set variable  ${table_anchor}//tbody/tr[${row}]/td[${offers_price_col}]
    Element should contain  xpath:${price_xpath}  ${offer_price}


I'm at the Offers - Received page and click this tab:
    [Documentation]  Navigate to this page and click this tab
    [Arguments]     ${tab_name}
    [Tags]          local

    Go to   ${ROOT URL}/offers
    Wait until page contains  Offers Received
    Click element  id:${tab_name}


I'm at the Offers - Made page and click this tab:
    [Documentation]  Navigate to this page and click this tab
    [Arguments]     ${tab_name}
    [Tags]          local

    Go to   ${ROOT URL}/offers?view_state=made
    Wait until page contains  Offers Made
    Click element  id:${tab_name}


Verify pending offer then accept or reject it:
    [Documentation]  Accept or Reject the offer on this asset or package
    [Arguments]     ${item_name}  ${offer_price}  ${action}
    [Tags]          local

    # Find the row with this package in the 'Pending Offers' table
    ${table_anchor}=  Set variable  //div[@id=\"pending-offers\"]
    ${row}  ${col} =  Find string in table  ${item_name}
    ...  ${item_name} not found in pending-offers table  anchor=${table_anchor}

    # Verify the seller, company name
    ${seller_xpath} =  Set variable  ${table_anchor}//tbody/tr[${row}]/td[${pending_seller_col}]
    Element should contain  xpath:${seller_xpath}  ${BUYER_USER_EMAIL}
    Element should contain  xpath:${seller_xpath}  ${BUYER_COMPANY}

    # Verify the offer price
    ${price_xpath} =  Set variable  ${table_anchor}//tbody/tr[${row}]/td[${pending_price_col}]
    #${offer_price}=  Replace String   ${offer_price}  $  USD${SPACE}
    Element should contain  xpath:${price_xpath}  ${offer_price}

    # Hit the reject or accpet button
    Click element  class:qa-${action}-offer-btn
    Handle alert  action=ACCEPT


# I Record asset quantities in a package:
#     [Documentation]  Record the quantities of each asset in a package
#     [Arguments]     ${type}  ${package_name}
#     [Tags]          local

#     I'm a buyer logged in as:   ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
#     I'm at the Requis Marketplace - Packages page

#     # Get counts of package assets
#     # Search for this package
#     ${count}=  Search for assets/packages with this keyword:  ${package_name}  package
#     Wait until page contains  Assets in Package

#     # Get asset quantities from the table and save them in a list
#     ${row_count}=  Run Keyword  Get element count  xpath://tr
#     ${asset_quans}  Create dictionary

#     : FOR  ${row}  IN RANGE  2  ${row_count}+1
#     \  ${quan}=   Get table cell  class:table  ${row}  ${package_asset_quan_col}
#     \  ${asset}=  Get table cell  class:table  ${row}  ${package_asset_name_col}
#     \  Set to dictionary  ${asset_quans}  ${asset}  ${quan}

#     Run keyword if  '${type}'=='initial'  Set global variable  ${initial_package_quans}  ${asset_quans}
#     Run keyword if  '${type}'=='final'    Set global variable  ${final_package_quans}    ${asset_quans}


# I submit this custom offer for:
#    [Documentation]  Submit a custom offer after all the asset quantities have been set
#    [Arguments]   ${offer_amount}
#    [Tags]        local

#     Input text  name:custom_offer[amount]  ${offer_amount}
#     Click element  class:qa-custom-offer-btn

#     Wait Until Page Contains Element  class:alert-success
#     Wait until page contains  Success! Offer created

#     # Verify the offer confirmation screen
#     Wait until page contains  Offers Made
#     Page should contain  Custom Offer


# The custom offer includes:
#    [Documentation]  Set an asset quantity for a custom offer
#    [Arguments]   ${asset_name}  ${quantity}
#    [Tags]        local

#     # Find the row with this asset in the asset table
#     ${row}  ${col} =  Find string in table  ${asset_name}  ${asset_name} not found in asset table
#     Should not be equal  ${row}  ${None}  msg='${asset_name}' not found in asset table

#     ${set_quantity_xpath} =  Set variable  //tbody/tr[${row}]/td[${custom_offer_quan_col}]/input
#     Set focus to element  xpath:${set_quantity_xpath}
#     Input text  xpath:${set_quantity_xpath}  ${quantity}


# I can make a custom offer on this package:
#     [Documentation]  Find this package and make a custom offer
#     [Arguments]     ${package_name}
#     [Tags]          local

#     # Search for this package
#     ${count}=  Search for assets/packages with this keyword:  ${package_name}  package
#     Should be true  ${count}  msg=Couldn't find "${package_name}" in the search results

#     # Find the table row with this package in the table
#     #${row}  ${col} =  Find string in table  ${package_name}  Package ${package_name} not found in table

#     # Enter an offer price and click the 'Custom Offer' button
#     #${make_offer_xpath} =  Set variable  //tbody/tr[${row}]/td[${package_make_offer_col}]/a[2]
#     #Set focus to element  xpath:${make_offer_xpath}
#     Click element  xpath:${make_offer_xpath}
#     Wait until page contains  Viewing Assets in Package

#     Click element  class:qa-custom-offer-btn
#     Wait until page contains  Make Custom Offer


