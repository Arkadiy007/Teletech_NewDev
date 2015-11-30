/**********************************************************************
Name: FAQEditController
Copyright � notice: NMAC.
======================================================
Purpose:
This is a controller for "FAQEdit" page
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/13/2015 Created
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev 
***********************************************************************/
public class FAQEditController {
	public FAQModel faq { get; set; }
	public String faqTestRecordTypeId { get; set; }
	public Boolean isRestored { get; set; }

	public Ws_Tab_Faq_Line__c faqLine { get; set; }
	public List <FAQLineItemModel > items { get; set; }
	public Set<Decimal> orderNumbers { get; set; }

	public FAQLineItemModel newQuestion { get; set; }
	public Integer orderNum { get; set; }

	public Boolean errorMsgAvailable { get; set; }

	public Boolean showBAImgLoaderBlock { get; set; }

	public String errorMsg { get; set; }
	public String commentsMsg { get; set; }

	private Reviewer_Email__c reviewerEmail { get; set; }

	public FAQEditController() {
		faqTestRecordTypeId = Schema.SObjectType.Ws_Tab_Faq__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
		isRestored = false;

		if (ApexPages.currentPage().getParameters().get('restore') == 'true') {
			if (ApexPages.currentPage().getParameters().get('id') != null) {
				Ws_Tab_Faq__c faqPage = [SELECT Id, Comments__c, Investor_Relations_Website__c, State__c FROM Ws_Tab_Faq__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')] [0];
				faq = FAQModel.fromObject(faqPage);
				isRestored = true;
			}
		}
		if (!isRestored) {
			Ws_Tab_Faq__c faqPage = [SELECT Id, Comments__c, State__c FROM Ws_Tab_Faq__c WHERE State__c = 'Sent For Review' AND RecordtypeId = :faqTestRecordTypeId] [0];
			faq = FAQModel.fromObject(faqPage);
		}

		List <Ws_Tab_Faq_Line__c > faqLines = [SELECT Id, Ws_Tab_Faq__c FROM Ws_Tab_Faq_Line__c WHERE Ws_Tab_Faq__c = :faq.Implementation.id];

		if (!faqLines.isEmpty()) {
			faqLine = faqLines[0];
		}

		items = new List <FAQLineItemModel > ();

		for (Ws_Tab_Faq_Line_Item__c item :[SELECT Id, Answer__c, Order_Number__c, Question__c, Ws_Tab_Faq_Line__c FROM Ws_Tab_Faq_Line_Item__c WHERE Ws_Tab_Faq_Line__c = :faqLine.id  ORDER BY Order_Number__c]) {
			items.add(FAQLineItemModel.fromObject(item));
		}

		showBAImgLoaderBlock = false;
		newQuestion = new FAQLineItemModel();

		errorMsg = '';

		if (faq.Comments != null) {
			commentsMsg = 'Reviewer comments: ' + faq.Comments;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, commentsMsg));
		}
		else {
			commentsMsg = '';
		}

		reviewerEmail = Reviewer_Email__c.getOrgDefaults();
	}

	public Pagereference deleteItems() {
		List <Ws_Tab_Faq_Line_Item__c > itemsToDelete = new List <Ws_Tab_Faq_Line_Item__c > ();

		for (FAQLineItemModel iw : items) {
			if (iw.IsDeleted) {
				itemsToDelete.add(iw.toObject());
			}
		}

		if (!itemsToDelete.isEmpty() && !isRestored) {
			delete itemsToDelete;
		}

		PageReference pageRef = new PageReference('/apex/FAQEdit?sfdc.tabName=01rM00000009E97');
		pageRef.setRedirect(true);

		return pageRef;
	}

	private void updateItems() {
		List <Ws_Tab_Faq_Line_Item__c > itemsToUpdate = new List <Ws_Tab_Faq_Line_Item__c > ();

		orderNumbers = new Set<Decimal> ();

		for (FAQLineItemModel iw : items) {
			if (!iw.IsDeleted) {

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
		updateItems();
		deleteItems();

		if (errorMsg != '') {
			return null;
		}

		if (newQuestion.Question != '' && showBAImgLoaderBlock) {
			if(orderNum >= 99 || orderNum < 0){
					errorMsgAvailable = true;
					errorMsg = 'Order number is out of range';
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
					return null;	
			}

			if (orderNumbers.contains(orderNum)) {
				errorMsgAvailable = true;
				errorMsg = 'Order number should be unique.';
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
				return null;
			}

			newQuestion.OrderNumber = orderNum;
			newQuestion.FaqLineId = faqLine.id;

			insert newQuestion.toObject();

			showBAImgLoaderBlock = false;
		}
		else if (newQuestion.Question == '' && showBAImgLoaderBlock) {
			errorMsgAvailable = true;
			errorMsg = 'Row with empty question cannot be added.';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
			showBAImgLoaderBlock = false;
			return null;

		}

		if (isRestored) {
			setCurrentTestPageToRejected();
			restoreTestHomePage(ApexPages.currentPage().getParameters().get('id'));
		}
		else {
			update faq.toObject();
		}

		PageReference pageRef = new PageReference('/apex/PagesEditSelector?sfdc.tabName=01rM00000009E97');
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
		mail.setSubject('Investor Relations Page Requires Approval:' + 'FAQ');
		mail.setPlainTextBody('Please use the link below to view and Approve/Reject "FAQ" ' + baseUrl + '/apex/FAQApprovalPage');
		mail.setHtmlBody('Please use the link below to view and Approve/Reject "FAQ" ' + '<a href="' + baseUrl + '/apex/FAQApprovalPage' + '"> LINK </a>');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	private void setCurrentTestPageToRejected() {
		List<Ws_Tab_Faq__c> testHome = [SELECT Id, Comments__c, State__c FROM Ws_Tab_Faq__c WHERE State__c = 'Sent For Review' AND RecordtypeId = :faqTestRecordTypeId];
		if(!testHome.isEmpty()){
			delete testHome;
		}
	}

	private void restoreTestHomePage(String recordId) {
		Ws_Tab_Faq__c updatedTestFAQ = new Ws_Tab_Faq__c();

		updatedTestFAQ.RecordtypeId = faqTestRecordTypeId;
		updatedTestFAQ.State__c = 'Sent For Review';
		updatedTestFAQ.Name = 'FAQ';
		updatedTestFAQ.Investor_Relations_Website__c = faq.Implementation.Investor_Relations_Website__c;

		insert updatedTestFAQ;

		Ws_Tab_Faq_Line__c testLine = [SELECT Id FROM Ws_Tab_Faq_Line__c WHERE Ws_Tab_Faq__c = :faq.Implementation.id LIMIT 1];

		Ws_Tab_Faq_Line__c updatedLine = new Ws_Tab_Faq_Line__c();
		updatedLine.Ws_Tab_Faq__c = updatedTestFAQ.id;

		insert updatedLine;

		List <Ws_Tab_Faq_Line_Item__c > itemsToInsert = new List <Ws_Tab_Faq_Line_Item__c > ();

		for (FAQLineItemModel it : items){
			if(!it.IsDeleted){
			Ws_Tab_Faq_Line_Item__c item = new Ws_Tab_Faq_Line_Item__c();
			item.Answer__c = it.Answer;
			item.Order_Number__c = it.OrderNumber;
			item.Question__c = it.Question;
			item.Ws_Tab_Faq_Line__c = updatedLine.id;

			itemsToInsert.add(item);
			}
		}

		insert itemsToInsert;
	}
}