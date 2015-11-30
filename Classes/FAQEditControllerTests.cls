/**********************************************************************
Name: FAQEditControllerTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a test class for FAQEditController.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/21/2015 Created 
***********************************************************************/
@isTest
public class FAQEditControllerTests {
    public static List<Ws_Tab_Faq_Line__c> testLines;
    public static List<Ws_Tab_Faq_Line__c> prodLines;
    public static User u {get; set;}

    static{
        populateTestData();
    }
    
    @isTest
    static void deleteAllItemsShouldWorkProperly(){
        System.runAs(u){
            Test.startTest();
                FAQEditController faq = new FAQEditController();
                System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Faq_Line_Item__c WHERE Ws_Tab_Faq_Line__c =: testLines[0].id]);

                //Mark all items for deletion
                for (FAQLineItemModel iw : faq.items) {
                    iw.IsDeleted = true;        
                }
                
                faq.saveAndSubmit();
            

                System.assertEquals(0, [SELECT Count() FROM Ws_Tab_Faq_Line_Item__c WHERE Ws_Tab_Faq_Line__c =: testLines[0].id]);
                Test.stopTest();

        }
    }
    
    @isTest
    static void updateAllItemsShouldWorkProperly(){
        System.runAs(u){
            Test.startTest();
                FAQEditController faq = new FAQEditController();
                System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Faq_Line_Item__c WHERE Ws_Tab_Faq_Line__c =: testLines[0].id]);

                //Change All items
                for (FAQLineItemModel iw : faq.items) {
                    iw.Question = 'true';       
                }
                
                faq.saveAndPreview();
            

                System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Faq_Line_Item__c WHERE Ws_Tab_Faq_Line__c =: testLines[0].id]);
                System.assertEquals('true', [SELECT Question__c FROM Ws_Tab_Faq_Line_Item__c WHERE Ws_Tab_Faq_Line__c =: testLines[0].id][0].Question__c);
                Test.stopTest();

        }
    }

    @isTest
    static void updateAllShouldFailIfSortingOrderIsNotUnique(){
        System.runAs(u){
            Test.startTest();
                FAQEditController faq = new FAQEditController();
                System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Faq_Line_Item__c WHERE Ws_Tab_Faq_Line__c =: testLines[0].id]);

                //Change All items
                for (FAQLineItemModel iw : faq.items) {
                    iw.OrderNumber = 1;     
                }
                faq.save();
                
                System.assert(faq.errorMsg.contains('should be'));
                System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Faq_Line_Item__c WHERE Ws_Tab_Faq_Line__c =: testLines[0].id]);
                System.assertEquals(null, [SELECT Question__c FROM Ws_Tab_Faq_Line_Item__c WHERE Ws_Tab_Faq_Line__c =: testLines[0].id][0].Question__c);
                Test.stopTest();

        }
    }

    @isTest
    static void restoreShouldWorkFine(){
        System.runAs(u){
            System.assertEquals(null, [SELECT Question__c FROM Ws_Tab_Faq_Line_Item__c WHERE Ws_Tab_Faq_Line__c =: testLines[0].id][0].Question__c);

            PageReference pageRef = Page.FAQEdit;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('restore', 'true');
            ApexPages.currentPage().getParameters().put('id', [SELECT ID FROM Ws_Tab_Faq__c WHERE State__c = 'Approved'][0].id);

            Test.startTest();
                FAQEditController faq = new FAQEditController();
                
                
                faq.save();
                
                System.assertEquals('prod', faq.items[0].Question);
                Test.stopTest();

        }
    }

    @isTest
    static void ifNewLineIsNotNull_SaveShouldAddIt(){
        System.runAs(u){
            Test.startTest();
                FAQEditController faq = new FAQEditController();
                System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Faq_Line_Item__c WHERE Ws_Tab_Faq_Line__c =: testLines[0].id]);

                faq.showBAImgLoaderBlock = true;
                faq.newQuestion = new FAQLineItemModel();
                faq.newQuestion.Question = 'test';
                faq.newQuestion.Answer = 'test';
                faq.newQuestion.OrderNumber = 99;

                faq.save();
                
                System.assertEquals(11, [SELECT Count() FROM Ws_Tab_Faq_Line_Item__c WHERE Ws_Tab_Faq_Line__c =: testLines[0].id]);
                Test.stopTest();

        }
    }
    
    


    private static void populateTestData(){
        Helper.insertRecords();

        testLines = [SELECT Id FROM Ws_Tab_Faq_Line__c WHERE Ws_Tab_Faq__c IN (SELECT ID FROM Ws_Tab_Faq__c WHERE State__c = 'Sent For Review')];
        prodLines = [SELECT Id FROM Ws_Tab_Faq_Line__c WHERE Ws_Tab_Faq__c IN (SELECT ID FROM Ws_Tab_Faq__c WHERE State__c = 'Approved')];

        List<Ws_Tab_Faq_Line_Item__c> testItems = new List<Ws_Tab_Faq_Line_Item__c>();
        List<Ws_Tab_Faq_Line_Item__c> productionItems = new List<Ws_Tab_Faq_Line_Item__c>();
        

        for(Integer i = 0; i < 10; i++){
            

            Ws_Tab_Faq_Line_Item__c testTmp = new Ws_Tab_Faq_Line_Item__c(Ws_Tab_Faq_Line__c = testLines[0].id, Order_Number__c = i);
            testItems.add(testTmp);

            Ws_Tab_Faq_Line_Item__c prodTmp = new Ws_Tab_Faq_Line_Item__c(Ws_Tab_Faq_Line__c = prodLines[0].id, Order_Number__c = i, Question__c = 'prod');
            productionItems.add(prodTmp);
        }

        insert testItems;
        insert productionItems;


        Profile p = [select id
                      from profile
                      where Name = 'System Administrator'
                      limit 1];  
        
        if(u == null){
            u = new User(profileId = p.id, username = 'test122sdasdsdas2@test.com', email = 'testxczxczxczasdas1222@test.com',
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname');
        

        
            insert u;
        }
    }
 
 }