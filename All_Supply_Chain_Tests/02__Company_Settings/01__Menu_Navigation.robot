*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Common_Keywords.robot

Suite Setup     Open browser and start
Suite Teardown  Close All Browsers

#Force Tags      critical


*** Variables ***


*** Test Cases ***

Verify navigation with the 'Buy' drop-down menu
    [Setup]  I'm Logged In As  ${UNIQUE_USER1}  ${USER1_PASSWD}

    [Template]  I can navigate to this top menu that contains:

 #Top_Menu  Sub_Menu         Page_Text                       URL
     buy    Dashboard        What do you want to do today?   /buy
     buy    Marketplace      Search Results                  /search
     buy    Offers_Made      Offers Made                     /offers?view_state=made
     buy    Purchases        Purchases (0)                   /procure/purchases
     buy    Active_Auctions  Active Auctions                 /auctions
     buy    Auction_Bids     Current Bid Summary             /procure/requis_marketplace/asset_records/bids
     buy    Packages         Search Results                  /search?view=1


Verify navigation with the 'Manage' drop-down menu
    [Setup]  I'm Logged In As  ${UNIQUE_USER1}  ${USER1_PASSWD}

    [Template]  I can navigate to this top menu that contains:

   #Top_Menu   Sub_Menu             Page_Text                  URL
     manage    Dashboard            Manage Dashboard for       /manage_dashboard
     manage    Assets               Manage Assets              /sell/asset_records
     manage    Create_Single_Asset  New Asset Record           /sell/asset_records/new
     manage    Bulk_Upload          Create bulk upload         /sell/bulk_uploads/new
     manage    Packages             Manage Packages            /packages
     manage    Projects             You are not authorized     /
     manage    API_Keys             Manage API Keys            /company/api_keys


Verify navigation with the 'Sell' drop-down menu
    [Setup]  I'm Logged In As  ${UNIQUE_USER1}  ${USER1_PASSWD}

    [Template]  I can navigate to this top menu that contains:

  #Top_Menu  Sub_Menu             Page_Text                  URL
     sell    Dashboard            Seller Dashboard for       /seller_dashboard
     sell    Offers_Received      Offers Received            /offers
     sell    Sales                Sales (                    /sales
     sell    Auction_Bids         Bids Received Summary      /sell/bids


Verify navigation with the 'User' drop-down menu
    [Setup]  I'm Logged In As  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}

    [Template]  I can navigate to this user menu that contains:

    #User_Menu         Page_Text                     URL
    addresses          Manage Company Addresses      /company/addresses
    users              Company Members               /company/members
    profile            Company Info                  /company/edit
    contacts           Company Contacts              /administration/company_contacts
    faqs               Company Entity Tax ID Number  /support/faqs
    tutorials          Video Tutorials               /support/tutorials
    manage             Manage Your Profile           /profile
    settings           Profile Settings              /profile/settings


Verify navigation with the 'Global Admin User' drop-down menu
    [Setup]  Run keywords  I'm Logged In As  ${GLOBAL_ADMIN_USER}  ${GLOBAL_ADMIN_PASSWORD}
    ...  AND  I'm at the global admin dashboard

    [Template]  I can navigate to this global admin user menu that contains:

    #User_Menu           Page_Text                          URL
    Comp_Registration    Company Registration Forms         /global_admins/company_registration_forms
    All_Users            Users (                            /global_admins/users
    Companies            Companies (                        /global_admins/companies
    Sales                Sales (                            /global_admins/sales
    Offers               Offers (                           /global_admins/all_offers
    Auctions             Auctions (                         /global_admins/auctions
    Verticals            Current (                          /global_admins/verticals
    Latest_Test_Results  Supply Chain Tests Report          /global_admins/static_pages/tests/report
    KPIs                 Key Performance Indicators (KPIs)  /global_admins/kpi_dashboard
    Release_Notes        All Release Notes                  /global_admins/release_notes


*** Keywords ***

I can navigate to this global admin user menu that contains:
    [Documentation]  Navigate to this GA user menu and verify that we are there
    [Tags]          local
    [Arguments]     ${user_menu}  ${page text}  ${url}

    # Select the user-menu
    click element  class:qa-ga-${user_menu}

    # Verify that the user-menu page text is displayed
    Wait until page contains  ${page_text}

    # Verify the url
    ${this_url}=  Get location
    Should be equal  ${this_url}  ${ROOT_URL}${url}  msg=URL didn't match for '${user_menu}':

    # Return to GA menu
    Go back
    Wait until page contains  Global Administration


I can navigate to this user menu that contains:
    [Documentation]  Navigate to this user menu and verify that we are there
    [Tags]          local
    [Arguments]     ${user_menu}  ${page text}  ${url}

    # Open the user menu (user icon on top right)
    Click element  class:qa-current-user
    Wait until element is visible  class:qa-dashboard-menu

    # Select the user-menu
    click element  class:qa-user-${user_menu}

    # Verify that the user-menu page text is displayed
    Wait until page contains  ${page_text}

    # Verify the url
    ${this_url}=  Get location
    Should be equal  ${this_url}  ${ROOT_URL}${url}  msg=URL didn't match for '${user_menu}':

    # Return to home
    Go to  ${ROOT_URL}
    Wait until page contains  Total Assets per Country


I can navigate to this top menu that contains:
    [Documentation]  Navigate to this top menu and verify that we are there
    [Tags]          local
    [Arguments]     ${top_menu}  ${sub_menu}  ${page text}  ${url}

    # Select the top level menu
    Click element  class:qa-${top_menu}-dropdown

    # Select the sub-menu
    click element  class:qa-${top_menu}-${sub_menu}

    # Verify that the sub-menu page text is displayed
    Wait until page contains  ${page_text}

    # Verify the url
    ${this_url}=  Get location
    Should be equal  ${this_url}  ${ROOT_URL}${url}  msg=URL didn't match for '${sub_menu}':

    # Return to home
    Go to  ${ROOT_URL}
    Wait until page contains  Total Assets per Country

