/**********************************************************************
  Name: TermsAndConditionsControllerTests
  Copyright ? notice: NMAC.
  ======================================================
  Purpose:
  This is test class for TermsAndConditionsController.cls
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL
  1.0 - Arshakyan Georgiy 6/11/2015 Created 
  ***********************************************************************/
@isTest
public class TermsAndConditionsControllerTests {
    public static User u {get; set;}
    static{
        populateTestData();
    }

    @isTest
    static void testReviewWorksForTestVersion(){
        System.runAs(u){
            PageReference pageRef = Page.Terms_And_Conditions;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('version', 'test');

            Test.startTest();
            TermsAndConditionsController review = new TermsAndConditionsController();
            
            System.assert(review.redirect().getUrl().contains('/'));
        }
    }

    @isTest
    static void testReviewWorksForProdVersion(){
        System.runAs(u){
            PageReference pageRef = Page.Terms_And_Conditions;
            Test.setCurrentPage(pageRef);

            Test.startTest();
            TermsAndConditionsController review = new TermsAndConditionsController();
            
            System.assert(review.redirect().getUrl().contains('/home'));
        }
    }

    private static void populateTestData(){
        Helper.insertRecords();
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