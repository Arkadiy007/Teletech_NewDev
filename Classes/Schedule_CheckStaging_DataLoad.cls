/**********************************************************************
Name: Schedule_CheckStaging_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules Staging Dataload jobs to run.
Run at 7:15pm MT:
System.schedule('Staging DataLoad - Check', '0 15 19 * * ?', new Schedule_CheckStaging_DataLoad());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry      03/20/2012 Created
***********************************************************************/
global class Schedule_CheckStaging_DataLoad implements Schedulable {
    global void execute(SchedulableContext SC) {

        /* OUTBOUND */
        // ZCA1 CheckRequestStage
        Batch_CheckRequestStaging_DataLoad checkRequestStageDataLoad = new Batch_CheckRequestStaging_DataLoad();
        Database.executeBatch(checkRequestStageDataLoad);
    }
}