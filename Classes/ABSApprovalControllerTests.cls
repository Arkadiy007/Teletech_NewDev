/**********************************************************************
Name: ABSApprovalControllerTests
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test class for "ABSApprovalControllerTests"
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/19/2015 Created 
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev
***********************************************************************/
@isTest
public class ABSApprovalControllerTests {
	public static Ws_Tab_Abs__c absTest {get; set;}
    public static Ws_Tab_Abs__c absProduction {get; set;}
	public static Investor_Relation_Website__c ws {get; set;}
	public static Reviewer_Email__c reviewerEmail {get; set;}

	public static Boolean isDataDeletedPrevious {get; set;}

	public static  String absTestRecordTypeId {get; set;}
	public static  String absProductionRecordTypeId {get; set;}

	public static List<Ws_Tab_Abs_Line__c> testLines {get; set;} 
	public static List<Ws_Tab_Abs_Line_Item__c> testItems {get; set;}

	public static List<Ws_Tab_Abs_Line__c> productionLines {get; set;} 
	public static List<Ws_Tab_Abs_Line_Item__c> productionItems {get; set;}

	public static User u {get; set;}

	static{
		isDataDeletedPrevious = false;
		populateTestData();
	}

	@isTest
	static void approverPressApproveShouldUpdateProd(){
		System.runAs(u){
			Test.startTest();
			ABSApprovalController abs = new ABSApprovalController();
			abs.approve();
			Test.stopTest();

			System.assertEquals([SELECT Count() FROM Ws_Tab_abs__c WHERE Name = 'Test Abs'], 2);
			System.assertEquals([SELECT Major_Heading__c FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_abs__c IN (SELECT Id FROM Ws_Tab_Abs__c WHERE State__c = 'Approved')][0].Major_Heading__c, 'Floor Plan');
			System.assertEquals([SELECT Count() FROM Ws_Tab_abs__c WHERE RecordtypeId = :absProductionRecordTypeId AND State__c = 'Rejected'], 1);
		}
	}

	@isTest
	static void approvedPressRejectApproveShouldNotUpdateProd(){
		clearData();
		populateTestData();

		System.runAs(u){
			Test.startTest();
			ABSApprovalController abs = new ABSApprovalController();
			abs.reject();
			Test.stopTest();

			System.assertEquals([SELECT Count() FROM Ws_Tab_abs__c WHERE Name = 'Abs'], 1);
			System.assertEquals([SELECT Major_Heading__c FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_abs__c IN (SELECT Id FROM Ws_Tab_Abs__c WHERE State__c = 'Approved')][0].Major_Heading__c, 'Lease');
			System.assertEquals([SELECT Count() FROM Ws_Tab_abs__c WHERE RecordtypeId = :absTestRecordTypeId AND State__c = 'Rejected'], 0);
		}
		
	}

	private static void clearData(){
		isDataDeletedPrevious = true;
		delete ws;
	}

	private static void populateTestData(){
		absTestRecordTypeId = Schema.SObjectType.Ws_Tab_Abs__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
		absProductionRecordTypeId = Schema.SObjectType.Ws_Tab_Abs__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
		
		ws  = new Investor_Relation_Website__c();
		insert ws;

		absTest = new Ws_Tab_abs__c(Name='Test Abs',
											  Investor_Relations_Website__c = ws.id,
											  RecordtypeId = absTestRecordTypeId,
											  State__c = 'Sent For Review');

		insert absTest;

		absProduction = new Ws_Tab_abs__c(Name='Abs',
											  Investor_Relations_Website__c = ws.id,
											  RecordtypeId = absProductionRecordTypeId,
											  State__c = 'Approved');

		insert absProduction;

		testLines = new List<Ws_Tab_Abs_Line__c>();
		productionLines = new List<Ws_Tab_Abs_Line__c>();
		testItems = new List<Ws_Tab_Abs_Line_Item__c>();
		productionItems = new List<Ws_Tab_Abs_Line_Item__c>();

		for(Integer i = 0; i < 10; i++){
			Ws_Tab_Abs_Line__c testTmp = new Ws_Tab_Abs_Line__c(Major_Heading__c = 'Floor Plan', Ws_Tab_Abs__c = absTest.id);
			testLines.add(testTmp);

			Ws_Tab_Abs_Line__c prodTmp = new Ws_Tab_Abs_Line__c(Major_Heading__c = 'Lease', Ws_Tab_Abs__c = absProduction.id);
			productionLines.add(prodTmp);
		}
		
		insert testLines;
		insert productionLines;

		for(Integer i = 0; i < 10; i++){
			Ws_Tab_Abs_Line_Item__c testTmp = new Ws_Tab_Abs_Line_Item__c(Ws_Tab_Abs_Line__c = testLines[0].id);
			testItems.add(testTmp);

			Ws_Tab_Abs_Line_Item__c prodTmp = new Ws_Tab_Abs_Line_Item__c(Ws_Tab_Abs_Line__c = productionLines[0].id);
			productionItems.add(prodTmp);
		}

		insert testItems;
		insert productionItems;

		if(!isDataDeletedPrevious){
		if(reviewerEmail == null){
			reviewerEmail = new Reviewer_Email__c(Email__c = 'test1222@test.com');
			insert reviewerEmail;
		}

		Profile p = [select id
                      from profile
                      where Name = 'System Administrator'
                      limit 1];  
		
		if(u == null){
			u = new User(profileId = p.id, username = 'tesasdasdadwdasdwdasdt1222@test.com', email = 'test1222@test.com',
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname');
		

		
			insert u;
		
		}
		}
	}
 }