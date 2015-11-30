/**********************************************************************
Name: QuarterlyDataEditController
Copyright � notice: NMAC.
======================================================
Purpose:
This is a controller for QuarterlyDataEdit page
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/14/2015 Created 
***********************************************************************/
public class QuarterlyDataEditController {
    public QuarterlyDataModel qData { get; set; }
    public String qTestRecordTypeId { get; set; }
    public Boolean isRestored { get; set; }

    public List <QuarterlyDataItemModel > items { get; set; }

    public Boolean showNewDiv { get; set; }

    public String lineId { get; set; }

    public String errorMsg { get; set; }
    public String commentsMsg { get; set; }

    public Boolean errorMsgAvailable { get; set; }

    private Reviewer_Email__c reviewerEmail { get; set; }


    public QuarterlyDataEditController() {
        qTestRecordTypeId = Schema.SObjectType.Ws_Tab_Quarterly_Data__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
        isRestored = false;
        items = new List <QuarterlyDataItemModel > ();

        Ws_Tab_Quarterly_Data__c qDataPage;
        if (ApexPages.currentPage().getParameters().get('restore') == 'true') {
            if (ApexPages.currentPage().getParameters().get('id') != null) {
                qDataPage = [SELECT Id, Comments__c, Investor_Relations_Website__c, Header_Text__c, State__c FROM Ws_Tab_Quarterly_Data__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')] [0];
                isRestored = true;
            }
        }
        if (!isRestored) {
            qDataPage = [SELECT Id, Comments__c, Header_Text__c, State__c FROM Ws_Tab_Quarterly_Data__c WHERE State__c = 'Sent For Review' AND RecordtypeId = :qTestRecordTypeId] [0];
        }

        qData = QuarterlyDataModel.fromObject(qDataPage);

        for (Ws_Tab_Quarterly_Data_Item__c it :[SELECT Document__c, Document__r.Link__c, Info_Text__c, Order_Number__c FROM Ws_Tab_Quarterly_Data_Item__c WHERE Ws_Tab_Quarterly_Data__c = :qData.Implementation.id ORDER BY Order_Number__c])
        {
            items.add(QuarterlyDataItemModel.fromObject(it));
        }

        showNewDiv = false;

        errorMsg = '';

        if (qData.Comments != null) {
            commentsMsg = 'Reviewer comments: ' + qData.Comments;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, commentsMsg));
        }
        else {
            commentsMsg = '';
        }



