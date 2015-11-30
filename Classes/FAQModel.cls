/**********************************************************************
Name: FAQModel
Copyright � notice: NMAC.
======================================================
Purpose:
This is an apex representation of Ws_Tab_Faq sObject
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/20/2015 Created 
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev 
***********************************************************************/
public class FAQModel {
public final Ws_Tab_Faq__c Implementation { get; private set; }

    public String Comments { get; set; }

    public FAQModel(Ws_Tab_Faq__c obj) {
        Implementation = obj;
        parseFromObject();
    }

    private void parseFromObject() {
        Comments = Implementation.Comments__c;
    }

    public Ws_Tab_Faq__c toObject() {
        Implementation.Comments__c=Comments;

        return Implementation;
    }

    public static FAQModel fromObject(Ws_Tab_Faq__c obj) {
        return new FAQModel(obj);
    }
     
}