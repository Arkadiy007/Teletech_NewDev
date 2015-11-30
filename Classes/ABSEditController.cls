/**********************************************************************
  Name: ABSEditController
  Copyright � notice: NMAC.
  ======================================================
  Purpose:
  This is a controller for "ABSpageEdit" page
 
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL
  1.0 - Arshakyan Georgiy 5/13/2015 Created 
  1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev
 ***********************************************************************/
public class ABSEditController {

	public ABSModel abs { get; set; }
	public String absTestRecordTypeId { get; set; }
	public Boolean isRestored { get; set; }


	public Map <HeadingWrapper, Map <ABSLineModel, List <ABSLineItemModel > > > absLines { get; set; }

	public Boolean showNewDiv { get; set; }
	public ABSLineModel newLine { get; set; }
	public Set<SelectOption> majorHeadings { get; set; }

	public String lineId { get; set; }
	public Boolean errorMsgAvailable { get; set; }

	public String errorMsg { get; set; }
	public String commentsMsg { get; set; }

	public Set<String> validTypes { get; set; }

	private Reviewer_Email__c reviewerEmail { get; set; }
	private Ws_Tab_abs__c absPage { get; set; }

	public ABSEditController() {
		absTestRecordTypeId = Schema.SObjectType.Ws_Tab_abs__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
		isRestored = false;
		showNewDiv = false;
		absLines = new Map <HeadingWrapper, Map <ABSLineModel, List <ABSLineItemModel > > > ();
		newLine = new ABSLineModel();

		if (ApexPages.currentPage().getParameters().get('restore') == 'true') {
			if (ApexPages.currentPage().getParameters().get('id') != null) {
				absPage = [SELECT Id, Comments__c, Name, Investor_Relations_Website__c, Overview__c, RecordTypeId, State__c FROM Ws_Tab_abs__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')] [0];
				abs = ABSModel.fromObject(absPage);
				isRestored = true;
			}
		}
		if (!isRestored) {
			absPage = [SELECT Id, Comments__c, Overview__c, State__c, Name, Investor_Relations_Website__c, RecordTypeId FROM Ws_Tab_abs__c WHERE State__c = 'Sent For Review' AND RecordtypeId = :absTestRecordTypeId] [0];
			abs = ABSModel.fromObject(absPage);
		}

		absLines = new Map <HeadingWrapper, Map <ABSLineModel, List <ABSLineItemModel > > > ();
		Map <Id, List <ABSLineItemModel > > lineItemsByLines = fillLineItemsByLines();
		Map <String, Map <ABSLineModel, List <ABSLineItemModel > > > tmpAbsLines = fillABSLinesByHeading(lineItemsByLines);
		fillABSLines(tmpAbsLines);
		tmpAbsLines.clear();

		majorHeadings = fillMajorHeadings();
		errorMsg = '';
		getComments();

		reviewerEmail = Reviewer_Email__c.getOrgDefaults();
	}

	public Pagereference uploadDoc() {
		return pagereferenceBuilder('/apex/UploadABSDocument' + '?id=' + lineId);
	}

	public Pagereference deleteItems() {
		List <Ws_Tab_Abs_Line_Item__c > itemsToDelete = getDeletedItems();

		if (!itemsToDelete.isEmpty() && !isRestored) {
			delete itemsToDelete;
		}

		return pagereferenceBuilder('/apex/ABSPageEdit');
	}

	private void updateItems() {

		List <Ws_Tab_Abs_Line_Item__c > itemsToUpdate = getUpdatedItems();

		if (!itemsToUpdate.isEmpty() && !isRestored) {
			update itemsToUpdate;
		}
	}

	private void updateLines() {
		List <Ws_Tab_Abs_Line__c > linesToUpdate = getUpdatedLines();

		if (!linesToUpdate.isEmpty() && !isRestored) {
			update linesToUpdate;
		}
	}

	private void deleteLines() {
		List <Ws_Tab_Abs_Line__c > linesToDelete = getDeletedLines();

		if (!linesToDelete.isEmpty() && !isRestored) {
			delete linesToDelete;
		}
	}


	public Pagereference save() {
		clearErrorMsgs();
		updateLines();
		deleteLines();
		if (errorMsgAvailable) {
			return null;
		}

		updateItems();
		deleteItems();
		if (errorMsgAvailable) {
			return null;
		}

		if (isRestored) {
			setCurrentTestPageToRejected();
			restoreTestHomePage(ApexPages.currentPage().getParameters().get('id'));
		}
		else {
			update abs.toObject();
		}

		return pagereferenceBuilder('/apex/PagesEditSelector?sfdc.tabName=01rM00000009E97');
	}

	public Pagereference add() {
		if (newLine.Name != null || newLine.Name != '') {
			newLine.AbsId = abs.Implementation.id;

			if (newLine.MHeading == null) {
				addErrorMsg('Please select major heading');
				return null;
			}

			if (isOrderNumberUnique(newLine.OrderNumber)) {
				showNewDiv = false;
				insert newLine.toObject();
			}
			else {
				addErrorMsg('Order number for subheadings should be unique.');
				return null;
			}


		}

		return pagereferenceBuilder('/apex/ABSPageEdit?sfdc.tabName=01rM00000009E97');
	}

	public Pagereference saveAndSubmit() {
		this.save();
		sendEmail();
		if (errorMsgAvailable) {
			return null;
		}

		return null;
	}

	public void saveAndPreview() {
		errorMsgAvailable = true;
		this.save();
	}

	private void sendEmail() {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
		String[] toAddresses = new String[] { reviewerEmail.Email__c };
		mail.setToAddresses(toAddresses);
		mail.setSubject('Investor Relations Page Requires Approval:' + 'ABS');
		mail.setPlainTextBody('Please use the link below to view and Approve/Reject "ABS" ' + baseUrl + '/apex/ABSpageApproval');
		mail.setHtmlBody('Please use the link below to view and Approve/Reject "ABS" ' + '<a href="' + baseUrl + '/apex/ABSpageApproval' + '"> LINK </a>');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	private void setCurrentTestPageToRejected() {
		Ws_Tab_abs__c absPg = [SELECT Id, Comments__c, Name, Overview__c, State__c FROM Ws_Tab_abs__c WHERE State__c = 'Sent For Review' AND RecordtypeId = :absTestRecordTypeId] [0];
		delete absPg;
	}

	//To Refactor
	private void restoreTestHomePage(String recordId) {
		Ws_Tab_Abs__c updatedAbsTest = new Ws_Tab_Abs__c();

		updatedAbsTest.Name = abs.Name;
		updatedAbsTest.RecordtypeId = absTestRecordTypeId;
		updatedAbsTest.Overview__c = abs.Implementation.Overview__c;
		updatedAbsTest.State__c = 'Sent For Review';
		updatedAbsTest.Investor_Relations_Website__c = absPage.Investor_Relations_Website__c;

		insert updatedAbsTest;


		Map <Id, List <ABSLineItemModel > > itemsByOldId = new Map <Id, List <ABSLineItemModel > > ();

		for (Map <ABSLineModel, List <ABSLineItemModel > > mp : absLines.values()) {
			for (List <ABSLineItemModel > iws : mp.values()) {
				for (ABSLineItemModel iw : iws) {
					if (!iw.IsDeleted) {
						if (itemsByOldId.get(iw.AbsLineId) == null) {
							List <ABSLineItemModel > temp = new List <ABSLineItemModel > ();
							temp.add(iw);
							itemsByOldId.put(iw.AbsLineId, temp);
						}
						else {
							itemsByOldId.get(iw.AbsLineId).add(iw);
						}
					}
				}
			}
		}

		List <Ws_Tab_Abs_Line__c > linesToInsert = new List <Ws_Tab_Abs_Line__c > ();
		Map <String, Id > absLinesByNewId = new Map <String, Id > ();
		Map <String, Id > absLinesByOldId = new Map <String, Id > ();

		for (Map <ABSLineModel, List <ABSLineItemModel > > mp : absLines.values()) {
			for (ABSLineModel lw : mp.keySet()) {
				if (!lw.IsDeleted) {
					Ws_Tab_Abs_Line__c newLine = new Ws_Tab_Abs_Line__c();
					newLine.Order_Number__c = lw.OrderNumber;
					newLine.Major_Heading__c = lw.MHeading;
					newLine.Ws_Tab_Abs__c = updatedAbsTest.id;
					newLine.Name = lw.Name;

					linesToInsert.add(newLine);
					absLinesByOldId.put(lw.Name, lw.ObjectId);
				}
			}
		}

		insert linesToInsert;


		for (Ws_Tab_Abs_Line__c newL :[SELECT Id, Name FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_Abs__c = :updatedAbsTest.id]) {
			absLinesByNewId.put(newL.Name, newL.id);
		}


		List <Ws_Tab_Abs_Line_Item__c > itemsToInsert = new List <Ws_Tab_Abs_Line_Item__c > ();


		for (Map <ABSLineModel, List <ABSLineItemModel > > mp : absLines.values()) {
			for (ABSLineModel lw : mp.keySet()) {
				if (!lw.IsDeleted) {
					if (itemsByOldId.get(absLinesByOldId.get(lw.Name)) != null) {
						for (ABSLineItemModel it : itemsByOldId.get(absLinesByOldId.get(lw.Name))) {
							Ws_Tab_Abs_Line_Item__c itemClone = new Ws_Tab_Abs_Line_Item__c();
							itemClone.Name = it.Name;
							itemClone.Order_Number__c = it.OrderNumber;
							itemClone.Ws_Tab_Abs_Line__c = absLinesByNewId.get(lw.Name);
							itemClone.Document__c = it.Document;
							itemClone.Subheading__c = it.Subheading;

							itemsToInsert.add(itemClone);

						}
					}
				}
			}
		}
		insert itemsToInsert;


		if (newLine.Name != null && newLine.Name != '') {
			newLine.AbsId = updatedAbsTest.id;
			upsert newLine.toObject();
		}
	}

	private Map <Id, List <ABSLineItemModel > > fillLineItemsByLines() {
		Map <Id, List <ABSLineItemModel > > lineItemsByLines = new Map <Id, List <ABSLineItemModel > > ();

		for (Ws_Tab_Abs_Line_Item__c lineItem :[SELECT Id, Ws_Tab_Abs_Line__c, Order_Number__c, Name, Document__c, Document__r.Link__c, Document__r.Document_Extension__c, Subheading__c FROM Ws_Tab_Abs_Line_Item__c WHERE Ws_Tab_Abs_Line__c IN(SELECT Id FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_abs__c = :abs.Implementation.id) ORDER BY Order_Number__c ASC]) {
			if (lineItemsByLines.get(lineItem.Ws_Tab_Abs_Line__c) == null) {
				List <ABSLineItemModel > temp = new List <ABSLineItemModel > ();
				temp.add(ABSLineItemModel.fromObject(lineItem));
				lineItemsByLines.put(lineItem.Ws_Tab_Abs_Line__c, temp);
			}
			else {
				lineItemsByLines.get(lineItem.Ws_Tab_Abs_Line__c).add(ABSLineItemModel.fromObject(lineItem));
			}
		}

		return lineItemsByLines;
	}

	private Map <String, Map <ABSLineModel, List <ABSLineItemModel > > > fillABSLinesByHeading(Map <Id, List <ABSLineItemModel > > lineItemsByLines) {
		Map <String, Map <ABSLineModel, List <ABSLineItemModel > > > tmpAbsLines = new Map <String, Map <ABSLineModel, List <ABSLineItemModel > > > ();

		for (Ws_Tab_Abs_Line__c al :[SELECT Id, Major_Heading__c, Ws_Tab_Abs__c, Order_Number__c, Name FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_Abs__c = :abs.Implementation.id ORDER BY Order_Number__c]) {
			if (tmpAbsLines.get(al.Major_Heading__c) == null) {
				Map <ABSLineModel, List <ABSLineItemModel > > temp = new Map <ABSLineModel, List <ABSLineItemModel > > ();
				if (lineItemsByLines.get(al.id) != null) {
					temp.put(ABSLineModel.fromObject(al), lineItemsByLines.get(al.id));
				}
				else {
					temp.put(ABSLineModel.fromObject(al), new List <ABSLineItemModel > ());
				}
				tmpAbsLines.put(al.Major_Heading__c, temp);
			}
			else {
				if (lineItemsByLines.get(al.id) != null) {
					tmpAbsLines.get(al.Major_Heading__c).put(ABSLineModel.fromObject(al), lineItemsByLines.get(al.id));
				}
				else {
					tmpAbsLines.get(al.Major_Heading__c).put(ABSLineModel.fromObject(al), new List <ABSLineItemModel > ());
				}
			}
		}

		return tmpAbsLines;
	}

	private void fillABSLines(Map <String, Map <ABSLineModel, List <ABSLineItemModel > > > tmpAbsLines) {
		for (String mHeading : tmpAbsLines.keySet()) {
			absLines.put(new HeadingWrapper(mHeading), tmpAbsLines.get(mHeading));
		}
	}

	private Set<SelectOption> fillMajorHeadings() {
		majorHeadings = new Set<SelectOption> ();
		for (HeadingWrapper h : absLines.keySet()) {
			majorHeadings.add(new SelectOption(h.heading, h.heading));
		}

		return majorHeadings;
	}

	private void getComments() {
		if (abs.Implementation.Comments__c != null) {
			commentsMsg = 'Reviewer comments: ' + abs.Implementation.Comments__c;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, commentsMsg));
		}
		else {
			commentsMsg = '';
		}
	}

