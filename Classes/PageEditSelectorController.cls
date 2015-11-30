/**********************************************************************
Name: PageEditSelectorController
Copyright � notice: NMAC.
======================================================
Purpose:
This is controller for "PagesEditSelector" page
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/5/2015 Created 
***********************************************************************/
public class PageEditSelectorController {
    public Ws_Tab_Home__c homeTab {get; set;}
    public Ws_Tab_abs__c absTab {get; set;}
    public Ws_Tab_Faq__c faqTab {get; set;}
    public Ws_Tab_Presentations__c presentationTab {get; set;}
    public Ws_Tab_Quarterly_Data__c quarterlyTab {get; set;}
    public String linkToEditPage {get; set;}
    public List<SelectOption> pages {get; set;}

    public PageEditSelectorController(){
        String homeTestRecordTypeId = Schema.SObjectType.Ws_Tab_Home__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
        String absTestRecordTypeId = Schema.SObjectType.Ws_Tab_abs__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
        String faqTestRecordTypeId = Schema.SObjectType.Ws_Tab_Faq__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
        String presentationTestRecordTypeId = Schema.SObjectType.Ws_Tab_Presentations__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
        String qdataTestRecordTypeId = Schema.SObjectType.Ws_Tab_Quarterly_Data__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();

        homeTab = [SELECT Id, Name FROM Ws_Tab_Home__c WHERE RecordtypeId= :homeTestRecordTypeId AND State__c = 'Sent For Review'][0];
        absTab = [SELECT Id, Name FROM Ws_Tab_abs__c WHERE RecordtypeId= :absTestRecordTypeId AND State__c = 'Sent For Review' LIMIT 1][0];
        faqTab = [SELECT Id, Name FROM Ws_Tab_Faq__c WHERE RecordtypeId= :faqTestRecordTypeId AND State__c = 'Sent For Review' LIMIT 1][0];
        presentationTab = [SELECT Id, Name FROM Ws_Tab_Presentations__c WHERE RecordtypeId= :presentationTestRecordTypeId AND  State__c = 'Sent For Review' LIMIT 1][0];
        quarterlyTab = [SELECT Id, Name FROM Ws_Tab_Quarterly_Data__c WHERE RecordtypeId= :qdataTestRecordTypeId AND State__c = 'Sent For Review' LIMIT 1][0];
    

        Pages_Available__c settings = Pages_Available__c.getOrgDefaults();

        pages = new List<SelectOption>();
        if(settings.Is_Home_Available__c){
            pages.add(new SelectOption('/apex/HomepageEdit?sfdc.tabName=01rM00000009E97' , 'Home'));
        }
        if(settings.Is_ABS_Available__c){
            pages.add(new SelectOption('/apex/ABSPageEdit?sfdc.tabName=01rM00000009E97', 'ABS'));
        }
        if(settings.Is_FAQ_Available__c){
            pages.add(new SelectOption('/apex/FAQEdit?sfdc.tabName=01rM00000009E97', 'FAQ'));
        }
        if(settings.Is_Presentations_Available__c){
            pages.add(new SelectOption('/apex/PresentationsEdit?sfdc.tabName=01rM00000009E97', 'Presentation'));
        }
        if(settings.Is_QD_Available__c){
            pages.add(new SelectOption('/apex/QuarterlyDataEdit?sfdc.tabName=01rM00000009E97', 'Quarterly Data'));
        }
        if(settings.Is_Footer_Available__c){
            pages.add(new SelectOption('/apex/FooterEdit?sfdc.tabName=01rM00000009E97', 'Footer'));
        }
    }

    public Pagereference redirectToEditPage(){
        if(linkToEditPage == null){
            return null;
        }
        else{
            PageReference pageRef = new PageReference(linkToEditPage);
            pageRef.setRedirect(true);

            return pageRef;   
        }
    
    }

 }