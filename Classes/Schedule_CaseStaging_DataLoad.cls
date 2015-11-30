/**********************************************************************
Name: Schedule_CaseStaging_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules Staging Dataload jobs to run.
Run at 6pm MT:
System.schedule('Staging DataLoad - Case', '0 0 18 * * ?', new Schedule_CaseStaging_DataLoad());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Munawar Esmail 09/20/2011 Created
1.1 - Bryan Fry      10/28/2011 Changed to call multiple Batch jobs
1.2 - Bryan Fry      03/20/2012 Changed to Schedule_CaseStaging_DataLoad
***********************************************************************/
global class Schedule_CaseStaging_DataLoad implements Schedulable {
    global void execute(SchedulableContext SC) {

        /* OUTBOUND */
        // ZCA1 CaseStaging
        Batch_CaseStaging_DataLoad caseStageZCA1DataLoad = new Batch_CaseStaging_DataLoad();
        Database.executeBatch(caseStageZCA1DataLoad);
    }
}