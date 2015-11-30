/**********************************************************************
  Name: TermsAndConditionsController
  Copyright � notice: NMAC.
  ======================================================
  Purpose:
  This is an apex class to redirect user to T&C document, stored in Footer__c object
 
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL
  1.0 - Arshakyan Georgiy 6/10/2015 Created 
  ***********************************************************************/
public class TermsAndConditionsController {
    private String documentLink {get; set;}

    public TermsAndConditionsController() {
        if(ApexPages.currentPage().getParameters().get('version') == 'test'){
            initializeForTest();
        }
        else{
            initializeForProd();
        }

    }

    public Pagereference redirect() {
        PageReference pageRef = new PageReference(documentLink);
        pageRef.setRedirect(true);
        return pageRef;

    }

    private void initializeForTest() {
        Footer__c footer = [SELECT Document__c, Document__r.Link__c FROM Footer__c WHERE State__c = 'Sent For Review'][0];
        documentLink = footer.Document__r.Link__c;
    }

    private void initializeForProd() {
        Footer__c footer = [SELECT Document__c, Document__r.Link__c FROM Footer__c WHERE State__c = 'Approved'][0];
        documentLink = footer.Document__r.Link__c;
    }
 }