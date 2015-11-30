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
***********************************************************************/
global class Batch_TESTING_CaseStaging_DataLoad implements Database.Batchable<sObject> {
    // String of query for all creatable fields on Case
    global String query;
    List<Error_Log__c> errors = new List<Error_Log__c>();
    
    private static final String DEFAULT_EMPTY_VALUE = 'NONE';
    private static final String DEFAULT_ZCA_ID = '12345678';
   
    public static String getQuery() {
        return 'SELECT Vehicles_Owned__c, Accident_Indicator__c, AccountId, Action_Code__c, Airbag_Indicator__c, Alternate_Email__c, EveningPhone__c, AlternatePhone__c, BeyondBasicWarrantyMiles__c, Beyond_Basic_Warranty_Miles__c, BeyondBasicWarrantyMonths__c, Beyond_Basic_Warranty_Months__c, Beyond_PT_Warranty_Miles__c, BeyondPTWarrantyMiles__c, BeyondPTWarrantyMonths__c, Beyond_PT_Warranty_Months__c, Buyback__c, Buyback_Restriction__c, C_A_R_File__c, CA_Reports__c, CDIID__c, Callback_Count__c, Callback_Required__c, Callback_Date_CYMD__c, Callback_UserID__c, Case_External_ID__c, Id, CaseNumber, Origin, Type, Categorizations__c, Channel__c, Check_Requests_Total__c, Check_Request_Origin__c, Classification__c, IsClosed, ClosedDate, Comment_Text__c, Considered_Vehicle_Make__c, Considered_Vehicle_Model__c, Considered_Vehicle_Data__c, CreatedById, CreatedDate, Current_Mileage__c, Current_Vehicle_Lease_Exp_Date__c, Current_Vehicle_Lease_Indicator__c, Current_Vehicle_Data__c, Customer_ID__c, Data_Net__c, Datanet_Dealer_Count__c, Datanet_Dealer_Date__c, Datanet_Dealer_Indicator__c, Date_Closed__c, Date_Opened__c, Date_Sent__c, Dealer__c, Dealer_CA_Manager_Name__c, Dealer_Code__c, DealerCode__c, Dealer_Forward_Indicator__c, Dealer_Instructions__c, Dealer_Name__c, Dealer_Number__c, Dealer_Update_By_User_ID__c, Dealer_Update_Date__c, Description, Do_Not_Contact__c, Document_ID__c, DocumentID__c, Email2__c, Email_Indicator__c, Email_Received_Date__c, Exec_Received_Date__c, Executive_Referral__c, Fire_Indicator__c, First_Name__c, Follow_Up_Date__c, Form__c, Goodwill_Offered__c, Goodwill_Processed__c, Home_Phone__c, How_Did_you_Find_the_Answer__c, How_was_the_action_taken__c, How_were_we_contacted__c, IIR__c, IIR_Date__c, IIR_Indicator__c, In_Service_Date__c, Incident_Date__c, Incident_Number__c, Incoming_Car_Indicator__c, Injury_Indicator__c, Language_Code__c, LastModifiedById, LastModifiedDate, Last_Name__c, Legacy_Case_Number__c, Letter_Received_Date__c, Literature_Data__c, Mailing_City__c, Mailing_State__c, Mailing_Street__c, Mailing_Street_2__c, Mailing_Zip_Plus4__c, Mailing_Zip_Code__c, Make__c, Middle_Initial__c, Mobile_Phone__c, Model_Code__c, Model_Id__c, Model_Line__c, Model_Name__c, Model_Series__c, Model_Year__c, Nearest_Infiniti_Dealer__c, Number_Injured__c, Origination__c, Originator_Code__c, Originator_Region__c, Other_TECH_LINE_Reports__c, OwnerId, ParentId, Part_Number_1__c, Mileage_Initial__c, Preferred_Dealer__c, Previous_Repair_Date__c, Previous_Repair_Location__c, Property_Damage_Indicator__c, Record_Suffix__c, RecordTypeId, Region__c, Channel_Designation_Code__c, Reopen_Callback_Count__c, Reopen_Callback_Date__c, Reopen_Callback_UserID__c, Reopen_Date__c, Reopen_New_UserID__c, Reopen_Other_Count__c, Reopen_Other_Date__c, Reopen_Other_UserID__c, Reopened_Times__c, Repair_Root_Cause_Code__c, Resend_Request_Indicator__c, Responsibility_Code__c, Responsible_Dealer_Data__c, Responsible_Dealer_Number__c, Responsible_District__c, Responsible_PDC__c, Responsible_Region__c, Retail_Dealer__c, Road_Service_Call_Indicator__c, Road_Service_Call_Number__c, Rollover_Indicator__c, Root_Cause_Code__c, Root_Cause_Code_2__c, Safety_Indicator__c, Selected_Dealer_Number__c, Sent_to_Legal_Indicator__c, Service_Dealer_Number__c, Servicing_Dealer__c, Servicing_Dealer_Region__c, Severity__c, Severity_Rating_Code__c, Solution_Description__c, Special_Remark_Line_Count__c, Special_Root_Cause_Closing_Code__c, Special_Root_Cause_Closing_Code_2__c, Stage_Status__c, State_Of_Incident__c, Status, Subject, Survey_Dealer_Number__c, Survey_Request_Date__c, Survey_Type__c, Survey_Source__c, TSO_Number__c, Tel_Survey_Indicator__c, Third_Party_Involvement__c, Total_Verbatims__c, Tow_Mileage__c, Tow_To_Address__c, Tow_To_Address_Name__c, Tow_To_City__c, Tow_To_State__c, Tow_To_Zip__c, URL_Related_to_Issue__c, VIN__c, VSC_Requests__c, Vehicle_Name__c, Vehicle_Maintained_Location__c, Vehicle_Make__c, Vehicle_Model__c, VehiclePurchasedType__c, Vehicle_Purchased__c, Vehicle_Purchased_Miles__c, Vehicle_Service_Contract__c, Vehicle_Year__c, VehiclesOwned__c, Who_called__c, What_Department__c, What_action_was_taken__c, What_is_the_issue__c, WhatIsTheIssue2__c, When_Plan_Purchase__c, Where_did_this_originate__c, Where_did_this_originate_2__c, Who_contacted_us__c, Who_Took_Action__c, Work_Phone__c, Contact.Phone, Contact.Email, Contact.FirstName, Contact.LastName, Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, Contact.HomePhone, Contact.MobilePhone, Contact.OtherPhone, Vehicle_Name__r.Vehicle_Identification_Number__c, Vehicle_Name__r.In_Service_Date__c, RecordType.Name  FROM Case ';
    }
   
    // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){

        query = getQuery();
        query = query + 'Where LastModifiedDate > 2013-10-01T00:00:00Z ' +
                        'And RecordTypeId in (\'012F0000000y9y7IAA\',\'012F0000000yC0BIAU\',\'012F0000000yBIrIAM\',\'012F0000000yCuIIAU\',\'012F0000000yCuHIAU\',\'012F0000000yCuEIAU\') ' +
                        'And Spam_Remove_From_Backfeed__c != true ' +
                        'and Stage_Status__c in (\'' + System.Label.Stage_Status_Add + '\',\'' + 
                                                         System.Label.Stage_Status_Update + '\') ';
                        

           /*
           'Where Stage_Status__c in (\'' + System.Label.Stage_Status_Add + '\',\'' + 
                                                         System.Label.Stage_Status_Update + '\') ' +
                                                         */
                                                         
       
       
       
        if (Test.isRunningTest()) {
            query = query + ' And Call_Recording_Id__c = \'ZYXABC\'';
        }
    
        return Database.getQueryLocator(query);
    } 

    // Handle each batch of Case rows returned and insert corresponding records into Stage_Case
    global void execute(Database.BatchableContext BC, List<Case> lstCaseTable) {

    }

    

  

    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){
                  
    }
}