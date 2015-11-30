/**********************************************************************
Name: Task_After
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Update CallDisposition field of case with Call Result field of Task. 
Related Class : TaskClass
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Mohd Afraz Siddiqui 01/10/2011 Created
1.1 - Biswa Ray           01/12/2011 New Notes Creation Functionality added
1.2 - Mohd Afraz Siddiqui 01/13/2011 Incorporated Comments and Headers
1.3 - Munawar Esmail      09/06/2011 Commented out New Notes Creation Functionality
1.4 - Matt Starr          03/06/2014 Add code to fix due dates for VCS tasks that are < the createdDate
1.5 - Vladimir Martynenkpo 08/06/2015 Added Maritz Backfeet Object creation
***********************************************************************/
trigger Task_After on Task (after insert, after update) {
    Set<Case> toUpdateCaseSet = new Set<Case>();
    List<Case> toUpdateCaseList = new List<Case>();
	List<task> tasksToUpdate = new List<Task>();
    Case caseRec = null;
    Account acc;
    Case cas;
    /*
        For all tasks update cases if its CallDisposition is changed. 
    */
	Database.DMLOptions dmlOptions = new Database.DMLOptions(); 
    for(Integer i = 0; i < Trigger.new.size(); i++) {
        caseRec = TaskClass.updateCase(Trigger.new[i]);
        if (caseRec != null) {
		if(Trigger.isUpdate){
			Task old = Trigger.oldMap.get(Trigger.new[i].ID);
			if(Trigger.isUpdate && old.OwnerId != Trigger.new[i].OwnerId && Trigger.new[i].Subject.contains('DTS Request')){
				caseRec.Task_Field_Inspection_Owner__c = Trigger.new[i].OwnerId;
				
                dmlOptions.EmailHeader.TriggerUserEmail = TRUE; 
				Trigger.new[i].setOptions(dmlOptions);
                tasksToUpdate.add(Trigger.new[i]);
			
                    
                caseRec.DTS_Notification__c = true;
                caseRec.Field_Inspection_Indicator__c = true;
			}
            toUpdateCaseSet.add(caseRec);
        }
		}
    }
   
    /*
        Update all the cases.
    */
    try {
        if(toUpdateCaseSet.size() > 0) {
            toUpdateCaseList.addAll(toUpdateCaseSet);
            update toUpdateCaseList;
        } 
    }
    catch (DMLException e){
        for(Case c : toUpdateCaseList) {
            c.addError(system.label.Exception_occured_while_inserting_Task + e.getMessage());   
        }
    }
    
    /* 
         Creation of New Notes Functionality.
     
    Note note;
    List<Note> noteList = new List<Note>();
    
        Iterate over the list of records being processed in the trigger and
        insert notes respectively       
          for (Integer i = 0; i < Trigger.new.size(); i++) {
            if (Trigger.isUpdate) {
                note = TaskClass.createNote(Trigger.old[i], Trigger.new[i]);
            }
            else if (Trigger.isInsert){
                note = TaskClass.createNote(null, Trigger.new[i]);
            }
            if (note!= null){           
               noteList.add(note); 
            }
        }
   

     
    
    try {
         if (noteList.size() > 0) {
          insert noteList;
        }
    }
    catch (DMLException e) {
        for (Note noteRec : noteList) {
            noteRec.addError(system.label.Exception_occured_while_inserting_new_notes + e.getMessage());
        }
    }
       */
 //1.6 Vladimir Martynenko: Maritz Backfeet Stage Object Creation;
    if(Trigger.isInsert){
        if(Maritz_Backfeed_Trigger_Enabled__c.getInstance() != null){
            if(Maritz_Backfeed_Trigger_Enabled__c.getInstance().EnabledForTask__c){
                Maritz_Backfeed_TaskTriggerHelper helper = new Maritz_Backfeed_TaskTriggerHelper(Trigger.NEW);
            }
        }
    }
/***1.4 Modify the due date for VCS tasks that have a due date prior to the 
    created date due to time zones.***/
    
    for(Task t : trigger.new){

    List<Task> tasks4update = new List<Task>();
    if(Trigger.isInsert == true && t.createdDate > t.ActivityDate 
        && t.IsRecurrence == false && t.RecordtypeId == '012F0000000yFlr'){
    
    Task t2 = New Task(Id = t.Id);
    Datetime duedate = t.createdDate.addDays(1);
     
      if (duedate.format('EEEE') != 'Saturday' && 
            duedate.format('EEEE') != 'Sunday') {
            
    t2.ActivityDate = date.valueOf(t.createdDate.addDays(1));
    tasks4update.add(t2);
        }
            if (duedate.format('EEEE') == 'Saturday'){
                t2.ActivityDate = date.valueOf(t.createdDate.addDays(3));
                tasks4update.add(t2); 
                
            } 
            
            if (duedate.format('EEEE') == 'Sunday'){
                t2.ActivityDate = date.valueOf(t.createdDate.addDays(2));
                tasks4update.add(t2); 
                
            }
        }       
    try{
    update tasks4update;
    }
    catch (Exception e) {
    Error_Log__c error = new Error_Log__c(Error_Message__c = e.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'After_Task_DueDateFix', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error');
                                    }
    
    }
	try{
		Database.update(tasksToUpdate, dmlOptions);
	}
	catch (Exception e){
		Error_Log__c error = new Error_Log__c(Error_Message__c = e.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'After_Task_SendNotification', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error');
                                    
	}


}