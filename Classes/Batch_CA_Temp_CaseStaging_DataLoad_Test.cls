/**********************************************************************
Name: Batch_CA_Temp_CaseStaging_DataLoad_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Batch_CA_Temp_CaseStaging_DataLoad.cls.
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - William Taylor 2/20/2012 Created / modification of CaseStaging Test.
***********************************************************************/
@isTest
private class Batch_CA_Temp_CaseStaging_DataLoad_Test {

    static testMethod void Batch_CA_Temp_CaseStaging_DataLoad_Test() {
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2005'));
        insert testVehicles;

        RecordType rt = [select id from RecordType where SObjectType = 'Case' and Name = 'CA'];

        Code__c code = new Code__c();
        code.Type__c = 'Last_Run_Time';
        code.Code__c = 'CaseStaging_Backfeed';
        code.Description__c = '';
        insert code;

      State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
      insert state;

        Account acct = new Account(LastName = 'Test', PersonMailingState = 'CO');
        insert acct;
        
        List<Case> cases = new List<Case>();
        Case c1 = new Case(VIN__c = 'VIN01000010000100',
                           AccountId = acct.Id,
                           Dealer_Instructions__c = 'File Reopened',
                           Who_Called__c = 'P - Parts Department',
                           Where_Did_This_Originate__c = 'D - Dealership',
                           What_Is_The_Issue__c = 'AV - Part or Vehicle Availability',
                           RecordTypeId = rt.Id,
                           Call_Recording_Id__c = 'ZYXABC');
        cases.add(c1); 
                
        insert cases; 
        
        Test.startTest();
    
            Batch_CA_Temp_CaseStaging_DataLoad batch = new Batch_CA_Temp_CaseStaging_DataLoad();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }   
    
}