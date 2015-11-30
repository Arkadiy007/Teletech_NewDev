/**********************************************************************
Name: Batch_CaseCommentStaging_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads CaseComment table data into Stage_Case_Detail__c table.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry         11/15/2011 Initial Creation
***********************************************************************/
global class Batch_CaseCommentStaging_DataLoad implements Database.Batchable<sObject> {
    private final DateTime lastRunDateTime;

    // String of query for all creatable fields on CaseComment
    global String query;
    
    global Batch_CaseCommentStaging_DataLoad() {
        // Get the last run time
        List<Code__c> lastRunTimeCode = [select Id, Description__c from Code__c where Type__c = 'Last_Run_Time' and Code__c = 'Case_Comment_Backfeed'];
        String lastRunTimeString = null;
        if (lastRunTimeCode.size() > 0) {
            lastRunTimeString = lastRunTimeCode[0].Description__c;
        }
        // If the last run time is set, use it.  Otherwise set the last run time to 1 day ago.
        if (lastRunTimeString != null && lastRunTimeString != '') {
            lastRunDateTime = DateTime.valueOfGmt(lastRunTimeString);
        } else {
            lastRunDateTime = DateTime.now().addDays(-1);
        }
    }
   
    // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){

        // Construct a clause where the LastModifiedDate of the record is greater than the last time
        // the job was run. 
        String WClause;
        if (Test.isRunningTest()) {
            WClause = 'CommentBody = \'ZYXABC\' ' +
                      'And Parent.RecordType.Name in (\'CA\',\'CA Email Infiniti\',\'CA Email Nissan\',\'T5\',\'Roadside Assistance\',\'CA Closed Case\') ' +
                      'And Parent.Spam_Remove_From_Backfeed__c != true';
        } else {
            WClause = 'LastModifiedDate > :lastRunDateTime ' +
                      'And Parent.RecordType.Name in (\'CA\',\'CA Email Infiniti\',\'CA Email Nissan\',\'T5\',\'Roadside Assistance\',\'CA Closed Case\') ' +
                      'And Parent.Spam_Remove_From_Backfeed__c != true';
        }
        
        // Construct query with the where clause and add a child field into the Select list
        query = BuildSoqlUtil.getCreatableFieldsSOQL('CaseComment', WClause);
        query = query.replace('FROM CaseComment', ', Parent.DocumentID__c, Parent.CaseNumber, Parent.RecordType.Name, CreatedBy.UserRole.Name, CreatedBy.Profile.Name FROM CaseComment');
        return Database.getQueryLocator(query);
    } 

    // Handle each batch of CaseComment rows returned and insert corresponding records
    // into Stage_Case_Detail
    global void execute(Database.BatchableContext BC, List<CaseComment> lstCaseComTable) {      

        // Initialize variables and lists
        String SFDC_Action_Code;
        Integer lineNumber = 1;
        List<Stage_Case_Detail__c> addList;
        List<Stage_Case_Detail__c> lstCaseDtlStg = new List<Stage_Case_Detail__c>();    
        Map<Integer, CaseComment> CaseComInsMap = new Map<Integer, CaseComment>();
        integer ins = 0;
        List<Error_Log__c> errors = new List<Error_Log__c>();
        
        // Get all ZCA ids looked up from User records
        Map<String,User> users = new Map<String,User>([select Id, ZCA_Id__c from User]);

        // Loop through all Case_Categorizations returned and classify them as adds or updates.
        for (CaseComment CaseComAll : lstCaseComTable)
        {
            try {
                SFDC_Action_Code = System.Label.Stage_Action_Add;           
                
                // Set Stage_Case_Detail fields from the input CaseComment
                addList = createStageCaseDetailList(SFDC_Action_Code, 1, CaseComAll, users);
                   
                // Add Stage_Case_Detail record to the list to insert 
                lstCaseDtlStg.addAll(addList);  
                
                // Save the input CaseComment to a numbered Map where the key of the Map is the
                // index of the CaseComment in the original input.
                CaseComInsMap.put(ins,CaseComAll);  
                ins++;
            } catch (Exception err) {
                errors.add(new Error_Log__c(Record_ID__c = CaseComAll.Id,
                                    Record_Type__c = 'CaseComment', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CaseCommentStaging_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
            }
        }
        
        // If any Stage_Case_Detail rows are in the list, insert them and handle any errors.
        if (!lstCaseDtlStg.isEmpty())       //INSERT/UPDATE PROCESSED
        {   
            // Insert rows
            Database.SaveResult[] dbCDStage = Database.insert(lstCaseDtlStg, false);

            // If there are any results, handle the errors
            if (!dbCDStage.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < lstCaseDtlStg.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbCDStage[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbCDStage[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = (CaseComInsMap.get(row)).Id,
                                    Record_Type__c = 'Stage_Case_Detail__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CaseCommentStaging_DataLoad', 
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
    
    private List<Stage_Case_Detail__c> createStageCaseDetailList(String SFDC_Action_Code, Integer lineNumber, CaseComment cc, Map<String,User> users) {
        Stage_Case_Detail__c stage;
        List<Stage_Case_Detail__c> stageList = new List<Stage_Case_Detail__c>();
        List<String> lines = Text_Util.splitString(cc.CommentBody , Integer.valueOf(System.Label.Comment_Split_Length));
        
        stage = new Stage_Case_Detail__c();
        User user = users.get(cc.CreatedById);
        String zcaId = user != null ? user.ZCA_Id__c : null;
        
        stage.SFDC_Action_code__c = SFDC_Action_Code;
        stage.Batch_Status__c = 'New';
        stage.Case_DocumentID__c = Text_Util.getDocumentId(cc.Parent.DocumentID__c, cc.Parent.CaseNumber, cc.Parent.RecordType.Name);
        stage.Comment_Body__c = 'Created by ' + zcaId + ' at ' + String.valueOf(cc.CreatedDate);
        stage.Detail_Type__c = System.Label.Detail_Type_BasicLine;
        stage.Last_Update_Date__c = Text_Util.getFormattedDateTime(DateTime.now());
        stage.Line_Number_1__c = lineNumber++;
        stage.Origination_Source__c = System.Label.Origination_Source_Salesforce;
        stage.Origination_Type__c = System.Label.Origination_Type_ZCA;
        stage.SFDC_Case_Id__c = cc.ParentId;
        stage.Successful__c = null;
        stage.User_Defined_Text_1__c = Text_Util.getFormattedDateTime(cc.CreatedDate) + 
                                       Text_Util.getFormattedTime(cc.CreatedDate);
        stageList.add(stage);
        
        for (String line : lines) {
            stage = new Stage_Case_Detail__c();
            stage.SFDC_Action_code__c = SFDC_Action_Code;
            stage.Batch_Status__c = 'New';
            stage.Case_DocumentID__c = Text_Util.getDocumentId(cc.Parent.DocumentID__c, cc.Parent.CaseNumber, cc.Parent.RecordType.Name);
            stage.Comment_Body__c = line;
            stage.Detail_Type__c = System.Label.Detail_Type_BasicLine;
            stage.Last_Update_Date__c = Text_Util.getFormattedDateTime(DateTime.now());
            stage.Line_Number_1__c = lineNumber++;
            stage.Origination_Source__c = System.Label.Origination_Source_Salesforce;
            stage.Origination_Type__c = System.Label.Origination_Type_ZCA;
            stage.SFDC_Case_Id__c = cc.ParentId;
            stage.Successful__c = null;
            stage.User_Defined_Text_1__c = Text_Util.getFormattedDateTime(cc.CreatedDate) + 
                                           Text_Util.getFormattedTime(cc.CreatedDate);
            stageList.add(stage);
        }
        
        return stageList;
    }

    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){
        Code__c lastRunTimeCode = [select Id, Description__c from Code__c where Type__c = 'Last_Run_Time' and Code__c = 'Case_Comment_Backfeed'];
        lastRunTimeCode.Description__c = String.valueOfGmt(DateTime.now());
        update lastRunTimeCode;
    }
}