/**********************************************************************
  Name: SurveysAfterTriggerHelper
  Copyright © notice: Nissan Motor Company.
  ======================================================
  Purpose:
  This trigger helper created to populate SurveyResponses records for each of new Live Agent survey coming into system.
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 03/05/2015 Created
  1.1 - Arkadiy Sychev 03/25/2015 Add static method for filling CaseID__c and PostChat_Agent__c fields from LiveAgent_PostChat controller. 
  It is needed when Agent closes chat tab in Console befor User fills Survey.
  1.2 - Vlad Martynenko 4/8/2015 - Added case fields to the object.
  1.3 - Vlad Martynenko 4/21/2015 - Added chat fields to the object.
  1.4 - Vlad Martynenko 8/11/2015 - Added logic for Epsilon Integration for Surveys
 ***********************************************************************/
public class SurveysAfterTriggerHelper {
	// Set of ids, for newly created 'LiveAgent' Surveys__c or SurveyTaker__c records.
	Set<Id> surveysIds = new Set<Id> ();

	// New Surveys__c records passed from trigger
	List <Surveys__c > liveagentsurveys;

	// New SurveyQuestionResponse__c records passed from trigger
	List <SurveyQuestionResponse__c > surveyQuestionsResponses;
	// New SurveyTaker__c records filled with SurveyQuestionResponse__c
	List <SurveyTaker__c > surveyTakers;
	// Maps used to access records that are related to newly passed surveys
	Map <Id, Survey__c > surveysMap = new Map <Id, Survey__c > ();
	Map <Id, List <SurveyQuestionResponse__c > > surveyQuestionsResponsesMap = new Map <Id, List <SurveyQuestionResponse__c > > ();
	Map <Id, LiveChatTranscript > transcriptsMap = new Map <Id, LiveChatTranscript > ();
	Map <Id, Case > surveysCasesMap = new Map <Id, Case > ();

	// New records that will be inserted by this helper
	List <Error_Log__c > errors = new List <Error_Log__c > ();
	List <Stage_FF_SFDC_SurveyResponse__c > surveyResponses = new List <Stage_FF_SFDC_SurveyResponse__c > ();

	// Constructor that is used by Surveys_After trigger
	public SurveysAfterTriggerHelper(List <Surveys__c > surveys) {
		liveagentsurveys = surveys;
		for (Surveys__c s : liveagentsurveys) {
			surveysIds.add(s.Id);
		}

		SelectSurveysTranscripts();
		HandleSurveysResponses();
	}

