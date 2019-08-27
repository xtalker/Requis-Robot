*** Settings ***

Resource        ${EXECDIR}/All_Supply_Chain_Tests/Common_Resourses/RFQ_Support.robot

Suite Setup     If no previous failure, open the browser and start
Suite Teardown  Close All Browsers

#Force Tags      skip

*** Variables ***

# Dirs and Files
${RFQ_DATA_DIR}     ${EXECDIR}/All_Supply_Chain_Tests/Project_Test_Data/RFQ_Related
${RFQ_DOC_LIST_CSV}  ${RFQ_DATA_DIR}/RFQ_additional_docs/Test-document-list.csv
${RFQ_ITEMS_CSV}    ${RFQ_DATA_DIR}/RFQ_additional_docs/RFQ_items.csv
${RFQ_DOCS_CSV}     ${RFQ_DATA_DIR}/RFQ_additional_docs/RFQ_documents.csv
${TEST_ZIP_DOC}     ${RFQ_DATA_DIR}/RFQ_additional_docs/Test-document-1.zip
${TEST_DOC_DOC}     ${RFQ_DATA_DIR}/RFQ_additional_docs/Test-document-2.doc
${TEST_DOCX_DOC}    ${RFQ_DATA_DIR}/RFQ_additional_docs/Test-document-3.docx
${TEST_PDF_DOC}     ${RFQ_DATA_DIR}/RFQ_additional_docs/Test-document-4.pdf
${TEST_JPG_DOC}     ${RFQ_DATA_DIR}/RFQ_additional_docs/Test-document-5.jpg

# CSV Headers
${ITEMS_HEADER}=    Item Number,Commodity / Tag,Description,Total Qty,Unit,Delivery Site
${DOCS_HEADER}=     Document / Attachment No,Document / Attachment Title,Document Rev,Applies To Items,Link

# Materials list table column indexes
${DELIV_ITEM_COL}=      1
${DELIV_TAG_COL}=       2
${DELIV_DESC_COL}=      3
${DELIV_QUAN_COL}=      4
${DELIV_UNIT_COL}=      5
${DELIV_SITE_COL}=      6
${DELIV_ACTIONS_COL}=   7

# Commercial documents column indexes
${DOC_NUMBER_COL}=      1
${DOC_TITLE_COL}=       2
${DOC_REV_COL}=         3
${DOC_LINK_COL}=        4
${DOC_ACTIONS_COL}=     5

# Technical documents column indexes
${TECH_NUMBER_COL}=      1
${TECH_TITLE_COL}=       2
${TECH_REV_COL}=         3
${TECH_APPLIES-TO_COL}=  4
${TECH_LINK_COL}=        5
${TECH_ACTIONS_COL}=     6

*** Test Cases ***

Upload and view a material items list to an RFQ
    [Setup]     Create a temporary CSV file from test data  ${RFQ_ITEMS_CSV}  ${ITEMS_HEADER}  ${RFQ_ITEM_LIST}
    [Teardown]  Remove file   ${RFQ_ITEMS_CSV}

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can upload this CSV file type to this RFQ:  materials  ${RFQ_ITEM_LIST}  ${RFQ_ITEMS_CSV}
    ...  ${RFQ_1.rfq_name}
    and I can view and verify the uploaded materials lists:  ${RFQ_ITEM_LIST}
    and I can verify that the timeline shows only these steps as completed:  team  docs


Upload and view a commercial document list to an RFQ
    [Setup]     Create a temporary CSV file from test data  ${RFQ_DOCS_CSV}  ${DOCS_HEADER}  ${RFQ_COMMERCIAL_DOCUMENT_LIST}
    [Teardown]  Remove file   ${RFQ_DOCS_CSV}

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can upload this CSV file type to this RFQ:  documents  ${RFQ_COMMERCIAL_DOCUMENT_LIST}
    ...  ${RFQ_DOCS_CSV}  ${RFQ_1['rfq_name']}
    and I can view and verify the uploaded commercial documents:  ${RFQ_COMMERCIAL_DOCUMENT_LIST}


