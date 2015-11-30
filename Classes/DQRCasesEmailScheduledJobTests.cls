@isTest
public class DQRCasesEmailScheduledJobTests {
	private static Account testAcc {get; Set;}

	static{
		initializeData();
	}

	@isTest
	static void testJobWillCorrectlyProcessOneRecord(){
		DQR_Cases_Business_Rules__c bRules = new DQR_Cases_Business_Rules__c(Name='0001', BR_Name__c = 'EmailSent', Field_Value__c = 'Closed', Field_Api_Name__c = 'Status');
		insert bRules;
		insert createCase();

		System.assertEquals(1, [SELECT Count() FROM Case]);
		System.assertEquals(1, [SELECT Count() FROM DQR_Stage_Object__c]);
		
		Test.startTest();
			Database.executeBatch(new DQRCasesEmailScheduledJob(), 25);
        Test.stopTest();

		System.assertEquals(1, [SELECT Count() FROM DQR_Stage_Object__c WHERE Status__c = 'Completed']);
	}

	@isTest
	static void testJobWillCorrectlyProcessBulkRecords(){
		DQR_Cases_Business_Rules__c bRules = new DQR_Cases_Business_Rules__c(Name='0001', BR_Name__c = 'EmailSent', Field_Value__c = 'Closed', Field_Api_Name__c = 'Status');
		insert bRules;

		List<Case> casesToInsert = new List<Case>();
			
		for (Integer i = 0; i < 20; i++){
			casesToInsert.add(createCase());
		}
		
		insert casesToInsert;
		
		System.assertEquals(20, [SELECT Count() FROM Case]);
		System.assertEquals(20, [SELECT Count() FROM DQR_Stage_Object__c]);
		
		Test.startTest();
			Database.executeBatch(new DQRCasesEmailScheduledJob(), 25);
        Test.stopTest();

		System.assertEquals(1, [SELECT Count() FROM DQR_Stage_Object__c WHERE Status__c = 'Completed']);
	}

	 @isTest
    static void ScheduledJob_TestSchedulingIsWorking(){
        Test.startTest();
            String CRON_EXP = '0 0 0 15 3 ? 2022';
            String jobId = System.schedule('Test ZTY DQR Cases Email', CRON_EXP, new DQRCasesEmailScheduledJob());

            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
            System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
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
		DQR_Configuration__c configuration = new DQR_Configuration__c(Minutes_To_Reschedule_Job__c = 1600, Minutes_To_Reselect_New_Stage_Objects__c = 0);
		insert configuration;

		testAcc = new Account(FirstName = 'TestF2irstName',
                                      LastName = 'TestLas2tName',
                                      Preferred_Dealer_Code__c = '987356321',
									  Do_Not_Contact_Indicator__c = false,
                                      RecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Maritz'),
                                      Internet_Certified__c = true);
        insert testAcc;

	}
}