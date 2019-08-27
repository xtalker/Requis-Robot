*** Settings ***
# Resource file with invoice related keywords used in multiple files


*** Variables ***

# "Invoice" table column indexes
${inv_item_col}                  1
${inv_model_col}                 2
${inv_sku_col}                   3
${inv_quan_col}                  5

# "Purchases" order summary table column indexes
${purch_item_col}                  2
${purch_model_col}                 4
${purch_pkg_quan_col}              6
${purch_quan_col}                  6
${purch_method_col}                14
${purch_seller_col}                16

*** Keywords ***

I see an invoice for the sale of this asset:
    [Documentation]  Verify a asset invoice contains all asset info
    [Arguments]     ${user_email}  ${user_password}  ${type}  ${asset}  ${quan}  ${seller_email}  ${sale_index}
    [Tags]          invoice_keywords

    Run keyword  Log in and find the invoice for this asset/package:  ${user_email}  ${user_password}
    ...  ${type}  ${asset["name"]}  ${seller_email}  ${sale_index}

    Run keyword  Verify invoice matches associated asset:  ${asset}  ${quan}


Verify invoice matches associated asset:
    [Arguments]     ${asset}  ${quan}
    [Tags]          invoice_keywords

    ${row}  ${col}=  Find string in table  ${asset["name"]}  ${asset["name"]} not found in invoice

    Table cell should contain  xpath://table  ${row+1}  ${inv_item_col}   ${asset["name"]}
    Table cell should contain  xpath://table  ${row+1}  ${inv_model_col}  ${asset["manufacturer_model"]}
    ${sku}=  Convert to string  ${asset["manufacturer_sku"]}
    Table cell should contain  xpath://table  ${row+1}  ${inv_sku_col}    ${sku}
    Table cell should contain  xpath://table  ${row+1}  ${inv_quan_col}  ${quan}


I see an invoice for the sale of this package:
    [Documentation]  Verify a package invoice contains all items in the assoc. asset group
    [Arguments]     ${user_email}  ${user_password}  ${type}  ${package_name}  ${seller_email}
    ...  ${asset_group}  ${sale_index}
    [Tags]          invoice_keywords

    Run keyword  Log in and find the invoice for this asset/package:  ${user_email}  ${user_password}
    ...  ${type}  ${package_name}  ${seller_email}  ${sale_index}

    Run keyword  Verify invoiced package matches associated asset group:  ${asset_group}


Log in and find the invoice for this asset/package:
    [Arguments]     ${user_email}  ${user_password}  ${method}  ${asset/package_name}  ${seller_email}  ${sale_index}
    [Tags]          invoice_keywords

    I'm logged in as  ${user_email}  ${user_password}

    Go to  ${ROOT_URL}/procure/purchases
    Wait until page contains  Completed Purchases

    # Find the table row with this sale method
    ${row}  ${col}=  Find string in table  ${method}  Invoice for ${method} not found in table

    # Verify asset/package name and purchase type and seller
    Table cell should contain  xpath://table  ${row+1}  ${purch_model_col}  ${asset/package_name}
    Table cell should contain  xpath://table  ${row+1}  ${purch_method_col}  ${method}
    Table cell should contain  xpath://table  ${row+1}  ${purch_seller_col}  ${seller_email}

    # Go to the invoice
    Go to  ${ROOT_URL}/sales/${sale_index}/invoice
    Wait until page contains  Reference number: ${sale_index}


Verify invoiced package matches associated asset group:
    [Arguments]     ${asset_group}
    [Tags]          invoice_keywords

    # Verify all package items are listed on the invoice
    : FOR   ${asset}  IN  @{asset_group}
    # Find the row with this asset in the table
    \  ${row}  ${col}=  Find string in table  ${asset["name"]}  ${asset["name"]} not found in invoice
    \  Table cell should contain  xpath://table  ${row+1}  ${inv_item_col}   ${asset["name"]}
    \  Table cell should contain  xpath://table  ${row+1}  ${inv_model_col}  ${asset["manufacturer_model"]}
    \  Table cell should contain  xpath://table  ${row+1}  ${inv_sku_col}    ${asset["manufacturer_sku"]}
    \  ${quan}=  Convert to string  ${asset["quantity"]}
    \  Table cell should contain  xpath://table  ${row+1}  ${inv_quan_col}   ${quan}
