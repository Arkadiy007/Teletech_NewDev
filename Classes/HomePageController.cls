/**********************************************************************
Name: HomePageController
Copyright � notice: NMAC.
======================================================
Purpose:
This is a controller for "Home" page
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/7/2015 Created 
***********************************************************************/
public class HomePageController {
    public HomeModel home {get; set;}
    public Boolean isProd {get; set;}
    public String bussinessActivitiesLink {get; set;}
    public String spreadsheetImageLink {get; set;}

    public QD_Components_Available__c qd {get; set;}


    public String AbsLink {
        get {
            if(isProd){
                return LinksManager.GetUrlForPage('ABS');
            }
            else{
                return LinksManager.GetUrlForPage('ABS?version=test');
            }
        }
    }

    public String HomeLink {
        get {
            if(isProd){
                return LinksManager.GetUrlForPage('Home');
            }
            else{
                return LinksManager.GetUrlForPage('Home?version=test');
            }
        }
    }

    public String QuarterlyDataLink {
        get {
            if(isProd){
                return LinksManager.GetUrlForPage('Quarterly_Data');
            }
            else{
                return LinksManager.GetUrlForPage('Quarterly_Data?version=test');
            }
        }
    }
    public String PresentationsLink {
        get {
            if(isProd){
                return LinksManager.GetUrlForPage('Presentations');
            }
            else{
                return LinksManager.GetUrlForPage('Presentations?version=test');
            }
        }
    }

    public String FAQLink {
        get {
            if(isProd){
                return LinksManager.GetUrlForPage('FAQ');
            }
            else{
                return LinksManager.GetUrlForPage('FAQ?version=test');
            }
        }
    }

    public HomePageController(){
        Ws_Tab_Home__c homeObject;
        if (LinksManager.IsPublicSite()) {
            String homeRecordTypeId = Schema.SObjectType.Ws_Tab_Home__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
            homeObject = [SELECT Id, Comments__c, Business_Activities_Image__c, Business_Activities_Image__r.Link__c,  Information_Text__c, Spreadsheat_Image__r.Link__c, Ratings_Text__c, Spreadsheat_Image__c FROM Ws_Tab_Home__c WHERE RecordtypeId = :homeRecordTypeId AND State__c = 'Approved'][0];
            
            isProd = true;
        } else if(ApexPages.currentPage().getParameters().get('id') != null){
            homeObject =  [SELECT Id, Comments__c, Business_Activities_Image__c, Business_Activities_Image__r.Link__c,  Information_Text__c, Spreadsheat_Image__r.Link__c, Ratings_Text__c, Spreadsheat_Image__c FROM Ws_Tab_Home__c WHERE Id =:ApexPages.currentPage().getParameters().get('id')][0];
            isProd = false;
        }
        else{
            if(ApexPages.currentPage().getParameters().get('version') == 'test'){
        
                String homeRecordTypeId = Schema.SObjectType.Ws_Tab_Home__c.getRecordTypeInfosByName().get('Test').getRecordTypeId(); 
                homeObject = [SELECT Id, Comments__c, Business_Activities_Image__c, Business_Activities_Image__r.Link__c,  Information_Text__c, Spreadsheat_Image__r.Link__c, Ratings_Text__c, Spreadsheat_Image__c FROM Ws_Tab_Home__c WHERE RecordtypeId = :homeRecordTypeId AND State__c = 'Sent For Review'][0];
                isProd = false;
            }
            else{
        
                String homeRecordTypeId = Schema.SObjectType.Ws_Tab_Home__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
                homeObject = [SELECT Id, Comments__c, Business_Activities_Image__c, Business_Activities_Image__r.Link__c,  Information_Text__c, Spreadsheat_Image__r.Link__c, Ratings_Text__c, Spreadsheat_Image__c FROM Ws_Tab_Home__c WHERE RecordtypeId = :homeRecordTypeId AND State__c = 'Approved'][0];
                isProd = true;
            }
        }

        home=HomeModel.fromObject(homeObject);
        bussinessActivitiesLink = LinksManager.GetUrlForDocument(homeObject.Business_Activities_Image__r.Link__c);
        spreadsheetImageLink = LinksManager.GetUrlForDocument(homeObject.Spreadsheat_Image__r.Link__c);
        qd = QD_Components_Available__c.getOrgDefaults();
    }
 }