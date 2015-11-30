/**********************************************************************
Name: DeleteInactiveFilesScheduledJobTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is test class for DeleteInactiveFilesScheduledJob.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/22/2015 Created 
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev 
***********************************************************************/
@isTest
private class DeleteInactiveFilesScheduledJobTests
{
	public static User u {get; set;}

	static{
		populateTestData();
	}
	
	@isTest
	static void testScheduleJobWorkingCorrectly(){
		System.runAs(u){
			

			Test.startTest();
				String CRON_EXP = '0 0 0 15 3 ? 2022';

				String jobId = System.schedule('TEST TEST Delete inactive documents', CRON_EXP, new DeleteInactiveFilesScheduledJob());

				 CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

         		System.assertEquals(CRON_EXP, ct.CronExpression);
     			System.assertEquals(0, ct.TimesTriggered);
      			System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
			Test.stopTest();
		}
	}
	
	@isTest
	static void testBatchJobWorkingCorrectlyForFiles(){
		System.runAs(u){
			
			System.assertEquals(4, [SELECT Count() FROM Document_Proxy__c]);
			System.assertEquals(2, [SELECT Count() FROM Image_Proxy__c]);
				Test.startTest();
					DeleteInactiveImagesBatchController batch = new DeleteInactiveImagesBatchController();
					Database.executeBatch(batch);	

					DeleteInactiveFilesBatchController fileBatch = new DeleteInactiveFilesBatchController();
					Database.executeBatch(fileBatch);	
				Test.stopTest();
			System.assertEquals(3, [SELECT Count() FROM Document_Proxy__c]);
			System.assertEquals(1, [SELECT Count() FROM Image_Proxy__c]);
		}
	}
	


	private static void populateTestData(){
		Helper.insertRecords();

		Document_Proxy__c dp1 = new Document_Proxy__c(Name = 'Test', Link__c='?id=01r000PCJ'); 
		Document_Proxy__c dp2 = new Document_Proxy__c(Name= 'Test2', Link__C='t?id=01TEST00PCJ');

		Image_Proxy__c prox1 = new Image_Proxy__c(Name='Test', Link__c = '/servlet/ImageServerTest?id=TEST&oid=');
		Image_Proxy__c prox2 = new Image_Proxy__c(Name='Test2', Link__c = '/servlet/ImageServerTest?id=01rW00000UCJ&oid=');

		insert dp1;
		insert dp2;
		insert prox1;
		insert prox2;

		Ws_Tab_Quarterly_Data_Item__c qdItem = new Ws_Tab_Quarterly_Data_Item__c(Order_Number__c = 1, Document__c=dp2.id, Ws_Tab_Quarterly_Data__c = [SELECT Id FROM Ws_Tab_Quarterly_Data__c LIMIT 1][0].id);
		insert qdItem;

		Ws_Tab_Presentation_Item__c pItem = new Ws_Tab_Presentation_Item__c(Order_Number__c = 1, Presentation_Image__c = prox1.id, Ws_Tab_Presentation__c = [SELECT Id FROM Ws_Tab_Presentations__c LIMIT 1][0].id);
		insert pItem;

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