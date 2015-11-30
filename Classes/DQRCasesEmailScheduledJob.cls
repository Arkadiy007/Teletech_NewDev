global class DQRCasesEmailScheduledJob implements Schedulable, Database.Batchable<SObject>  {
    
	private static DQR_Configuration__c config {
    get {
      if (null == config) {
        config = getConfigurationSettings();
      }

      return config;
    }
    
    set;
  }

	private final static String SCHEDULE_JOB_NAME = (Test.isRunningTest() ? 'TEST ' : '') + 'DQR Cases Email Sender';
	private final static Integer BATCH_SIZE = 100;

    private static String query = 'SELECT Id, Case_Id__c, Email__c, Status__c FROM DQR_Stage_Object__c WHERE Status__c = \'New\'';


    /**
     * @description Executes the scheduled Apex job. 
     * @param sc contains the job ID
     */ 
    global void execute(SchedulableContext sc) {
		  Database.executeBatch(new DQRCasesEmailScheduledJob(), BATCH_SIZE);
		
		  rescheduleJob(String.valueOf(sc.getTriggerId()));
    }

	global Database.QueryLocator start(Database.BatchableContext context) {
		query += ' AND CreatedDate <= ' + System.now().addHours(5).addMinutes(- (Integer) config.Minutes_To_Reselect_New_Stage_Objects__c).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
		return Database.getQueryLocator(query);
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<DQR_Stage_Object__c> scope) {
		List<DQR_Stage_Object__c> duplicatesFreeScope = checkForDuplicates(scope);//new List<DQR_Stage_Object__c>();

		for (DQR_Stage_Object__c stageObject : duplicatesFreeScope){
			stageObject.Status__c = 'Completed';
		}

		
		update duplicatesFreeScope;
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
	
	}


	private void rescheduleJob(String jobId){
		System.abortJob(jobId);
		final DateTime d = DateTime.now().addMinutes((Integer)config.Minutes_To_Reschedule_Job__c);
		System.schedule(SCHEDULE_JOB_NAME, d.format('ss mm HH dd MM ? yyyy'), new DQRCasesEmailScheduledJob());
	}

	private static DQR_Configuration__c getConfigurationSettings(){
		DQR_Configuration__c configuration = DQR_Configuration__c.getOrgDefaults();
		
		if (configuration == null){
				configuration = new DQR_Configuration__c(
          Minutes_To_Reschedule_Job__c = 600, 
          Minutes_To_Reselect_New_Stage_Objects__c = 0
        );
				insert configuration;
				return DQR_Configuration__c.getOrgDefaults();
		}
		else{
			return configuration;
		}																								
	}

	private static List<DQR_Stage_Object__c> checkForDuplicates(List<DQR_Stage_Object__c> scope){
		Map<String, DQR_Stage_Object__c> dupFreeStageObjects = new Map<String, DQR_Stage_Object__c>();
		Set<DQR_Stage_Object__c> duplicatesStageObjects = new Set<DQR_Stage_Object__c>();

		//Any duplicates in scope?
		for(DQR_Stage_Object__c stageObject : scope){
			if(dupFreeStageObjects.containsKey(stageObject.Email__c)){
				stageObject.Status__c = 'Error';
				duplicatesStageObjects.add(stageObject);
			}
			else{
				dupFreeStageObjects.put(stageObject.Email__c, stageObject);
			}
		}

		//Any duplicates in mails sended last 24 hours?
		for(DQR_Stage_Object__c sendedStageObject : [SELECT Id, Email__c FROM DQR_Stage_Object__c WHERE Status__c = 'Completed' AND LastModifiedDate >= :Datetime.now().addHours(- (Integer) config.HoursToCheckEmailDuplicates__c) AND Email__c IN :dupFreeStageObjects.keySet()]){
			dupFreeStageObjects.get(sendedStageObject.Email__c).Status__c = 'Error';
			duplicatesStageObjects.add(dupFreeStageObjects.get(sendedStageObject.Email__c));
		}


		if(!duplicatesStageObjects.isEmpty()){
			update new List<DQR_Stage_Object__c>(duplicatesStageObjects);
		}

		return dupFreeStageObjects.values();
	}
}