	private Pagereference pagereferenceBuilder(String link) {
		PageReference p = new PageReference(link);
		p.setredirect(true);
		return p;
	}


	private List <Ws_Tab_Abs_Line_Item__c > getDeletedItems() {
		List <Ws_Tab_Abs_Line_Item__c > itemsToDelete = new List <Ws_Tab_Abs_Line_Item__c > ();
		for (Map <ABSLineModel, List <ABSLineItemModel > > mp : absLines.values()) {
			for (List <ABSLineItemModel > iws : mp.values()) {
				for (ABSLineItemModel iw : iws) {
					if (iw.IsDeleted) {
						itemsToDelete.add(iw.toObject());

					}
				}
			}
		}
		return itemsToDelete;
	}

	private List <Ws_Tab_Abs_Line_Item__c > getUpdatedItems() {
		List <Ws_Tab_Abs_Line_Item__c > itemsToUpdate = new List <Ws_Tab_Abs_Line_Item__c > ();

		for (Map <ABSLineModel, List <ABSLineItemModel > > mp : absLines.values()) {
			for (List <ABSLineItemModel > iws : mp.values()) {
				Set<Decimal> orderNumbers = new Set<Decimal> ();
				for (ABSLineItemModel iw : iws) {
					if (!iw.IsDeleted) {
						if (isOrderNumberOutOfRange(iw.OrderNumber)) {
							addErrorMsg('Order number is out of range');
							return new List <Ws_Tab_Abs_Line_Item__c > (); //void list
						}

						itemsToUpdate.add(iw.toObject());
					}

					if (orderNumbers.contains(iw.OrderNumber)) {
						addErrorMsg('Order number for items should be unique.');
						return new List <Ws_Tab_Abs_Line_Item__c > (); //void list
					}
					orderNumbers.add(iw.OrderNumber);
				}
			}
		}
		return itemsToUpdate;
	}

