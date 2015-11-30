/**********************************************************************
Name: FAQControllerTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a test class for FAQController.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/19/2015 Created 
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev 
***********************************************************************/
@isTest
public class FAQControllerTests {

	public static User u {get; set;}

	static{
		populateTestData();
	}
	
	@isTest
	static void testLinksAreWorkingForProd(){
		System.runAs(u){
			Test.startTest();
				FAQController abs = new FAQController();
				System.Assert(abs.AbsLink.contains('/apex/ABS'));
				System.Assert(abs.HomeLink.contains('/apex/Home'));
				System.Assert(abs.QuarterlyDataLink.contains('/apex/Quarterly_Data'));
				System.Assert(abs.PresentationsLink.contains('/apex/Presentations'));
				System.Assert(abs.FAQLink.contains('/apex/FAQ'));
				System.Assert(abs.isProd);
			Test.stopTest();

		}
	}
	
	@isTest
	static void testLinksAreWorkingForTest(){
		System.runAs(u){
			PageReference pageRef = Page.FAQ;
			Test.setCurrentPage(pageRef);
			
			ApexPages.currentPage().getParameters().put('version', 'test');

			Test.startTest();
				FAQController abs = new FAQController();
				
				System.Assert(abs.AbsLink.contains('/apex/ABS?version=test'));
				System.Assert(abs.HomeLink.contains('/apex/Home?version=test'));
				System.Assert(abs.QuarterlyDataLink.contains('/apex/Quarterly_Data?version=test'));
				System.Assert(abs.PresentationsLink.contains('/apex/Presentations?version=test'));
				System.Assert(abs.FAQLink.contains('/apex/FAQ?version=test'));
				System.Assert(!abs.isProd);
			Test.stopTest();

		}
	} 
	
	@isTest
	static void testLinksAreWorkingForHistorical(){
		System.runAs(u){
			PageReference pageRef = Page.FAQ;
			Test.setCurrentPage(pageRef);
			
			ApexPages.currentPage().getParameters().put('id', [SELECT Id FROM Ws_Tab_Faq__c WHERE State__c = 'Sent For Review'][0].id);

			Test.startTest();
				FAQController abs = new FAQController();
				
				System.Assert(abs.AbsLink.contains('/apex/ABS?version=test'));
				System.Assert(abs.HomeLink.contains('/apex/Home?version=test'));
				System.Assert(abs.QuarterlyDataLink.contains('/apex/Quarterly_Data?version=test'));
				System.Assert(abs.PresentationsLink.contains('/apex/Presentations?version=test'));
				System.Assert(abs.FAQLink.contains('/apex/FAQ?version=test'));
				System.Assert(!abs.isProd);
			Test.stopTest();

		}
	}  


	private static void populateTestData(){
		Helper.insertRecords();

		List<Ws_Tab_Faq_Line__c> testLines = [SELECT Id FROM Ws_Tab_Faq_Line__c WHERE Ws_Tab_Faq__c IN (SELECT ID FROM Ws_Tab_Faq__c WHERE State__c = 'Sent For Review')];
		List<Ws_Tab_Faq_Line__c> prodLines = [SELECT Id FROM Ws_Tab_Faq_Line__c WHERE Ws_Tab_Faq__c IN (SELECT ID FROM Ws_Tab_Faq__c WHERE State__c = 'Approved')];

		List<Ws_Tab_Faq_Line_Item__c> testItems = new List<Ws_Tab_Faq_Line_Item__c>();
		List<Ws_Tab_Faq_Line_Item__c> productionItems = new List<Ws_Tab_Faq_Line_Item__c>();
		

		for(Integer i = 0; i < 10; i++){
			

			Ws_Tab_Faq_Line_Item__c testTmp = new Ws_Tab_Faq_Line_Item__c(Ws_Tab_Faq_Line__c = testLines[0].id, Order_Number__c = i);
			testItems.add(testTmp);

			Ws_Tab_Faq_Line_Item__c prodTmp = new Ws_Tab_Faq_Line_Item__c(Ws_Tab_Faq_Line__c = prodLines[0].id, Order_Number__c = i);
			productionItems.add(prodTmp);
		}

		insert testItems;
		insert productionItems;


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