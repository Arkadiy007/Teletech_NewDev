/**********************************************************************
Name: PresentationItemModel
Copyright � notice: NMAC.
======================================================
Purpose:
This is an apex respresantation of Ws_Tab_Presentations_Item sObject
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/21/2015 Created 
***********************************************************************/
public class PresentationItemModel {
    public final Ws_Tab_Presentation_Item__c Implementation { get; private set; }

    public Id PresentationTab {get; set;}
    public Id ObjectId { get; private set; }
    public Id DocumentId { get; set; }
    public Id PresentationImageId { get; set; }
    public String ItemText { get; set; }
    public Decimal OrderNumber { get; set; }
    public Boolean IsDeleted { get; set; }
    public String DocumentLink { get; private set; }
    public String PresentationImageLink { get; private set; }

    public PresentationItemModel(Ws_Tab_Presentation_Item__c obj) {
        Implementation = obj;
        parseFromObject();
    }

    public PresentationItemModel() {
        Implementation = new Ws_Tab_Presentation_Item__c();
        parseFromObject();
    }

    private void parseFromObject() {
        DocumentId = Implementation.Document__c;
        PresentationImageId = Implementation.Presentation_Image__c;
        IsDeleted = false;
        ItemText = Implementation.Item_Text__c;
        OrderNumber = Implementation.Order_Number__c;
        DocumentLink = LinksManager.GetUrlForDocument(Implementation.Document__r.Link__c);
        PresentationImageLink=LinksManager.GetUrlForDocument(Implementation.Presentation_Image__r.Link__c);
        PresentationTab = Implementation.Ws_Tab_Presentation__c;
        ObjectId = Implementation.Id;
    }

    public Ws_Tab_Presentation_Item__c toObject() {
        Implementation.Document__c = DocumentId;
        Implementation.Presentation_Image__c = PresentationImageId;
        Implementation.Item_Text__c = ItemText;
        Implementation.Order_Number__c = OrderNumber;
        Implementation.Ws_Tab_Presentation__c = PresentationTab;

        return Implementation;
    }

    public static PresentationItemModel fromObject(Ws_Tab_Presentation_Item__c obj) {
        return new PresentationItemModel(obj);
    }
}