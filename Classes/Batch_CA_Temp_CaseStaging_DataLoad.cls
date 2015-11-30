/**********************************************************************
Name: Batch_CaseStaging_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads Case table data into Stage_Case__c table.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Munawar Esmail    09/19/2011 Created
1.1 - Bryan Fry         10/21/2011 Changed method of getting rows
1.2 - Bryan Fry         01/23/2013 Added 'B' Classification Code for T5
1.3 - William T         01/16/2014 Added 'Chat' as origin to set Received Date
1.4 - Will T            2/3/2014   Modified for testing for query fix, msg
1.5 - Will T            2/5/2014   Added lastRunDateTime lookup
***********************************************************************/
global class Batch_CA_Temp_CaseStaging_DataLoad implements Database.Batchable<sObject> {
    // String of query for all creatable fields on Case
    global String query;
    
    private static final String DEFAULT_EMPTY_VALUE = 'NONE';
    private static final String DEFAULT_ZCA_ID = '12345678';
    private final DateTime lastRunDateTime;
    
    
    global Batch_CA_Temp_CaseStaging_DataLoad() {
        // Get the last run time
        List<Code__c> lastRunTimeCode = [select Id, Description__c from Code__c where Type__c = 'Last_Run_Time' and Code__c = 'CaseStaging_Backfeed'];
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
    
    
    public static String getQuery() {
        return 'SELECT Vehicles_Owned__c, Accident_Indicator__c, AccountId, Action_Code__c, Airbag_Indicator__c, Alternate_Email__c, EveningPhone__c, AlternatePhone__c, BeyondBasicWarrantyMiles__c, Beyond_Basic_Warranty_Miles__c, BeyondBasicWarrantyMonths__c, Beyond_Basic_Warranty_Months__c, Beyond_PT_Warranty_Miles__c, BeyondPTWarrantyMiles__c, BeyondPTWarrantyMonths__c, Beyond_PT_Warranty_Months__c, Buyback__c, Buyback_Restriction__c, C_A_R_File__c, CA_Reports__c, CDIID__c, Callback_Count__c, Callback_Required__c, Callback_Date_CYMD__c, Callback_UserID__c, Case_External_ID__c, Id, CaseNumber, Origin, Type, Categorizations__c, Channel__c, Check_Requests_Total__c, Check_Request_Origin__c, Classification__c, IsClosed, ClosedDate, Comment_Text__c, Considered_Vehicle_Make__c, Considered_Vehicle_Model__c, Considered_Vehicle_Data__c, CreatedById, CreatedDate, Current_Mileage__c, Current_Vehicle_Lease_Exp_Date__c, Current_Vehicle_Lease_Indicator__c, Current_Vehicle_Data__c, Customer_ID__c, Data_Net__c, Datanet_Dealer_Count__c, Datanet_Dealer_Date__c, Datanet_Dealer_Indicator__c, Date_Closed__c, Date_Opened__c, Date_Sent__c, Dealer__c, Dealer_CA_Manager_Name__c, Dealer_Code__c, DealerCode__c, Dealer_Forward_Indicator__c, Dealer_Instructions__c, Dealer_Name__c, Dealer_Number__c, Dealer_Update_By_User_ID__c, Dealer_Update_Date__c, Description, Do_Not_Contact__c, Document_ID__c, DocumentID__c, Email2__c, Email_Indicator__c, Email_Received_Date__c, Exec_Received_Date__c, Executive_Referral__c, Fire_Indicator__c, First_Name__c, Follow_Up_Date__c, Form__c, Goodwill_Offered__c, Goodwill_Processed__c, Home_Phone__c, How_Did_you_Find_the_Answer__c, How_was_the_action_taken__c, How_were_we_contacted__c, IIR__c, IIR_Date__c, IIR_Indicator__c, In_Service_Date__c, Incident_Date__c, Incident_Number__c, Incoming_Car_Indicator__c, Injury_Indicator__c, Language_Code__c, LastModifiedById, LastModifiedDate, Last_Name__c, Legacy_Case_Number__c, Letter_Received_Date__c, Literature_Data__c, Mailing_City__c, Mailing_State__c, Mailing_Street__c, Mailing_Street_2__c, Mailing_Zip_Plus4__c, Mailing_Zip_Code__c, Make__c, Middle_Initial__c, Mobile_Phone__c, Model_Code__c, Model_Id__c, Model_Line__c, Model_Name__c, Model_Series__c, Model_Year__c, Nearest_Infiniti_Dealer__c, Number_Injured__c, Origination__c, Originator_Code__c, Originator_Region__c, Other_TECH_LINE_Reports__c, OwnerId, ParentId, Part_Number_1__c, Mileage_Initial__c, Preferred_Dealer__c, Previous_Repair_Date__c, Previous_Repair_Location__c, Property_Damage_Indicator__c, Record_Suffix__c, RecordTypeId, Region__c, Channel_Designation_Code__c, Reopen_Callback_Count__c, Reopen_Callback_Date__c, Reopen_Callback_UserID__c, Reopen_Date__c, Reopen_New_UserID__c, Reopen_Other_Count__c, Reopen_Other_Date__c, Reopen_Other_UserID__c, Reopened_Times__c, Repair_Root_Cause_Code__c, Resend_Request_Indicator__c, Responsibility_Code__c, Responsible_Dealer_Data__c, Responsible_Dealer_Number__c, Responsible_District__c, Responsible_PDC__c, Responsible_Region__c, Retail_Dealer__c, Road_Service_Call_Indicator__c, Road_Service_Call_Number__c, Rollover_Indicator__c, Root_Cause_Code__c, Root_Cause_Code_2__c, Safety_Indicator__c, Selected_Dealer_Number__c, Sent_to_Legal_Indicator__c, Service_Dealer_Number__c, Servicing_Dealer__c, Servicing_Dealer_Region__c, Severity__c, Severity_Rating_Code__c, Solution_Description__c, Special_Remark_Line_Count__c, Special_Root_Cause_Closing_Code__c, Special_Root_Cause_Closing_Code_2__c, Stage_Status__c, State_Of_Incident__c, Status, Subject, Survey_Dealer_Number__c, Survey_Request_Date__c, Survey_Type__c, Survey_Source__c, TSO_Number__c, Tel_Survey_Indicator__c, Third_Party_Involvement__c, Total_Verbatims__c, Tow_Mileage__c, Tow_To_Address__c, Tow_To_Address_Name__c, Tow_To_City__c, Tow_To_State__c, Tow_To_Zip__c, URL_Related_to_Issue__c, VIN__c, VSC_Requests__c, Vehicle_Name__c, Vehicle_Maintained_Location__c, Vehicle_Make__c, Vehicle_Model__c, VehiclePurchasedType__c, Vehicle_Purchased__c, Vehicle_Purchased_Miles__c, Vehicle_Service_Contract__c, Vehicle_Year__c, VehiclesOwned__c, Who_called__c, What_Department__c, What_action_was_taken__c, What_is_the_issue__c, WhatIsTheIssue2__c, When_Plan_Purchase__c, Where_did_this_originate__c, Where_did_this_originate_2__c, Who_contacted_us__c, Who_Took_Action__c, Work_Phone__c, Contact.Phone, Contact.Email, Contact.FirstName, Contact.LastName, Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, Contact.HomePhone, Contact.MobilePhone, Contact.OtherPhone, Vehicle_Name__r.Vehicle_Identification_Number__c, Vehicle_Name__r.In_Service_Date__c, RecordType.Name  FROM Case ';
    }
   
   
   
    // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = getQuery();
        if (!Test.isRunningTest()) {
        
            query = query + 'Where LastModifiedDate > :lastRunDateTime  ' +
            ' And RecordTypeId in (\'012F0000000y9y7IAA\',\'012F0000000yC0BIAU\',\'012F0000000yBIrIAM\',\'012F0000000yCuIIAU\',\'012F0000000yCuHIAU\',\'012F0000000yCuEIAU\') ' +
            ' And Spam_Remove_From_Backfeed__c != true ' +
            ' and Stage_Status__c in (\'' + System.Label.Stage_Status_Add + '\',\'' + 
                                System.Label.Stage_Status_Update + '\') ';

        } else {
        /* query = query + 'Where Stage_Status__c in (\'' + System.Label.Stage_Status_Add + '\',\'' + 
                                                         System.Label.Stage_Status_Update + '\') ' +
                        'And RecordType.Name in (\'CA\',\'CA Email Infiniti\',\'CA Email Nissan\',\'T5\',\'Roadside Assistance\',\'CA Closed Case\') ' +
                        'And Spam_Remove_From_Backfeed__c != true'; */
            
            query = query + 'WHERE Call_Recording_Id__c = \'ZYXABC\'';
        }

        return Database.getQueryLocator(query);
    } 

    // Handle each batch of Case rows returned and insert corresponding records into Stage_Case
    global void execute(Database.BatchableContext BC, List<Case> lstCaseTable) {
        // Initialize variables and lists
        Stage_Case__c CaseStgRec;
        List<Stage_Case__c> lstCaseStg = new List<Stage_Case__c>(); 
        Map<Integer, Case> CaseInsMap = new Map<Integer, Case>();
        integer ins = 0;
        List<Error_Log__c> errors = new List<Error_Log__c>();
        Case doneCase;
        List<Case> updateCaseList = new List<Case>();
        Stage_Case_Detail__c dealerInstructions;
        List<Stage_Case_Detail__c> rootCauses;
        Map<Id, Stage_Case_Detail__c> commentHeaderMap = new Map<Id, Stage_Case_Detail__c>();
        Map<Id, Stage_Case_Detail__c> commentDealerInstructionsMap = new Map<Id, Stage_Case_Detail__c>();
        Map<Id, List<Stage_Case_Detail__c>> rootCausesMap = new Map<Id, List<Stage_Case_Detail__c>>();
        List<Stage_Case_Detail__c> commentList = new List<Stage_Case_Detail__c>();

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
    
        // Loop through all Cases returned
        for (Case CaseAll : lstCaseTable)
        {
            CaseStgRec = new Stage_Case__c();
            
            try {
                // Get a Stage_Case_Detail row with the required Header comment
                commentHeaderMap.put(CaseAll.Id, createCommentHeader(CaseAll, users));
                
                // Mainframe does upsert for cases so always send an Add action
                CaseStgRec.SFDC_Action_Code__c = System.Label.Stage_Action_Add;

                // Get a Stage_Case_Detail row with dealer instructions
                if (CaseAll.Dealer_Instructions__c != null) {
                    dealerInstructions = createCommentDealerInstructions(CaseAll);
                    if (dealerInstructions != null) {
                        commentDealerInstructionsMap.put(CaseAll.Id, dealerInstructions);
                    }
                }
    
                // Get a Stage_Case_Detail row with root cause
                if (CaseAll.Root_Cause_Code__c != null || CaseAll.Root_Cause_Code_2__c != null) {
                    rootCauses = createRootCauses(CaseAll);
                    if (rootCauses != null) {
                        rootCausesMap.put(CaseAll.Id, rootCauses);
                    }
                }
                
                // Set Stage_Case fields from the input Case
                fillCaseStage(CaseStgRec, CaseAll, users, modelLines);
                   
                // Add Stage_Case record to the list to insert 
                lstCaseStg.add(CaseStgRec); 
                
                // Save the input Case to a numbered Map where the key of the Map is the
                // index of the Case in the original input.
                CaseInsMap.put(ins,CaseAll);    
                ins++;
            } catch (Exception err) {
                errors.add(new Error_Log__c(Record_ID__c = CaseAll.Id,
                                    Record_Type__c = 'Case', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CA_Temp_CaseStaging_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
            }
        }
        
        // If any Stage_Case rows are in the list, insert them and handle any errors.
        if (!lstCaseStg.isEmpty())      //INSERT/UPDATE PROCESSED
        {   
            // Insert rows
            Database.SaveResult[] dbCStage = Database.insert(lstCaseStg, false);

            // If there are any results, handle the errors
            if (!dbCStage.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < lstCaseStg.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbCStage[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbCStage[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = (CaseInsMap.get(row)).Id,
                                    Record_Type__c = 'Stage_Case__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CA_Temp_CaseStaging_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    } else {
                        // If the current row was successful, set its status to Done Processing.
                        doneCase = CaseInsMap.get(row);
                        doneCase.Stage_Status__c = System.Label.Stage_Status_Done;
                        updateCaseList.add(doneCase);
                        if (commentHeaderMap.containsKey((CaseInsMap.get(row)).Id)) {
                            commentList.add(commentHeaderMap.get((CaseInsMap.get(row)).Id));
                        }
                        if (commentDealerInstructionsMap.containsKey((CaseInsMap.get(row)).Id)) {
                            commentList.add(commentDealerInstructionsMap.get((CaseInsMap.get(row)).Id));
                        }
                        if(rootCausesMap.containsKey((CaseInsMap.get(row)).Id)) {
                            commentList.addAll(rootCausesMap.get((CaseInsMap.get(row)).Id));
                        }
                    }
                }
            }
        }

        // Insert any Stage_Case_Detail rows with comments based on the Cases that succeeded
        if (!commentList.isEmpty()) {
            // Insert rows
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
                                    Record_Type__c = 'Stage_Case_Detail__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CA_Temp_CaseStaging_DataLoad.Stage_Case_Detail', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    }
                }
            }
        }

        // If any Cases were successful, update them so their Stage_Status__c is set to Done Processing.
        if (!updateCaseList.isEmpty()) {
            // Insert rows
            Database.SaveResult[] dbResults = Database.update(updateCaseList, false);

            // If there are any results, handle the errors
            if (!dbResults.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < updateCaseList.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbResults[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbResults[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = updateCaseList[row].Id,
                                    Record_Type__c = 'Case',
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_CA_Temp_CaseStaging_DataLoad.Update_Case', 
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

    public static void fillCaseStage(Stage_Case__c stage, Case c, Map<String,User> users, Map<String,String> modelLines) {
        stage.Action_code__c = c.Action_Code__c != null ? c.Action_Code__c.toUpperCase() : null;
        stage.Accident_Indicator__c = (c.Accident_Indicator__c == true) ? 'Y' : 'N';
        stage.Airbag_Indicator__c = (c.Airbag_Indicator__c == true) ? 'Y' : 'N';
        stage.Batch_Status__c = 'New';
        stage.Beyond_Basic_Warranty_Miles__c = String.valueOf(c.BeyondBasicWarrantyMiles__c);
        stage.Beyond_Basic_Warranty_Months__c = String.valueOf(c.BeyondBasicWarrantyMonths__c);
        stage.Beyond_PT_Warranty_Miles__c = String.valueOf(c.BeyondPTWarrantyMiles__c);
        stage.Beyond_PT_Warranty_Months__c = String.valueOf(c.BeyondPTWarrantyMonths__c);
        stage.Case_Open_Time__c = Text_Util.getFormattedTime(c.CreatedDate);
        stage.Channel_Designation_code__c = c.Channel_Designation_Code__c == 'Infiniti' ? 'I' : 'N';
        if (c.Mailing_City__c != null)
            stage.City__c = c.Mailing_City__c.toUpperCase();
        else if (c.Contact.MailingCity != null)
            stage.City__c = c.Contact.MailingCity.toUpperCase();
        // Nissan = 3, Infiniti = 8, CCG = 6, T5 = B
        if (c.RecordType.Name == 'Roadside Assistance')
            stage.Classification_code__c = '6';
        else if (c.RecordType.Name == 'T5')
            stage.Classification_code__c = 'B';
        else if (c.Channel_Designation_Code__c == 'Infiniti')
            stage.Classification_code__c = '8';
        else
            stage.Classification_code__c = '3';
        stage.Close_Date__c = Text_Util.getFormattedDateTime(c.ClosedDate);
        stage.Datanet_Dealer_count__c = c.Datanet_Dealer_Count__c;
        stage.Datanet_Dealer_Date__c = Text_Util.getFormattedDate(c.Datanet_Dealer_Date__c);
        stage.Datanet_Dealer_Indicator__c = (c.Data_Net__c == true) ? 'Y' : 'N';
        if (c.Work_Phone__c != null)
            stage.DayPhone__c = c.Work_Phone__c;
        else if (c.Contact.OtherPhone != null)
            stage.DayPhone__c = c.Contact.OtherPhone; 
        stage.Dealer_cA_Manager_Name__c = c.Dealer_CA_Manager_Name__c != null ? c.Dealer_CA_Manager_Name__c.toUpperCase() : null;
        // For case numbers over 9,000,000, we have a conflict with check request case numbers so we subtract
        // 8,000,000 to bring them into the 1,000,000 range, older than any still in the mainframe.
        stage.DocumentID__c = Text_Util.getDocumentId(c.DocumentId__c, c.CaseNumber, c.RecordType.Name);
        stage.Email__c = c.Contact.Email != null ? c.Contact.Email.toUpperCase() : DEFAULT_EMPTY_VALUE;
        stage.Email_Indicator__c = c.Email_Indicator__c;
        stage.Email_Received_Date__c = c.Origin == 'Email to Case' || c.Origin == 'Email' || c.Origin == 'Chat' ? Text_Util.getFormattedDateTime(c.CreatedDate) : '0';
        if (c.EveningPhone__c != null)
            stage.EveningPhone__c = c.EveningPhone__c;
        else if (c.Contact.HomePhone != null)
            stage.EveningPhone__c = c.Contact.HomePhone;
        stage.Exec_Received_Date__c = c.Exec_Received_Date__c;
        stage.Fire_Indicator__c = (c.Fire_Indicator__c == true) ? 'Y' : 'N';
        if (c.Contact.FirstName != null)
            stage.First_Name__c = c.Contact.FirstName.toUpperCase();
        else if (c.First_Name__c != null)
            stage.First_Name__c = c.First_Name__c.toUpperCase();
        else
            stage.First_Name__c = DEFAULT_EMPTY_VALUE; 
        stage.Follow_Up_Date__c = c.Follow_Up_Date__c != null ? Text_Util.getFormattedDate(c.Follow_Up_Date__c) : Text_Util.getFormattedDate(Date.today());
        stage.Goodwill_claim_Indicator__c = (c.Goodwill_Offered__c == true) ? 'Y' : 'N';
        stage.IIR_Date__c = Text_Util.getFormattedDate(c.IIR_Date__c);
        stage.Incident_Date__c = Text_Util.getFormattedDate(c.Incident_Date__c);
        stage.Injury_Indicator__c = (c.Injury_Indicator__c == true) ? 'Y' : 'N';
        if(c.In_Service_Date__c != null)
            stage.In_Service_Date__c = Text_Util.getFormattedDate(c.In_Service_Date__c);
        else if (c.Vehicle_Name__r.In_Service_Date__c != null)
            stage.In_Service_Date__c = Text_Util.getFormattedDate(c.Vehicle_Name__r.In_Service_Date__c);
        stage.Language_code__c = c.Language_Code__c != null ? c.Language_Code__c.toUpperCase() : null;
        if (c.Contact.LastName != null)
            stage.Last_Name__c = c.Contact.LastName.toUpperCase();
        else if (c.Last_Name__c != null)
            stage.Last_Name__c = c.Last_Name__c.toUpperCase();
        else
            stage.Last_Name__c = DEFAULT_EMPTY_VALUE;
        stage.Last_Update_Date__c = Text_Util.getFormattedDateTime(DateTime.now());
        stage.Letter_Received_Date__c = Text_Util.getFormattedDate(c.Letter_Received_Date__c);
        stage.Middle_Initial__c = c.Middle_Initial__c != null ? c.Middle_Initial__c.toUpperCase() : null;
        stage.Mileage__c = c.Current_Mileage__c != null ? String.valueOf(c.Current_Mileage__c) : '0';
        stage.Mileage_Initial__c = c.Mileage_Initial__c != null ? String.valueOf(c.Mileage_Initial__c) : '0';
        stage.Model__c = c.Model_Line__c != null ? modelLines.get(c.Model_Line__c.toUpperCase()) : null;
        stage.ModelCode__c = c.Model_Code__c != null ? c.Model_Code__c.toUpperCase() : null;
        stage.ModelYear__c = convertYear(c.Model_Year__c);
        stage.Modified_Date__c = Text_Util.getFormattedDateTime(c.LastModifiedDate);
        stage.Number_Injured__c = String.valueOf(c.Number_Injured__c);
        stage.Open_Date__c = Text_Util.getFormattedDateTime(c.CreatedDate);
        stage.Origination_Source__c = System.Label.Origination_Source_Salesforce;
        stage.Origination_Type__c = System.Label.Origination_Type_ZCA;
        stage.Originator_code__c = c.Originator_Code__c != null ? c.Originator_Code__c.toUpperCase() : null;
        stage.Originator_Region__c = '11';
        stage.Part_Number__c = c.Part_Number_1__c != null ? c.Part_Number_1__c.toUpperCase() : null;
        stage.Previous_Repair_Date__c = Text_Util.getFormattedDate(c.Previous_Repair_Date__c);
        stage.Previous_Repair_Location__c  = c.Previous_Repair_Location__c != null ? c.Previous_Repair_Location__c.toUpperCase() : 'NONE';
        stage.Property_Damage_Indicator__c = (c.Property_Damage_Indicator__c == true) ? 'Y' : 'N';
        stage.Reopen_Count__c = c.Reopened_Times__c;
        stage.Reopen_Date__c = Text_Util.getFormattedDateTime(c.Reopen_Date__c);
        if (c.Responsibility_Code__c == 'Sales Department')
            stage.Responsible_code__c = 'L';
        else if (c.Responsibility_Code__c == 'Parts Department')
            stage.Responsible_code__c = 'P';
        else if (c.Responsibility_Code__c == 'Service Department')
            stage.Responsible_code__c = 'S';
        else
            stage.Responsible_code__c = 'N';
        stage.Responsible_Dealer_Number__c = c.Service_Dealer_Number__c;
        stage.Responsible_Region__c = c.Responsible_Region__c == null ? '11' : c.Responsible_Region__c;
        stage.Responsible_District__c = c.Responsible_Region__c == '11' ? '00' : c.Responsible_District__c;
        stage.Retail_Dealer__c = c.Retail_Dealer__c != null ? c.Retail_Dealer__c.toUpperCase() : null;
        stage.Road_Service_call_Indicator__c = c.Road_Service_Call_Indicator__c;
        stage.Road_Service_call_Number__c = c.Road_Service_Call_Number__c;
        stage.Rollover_Indicator__c = (c.Rollover_Indicator__c == true) ? 'Y' : 'N';
        stage.Safety_Indicator__c = (c.Safety_Indicator__c == true) ? 'Y' : 'N';
        stage.Sent_to_Legal_Indicator__c = (c.Sent_to_Legal_Indicator__c == true) ? 'Y' : 'N';
        stage.Service_Dealer_Number__c = c.Service_Dealer_Number__c;
        stage.Severity_Rating_code__c = '9';
        stage.SFDC_Case_Id__c = c.Id;
        if (c.Mailing_State__c != null)
            stage.State__c = c.Mailing_State__c.toUpperCase();
        else if (c.Contact.MailingState != null)
            stage.State__c = c.Contact.MailingState.toUpperCase();
        stage.State_Of_Incident__c = c.State_Of_Incident__c != null ? c.State_Of_Incident__c.toUpperCase() : null;
        if (c.Mailing_Street__c != null)
            stage.Street__c = c.Mailing_Street__c.toUpperCase();
        else if (c.Contact.MailingStreet != null)
            stage.Street__c = c.Contact.MailingStreet.toUpperCase();
        stage.Survey_Dealer_Number__c = c.Survey_Dealer_Number__c;
        stage.Survey_Request_Date__c = c.Survey_Request_Date__c;
        stage.Survey_Source__c = c.Survey_Source__c != null ? c.Survey_Source__c.toUpperCase() : null;
        stage.Survey_Type__c = c.Survey_Type__c != null ? c.Survey_Type__c.toUpperCase() : null;
        // True for T5?
        stage.Tel_Survey_Indicator__c = c.RecordType.Name == 'T5' ? 'Y' : 'N';
        stage.Third_Party_Involvement__c = c.Third_Party_Involvement__c;
        stage.Vehicle_Maintained_Location__c = c.Vehicle_Maintained_Location__c != null ? c.Vehicle_Maintained_Location__c.toUpperCase() : 'NONE';
        stage.Vehicle_Purchase_Type__c = c.VehiclePurchasedType__c == 'Pre-Owned' ? 'P' : 'N';
        stage.Vehicle_Purchased_Miles__c = c.Vehicle_Purchased_Miles__c;
        stage.Vehicles_Owned__c = c.Vehicles_Owned__c != null ? String.valueOf(c.Vehicles_Owned__c) : null;
        if (c.Vehicle_Name__c != null && c.Vehicle_Name__r.Vehicle_Identification_Number__c != null)
            stage.VIN__c = c.Vehicle_Name__r.Vehicle_Identification_Number__c;
        else if (c.VIN__c != null) 
            stage.VIN__c = c.VIN__c;
        if (stage.VIN__c == null || stage.VIN__c == '')
            stage.VIN__c = 'NONE';
        stage.When_Plan_Purchase__c = c.When_Plan_Purchase__c;
        stage.ZIP__c = getNormalizedZipCode(c);

        // Convert all user ids from Salesforce to ZCA ids looked up from User records  
        User user = users.get(c.CreatedById);
        stage.Open_By_UserID__c = user != null && user.ZCA_Id__c != null ? user.ZCA_Id__c : DEFAULT_ZCA_ID;
        user = users.get(c.OwnerId);
        stage.Responsible_cAA__c = user != null && user.ZCA_Id__c != null ? user.ZCA_Id__c : null;
    }

    public static Stage_Case_Detail__c createCommentHeader(Case c, Map<String,User> users) {
        Stage_Case_Detail__c stage;
        
        stage = new Stage_Case_Detail__c();
        
        stage.Batch_Status__c = 'New';
        stage.Case_DocumentID__c = Text_Util.getDocumentId(c.DocumentId__c, c.CaseNumber, c.RecordType.Name);
        User user = users.get(c.CreatedById);
        String zcaId = user != null ? user.ZCA_Id__c : null;
        stage.Comment_Body__c = 'Created by ' + zcaId + ' at ' + String.valueOf(c.CreatedDate);
        stage.Detail_Type__c = System.Label.Detail_Type_Header;
        stage.Last_Update_Date__c = Text_Util.getFormattedDateTime(DateTime.now());
        stage.Line_Number_1__c = 1;
        stage.Origination_Source__c = System.Label.Origination_Source_Salesforce;
        stage.Origination_Type__c = System.Label.Origination_Type_ZCA;
        stage.SFDC_Action_code__c = System.Label.Stage_Action_Add;
        stage.SFDC_Case_Id__c = c.Id;
        stage.Successful__c = null;
        stage.User_Defined_Text_1__c = '0';
        
        return stage;
    }

    private Stage_Case_Detail__c createCommentDealerInstructions(Case c) {
        Stage_Case_Detail__c stage;
        
        stage = new Stage_Case_Detail__c();
        
        stage.Batch_Status__c = 'New';
        stage.Case_DocumentID__c = Text_Util.getDocumentId(c.DocumentId__c, c.CaseNumber, c.RecordType.Name);
        stage.Comment_Body__c = c.Dealer_Instructions__c;
        stage.Detail_Type__c = System.Label.Detail_Type_Dealer_Instructions;
        stage.Last_Update_Date__c = Text_Util.getFormattedDateTime(DateTime.now());
        stage.Line_Number_1__c = 1;
        stage.Origination_Source__c = System.Label.Origination_Source_Salesforce;
        stage.Origination_Type__c = System.Label.Origination_Type_ZCA;
        stage.SFDC_Action_code__c = System.Label.Stage_Action_Add;
        stage.SFDC_Case_Id__c = c.Id;
        stage.Successful__c = null;
        
        return stage;
    }

    private List<Stage_Case_Detail__c> createRootCauses(Case c) {
        Stage_Case_Detail__c stage;
        List<Stage_Case_Detail__c> stages = new List<Stage_Case_Detail__c>();
        
        if (c.Root_Cause_Code__c != null) {
            stage = new Stage_Case_Detail__c();
            stage.Batch_Status__c = 'New';
            stage.Case_DocumentID__c = Text_Util.getDocumentId(c.DocumentId__c, c.CaseNumber, c.RecordType.Name);
            stage.Detail_Type__c = System.Label.Detail_Type_Categorization;
            stage.Last_Update_Date__c = Text_Util.getFormattedDateTime(DateTime.now());
            stage.Origination_Source__c = System.Label.Origination_Source_Salesforce;
            stage.Origination_Type__c = System.Label.Origination_Type_ZCA;
            stage.Root_Cause__c = c.Root_Cause_Code__c;
            stage.SFDC_Action_code__c = System.Label.Stage_Action_Add;
            stage.SFDC_Case_Id__c = c.Id;
            stage.Successful__c = null;
            stages.add(stage);
        }

        if (c.Root_Cause_Code_2__c != null) {
            stage = new Stage_Case_Detail__c();
            stage.Batch_Status__c = 'New';
            stage.Case_DocumentID__c = Text_Util.getDocumentId(c.DocumentId__c, c.CaseNumber, c.RecordType.Name);
            stage.Detail_Type__c = System.Label.Detail_Type_Categorization;
            stage.Last_Update_Date__c = Text_Util.getFormattedDateTime(DateTime.now());
            stage.Origination_Source__c = System.Label.Origination_Source_Salesforce;
            stage.Origination_Type__c = System.Label.Origination_Type_ZCA;
            stage.Root_Cause__c = c.Root_Cause_Code_2__c;
            stage.SFDC_Action_code__c = System.Label.Stage_Action_Add;
            stage.SFDC_Case_Id__c = c.Id;
            stage.Successful__c = null;
            stages.add(stage);
        }
        
        return stages;
    }
    
    /* Model years must be sent as 3 numbers: the last 2 digits of the year and either a 0 or a 5,
       depending on whether it is a full or half year designation. Four-digit years are assumed to 
       be full years and half years are only sent if specified in the model year data.
       Examples:    1996   = 960
                    2000   = 000
                    2005.0 = 050
                    2005.5 = 055
    */
    private static String convertYear(String inYear) {
        String outYear = '';
        if (inYear != null) {
            if (inYear.length() == 4) {
                inYear = inYear + '.0';
            }
            outYear = inYear.substring(2,4) + inYear.substring(5,6);
        }
                
        return outYear;
    }

    private static String getNormalizedZipCode(Case c) {
        String zip = null;
        if (c.Mailing_Zip_Code__c != null)
            zip = getNormalizedZipCode(c.Mailing_Zip_Code__c);
        
        if (zip == null && c.Contact.MailingPostalCode != null)
            zip = getNormalizedZipCode(c.Contact.MailingPostalCode);
            
        return zip;
    }
    
    private static String getNormalizedZipCode(String zip) {
        String outZip = '';
        String hex;
        
        // Convert each character to hex and create a new String with only numbers 0-9, all other
        // characters are stripped out.
        for (Integer zipChar = 0; zipChar < zip.length(); zipChar++) {
            hex = encodingUtil.convertToHex(Blob.valueOf(zip.substring(zipChar, zipChar + 1)));
            if (hex == '30' || hex == '31' || hex == '32' || hex == '33' || hex == '34' ||
                    hex == '35' || hex == '36' || hex == '37' || hex == '38' || hex == '39') {
                outZip = outZip + zip.substring(zipChar, zipChar + 1);
            }
        }
        
        // Return a String of 9 numbers if possible, otherwise a String of 5 numbers, otherwise blank.
        if (outZip.length() > 9) {
            outZip = outZip.substring(0,9);
        } else if (outZip.length() != 9 && outZip.length() > 5) {
            outZip = outZip.substring(0,5);
        } else if (outZip.length() != 9 && outZip.length() != 5) {
            outZip = '';
        }
        
        return outZip;
    }

    global void sendMSG(String msg) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'wrmtyr@gmail.com','digeshshah@teletech.com'};  //a.CreatedBy.Email
        mail.setToAddresses(toAddresses);
        mail.setSubject('Techline Batch Case DataLoad Message');
        mail.setPlainTextBody(msg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
    }

    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){
        sendMSG('The batch job: Batch_CA_Temp_CaseStaging_DataLoad has completed.');
    }
}