	// Constructor that is used by SurveyQuestionResponseAfterTrigger trigger
	public SurveysAfterTriggerHelper(List <SurveyQuestionResponse__c > surveyQuestionResponses) {

		surveyQuestionsResponses = surveyQuestionResponses;

		for (SurveyQuestionResponse__c qresp : surveyQuestionsResponses) {
			if (!surveysIds.contains(qresp.SurveyTaker__c)) {
				surveysIds.add(qresp.SurveyTaker__c);
			}

			if (surveyQuestionsResponsesMap.containsKey(qresp.SurveyTaker__c)) {
				surveyQuestionsResponsesMap.get(qresp.SurveyTaker__c).add(qresp);
			}
			else {
				List <SurveyQuestionResponse__c > takerQuestions = new List <SurveyQuestionResponse__c > ();
				takerQuestions.add(qresp);
				surveyQuestionsResponsesMap.put(qresp.SurveyTaker__c, takerQuestions);
			}
		}

		surveyTakers = [Select Id, Survey__c, CreatedDate, SurveyTaker__c.Case__r.Owner.Name FROM SurveyTaker__c WHERE Id IN :surveysIds];

		Set<Id> survIds = new Set<Id> ();

		for (SurveyTaker__c s : surveyTakers) {
			surveysIds.add(s.Id);

			if (!survIds.contains(s.Survey__c)) {
				survIds.add(s.Survey__c);
			}
		}

		SelectSurveyMap(survIds);
		HandleSurveysResponses();
	}
	

	
	// Selects Survey__c records that are related to SurveyTaker__c records
	private void SelectSurveyMap(Set<Id> survIds) {
		Map <ID, Survey__c > surveys = new Map <ID, Survey__c > ([Select Id, Name FROM Survey__c WHERE Id IN :survIds]);

		Set<Id> casesIds = new Set<Id> ();

		for (SurveyTaker__c s : surveyTakers) {
			if (surveys.containsKey(s.Survey__c) &&
			    !surveysMap.containsKey(s.Survey__c)) {
				surveysMap.put(s.Id, surveys.get(s.Survey__c));

				if (s.Case__c != null) {
					casesIds.add(s.Case__c);
				}
			}
		}

		surveysCasesMap = new Map <ID, Case > ([Select Id,
		                                       Contact_ID__c,
		                                       OwnerId,
		                                       ClosedDate,
		                                       CreatedDate,
		                                       DealerCode__c,
		                                       Model1__c,
		                                       Model_Year__c,
		                                       VIN__c,
		                                       Model_of_Interest_1st__c,
		                                       Survey_NPS_Score_1__c,
		                                       Survey_NPS_Score_2__c,
		                                       Alert_Trigger_Verbatim__c,
		                                       Lead_Date__c,
		                                       Owner.Name,
		                                       Case_Type__c,
		                                       Description,
		                                       Subject,
		                                       NNA_Net_Hot_Alert_Type__c,
		                                       Survey_ID__c,
		                                       CaseNumber FROM Case WHERE Id IN :casesIds]);
	}

	// Selects LiveChatTranscript records that are related to Surveys__c records
	private void SelectSurveysTranscripts() {
		List <LiveChatTranscript > transcripts = [Select Id, Survey__c, OwnerId, CaseId, Body, RequestTime, Survey__r.Name, Name FROM LiveChatTranscript WHERE Survey__c IN :surveysIds];

		Set<Id> casesIds = new Set<Id> ();

		for (LiveChatTranscript trans : transcripts) {
			transcriptsMap.put(trans.Survey__c, trans);
			if (trans.CaseId != null) {
				casesIds.add(trans.CaseId);
			}
		}

		surveysCasesMap = new Map <ID, Case > ([Select Id,
		                                       Contact_ID__c,
		                                       OwnerId,
		                                       ClosedDate,
		                                       CreatedDate,
		                                       DealerCode__c,
		                                       Model1__c,
		                                       Model_Year__c,
		                                       VIN__c,
		                                       Model_of_Interest_1st__c,
		                                       Survey_NPS_Score_1__c,
		                                       Survey_NPS_Score_2__c,
		                                       Alert_Trigger_Verbatim__c,
		                                       Lead_Date__c,
		                                       Owner.Name,
		                                       Case_Type__c,
		                                       Description,
		                                       Subject,
		                                       NNA_Net_Hot_Alert_Type__c,
		                                       Survey_ID__c,
		                                       CaseNumber FROM Case WHERE Id IN :casesIds]);
	}

	// Populates new Stage_FF_SFDC_SurveyResponse__c with values from selected and passed to helper data and performing insert.
	private void HandleSurveysResponses() {
		PopulateSurveyResponsesData();
		InsertSurveyResponsesData();
	}

