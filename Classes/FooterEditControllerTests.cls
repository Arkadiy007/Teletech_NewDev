/**********************************************************************
  Name: FooterEditControllerTests
  Copyright � notice: NMAC.
  ======================================================
  Purpose:
  This is a test class for FooterEditController.cls
 
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL
  1.0 - Arshakyan Georgiy 6/11/2015 Created 
  ***********************************************************************/
@isTest
public class FooterEditControllerTests {
    public static User u {get; set;}

    static{
        populateTestData();
    }   
    @isTest
    static void testDocumentUploading(){
        System.runAs(u){
            System.assertEquals('/', [SELECT Document__r.Link__c FROM Footer__c WHERE State__c = 'Sent For Review'][0].Document__r.Link__c);
        
            Test.startTest();
            FooterEditController home = new  FooterEditController();
            home.d = new Document(Name='test.pdf', Body=Blob.valueof('Test'));

            home.save();

            System.assertNotEquals('/', [SELECT Document__r.Link__c FROM Footer__c WHERE State__c = 'Sent For Review'][0].Document__r.Link__c);
            Test.stopTest();

        }
    }
    

    @isTest
    static void testDocumentsUploadingNotWorkingForNotPDFs(){
        System.runAs(u){
            System.assertEquals('/', [SELECT Document__r.Link__c FROM Footer__c WHERE State__c = 'Sent For Review'][0].Document__r.Link__c);
            Test.startTest();

            FooterEditController home = new  FooterEditController();
            home.d = new Document(Name='test.xls', Body=Blob.valueof('Test'));

            home.saveAndSubmit();
            
            System.assert(home.errorMsg.contains('test.xls'));
            System.assertEquals('/', [SELECT Document__r.Link__c FROM Footer__c WHERE State__c = 'Sent For Review'][0].Document__r.Link__c);
            
            Test.stopTest();    
        }
    }


    private static void populateTestData(){
        Helper.insertRecords();

        Profile p = [select id
                      from profile
                      where Name = 'System Administrator'
                      limit 1];  
        
        if(u == null){
            u = new User(profileId = p.id, username = 'test12xzcxzcxzc22@test.com', email = 'test12232asdx22@test.com',
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname');
        

        
            insert u;
        }
    }

}