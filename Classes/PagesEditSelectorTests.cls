/**********************************************************************
Name: PagesEditSelectorTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a test class for PagesEditSelectorController.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/6/2015 Created 
***********************************************************************/
@isTest
public class PagesEditSelectorTests {
    public static User u {get; set;}
    static{
        populateTestData();
    }

    @isTest
    static void PageSelectorController_ShouldCreateValidSelectOptions(){
        System.runAs(u){
            Helper.insertRecords();
            Test.startTest();
                PageEditSelectorController psc = new PageEditSelectorController();
                
                System.assert(psc.pages[0].getValue().contains('/apex/HomepageEdit?sfdc.tabName=01rM00000009E97')); 
                
            Test.stopTest();
        }
    }

    @isTest
    static void PageSelectorRedirect_ShouldReturnValidPageReference(){
        System.runAs(u){
            Helper.insertRecords();
            Test.startTest();
                PageEditSelectorController psc = new PageEditSelectorController();
                
                System.assertEquals(null, psc.redirectToEditPage()); 

                psc.linkToEditPage = '/apex/HomepageEdit?sfdc.tabName=01rM00000009E97';

                System.assert(psc.redirectToEditPage().getUrl().contains('/apex/HomepageEdit?sfdc.tabName=01rM00000009E97')); 
                
            Test.stopTest();
        }
    }

    private static void populateTestData(){

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