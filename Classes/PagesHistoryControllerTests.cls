/**********************************************************************
Name: PagesHistoryControllerTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a test class for PagesHistoryController.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/20/2015 Created 
***********************************************************************/
@isTest
private class PagesHistoryControllerTests
{
    public static User u {get; set;}
    public static Ws_Tab_Presentation_Item__c pItem {get; set;}
    public static Ws_Tab_Quarterly_Data_Item__c qdItem {get; set;}
    static{
        populateTestData();
    }

    @isTest
    static void testHLinkistoryForHome(){
        System.runAs(u){

            Test.startTest();
            PagesHistoryController history = new PagesHistoryController();
            history.linkToEditPage = 'Home';
            System.assert(history.redirectToEditPage().getUrl().contains('/apex/PagesHistory?page=Home'));
        }
    }
    @isTest
    static void testHLinkistoryForABS(){
        System.runAs(u){

            Test.startTest();
            PagesHistoryController history = new PagesHistoryController();
            history.linkToEditPage = 'ABS';
            System.assert(history.redirectToEditPage().getUrl().contains('/apex/PagesHistory?page=ABS'));
        }
    }
    @isTest
    static void testHLinkistoryForFAQ(){
        System.runAs(u){

            Test.startTest();
            PagesHistoryController history = new PagesHistoryController();
            history.linkToEditPage = 'FAQ';
            System.assert(history.redirectToEditPage().getUrl().contains('/apex/PagesHistory?page=FAQ'));
        }
    }
    @isTest
    static void testHLinkistoryForQData(){
        System.runAs(u){

            Test.startTest();
            PagesHistoryController history = new PagesHistoryController();
            history.linkToEditPage = 'Presentation';
            System.assert(history.redirectToEditPage().getUrl().contains('/apex/PagesHistory?page=Presentation'));
        }
    }
    @isTest
    static void testHLinkistoryForPres(){
        System.runAs(u){

            Test.startTest();
            PagesHistoryController history = new PagesHistoryController();
            history.linkToEditPage = 'QuarterlyData';
            System.assert(history.redirectToEditPage().getUrl().contains('/apex/PagesHistory?page=QuarterlyData'));
        }
    }

    @isTest
    static void testHistoryForHome(){
        
        PageReference pageRef = Page.PagesHistory;
        Test.setCurrentPage(pageRef);
            
        ApexPages.currentPage().getParameters().put('page', 'Home');


        System.runAs(u){

            Test.startTest();
            PagesHistoryController history = new PagesHistoryController();
            System.assert(history.records[0].Link.contains('/apex/Home?id='));
            System.assert(history.records[1].RestorationLink.contains('/apex/HomepageEdit?id='));
            System.assert(history.PageName.contains('Home'));
        }
    }



    
    private static void populateTestData(){
        Helper.insertRecords();

        Ws_Tab_Abs__c abs = [SELECT Id, Overview__c, State__c FROM Ws_Tab_Abs__c WHERE State__c = 'Approved'][0];
            abs.Overview__c = 'Rejected Page Overview';
            abs.State__c = 'Rejected';

        Ws_Tab_Home__c home = [SELECT Id, Information_Text__c, State__c FROM Ws_Tab_Home__c WHERE State__c = 'Approved'][0];
            home.Information_Text__c = 'Rejected Page Overview';
            home.State__c = 'Rejected';

        Ws_Tab_Faq__c faq = [SELECT Id, Comments__c, State__c FROM Ws_Tab_Faq__c WHERE State__c = 'Approved'][0];
            faq.Comments__c = 'Rejected Page Overview';
            faq.State__c = 'Rejected';

        Ws_Tab_Quarterly_Data__c qData = [SELECT Id, Header_Text__c, State__c FROM Ws_Tab_Quarterly_Data__c WHERE State__c = 'Approved'][0];
            qData.Header_Text__c = 'Rejected Page Overview';
            qData.State__c = 'Rejected';

        Ws_Tab_Presentations__c pres = [SELECT Id, Header_Text__c, State__c FROM Ws_Tab_Presentations__c WHERE State__c = 'Approved'][0];
            pres.Header_Text__c = 'Rejected Page Overview';
            pres.State__c = 'Rejected';


        Ws_Tab_Abs__c absTest = [SELECT Id, Overview__c, State__c FROM Ws_Tab_Abs__c WHERE State__c = 'Sent For Review'][0];
            absTest.Overview__c = 'Rejected Page Overview';
            absTest.State__c = 'Rejected';

        Ws_Tab_Home__c homeTest = [SELECT Id, Information_Text__c, State__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0];
            homeTest.Information_Text__c = 'Rejected Page Overview';
            homeTest.State__c = 'Rejected';

        Ws_Tab_Faq__c faqTest = [SELECT Id, Comments__c, State__c FROM Ws_Tab_Faq__c WHERE State__c = 'Sent For Review'][0];
            faqTest.Comments__c = 'Rejected Page Overview';
            faqTest.State__c = 'Rejected';

        Ws_Tab_Quarterly_Data__c qDataTest = [SELECT Id, Header_Text__c, State__c FROM Ws_Tab_Quarterly_Data__c WHERE State__c = 'Sent For Review'][0];
            qDataTest.Header_Text__c = 'Rejected Page Overview';
            qDataTest.State__c = 'Rejected';

        Ws_Tab_Presentations__c presTest = [SELECT Id, Header_Text__c, State__c FROM Ws_Tab_Presentations__c WHERE State__c = 'Sent For Review'][0];
            presTest.Header_Text__c = 'Rejected Page Overview';
            presTest.State__c = 'Rejected';




        update abs;
        update home;
        update faq;
        update qData;
        update pres;

        update absTest;
        update homeTest;
        update faqTest;
        update qDataTest;
        update presTest;

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