Upload and view a technical document list to an RFQ
    [Setup]     Create a temporary CSV file from test data  ${RFQ_DOCS_CSV}  ${DOCS_HEADER}  ${RFQ_TECH_DOCUMENT_LIST}
    [Teardown]  Remove file   ${RFQ_DOCS_CSV}

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can upload this CSV file type to this RFQ:  technical  ${RFQ_TECH_DOCUMENT_LIST}  ${RFQ_DOCS_CSV}  ${RFQ_1['rfq_name']}
    and I can view and verify the uploaded technical documents:  ${RFQ_TECH_DOCUMENT_LIST}


Delete a deliverable item from the materials list of an RFQ

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can delete this item from the materials list for this RFQ:  ${RFQ_1['rfq_name']}  ${RFQ_ITEM_LIST[0]['description']}


Delete a commercial document from the list for this RFQ

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can delete this commercial document from the list for this RFQ:  ${RFQ_1.rfq_name}
    ...  ${RFQ_COMMERCIAL_DOCUMENT_LIST[0]['title']}


Delete a technical document for this RFQ

    Given I'm logged in as  ${UNIQUE_ADMIN}  ${ADMIN_PASSWD}
    When I'm at the Buy - RFQs page
    Then I can delete this technical document from the list for this RFQ:  ${RFQ_1.rfq_name}
    ...  ${RFQ_TECH_DOCUMENT_LIST[1]['title']}


*** Keywords ***

I can delete the data requirements checklist for this RFQ:
    [Documentation]  Delete this document from the "Additional Docs" list
    [Tags]          local
    [Arguments]     ${rfq_name}  ${doc_name}

    Run keyword  Find this RFQ, select this tab, find this document, delete and verify:
    ...  ${rfq_name}  Data Requirements  ${doc_name}


I can delete this technical document from the list for this RFQ:
    [Documentation]  Delete this document from the "Additional Docs" list
    [Tags]          local
    [Arguments]     ${rfq_name}  ${doc_name}

    Run keyword  Find this RFQ, select this tab, find this document, delete and verify:
    ...  ${rfq_name}  Technical Documents  ${doc_name}


I can delete this item from the materials list for this RFQ:
    [Documentation]  Delete this item from the materials list
    [Tags]          local
    [Arguments]     ${rfq_name}  ${item_name}

    Run keyword  Find this RFQ, select this tab, find this document, delete and verify:
    ...  ${rfq_name}  Materials Lists  ${item_name}


I can delete this commercial document from the list for this RFQ:
    [Documentation]  Delete this item from the materials list
    [Tags]          local
    [Arguments]     ${rfq_name}  ${doc_name}

    Run keyword  Find this RFQ, select this tab, find this document, delete and verify:
    ...  ${rfq_name}  Commercial Documents  ${doc_name}


Find this RFQ, select this tab, find this document, delete and verify:
    [Tags]          local
    [Arguments]     ${rfq_name}  ${tab_name}  ${doc_name}

    Run Keyword  Find this RFQ in the table and select it:  ${rfq_name}

    Click link  ${tab_name}

    Run keyword if  $tab_name == 'Materials Lists'  Run keywords
    ...  Wait until page contains  Deliverable Items
    ...  AND  Set suite variable  ${table_id}  qa-items-table

    Run keyword if  $tab_name == 'Technical Documents'  Run keywords
    ...  Wait until page contains  Upload Technical Documents
    ...  AND  Set suite variable  ${table_id}  qa-technical-docs-table

    Run keyword if  $tab_name == 'Commercial Documents'  Run keywords
    ...  Wait until page contains  Commercial Documents & Attachments
    ...  AND  Set suite variable  ${table_id}  qa-commercial-docs-table

    ${table_anchor}=  Set Variable  //table[contains(@class,\'${table_id}\')]
    ${row}  ${col} =  Find string in table  ${doc_name}  anchor=${table_anchor}  error_msg=Couldn't find ${doc_name} in table

    # Click the delete link
    Click element  xpath=${table_anchor}//tbody/tr[${row}]//a/i[contains(@class,'fa-trash')]

    # Verify sucess alert popup
    Wait until element is visible   class=alert-success
    Run keyword if  $tab_name == 'Materials Lists'       Page should contain
    ...  Item successfully deleted.
    Run keyword if  $tab_name == 'Commercial Documents'  Page should contain
    ...  Document successfully deleted.
    Run keyword if  $tab_name == 'Technical Documents'   Page should contain
    ...  Document successfully deleted.

    # Verify the doc is gone
    Page should not contain   ${doc_name}


