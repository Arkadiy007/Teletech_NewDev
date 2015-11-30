/**********************************************************************
Name: Batch_TechlineN_Staging_DataLoad_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for Techline New Case Staging
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Will Taylor 1-31-2014
***********************************************************************/   
   
@isTest
private class Batch_TESTING_CaseStaging_DataLoad_Test {
   
    static testMethod void Batch_TESTING_CaseStaging_DataLoad_Test() {
       /* List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        testVehicles.add(new Vehicle__c(Vehicle_identification_Number__c = 'VIN01000010000101', Model_Year__c = '2005'));
        insert testVehicles;
       */
       
       
        /* List<Case> cases = new List<Case>();
        Case c1 = new Case(VIN__c = 'VIN01000010000100',
                           Issue_Type__c = 'MINI',
                           RecordTypeId = rt.Id,
                           Call_Recording_Id__c = 'ZYXABC');
        
        cases.add(c1); 
                
        insert cases; 
        */
        Test.startTest();
    
            Batch_TESTING_CaseStaging_DataLoad batch = new Batch_TESTING_CaseStaging_DataLoad();
            Database.executeBatch(batch);
    
        Test.stopTest();
    }   
    
    
    
}