        reviewerEmail = Reviewer_Email__c.getOrgDefaults();
    }

    public Pagereference uploadDoc() {
        PageReference p = new PageReference('/apex/UploadABSDocument' + '?id=' + lineId + '&page=QData');
        p.setredirect(true);
        return p;
    }

    public Pagereference deleteItems() {
        List <Ws_Tab_Quarterly_Data_Item__c > itemsToDelete = new List <Ws_Tab_Quarterly_Data_Item__c > ();
    

        for (Integer i = 0; i <items.size(); i++) {
            if (items[i].IsDeleted) {
                itemsToDelete.add(items[i].toObject());
                
                }
            
        }



        if (!itemsToDelete.isEmpty() && !isRestored) {
    
            delete itemsToDelete;
        }

        PageReference pageRef = new PageReference('/apex/QuarterlyDataEdit?sfdc.tabName=01rM00000009E97');
        pageRef.setRedirect(true);

        return pageRef;
    }

    private void updateItems() {

        List <Ws_Tab_Quarterly_Data_Item__c > itemsToUpdate = new List <Ws_Tab_Quarterly_Data_Item__c > ();

        Set<Decimal> orderNumbers = new Set<Decimal> ();

        List <Ws_Tab_Quarterly_Data_Item__c > insertedItems = [SELECT Document__c, Document__r.Link__c, Info_Text__c, Order_Number__c FROM Ws_Tab_Quarterly_Data_Item__c WHERE Ws_Tab_Quarterly_Data__c = :qData.Implementation.id ORDER BY Order_Number__c];


        for (QuarterlyDataItemModel iw : items) {
            if (!iw.IsDeleted) {
                for (Ws_Tab_Quarterly_Data_Item__c it : insertedItems) {
                    if (it.id == iw.Implementation.id) {
                        if (it.Document__c != iw.DocumentId) {
                            iw.DocumentId = it.Document__c;
                        }
                    }
                }
                if(iw.OrderNumber >= 99 || iw.OrderNumber < 0){
                    errorMsgAvailable = true;
                    errorMsg = 'Order number is out of range';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                    return;
                }

                itemsToUpdate.add(iw.toObject());

                if (orderNumbers.contains(iw.OrderNumber)) {
                    errorMsgAvailable = true;
                    errorMsg = 'Order number should be unique.';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                    return;
                }
                orderNumbers.add(iw.OrderNumber);
            }
        }

        errorMsg = '';

        if (!itemsToUpdate.isEmpty() && !isRestored) {
            update itemsToUpdate;
        }

    }


    public Pagereference save() {
        deleteItems();
        updateItems();

        if (errorMsg != '') {
            return null;
        }

        if (isRestored) {
            setCurrentTestPageToRejected();
            restoreTestHomePage(ApexPages.currentPage().getParameters().get('id'));
        }
        else {
            update qData.toObject();
        }


        PageReference pageRef = new PageReference('/apex/PagesEditSelector?sfdc.tabName=01rM00000009E97');
        pageRef.setRedirect(true);

        return pageRef;
    }

    public Pagereference add() {

        PageReference pageRef = new PageReference('/apex/UploadABSDocument?page=QData');
        pageRef.setRedirect(true);

        return pageRef;
    }

    public Pagereference saveAndSubmit() {

        this.save();

        if (errorMsg != '') {
            return null;
        }
        sendEmail();

        PageReference pageRef = new PageReference('/apex/PagesEditSelector?sfdc.tabName=01rM00000009E97');
        pageRef.setRedirect(true);

        return pageRef;
    }

    public void saveAndPreview() {
        errorMsgAvailable = false;
        this.save();

    }

    private void sendEmail() {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String[] toAddresses = new String[] { reviewerEmail.Email__c };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Investor Relations Page Requires Approval:' + 'Quarterly Data');
        mail.setPlainTextBody('Please use the link below to view and Approve/Reject "Quarterly Data" ' + baseUrl + '/apex/QuarterlyDataApproval');
        mail.setHtmlBody('Please use the link below to view and Approve/Reject "Quarterly Data" ' + '<a href="' + baseUrl + '/apex/QuarterlyDataApproval' + '"> LINK </a>');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }


    private void setCurrentTestPageToRejected() {
        Ws_Tab_Quarterly_Data__c absPg = [SELECT Id, Comments__c, State__c FROM Ws_Tab_Quarterly_Data__c WHERE State__c = 'Sent For Review' AND RecordtypeId = :qTestRecordTypeId] [0];
    
        delete absPg;
    }

    private void restoreTestHomePage(String recordId) {
        Ws_Tab_Quarterly_Data__c updatedTestQD = new Ws_Tab_Quarterly_Data__c();

        updatedTestQD.RecordtypeId = qTestRecordTypeId;
        updatedTestQD.State__c = 'Sent For Review';
        updatedTestQD.Header_Text__c = qData.HeaderText;
        updatedTestQD.Name = 'Quarterly Data';
        updatedTestQD.Investor_Relations_Website__c = qData.Implementation.Investor_Relations_Website__c;

        insert updatedTestQD;

        Map <Id, Ws_Tab_Quarterly_Data_Item__c > itemsToInsert = new Map <Id, Ws_Tab_Quarterly_Data_Item__c > ();
        Set<Id> documentIds = new Set<Id>();

        for (QuarterlyDataItemModel it :items)
        {
            if(!it.IsDeleted){
                Ws_Tab_Quarterly_Data_Item__c item = new Ws_Tab_Quarterly_Data_Item__c();
                item.Document__c = it.DocumentId;
                item.Info_Text__c = it.InfoText;
                item.Order_Number__c = it.OrderNumber;
                item.Ws_Tab_Quarterly_Data__c = updatedTestQD.id;

                itemsToInsert.put(it.ObjectId, item);
            }
            
        }

        List<Ws_Tab_Quarterly_Data_Item__c> itemsToUpdate = new List<Ws_Tab_Quarterly_Data_Item__c>();

        for(Ws_Tab_Quarterly_Data_Item__c newlyInsItem : [SELECT Id, Ws_Tab_Quarterly_Data__c FROM Ws_Tab_Quarterly_Data_Item__c WHERE Ws_Tab_Quarterly_Data__c = :qData.Implementation.id]){
            if(itemsToInsert.get(newlyInsItem.id) == null){
                newlyInsItem.Ws_Tab_Quarterly_Data__c = updatedTestQD.id;
                itemsToUpdate.add(newlyInsItem);
            }
        }
        

        insert itemsToInsert.values();
        update itemsToUpdate;


    }


}