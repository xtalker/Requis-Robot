*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Common_Keywords.robot
Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Email_Keywords.robot
Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Invoice_Keywords.robot

# Asset related test data
Variables       ${EXECDIR}/All_Supply_Chain_Tests/Project_Test_Data/unique_asset_test_data.yaml

Suite Setup     Open browser and start
Suite Teardown  Close All Browsers

#Force Tags      critical


*** Variables ***

${single_asset}=        ${asset_group3[0]}
${sale_index}=          ${NONE}

# Column indexs for asset table
${asset_quan_col}=           2
${buy_now_col}=              7

# Column indexs for package table
${packages_actions_col}=     6


*** Test Cases ***

# Forcing banking info removed 5/30/19, https://github.com/RequisDev/requis/pull/279
# Verify that bank info is required before a buyer can buy an asset

#     Given I'm a buyer logged in as:  ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
#     When I'm At The Marketplace - Search Page
#     Then I can see the 'Buy Now' button on this asset is:  ${single_asset["name"]}  NOT_VISIBLE
#     And I can add my banking info for this company:  ${company_microsoft}
#     Then I can see the 'Buy Now' button on this asset is:  ${single_asset["name"]}  VISIBLE


Purchase a package with 'Buy Now'
    [Setup]  Delete Emails

    Given I'm a buyer logged in as:  ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    When I'm at the Requis Marketplace - Packages page
    And Delete all notifications
    Then I can 'Buy Now' the package of assets named:  Asset Group 1-${UNIQUE_ID}

    # Modify this test until "Completed Purchases" screen shows the asset/package name again
    # and I can see the completion screen for the purchase of the package named:  Asset Group 1-${UNIQUE_ID}
    and I can see the transaction record for the purchase of the package named:  ${asset_group1}
    ...  4  ${BUYER_COMPANY}  ${UNIQUE_COMPANY}  Buy now

    and Verify that this notification exists:  ${company1.user1.name} provided purchase invoice
    and Verify invoiced package matches associated asset group:  ${asset_group1}

    and I can see that this package is no longer listed:  Asset Group 1-${UNIQUE_ID}
    and The seller receives an emailed notification of the sale:  Buy now received on one of your listings
    ...  ${UNIQUE_USER1}  ${Email_user}
    #and The buyer gets a notification that an invoice has been sent

    # Work-around until "Completed Purchases" screen shows the asset/package name again
    # and I see an invoice for the sale of this package:
    # ...  ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}  Buy now  Asset Group 1-${UNIQUE_ID}  ${UNIQUE_USER1}
    # ...  ${asset_group1}  ${sale_index}


Purchase an individual asset with 'Buy Now'
    [Setup]  Delete Emails

    Given I'm a buyer logged in as:  ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}
    When I'm at the Requis Marketplace - Asset Records page
    And Delete all notifications
    Then I can 'Buy Now' an individual asset:  ${single_asset["name"]}  2

    and I can see the transaction record for the purchase of the asset named:  ${single_asset["name"]}
    ...  2  ${BUYER_COMPANY}  ${UNIQUE_COMPANY}  Buy now

    and Verify that this notification exists:  ${company1.user1.name} provided purchase invoice
    and I can see that this asset quantity has decreased:  ${single_asset["name"]}  2

    and The seller receives an emailed notification of the sale:  Buy now received on one of your listings
    ...  ${UNIQUE_USER1}  ${Email_user}

    # Work-around until "Completed Purchases" screen shows the asset/package name again
    and I see an invoice for the sale of this asset:
    ...  ${BUYER_USER_EMAIL}  ${BUYER_PASSWD}  Buy now  ${single_asset}  2  ${UNIQUE_USER1}  ${sale_index}


*** Keywords ***

I can add my banking info for this company:
    [Documentation]  Add banking info when buying or making offers
    [Tags]          local
    [Arguments]     ${company}

    Click element  class:qa-bank-info-btn
    Wait until page contains  Bank Details

    Input text  name:company[banking_account_number]  ${company.bank_account}
    Input text  name:company[banking_routing_number]  ${company.bank_routing}

    Click element  class:qa-send-bank-info-btn
    Wait until element is visible   class=alert-success
    Page should contain  Bank info Updated

    Run keyword  I'm at the Requis Marketplace - Asset Records page


