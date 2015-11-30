/**********************************************************************
Name: PresentationModel
Copyright � notice: NMAC.
======================================================
Purpose:
This is an apex respresantation of Ws_Tab_Presentations sObject
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/21/2015 Created 
***********************************************************************/
public class PresentationModel {
    public final Ws_Tab_Presentations__c Implementation { get; private set; }

    public String Comments { get; set; }
    public String HeaderText { get; set; }
    public Id ObjectId { get; private set; }

    public PresentationModel(Ws_Tab_Presentations__c obj) {
        Implementation = obj;
        parseFromObject();
    }

    private void parseFromObject() {
        Comments = Implementation.Comments__c;
        HeaderText = Implementation.Header_Text__c;
        ObjectId = Implementation.Id;
    }

    public Ws_Tab_Presentations__c toObject() {
        Implementation.Comments__c = Comments;
        Implementation.Header_Text__c = HeaderText;

        return Implementation;
    }

    public static PresentationModel fromObject(Ws_Tab_Presentations__c obj) {
        return new PresentationModel(obj);
    }
}