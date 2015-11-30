/**********************************************************************
Name: HomeModel
Copyright � notice: NMAC.
======================================================
Purpose:
This is an apex representation of Ws_Tab_Home sObject
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/20/2015 Created 
***********************************************************************/
public class HomeModel {
    public final Ws_Tab_Home__c Implementation { get; private set; }

    public String Comments { get; set; }
    public String InformationText { get; set; }
    public String RatingsText { get; set; }
    public String BusinessActivitiesImageLink { get; private set; }
    public Id BusinessActivitiesImageId { get; set; }
    public String SpreadsheetImageLink { get; private set; }
    public Id SpreadsheetImageId { get; set; }

    public HomeModel(Ws_Tab_Home__c obj) {
        Implementation = obj;
        parseFromObject();
    }

    private void parseFromObject() {
        Comments = Implementation.Comments__c;
        InformationText = Implementation.Information_Text__c;
        RatingsText = Implementation.Ratings_Text__c;
        BusinessActivitiesImageLink = Implementation.Business_Activities_Image__r.Link__c;
        BusinessActivitiesImageId = Implementation.Business_Activities_Image__c;
        SpreadsheetImageLink = Implementation.Spreadsheat_Image__r.Link__c;
        SpreadsheetImageId=Implementation.Spreadsheat_Image__c;
    }

    public Ws_Tab_Home__c toObject() {
        Implementation.Comments__c=Comments;
        Implementation.Information_Text__c=InformationText;
        Implementation.Ratings_Text__c=RatingsText;
        Implementation.Business_Activities_Image__c=BusinessActivitiesImageId;
        Implementation.Spreadsheat_Image__c=SpreadsheetImageId;

        return Implementation;
    }

    public static HomeModel fromObject(Ws_Tab_Home__c obj) {
        return new HomeModel(obj);
    }
}