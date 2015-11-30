/**********************************************************************
Name: HelperTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a test class for Helper.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/21/2015 Created 
***********************************************************************/
@isTest
public class HelperTests {
    public static User u {get; set;}

    static{

        populateTestData();
    }

    @isTest
    static void helperClassShouldInsertRecordsIfThereArenotPresented(){
        System.runAs(u){
            System.assertEquals(0, [SELECT Count() FROM Ws_Tab_Home__c]);
            System.assertEquals(0, [SELECT Count() FROM Investor_Relation_Website__c]);
            System.assertEquals(0, [SELECT Count() FROM Reviewer_Email__c]);
            System.assertEquals(0, [SELECT Count() FROM Ws_Tab_Abs_Line__c]);

            Test.startTest();
                Helper.insertRecords();
            Test.stopTest();

            System.assertEquals(2, [SELECT Count() FROM Ws_Tab_Home__c]);
            System.assertEquals(1, [SELECT Count() FROM Investor_Relation_Website__c]);
            System.assertEquals(1, [SELECT Count() FROM Reviewer_Email__c]);
            System.assertEquals(6, [SELECT Count() FROM Ws_Tab_Abs_Line__c]);
        }
    }


    @isTest
    static void helperClassShouldDoNothingIfWSIsAlreadyCreated(){
        System.runAs(u){
            
            Investor_Relation_Website__c website = new Investor_Relation_Website__c();
            website.Name = 'Investor Relations Website';
            insert website;
            
            System.assertEquals(0, [SELECT Count() FROM Ws_Tab_Home__c]);
            System.assertEquals(1, [SELECT Count() FROM Investor_Relation_Website__c]);
            System.assertEquals(0, [SELECT Count() FROM Reviewer_Email__c]);
            System.assertEquals(0, [SELECT Count() FROM Ws_Tab_Abs_Line__c]);

            Test.startTest();
                Helper.insertRecords();
            Test.stopTest();

            System.assertEquals(0, [SELECT Count() FROM Ws_Tab_Home__c]);
            System.assertEquals(1, [SELECT Count() FROM Investor_Relation_Website__c]);
            System.assertEquals(0, [SELECT Count() FROM Reviewer_Email__c]);
            System.assertEquals(0, [SELECT Count() FROM Ws_Tab_Abs_Line__c]);
        }
    }




    private static void populateTestData(){

        Profile p = [select id
                      from profile
                      where Name = 'System Administrator'
                      limit 1];  
        
        if(u == null){
            u = new User(profileId = p.id, username = 'test1ASDSHKDASsx222@test.com', email = 'tesdasdae2est1222@test.com',
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname');
        

        
            insert u;
        
        }
        
    }
 }