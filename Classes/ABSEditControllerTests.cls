/**********************************************************************
Name: ABSEditControllerTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a controller for "ABSpageEdit" page
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/20/2015 Created 
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev
***********************************************************************/
@isTest
public class ABSEditControllerTests {
	public static Ws_Tab_Abs__c absTest {get; set;}
	public static Ws_Tab_Abs__c absHistoryPage {get; set;}

	public static Investor_Relation_Website__c ws {get; set;}
	public static Reviewer_Email__c reviewerEmail {get; set;}

	public static  String absTestRecordTypeId {get; set;}
	public static  String absProductionRecordTypeId {get; set;}

	public static List<Ws_Tab_Abs_Line__c> testLines {get; set;} 
	public static List<Ws_Tab_Abs_Line_Item__c> testItems {get; set;}

	public static List<Ws_Tab_Abs_Line__c> historyLines {get; set;} 
	public static List<Ws_Tab_Abs_Line_Item__c> historyItems {get; set;}

	public static User u {get; set;}

	static{
		populateTestData();
	}
	
	@isTest
	static void deleteItems_ShouldDeleteABSLineItems(){
		System.runAs(u){
			Test.startTest();
			ABSEditController abs = new ABSEditController();
			
			System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Abs_Line_Item__c WHERE Ws_Tab_Abs_Line__c =: testLines[0].id]);

			//Mark all items for deletion
			for(Map<ABSLineModel, List<ABSLineItemModel>> mp : abs.absLines.values()){
				for(List<ABSLineItemModel> iws : mp.values()){
					for(ABSLineItemModel iw : iws){
						iw.IsDeleted = true;
						}
					}
				}	
			
		
			
			abs.saveAndSubmit();
			Test.stopTest();

