/**********************************************************************
Name: UploadABSDocumentController
Copyright � notice: NMAC.
======================================================
Purpose:
This is a controller for UploadABSDocument page
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/13/2015 Created 
***********************************************************************/
public class UploadABSDocumentController {
    public Document d { get; set; }
    public Document img { get; set; }
    public String lineId { get; set; }
    public String oid { get; set; }

    public String errorMsg { get; set; }

    public ABSLineItemModel item { get; set; }
    public QuarterlyDataItemModel qItem { get; set; }
    public PresentationItemModel pItem { get; set; }

    public Boolean isPItemNeedsToBeUpdated { get; set; }
    public Boolean isPItemNeedsToBeInserted { get; set; }
    public Boolean imageUploaded { get; set; }

    public Integer orderNumber { get; set; }

    public Boolean uploadForABS { get; set; }
    public Boolean uploadForQData { get; set; }
    public Boolean uploadForPresentation { get; set; }

    public Boolean isInfoTextNeededToBeShown { get; set; }

    public UploadABSDocumentController() {
        d = new Document();
        img = new Document();

        errorMsg = '';
        orderNumber = 0;

        uploadForABS = false;
        uploadForQData = false;
        uploadForPresentation = false;
        imageUploaded = false;

        isPItemNeedsToBeUpdated = false;
        isPItemNeedsToBeInserted = false;
        isInfoTextNeededToBeShown = false;

        System.DEBUG(ApexPages.currentPage().getParameters().get('page'));
        if (ApexPages.currentPage().getParameters().get('page') == 'QData') {
            initForQuarterlyData();
        }
        else if (ApexPages.currentPage().getParameters().get('page') == 'pres') {
            initForPresentation();
        }
        else {
            initForAbs();
        }
    }

    private void initForQuarterlyData() {
        uploadForQData = true;
        Ws_Tab_Quarterly_Data_Item__c qItemObject;
        if (ApexPages.currentPage().getParameters().get('id') != null) {
            isInfoTextNeededToBeShown = false;
            lineId = ApexPages.currentPage().getParameters().get('id');
            qItemObject = [SELECT Id, Document__c, Info_Text__c, Order_Number__c, Ws_Tab_Quarterly_Data__c,  Document__r.Link__c FROM Ws_Tab_Quarterly_Data_Item__c WHERE Id = :lineId] [0];
        }
        else {
            isInfoTextNeededToBeShown = true;
            oid = ApexPages.currentPage().getParameters().get('oid');
            qItemObject = new Ws_Tab_Quarterly_Data_Item__c();
        }

        qItem=QuarterlyDataItemModel.fromObject(qItemObject);
    }

    private void initForPresentation() {
        uploadForPresentation = true;

        if (ApexPages.currentPage().getParameters().get('id') != null) {
            isInfoTextNeededToBeShown = false;
            lineId = ApexPages.currentPage().getParameters().get('id');
            Ws_Tab_Presentation_Item__c pItemObject = [SELECT Document__c, Ws_Tab_Presentation__c, Document__r.Link__c, Item_Text__c, Order_Number__c, Presentation_Image__c, Presentation_Image__r.Link__c FROM Ws_Tab_Presentation_Item__c WHERE Id = :lineId] [0];
            pItem = PresentationItemModel.fromObject(pItemObject);
        }
        else {
            isInfoTextNeededToBeShown = true;
            oid = ApexPages.currentPage().getParameters().get('oid');

            pItem = new PresentationItemModel();
        }
    }

    private void initForAbs() {
        uploadForABS = true;

        if (ApexPages.currentPage().getParameters().get('id') != null) {
            lineId = ApexPages.currentPage().getParameters().get('id');
        }

        item = new ABSLineItemModel();
        item.Subheading = '';

    }

    public Pagereference uploadDoc() {
        Folder f = [select id from Folder where name = 'Company Page Files'] [0];
        Document_Proxy__c dp;



        if (d.Name != null) {
            d.folderid = f.id;
            d.isPublic = true;

            insert d;

            dp = new Document_Proxy__c(Name = d.Name, Link__c = '/servlet/servlet.FileDownload?file=' + d.Id, Document_Extension__c = d.Name.right(3));

            d.Body = null;
            d = new Document();

            insert dp;


            if (uploadForABS) {
                item.Name = dp.Name;
                item.Document = dp.id;
                item.AbsLineId = lineId;

                if(orderNumber >= 99 || orderNumber < 0){
                    errorMsg = 'Order number is out of range';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                    return null;
                    }


                item.OrderNumber = orderNumber;

                if (item.Subheading == null) {
                    item.Subheading = dp.Name.remove(dp.Document_Extension__c);
                }

                if (checkOrderNumber(item)) {
                    insert item.toObject();
                }
                else {
                    errorMsg = 'Order number for items should be unique.';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                    return null;
                }


                item = new ABSLineItemModel();

                PageReference p = new PageReference('/apex/UploadABSDocument' + '?id=' + lineId);
                p.setredirect(true);

                return p;
            }
            else if (uploadForQData) {
                if (oid == null || oid == '') {
                    qItem.Implementation.Name = dp.Name;
                    qItem.DocumentId = dp.id;

                    update qItem.toObject();
                }
                else {
                    qItem.Implementation.Name = dp.Name;
                    qItem.DocumentId = dp.id;
                    qItem.Implementation.Ws_Tab_Quarterly_Data__c = oid;

                    if(orderNumber >= 99 || orderNumber < 0){
                    errorMsg = 'Order number is out of range';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                    return null;
                    }


                    qItem.OrderNumber = orderNumber;

                    if (checkOrderNumber(qItem)) {
                        insert qItem.toObject();
                    }
                    else {
                        errorMsg = 'Order number for items should be unique.';
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                        return null;
                    }

                    lineId = qItem.Implementation.id;
                }

            }

            else if (uploadForPresentation) {
                if (oid == null || oid == '') {
                    pItem.DocumentId = dp.id;


                    isPItemNeedsToBeUpdated = true;
                }
                else {
                    pItem.DocumentId = dp.id;
                    pItem.PresentationTab = oid;
                    pItem.OrderNumber = orderNumber;

                    isPItemNeedsToBeInserted = true;

                    lineId = pItem.ObjectId;
                }
                imageUploaded = true;
                return uploadImg(f);

            }
        }

        else {
            if (uploadForQData) {
                errorMsg = 'Please, select document for item';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                return null;
            }
        }
        if(d.Name == null && uploadForABS){
                        errorMsg = 'Select Document To Upload';
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                        return null;
        }

        if(d.Name == null && img.Name == null && uploadForPresentation){
            errorMsg = 'Select Document To Upload';
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                        return null;
        }

        if (!imageUploaded) {
            return uploadImg(f);
        }

        

        return new PageReference('javascript:window.close()');
    }

