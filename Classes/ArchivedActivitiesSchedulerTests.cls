/**********************************************************************
Name: ArchivedActivitiesSchedulerTests
Copyright © notice: Nissan Motor Company.
======================================================
Purpose
Tests class for ArchivedActivitiesScheduler
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Vlad Martynenko 01/08/2015 Created
***********************************************************************/
@isTest
public class ArchivedActivitiesSchedulerTests {
	 
	 static testMethod void testRunningScheduledJobWhenOldJobIsRunning() {
		Heroku_Sync_Job__c sync = createJobSetting(true,'', DateTime.now());

		Test.startTest();
		final Id jobId = ArchivedActivitiesScheduler.scheduleNewJob(DateTime.now().addminutes(2));

		// Verify the job has not run
		System.assertEquals(0, [SELECT TimesTriggered FROM CronTrigger WHERE id = :jobId].TimesTriggered);
		Test.stopTest();
	}

	static testMethod void testJobShouldMigrateDataToHerokuAndDeleteItFromSF() {
		Test.startTest();
		Task t = new Task(Subject = 'Archived');
		insert t;

		Heroku_Sync_Job__c sync = createJobSetting(false,'', DateTime.now().adddays(1));
		Archived_Activities_schedule__c schedule = createArchivedActivitiesSchedule('WHERE Subject=\'Archived\' LIMIT 10', DateTime.now().adddays(1));
		
		createHerokuSettings();

		Test.setMock(HttpCalloutMock.class, new HerokuAppSaveCalloutMockImpl());

		ArchivedActivitiesScheduler.callout(schedule.Id);
		Test.stopTest();
		List<Task> selectedTasks = [Select Id FROM Task where Id=:t.Id];

		System.assertEquals(0, selectedTasks.size());
		
	}

	static testMethod void testJobShouldUpdateSettingsWhenThereIsNoRecordsForMigration() {
		Test.startTest();
		Heroku_Sync_Job__c sync = createJobSetting(false,'', DateTime.now().adddays(1));
		Archived_Activities_schedule__c schedule = createArchivedActivitiesSchedule('WHERE Subject=\'Archived\' LIMIT 10', DateTime.now().adddays(1));
		
		createHerokuSettings();

		Test.setMock(HttpCalloutMock.class, new HerokuAppSaveCalloutMockImpl());

		ArchivedActivitiesScheduler.callout(schedule.Id);
		Test.stopTest();

		Archived_Activities_schedule__c updatedSchedule = [Select Id,Next_Schedule_Time__c from Archived_Activities_schedule__c WHERE Id=:schedule.Id];

		System.assertEquals(schedule.Next_Schedule_Time__c.adddays(Integer.valueof(sync.Days_Between_Sync__c)), updatedSchedule.Next_Schedule_Time__c);		
	}

	 private static Heroku_Sync_Job__c createJobSetting(Boolean isRunning, String jobId, DateTime nextSchedule){
		Heroku_Sync_Job__c settings = new Heroku_Sync_Job__c(
		Is_Running__c = isRunning,
		Job_ID__c = jobId,
		Retry_Inteval__c = 60,
		Next_Schedule_Time__c = nextSchedule,
		Days_Between_Sync__c = 30);

		insert settings;
		return settings;
	 }

	 private static Archived_Activities_schedule__c createArchivedActivitiesSchedule(String whereStatement, DateTime nextScheduleTime) {
		Archived_Activities_schedule__c setting = new Archived_Activities_schedule__c( 
		  Name = 'Task', 
		  Where_Statement__c = whereStatement, 
		  Next_Schedule_Time__c = nextScheduleTime);

		insert setting;
		return setting;
	}

	private static Heroku_Credentials__c createHerokuSettings() {
		Heroku_Credentials__c setting = new Heroku_Credentials__c(
		Name = 'Save',
		Api_Link__c = 'link',
		Access_Key__c = 'key');
		
		insert setting;
		return setting;
	}

	public class HerokuAppSaveCalloutMockImpl implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			Heroku_Credentials__c saveSetting = [SELECT Name, Api_Link__c, Access_Key__c FROM Heroku_Credentials__c WHERE Name='Save'];

			HttpResponse res = new HttpResponse();

			System.assertEquals('POST', req.getMethod());
		
			res.setBody('');
			res.setStatusCode(200);
			res.setStatus('OK');

			return res;
		}
	}
}