I can view and verify the uploaded technical documents:
    [Documentation]  Verify the uploaded supporting documents list
    [Tags]          local
    [Arguments]     ${doc_list}

    Click link  Technical Documents
    Wait until page contains  Technical Documents

    ${table_anchor}=  Set Variable  //table[contains(@class,'qa-technical-docs-table')]

    # For each item record in the test data, compare with row data
    : FOR   ${doc}  IN  @{doc_list}
    \  # Find the row in the table with this doc
    \  ${row}  ${col} =  Find string in table  ${doc['title']}  anchor=${table_anchor}  error_msg=Couldn't find ${doc['title']} in table
    \  # Verify each column in this row
    \  ${row_anchor}=  Set variable  ${table_anchor}//tbody/tr[${row}]
    \  ${txt}=  Get text  ${row_anchor}/td[${TECH_NUMBER_COL}]
    \  Should be equal as strings  ${txt}  ${doc['number']}
    \  ${txt}=  Get text  ${row_anchor}/td[${TECH_TITLE_COL}]
    \  Should be equal as strings  ${txt}  ${doc['title']}
    \  ${txt}=  Get text  ${row_anchor}/td[${TECH_REV_COL}]
    \  Should be equal as strings  ${txt}  ${doc['revision']}
    \  ${txt}=  Get text  ${row_anchor}/td[${TECH_APPLIES-TO_COL}]
    \  Should be equal as strings  ${txt}  ${doc['applies_to_items']}


I can view and verify the uploaded commercial documents:
    [Documentation]  Verify the uploaded supporting documents list
    [Tags]          local
    [Arguments]     ${doc_list}

    Click link  Commercial Documents
    Wait until page contains  Commercial Documents & Attachments

    ${table_anchor}=  Set Variable  //table[contains(@class,'qa-commercial-docs-table')]

    # For each item record in the test data, compare with row data
    : FOR   ${doc}  IN  @{doc_list}
    \  # Find the row in the table with this doc
    \  ${row}  ${col} =  Find string in table  ${doc['title']}  anchor=${table_anchor}  error_msg=Couldn't find ${doc['title']} in table
    \  # Verify each column in this row
    \  ${row_anchor}=  Set variable  ${table_anchor}//tbody/tr[${row}]
    \  ${txt}=  Get text  ${row_anchor}/td[${DOC_NUMBER_COL}]
    \  Should be equal as strings  ${txt}  ${doc['number']}
    \  ${txt}=  Get text  ${row_anchor}/td[${DOC_TITLE_COL}]
    \  Should be equal as strings  ${txt}  ${doc['title']}
    \  ${txt}=  Get text  ${row_anchor}/td[${DOC_REV_COL}]
    \  Should be equal as strings  ${txt}  ${doc['revision']}
    # Not sure how to verify uploaded images yet?
    #\  ${txt}=  get element attribute   xpath=${row_anchor}/td[${DOC_LINK_COL}]/a  href
    #\  Should be equal as strings  ${txt}  ${doc['link']}