			System.assertEquals(0, [SELECT Count() FROM Ws_Tab_Abs_Line_Item__c WHERE Ws_Tab_Abs_Line__c =: testLines[0].id]);
		}
	}
	

	@isTest
	static void updateItems_ShouldCorrectlyUpdateAllOfItems(){
		System.runAs(u){
			Test.startTest();
			ABSEditController abs = new ABSEditController();
			
			System.assertEquals(null, [SELECT Subheading__c FROM Ws_Tab_Abs_Line_Item__c WHERE Ws_Tab_Abs_Line__c =: testLines[0].id][0].Subheading__c);

			//Change all items: Subheading__c = 'test'
			for(Map<ABSLineModel, List<ABSLineItemModel>> mp : abs.absLines.values()){
				for(List<ABSLineItemModel> iws : mp.values()){
					for(ABSLineItemModel iw : iws){
						iw.Subheading = 'test';
						}
					}
				}	
			
			
			abs.saveAndPreview();
			Test.stopTest();

			System.assertEquals('test', [SELECT Subheading__c FROM Ws_Tab_Abs_Line_Item__c WHERE Ws_Tab_Abs_Line__c =: testLines[0].id][0].Subheading__c);
		}
	}
	
	@isTest
	static void updateLines_ShouldCorrectlyUpdateAllOfItems(){
		System.runAs(u){
			Test.startTest();
			ABSEditController abs = new ABSEditController();
			
			System.assertEquals('Floor Plan', [SELECT Major_Heading__c FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_Abs__c =: absTest.id][0].Major_Heading__c);

			
			//Change all lines: Major_Heading__c = 'Lease'
			for(Map<ABSLineModel, List<ABSLineItemModel>> mp : abs.absLines.values()){
				for(ABSLineModel lw : mp.keySet()){
					lw.MHeading = 'Lease';
				}
			}
			
			
			abs.save();
			Test.stopTest();

			System.assertEquals('Lease', [SELECT Major_Heading__c FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_Abs__c =: absTest.id][0].Major_Heading__c);
			}
	}

	@isTest
	static void updateLines_ShouldDoNothingIfItFaceSameOrderNumbersOnItems(){
		System.runAs(u){
			Test.startTest();
			ABSEditController abs = new ABSEditController();
			
	
			System.assertEquals(null, [SELECT Subheading__c FROM Ws_Tab_Abs_Line_Item__c WHERE Ws_Tab_Abs_Line__c =: testLines[0].id][0].Subheading__c);
		
			//Change all lines: Major_Heading__c = 'Lease'
			for(Map<ABSLineModel, List<ABSLineItemModel>> mp : abs.absLines.values()){
				for(List<ABSLineItemModel> iws : mp.values()){
					for(ABSLineItemModel iw : iws){
						iw.OrderNumber = 1;
						}
					}
				}	
			
				
			
			abs.saveAndPreview();
			Test.stopTest();

			System.assertEquals(null, [SELECT Subheading__c FROM Ws_Tab_Abs_Line_Item__c WHERE Ws_Tab_Abs_Line__c =: testLines[0].id][0].Subheading__c);
			}
	}

	@isTest
	static void updateLines_ShouldDoNothingIfItFaceSameOrderNumbersOnLines(){
		System.runAs(u){
			Test.startTest();
			ABSEditController abs = new ABSEditController();
			
	
			System.assertEquals('Floor Plan', [SELECT Major_Heading__c FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_Abs__c =: absTest.id][0].Major_Heading__c);
			
			for(Map<ABSLineModel, List<ABSLineItemModel>> mp : abs.absLines.values()){
				for(ABSLineModel lw : mp.keySet()){
					lw.OrderNumber = 1;
				}
			}
			
			abs.save();
			Test.stopTest();

			System.assertEquals('Floor Plan', [SELECT Major_Heading__c FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_Abs__c =: absTest.id][0].Major_Heading__c);
			}
	}

	@isTest
	static void deleteLines_ShouldCorrectlyUpdateAllOfItems(){
		System.runAs(u){
			Test.startTest();
			ABSEditController abs = new ABSEditController();
			
			System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_Abs__c =: absTest.id]);

			for(Map<ABSLineModel, List<ABSLineItemModel>> mp : abs.absLines.values()){
				for(ABSLineModel lw : mp.keySet()){
					lw.IsDeleted = true;
				}
			}

		
			
			abs.save();
			Test.stopTest();
			}
		System.assertEquals(0, [SELECT Count() FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_Abs__c =: absTest.id]);
		}
	

	@isTest
	static void addLines_ShouldAddLineIfMajorHeadingIsSelected(){
		System.runAs(u){
			Test.startTest();
			ABSEditController abs = new ABSEditController();
			
			System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_Abs__c =: absTest.id]);

			abs.newLine = new ABSLineModel();
			abs.newLine.MHeading = 'Retail';
			abs.newLine.AbsId = abs.abs.Implementation.id;
			abs.newLine.Name = 'Nissan 2010-A Retail';
			abs.add();

			abs.newLine = new ABSLineModel();
			abs.newLine.AbsId = abs.abs.Implementation.id;
			abs.newLine.Name = 'Nissan 2010-A Retail';
			abs.add();

			abs.save();
			Test.stopTest();

			System.assertEquals(11, [SELECT Count() FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_Abs__c =: absTest.id]);
			System.assertEquals('Nissan 2010-A Retail', [SELECT Name FROM Ws_Tab_Abs_Line__c WHERE Major_Heading__c = 'Retail'][0].Name);
			}
	}

	@isTest
	static void uploadDoc_ShouldReturnValidPageReference(){
		System.runAs(u){
			Test.startTest();
			ABSEditController abs = new ABSEditController();
			abs.lineId = 'none';
			System.assert(abs.uploadDoc().getUrl().contains('/apex/UploadABSDocument?id='));
			abs.lineId = testLines[4].id;

			System.assert(abs.uploadDoc().getUrl().contains(testLines[4].id));

			Test.stopTest();

			}
	}

	@isTest
	static void restorationProcessTest(){
		System.runAs(u){

			PageReference pageRef = Page.ABSPageEdit;
			Test.setCurrentPage(pageRef);
			
			ApexPages.currentPage().getParameters().put('restore', 'true');
			ApexPages.currentPage().getParameters().put('id', absHistoryPage.id);


			Test.startTest();

			ABSEditController abs = new ABSEditController();
			abs.save();


			System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Abs_Line__c WHERE Major_Heading__c= 'Lease' AND  Ws_Tab_Abs__c IN (SELECT Id FROM Ws_Tab_abs__c WHERE State__c = 'Sent For Review')]);

			Test.stopTest();
			}
	}

	
	private static void clearData(){
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


		absHistoryPage = new Ws_Tab_abs__c(Name='History Abs',
											  Investor_Relations_Website__c = ws.id,
											  RecordtypeId = absTestRecordTypeId,
											  State__c = 'Rejected');

		insert absHistoryPage;

		testLines = new List<Ws_Tab_Abs_Line__c>();
		historyLines = new List<Ws_Tab_Abs_Line__c>();
		testItems = new List<Ws_Tab_Abs_Line_Item__c>();
		historyItems = new List<Ws_Tab_Abs_Line_Item__c>();

		for(Integer i = 0; i < 10; i++){
			Ws_Tab_Abs_Line__c testTmp = new Ws_Tab_Abs_Line__c(Major_Heading__c = 'Floor Plan', Ws_Tab_Abs__c = absTest.id, Order_Number__c = i);
			testLines.add(testTmp);

			Ws_Tab_Abs_Line__c prodTmp = new Ws_Tab_Abs_Line__c(Major_Heading__c = 'Lease', Ws_Tab_Abs__c = absHistoryPage.id, Order_Number__c = i);
			historyLines.add(prodTmp);
		}
		
		insert testLines;
		insert historyLines;

		for(Integer i = 0; i < 10; i++){
			Ws_Tab_Abs_Line_Item__c testTmp = new Ws_Tab_Abs_Line_Item__c(Ws_Tab_Abs_Line__c = testLines[0].id, Order_Number__c = i);
			testItems.add(testTmp);

			Ws_Tab_Abs_Line_Item__c prodTmp = new Ws_Tab_Abs_Line_Item__c(Ws_Tab_Abs_Line__c = historyLines[0].id, Order_Number__c = i);
			historyItems.add(prodTmp);
		}

		insert testItems;
		insert historyItems;

		if(reviewerEmail == null){
			reviewerEmail = new Reviewer_Email__c(Email__c = 'test1222@test.com');
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