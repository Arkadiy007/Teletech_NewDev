/**********************************************************************
Name: Batch_CheckRequestStaging_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads Check Request table data into Stage_Check_Request table.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry         11/03/2011 Created
***********************************************************************/
global class Batch_CheckRequestStaging_DataLoad implements Database.Batchable<sObject> {               
    private static final String DEFAULT_EMPTY_VALUE = 'NONE';

    // String of query for all creatable fields on Check_Request
    global String query;
   
    // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){
        String WClause = 'Stage_Status__c in (\'' + System.Label.Stage_Status_Add + '\',\'' + 
                                                    System.Label.Stage_Status_Update + '\')' +
                         'AND Approval_Indicator__c = \'Y\' ' +
                         'AND Check_Number__c = null';
        if (Test.isRunningTest()) {
            WClause = WClause + ' And Payable_To_First_Name__c = \'ZYXABC\'';
        }
        query = BuildSoqlUtil.getCreatableFieldsSOQL('Check_Request__c', WClause);
        return Database.getQueryLocator(query);
    } 

    // Handle each batch of Check_Request__c rows returned and insert corresponding records
    // into Stage_Check_Request
    global void execute(Database.BatchableContext BC, List<Check_Request__c> lstChkTable) {     
        // Initialize variables and lists
        Stage_Check_Request__c ChkStgRec;
        List<Stage_Check_Request__c> lstChkStg = new List<Stage_Check_Request__c>();    
        Map<Integer, Check_Request__c> ChkInsMap = new Map<Integer, Check_Request__c>();
        integer ins = 0;
        List<Error_Log__c> errors = new List<Error_Log__c>();
        Check_Request__c doneCheckRequest;
        List<Check_Request__c> updateCheckRequestList = new List<Check_Request__c>();
        List<Stage_Case_Detail__c> commentList = new List<Stage_Case_Detail__c>();
        Map<Id,List<Stage_Case_Detail__c>> commentMap = new Map<Id,List<Stage_Case_Detail__c>>();
        Map<Id,Stage_Case__c> checkStageCaseMap = new Map<Id,Stage_Case__c>();

        // Loop through all Check_Requests returned and classify them as adds or updates.
        for (Check_Request__c ChkAll : lstChkTable)
        {
            ChkStgRec = new Stage_Check_Request__c();

            try {
                if (ChkAll.Stage_Status__c == System.Label.Stage_Status_Add)        //ADD
                {   
                    System.debug('********** ADD: ');   
                    ChkStgRec.SFDC_Action_Code__c = System.Label.Stage_Action_Add;          
                }  
                else if (ChkAll.Stage_Status__c == System.Label.Stage_Status_Update)//UPDATE 
                { 
                    System.debug('********** UPDATE: ');
                    ChkStgRec.SFDC_Action_Code__c = System.Label.Stage_Action_Update;
                }
    
                // Create list of Stage_Case_Details from input special comment
                commentMap.put(ChkAll.Id, createStageCaseDetailList(1, ChkAll));
    
                // Set Stage_Check_Request fields from the input Check_Request
                fillChkStage(ChkStgRec, ChkAll);
                   
                // Add Stage_Check_Request record to the list to insert 
                lstChkStg.add(ChkStgRec);   
                
                // Save the input Check_Request to a numbered Map where the key of the Map is the
                // index of the Check_Reqeust in the original input.
                ChkInsMap.put(ins,ChkAll);  
                ins++;
            } catch (Exception err) {
                errors.add(new Error_Log__c(Record_ID__c = ChkAll.Id,
                                    Record_Type__c = 'Check_Request__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CheckRequestStaging_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
            }
        }
    
        // If any Stage_Check_Request rows are in the list, insert them and handle any errors.
        if (!lstChkStg.isEmpty())       //INSERT/UPDATE PROCESSED
        {   
            // Insert rows
            Database.SaveResult[] dbCStage = Database.insert(lstChkStg, false);

            // If there are any results, handle the errors
            if (!dbCStage.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < lstChkStg.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbCStage[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbCStage[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = (ChkInsMap.get(row)).Id,
                                    Record_Type__c = 'Stage_Check_Request__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CheckRequestStaging_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    } else {
                        // If the current row was successful, set its status to Done Processing.
                        doneCheckRequest = ChkInsMap.get(row);
                        doneCheckRequest.Stage_Status__c = System.Label.Stage_Status_Done;
                        List<Stage_Case_Detail__c> comments = commentMap.get((ChkInsMap.get(row)).Id);
                        commentList.addAll(comments);

                        updateCheckRequestList.add(doneCheckRequest);
                    }
                }
            }
        }

        // Get all ZCA ids looked up from User records
        Map<String,User> users = new Map<String,User>([select Id, ZCA_Id__c from User]);

        // Get all Model lines from Code__c records
        List<Code__c> modelLineList = new List<Code__c>([select Id, Type__c, Code__c, Description__c 
                                                         from Code__c
                                                         where Type__c = 'Model_Line']);
        Map<String,String> modelLines = new Map<String,String>();
        for(Code__c modelLine: modelLineList) {
            modelLines.put(modelLine.Description__c, modelLine.Code__c);
        }

        // Use the Stage Check Request rows to lookup associated Case records and create Stage_Case rows.
        try {
            createStageCases(lstChkStg, users, modelLines, errors);
        } catch (Exception err) {
            errors.add(new Error_Log__c(Record_Type__c = 'Stage_Case__c', 
                                        Error_Message__c = err.getMessage(), 
                                        TimeStamp__c = System.now(), 
                                        Operation_Name__c = 'Batch_CheckRequestStaging_DataLoad.CreateStageCases', 
                                        Source__c='Salesforce', 
                                        Log_Type__c = 'Error', 
                                        Log_Level__c = 1));
        }
            
        // Insert any Stage_Case_Detail rows with comments based on the Check Requests that succeeded
        if (!commentList.isEmpty()) {
            Database.SaveResult[] dbResults = Database.insert(commentList, false);

            // If there are any results, handle the errors
            if (!dbResults.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < commentList.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbResults[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = commentList[row].SFDC_Case_Id__c,
                                    Record_Type__c = 'Case',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CheckRequestStaging_DataLoad.Comments', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    }
                }
            }
        }
        
        // If any Check Requests were successful, update them so their Stage_Status__c is set to Done Processing.
        if (!updateCheckRequestList.isEmpty()) {
            Database.SaveResult[] dbResults = Database.update(updateCheckRequestList, false);

            // If there are any results, handle the errors
            if (!dbResults.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < updateCheckRequestList.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbResults[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = updateCheckRequestList[row].Id,
                                    Record_Type__c = 'Check_Request__c',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CheckRequestStaging_DataLoad.Update_CheckRequests', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    }
                }
            }
        }
        
        // If any errors were returned, add them to the Error_Log table.
        if (!errors.isEmpty()) {
            // Insert rows
            Database.SaveResult[] dbResults = Database.insert(errors, false);
        }
    }
    
    private void fillChkStage(Stage_Check_Request__c stage, Check_Request__c c) {
        stage.Account__c = c.GL_Account__c;
        stage.Address__c = c.Address__c != null ? c.Address__c.toUpperCase() : null;
        stage.Approval_Indicator__c = c.Approval_Indicator__c == 'Y' ? 'Y' : 'N';
        stage.Approved_By__c = c.Approved_By_ID__c != null ? c.Approved_By_ID__c : DEFAULT_EMPTY_VALUE;
        stage.Approving_Manager_ID__c = c.Approving_Manager_ID__c != null ? c.Approving_Manager_ID__c : DEFAULT_EMPTY_VALUE;
        stage.Approving_Manager_Name__c = c.Approving_Manager_Name__c != null ? c.Approving_Manager_Name__c.toUpperCase() : null;
        stage.Batch_Status__c = 'New';
        stage.Business_Name_1__c = c.Business_Name_1__c != null ? c.Business_Name_1__c.toUpperCase() : null;
        stage.Business_Name_2__c = c.Business_Name_2__c != null ? c.Business_Name_2__c.toUpperCase() : null;
        stage.Case_DocumentID__c = c.Document_ID__c;
        stage.Channel_Designation_code__c = c.Channel_Designation_Code__c == 'Infiniti' ? 'I' : 'N';
        stage.Check_Amount__c = c.Check_Amount__c;
        stage.Check_Number__c = c.Check_Number__c;
        stage.Check_Request_GUID__c = c.Id;
        stage.City__c = c.City__c != null ? c.City__c.toUpperCase() : null;
        stage.Date_Approved__c = Text_Util.getFormattedDate(c.Date_Approved__c);
        stage.GL_Value_Code__c = c.GL_Value_Code__c;
        stage.Issue_Date__c = c.Issue_Date__c != null ? Text_Util.getFormattedDate(c.Issue_Date__c) : '0';
        stage.Last_Update_Date__c = Text_Util.getFormattedDateTime(DateTime.now());
        stage.Mileage__c = c.Mileage__c != null ? c.Mileage__c : 0;
        stage.Origination_Source__c = System.Label.Origination_Source_Salesforce;
        stage.Origination_Type__c = System.Label.Origination_Type_ZCA;
        stage.Payable_To_First_Name__c = c.Payable_To_First_Name__c != null ? c.Payable_To_First_Name__c.toUpperCase() : null;
        stage.Payable_To_Last_Name__c = c.Payable_To_Last_Name__c != null ? c.Payable_To_Last_Name__c.toUpperCase() : null;
        stage.Payable_To_Middle_Name__c = c.Payable_To_Middle_Name__c != null ? c.Payable_To_Middle_Name__c.toUpperCase() : null;
        stage.Reimbursement_Indicator__c = c.Reimbursement_Indicator__c == 'Y' ? 'Y' : 'N';
        stage.Request_Date__c = Text_Util.getFormattedDateTime(c.Submitted_Date__c);
        stage.Requested_By__c = c.Submitted_By_ID__c;
        if (c.Requestor_Name__c != null) {
            if (c.Requestor_Name__c.length() > 21) {
                stage.Requestor_Name__c = c.Requestor_Name__c.toUpperCase().substring(0,21);
            } else {
                stage.Requestor_Name__c = c.Requestor_Name__c.toUpperCase();
            }
        } else {
            stage.Requestor_Name__c = null;
        }
        
        stage.Requestor_Terminal_ID__c = c.Requestor_Terminal_ID__c;
        stage.RO_Date__c = c.RO_Date__c != null ? Text_Util.getFormattedDate(c.RO_Date__c) : '0';
        stage.SFDC_Case_Id__c = c.Case__c;
        stage.SFDC_SubCase_Id__c = c.Document_ID__c;
        stage.State__c = c.State__c != null ? c.State__c.toUpperCase() : null;
        stage.Supervisor_Manager_Code__c = 'M';
        stage.VIN__c = c.VIN__c == null ? 'NONE' : c.VIN__c;
        stage.Zip__c = c.Zip__c.Left(5); /****Matt Starr Changed 3/10/14****/
    }

    private List<Stage_Case_Detail__c> createStageCaseDetailList(Integer lineNumber, Check_Request__c cr) {
        Stage_Case_Detail__c stage;
        List<Stage_Case_Detail__c> stageList = new List<Stage_Case_Detail__c>();
        List<String> lines = Text_Util.splitString(cr.Special_Comments__c , Integer.valueOf(System.Label.Comment_Split_Length));
        
        for (String line : lines) {
            stage = new Stage_Case_Detail__c();
            
            stage.Batch_Status__c = 'New';
            stage.Case_DocumentID__c = cr.Document_ID__c;
            stage.Comment_Body__c = line;
            stage.Detail_Type__c = System.Label.Detail_Type_Special;
            stage.Last_Update_Date__c = Text_Util.getFormattedDateTime(DateTime.now());
            stage.Line_Number_1__c = lineNumber++;
            stage.Origination_Source__c = System.Label.Origination_Source_Salesforce;
            stage.Origination_Type__c = System.Label.Origination_Type_ZCA;
            stage.SFDC_Action_code__c = System.Label.Stage_Action_Add;
            stage.SFDC_Case_Id__c = cr.Case__c;
            stage.Successful__c = null;

            stageList.add(stage);
        }
        
        return stageList;
    }

    private void createStageCases(List<Stage_Check_Request__c> checkRequests, Map<String,User> users, Map<String,String> modelLines, List<Error_Log__c> errors) {
        List<Id> caseIdList = new List<Id>();
        String caseQuery;
        Map<Id,Id> checkToCaseMap = new Map<Id,Id>();
        List<Case> caseList;
        Map<Id,Case> caseMap = new Map<Id,Case>();
        Map<Id,Stage_Case__c> checkStageCaseMap = new Map<Id,Stage_Case__c>();
        Case c;
        Stage_Case__c stage;
        
        String categoryQuery;
        List<Case_Categorization__c> caseCategorizationList;
        Map<Id,List<Case_Categorization__c>> caseCategorizationMap = new Map<Id,List<Case_Categorization__c>>();
        Stage_Case_Detail__c caseCommentHeader;
        List<Stage_Case_Detail__c> caseCommentHeaders = new List<Stage_Case_Detail__c>();
        Stage_Case_Detail__c stageCategory;
        List<Stage_Case_Detail__c> caseCategorizations = new List<Stage_Case_Detail__c>();

        // Get List of Case Ids and a Map of Check Request Ids to Case Ids
        for (Stage_Check_Request__c cr: checkRequests) {
            caseIdList.add(cr.SFDC_Case_Id__c);
            checkToCaseMap.put(cr.Check_Request_GUID__c, cr.SFDC_Case_Id__c);
        }
        
        // Build query to get all needed Case fields for Cases in the List of Ids
        caseQuery = Batch_CaseStaging_DataLoad.getQuery() + ' Where Id in :caseIdList';
        
        // Run the query to get the Cases
        caseList = Database.query(caseQuery);
        
        // Create a Map of Case Id to Case
        for (Case oneCase: caseList) {
            caseMap.put(oneCase.Id, oneCase);
        }
    
        // Build query to get all needed Case_Categorization fields for Cases in the List of Ids
        categoryQuery = BuildSoqlUtil.getCreatableFieldsSOQL('Case_Categorization__c', 'Case__c in :caseIdList');
        categoryQuery = categoryQuery.replace('FROM Case_Categorization__c', ', Case__r.DocumentID__c, Case__r.CaseNumber FROM Case_Categorization__c');

        // Run the query to get the Case_Categorizations
        caseCategorizationList = Database.query(categoryQuery);

        List<Case_Categorization__c> caseCatSubList = new List<Case_Categorization__c>();
        // Create a Map of Case Id to List<Case_Categorization>
        for (Case_Categorization__c category: caseCategorizationList) {
            if (caseCategorizationMap.containsKey(category.Case__c)) {
                caseCatSubList = caseCategorizationMap.get(category.Case__c);
                caseCatSubList.add(category);
            } else {
                caseCatSubList = new List<Case_Categorization__c>();
                caseCatSubList.add(category);
                caseCategorizationMap.put(category.Case__c, caseCatSubList);
            }
        }

        // Create a Map from Check Request Id to Case object
        for (Stage_Check_Request__c cr: checkRequests) {
            try {
                c = caseMap.get(cr.SFDC_Case_Id__c);
                stage = new Stage_Case__c();
                Batch_CaseStaging_DataLoad.fillCaseStage(stage, c, users, modelLines);
                stage.Close_Date__c = null;
                stage.DocumentID__c = cr.Case_DocumentID__c;
                stage.SFDC_Action_Code__c = cr.SFDC_Action_code__c;
                checkStageCaseMap.put(cr.Check_Request_GUID__c, stage);
                caseCommentHeader = Batch_CaseStaging_DataLoad.createCommentHeader(c, users);
                caseCommentHeader.Case_DocumentID__c = cr.Case_DocumentID__c;
                caseCommentHeaders.add(caseCommentHeader);
                
                caseCatSubList = caseCategorizationMap.get(cr.SFDC_Case_Id__c);
                if (caseCatSubList != null) {
                    for (Case_Categorization__c caseCat: caseCatSubList) {
                        stageCategory = new Stage_Case_Detail__c();
                        Batch_CaseCategoryStaging_DataLoad.fillStageCaseDetail(stageCategory, caseCat);
                        stageCategory.Case_DocumentID__c = cr.Case_DocumentID__c;
                        caseCategorizations.add(stageCategory);
                    }
                }
            } catch (Exception err) {
                errors.add(new Error_Log__c(Record_ID__c = cr.Id,
                                    Record_Type__c = 'Check_Request__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CheckRequestStaging_DataLoad.CreateStageCases', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
            }
        }
        
        // Insert StageCase rows
        if (!checkStageCaseMap.isEmpty()) {
            Database.SaveResult[] dbResults = Database.insert(checkStageCaseMap.values(), false);

            // If there are any results, handle the errors
            if (!dbResults.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < checkStageCaseMap.values().size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbResults[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = checkStageCaseMap.values()[row].SFDC_Case_Id__c,
                                    Record_Type__c = 'Case',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CheckRequestStaging_DataLoad.Stage_Case', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    }
                }
            }
        }
        
        // Insert StageCaseDetail rows for Case Comment Headers
        if (!caseCommentHeaders.isEmpty()) {
            Database.SaveResult[] dbResults = Database.insert(caseCommentHeaders, false);

            // If there are any results, handle the errors
            if (!dbResults.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < caseCommentHeaders.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbResults[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = caseCommentHeaders[row].SFDC_Case_Id__c,
                                    Record_Type__c = 'Case',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CheckRequestStaging_DataLoad.Stage_Case_Comment_Headers', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    }
                }
            }
        }


        // Insert StageCaseDetail rows for Case Categorizations
        if (!caseCategorizations.isEmpty()) {
            Database.SaveResult[] dbResults = Database.insert(caseCategorizations, false);

            // If there are any results, handle the errors
            if (!dbResults.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < caseCategorizations.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbResults[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = caseCategorizations[row].SFDC_Case_Id__c,
                                    Record_Type__c = 'Case',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CheckRequestStaging_DataLoad.Stage_Case_Categorizations', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    }
                }
            }
        }
    }

    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){
    }
}