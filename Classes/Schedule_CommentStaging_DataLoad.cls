/**********************************************************************
Name: Schedule_CommentStaging_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules Staging Dataload jobs to run.
Run at 7:30pm MT:
System.schedule('Staging DataLoad - Comment', '0 30 19 * * ?', new Schedule_CommentStaging_DataLoad());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry      03/20/2012 Created
***********************************************************************/
global class Schedule_CommentStaging_DataLoad implements Schedulable {
    global void execute(SchedulableContext SC) {

        /* OUTBOUND */
        // ZCA1 CaseCommentStage
        Batch_CaseCommentStaging_DataLoad caseCommentStageDataLoad = new Batch_CaseCommentStaging_DataLoad();
        Database.executeBatch(caseCommentStageDataLoad);
    }
}