/**********************************************************************
Name: FAQApprovalControllerTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a test class for FAQApprovalController.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/18/2015 Created 
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev 
***********************************************************************/
@isTest
public class FAQApprovalControllerTests {
	public static Ws_Tab_Faq__c absTest {get; set;}
    public static Ws_Tab_Faq__c absProduction {get; set;}
	public static Investor_Relation_Website__c ws {get; set;}
	public static Reviewer_Email__c reviewerEmail {get; set;}

	public static  String absTestRecordTypeId {get; set;}
	public static  String absProductionRecordTypeId {get; set;}

	public static List<Ws_Tab_Faq_Line__c> testLines {get; set;} 
	public static List<Ws_Tab_Faq_Line_Item__c> testItems {get; set;}

	public static List<Ws_Tab_Faq_Line__c> productionLines {get; set;} 
	public static List<Ws_Tab_Faq_Line_Item__c> productionItems {get; set;}

	public static User u {get; set;}

	static{
		populateTestData();
	}

	@isTest
	static void approverPressApproveShouldUpdateProd(){
		System.runAs(u){
			Test.startTest();
			FAQApprovalController faq = new FAQApprovalController();
			faq.approve();
			Test.stopTest();

			System.assertEquals([SELECT Count() FROM Ws_Tab_Faq__c WHERE Name = 'FAQ'], 1);
			System.assertEquals([SELECT Count() FROM Ws_Tab_Faq__c WHERE RecordtypeId = :absProductionRecordTypeId AND State__c = 'Rejected'], 1);
		}
	}

	@isTest
	static void approvedPressRejectApproveShouldNotUpdateProd(){
		clearData();
		populateTestData();

		System.runAs(u){
			Test.startTest();
			FAQApprovalController faq = new FAQApprovalController();
			faq.reject();
			Test.stopTest();

			System.assertEquals([SELECT Count() FROM Ws_Tab_Faq__c WHERE Name = 'FAQ'], 0);
			System.assertEquals([SELECT Count() FROM Ws_Tab_Faq__c WHERE RecordtypeId = :absTestRecordTypeId AND State__c = 'Rejected'], 0);
		}
		
	}

	private static void clearData(){
		delete ws;
	}

	private static void populateTestData(){
		absTestRecordTypeId = Schema.SObjectType.Ws_Tab_Faq__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
		absProductionRecordTypeId = Schema.SObjectType.Ws_Tab_Faq__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
		
		ws  = new Investor_Relation_Website__c();
		insert ws;

		absTest = new Ws_Tab_Faq__c(Name='Test',
											  Investor_Relations_Website__c = ws.id,
											  RecordtypeId = absTestRecordTypeId,
											  State__c = 'Sent For Review');

		insert absTest;

		absProduction = new Ws_Tab_Faq__c(Name='Prod',
											  Investor_Relations_Website__c = ws.id,
											  RecordtypeId = absProductionRecordTypeId,
											  State__c = 'Approved');

		insert absProduction;

		testLines = new List<Ws_Tab_Faq_Line__c>();
		productionLines = new List<Ws_Tab_Faq_Line__c>();
		testItems = new List<Ws_Tab_Faq_Line_Item__c>();
		productionItems = new List<Ws_Tab_Faq_Line_Item__c>();

		for(Integer i = 0; i < 1; i++){
			Ws_Tab_Faq_Line__c testTmp = new Ws_Tab_Faq_Line__c(Ws_Tab_Faq__c = absTest.id);
			testLines.add(testTmp);

			Ws_Tab_Faq_Line__c prodTmp = new Ws_Tab_Faq_Line__c(Ws_Tab_Faq__c = absProduction.id);
			productionLines.add(prodTmp);
		}
		
		insert testLines;
		insert productionLines;

		for(Integer i = 0; i < 10; i++){
			Ws_Tab_Faq_Line_Item__c testTmp = new Ws_Tab_Faq_Line_Item__c(Ws_Tab_Faq_Line__c = testLines[0].id);
			testItems.add(testTmp);

			Ws_Tab_Faq_Line_Item__c prodTmp = new Ws_Tab_Faq_Line_Item__c(Ws_Tab_Faq_Line__c = productionLines[0].id);
			productionItems.add(prodTmp);
		}

		insert testItems;
		insert productionItems;

		if(reviewerEmail == null){
			reviewerEmail = new Reviewer_Email__c(Email__c = 'testxczxczxczasdas1222@test.com');
			insert reviewerEmail;
		}

		Profile p = [select id
                      from profile
                      where Name = 'System Administrator'
                      limit 1];  
		

		if(u == null){
			u = new User(profileId = p.id, username = 'test122sdasdsdas2@test.com', email = 'testxczxczxczasdas1222@test.com',
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname');
		

		
			insert u;
		
		}
	}
 }