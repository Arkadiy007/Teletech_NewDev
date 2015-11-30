/**********************************************************************
Name: HomePageApprovalControllerTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a test class for HomePageApprovalController.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/8/2015 Created 
***********************************************************************/
@isTest
public class HomePageApprovalControllerTests {
    public static Ws_Tab_Home__c absTest {get; set;}
    public static Ws_Tab_Home__c absProduction {get; set;}
    public static Investor_Relation_Website__c ws {get; set;}
    public static Reviewer_Email__c reviewerEmail {get; set;}

    public static  String absTestRecordTypeId {get; set;}
    public static  String absProductionRecordTypeId {get; set;}

    public static User u {get; set;}

    static{
        populateTestData();
    }

    @isTest
    static void approverPressApproveShouldUpdateProd(){
        System.runAs(u){
            Test.startTest();
            HomePageApprovalController hmPg = new HomePageApprovalController();
            hmPg.approve();
            Test.stopTest();

            System.assertEquals([SELECT Count() FROM Ws_Tab_Home__c WHERE Name = 'Home'], 1);
            System.assertEquals([SELECT Count() FROM Ws_Tab_Home__c WHERE RecordtypeId = :absProductionRecordTypeId AND State__c = 'Rejected'], 1);
        }
    }

    @isTest
    static void approvedPressRejectApproveShouldNotUpdateProd(){
        clearData();
        populateTestData();

        System.runAs(u){
            Test.startTest();
            HomePageApprovalController hmPg = new HomePageApprovalController();
            hmPg.reject();
            Test.stopTest();

            System.assertEquals([SELECT Count() FROM Ws_Tab_Home__c WHERE Name = 'Home'], 0);
            System.assertEquals([SELECT Count() FROM Ws_Tab_Home__c WHERE RecordtypeId = :absTestRecordTypeId AND State__c = 'Rejected'], 0);
        }
        
    }

    private static void clearData(){
        delete ws;
    }

    private static void populateTestData(){
        absTestRecordTypeId = Schema.SObjectType.Ws_Tab_Home__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
        absProductionRecordTypeId = Schema.SObjectType.Ws_Tab_Home__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
        
        ws  = new Investor_Relation_Website__c();
        insert ws;

        absTest = new Ws_Tab_Home__c(Name='Test',
                                              Investor_Relations_Website__c = ws.id,
                                              RecordtypeId = absTestRecordTypeId,
                                              State__c = 'Sent For Review');

        insert absTest;

        absProduction = new Ws_Tab_Home__c(Name='Prod',
                                              Investor_Relations_Website__c = ws.id,
                                              RecordtypeId = absProductionRecordTypeId,
                                              State__c = 'Approved');

        insert absProduction;


        if(reviewerEmail == null){
            reviewerEmail = new Reviewer_Email__c(Email__c = 'testxczxczxczasdas1222@test.com');
            insert reviewerEmail;
        }

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