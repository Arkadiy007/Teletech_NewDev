/**********************************************************************
Name: QuarterlyDataModel
Copyright � notice: NMAC.
======================================================
Purpose:
This is an apex representation of Ws_Tab_Quarterly_Data sObject
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/20/2015 Created 
***********************************************************************/
public class QuarterlyDataModel {
    public final Ws_Tab_Quarterly_Data__c Implementation { get; private set; }

    public String Comments { get; set; }
    public String HeaderText { get; set; }
    public Id ObjectId { get; private set; }

    public QuarterlyDataModel(Ws_Tab_Quarterly_Data__c obj) {
        Implementation = obj;
        parseFromObject();
    }

    private void parseFromObject() {
        Comments = Implementation.Comments__c;
        HeaderText = Implementation.Header_Text__c;
        ObjectId = Implementation.Id;
    }

    public Ws_Tab_Quarterly_Data__c toObject() {
        Implementation.Comments__c = Comments;
        Implementation.Header_Text__c = HeaderText;

        return Implementation;
    }

    public static QuarterlyDataModel fromObject(Ws_Tab_Quarterly_Data__c obj) {
        return new QuarterlyDataModel(obj);
    }
}