    private Pagereference uploadImg(Folder f) {
        Set<String> validTypes = new Set<String> ();
        validTypes.add('.png');
        validTypes.add('.jpg');
        validTypes.add('jpeg');



        if (img.Name != null) {
            if (!validTypes.contains(img.Name.right(4))) {
                addErrorMsg(img.Name);
                return null;
            }
            img.folderid = f.id;
            img.isPublic = true;

            insert img;

            Image_Proxy__c dp = new Image_Proxy__c(Name = img.Name, Link__c = '/servlet/servlet.ImageServer?id=' + img.Id + '&oid=' + UserInfo.getOrganizationId());

            img.Body = null;
            img = new Document();

            insert dp;

            if (uploadForPresentation) {
                if (oid == null || oid == '') {
                    pItem.PresentationImageId = dp.id;

                    isPItemNeedsToBeUpdated = true;
                }
                else {
                    pItem.PresentationImageId = dp.id;
                    pItem.PresentationTab = oid;

                    if(orderNumber >= 99 || orderNumber < 0){
                    errorMsg = 'Order number is out of range';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                    return null;
                    }


                    pItem.OrderNumber = orderNumber;

                    isPItemNeedsToBeInserted = true;

                    lineId = pItem.ObjectId;
                }

                if (isPItemNeedsToBeUpdated) {
                    update pItem.toObject();
                    isPItemNeedsToBeUpdated = false;

                }

                if (isPItemNeedsToBeInserted) {
                    isPItemNeedsToBeInserted = false;

                    if (checkOrderNumber(pItem)) {
                        if (pItem.PresentationImageId == null && pItem.DocumentId == null) {
                            errorMsg = 'Please, select document for item';
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                            return null;
                        }

                        insert pItem.toObject();
                    }
                    else {
                        errorMsg = 'Order number for items should be unique.';
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                        return null;
                    }
                }

                return new PageReference('javascript:window.close()');
            }
            else {

                return new PageReference('javascript:window.close()');
            }
        }
        else {
            if (isPItemNeedsToBeUpdated) {
                update pItem.toObject();
                isPItemNeedsToBeUpdated = false;
            }

            if (isPItemNeedsToBeInserted) {
                isPItemNeedsToBeInserted = false;

                if (checkOrderNumber(pItem)) {
                    if (pItem.PresentationImageId == null && pItem.DocumentId == null) {
                        errorMsg = 'Please, select document for item';
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                        return null;
                    }
                    insert pItem.toObject();
                }
                else {
                    errorMsg = 'Order number for items should be unique.';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                    return null;
                }
            }

            return new PageReference('javascript:window.close()');
        }

    }

    private void addErrorMsg(String filename) {
        errorMsg = 'File ' + filename + ' needs to be an image. Available extensions are: .png, .jpg, .jpeg ';
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
    }

    private Boolean checkOrderNumber(PresentationItemModel p) {
        Set<Decimal> orderNumbers = new Set<Decimal> ();
        orderNumbers.add(p.OrderNumber);

        for (Ws_Tab_Presentation_Item__c itm :[SELECT Id, Order_Number__c FROM Ws_Tab_Presentation_Item__c WHERE Ws_Tab_Presentation__c = :p.PresentationTab]) {
            if (orderNumbers.contains(itm.Order_Number__c)) {
                return false;
            }
            orderNumbers.add(itm.Order_Number__c);
        }
        return true;
    }

    private Boolean checkOrderNumber(QuarterlyDataItemModel p) {
        Set<Decimal> orderNumbers = new Set<Decimal> ();
        orderNumbers.add(p.OrderNumber);

        for (Ws_Tab_Quarterly_Data_Item__c itm :[SELECT Id, Order_Number__c FROM Ws_Tab_Quarterly_Data_Item__c WHERE Ws_Tab_Quarterly_Data__c = :p.Implementation.Ws_Tab_Quarterly_Data__c]) {
            if (orderNumbers.contains(itm.Order_Number__c)) {
                return false;
            }
            orderNumbers.add(itm.Order_Number__c);
        }
        return true;
    }

    private Boolean checkOrderNumber(ABSLineItemModel p) {
        Set<Decimal> orderNumbers = new Set<Decimal> ();
        orderNumbers.add(p.OrderNumber);

        for (Ws_Tab_Abs_Line_Item__c itm :[SELECT Id, Order_Number__c FROM Ws_Tab_Abs_Line_Item__c WHERE Ws_Tab_Abs_Line__c = :p.AbsLineId]) {
            if (orderNumbers.contains(itm.Order_Number__c)) {
                return false;
            }
            orderNumbers.add(itm.Order_Number__c);
        }
        return true;
    }
}