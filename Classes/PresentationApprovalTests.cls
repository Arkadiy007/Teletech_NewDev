/**********************************************************************
Name: PresentationApprovalTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a test class for PresentationApprovalController.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/20/2015 Created 
***********************************************************************/
@isTest
public class PresentationApprovalTests {
    public static Ws_Tab_Presentations__c absTest {get; set;}
    public static Ws_Tab_Presentations__c absProduction {get; set;}
    public static Investor_Relation_Website__c ws {get; set;}
    
    public static Reviewer_Email__c reviewerEmail {get; set;}

    public static  String absTestRecordTypeId {get; set;}
    public static  String absProductionRecordTypeId {get; set;}

    public static List<Ws_Tab_Presentation_Item__c> productionItems {get; set;} 
    public static List<Ws_Tab_Presentation_Item__c> testItems {get; set;}

    public static User u {get; set;}

    static{
        populateTestData();
    }

    @isTest
    static void approverPressApproveShouldUpdateProd(){
        System.runAs(u){
            Test.startTest();
            PresentationsApprovalController pres = new PresentationsApprovalController();
            pres.approve();
            Test.stopTest();

            System.assertEquals([SELECT Count() FROM Ws_Tab_Presentations__c WHERE Name = 'Presentations'], 1);
            System.assertEquals([SELECT Count() FROM Ws_Tab_Presentations__c WHERE RecordtypeId = :absProductionRecordTypeId AND State__c = 'Rejected'], 1);
        }
    }

    @isTest
    static void approvedPressRejectApproveShouldNotUpdateProd(){
        clearData();
        populateTestData();

        System.runAs(u){
            Test.startTest();
            PresentationsApprovalController pres = new PresentationsApprovalController();
            pres.reject();
            Test.stopTest();

            System.assertEquals([SELECT Count() FROM Ws_Tab_Presentations__c WHERE Name = 'Presentations'], 0);
            System.assertEquals([SELECT Count() FROM Ws_Tab_Presentations__c WHERE RecordtypeId = :absTestRecordTypeId AND State__c = 'Rejected'], 0);
        }
        
    }

    private static void clearData(){
        delete ws;
    }

    private static void populateTestData(){
        absTestRecordTypeId = Schema.SObjectType.Ws_Tab_Presentations__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
        absProductionRecordTypeId = Schema.SObjectType.Ws_Tab_Presentations__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
        
        ws  = new Investor_Relation_Website__c();
        insert ws;

        absTest = new Ws_Tab_Presentations__c(Name='Test',
                                              Investor_Relations_Website__c = ws.id,
                                              RecordtypeId = absTestRecordTypeId,
                                              State__c = 'Sent For Review');

        insert absTest;

        absProduction = new Ws_Tab_Presentations__c(Name='Prod',
                                              Investor_Relations_Website__c = ws.id,
                                              RecordtypeId = absProductionRecordTypeId,
                                              State__c = 'Approved');

        insert absProduction;

        testItems = new List<Ws_Tab_Presentation_Item__c>();
        productionItems = new List<Ws_Tab_Presentation_Item__c>();


        for(Integer i = 0; i < 10; i++){
            Ws_Tab_Presentation_Item__c testTmp = new Ws_Tab_Presentation_Item__c(Ws_Tab_Presentation__c = absTest.id);
            testItems.add(testTmp);

            Ws_Tab_Presentation_Item__c prodTmp = new Ws_Tab_Presentation_Item__c(Ws_Tab_Presentation__c = absProduction.id);
            productionItems.add(prodTmp);
        }

        insert testItems;
        insert productionItems;

        if(reviewerEmail == null){
            reviewerEmail = new Reviewer_Email__c(Email__c = 'test12232asdx22@test.com');
            insert reviewerEmail;
        }

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