	// Fills new Stage_FF_SFDC_SurveyResponse__c records with data from survey records and records that are releated to survey
	private void PopulateSurveyResponsesData() {
		if (liveagentsurveys != null) {
			for (Surveys__c surv : liveagentsurveys) {
				Stage_FF_SFDC_SurveyResponse__c surveyResponse = new Stage_FF_SFDC_SurveyResponse__c();
				surveyResponse.Survey_Name__c = 'Live chat';
				surveyResponse.SurveyID__c = surv.Id;
				surveyResponse.PostChat_Brand__c = '';
				surveyResponse.Survey_ResponseDate__c = Date.valueOf(surv.CreatedDate);
				surveyResponse.Batch_Status__c = 'New';

				if (transcriptsMap.containsKey(surv.Id)) {
					LiveChatTranscript transcript = transcriptsMap.get(surv.Id);
					surveyResponse.PostChat_Agent__c = transcript.OwnerId;
					surveyResponse.CaseId__c = transcript.CaseId;
					surveyResponse.PostChat_Survey__c = transcript.Survey__r.Name;
					UpdateSurveyResponseWithParsedChatText(transcript, surveyResponse);
				}
				else {
					surveyResponse.PostChat_Agent__c = null;
					surveyResponse.CaseId__c = null;
				}

				if (surveyResponse.CaseId__c != null && surveysCasesMap.containsKey(surveyResponse.CaseId__c)) {
					Case relatedCase = surveysCasesMap.get(surveyResponse.CaseId__c);
					surveyResponse.Case_Owner_Name__c = relatedCase.Owner.Name;
					surveyResponse.Contact_ID__c = relatedCase.Contact_ID__c;
					surveyResponse.Date_Closed__c = relatedCase.ClosedDate;
					surveyResponse.Dealer_Code__c = relatedCase.DealerCode__c;
					surveyResponse.Model_of_Interest_1st__c = relatedCase.Model_of_Interest_1st__c;
					surveyResponse.Model_Year__c = relatedCase.Model_Year__c;
					surveyResponse.VIN__c = relatedCase.VIN__c;
					surveyResponse.Survey_NPS_Score_1__c = relatedCase.Survey_NPS_Score_1__c;
					surveyResponse.Survey_NPS_Score_2__c = relatedCase.Survey_NPS_Score_2__c;
					surveyResponse.Alert_Trigger_Verbatim__c = relatedCase.Alert_Trigger_Verbatim__c;
					surveyResponse.Lead_Date__c = relatedCase.Lead_Date__c;
					surveyResponse.Date_Opened__c = relatedCase.CreatedDate;
					surveyResponse.Case_Number__c = relatedCase.CaseNumber;
					surveyResponse.Case_Type__c = relatedCase.Case_Type__c;
					surveyResponse.Case_Description__c = relatedCase.Description;
					surveyResponse.Subject__c = relatedCase.Subject;
					surveyResponse.NNA_Net_Hot_Alert_Type__c = relatedCase.NNA_Net_Hot_Alert_Type__c;
					surveyResponse.Case_Survey_ID__c = relatedCase.Survey_ID__c;
				}

				surveyResponse.PostChat_ConcernSatisfiedComments__c = surv.Live_Agent_Concern_Comments__c;
				surveyResponse.PostChat_ConcernSatisfiedYesNo__c = surv.Live_Agent_Concern_Satisfied__c;
				surveyResponse.PostChat_ExpSatisfiedComments__c = surv.Live_Agent_Experience_Comments__c;
				surveyResponse.PostChat_ExpSatisfiedYesNo__c = surv.Live_Agent_Experience_Satisfied__c;
				surveyResponse.PostChat_RecommededComments__c = surv.Live_Agent_Recommended_Comments__c;
				surveyResponse.PostChat_RecommededNPS__c = surv.Live_Agent_Recommended__c;

				surveyResponses.add(surveyResponse);
			}
		}

		if (surveyTakers != null) {
			for (SurveyTaker__c surv : surveyTakers) {

				String surveyName = surveysMap.get(surv.Id).Name;

				Stage_FF_SFDC_SurveyResponse__c surveyResponse = new Stage_FF_SFDC_SurveyResponse__c();
				surveyResponse.Survey_Name__c = surveyName;
				surveyResponse.SurveyID__c = surv.Id;
				surveyResponse.PostChat_Agent__c = '';
				surveyResponse.PostChat_Brand__c = surveyName.Contains('Infiniti') ? 'Infiniti' : 'Nissan';
				surveyResponse.Survey_ResponseDate__c = Date.valueOf(surv.CreatedDate);
				surveyResponse.Batch_Status__c = 'New';
				surveyResponse.CaseId__c = surv.Case__c;
				if (surv.Case__c != null) {
					Case relatedCase = surveysCasesMap.get(surveyResponse.CaseId__c);
					surveyResponse.Case_Owner_Name__c = relatedCase.Owner.Name;
					surveyResponse.Contact_ID__c = relatedCase.Contact_ID__c;
					surveyResponse.Date_Closed__c = relatedCase.ClosedDate;
					surveyResponse.Dealer_Code__c = relatedCase.DealerCode__c;
					surveyResponse.Model_of_Interest_1st__c = relatedCase.Model_of_Interest_1st__c;
					surveyResponse.Model_Year__c = relatedCase.Model_Year__c;
					surveyResponse.VIN__c = relatedCase.VIN__c;
					surveyResponse.Survey_NPS_Score_1__c = relatedCase.Survey_NPS_Score_1__c;
					surveyResponse.Survey_NPS_Score_2__c = relatedCase.Survey_NPS_Score_2__c;
					surveyResponse.Alert_Trigger_Verbatim__c = relatedCase.Alert_Trigger_Verbatim__c;
					surveyResponse.Lead_Date__c = relatedCase.Lead_Date__c;
					surveyResponse.Date_Opened__c = relatedCase.CreatedDate;
					surveyResponse.Case_Number__c = relatedCase.CaseNumber;
					surveyResponse.Case_Type__c = relatedCase.Case_Type__c;
					surveyResponse.Case_Description__c = relatedCase.Description;
					surveyResponse.Subject__c = relatedCase.Subject;
					surveyResponse.NNA_Net_Hot_Alert_Type__c = relatedCase.NNA_Net_Hot_Alert_Type__c;
					surveyResponse.Case_Survey_ID__c = relatedCase.Survey_ID__c;
				}

				UpdateSurveyResponseFieldsAccordingToSurveyTaken(surveyName, surveyResponse, surveyQuestionsResponsesMap.get(surv.Id));

				surveyResponses.add(surveyResponse);
			}
		}
	}

