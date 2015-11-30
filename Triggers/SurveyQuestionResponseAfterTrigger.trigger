/**********************************************************************
  Name: SurveyQuestionResponseAfterTrigger
  Copyright � notice: Nissan Motor Company.
  ======================================================
  Purpose:
  Trigger on SurveyQuestionResponse__c, for creation which is used for SurveysAfterTriggerHelper to populate new SurveyResponse records, every time SurveyQuestionResponse__c is inserted.
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko	03/10/2015 Created
 ***********************************************************************/
trigger SurveyQuestionResponseAfterTrigger on SurveyQuestionResponse__c (after insert)  { 
	new SurveysAfterTriggerHelper(Trigger.New);
}