/**********************************************************************
Name: FAQLineItemModel
Copyright � notice: NMAC.
======================================================
Purpose:
This is an apex representation of Ws_Tab_Faq_Line_Item sObject
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/20/2015 Created
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev 
***********************************************************************/
public class FAQLineItemModel {
public final Ws_Tab_Faq_Line_Item__c Implementation { get; private set; }

    public String Answer { get; set; }
    public String Question { get; set; }
    public Decimal OrderNumber { get; set; }
    public Boolean IsDeleted { get; set; }
    public Id FaqLineId { get; set; }

    public FAQLineItemModel(Ws_Tab_Faq_Line_Item__c obj) {
        Implementation = obj;
        parseFromObject();
    }

    public FAQLineItemModel() {
        Implementation = new Ws_Tab_Faq_Line_Item__c();
        parseFromObject();
    }

    private void parseFromObject() {
        Answer=Implementation.Answer__c;
        IsDeleted= false;
        OrderNumber=Implementation.Order_Number__c;
        Question=Implementation.Question__c;
        FaqLineId=Implementation.Ws_Tab_Faq_Line__c;
    }

    public Ws_Tab_Faq_Line_Item__c toObject() {
        Implementation.Answer__c=Answer;
        Implementation.Order_Number__c=OrderNumber;
        Implementation.Question__c=Question;
        Implementation.Ws_Tab_Faq_Line__c=FaqLineId;

        return Implementation;
    }

    public static FAQLineItemModel fromObject(Ws_Tab_Faq_Line_Item__c obj) {
        return new FAQLineItemModel(obj);
    }

}