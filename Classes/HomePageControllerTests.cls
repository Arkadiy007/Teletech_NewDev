/**********************************************************************
Name: HomePageControllerTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a test class for HomePageController.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/19/2015 Created 
***********************************************************************/
@isTest
public class HomePageControllerTests {

    public static User u {get; set;}

    static{
        populateTestData();
    }
    
    @isTest
    static void testLinksAreWorkingForProd(){
        System.runAs(u){
            Test.startTest();
                HomePageController abs = new HomePageController();
                System.Assert(abs.AbsLink.contains('/apex/ABS'));
                System.Assert(abs.HomeLink.contains('/apex/Home'));
                System.Assert(abs.QuarterlyDataLink.contains('/apex/Quarterly_Data'));
                System.Assert(abs.PresentationsLink.contains('/apex/Presentations'));
                System.Assert(abs.FAQLink.contains('/apex/FAQ'));
                System.Assert(abs.isProd);
            Test.stopTest();

        }
    }
    
    @isTest
    static void testLinksAreWorkingForTest(){
        System.runAs(u){
            PageReference pageRef = Page.Home;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('version', 'test');

            Test.startTest();
                HomePageController abs = new HomePageController();
                
                System.Assert(abs.AbsLink.contains('/apex/ABS?version=test'));
                System.Assert(abs.HomeLink.contains('/apex/Home?version=test'));
                System.Assert(abs.QuarterlyDataLink.contains('/apex/Quarterly_Data?version=test'));
                System.Assert(abs.PresentationsLink.contains('/apex/Presentations?version=test'));
                System.Assert(abs.FAQLink.contains('/apex/FAQ?version=test'));
                System.Assert(!abs.isProd);
            Test.stopTest();

        }
    }  

    @isTest
    static void testLinksAreWorkingForHistorical(){
        System.runAs(u){
            PageReference pageRef = Page.Home;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('id', [SELECT Id FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review'][0].id);

            Test.startTest();
                HomePageController abs = new HomePageController();
                
                System.Assert(abs.AbsLink.contains('/apex/ABS?version=test'));
                System.Assert(abs.HomeLink.contains('/apex/Home?version=test'));
                System.Assert(abs.QuarterlyDataLink.contains('/apex/Quarterly_Data?version=test'));
                System.Assert(abs.PresentationsLink.contains('/apex/Presentations?version=test'));
                System.Assert(abs.FAQLink.contains('/apex/FAQ?version=test'));
                System.Assert(!abs.isProd);
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
            u = new User(profileId = p.id, username = 'test122sdasdsdas2@test.com', email = 'testxczxczxczasdas1222@test.com',
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname');
        

        
            insert u;
        }
    }
 
 }