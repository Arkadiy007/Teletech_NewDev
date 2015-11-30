/**********************************************************************
Name: PresentationsApprovalController
Copyright � notice: NMAC.
======================================================
Purpose:
This is a controller for "PresentationsEdit" page
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/15/2015 Created 
***********************************************************************/
public class PresentationsEditController {

    public PresentationModel pres { get; set; }
    public String qTestRecordTypeId { get; set; }
    public Boolean isRestored { get; set; }

    public List <PresentationItemModel > items { get; set; }

    public String lineId { get; set; }

    public String errorMsg { get; set; }
    public String commentsMsg { get; set; }

    public Boolean errorMsgAvailable { get; set; }

    private Reviewer_Email__c reviewerEmail { get; set; }

    public PresentationsEditController() {
        qTestRecordTypeId = Schema.SObjectType.Ws_Tab_Presentations__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
        isRestored = false;
        items = new List <PresentationItemModel > ();

        Ws_Tab_Presentations__c presentationObject;
        if (ApexPages.currentPage().getParameters().get('restore') == 'true') {
            if (ApexPages.currentPage().getParameters().get('id') != null) {
                presentationObject = [SELECT Id, Comments__c, Investor_Relations_Website__c, Header_Text__c, State__c FROM Ws_Tab_Presentations__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')] [0];
                isRestored = true;
            }
        }
        if (!isRestored) {
            presentationObject = [SELECT Id, Comments__c, Header_Text__c, State__c FROM Ws_Tab_Presentations__c WHERE State__c = 'Sent For Review' AND RecordtypeId = :qTestRecordTypeId] [0];
        }

        pres = PresentationModel.fromObject(presentationObject);

        for (Ws_Tab_Presentation_Item__c it :[SELECT Document__c, Document__r.Link__c, Item_Text__c, Order_Number__c, Ws_Tab_Presentation__c , Presentation_Image__c, Presentation_Image__r.Link__c FROM Ws_Tab_Presentation_Item__c WHERE Ws_Tab_Presentation__c = :pres.Implementation.id ORDER BY Order_Number__c])
        {
            items.add(PresentationItemModel.fromObject(it));
        }

        errorMsg = '';

        if (pres.Comments != null) {
            commentsMsg = 'Reviewer comments: ' + pres.Comments;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, commentsMsg));
        }
        else {
            commentsMsg = '';
        }

        reviewerEmail = Reviewer_Email__c.getOrgDefaults();
    }

    public Pagereference uploadDoc() {
        PageReference p = new PageReference('/apex/UploadABSDocument' + '?id=' + lineId + '&page=Pres');
        p.setredirect(true);
        return p;
    }

    public Pagereference deleteItems() {
        List <Ws_Tab_Presentation_Item__c > itemsToDelete = new List <Ws_Tab_Presentation_Item__c > ();
        Set<Id> documentIds = new Set<Id>();

        for (PresentationItemModel iw : items) {
            if (iw.IsDeleted) {
                itemsToDelete.add(iw.toObject());
            }
        }

        if (!itemsToDelete.isEmpty() && !isRestored) {
            

            delete itemsToDelete;
        
        }

        PageReference pageRef = new PageReference('/apex/PresentationsEdit?sfdc.tabName=01rM00000009E97');
        pageRef.setRedirect(true);

        return pageRef;
    }

    private void updateItems() {

        List <Ws_Tab_Presentation_Item__c > itemsToUpdate = new List <Ws_Tab_Presentation_Item__c > ();

        Set<Decimal> orderNumbers = new Set<Decimal> ();

        List <Ws_Tab_Presentation_Item__c > insertedItems = [SELECT Document__c, Presentation_Image__c FROM Ws_Tab_Presentation_Item__c WHERE Ws_Tab_Presentation__c = :pres.Implementation.id ORDER BY Order_Number__c];


        for (PresentationItemModel iw : items) {
            if (!iw.IsDeleted) {
                for (Ws_Tab_Presentation_Item__c it : insertedItems) {
                    if (it.id == iw.ObjectId) {
                        if (it.Document__c != iw.DocumentId) {
                            iw.DocumentId = it.Document__c;
                        }
                        if (it.Presentation_Image__c != iw.PresentationImageId) {
                            iw.PresentationImageId = it.Presentation_Image__c;
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
            update pres.toObject();
        }


        PageReference pageRef = new PageReference('/apex/PagesEditSelector?sfdc.tabName=01rM00000009E97');
        pageRef.setRedirect(true);

        return pageRef;
    }

    public Pagereference add() {

        PageReference pageRef = new PageReference('/apex/UploadABSDocument?page=pres');
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
        mail.setSubject('Investor Relations Page Requires Approval:' + 'Presentations');
        mail.setPlainTextBody('Please use the link below to view and Approve/Reject "Presentations" ' + baseUrl + '/apex/PresentationsApproval');
        mail.setHtmlBody('Please use the link below to view and Approve/Reject "Presentations" ' + '<a href="' + baseUrl + '/apex/PresentationsApproval' + '"> LINK </a>');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }


    private void setCurrentTestPageToRejected() {
        Ws_Tab_Presentations__c absPg = [SELECT Id, Comments__c, State__c FROM Ws_Tab_Presentations__c WHERE State__c = 'Sent For Review' AND RecordtypeId = :qTestRecordTypeId] [0];
        delete absPg;
    }

    private void restoreTestHomePage(String recordId) {
        Ws_Tab_Presentations__c updatedTestPres = new Ws_Tab_Presentations__c();

        updatedTestPres.RecordtypeId = qTestRecordTypeId;
        updatedTestPres.State__c = 'Sent For Review';
        updatedTestPres.Header_Text__c = pres.HeaderText;
        updatedTestPres.Name = 'Presentations';
        updatedTestPres.Investor_Relations_Website__c = pres.Implementation.Investor_Relations_Website__c;

        insert updatedTestPres;

        Map <Id, Ws_Tab_Presentation_Item__c > itemsToInsert = new Map <Id, Ws_Tab_Presentation_Item__c > ();

        for (PresentationItemModel it : items)
        {
            if(!it.IsDeleted){
            Ws_Tab_Presentation_Item__c item = new Ws_Tab_Presentation_Item__c();
            item.Document__c = it.DocumentId;
            item.Presentation_Image__c = it.PresentationImageId;
            item.Item_Text__c = it.ItemText;
            item.Order_Number__c = it.OrderNumber;
            item.Ws_Tab_Presentation__c = updatedTestPres.id;

            itemsToInsert.put(it.ObjectId, item);
            }

        }

        List<Ws_Tab_Presentation_Item__c> itemsToUpdate = new List<Ws_Tab_Presentation_Item__c>();

        for(Ws_Tab_Presentation_Item__c newlyInsItem : [SELECT Id, Ws_Tab_Presentation__c FROM Ws_Tab_Presentation_Item__c WHERE Ws_Tab_Presentation__c = :pres.Implementation.id]){
            if(itemsToInsert.get(newlyInsItem.id) == null){
                newlyInsItem.Ws_Tab_Presentation__c = updatedTestPres.id;
                itemsToUpdate.add(newlyInsItem);
            }
        }
        

        insert itemsToInsert.values();
        update itemsToUpdate;
    }





}