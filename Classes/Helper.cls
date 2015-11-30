/**********************************************************************
Name: Helper
Copyright � notice: NMAC.
======================================================
Purpose:
This is an helper class to insert void records of Investor_Relation_Website__c sObject,
And two versions of all pages: "Home", "ABS", "FAQ", "Presentations", "Quarterly Data"
+ insert custom settings, such as:  Reviewer_Email__c, QD_Components_Available__c and Pages_Available__c
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/5/2015 Created 
1.1 - Arshakyan Georgiy 5/21/2015 Added custom settings insertion
1.2 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev
***********************************************************************/
public without sharing class Helper {
	
	/*
	*	Method to insert two instance of all pages(approved and test) (with all subitems etc)
	*/
	public static void insertRecords(){
		Investor_Relation_Website__c website = new Investor_Relation_Website__c();

		List<Investor_Relation_Website__c> availableWS = new List<Investor_Relation_Website__c>();
		availableWS = [SELECT Id, Name FROM Investor_Relation_Website__c WHERE Name = 'Investor Relations Website'];
		
		if(!availableWS.isEmpty()){
			website = availableWS.get(0);
		}
		else{
			website.Name = 'Investor Relations Website';
			insert website;
			insertRejectedPages(website);
			insertApprovedPages(website);
			insertCustomSettings();
		}

		
	}

	private static void insertRejectedPages(Investor_Relation_Website__c ws){
		String homeTestRecordTypeId = Schema.SObjectType.Ws_Tab_Home__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
		String absTestRecordTypeId = Schema.SObjectType.Ws_Tab_abs__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
		String faqTestRecordTypeId = Schema.SObjectType.Ws_Tab_Faq__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
		String presentationTestRecordTypeId = Schema.SObjectType.Ws_Tab_Presentations__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
		String qdataTestRecordTypeId = Schema.SObjectType.Ws_Tab_Quarterly_Data__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();

		Ws_Tab_Home__c home = new Ws_Tab_Home__c(Name='Home',
												 Information_Text__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
												 Ratings_Text__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
												 Investor_Relations_Website__c = ws.id,
												 RecordtypeId = homeTestRecordTypeId,
												 State__c = 'Sent For Review');
		insert home;
		
		Ws_Tab_abs__c abs = new Ws_Tab_abs__c(Name='Abs',
											  Investor_Relations_Website__c = ws.id,
											  RecordtypeId = absTestRecordTypeId,
											  State__c = 'Sent For Review');

		insert abs;

		List<Ws_Tab_Abs_Line__c> testLines = new List<Ws_Tab_Abs_Line__c>();

		Ws_Tab_Abs_Line__c absLineF = new Ws_Tab_Abs_Line__c(Major_Heading__c = 'Floor Plan', Ws_Tab_Abs__c = abs.id);
		testLines.add(absLineF);
		Ws_Tab_Abs_Line__c absLineR = new Ws_Tab_Abs_Line__c(Major_Heading__c = 'Retail', Ws_Tab_Abs__c = abs.id);
		testLines.add(absLineR);
		Ws_Tab_Abs_Line__c absLineL = new Ws_Tab_Abs_Line__c(Major_Heading__c = 'Lease', Ws_Tab_Abs__c = abs.id);
		testLines.add(absLineL);

		insert testLines;
		
		Ws_Tab_Faq__c faq = new Ws_Tab_Faq__c(Name='FAQ',
											  Investor_Relations_Website__c = ws.id,
											  RecordtypeId = faqTestRecordTypeId,
											  State__c = 'Sent For Review');
		insert faq;

		Ws_Tab_Faq_Line__c testTmp = new Ws_Tab_Faq_Line__c(Ws_Tab_Faq__c = faq.id);
		insert testTmp;

		Ws_Tab_Presentations__c presentation = new Ws_Tab_Presentations__c(Name='Presentation',
																		   Investor_Relations_Website__c = ws.id,
																		   State__c = 'Sent For Review',
																		   RecordtypeId = presentationTestRecordTypeId,
																		   Header_Text__c = 'Verbiage explaining page');

		insert presentation; 
		

		Ws_Tab_Quarterly_Data__c qdata = new Ws_Tab_Quarterly_Data__c(Name='Quarterly Data',
																	Investor_Relations_Website__c = ws.id,
																	State__c = 'Sent For Review',
																	RecordtypeId = qdataTestRecordTypeId,
																	Header_Text__c = 'Verbiage explaining page');
		insert qdata; 
		
		Document_Proxy__c dp = new Document_Proxy__c(Link__c = '/');
		insert dp;


		Footer__c footer  = new Footer__c(Investor_Relations_Website__c = ws.id,
									   State__c = 'Sent For Review',
									   Document__c = dp.id);
		insert footer;
	}
	private static void insertApprovedPages(Investor_Relation_Website__c ws){
		String homeProductionRecordTypeId = Schema.SObjectType.Ws_Tab_Home__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
		String absProductionRecordTypeId = Schema.SObjectType.Ws_Tab_abs__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
		String faqProductionRecordTypeId = Schema.SObjectType.Ws_Tab_Faq__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
		String presentationProductionRecordTypeId = Schema.SObjectType.Ws_Tab_Presentations__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
		String qdataProductionRecordTypeId = Schema.SObjectType.Ws_Tab_Quarterly_Data__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();

		Ws_Tab_Home__c home = new Ws_Tab_Home__c(Name='Home',
												 Information_Text__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
												 Ratings_Text__c = 'APPROVED Lorem ipsum dolor sit amet, consectetur adipiscing elit',
												 Investor_Relations_Website__c = ws.id,
												 RecordtypeId = homeProductionRecordTypeId,
												 State__c = 'Approved');
		insert home;
		
		
		Ws_Tab_abs__c abs = new Ws_Tab_abs__c(Name='Abs',
											  Investor_Relations_Website__c = ws.id,
											  RecordtypeId = absProductionRecordTypeId,
											  State__c = 'Approved');

		insert abs;

		List<Ws_Tab_Abs_Line__c> testLines = new List<Ws_Tab_Abs_Line__c>();

		Ws_Tab_Abs_Line__c absLineF = new Ws_Tab_Abs_Line__c(Major_Heading__c = 'Floor Plan', Ws_Tab_Abs__c = abs.id);
		testLines.add(absLineF);
		Ws_Tab_Abs_Line__c absLineR = new Ws_Tab_Abs_Line__c(Major_Heading__c = 'Retail', Ws_Tab_Abs__c = abs.id);
		testLines.add(absLineR);
		Ws_Tab_Abs_Line__c absLineL = new Ws_Tab_Abs_Line__c(Major_Heading__c = 'Lease', Ws_Tab_Abs__c = abs.id);
		testLines.add(absLineL);

		insert testLines;

		Ws_Tab_Faq__c faq = new Ws_Tab_Faq__c(Name='FAQ',
											  Investor_Relations_Website__c = ws.id,
											  RecordtypeId = faqProductionRecordTypeId,
											  State__c = 'Approved');
		insert faq;
		Ws_Tab_Faq_Line__c testTmp = new Ws_Tab_Faq_Line__c(Ws_Tab_Faq__c = faq.id);
		insert testTmp;


		Ws_Tab_Presentations__c presentation = new Ws_Tab_Presentations__c(Name='Presentation',
																		   Investor_Relations_Website__c = ws.id,
																		   State__c = 'Approved',
																		   RecordtypeId = presentationProductionRecordTypeId,
																		   Header_Text__c = 'Verbiage explaining page');

		insert presentation; 
		
		Ws_Tab_Quarterly_Data__c qdata = new Ws_Tab_Quarterly_Data__c(Name='Quarterly Data',
																	Investor_Relations_Website__c = ws.id,
																	State__c = 'Approved',
																	RecordtypeId = qdataProductionRecordTypeId,
																	Header_Text__c = 'Verbiage explaining page');
		insert qdata;
		
		Document_Proxy__c dp = new Document_Proxy__c(Link__c = '/home');
		insert dp;

		Footer__c footer  = new Footer__c(Investor_Relations_Website__c = ws.id,
									   State__c = 'Approved',
									   Document__c = dp.id);
		insert footer; 
		
	}
	private static void insertCustomSettings(){
		Reviewer_Email__c reviewerEmail = new Reviewer_Email__c(Email__c = 'test@test.com');
		insert reviewerEmail;

		QD_Components_Available__c qd = new QD_Components_Available__c(Available__c = false);
		insert qd;
		
		Pages_Available__c settings = new Pages_Available__c(
															Is_Home_Available__c = true,
															Is_ABS_Available__c = true,
															Is_FAQ_Available__c = true,
															Is_Presentations_Available__c = true,
															Is_QD_Available__c = true
		);

		insert settings;
	}

 }