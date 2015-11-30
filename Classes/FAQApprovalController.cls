/**********************************************************************
Name: FAQApprovalController
Copyright � notice: NMAC.
======================================================
Purpose:
This is a controller for "FAQApprovalPage" page
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/13/2015 Created 
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev 
***********************************************************************/
public class FAQApprovalController {

	public Ws_Tab_Faq__c fTest { get; set; }
	public Ws_Tab_Faq__c fProduction { get; set; }
	public String Comments { get; set; }
	private String fTestRecordTypeId { get; set; }
	private String fProductionRecordTypeId { get; set; }

	public Boolean isUserAreApprover { get; set; }
	private Reviewer_Email__c reviewerEmail { get; set; }

	public FAQApprovalController() {
		reviewerEmail = Reviewer_Email__c.getOrgDefaults();

		if (reviewerEmail.Email__c != [SELECT Email, Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1] [0].Email) {
			isUserAreApprover = false;
		}
		else {
			isUserAreApprover = true;
			fTestRecordTypeId = Schema.SObjectType.Ws_Tab_Faq__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
			fTest = [SELECT Id, Comments__c, LastModifiedById, State__c, Investor_Relations_Website__c FROM Ws_Tab_Faq__c WHERE RecordtypeId = :fTestRecordTypeId AND State__c = 'Sent For Review'] [0];
			Comments = '';

			fProductionRecordTypeId = Schema.SObjectType.Ws_Tab_Faq__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
			fProduction = [SELECT Id, Comments__c, LastModifiedById, State__c, Investor_Relations_Website__c FROM Ws_Tab_Faq__c WHERE RecordtypeId = :fProductionRecordTypeId AND State__c = 'Approved'] [0];
		}
		
	}

	public Pagereference approve() {
		
		sendEmail(fTest.LastModifiedById, false);
		
		Ws_Tab_Faq__c updatedTestFAQ = new Ws_Tab_Faq__c();

		updatedTestFAQ.RecordtypeId = fTestRecordTypeId;
		updatedTestFAQ.State__c = 'Sent For Review';
		updatedTestFAQ.Name = 'FAQ';
		updatedTestFAQ.Investor_Relations_Website__c = fTest.Investor_Relations_Website__c;
		updatedTestFAQ.Comments__c = Comments;

		insert updatedTestFAQ;

		Ws_Tab_Faq_Line__c testLine = [SELECT Id FROM Ws_Tab_Faq_Line__c WHERE Ws_Tab_Faq__c = :fTest.id] [0];

		Ws_Tab_Faq_Line__c updatedLine = new Ws_Tab_Faq_Line__c();
		updatedLine.Ws_Tab_Faq__c = updatedTestFAQ.id;

		insert updatedLine;




		List <Ws_Tab_Faq_Line_Item__c > itemsToInsert = new List <Ws_Tab_Faq_Line_Item__c > ();

		for (Ws_Tab_Faq_Line_Item__c it :[SELECT Id, Answer__c, Order_Number__c, Question__c, Ws_Tab_Faq_Line__c FROM Ws_Tab_Faq_Line_Item__c WHERE Ws_Tab_Faq_Line__c = :testLine.id ORDER BY Order_Number__c]) {
			Ws_Tab_Faq_Line_Item__c item = new Ws_Tab_Faq_Line_Item__c();
			item.Answer__c = it.Answer__c;
			item.Order_Number__c = it.Order_Number__c;
			item.Question__c = it.Question__c;
			item.Ws_Tab_Faq_Line__c = updatedLine.id;

			itemsToInsert.add(item);
		}


		insert itemsToInsert;

		fTest.RecordtypeId = fProductionRecordTypeId;
		fTest.State__c = 'Approved';

		fProduction.State__c = 'Rejected';


		update fTest;
		update fProduction;

		PageReference pageRef = new PageReference('/');
		pageRef.setRedirect(true);

		return pageRef;
	}

	public Pagereference reject() {
		
		sendEmail(fTest.LastModifiedById, true);
		

		fTest.Comments__c = Comments;
		update fTest;

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
			mail.setSubject('Investor Relation page "FAQ" was Rejected');
			mail.setPlainTextBody('Investor Relation page  "FAQ" was Rejected and following comments added: ' + Comments);
			mail.setHtmlBody('Investor Relation page  "FAQ" was Rejected and following comments added: ' + '<b>' + Comments + '</b>');
		}
		else {
			mail.setSubject('Investor Relation page "FAQ" Approved and Deployed to Production');
			mail.setPlainTextBody('Investor Relation page "FAQ" Approved and Deployed to Production');
			mail.setHtmlBody('Investor Relation page "FAQ" Approved and Deployed to Production');
		}
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}


}