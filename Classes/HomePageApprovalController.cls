/**********************************************************************
  Name: HomePageApprovalController
  Copyright � notice: NMAC.
  ======================================================
  Purpose:
  This is a controller for "HomePageApproval" page
 
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL
  1.0 - Arshakyan Georgiy 5/8/2015 Created 
  ***********************************************************************/
public class HomePageApprovalController {
    public Ws_Tab_Home__c homeTest { get; set; }
    public String Comments { get; set; }
    public Ws_Tab_Home__c homeProduction { get; set; }
    private String homeTestRecordTypeId { get; set; }
    private String homeProductionRecordTypeId { get; set; }

    public Boolean isUserAreApprover { get; set; }
    private Reviewer_Email__c reviewerEmail { get; set; }

    public HomePageApprovalController() {
        reviewerEmail = Reviewer_Email__c.getOrgDefaults();

        if (reviewerEmail.Email__c != [SELECT Email, Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1] [0].Email) {
            isUserAreApprover = false;

        }
        else {
            isUserAreApprover = true;
            homeTestRecordTypeId = Schema.SObjectType.Ws_Tab_Home__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
            homeTest = [SELECT Id, LastModifiedById, Comments__c, Investor_Relations_Website__c, Business_Activities_Image__c, Business_Activities_Image__r.Link__c, Information_Text__c, Spreadsheat_Image__r.Link__c, Ratings_Text__c, Spreadsheat_Image__c FROM Ws_Tab_Home__c WHERE RecordtypeId = :homeTestRecordTypeId AND State__c = 'Sent For Review'] [0];
            Comments = '';

            homeProductionRecordTypeId = Schema.SObjectType.Ws_Tab_Home__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
            homeProduction = [SELECT Id, Investor_Relations_Website__c, Business_Activities_Image__c, Business_Activities_Image__r.Link__c, Information_Text__c, Spreadsheat_Image__r.Link__c, Ratings_Text__c, Spreadsheat_Image__c FROM Ws_Tab_Home__c WHERE RecordtypeId = :homeProductionRecordTypeId AND State__c = 'Approved'] [0];
        }
    }

    public Pagereference approve() {
        
        sendEmail(homeTest.LastModifiedById, false);
        
        Ws_Tab_Home__c updatedTestHome = cloneHomeTest();
        insert updatedTestHome;

        approveCurrentTest();
        rejectCurrentProduction();

        return redirectHome();
    }

    public Pagereference reject() {
        
        sendEmail(homeTest.LastModifiedById, true);
        
        addCommentsToTest();
        
        return redirectHome();
    }

    private Ws_Tab_Home__c cloneHomeTest() {
        Ws_Tab_Home__c updatedTestHome = new Ws_Tab_Home__c();
        updatedTestHome.RecordtypeId = homeTestRecordTypeId;
        updatedTestHome.State__c = 'Sent For Review';
        updatedTestHome.Business_Activities_Image__c = homeTest.Business_Activities_Image__c;
        updatedTestHome.Information_Text__c = homeTest.Information_Text__c;
        updatedTestHome.Ratings_Text__c = homeTest.Ratings_Text__c;
        updatedTestHome.Spreadsheat_Image__c = homeTest.Spreadsheat_Image__c;
        updatedTestHome.Name = 'Home';
        updatedTestHome.Investor_Relations_Website__c = homeTest.Investor_Relations_Website__c;

        return updatedTestHome;
    }

    private void approveCurrentTest() {

        homeTest.RecordtypeId = homeProductionRecordTypeId;
        homeTest.State__c = 'Approved';
        homeTest.Comments__c = Comments;
        update homeTest;
    }

    private void addCommentsToTest(){
            homeTest.Comments__c = Comments;
            update homeTest;
    }

    private void rejectCurrentProduction() {
        homeProduction.State__c = 'Rejected';
        update homeProduction;
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
            mail.setSubject('Investor Relation page "Home" was Rejected');
            mail.setPlainTextBody('Investor Relation page  "Home" was Rejected and following comments added: ' + Comments);
            mail.setHtmlBody('Investor Relation page  "Home" was Rejected and following comments added: ' + '<b>' + Comments + '</b>');
        }
        else {
            mail.setSubject('Investor Relation page "Home" Approved and Deployed to Production');
            mail.setPlainTextBody('Investor Relation page "Home" Approved and Deployed to Production');
            mail.setHtmlBody('Investor Relation page "Home" Approved and Deployed to Production');
        }

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}