	private void UpdateSurveyResponseWithParsedChatText(LiveChatTranscript chat, Stage_FF_SFDC_SurveyResponse__c response) {
		//response.Team__c = chat.OwnerId;
		response.Chat_date__c = chat.RequestTime;
		response.chat_number__c = chat.Name;

		String chatText = chat.body;
		if (chatText != '' && chatText != null) {
			String[] chatlines = chatText.split('</p>');
			if (chatlines.size() >= 4) {
				response.chat_origin__c = chatlines.get(1).replace('<p align="center">Chat Origin: ', '');
				response.Chat_Content__c = chatlines.get(3).replace('<br>', '\n');
			}
		}
	}

	// Sets specific field values for new Stage_FF_SFDC_SurveyResponse__c record, depending on the survey name.
	private void UpdateSurveyResponseFieldsAccordingToSurveyTaken(String surveyName, Stage_FF_SFDC_SurveyResponse__c surveyResponse, List <SurveyQuestionResponse__c > responses) {
		responses.sort();

		if (surveyName == 'Infiniti Customer Feedback') {
			PopulateInfinitiCustomerFeedbackInfo(surveyResponse, responses);
		}
		else if (surveyName == 'Nissan Customer Feedback') {
			PopulateNissanCustomerFeedbackInfo(surveyResponse, responses);
		}
		else if (surveyName == 'Nissan Closed Loop Feedback') {
			PopulateNissanClosedLoopFeedbackInfo(surveyResponse, responses);
		}
		else if (surveyName == 'Infiniti Closed Loop Feedback') {
			PopulateInfinitiClosedLoopFeedbackInfo(surveyResponse, responses);
		}
		else if (surveyName == 'Nissan Feedback Requested: Your Email Inquiry') {
			PopulateNissanEmailInquirykInfo(surveyResponse, responses);
		}
		else if (surveyName == 'Infiniti Feedback Requested: Your Email Inquiry') {
			PopulateInfinityEmailInquiryInfo(surveyResponse, responses);
		}
	}