I can see the 'Buy Now' button on this asset is:
    [Documentation]  Check for "Buy Now" or "Add banking info" when buying or making offers
    [Tags]          local
    [Arguments]     ${asset_name}  ${type}

    # Search for this asset
    ${count}=  Search for assets/packages with this keyword:  ${asset_name}
    Should be true  ${count}  msg=Couldn't find "${asset_name}" in the search results
    #Click link  ${asset_name}
    #Wait Until Keyword Succeeds  10s  3s  Select window  NEW
    #Wait until page contains  Product Details:

    Run keyword if  $type == 'VISIBLE'      Page should contain element  class:qa-buy-now-btn

    Run keyword if  $type == 'NOT_VISIBLE'  Page should not contain element  class:qa-buy-now-btn
    Run keyword if  $type == 'NOT_VISIBLE'  Page should contain element  class:qa-bank-info-btn


The seller receives an emailed notification of the sale:
    [Documentation]  Verify an emailed offer notification
    [Arguments]     ${subject}  ${receiver}  ${sender}
    [Tags]          local

   ${links}  Run keyword  Wait for latest email with this subject, to this user, get link:
   ...  ${subject}  ${receiver}

   ${sales_link}=  Get matches  ${links}  *sales
   Should Contain    ${sales_link}  ${ROOT_URL}/sales


I can 'Buy Now' the package of assets named:
    [Documentation]  Find this package and click 'Buy Now'
    [Arguments]     ${package_name}
    [Tags]          local

    # Search for this package
    ${count}=  Search for assets/packages with this keyword:  ${package_name}  package
    Should be true  ${count}  msg=Couldn't find "${package_name}" in the search results

    Run keyword  Add banking info if required

    # Click the 'Buy Now' button
    Click element  class:qa-buy-now-btn

    # Verify the purchase confirmation screen
    Wait until page contains  Buy Package Now
    Page should contain   Package Name:
    Page should contain   ${package_name}

    # Click 'Accept shipping' check and the 'Confirm Buy Now' button
    Click element  class:buyer-shipping-confirmation
    Click element  name:commit

    Wait until element is visible   class=alert-success
    Page should contain  Successful Purchase of Package ${package_name}!

    Wait until page contains  Transaction Record


I can 'Buy Now' an individual asset:
    [Documentation]  Find this asset and click 'Buy Now'
    [Arguments]     ${asset_name}  ${quantity}
    [Tags]          local

    # Search for this asset
    ${count}=  Search for assets/packages with this keyword:  ${asset_name}
    Should be true  ${count}  msg=Couldn't find "${asset_name}" in the search results

    Run keyword  Add banking info if required

    # Capture the initial quantity
    ${quantity_text}=  get text  class:qa-quan-txt
    ${initial_asset_quantity}  Fetch from right  ${quantity_text}  ${SPACE}
    Set suite variable  ${initial_asset_quantity}

    # Verify the 'Freight Calculator' is available
    Page should contain element  class:qa-calc-freight-btn  message=Can't find the freight calculator!
    Click element  class:qa-calc-freight-btn
    Wait until element is visible  class:qa-close-calc-btn

    Sleep  2 s  # Obscured by div class="modal-backdrop fade?"
    Click button  class:qa-close-calc-btn
    Sleep  2 s  # Obscured by div class="modal-backdrop fade?"

    # Buy Now window
    Click element  class:qa-buy-now-btn
    Wait until page contains  Buy Now:
    Page should contain   ${asset_name}

    # Set the quantity to buy to 1
    Input text  id:quantity_to_buy  ${quantity}
    Set focus to element  name:commit
    Click element  name:commit

    # This alert is missing (Bug# 141)
    # Wait until element is visible   class=alert-success
    # Page should contain  Successful Purchase of Asset ${asset_name}!

    Wait until page contains  Transaction Record  timeout=60  error=Buy Now took too long


