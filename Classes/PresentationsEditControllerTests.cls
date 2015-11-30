/**********************************************************************
Name: PresentationsEditControllerTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a test class for PresentationsEditController.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/18/2015 Created 
***********************************************************************/
@isTest
private class PresentationsEditControllerTests {
    public static List<Ws_Tab_Presentations__c> testLines;
    public static List<Ws_Tab_Presentations__c> prodLines;
    public static User u {get; set;}

    static{
        populateTestData();
    }
    
    @isTest
    static void deleteAllItemsShouldWorkProperly(){
        System.runAs(u){
            Test.startTest();
                PresentationsEditController faq = new PresentationsEditController();
                System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Presentation_Item__c WHERE Ws_Tab_Presentation__c =: testLines[0].id]);

                //Mark all items for deletion
                for (PresentationItemModel iw : faq.items) {
                    iw.IsDeleted = true;
                }

        
                faq.saveAndSubmit();
            

                System.assertEquals(0, [SELECT Count() FROM Ws_Tab_Presentation_Item__c WHERE Ws_Tab_Presentation__c =: testLines[0].id]);
                Test.stopTest();

        }
    }
    @isTest
    static void updateAllItemsShouldWorkProperly(){
        System.runAs(u){
            Test.startTest();
                PresentationsEditController faq = new PresentationsEditController();
                System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Presentation_Item__c WHERE Ws_Tab_Presentation__c =: testLines[0].id]);

                
                for (PresentationItemModel iw : faq.items) {
                    iw.ItemText = 'Test';
                }

        
                faq.saveAndPreview();
            

                Test.stopTest();

        }
    }

    @isTest
    static void updateAllShouldFailIfSortingOrderIsNotUnique(){
        System.runAs(u){
            Test.startTest();
                PresentationsEditController faq = new PresentationsEditController();
                
                
                for (PresentationItemModel iw : faq.items) {
                    iw.OrderNumber = 1;
                }

        
                faq.saveAndSubmit();
            

                Test.stopTest();

        }
    }


    @isTest
    static void restoreShouldWorkFine(){
        System.runAs(u){

            PageReference pageRef = Page.FAQEdit;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('restore', 'true');
            ApexPages.currentPage().getParameters().put('id', [SELECT ID FROM Ws_Tab_Presentations__c WHERE State__c = 'Approved'][0].id);


            Test.startTest();
                PresentationsEditController faq = new PresentationsEditController();
                
        
                faq.saveAndSubmit();
            

                Test.stopTest();

        }
    }

    @isTest
    static void uploadDocShouldReturnValidPR(){
        System.runAs(u){


            Test.startTest();
                PresentationsEditController faq = new PresentationsEditController();
                
                System.assert(faq.uploadDoc().getUrl().contains('/apex/UploadABSDocument?id='));
                System.assert(faq.uploadDoc().getUrl().contains('&page=Pres'));
                
                Test.stopTest();

        }
    }

    @isTest
    static void addShouldReturnValidPR(){
        System.runAs(u){


            Test.startTest();
                PresentationsEditController faq = new PresentationsEditController();
                
                System.assert(faq.add().getUrl().contains('/apex/UploadABSDocument?page=pres'));
                
                Test.stopTest();

        }
    }



    private static void populateTestData(){
        Helper.insertRecords();

        testLines = [SELECT Id FROM Ws_Tab_Presentations__c WHERE State__c = 'Sent For Review'];
        prodLines = [SELECT Id FROM Ws_Tab_Presentations__c WHERE State__c = 'Approved'];

        List<Ws_Tab_Presentation_Item__c> testItems = new List<Ws_Tab_Presentation_Item__c>();
        List<Ws_Tab_Presentation_Item__c> productionItems = new List<Ws_Tab_Presentation_Item__c>();
        

        for(Integer i = 0; i < 10; i++){
            

            Ws_Tab_Presentation_Item__c testTmp = new Ws_Tab_Presentation_Item__c(Ws_Tab_Presentation__c = testLines[0].id, Order_Number__c = i);
            testItems.add(testTmp);

            Ws_Tab_Presentation_Item__c prodTmp = new Ws_Tab_Presentation_Item__c(Ws_Tab_Presentation__c = prodLines[0].id, Order_Number__c = i, Item_Text__c = 'prod');
            productionItems.add(prodTmp);
        }

        insert testItems;
        insert productionItems;


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