	private List <Ws_Tab_Abs_Line__c > getUpdatedLines() {
		List <Ws_Tab_Abs_Line__c > linesToUpdate = new List <Ws_Tab_Abs_Line__c > ();

		for (Map <ABSLineModel, List <ABSLineItemModel > > mp : absLines.values()) {
			Set<Decimal> orderNumbers = new Set<Decimal> ();
			for (ABSLineModel lw : mp.keySet()) {
				if (!lw.IsDeleted) {
					if (isOrderNumberOutOfRange(lw.OrderNumber)) {
						addErrorMsg('Order number is out of range');
						return new List <Ws_Tab_Abs_Line__c > (); //void list
					}

					linesToUpdate.add(lw.toObject());

					if (orderNumbers.contains(lw.OrderNumber)) {
						addErrorMsg('Order number for items should be unique.');
						return new List <Ws_Tab_Abs_Line__c > (); //void list
					}
					orderNumbers.add(lw.OrderNumber);
				}
			}
		}
		return linesToUpdate;
	}

	private List <Ws_Tab_Abs_Line__c > getDeletedLines() {
		List <Ws_Tab_Abs_Line__c > linesToDelete = new List <Ws_Tab_Abs_Line__c > ();

		for (Map <ABSLineModel, List <ABSLineItemModel > > mp : absLines.values()) {
			for (ABSLineModel lw : mp.keySet()) {
				if (lw.IsDeleted) {
					linesToDelete.add(lw.toObject());
					mp.remove(lw);
				}
			}
		}
		return linesToDelete;
	}




