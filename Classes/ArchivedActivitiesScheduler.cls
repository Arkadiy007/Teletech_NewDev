/**********************************************************************
Name: ArchivedActivitiesScheduler
Copyright © notice: Nissan Motor Company.
======================================================
Purpose
Schedule job, for records migration into Heroku application using callouts
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Vlad Martynenko 01/08/2015 Created
***********************************************************************/
public class ArchivedActivitiesScheduler implements Schedulable { 

	// Main job settings
	public static Heroku_Sync_Job__c JobSetting {
		get{
			if(JobSetting == null){
				JobSetting = [Select Id, Is_Running__c, Job_ID__c, Retry_Inteval__c, Next_Schedule_Time__c, Days_Between_Sync__c FROM Heroku_Sync_Job__c];
			}
			
			return JobSetting;
		}
		set;
	}

	public ArchivedActivitiesScheduler() {
	}

	public void execute(SchedulableContext sc) {
		final String jobId = String.valueOf(sc.getTriggerid());
		abortJob(jobId);

		Archived_Activities_schedule__c schedule = GetScheduleForSync();

		// If we do have objects schedules that must be migrated to Heroku then proceed.
		// Otherwise reschedule self to run after 30 days.
		if(schedule != null) {
			// If migration is not being performed, make a callout to migrate data.
			// Otherwise reschedule self to try again in one minute.
			if(!JobSetting.Is_Running__c) {
				JobSetting.Is_Running__c = true;
				update JobSetting;
				DateTime retryTime = DateTime.now().addSeconds(Integer.valueof(JobSetting.Retry_Inteval__c));
				scheduleNewJob(retryTime);
				callout(schedule.Id);
			}
			else {
				DateTime retryTime = DateTime.now().addSeconds(Integer.valueof(JobSetting.Retry_Inteval__c));
				scheduleNewJob(retryTime);
			}
		}
		else {
			DateTime retryTime = JobSetting.Next_Schedule_Time__c.addDays(Integer.valueof(JobSetting.Days_Between_Sync__c));
			JobSetting.Job_ID__c = '';
			JobSetting.Next_Schedule_Time__c = retryTime;
			update JobSetting;
			scheduleNewJob(retryTime);
		}
	}

	// Future method that performs data migration to Heroku
	// Data that was successfully moved is going to be deleted.
	// This method is fully independent from type of object being moved, it manipulates data using settings variables and general sObject type.
	@future(callout = true)
	public static void callout(Id scheduleId) {
		// Get settings for object type, that we trying to migrate by settings id
		
		Archived_Activities_schedule__c[] schedule = [Select Id, Name, Where_Statement__c, Next_Schedule_Time__c 
													   FROM Archived_Activities_schedule__c WHERE Id=:scheduleId];
		
		String objType = schedule[0].Name; 

		Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
		Schema.SObjectType sobjType = gd.get(objType); 
		Schema.DescribeSObjectResult describeResult = sobjType.getDescribe(); 
		List<Schema.SObjectField> fields = describeResult.fields.getMap().values();

		// Generate query, based on settings and describe results, to select proper fields from records
		String query = BuildQuery(fields, objType, schedule[0].Where_Statement__c);
		
		List<sObject> objects = Database.query(query);
		
		// If we do have objects to move, perform serialization and Heroku callout, otherwise reschedule self, to run in 30 days
		if(objects.size() > 0){
			String csvResult = CSVHandler.getEncodedCsvByObjectType(fields, objects);
			
			Boolean herokuResult = HerokuApi.SaveRecords(csvResult, objType);

			// if Heroku call went well, remove migrated data from SF
			if(herokuResult){
				delete objects;
			}

			JobSetting.Job_ID__c = scheduleId;
		}
		else{
			DateTime retryTime = schedule[0].Next_Schedule_Time__c.addDays(Integer.valueof(JobSetting.Days_Between_Sync__c));
			schedule[0].Next_Schedule_Time__c = retryTime;
			update schedule;
		}

		// Update maing settings to inform schedule job, that we done with data migration and we can proceed
		JobSetting.Is_Running__c = false;
		update JobSetting;
	}

	// Schedules new job, on passed date time.
	public static Id scheduleNewJob(DateTime nextSchedule) {
		return System.schedule('Sync archived activities with Heroku',
		                       nextSchedule.format('ss mm HH dd MM ? yyyy'),
		                       new ArchivedActivitiesScheduler());
	}

	// Helper for schedule job aborting.
	public static void abortJob(Id jobId) {
	  try {
	    System.abortJob(jobId);
	  } catch(Exception ex) {
	    // ignore any exceptions - the job was most likely deleted manually
	  }
	}

	// Helper for schedule job, to determine, which object type should be migrated next.
	// Returns null if there is nothing to migrate.
	private static Archived_Activities_schedule__c GetScheduleForSync(){
		Archived_Activities_schedule__c[] schedules = [Select Id, Name, Where_Statement__c, Next_Schedule_Time__c FROM Archived_Activities_schedule__c];

		// If we do have object, that is being migrated now, then try to proceed with same settings
		if(JobSetting.Job_ID__c != ''){
			Map<Id, Archived_Activities_schedule__c> schedulesMap = new Map<Id, Archived_Activities_schedule__c>(schedules);
			Archived_Activities_schedule__c schedule = schedulesMap.get(JobSetting.Job_ID__c);

			// If all records of the current object type were not moved, proceed with same settings.
			if(schedule != null && schedule.Next_Schedule_Time__c.date() == JobSetting.Next_Schedule_Time__c.date()){
				return schedule;
			}
		}
		
		// Try to find any object type that can be migrated to Heroku
		for(Archived_Activities_schedule__c schedule:schedules){
			if(schedule.Next_Schedule_Time__c.date() == JobSetting.Next_Schedule_Time__c.date()){
				return schedule;
			}
		}

		return null;
	}

	// Helper that builds SOQL query, based on described fields, object type and where clause.
	private static String BuildQuery(List<Schema.SObjectField> fields, String objType, String whereClause){
		String request ='';

		for(Schema.SObjectField field : fields){
		 String name = field.getDescribe().getName();
		 if(request != '') {
			request += ',';
		 }
		 request += name;
		}

		return String.Format('SELECT {0} FROM {1} {2}', new List<String>{request, objType, whereClause});
	}
}