I can see the transaction record for the purchase of the asset named:
    [Documentation]  Verify the sales completion screen for a single asset
    [Arguments]     ${asset_name}  ${quan}  ${buyer_co}  ${seller_co}  ${method}
    [Tags]          local

    Page should contain  Transaction Record

    ${info_xpath}=  Set variable  //table[contains(@class,'qa-sale-table')]/tbody
    Element should contain  xpath:${info_xpath}//td[contains(@class,'qa-sale-buyer')]   ${buyer_co}
    Element should contain  xpath:${info_xpath}//td[contains(@class,'qa-sale-seller')]  ${seller_co}
    Element should contain  xpath:${info_xpath}//td[contains(@class,'qa-sale-method')]  ${method}

    ${item_xpath}=  Set variable  //table[contains(@class,'qa-item-table')]/tbody
    Element should contain  xpath:${item_xpath}//td[contains(@class,'qa-item-descr')]  ${asset_name}
    Element should contain  xpath:${item_xpath}//td[contains(@class,'qa-item-quan')]   ${quan}

    # Get sale index from invoice link and save it
    ${invoice_link}=  get element attribute  xpath://a[contains(@class,'qa-invoice-btn')]  attribute=href
    ${index}=  Evaluate  re.search(r'\/\([0-9]+\)', '''${invoice_link}''').group(1)  re
    Set global variable  ${sale_index}  ${index}


I can see that this package is no longer listed:
    [Documentation]  Verify this package is no longer listed
    [Arguments]     ${package_name}
    [Tags]          local

    Go to   ${ROOT URL}/search
    Wait until page contains  Search Results
    Search for assets/packages with this keyword:  ${package_name}  not_listed


Package is no longer Listed

    # Find the table row with this package
    ${row}  ${col} =  Locate table string  ${package_name}
    Run keyword if  $row != $None  capture page screenshot
    Should be equal  ${row}  ${None}  msg='${package_name}' was found in table, expected it to be sold!


I can see the transaction record for the purchase of the package named:
    [Documentation]  Verify the completed purchase
    [Arguments]     ${asset_group}  ${quan}  ${buyer_co}  ${seller_co}  ${method}
    [Tags]          local

    Page should contain  Transaction Record

    ${info_xpath}=  Set variable  //table[contains(@class,'qa-sale-table')]/tbody
    Element should contain  xpath:${info_xpath}//td[contains(@class,'qa-sale-buyer')]   ${buyer_co}
    Element should contain  xpath:${info_xpath}//td[contains(@class,'qa-sale-seller')]  ${seller_co}
    Element should contain  xpath:${info_xpath}//td[contains(@class,'qa-sale-method')]  ${method}

    # Verify the line items matches the asset group
    ${item_xpath}=  Set variable  //table[contains(@class,'qa-item-table')]/tbody
    : FOR   ${asset}  IN  @{asset_group}
    # Find the row with this asset in the table
    \  ${row}  ${col}=  Find string in table  ${asset["name"]}
    \    ...  ${asset["name"]} not found in invoice  ${item_xpath}
    \
    \  Element should contain  xpath:${item_xpath}//tr[${row+1}]/td[contains(@class,'qa-item-descr')]
    \    ...  ${asset["name"]}
    \
    \  ${quan}=  Convert to string  ${asset["quantity"]}
    \  Element should contain  xpath:${item_xpath}//tr[${row+1}]/td[contains(@class,'qa-item-quan')]
    \    ...  ${quan}

    # Go to the invoice
    Click element  class:qa-invoice-btn
    Wait until page contains  Reference number:

    # Get sale index from the URL and save it
    # ${url}=  Get location
    # ${index}=  Evaluate  re.search(r'\/\([0-9]+\)', '''${url}''').group(1)  re
    # Set global variable  ${sale_index}  ${index}


I can see that this asset quantity has decreased:
    [Documentation]  Verify the listing for a single asset has decremented
    [Arguments]     ${asset_name}  ${quantity}
    [Tags]          local

    Go to   ${ROOT URL}/search
    Wait until page contains  Search Results
    Search for assets/packages with this keyword:  ${asset_name}

    # Compare the new quantity to the initial
    ${details}=  get text  xpath://h2[contains(text(),'Product Details')]/following-sibling::div
    ${new_asset_quantity}=  Evaluate  re.search(r'Quantity: \([0-9]+\)', '''${details}''').group(1)  re

    #${new_asset_quantity}=  get text  xpath://tbody/tr[${row}]/td[${asset_quan_col}]
    ${calc_quatity}=  Evaluate  ${initial_asset_quantity}-${quantity}
    Should be true   ${calc_quatity} == ${new_asset_quantity}
    ...  msg=Asset quantity mismatch, expected: ${calc_quatity}, got: ${new_asset_quantity}

