/**********************************************************************
  Name: FooterApprovalController
  Copyright � notice: NMAC.
  ======================================================
  Purpose:
  This is a controller for "FooterApproval" page
 
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL
  1.0 - Arshakyan Georgiy 6/11/2015 Created 
  ***********************************************************************/
public class FooterApprovalController {
    private Footer__c testFooter { get; set; }
    private Footer__c prodFooter { get; set; }
    public String Comments { get; set; }
    public String testFooterDocumentLink {get; set;}
    public String productionFooterDocumentLink {get; set;}

    public Boolean isUserAreApprover { get; set; }
    private Reviewer_Email__c reviewerEmail { get; set; }

    public FooterApprovalController() {
        reviewerEmail = Reviewer_Email__c.getOrgDefaults();

        if (reviewerEmail.Email__c != [SELECT Email, Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1] [0].Email) {
            isUserAreApprover = false;
        }
        else {
            isUserAreApprover = true;
            testFooter = [SELECT Id, Document__c, LastModifiedById, Document__r.Link__c, Comments__c, Investor_Relations_Website__c FROM Footer__c WHERE State__c = 'Sent For Review'][0];
            prodFooter = [SELECT Id, Document__c, LastModifiedById, Document__r.Link__c, Comments__c, Investor_Relations_Website__c FROM Footer__c WHERE State__c = 'Approved'][0];
            Comments = '';

            testFooterDocumentLink = testFooter.Document__r.Link__c;
            productionFooterDocumentLink = prodFooter.Document__r.Link__c;
        }
    }

    public Pagereference approve() {    
        sendEmail(testFooter.LastModifiedById, false);
        
        Footer__c updatedTestFooter = cloneTestFooter();
        insert updatedTestFooter;

        approveCurrentTest();
        deleteCurrentProd();
        return redirectHome();
    }

    public Pagereference reject() {
        sendEmail(testFooter.LastModifiedById, true);
        addCommentsToTest();
        return redirectHome();
    }

    private Footer__c cloneTestFooter() {
        Footer__c updatedTestFooter = new Footer__c();
        updatedTestFooter.State__c = 'Sent For Review';
        updatedTestFooter.Document__c = testFooter.Document__c;
        updatedTestFooter.Name = 'Footer';
        updatedTestFooter.Investor_Relations_Website__c = testFooter.Investor_Relations_Website__c;

        return updatedTestFooter;
    }

    private void approveCurrentTest() {
        testFooter.State__c = 'Approved';
        testFooter.Comments__c = Comments;
        update testFooter;
    }

    private void addCommentsToTest(){
        testFooter.Comments__c = Comments;
        update testFooter;
    }

    private void deleteCurrentProd() {
        delete prodFooter;
    }

    private Pagereference redirectHome(){
        PageReference pageRef = new PageReference('/');
        pageRef.setRedirect(true);
        return pageRef;
    }

    private void sendEmail(Id UserToSend, Boolean isRejected) {
        String userEmail = [SELECT Email FROM User WHERE Id = :UserToSend] [0].Email;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String[] toAddresses = new String[] { userEmail };
        mail.setToAddresses(toAddresses);

        if (isRejected) {
            mail.setSubject('Investor Relation footer document was Rejected');
            mail.setPlainTextBody('Investor Relation footer document was Rejected and following comments added: ' + Comments);
            mail.setHtmlBody('Investor Relation footer document was Rejected and following comments added: ' + '<b>' + Comments + '</b>');
        }
        else {
            mail.setSubject('Investor Relation footer document Approved and Deployed to Production');
            mail.setPlainTextBody('Investor Relation footer document Approved and Deployed to Production');
            mail.setHtmlBody('Investor Relation footer document Approved and Deployed to Production');
        }

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
 }