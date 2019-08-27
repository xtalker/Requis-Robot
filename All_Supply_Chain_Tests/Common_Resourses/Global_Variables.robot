*** Settings ***
# Resource file with global variables


*** Variables ***

# System related
${DATABASE_NAME}          requis_rails_qa
${DATABASE_USER}          bsteinbeiser

# Browser related
${THIS_BROWSER}           firefox     # Can be overridden by command line option
${THIS_URL}               http://localhost:5000
${BROWSER_WINDOW_HEIGHT}  1200
${BROWSER_WINDOW_WIDTH}   1280
${SELENIUM_SPEED}         0.0 seconds  # 0.2 here makes it easy to watch (takes about 3x longer)

# File locations
${DYN_TEST_DATA_FILE}     ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Dynamic_Test_Data.py
${ASSET_TEMPLATE_FILE}    ${EXECDIR}/All_Supply_Chain_Tests/Project_Test_Data/asset_test_data_template.yaml
${ASSET_DATA_FILE}        ${EXECDIR}/All_Supply_Chain_Tests/Project_Test_Data/unique_asset_test_data.yaml

# User related
${USER_SIGNOUT_TIME}       240
${CURRENT_LOGGED_IN_USER}  ${NONE}

#                           (from admin_test_data.yaml)
${GLOBAL_ADMIN_USER}        ${global_admin_username}
${GLOBAL_ADMIN_PASSWORD}    ${global_admin_passwd}

# ${ADMIN_NAME}               ${company_1.admin.name}
# ${ADMIN_PASSWD}             ${company_1.admin.password}
# ${USER1_NAME}               ${company_1.user1_name}
# ${USER1_PASSWD}             ${company_1.user1_password}
# ${USER2_NAME}               ${company_1.user2_name}
# ${USER2_PASSWD}             ${company_1.user2_password}
# ${USER3_NAME}               ${company_1.user3_name}
# ${USER3_PASSWD}             ${company_1.user3_password}
# ${USER4_NAME}               ${company_1.user4_name}
# ${USER4_PASSWD}             ${company_1.user4_password}

${ADMIN_NAME}               ${company_1.admin.name}
${ADMIN_PASSWD}             ${company_1.admin.password}

${USER1_NAME}               ${company_1.user1.name}
${USER1_PASSWD}             ${company_1.user1.password}

${USER2_NAME}               ${company_1.user2.name}
${USER2_PASSWD}             ${company_1.user2.password}

${USER3_NAME}               ${company_1.user3.name}
${USER3_PASSWD}             ${company_1.user3.password}

${USER4_NAME}               ${company_1.user4.name}
${USER4_PASSWD}             ${company_1.user4.password}

${BUYER_COMPANY}            ${company_microsoft.base_company_name}
${BUYER_USER_NAME}          ${company_microsoft.user2_name}
${BUYER_USER_EMAIL}         ${company_microsoft.user2_email}
${BUYER_PASSWD}             ${company_microsoft.user2_password}

${SELLER_COMPANY}           ${company_apple.base_company_name}
${SELLER_USER_NAME}         ${company_apple.user1_name}
${SELLER_USER_EMAIL}        ${company_apple.user1_email}
${SELLER_PASSWD}            ${company_apple.user1_password}
