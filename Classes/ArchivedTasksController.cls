/**********************************************************************
Name: ArchivedTasksController
Copyright © notice: Nissan Motor Company.
======================================================
Purpose
Controller for ArchivedTasks page
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Vlad Martynenko 01/08/2015 Created
***********************************************************************/
public class ArchivedTasksController { 
	public String AccountId {get;set;}
	public List<Task> Tasks {get;set;}

	Public Boolean IsTask {get;set;}
	public Account Acc {get;set;}

	public ArchivedTasksController() {
		AccountId = Apexpages.currentPage().getParameters().get('sId');
		IsTask = true;

		Acc = [Select Id, Name From Account Where Id=:AccountId].get(0);

		Archived_Activities_schedule__c[] schedule = [Select Id, Name, Where_Statement__c, Next_Schedule_Time__c , Records_Per_Page__c
													   FROM Archived_Activities_schedule__c WHERE Name='Task'];
		Integer recordsPerPage = Integer.valueof(schedule.get(0).Records_Per_Page__c);

		GetArchivedTasks(0, recordsPerPage);
	}

	// Displays list of tasks on the page, using Heroku api and csv parser
	private void GetArchivedTasks(Integer offset, Integer lim) {
		Map<String,String> params = new Map<String,String>();
		params.put('offset', String.valueof(offset));
		params.put('limit', String.valueof(lim));
		params.put('account_id', Acc.Id);
		params.put('table_name', 'Task');

		String herokuResponse = HerokuApi.GetRecords(params);
		tasks = CSVHandler.getDecodedObjectsFromCsv(herokuResponse, 'Task');
	}
}