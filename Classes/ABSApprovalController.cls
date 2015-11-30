/**********************************************************************
Name: ABSApprovalController
Copyright � notice: NMAC.
======================================================
Purpose:
This is a controller for "ABSpageApproval" page
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/12/2015 Created 
1.1 - Arshakyan Georgiy 5/25/2015 Refactored
1.2 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev
***********************************************************************/
public class ABSApprovalController {
	public Ws_Tab_Abs__c absTest { get; set; }
	public Ws_Tab_Abs__c absProduction { get; set; }
	public String Comments { get; set; }
	private String absTestRecordTypeId { get; set; }
	private String absProductionRecordTypeId { get; set; }



	public Boolean isUserAreApprover { get; set; }
	private Reviewer_Email__c reviewerEmail { get; set; }

	public ABSApprovalController() {
		reviewerEmail = Reviewer_Email__c.getOrgDefaults();

		if (reviewerEmail.Email__c != [SELECT Email, Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1] [0].Email) {
			isUserAreApprover = false;

		}
		
		else {
			isUserAreApprover = true;

			absTestRecordTypeId = Schema.SObjectType.Ws_Tab_Abs__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
			absTest = [SELECT Id, Comments__c, Overview__c, Name, LastModifiedById, Investor_Relations_Website__c, State__c FROM Ws_Tab_abs__c WHERE State__c = 'Sent For Review' AND RecordtypeId = :absTestRecordTypeId] [0];
			Comments = '';

			absProductionRecordTypeId = Schema.SObjectType.Ws_Tab_Abs__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
			absProduction = [SELECT Id, Comments__c, Overview__c, Name, LastModifiedById, Investor_Relations_Website__c, State__c FROM Ws_Tab_abs__c WHERE RecordtypeId = :absProductionRecordTypeId AND State__c = 'Approved'] [0];
		}
	}

	public Pagereference approve() {
		sendEmail(absTest.LastModifiedById, false);
		Ws_Tab_Abs__c updatedAbsTest = cloneCurrentTestPage();
		insert updatedAbsTest;

		cloneAllComponents(updatedAbsTest);

		approveCurrentTestPage();
		rejectCurrentProductionPage();

		
		return redirectHome();
	}

	public Pagereference reject() {
		if(!Test.isRunningtest()){
			sendEmail(absTest.LastModifiedById, true);
		}
		addCommentsToTestPage();
		
		return redirectHome();
	}

	private Ws_Tab_Abs__c cloneCurrentTestPage() {
		Ws_Tab_Abs__c updatedAbsTest = new Ws_Tab_Abs__c();

		updatedAbsTest.Name = absTest.Name;
		updatedAbsTest.RecordtypeId = absTestRecordTypeId;
		updatedAbsTest.Overview__c = absTest.Overview__c;
		updatedAbsTest.State__c = absTest.State__c;
		updatedAbsTest.Investor_Relations_Website__c = absTest.Investor_Relations_Website__c;

		return updatedAbsTest;
	}

	private void cloneAllComponents(Ws_Tab_Abs__c updatedAbsTest) {
		Map<Id, List<Ws_Tab_Abs_Line_Item__c>> itemsByOldId = fillItemsByOldId();
		Map<String, Id> absLinesByOldId = fillLinesByOldId();
		
		List<Ws_Tab_Abs_Line__c> linesToInsert = cloneLines(updatedAbsTest);
		insert linesToInsert;

		List <Ws_Tab_Abs_Line_Item__c > itemsToInsert = cloneItems(updatedAbsTest, absLinesByOldId, itemsByOldId);
		insert itemsToInsert;

	}

	private Map<Id, List <Ws_Tab_Abs_Line_Item__c>> fillItemsByOldId() {
		Map<Id, List <Ws_Tab_Abs_Line_Item__c>> itemsByOldId = new Map<Id, List <Ws_Tab_Abs_Line_Item__c>>();

		for (Ws_Tab_Abs_Line_Item__c lineItem :[SELECT Id, Ws_Tab_Abs_Line__c, Order_Number__c, Name, Document__c, Document__r.Link__c, Subheading__c FROM Ws_Tab_Abs_Line_Item__c WHERE Ws_Tab_Abs_Line__c IN(SELECT Id FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_abs__c = :absTest.id)]) {
			if (itemsByOldId.get(lineItem.Ws_Tab_Abs_Line__c) == null) {
				List <Ws_Tab_Abs_Line_Item__c > temp = new List <Ws_Tab_Abs_Line_Item__c > ();
				temp.add(lineItem);
				itemsByOldId.put(lineItem.Ws_Tab_Abs_Line__c, temp);
			}
			else {
				itemsByOldId.get(lineItem.Ws_Tab_Abs_Line__c).add(lineItem);
			}
		}

		return itemsByOldId;
	}

