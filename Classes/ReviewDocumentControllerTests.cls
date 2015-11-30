/**********************************************************************
Name: ReviewDocumentControllerTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a tests for ReviewDocumentController.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/19/2015 Created 
***********************************************************************/
@isTest
private class ReviewDocumentControllerTests
{

    public static User u {get; set;}
    public static Ws_Tab_Presentation_Item__c pItem {get; set;}
    public static Ws_Tab_Quarterly_Data_Item__c qdItem {get; set;}
    static{
        populateTestData();
    }

    @isTest
    static void testReviewDocumentLinksControllerLinkForQData(){
        System.runAs(u){
            PageReference pageRef = Page.ReviewDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page', 'QData');
            ApexPages.currentPage().getParameters().put('ID', qdItem.id);


            Test.startTest();
            ReviewDocumentController review = new ReviewDocumentController();
            
            System.assert(review.redirect().getUrl().contains('/testDocument2Link?id=Test'));
        }
    }

    @isTest
    static void testReviewDocumentLinksControllerLinkForPres(){
        System.runAs(u){
            PageReference pageRef = Page.ReviewDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page', 'pres');
            ApexPages.currentPage().getParameters().put('ID', pItem.id);
            ApexPages.currentPage().getParameters().put('type', 'Doc');
            Test.startTest();
            ReviewDocumentController review = new ReviewDocumentController();
            
            System.assert(review.redirect().getUrl().contains('/testDocument1Link?id=Test'));
        }
    }

    @isTest
    static void testReviewImageLinksControllerLinkForPres(){
        System.runAs(u){
            PageReference pageRef = Page.ReviewDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page', 'pres');
            ApexPages.currentPage().getParameters().put('ID', pItem.id);
            ApexPages.currentPage().getParameters().put('type', 'Image');
            Test.startTest();
            ReviewDocumentController review = new ReviewDocumentController();
            
            System.assert(review.redirect().getUrl().contains('/testImageLink?id=Test'));
        }
    }
    private static void populateTestData(){
        Helper.insertRecords();

        Document_Proxy__c dp1 = new Document_Proxy__c(Name = 'Test', Link__c='/testDocument1Link?id=Test'); 
        Document_Proxy__c dp2 = new Document_Proxy__c(Name= 'Test2', Link__C='/testDocument2Link?id=Test');

        Image_Proxy__c prox1 = new Image_Proxy__c(Name='Test', Link__c = '/testImageLink?id=Test');
        
        insert dp1;
        insert dp2;
        insert prox1;

        qdItem = new Ws_Tab_Quarterly_Data_Item__c(Order_Number__c = 1, Document__c=dp2.id, Ws_Tab_Quarterly_Data__c = [SELECT Id FROM Ws_Tab_Quarterly_Data__c LIMIT 1][0].id);
        insert qdItem;

        pItem = new Ws_Tab_Presentation_Item__c(Order_Number__c = 1, Document__c = dp1.id, Presentation_Image__c = prox1.id, Ws_Tab_Presentation__c = [SELECT Id FROM Ws_Tab_Presentations__c LIMIT 1][0].id);
        insert pItem;



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