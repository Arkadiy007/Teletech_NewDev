/**********************************************************************
Name: PresentationsApprovalController
Copyright � notice: NMAC.
======================================================
Purpose:
This is a controller for "PresentationsApproval" paage
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/15/2015 Created 
***********************************************************************/
public class PresentationsApprovalController {

    public Ws_Tab_Presentations__c pTest { get; set; }
    public Ws_Tab_Presentations__c pProduction { get; set; }
    public String Comments { get; set; }
    private String pTestRecordTypeId { get; set; }
    private String pProductionRecordTypeId { get; set; }

    public Boolean isUserAreApprover { get; set; }
    private Reviewer_Email__c reviewerEmail { get; set; }

    public PresentationsApprovalController() {
        reviewerEmail = Reviewer_Email__c.getOrgDefaults(); 

        if (reviewerEmail.Email__c != [SELECT Email, Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1] [0].Email) {
            isUserAreApprover = false;

        }
        else {
            isUserAreApprover = true;
            pTestRecordTypeId = Schema.SObjectType.Ws_Tab_Presentations__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
            pTest = [SELECT Id, Comments__c, Header_Text__c, LastModifiedById, State__c, Investor_Relations_Website__c FROM Ws_Tab_Presentations__c WHERE RecordtypeId = :pTestRecordTypeId AND State__c = 'Sent For Review'] [0];
            Comments = '';

            pProductionRecordTypeId = Schema.SObjectType.Ws_Tab_Presentations__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
            pProduction = [SELECT Id, Comments__c, Header_Text__c, LastModifiedById, State__c, Investor_Relations_Website__c FROM Ws_Tab_Presentations__c WHERE RecordtypeId = :pProductionRecordTypeId AND State__c = 'Approved'] [0];
        }
    }

    public Pagereference approve() {
        
        sendEmail(pTest.LastModifiedById, false);
        
        Ws_Tab_Presentations__c updatedTestPres = cloneCurrentTest();
        insert updatedTestPres;

        List <Ws_Tab_Presentation_Item__c > itemsToInsert = cloneTestItems(updatedTestPres.id);
        insert itemsToInsert;

        deployCurrentTest();
        rejectCurrentProd();
            

        return redirectHome();
    }

    public Pagereference reject() {
        
        sendEmail(pTest.LastModifiedById, true);
        
        addCommentsToTestPage();
        return redirectHome();
    }


    private Ws_Tab_Presentations__c cloneCurrentTest(){
        Ws_Tab_Presentations__c updatedTestPres = new Ws_Tab_Presentations__c();
        updatedTestPres.RecordtypeId = pTestRecordTypeId; 
        updatedTestPres.State__c = 'Sent For Review';
        updatedTestPres.Header_Text__c = pTest.Header_Text__c;
        updatedTestPres.Name = 'Presentations';
        updatedTestPres.Investor_Relations_Website__c = pTest.Investor_Relations_Website__c;

        return updatedTestPres;
    }


    private List <Ws_Tab_Presentation_Item__c> cloneTestItems(Id updatedTestPresId){
        List <Ws_Tab_Presentation_Item__c > itemsToInsert = new List <Ws_Tab_Presentation_Item__c > (); 

        for (Ws_Tab_Presentation_Item__c it :[SELECT Document__c, Presentation_Image__c, Ws_Tab_Presentation__c, Item_Text__c, Order_Number__c FROM Ws_Tab_Presentation_Item__c WHERE Ws_Tab_Presentation__c = :pTest.id ORDER BY Order_Number__c])
        {
            itemsToInsert.add(cloneItem(it, updatedTestPresId));
        }

        return itemsToInsert;
    }

    private Ws_Tab_Presentation_Item__c cloneItem(Ws_Tab_Presentation_Item__c it, Id updatedTestPresId){
        Ws_Tab_Presentation_Item__c item = new Ws_Tab_Presentation_Item__c();
        item.Document__c = it.Document__c;
        item.Presentation_Image__c = it.Presentation_Image__c;
        item.Item_Text__c = it.Item_Text__c;
        item.Order_Number__c = it.Order_Number__c;
        item.Ws_Tab_Presentation__c = updatedTestPresId;        

        return item;
    }
    
    private void deployCurrentTest(){
        pTest.RecordtypeId = pProductionRecordTypeId;
        pTest.State__c = 'Approved';
        pTest.Comments__c = Comments;
        update pTest;
    }

    private void rejectCurrentProd(){
        pProduction.State__c = 'Rejected';
        update pProduction;
    }

    private void addCommentsToTestPage(){
        pTest.Comments__c = Comments;
        update pTest;
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
            mail.setSubject('Investor Relation page "Presentations" was Rejected');
            mail.setPlainTextBody('Investor Relation page  "Presentations" was Rejected and following comments added: ' + Comments);
            mail.setHtmlBody('Investor Relation page  "Presentations" was Rejected and following comments added: ' + '<b>' + Comments + '</b>');
        }
        else {
            mail.setSubject('Investor Relation page "Presentations" Approved and Deployed to Production');
            mail.setPlainTextBody('Investor Relation page "Presentations" Approved and Deployed to Production');
            mail.setHtmlBody('Investor Relation page "Presentations" Approved and Deployed to Production');
        }


        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}