I can view and verify the uploaded materials lists:
    [Documentation]  Verify the uploaded items list
    [Tags]          local
    [Arguments]     ${item_list}

    ${table_anchor}=  Set Variable  //table[contains(@class,'qa-items-table')]

    # For each item record in the test data, compare with row data
    : FOR   ${item}  IN  @{item_list}
    \  # Find the row in the table with this item
    \  ${row}  ${col} =  Find string in table  ${item['description']}  anchor=${table_anchor}  error_msg=Couldn't find ${item['description']} in table
    \  # Verify each column in this row
    \  ${row_anchor}=  Set variable  ${table_anchor}//tbody/tr[${row}]
    \  ${txt}=  Get text  ${row_anchor}/td[${DELIV_ITEM_COL}]
    \  Should be equal as strings  ${txt}  ${item['item_number']}
    \  ${txt}=  Get text  ${row_anchor}/td[${DELIV_TAG_COL}]
    \  Should be equal as strings  ${txt}  ${item['commodity-tag']}
    \  ${txt}=  Get text  ${row_anchor}/td[${DELIV_DESC_COL}]
    \  Should be equal as strings  ${txt}  ${item['description']}
    \  ${txt}=  Get text  ${row_anchor}/td[${DELIV_QUAN_COL}]
    \  Should be equal as strings  ${txt}  ${item['quantity']}
    \  ${txt}=  Get text  ${row_anchor}/td[${DELIV_UNIT_COL}]
    \  Should be equal as strings  ${txt}  ${item['unit']}
    \  ${txt}=  Get text  ${row_anchor}/td[${DELIV_SITE_COL}]
    \  Should be equal as strings  ${txt}  ${item['delivery_site']}


I can upload this CSV file type to this RFQ:
    [Documentation]  Upload this items list CSV to this RFQ
    [Tags]          local
    [Arguments]     ${file_type}  ${test_data}  ${items_csv_file}  ${rfq_name}

    Run Keyword  Find this RFQ in the table and select it:  ${rfq_name}

    # Materials List Upload
    Run keyword if  $file_type == 'materials'  Click link  Materials Lists
    Run keyword if  $file_type == 'materials'  Click link  Upload Materials List
    Run keyword if  $file_type == 'materials'  Wait until page contains  Upload Materials List

    # Documents List Upload
    Run keyword if  $file_type == 'documents'  Click link  Commercial Documents
    Run keyword if  $file_type == 'documents'  Click link  Upload Commercial Documents
    Run keyword if  $file_type == 'documents'  Wait until page contains  Download the RFQ Commercial Documents Template

    # Documents List Upload
    Run keyword if  $file_type == 'technical'  Click link  Technical Documents
    Run keyword if  $file_type == 'technical'  Click link  Upload Technical Documents
    Run keyword if  $file_type == 'technical'  Wait until page contains  Download the RFQ Technical Documents Template

    Click element  class:qa-upload-btn
    Choose file   id:attachment   ${items_csv_file}

    ${count}=  Get length  ${test_data}
    Wait until page contains  Bulk CSV Upload
    Click element  class:qa-upload-now-btn
    Wait until element is visible   class=alert-success  timeout=60

    # Verify success and count
    Run keyword if  $file_type == 'materials'  Wait until page contains
    ...  Successfully imported ${count} Deliverable Items
    Run keyword if  $file_type == 'documents'  Wait until page contains
    ...  Successfully imported ${count} Commercial Documents
    Run keyword if  $file_type == 'technical'  Wait until page contains
    ...  Successfully imported ${count} Technical Documents


Create a temporary CSV file from test data
    [Tags]          local
    [Arguments]     ${csv_file}  ${header}  @{test_data_group}

    # 'Create CSV' is a python script in "Python_methods.py"
    ${result} =     run keyword   Create CSV  ${csv_file}  @{test_data_group}  ${header}
    Should contain  ${result}  DONE

