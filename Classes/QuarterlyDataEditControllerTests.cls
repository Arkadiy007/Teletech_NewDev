/**********************************************************************
Name: QuarterlyDataEditControllerTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a test class for QuarterlyDataEditController.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/20/2015 Created 
***********************************************************************/
@isTest
private class QuarterlyDataEditControllerTests {
    public static List<Ws_Tab_Quarterly_Data__c> testLines;
    public static List<Ws_Tab_Quarterly_Data__c> prodLines;
    public static User u {get; set;}

    static{
        populateTestData();
    }
    
    @isTest
    static void deleteAllItemsShouldWorkProperly(){
        System.runAs(u){
            Test.startTest();
                QuarterlyDataEditController faq = new QuarterlyDataEditController();
                System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Quarterly_Data_Item__c WHERE Ws_Tab_Quarterly_Data__c =: testLines[0].id]);

                //Mark all items for deletion
                for (QuarterlyDataItemModel iw : faq.items) {
                    iw.IsDeleted = true;
                }

        
                faq.saveAndSubmit();
            

                Test.stopTest();

        }
    }

    @isTest
    static void updateAllItemsShouldWorkProperly(){
        System.runAs(u){
            Test.startTest();
                QuarterlyDataEditController faq = new QuarterlyDataEditController();
                System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Quarterly_Data_Item__c WHERE Ws_Tab_Quarterly_Data__c =: testLines[0].id]);

            
                for (QuarterlyDataItemModel iw : faq.items) {
                    iw.InfoText = 'Test';
                }

        
                faq.saveAndPreview();
            
                System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Quarterly_Data_Item__c WHERE Ws_Tab_Quarterly_Data__c =: testLines[0].id]);

                Test.stopTest();
    
        }
    }

    @isTest
    static void updateAllShouldFailIfSortingOrderIsNotUnique(){
        System.runAs(u){
            Test.startTest();
                QuarterlyDataEditController faq = new QuarterlyDataEditController();
                
            
                for (QuarterlyDataItemModel iw : faq.items) {
                    iw.OrderNumber = 1;
                }

        
                faq.saveAndSubmit();
            

                Test.stopTest();

        }
    }


    


    @isTest
    static void restoreShouldWorkFine(){
        System.runAs(u){

            PageReference pageRef = Page.QuarterlyDataEdit;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('restore', 'true');
            ApexPages.currentPage().getParameters().put('id', [SELECT ID FROM Ws_Tab_Quarterly_Data__c WHERE State__c = 'Approved'][0].id);


            Test.startTest();
                QuarterlyDataEditController faq = new QuarterlyDataEditController();
        
        
                faq.saveAndSubmit();
            

                Test.stopTest();

        }
    }

    @isTest
    static void uploadDocShouldReturnValidPR(){
        System.runAs(u){


            Test.startTest();
                QuarterlyDataEditController faq = new QuarterlyDataEditController();
                
                System.assert(faq.uploadDoc().getUrl().contains('/apex/UploadABSDocument?id='));
                System.assert(faq.uploadDoc().getUrl().contains('&page=QData'));
                
                Test.stopTest();

        }
    }

    @isTest
    static void addShouldReturnValidPR(){
        System.runAs(u){


            Test.startTest();
                QuarterlyDataEditController faq = new QuarterlyDataEditController();
                
                System.assert(faq.add().getUrl().contains('/apex/UploadABSDocument?page=QData'));
                
                Test.stopTest();

        }
    }



    private static void populateTestData(){
        Helper.insertRecords();

        testLines = [SELECT Id FROM Ws_Tab_Quarterly_Data__c WHERE State__c = 'Sent For Review'];
        prodLines = [SELECT Id FROM Ws_Tab_Quarterly_Data__c WHERE State__c = 'Approved'];

        List<Ws_Tab_Quarterly_Data_Item__c> testItems = new List<Ws_Tab_Quarterly_Data_Item__c>();
        List<Ws_Tab_Quarterly_Data_Item__c> productionItems = new List<Ws_Tab_Quarterly_Data_Item__c>();
        

        for(Integer i = 0; i < 10; i++){
            

            Ws_Tab_Quarterly_Data_Item__c testTmp = new Ws_Tab_Quarterly_Data_Item__c(Ws_Tab_Quarterly_Data__c = testLines[0].id, Order_Number__c = i);
            testItems.add(testTmp);

            Ws_Tab_Quarterly_Data_Item__c prodTmp = new Ws_Tab_Quarterly_Data_Item__c(Ws_Tab_Quarterly_Data__c = prodLines[0].id, Order_Number__c = i, Info_Text__c = 'prod');
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