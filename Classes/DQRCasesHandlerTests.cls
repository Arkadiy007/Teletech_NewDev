@isTest
public class DQRCasesHandlerTests {
	
	private static Account testAcc {get; Set;}

	static{
		initializeData();
	}

	@isTest
	static void testDQRCasesHandler_WillInsertStageObjectIfEmailAvailable(){
		System.assertEquals(0, [SELECT Count() FROM DQR_Cases_Business_Rules__c]);

		Test.startTest();
			insert createCase();
        Test.stopTest();

		System.assertEquals(1, [SELECT Count() FROM Case]);
		System.assertEquals(1, [SELECT Count() FROM DQR_Stage_Object__c]);
		System.assertEquals('Open', [SELECT Status FROM Case LIMIT 1][0].Status);
	}
	
	@isTest
	static void testDQRCasesHandler_WillInsertStageObjectIfEmailAvailable_BULK(){
		System.assertEquals(0, [SELECT Count() FROM DQR_Cases_Business_Rules__c]);

		Test.startTest();

			List<Case> casesToInsert = new List<Case>();
			
			for (Integer i = 0; i < 200; i++){
				casesToInsert.add(createCase());
			}
			insert casesToInsert;
        Test.stopTest();

		System.assertEquals(200, [SELECT Count() FROM Case]);
		System.assertEquals(200, [SELECT Count() FROM DQR_Stage_Object__c]);
		System.assertEquals('Open', [SELECT Status FROM Case LIMIT 1][0].Status);
	}

	@isTest
	static void testDQRCasesHandler_WillCloseCase(){
		DQR_Cases_Business_Rules__c bRules = new DQR_Cases_Business_Rules__c(Name='0001', BR_Name__c = 'NoPhoneNoEmail', Field_Value__c = 'Closed', Field_Api_Name__c = 'Status');
		insert bRules;

		Test.startTest();
			Case cs =  createCase();
			cs.Alternate_Email__c = '';

			insert cs;
        Test.stopTest();

		System.assertEquals(1, [SELECT Count() FROM Case]);
		System.assertEquals(0, [SELECT Count() FROM DQR_Stage_Object__c]);
		System.assertEquals('Closed', [SELECT Status FROM Case LIMIT 1][0].Status);
	}

	@isTest
	static void testDQRCasesHandler_WillCloseCase_WithPhone(){
		DQR_Cases_Business_Rules__c bRules = new DQR_Cases_Business_Rules__c(Name='0001', BR_Name__c = 'ControlGroup', Field_Value__c = 'Closed', Field_Api_Name__c = 'Status');
		insert bRules;
		
		Test.startTest();
			Case cs =  createCase();
			cs.Work_Phone__c = '1-800-5553535';

			insert cs;
        Test.stopTest();

		System.assertEquals(1, [SELECT Count() FROM Case]);
		System.assertEquals(0, [SELECT Count() FROM DQR_Stage_Object__c]);
		System.assertEquals('Open', [SELECT Status FROM Case LIMIT 1][0].Status);
	}
	
	@isTest
	static void testDQRCasesHandler_WillCloseCase_BULK(){
		DQR_Cases_Business_Rules__c bRules = new DQR_Cases_Business_Rules__c(Name='0001', BR_Name__c = 'NoPhoneNoEmail', Field_Value__c = 'Closed', Field_Api_Name__c = 'Status');
		insert bRules;
		
		Test.startTest();

			List<Case> casesToInsert = new List<Case>();
			
			for (Integer i = 0; i < 150; i++){
				Case cs =  createCase();
				cs.Alternate_Email__c = '';

				casesToInsert.add(cs);
			}
			insert casesToInsert;
        Test.stopTest();

		System.assertEquals(150, [SELECT Count() FROM Case]);
		System.assertEquals(0, [SELECT Count() FROM DQR_Stage_Object__c]);
		System.assertEquals('Closed', [SELECT Status FROM Case LIMIT 1][0].Status);
	}
	

	@isTest
	static void testDQRCasesHandler_WillCloseCase_WithPhoneBulk(){
		DQR_Cases_Business_Rules__c bRules = new DQR_Cases_Business_Rules__c(Name='0001', BR_Name__c = 'StandardDQRCase', Field_Value__c = 'Closed', Field_Api_Name__c = 'Status');
		insert bRules;

		DQR_Cases_Business_Rules__c bRules2 = new DQR_Cases_Business_Rules__c(Name='0002', BR_Name__c = 'Duplicate', Field_Value__c = 'Open', Field_Api_Name__c = 'Status');
		insert bRules2;
		
		Test.startTest();
			List<Case> casesToInsert = new List<Case>();
			
			for (Integer i = 0; i < 150; i++){
				
			Case cs =  createCase();
			cs.Work_Phone__c = '1-800-5553535';
			cs.Alternate_Email__c = '';
				casesToInsert.add(cs);
			}
			insert casesToInsert;


        Test.stopTest();

		System.assertEquals(150, [SELECT Count() FROM Case]);
		System.assertEquals(0, [SELECT Count() FROM DQR_Stage_Object__c]);
		System.assertEquals(149, [SELECT Count() FROM Case WHERE Status = 'Open']);
	}
	

	static Case createCase(){
        Case testCase = new Case(
                                 RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'Customer Connection Follow Up'),
                                 SuppliedEmail = 'test2@test.com',
                                 Alternate_Email__c = 'test2@test.com',
								 Status = 'Open',
                                 VIN__C = '12323',
                                 AccountId = testAcc.id,
                                 Mailing_Zip_Code__c = '22122',
                                 Considered_Vehicle_Make__c = 'Nissan',
                                 Considered_Vehicle_Model__c = 'Considered Vehicle Model',
                                 Lead_Provider__c = 'Lead Provider',
                                 Lead_Provider_Detail__c = 'Lead Provider Detail',
                                 Lead_Provider_Name__c = 'Lead Provider Name');

		return testCase;
	}


	static void initializeData(){
		
		DQR_Configuration__c configuration = new DQR_Configuration__c(Counter__c = 0, Control_Group_Cases_Number__c = 10);
		insert configuration;

		testAcc = new Account(FirstName = 'TestF2irstName',
                                      LastName = 'TestLas2tName',
									  Do_Not_Contact_Indicator__c = false,
                                      Preferred_Dealer_Code__c = '987356321',
                                      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'),
                                      Internet_Certified__c = true);
        insert testAcc;

	}
 }