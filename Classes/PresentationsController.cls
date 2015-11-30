/**********************************************************************
    Name: PresentationsController
    Copyright � notice: NMAC.
    ======================================================
    Purpose:
    This is a controller for "Presentations" page
     
    ======================================================
    History: 

    VERSION AUTHOR DATE DETAIL
    1.0 - Arshakyan Georgiy 5/14/2015 Created 
    ***********************************************************************/
    public class PresentationsController {
        public PresentationModel pres {get; set;}
        public List<PresentationItemModel> items {get; set;}
        public Boolean isProd {get; set;}

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
        
        public PresentationsController(){
            Ws_Tab_Presentations__c presObject;

            if (LinksManager.IsPublicSite()) {
                String presRecordTypeId = Schema.SObjectType.Ws_Tab_Presentations__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
                presObject = [SELECT Id, Comments__c, Header_Text__c, State__c FROM Ws_Tab_Presentations__c WHERE RecordtypeId = :presRecordTypeId AND State__c = 'Approved'][0];
                isProd = true;
            } else if(ApexPages.currentPage().getParameters().get('id') != null){
                presObject =  [SELECT Id, Comments__c, Header_Text__c, State__c FROM Ws_Tab_Presentations__c WHERE Id =:ApexPages.currentPage().getParameters().get('id')][0];
                isProd = false; 
            }
            else{
                if(ApexPages.currentPage().getParameters().get('version') == 'test'){
                    String presRecordTypeId = Schema.SObjectType.Ws_Tab_Presentations__c.getRecordTypeInfosByName().get('Test').getRecordTypeId(); 
                    presObject = [SELECT Id, Comments__c, Header_Text__c, State__c FROM Ws_Tab_Presentations__c WHERE RecordtypeId = :presRecordTypeId AND State__c = 'Sent For Review'][0];
                    isProd = false;
                }
                else{
                    String presRecordTypeId = Schema.SObjectType.Ws_Tab_Presentations__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
                    presObject = [SELECT Id, Comments__c, Header_Text__c, State__c FROM Ws_Tab_Presentations__c WHERE RecordtypeId = :presRecordTypeId AND State__c = 'Approved'][0];
                    isProd = true;
                }
            }
            pres=PresentationModel.fromObject(presObject);
            getAllItems();

            
            qd = QD_Components_Available__c.getOrgDefaults();
                
        }

        private void getAllItems(){
            items = new List<PresentationItemModel>();
            
            for(Ws_Tab_Presentation_Item__c it: [SELECT Document__c, Document__r.Link__c, Item_Text__c, Ws_Tab_Presentation__c , Order_Number__c, Presentation_Image__c, Presentation_Image__r.Link__c FROM Ws_Tab_Presentation_Item__c WHERE Ws_Tab_Presentation__c = :pres.Implementation.id ORDER BY Order_Number__c])
            {
                items.add(PresentationItemModel.fromObject(it));    
            }

        }
     }