	private Map<String, Id> fillLinesByOldId(){
		Map <String, Id > absLinesByOldId = new Map <String, Id> ();
	
		for (Ws_Tab_Abs_Line__c line :[SELECT Id, Name, Order_Number__c, Major_Heading__c, Ws_Tab_Abs__c FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_Abs__c = :absTest.id]) {
			absLinesByOldId.put(line.Name, line.id);
		}
		return absLinesByOldId;
	}

	private List<Ws_Tab_Abs_Line__c> cloneLines(Ws_Tab_Abs__c updatedAbsTest){
		List<Ws_Tab_Abs_Line__c> linesToInsert = new List<Ws_Tab_Abs_Line__c>();

		for (Ws_Tab_Abs_Line__c line :[SELECT Id, Name, Order_Number__c, Major_Heading__c, Ws_Tab_Abs__c FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_Abs__c = :absTest.id]) {
			linesToInsert.add(cloneLine(line, updatedAbsTest));
		}
		return linesToInsert;
	}

	private Ws_Tab_Abs_Line__c cloneLine(Ws_Tab_Abs_Line__c line, Ws_Tab_Abs__c updatedAbsTest){
		Ws_Tab_Abs_Line__c newLine = new Ws_Tab_Abs_Line__c();
		newLine.Major_Heading__c = line.Major_Heading__c;
		newLine.Ws_Tab_Abs__c = updatedAbsTest.id;
		newLine.Order_Number__c = line.Order_Number__c;
		newLine.Name = line.Name;

		return newLine;
	}

	private List<Ws_Tab_Abs_Line_Item__c> cloneItems(Ws_Tab_Abs__c updatedAbsTest, Map<String, Id> absLinesByOldId, Map<Id, List<Ws_Tab_Abs_Line_Item__c>> itemsByOldId){
		List <Ws_Tab_Abs_Line_Item__c> itemsToInsert = new List <Ws_Tab_Abs_Line_Item__c>();

		for (Ws_Tab_Abs_Line__c l :[SELECT Id, Name, Major_Heading__c, Ws_Tab_Abs__c FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_Abs__c = :updatedAbsTest.id]) {
			if (itemsByOldId.get(absLinesByOldId.get(l.Name)) != null) {
				for (Ws_Tab_Abs_Line_Item__c it : itemsByOldId.get(absLinesByOldId.get(l.Name))) {
					itemsToInsert.add(cloneItem(l, it));
				}
			}
		}
		return itemsToInsert;
	}

	private Ws_Tab_Abs_Line_Item__c cloneItem(Ws_Tab_Abs_Line__c l, Ws_Tab_Abs_Line_Item__c it){
		Ws_Tab_Abs_Line_Item__c itemClone = new Ws_Tab_Abs_Line_Item__c();
		itemClone.Name = it.Name;
		itemClone.Order_Number__c = it.Order_Number__c;
		itemClone.Ws_Tab_Abs_Line__c = l.id;
		itemClone.Document__c = it.Document__c;
		itemClone.Subheading__c = it.Subheading__c;

		return itemClone;
	}

	private void approveCurrentTestPage(){
		absTest.RecordtypeId = absProductionRecordTypeId;
		absTest.State__c = 'Approved';
		absTest.Comments__c = Comments;

		update absTest;
	}

	private void rejectCurrentProductionPage(){
		absProduction.State__c = 'Rejected';
		update absProduction;
	}

	private void addCommentsToTestPage(){
		absTest.Comments__c = Comments;
		update absTest;
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
			mail.setSubject('Investor Relation page "ABS" was Rejected');
			mail.setPlainTextBody('Investor Relation page  "ABS" was Rejected and following comments added: ' + Comments);
			mail.setHtmlBody('Investor Relation page  "ABS" was Rejected and following comments added: ' + '<b>' + Comments + '</b>');
		}
		else {
			mail.setSubject('Investor Relation page "ABS" Approved and Deployed to Production');
			mail.setPlainTextBody('Investor Relation page "ABS" Approved and Deployed to Production');
			mail.setHtmlBody('Investor Relation page "ABS" Approved and Deployed to Production');

		}
		System.DEBUG(mail);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}