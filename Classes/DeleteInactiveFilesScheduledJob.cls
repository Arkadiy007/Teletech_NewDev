/**********************************************************************
Name: DeleteInactiveFilesScheduledJob
Copyright � notice: NMAC.
======================================================
Purpose:
This is scheduled job to schedule batch jobs, that delete
Inactive documents and images to free some storage space
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/22/2015 Created 
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev 
***********************************************************************/
global with sharing class DeleteInactiveFilesScheduledJob implements Schedulable {
	  global void execute(SchedulableContext SC) {
    	Database.executeBatch(new DeleteInactiveFilesBatchController(), 50);
    	Database.executeBatch(new DeleteInactiveImagesBatchController(), 50);
  	}
}