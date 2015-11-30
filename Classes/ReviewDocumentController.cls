/**********************************************************************
  Name: ReviewDocumentController
  Copyright � notice: NMAC.
  ======================================================
  Purpose:
  This is an apex class to redirect user to direct document uploaded for
  Quarterly Data or Presentations page.
 
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL
  1.0 - Arshakyan Georgiy 5/18/2015 Created 
  ***********************************************************************/
public without sharing class ReviewDocumentController {
    private String page { get; set; }
    private String documentLink { get; set; }

    public ReviewDocumentController() {
        page = ApexPages.currentPage().getParameters().get('page');

        if (page == 'QData') {
            initializeForQData();
        }
        if (page == 'Pres') {
            initializeForPresentations();
        }
    }

    public Pagereference redirect() {
        PageReference pageRef = new PageReference(documentLink);
        pageRef.setRedirect(true);
        return pageRef;

    }

    private void initializeForQData() {
        Ws_Tab_Quarterly_Data_Item__c qItem = [SELECT Document__c, Document__r.Link__c, Info_Text__c, Order_Number__c FROM Ws_Tab_Quarterly_Data_Item__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')] [0];
        documentLink = qItem.Document__r.Link__c;
    }

    private void initializeForPresentations() {
        Ws_Tab_Presentation_Item__c pItem = [SELECT Document__c, Document__r.Link__c, Item_Text__c, Order_Number__c, Presentation_Image__c, Presentation_Image__r.Link__c FROM Ws_Tab_Presentation_Item__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')] [0];
        String typeOfDoc = ApexPages.currentPage().getParameters().get('type');
        if (typeOfDoc == 'Doc') {
            documentLink = pItem.Document__r.Link__c;
        }
        if (typeOfDoc == 'Image') {
            documentLink = pItem.Presentation_Image__r.Link__c;
        }
    }
}