	private void clearErrorMsgs() {
		errorMsg = '';
		errorMsgAvailable = false;
	}

	private Boolean isOrderNumberOutOfRange(Decimal orderNum) {
		return orderNum >= 99 || orderNum <0;
	}

	private Boolean isOrderNumberUnique(Decimal orderNumber) {
		for (Map <ABSLineModel, List <ABSLineItemModel > > mp : absLines.values()) {
			Set<Decimal> orderNumbers = new Set<Decimal> ();
			for (ABSLineModel lw : mp.keySet()) {
				if (!lw.IsDeleted) {
					orderNumbers.add(lw.OrderNumber);
				}
				if (lw.MHeading == newLine.MHeading) {
					if (orderNumbers.contains(orderNumber)) {
						return false;
					}
				}
			}
		}
		return true;
	}


	private void addErrorMsg(String msg) {
		errorMsgAvailable = true;
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, msg));
	}

	public class HeadingWrapper implements Comparable {
		public String heading { get; set; }

		public HeadingWrapper(String i) {
			heading = i;
		}

		public Integer compareTo(Object compareTo) {
			HeadingWrapper cmpTo = (HeadingWrapper) compareTo;

			if (cmpTo.heading > this.heading) {
				return 1;
			}
			else {
				return - 1;
			}
		}
	}
}