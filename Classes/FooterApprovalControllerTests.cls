/**********************************************************************
Name: FooterApprovalControllerTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a test class for FooterApprovalController.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/8/2015 Created 
***********************************************************************/
@isTest
public class FooterApprovalControllerTests {
    public static Footer__c absTest {get; set;}
    public static Footer__c absProduction {get; set;}
    public static Investor_Relation_Website__c ws {get; set;}
    public static Reviewer_Email__c reviewerEmail {get; set;}
    public static Document_Proxy__c dp {get; set;}

    public static User u {get; set;}

    static{
        populateTestData();
    }

    @isTest
    static void approverPressApproveShouldUpdateProd(){
        System.runAs(u){
            Test.startTest();
            FooterApprovalController hmPg = new FooterApprovalController();
            hmPg.approve();
            Test.stopTest();

            System.assertEquals([SELECT Count() FROM Footer__c WHERE Name = 'Footer'], 1);
            System.assertEquals([SELECT Count() FROM Footer__c ], 2);
        }
    }

    @isTest
    static void approvedPressRejectApproveShouldNotUpdateProd(){
        clearData();
        populateTestData();

        System.runAs(u){
            Test.startTest();
            FooterApprovalController hmPg = new FooterApprovalController();
            hmPg.reject();
            Test.stopTest();

            System.assertEquals([SELECT Count() FROM Footer__c WHERE Name = 'Footer'], 0);
            System.assertEquals([SELECT Count() FROM Footer__c], 2);
        }
        
    }

    private static void clearData(){
        delete ws;
        delete dp;
    }

    private static void populateTestData(){
        ws  = new Investor_Relation_Website__c();
        insert ws;

        dp = new Document_Proxy__c(Link__c = '/');
        insert dp;

        absTest  = new Footer__c(Investor_Relations_Website__c = ws.id,
                                       State__c = 'Sent For Review',
                                       Document__c = dp.id);
        insert absTest;

        absProduction  = new Footer__c(Investor_Relations_Website__c = ws.id,
                                       State__c = 'Approved',
                                       Document__c = dp.id);
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