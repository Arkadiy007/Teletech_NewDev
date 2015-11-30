/**********************************************************************
Name: HomepageEditControllerTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a test class for HomepageEditController.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/15/2015 Created 
***********************************************************************/
@isTest
public class HomepageEditControllerTests {
    public static User u {get; set;}

    static{
        populateTestData();
    }
    
    @isTest
    static void testSavingWorksCorrectly(){
        System.runAs(u){
            Test.startTest();

            System.assert([SELECT Information_Text__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0].Information_Text__c.contains('Lorem'));

            HomepageEditController home = new  HomepageEditController();
            home.home.InformationText = 'Test';

            home.save();
            
            System.assertEquals('Test', [SELECT Information_Text__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0].Information_Text__c);

            Test.stopTest();

        }
    }
    
    @isTest
    static void testDocumentsUploading(){
        System.runAs(u){
            Test.startTest();

            System.assertEquals(null, [SELECT Business_Activities_Image__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0].Business_Activities_Image__c);
            System.assertEquals(null, [SELECT Spreadsheat_Image__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0].Spreadsheat_Image__c);

            
            HomepageEditController home = new  HomepageEditController();
            home.businessActivitiesImg = new Document(Name='test.jpg', Body=Blob.valueof('Test'));
            home.spreadsheetImg = new Document(Name='test2.jpg', Body=Blob.valueof('Test2'));

            home.saveAndPreview();
            
            System.assertNotEquals(null, [SELECT Business_Activities_Image__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0].Business_Activities_Image__c);
            System.assertNotEquals(null, [SELECT Spreadsheat_Image__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0].Spreadsheat_Image__c);

            Test.stopTest();

        }
    }
    

    @isTest
    static void testDocumentsUploadingNotWorkingForNotPictures(){
        System.runAs(u){
            System.assertEquals(null, [SELECT Business_Activities_Image__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0].Business_Activities_Image__c);
            System.assertEquals(null, [SELECT Spreadsheat_Image__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0].Spreadsheat_Image__c);


            Test.startTest();

            HomepageEditController home = new  HomepageEditController();
            home.businessActivitiesImg = new Document(Name='test.xls', Body=Blob.valueof('Test'));

            home.saveAndSubmit();
            
            System.assert(home.errorMsg.contains('test.xls'));
            System.assertEquals(null, [SELECT Business_Activities_Image__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0].Business_Activities_Image__c);
            
            Test.stopTest();

            
        
        }
    }
    
    @isTest
    static void testDocumentsUploadingNotWorkingForNotPicturesSpreadsheetImg(){
        System.runAs(u){
            System.assertEquals(null, [SELECT Business_Activities_Image__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0].Business_Activities_Image__c);
            System.assertEquals(null, [SELECT Spreadsheat_Image__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0].Spreadsheat_Image__c);

            Test.startTest();

            HomepageEditController home2 = new  HomepageEditController();
            home2.spreadsheetImg = new Document(Name='test.xls', Body=Blob.valueof('Test'));

            home2.saveAndSubmit();
            
            System.assert(home2.errorMsg.contains('test.xls'));
            System.assertEquals(null, [SELECT Business_Activities_Image__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0].Business_Activities_Image__c);
            
            Test.stopTest();
        }
    }

    @isTest
    static void restoreShouldWorkFine(){
        System.runAs(u){

            System.assert([SELECT Information_Text__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0].Information_Text__c.contains('Lorem'));

            PageReference pageRef = Page.HomepageEdit;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('restore', 'true');
            ApexPages.currentPage().getParameters().put('id', [SELECT ID FROM Ws_Tab_Home__c WHERE State__c = 'Approved'][0].id);

            Test.startTest();
                HomepageEditController faq = new HomepageEditController();
                
                faq.saveAndSubmit();
                
                System.assert([SELECT Information_Text__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0].Information_Text__c.contains('Historical'));
                Test.stopTest();

        }
    }

    private static void populateTestData(){
        Helper.insertRecords();

        Ws_Tab_Home__c prod = [SELECT Id, Information_Text__c FROM Ws_Tab_Home__c WHERE State__c = 'Approved'][0];
        prod.Information_Text__c = 'Historical Version';
        update prod;

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