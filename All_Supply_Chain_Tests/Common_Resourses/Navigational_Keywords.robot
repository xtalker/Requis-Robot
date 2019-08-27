*** Settings ***
# Resource file with global navigational keywords


*** Variables ***


*** Keywords ***

################################
#***** Navigation Keywords *****
################################

I'm at the Marketplace - Search page
    [Documentation]  Navigate to this page
    [Tags]          local

    Go to  ${ROOT URL}/search
    Wait until page contains  Search Results


I'm at the Sell - Upload History page
    [Documentation]  Navigate to this page
    [Tags]          local

    Go to  ${ROOT URL}/sell/bulk_uploads
    Wait until page contains  Upload History


I'm at the Procure - Auctions page
    [Tags]          navigational

    Go to  ${ROOT URL}/procure/auctions
    Wait until page contains  Available Auctions


I'm at the Sell - New Lots page
    [Tags]          navigational

    Go to  ${ROOT URL}/sell/marketplace_lots/new
    Wait until page contains  Create New Marketplace Lot


I'm at the Sell - Lots page
    [Tags]          navigational

    Go to  ${ROOT URL}/sell/marketplace_lots
    Wait until page contains  Manage Marketplace Lots


I'm at the Sell - Manage Auctions page
    [Tags]          navigational

    Go to  ${ROOT URL}/sell/auctions
    Wait until page contains  Manage Auctions


I'm at the Sell - New Auction page
    [Tags]          navigational

    Go to  ${ROOT URL}/sell/auctions/new
    Wait until element contains  tag:H3  Create New Auction

I'm at the global admin dashboard
    [Tags]          navigational

    # Open the user menu (user icon on top right)
    Click element  class:qa-current-user
    Wait until element is visible  class:qa-dashboard-menu

    # Select the user-menu
    click element  class:qa-user-ga_dashboard

    # Verify that the user-menu page text is displayed
    Wait until page contains  Global Administration


I'm at the global admin dashboard, review company registrations page
    [Documentation]  Navigate to the global admin dashboard (only avail when logged in as a global admin)
    [Tags]          navigational

    Go to  ${ROOT URL}/global_admins/dashboard
    Wait until element contains  tag:H1  Global Administration
    Click link   Registration Forms
    Wait until page contains    Review - Company Registration Forms


I'm at the Administration - Company Contacts page
    [Documentation]  Navigate to this page
    [Tags]          navigational

    Go to  ${ROOT URL}/administration/company_contacts
    Wait until page contains  's Contacts


I'm at the Buy - Projects page
    [Documentation]  Navigate to this page
    [Tags]          navigational

    Go to  ${ROOT URL}/buyer/projects
    Wait until page contains  Create a New Project


I'm at the Buy - RFQs page
    [Documentation]  Navigate to this page
    [Tags]          navigational

    Go to  ${ROOT URL}/buyer/rfqs
    Wait until page contains  Create a New RFQ


I'm at the Vendor - RFQs page
    [Documentation]  Navigate to this page
    [Tags]          navigational

    Go to  ${ROOT URL}/vendor/rfqs
    Wait until page contains  Companies Requesting Quotations from You


I'm at the Manage API keys page
    [Documentation]  Navigate to this page
    [Tags]          navigational

    Go to   ${ROOT URL}/company/api_keys
    Wait until page contains  Manage API Keys


I'm at the Requis Marketplace - Packages page
    [Documentation]  Navigate to this page
    [Tags]          navigational

    Go to   ${ROOT URL}/search?view=1
    Wait until page contains  Search Results


I'm at the Manage - Packages page
    [Documentation]  Navigate to this page
    [Tags]          navigational

    Go to  ${ROOT URL}/packages
    Wait until page contains  Manage Packages


I'm at the Sell - Asset Records page
    [Documentation]  Navigate to this page
    [Tags]          navigational

    Go to  ${ROOT URL}/sell/asset_records
    Wait until page contains  Manage Assets


I'm at the Sell - Buy Asset Records page
    [Documentation]  Navigate to this page
    [Tags]          navigational

    Go to  ${ROOT URL}/procure/requis_marketplace/asset_records
    Wait until page contains  Requis Marketplace

I'm at the Requis Marketplace - Asset Records page
    [Documentation]  Navigate to this page
    [Tags]          navigational

    Go to   ${ROOT URL}/search
    Wait until page contains  Search Results


Scroll to the top of the page
    [Documentation]  JS code to get to the top of the page, sometimes required to find elements
    [Tags]          navigational

    Execute Javascript  window.scrollTo(1,1)


Logout
    [Tags]   navigational
    [Documentation]  Log out immediately

    Go to   ${ROOT URL}/logout



