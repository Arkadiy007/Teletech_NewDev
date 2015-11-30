/**********************************************************************
Name: PresentationControllerTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a test class for PresentationController.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/19/2015 Created 
***********************************************************************/
@isTest
public class PresentationControllerTests {
    public static User u {get; set;}

    static{
        populateTestData();
    }
    
    @isTest
    static void testLinksAreWorkingForProd(){
        System.runAs(u){
            Test.startTest();
                PresentationsController abs = new PresentationsController();
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
            PageReference pageRef = Page.Presentations;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('version', 'test');

            Test.startTest();
                PresentationsController abs = new PresentationsController();
                
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
            PageReference pageRef = Page.Presentations;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('id', [SELECT Id FROM Ws_Tab_Presentations__c WHERE State__c = 'Sent For Review'][0].id);

            Test.startTest();
                PresentationsController abs = new PresentationsController();
                
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

        Ws_Tab_Presentations__c testP = [SELECT Id, Name FROM Ws_Tab_Presentations__c WHERE State__c = 'Sent For Review'][0];
        Ws_Tab_Presentations__c prpdP = [SELECT Id, Name FROM Ws_Tab_Presentations__c WHERE State__c = 'Approved'][0];

        List<Ws_Tab_Presentation_Item__c> testItems = new List<Ws_Tab_Presentation_Item__c>();
        List<Ws_Tab_Presentation_Item__c> productionItems = new List<Ws_Tab_Presentation_Item__c>();
        
        
        Document_Proxy__c dp1 = new Document_Proxy__c(Name = 'Document', Link__c = '/servlet/servlet.FileDownload?file=xc2sasdaxczs', Document_Extension__c = 'xls');
        Document_Proxy__c dp2 = new Document_Proxy__c(Name = 'Document', Link__c = '/servlet/servlet.FileDownload?file=xsdc2sasdaxczs', Document_Extension__c = 'pdf');
        Document_Proxy__c dp3 = new Document_Proxy__c(Name = 'Document', Link__c = '/servlet/servlet.FileDownload?file=xzxcxc2sasdaxczs', Document_Extension__c = 'lsx');

        insert dp1;
        insert dp2;
        insert dp3;

        Image_Proxy__c ip1 = new Image_Proxy__c(Name = 'Image', Link__c = '/servlet/servlet.ImageServer?id=xzxcxc2sasdaxczs');
        insert ip1;


        for(Integer i = 0; i < 10; i++){
            Ws_Tab_Presentation_Item__c testTmp = new Ws_Tab_Presentation_Item__c(Ws_Tab_Presentation__c = testP.id, Order_Number__c = i);
            testItems.add(testTmp);
            Ws_Tab_Presentation_Item__c prodTmp = new Ws_Tab_Presentation_Item__c(Ws_Tab_Presentation__c = prpdP.id, Order_Number__c = i);
            productionItems.add(prodTmp);
        }
        
        testItems[3].Document__c = dp1.id;
        productionItems[2].Document__c = dp2.id;
        productionItems[8].Document__c = dp3.id;

        testItems[3].Presentation_Image__c = ip1.id;


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