	// Sets Infiniti Customer Feedback field values for new Stage_FF_SFDC_SurveyResponse__c record, depending on SurveyQuestionResponse__c index.
	private void PopulateInfinitiCustomerFeedbackInfo(Stage_FF_SFDC_SurveyResponse__c surveyResponse, List <SurveyQuestionResponse__c > responses) {
		Integer responsesLengh = responses.size();
		for (Integer i = 0; responsesLengh > i; i++) {
			if (i == 3) {
				surveyResponse.CustomerFb_Infiniti_ExpBrand_Comments__c = responses[i].Response__c;
			}
			else if (i == 2) {
				surveyResponse.CustomerFb_Infiniti_ExpBrand_NPS__c = responses[i].Response__c;
			}
			else if (i == 1) {
				surveyResponse.CustomerFb_Infiniti_ExpRetailer_Comments__c = responses[i].Response__c;
			}
			else if (i == 0) {
				surveyResponse.CustomerFb_Infiniti_ExpRetailer_NPS__c = responses[i].Response__c;
			}
		}
	}

	// Sets Nissan Customer Feedback field values for new Stage_FF_SFDC_SurveyResponse__c record, depending on SurveyQuestionResponse__c index.
	private void PopulateNissanCustomerFeedbackInfo(Stage_FF_SFDC_SurveyResponse__c surveyResponse, List <SurveyQuestionResponse__c > responses) {
		Integer responsesLengh = responses.size();
		for (Integer i = 0; responsesLengh > i; i++) {
			if (i == 3) {
				surveyResponse.CustomerFb_Nissan_ExpBrand_Comments__c = responses[i].Response__c;
			}
			else if (i == 2) {
				surveyResponse.CustomerFb_Nissan_ExpBrand_NPS__c = responses[i].Response__c;
			}
			else if (i == 1) {
				surveyResponse.CustomerFb_Nissan_ExpRetailer_Comments__c = responses[i].Response__c;
			}
			else if (i == 0) {
				surveyResponse.CustomerFb_Nissan_ExpRetailer_NPS__c = responses[i].Response__c;
			}
		}
	}

	// Sets Nissan ClosedLoop Feedback field values for new Stage_FF_SFDC_SurveyResponse__c record, depending on SurveyQuestionResponse__c index.
	private void PopulateNissanClosedLoopFeedbackInfo(Stage_FF_SFDC_SurveyResponse__c surveyResponse, List <SurveyQuestionResponse__c > responses) {
		Integer responsesLengh = responses.size();
		for (Integer i = 0; responsesLengh > i; i++) {
			if (i == 3) {
				surveyResponse.ClosedLFb_Nissan_ExpBrand_Comments__c = responses[i].Response__c;
			}
			else if (i == 2) {
				surveyResponse.ClosedLFb_Nissan_ExpBrand_NPS__c = responses[i].Response__c;
			}
			else if (i == 1) {
				surveyResponse.ClosedLFb_Nissan_ExpRetailer_Comments__c = responses[i].Response__c;
			}
			else if (i == 0) {
				surveyResponse.ClosedLFb_Nissan_ExpRetailer_NPS__c = responses[i].Response__c;
			}
		}
	}

