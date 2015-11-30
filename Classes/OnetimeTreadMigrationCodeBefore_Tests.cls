/**********************************************************************
  Name: OnetimeTreadMigrationCodeBefore_Tests
  Copyright © notice: Nissan Motor Company
  ======================================================
  Purpose:
  Tests class for OnetimeTreadMigrationCode_Before trigger

  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Anna Koseikina 02/26/2015 Created
  ***********************************************************************/
@isTest
public class OnetimeTreadMigrationCodeBefore_Tests {
    private static Case testCase = new Case(Status = 'New', 
                                 Origin = 'Phone', 
                                 Description = 'Initial Description', 
                                 Who_called__c = 'P - Parts Department', 
                                 What_Department__c = 'P - Parts Department');
        
    private static List<Code__c> testCodes;
    private static CaseCategory_Dependency__c testCCD;
    private static Case_Categorization__c testCC; 
    private static void init(){
        testCodes = new List<Code__c>();
        testCodes.add(new Code__c(Type__c = 'Concern', Code__c = 'CN', Description__c = 'Concern', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Category', Code__c = 'CT', Description__c = 'Category', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Subcategory', Code__c = '9IIII9', Description__c = 'Subcategory', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Symptom', Code__c = 'SM', Description__c = 'Symptom', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Major Component Code', Code__c = 'MJ', Description__c = 'Symptom', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Root_Cause_Code', Code__c = 'test', Description__c = 'Symptom', Active__c = TRUE));
        insert testCodes;
        //testCase.Special_Root_Cause_Closing_Code__c = testCodes[5].Id;
        insert testCase;
        testCCD = new CaseCategory_Dependency__c();
        testCCD.Concern__c = testCodes[0].ID;
        testCCD.Category__c = testCodes[1].ID;
        testCCD.Subcategory__c = testCodes[2].ID;
        testCCD.Symptom__c = testCodes[3].ID;
        testCCD.Major_Component_Code__c = 'MJ';
        insert testCCD;

        testCC = new Case_Categorization__c();
        testCC.Case__c = testCase.ID;
        
        testCC.Concern__c = testCodes[0].ID;
        testCC.Concern_Code__c = 'CN';
        
        testCC.Category__c = testCodes[1].ID;
        testCC.Category_Code__c = 'CT';
        
        testCC.Subcategory__c = testCodes[2].ID;
        testCC.Subcategory_Code__c = '9IIII9';
        
        testCC.Symptom__c = testCodes[3].ID;
        testCC.Symptom_Code__c = 'SM';
        
        insert testCC;
    }
    static testmethod void testAllCorrect(){
                Test.startTest();
        init();
       
        TREAD_Codes_Logic__c treadCodeSettings = TREAD_Codes_Logic__c.getOrgDefaults();
        if(treadCodeSettings.User_ID_not_Fire__c == null){
            treadCodeSettings = new TREAD_Codes_Logic__c();         
            treadCodeSettings.CasesTypes__c = 'CA,CA Closed Case,T5,CA Email Infiniti,CA Email Nissan,CA Sales & Service';
            treadCodeSettings.Calculate_TREAD__c = true;
            treadCodeSettings.User_ID_not_Fire__c = '005A0000001Y7Ek'; //Managed Services ID
            insert treadCodeSettings;
            treadCodeSettings = TREAD_Codes_Logic__c.getOrgDefaults();
        }

        User runAsUser = new User();
        if(treadCodeSettings.User_ID_not_Fire__c != null){
            runAsUser = [SELECT ID FROM User WHERE ID = :treadCodeSettings.User_ID_not_Fire__c];
        }
        else{
            runAsUser = [SELECT ID FROM User WHERE ID = :UserInfo.getUserId()];
        }
        OnetimeTreadMigration_Code__c treadMigration = new OnetimeTreadMigration_Code__c(Salesforce_Case_Id__c = String.valueOf(testCase.Id).substring(0,15),
                                                                                         Category_Code__c = 'CT',
                                                                                         Concern_Code__c = 'CN',
                                                                                         Subcategory_Code__c = '9IIII9',
                                                                                         Symptom_Code__c = 'SM',
                                                                                         Tread_Code__c = '03',
                                                                                         Incident_Open_Date__c =  Date.newInstance(2014,1,11),
                                                                                         Tread_Effective_Date__c = Date.newInstance(2014,1,11));
        System.runAs(runAsUser){
            insert treadMigration;
        }
        testCC = [SELECT Id, Major_Component_Code__c FROM Case_Categorization__c WHERE Case__c=:testCase.Id LIMIT 1];
        //treadMigration = [SELECT Id, Error_Description__c from OnetimeTreadMigration_Code__c where id=:treadMigration.id limit 1];
        //System.assert(false, treadMigration.Error_Description__c);
        
        System.assertEquals(testCC.Major_Component_Code__c, treadMigration.Tread_Code__c);
        test.stopTest();
    }
    static testmethod void testWithNp(){
                Test.startTest();
        init();
        
        OnetimeTreadMigration_Code__c treadMigration = new OnetimeTreadMigration_Code__c(Salesforce_Case_Id__c = String.valueOf(testCase.Id).substring(0,15),
                                                                                         Category_Code__c = 'CT',
                                                                                         Concern_Code__c = 'CN',
                                                                                         Subcategory_Code__c = '9IIII9',
                                                                                         Symptom_Code__c = 'SM',
                                                                                         Tread_Code__c = 'NP',
                                                                                         Tread_Effective_Date__c = Date.newInstance(2014,1,11));
        insert treadMigration;
        testCC = [SELECT Id, Major_Component_Code__c FROM Case_Categorization__c WHERE Case__c=:testCase.Id LIMIT 1];
        System.assertEquals(testCC.Major_Component_Code__c, testCCD.Major_Component_Code__c);
        test.stopTest();
    }
}