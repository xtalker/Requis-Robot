*** Settings ***
# Resource file with RFQ related keywords used in multiple files

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Common_Keywords.robot
Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/Email_Keywords.robot

# RFQ related test data
Variables       ${EXECDIR}/All_Supply_Chain_Tests/Project_Test_Data/RFQ_Related/RFQ_test_data.yaml


*** Variables ***

# Test data dir
${RFQ_DATA_DIR}     ${EXECDIR}/All_Supply_Chain_Tests/Project_Test_Data/RFQ_Related

# RFQ table column indexes
${RFQ_NAME_COL}=        2
${RFQ_ACTIONS_COL}=     8

# Make sure to add (review, award) when these steps are implemented!
@{ALL_PROCESS_STEPS}  team  docs  vendors  approve  send  wait
@{VALID_STEP_TESTS}   done  undone


*** Keywords ***

Find this RFQ in the table and select it:
    [Tags]          RFQ_support
    [Arguments]     ${rfq_name}

    ${row}  ${col} =  Find string in table  ${rfq_name}  Couldn't find ${rfq_name} in table
    ${rfq_name_xpath} =  Set variable  //tbody/tr[${row}]/td[${RFQ_NAME_COL}]
    Set focus to element  xpath: ${rfq_name_xpath}
    Click link  xpath:${rfq_name_xpath}//a
    Wait until page contains  ${rfq_name}


I can verify that the timeline shows only these steps as completed:
    [Documentation]  Verifies that the passed timeline steps show as done, all others show as undone
    [Tags]          RFQ_support
    [Arguments]     @{steps}

    # "none" indicates that all steps should be incomplete
    Run keyword if  "none" in $steps
    \  ...  I can verify all progress steps are in this state:  'done'
    \  ...  Return from keyword

    # "all" indicates that all steps should be complete
    Run keyword if  "all" in $steps
    \  ...  I can verify all progress steps are in this state:  'undone'
    \  ...  Return from keyword

    #  Check each process step
    : FOR  ${step}  IN  @{ALL_PROCESS_STEPS}
    \
    \  # Test if progress step is completed or not
    \  Run keyword if  $step in $steps
    \  ...    Page should contain element  class:qa-${step}-done
    \  ...      message=Expected progress step: ${step} to be done
    \  ...  ELSE
    \  ...    Page should contain element  class:qa-${step}-undone
    \  ...      message=Expected progress step: ${step} to be undone


I can verify the progress timeline steps are all in this state:
    [Documentation]  Verifies that all progress timeline steps are in this state ("done" or "undone")
    [Tags]          RFQ_support
    [Arguments]     ${state}

    # Validate the passed state test
    Should contain  ${VALID_STEP_TESTS}  ${state}  msg=${state} not valid, only ${VALID_STEP_TESTS}

    : FOR  ${step}  IN  @{ALL_PROCESS_STEPS}
    \
    \  Run keyword if  $state == "done"
    \  ...  Page should contain element  class:qa-${step}-done
    \  ...    message=Expected progress step ${step} to be complete
    \
    \  Run keyword if  $state == "undone"
    \  ...  Page should contain element  class:qa-${step}-undone
    \  ...    message=Expected progress step ${step} to be not complete