	// Sets Infiniti ClosedLoop Feedback field values for new Stage_FF_SFDC_SurveyResponse__c record, depending on SurveyQuestionResponse__c index.
	private void PopulateInfinitiClosedLoopFeedbackInfo(Stage_FF_SFDC_SurveyResponse__c surveyResponse, List <SurveyQuestionResponse__c > responses) {
		Integer responsesLengh = responses.size();
		for (Integer i = 0; responsesLengh > i; i++) {
			if (i == 3) {
				surveyResponse.ClosedLFb_Inf_ExpBrand_Comments__c = responses[i].Response__c;
			}
			else if (i == 2) {
				surveyResponse.ClosedLFb_Inf_ExpBrand_NPS__c = responses[i].Response__c;
			}
			else if (i == 1) {
				surveyResponse.ClosedLFb_Inf_ExpRetailer_Comments__c = responses[i].Response__c;
			}
			else if (i == 0) {
				surveyResponse.ClosedLFb_Inf_ExpRetailer_NPS__c = responses[i].Response__c;
			}
		}
	}

	// Sets Nissan Email Inquiry field values for new Stage_FF_SFDC_SurveyResponse__c record, depending on SurveyQuestionResponse__c index.
	private void PopulateNissanEmailInquirykInfo(Stage_FF_SFDC_SurveyResponse__c surveyResponse, List <SurveyQuestionResponse__c > responses) {
		Integer responsesLengh = responses.size();
		for (Integer i = 0; responsesLengh > i; i++) {
			if (i == 3) {
				surveyResponse.EmailInquiry_Nissan_ExpBrand_Comments__c = responses[i].Response__c;
			}
			else if (i == 2) {
				surveyResponse.EmailInquiry_Nissan_ExpBrand_NPS__c = responses[i].Response__c;
			}
			else if (i == 1) {
				surveyResponse.EmailInquiry_Nissan_Rep_Comments__c = responses[i].Response__c;
			}
			else if (i == 0) {
				surveyResponse.EmailInquiry_Nissan_RepExp_NPS__c = responses[i].Response__c;
			}
		}
	}

	// Sets Infinity Email Inquiry field values for new Stage_FF_SFDC_SurveyResponse__c record, depending on SurveyQuestionResponse__c index.
	private void PopulateInfinityEmailInquiryInfo(Stage_FF_SFDC_SurveyResponse__c surveyResponse, List <SurveyQuestionResponse__c > responses) {
		Integer responsesLengh = responses.size();
		for (Integer i = 0; responsesLengh > i; i++) {
			if (i == 3) {
				surveyResponse.EmailInquiry_Infiniti_ExpBrand_Comments__c = responses[i].Response__c;
			}
			else if (i == 2) {
				surveyResponse.EmailInquiry_Infiniti_ExpBrand_NPS__c = responses[i].Response__c;
			}
			else if (i == 1) {
				surveyResponse.EmailInquiry_Infiniti_Rep_Comments__c = responses[i].Response__c;
			}
			else if (i == 0) {
				surveyResponse.EmailInquiry_Infiniti_RepExp_NPS__c = responses[i].Response__c;
			}
		}
	}

	// Inserts new Stage_FF_SFDC_SurveyResponse__c records and logs all errors that has been occured during this process.
	private void InsertSurveyResponsesData() {
		if (!surveyResponses.isEmpty()) {
			// Insert rows
			Database.SaveResult[] dbResults = Database.insert(surveyResponses, false);
			// If there are any results, handle the errors
			if (!dbResults.isEmpty())
			{
				// Loop through results returned
				for (integer row = 0; row <surveyResponses.size(); row++)
				{
					// If the current row was not sucessful, handle the error.
					if (!dbResults[row].isSuccess())
					{
						// Get the error for this row and populate corresponding fields
						Database.Error err = dbResults[row].getErrors() [0];
						errors.add(new Error_Log__c(Record_ID__c = surveyResponses[row].SurveyID__c,
						                            Record_Type__c = 'Stage_FF_SFDC_SurveyResponse__c',
						                            Error_Message__c = err.getMessage(),
						                            TimeStamp__c = System.now(),
						                            Operation_Name__c = 'SurveysAfterTriggerHelper',
						                            Source__c = 'Salesforce',
						                            Log_Type__c = 'Error',
						                            Log_Level__c = 1));
					}
				}
			}
		}

		insert errors;
	}

}