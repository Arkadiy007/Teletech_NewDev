/**********************************************************************
Name: Schedule_Staging_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules Staging Dataload jobs to run.
Run at 9pm MT:
System.schedule('Staging DataLoad - Early', '0 0 21 * * ?', new Schedule_Staging_DataLoad());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Munawar Esmail 09/20/2011 Created
1.1 - Bryan Fry      10/28/2011 Changed to call multiple Batch jobs
1.2 - Bryan Fry      03/15/2012 Changed to Schedule_Staging_DataLoad_Mid
***********************************************************************/
global class Schedule_Staging_DataLoad implements Schedulable {
	global void execute(SchedulableContext SC) {
/*
		// CCG Cases
		Batch_CCG_Case_DataLoad ccgCaseDataLoad = new Batch_CCG_Case_DataLoad();
		Database.executeBatch(ccgCaseDataLoad);
		// SAP CheckRequests
		Batch_CheckRequest_DataLoad checkRequestDataLoad = new Batch_CheckRequest_DataLoad();
		Database.executeBatch(checkRequestDataLoad);

		// OUTBOUND
		// ZCA1 CaseStaging
		Batch_CaseStaging_DataLoad caseStageZCA1DataLoad = new Batch_CaseStaging_DataLoad();
		Database.executeBatch(caseStageZCA1DataLoad);
		// ZCA1 CheckRequestStage
		Batch_CheckRequestStaging_DataLoad checkRequestStageDataLoad = new Batch_CheckRequestStaging_DataLoad();
		Database.executeBatch(checkRequestStageDataLoad);
		// ZCA1 CaseCommentStage
		Batch_CaseCommentStaging_DataLoad caseCommentStageDataLoad = new Batch_CaseCommentStaging_DataLoad();
		Database.executeBatch(caseCommentStageDataLoad);
		// ZCA1 CaseCategoryStage
		Batch_CaseCategoryStaging_DataLoad caseCategoryStageDataLoad = new Batch_CaseCategoryStaging_DataLoad();
		Database.executeBatch(caseCategoryStageDataLoad);
		// Delete Old Cases
		Batch_DeleteOldCases_DataLoad deleteOldCasesDataLoad = new Batch_DeleteOldCases_DataLoad();
		Database.executeBatch(deleteOldCasesDataLoad);
*/
	}
}