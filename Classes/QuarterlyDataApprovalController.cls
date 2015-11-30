/**********************************************************************
Name: QuarterlyDataApprovalController
Copyright � notice: NMAC.
======================================================
Purpose:
This is a controller for QuarterlyDataApproval page
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/15/2015 Created 
***********************************************************************/
public class QuarterlyDataApprovalController {

    public Ws_Tab_Quarterly_Data__c qTest { get; set; }
    public Ws_Tab_Quarterly_Data__c qProduction { get; set; }
    public String Comments { get; set; }
    private String qTestRecordTypeId { get; set; }
    private String qProductionRecordTypeId { get; set; }

    public Boolean isUserAreApprover { get; set; }
    private Reviewer_Email__c reviewerEmail { get; set; }
    private QD_Components_Available__c qd { get; set; }

    public QuarterlyDataApprovalController() {
        reviewerEmail = Reviewer_Email__c.getOrgDefaults();

        if (reviewerEmail.Email__c != [SELECT Email, Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1] [0].Email) {
            isUserAreApprover = false;

        }
        else {
            isUserAreApprover = true;
            qTestRecordTypeId = Schema.SObjectType.Ws_Tab_Quarterly_Data__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
            qTest = [SELECT Id, LastModifiedById, Comments__c, Investor_Relations_Website__c, Header_Text__c FROM Ws_Tab_Quarterly_Data__c WHERE RecordtypeId = :qTestRecordTypeId AND State__c = 'Sent For Review'] [0];
            Comments = '';

            qProductionRecordTypeId = Schema.SObjectType.Ws_Tab_Quarterly_Data__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
            qProduction = [SELECT Id, Investor_Relations_Website__c, Header_Text__c FROM Ws_Tab_Quarterly_Data__c WHERE RecordtypeId = :qProductionRecordTypeId AND State__c = 'Approved'] [0];
        }
        
        qd = QD_Components_Available__c.getOrgDefaults();
    }

    public Pagereference approve() {
        
        sendEmail(qTest.LastModifiedById, false);
        

        Ws_Tab_Quarterly_Data__c updatedTestQD = cloneCurrentTest(); 
        insert updatedTestQD;

    

        List <Ws_Tab_Quarterly_Data_Item__c > itemsToInsert = cloneTestItems(updatedTestQD.id);

        if (itemsToInsert.isEmpty()) {
            qd.Available__c = false;
        }
        else {
            qd.Available__c = true;
        }

        insert itemsToInsert;
        update qd;

        qTest.RecordtypeId = qProductionRecordTypeId;
        qTest.State__c = 'Approved';
        qTest.Comments__c = Comments;

        qProduction.State__c = 'Rejected';


        update qTest;
        update qProduction;

        return redirectHome();
    }

    public Pagereference reject() {
    
        sendEmail(qTest.LastModifiedById, true);
        
        addCommentsToTest();
        return redirectHome();
    }

    private Ws_Tab_Quarterly_Data__c cloneCurrentTest(){
        Ws_Tab_Quarterly_Data__c updatedTestQD = new Ws_Tab_Quarterly_Data__c();

        updatedTestQD.RecordtypeId = qTestRecordTypeId;
        updatedTestQD.State__c = 'Sent For Review';
        updatedTestQD.Header_Text__c = qTest.Header_Text__c;
        updatedTestQD.Name = 'Quarterly Data';
        updatedTestQD.Investor_Relations_Website__c = qTest.Investor_Relations_Website__c;

        return updatedTestQD;
    }

    private List <Ws_Tab_Quarterly_Data_Item__c > cloneTestItems(Id updatedTestQDId){
        List <Ws_Tab_Quarterly_Data_Item__c > itemsToInsert = new List <Ws_Tab_Quarterly_Data_Item__c > (); 

        for (Ws_Tab_Quarterly_Data_Item__c it :[SELECT Document__c, Document__r.Link__c, Ws_Tab_Quarterly_Data__c, Info_Text__c, Order_Number__c FROM Ws_Tab_Quarterly_Data_Item__c WHERE Ws_Tab_Quarterly_Data__c = :qTest.id ORDER BY Order_Number__c])
        {
            itemsToInsert.add(cloneItem(it, updatedTestQDId));
        }

        return itemsToInsert;
    }

    private Ws_Tab_Quarterly_Data_Item__c cloneItem(Ws_Tab_Quarterly_Data_Item__c it, Id updatedTestQD){
        Ws_Tab_Quarterly_Data_Item__c item = new Ws_Tab_Quarterly_Data_Item__c();
        item.Document__c = it.Document__c;
        item.Info_Text__c = it.Info_Text__c;
        item.Order_Number__c = it.Order_Number__c;
        item.Ws_Tab_Quarterly_Data__c = updatedTestQD;

        return item;
    }

    private void addCommentsToTest(){
        qTest.Comments__c = Comments;
        update qTest;
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
            mail.setSubject('Investor Relation page "Quarterly Data" was Rejected');
            mail.setPlainTextBody('Investor Relation page  "Quarterly Data" was Rejected and following comments added: ' + Comments);
            mail.setHtmlBody('Investor Relation page  "Quarterly Data" was Rejected and following comments added: ' + '<b>' + Comments + '</b>');
        }
        else {
            mail.setSubject('Investor Relation page "Quarterly Data" Approved and Deployed to Production');
            mail.setPlainTextBody('Investor Relation page "Quarterly Data" Approved and Deployed to Production');
            mail.setHtmlBody('Investor Relation page "Quarterly Data" Approved and Deployed to Production');
        }

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}