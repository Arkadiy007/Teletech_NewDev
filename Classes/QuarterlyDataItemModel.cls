/**********************************************************************
    Name: QuarterlyDataItemModel
    Copyright � notice: NMAC.
    ======================================================
    Purpose:
    This is an apex representation of Ws_Tab_Quarterly_Data_Item sObject
     
    ======================================================
    History: 

    VERSION AUTHOR DATE DETAIL
    1.0 - Arshakyan Georgiy 5/20/2015 Created 
    ***********************************************************************/
    public class QuarterlyDataItemModel {
        public final Ws_Tab_Quarterly_Data_Item__c Implementation { get; private set; }

        public Id ObjectId { get; private set; }
        public Id DocumentId { get; set; }
        public String InfoText { get; set; }
        public Decimal OrderNumber { get; set; }
        public Boolean IsDeleted { get; set; }
        public String DocumentLink { get; private set; }
        public Boolean IsRestored {get; set;}

        public QuarterlyDataItemModel(Ws_Tab_Quarterly_Data_Item__c obj) {
            Implementation = obj;
            parseFromObject();
        }

        public QuarterlyDataItemModel() {
            Implementation = new Ws_Tab_Quarterly_Data_Item__c();
            parseFromObject();
        }

        private void parseFromObject() {
            DocumentId = Implementation.Document__c;
            IsDeleted = false;
            IsRestored = false;
            InfoText = Implementation.Info_Text__c;
            OrderNumber = Implementation.Order_Number__c;
            DocumentLink = LinksManager.GetUrlForDocument(Implementation.Document__r.Link__c);
            ObjectId = Implementation.Id;
        }

        public Ws_Tab_Quarterly_Data_Item__c toObject() {
            Implementation.Document__c = DocumentId;
            Implementation.Info_Text__c = InfoText;
            Implementation.Order_Number__c = OrderNumber;

            return Implementation;
        }

        public static QuarterlyDataItemModel fromObject(Ws_Tab_Quarterly_Data_Item__c obj) {
            return new QuarterlyDataItemModel(obj);
        }
    }