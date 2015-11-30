/**********************************************************************
Name: MANUAL_CaseCommentStaging_DataLoad_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for MANUAL_CaseCommentStaging_DataLoad.cls.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - William Taylor 4/23/2014 Created 
***********************************************************************/
@isTest
private class MANUAL_CaseCommentStaging_DataLoad_Test {

    static testMethod void MANUAL_CaseCommentStaging_Test() {
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2005'));
        insert testVehicles;

        RecordType rt = [select id from RecordType where SObjectType = 'Case' and Name = 'CA'];

    State__c state = new State__c();
    state.name__c = 'Colorado';
    state.name = 'CO';
    insert state;
    
    Code__c code = new Code__c();
    code.Type__c = 'Last_Run_Time';
    code.Code__c = 'Case_Comment_Backfeed';
    code.Description__c = '';
    insert code;

        Account acct = new Account(LastName = 'Test',PersonMailingState = 'CO');
        insert acct;
        
        List<Case> cases = new List<Case>();
        Case c1 = new Case(VIN__c = 'VIN01000010000100',
                           AccountId = acct.Id,
                           Dealer_Instructions__c = 'File Reopened',
                           Who_Called__c = 'P - Parts Department',
                           Where_Did_This_Originate__c = 'D - Dealership',
                           What_Is_The_Issue__c = 'AV - Part or Vehicle Availability',
                           RecordTypeId = rt.Id);
        cases.add(c1); 
                
        insert cases;

        List<CaseComment> caseComments = new List<CaseComment>();
        CaseComment cc1 = new CaseComment();
        cc1.ParentId = c1.Id;
        cc1.CommentBody = 'ZYXABC';
        caseComments.add(cc1);
        
        insert caseComments;        
        
        Test.startTest();
    
            MANUAL_CaseCommentStaging_DataLoad batch = new MANUAL_CaseCommentStaging_DataLoad();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }   
    
}