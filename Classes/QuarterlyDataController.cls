/**********************************************************************
Name: QuarterlyDataController
Copyright � notice: NMAC.
======================================================
Purpose:
This is a controller for QuarterlyData page
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/14/2015 Created 
***********************************************************************/
public class QuarterlyDataController {
    public QuarterlyDataModel qData { get; set; }
    public List <QuarterlyDataItemModel > items { get; set; }
    public Boolean IsComponentsAvailable { get; set; }
    public Boolean isProd { get; set; }

    public QD_Components_Available__c qd { get; set; }


    public String AbsLink {
        get {
            if (isProd) {
                return LinksManager.GetUrlForPage('ABS');
            }
            else {
                return LinksManager.GetUrlForPage('ABS?version=test');
            }
        }
    }

    public String HomeLink {
        get {
            if (isProd) {
                return LinksManager.GetUrlForPage('Home');
            }
            else {
                return LinksManager.GetUrlForPage('Home?version=test');
            }
        }
    }

    public String QuarterlyDataLink {
        get {
            if (isProd) {
                return LinksManager.GetUrlForPage('Quarterly_Data');
            }
            else {
                return LinksManager.GetUrlForPage('Quarterly_Data?version=test');
            }
        }
    }
    public String PresentationsLink {
        get {
            if (isProd) {
                return LinksManager.GetUrlForPage('Presentations');
            }
            else {
                return LinksManager.GetUrlForPage('Presentations?version=test');
            }
        }
    }

    public String FAQLink {
        get {
            if (isProd) {
                return LinksManager.GetUrlForPage('FAQ');
            }
            else {
                return LinksManager.GetUrlForPage('FAQ?version=test');
            }
        }
    }

    public QuarterlyDataController() {
        Ws_Tab_Quarterly_Data__c qDataObject;

        if (LinksManager.IsPublicSite()) {
            String qRecordTypeId = Schema.SObjectType.Ws_Tab_Quarterly_Data__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
            qDataObject = [SELECT Id, Comments__c, Header_Text__c, State__c FROM Ws_Tab_Quarterly_Data__c WHERE RecordtypeId = :qRecordTypeId AND State__c = 'Approved'] [0];
            isProd = true;
        } else if (ApexPages.currentPage().getParameters().get('id') != null) {
            qDataObject = [SELECT Id, Comments__c, Header_Text__c, State__c FROM Ws_Tab_Quarterly_Data__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')] [0];
            isProd = false;
        }
        else {
            if (ApexPages.currentPage().getParameters().get('version') == 'test') {
                String qRecordTypeId = Schema.SObjectType.Ws_Tab_Quarterly_Data__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
                qDataObject = [SELECT Id, Comments__c, Header_Text__c, State__c FROM Ws_Tab_Quarterly_Data__c WHERE RecordtypeId = :qRecordTypeId AND State__c = 'Sent For Review'] [0];
                isProd = false;
            }
            else {
                String qRecordTypeId = Schema.SObjectType.Ws_Tab_Quarterly_Data__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
                qDataObject = [SELECT Id, Comments__c, Header_Text__c, State__c FROM Ws_Tab_Quarterly_Data__c WHERE RecordtypeId = :qRecordTypeId AND State__c = 'Approved'] [0];
                isProd = true;
            }
        }

        qData=QuarterlyDataModel.fromObject(qDataObject);

        items = new List <QuarterlyDataItemModel > ();
        for (Ws_Tab_Quarterly_Data_Item__c it :[SELECT Document__c, Document__r.Link__c, Info_Text__c, Order_Number__c FROM Ws_Tab_Quarterly_Data_Item__c WHERE Ws_Tab_Quarterly_Data__c = :qData.Implementation.id ORDER BY Order_Number__c])
        {
            items.add(QuarterlyDataItemModel.fromObject(it));
        }
        if (items.isEmpty()) {
            IsComponentsAvailable = false;
        }
        else {
            IsComponentsAvailable = true;
        }

        qd = QD_Components_Available__c.getOrgDefaults();

    }
}