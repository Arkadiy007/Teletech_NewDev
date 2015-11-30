/**********************************************************************
  Name: SurveyQuestionResponseAfterTriggerTests
  Copyright © notice: Nissan Motor Company.
  ======================================================
  Purpose:
  Test class for SurveyQuestionResponseAfterTrigger trigger and helper class SurveysAfterTriggerHelper.
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko	03/10/2015 Created
 ***********************************************************************/
@istest
public class SurveyQuestionResponseAfterTriggerTests {
	final static RecordType liveagentRecordType = [select id, name from recordtype where name = 'Live Agent' and sobjecttype = 'Surveys__c' limit 1];
	private static Surveys__c surveys;
	private static Survey__c survey;
	private static SurveyTaker__c taker;
	private static List <SurveyQuestionResponse__c > resps;

	static testMethod void SurveyQuestionResponseAfterTrigger_ShouldCreateSurveyResponseRecord_ForInfinitiCustomerFeedback() {
		Test.startTest();
		CreateSurveyQuestionResponseData('Infiniti Customer Feedback');
		Test.stopTest();

		List <Stage_FF_SFDC_SurveyResponse__c > result = [Select Id, CustomerFb_Infiniti_ExpBrand_Comments__c,
		                                                  CustomerFb_Infiniti_ExpBrand_NPS__c, CustomerFb_Infiniti_ExpRetailer_Comments__c, CustomerFb_Infiniti_ExpRetailer_NPS__c
		                                                  FROM Stage_FF_SFDC_SurveyResponse__c WHERE SurveyID__c = :taker.Id];

		system.assertequals(1, result.size());
		system.assertequals('test1', result.get(0).CustomerFb_Infiniti_ExpRetailer_NPS__c);
		system.assertequals('test2', result.get(0).CustomerFb_Infiniti_ExpRetailer_Comments__c);
		system.assertequals('test3', result.get(0).CustomerFb_Infiniti_ExpBrand_NPS__c);
		system.assertequals('test4', result.get(0).CustomerFb_Infiniti_ExpBrand_Comments__c);
	}

	static testMethod void SurveyQuestionResponseAfterTrigger_ShouldCreateSurveyResponseRecord_ForNissanCustomerFeedback() {
		Test.startTest();
		CreateSurveyQuestionResponseData('Nissan Customer Feedback');
		Test.stopTest();

		List <Stage_FF_SFDC_SurveyResponse__c > result = [Select Id, CustomerFb_Nissan_ExpRetailer_NPS__c,
		                                                  CustomerFb_Nissan_ExpRetailer_Comments__c, CustomerFb_Nissan_ExpBrand_NPS__c, CustomerFb_Nissan_ExpBrand_Comments__c
		                                                  FROM Stage_FF_SFDC_SurveyResponse__c WHERE SurveyID__c = :taker.Id];

		system.assertequals(1, result.size());
		system.assertequals('test1', result.get(0).CustomerFb_Nissan_ExpRetailer_NPS__c);
		system.assertequals('test2', result.get(0).CustomerFb_Nissan_ExpRetailer_Comments__c);
		system.assertequals('test3', result.get(0).CustomerFb_Nissan_ExpBrand_NPS__c);
		system.assertequals('test4', result.get(0).CustomerFb_Nissan_ExpBrand_Comments__c);
	}

	static testMethod void SurveyQuestionResponseAfterTrigger_ShouldCreateSurveyResponseRecord_ForNissanClosedLoopFeedback() {
		Test.startTest();
		CreateSurveyQuestionResponseData('Nissan Closed Loop Feedback');
		Test.stopTest();

		List <Stage_FF_SFDC_SurveyResponse__c > result = [Select Id, ClosedLFb_Nissan_ExpRetailer_NPS__c,
		                                                  ClosedLFb_Nissan_ExpRetailer_Comments__c, ClosedLFb_Nissan_ExpBrand_NPS__c, ClosedLFb_Nissan_ExpBrand_Comments__c
		                                                  FROM Stage_FF_SFDC_SurveyResponse__c WHERE SurveyID__c = :taker.Id];

		system.assertequals(1, result.size());
		system.assertequals('test1', result.get(0).ClosedLFb_Nissan_ExpRetailer_NPS__c);
		system.assertequals('test2', result.get(0).ClosedLFb_Nissan_ExpRetailer_Comments__c);
		system.assertequals('test3', result.get(0).ClosedLFb_Nissan_ExpBrand_NPS__c);
		system.assertequals('test4', result.get(0).ClosedLFb_Nissan_ExpBrand_Comments__c);
	}

	static testMethod void SurveyQuestionResponseAfterTrigger_ShouldCreateSurveyResponseRecord_ForInfinitiClosedLoopFeedback() {
		Test.startTest();
		CreateSurveyQuestionResponseData('Infiniti Closed Loop Feedback');
		Test.stopTest();

		List <Stage_FF_SFDC_SurveyResponse__c > result = [Select Id, ClosedLFb_Inf_ExpRetailer_NPS__c,
		                                                  ClosedLFb_Inf_ExpRetailer_Comments__c, ClosedLFb_Inf_ExpBrand_NPS__c, ClosedLFb_Inf_ExpBrand_Comments__c
		                                                  FROM Stage_FF_SFDC_SurveyResponse__c WHERE SurveyID__c = :taker.Id];

		system.assertequals(1, result.size());
		system.assertequals('test1', result.get(0).ClosedLFb_Inf_ExpRetailer_NPS__c);
		system.assertequals('test2', result.get(0).ClosedLFb_Inf_ExpRetailer_Comments__c);
		system.assertequals('test3', result.get(0).ClosedLFb_Inf_ExpBrand_NPS__c);
		system.assertequals('test4', result.get(0).ClosedLFb_Inf_ExpBrand_Comments__c);
	}

	static testMethod void SurveyQuestionResponseAfterTrigger_ShouldCreateSurveyResponseRecord_ForNissanEmailInquiry() {
		Test.startTest();
		CreateSurveyQuestionResponseData('Nissan Feedback Requested: Your Email Inquiry');
		Test.stopTest();

		List <Stage_FF_SFDC_SurveyResponse__c > result = [Select Id, EmailInquiry_Nissan_RepExp_NPS__c,
		                                                  EmailInquiry_Nissan_Rep_Comments__c, EmailInquiry_Nissan_ExpBrand_NPS__c, EmailInquiry_Nissan_ExpBrand_Comments__c
		                                                  FROM Stage_FF_SFDC_SurveyResponse__c WHERE SurveyID__c = :taker.Id];

		system.assertequals(1, result.size());
		system.assertequals('test1', result.get(0).EmailInquiry_Nissan_RepExp_NPS__c);
		system.assertequals('test2', result.get(0).EmailInquiry_Nissan_Rep_Comments__c);
		system.assertequals('test3', result.get(0).EmailInquiry_Nissan_ExpBrand_NPS__c);
		system.assertequals('test4', result.get(0).EmailInquiry_Nissan_ExpBrand_Comments__c);
	}

	static testMethod void SurveyQuestionResponseAfterTrigger_ShouldCreateSurveyResponseRecord_InfinityEmailInquiry() {
		Test.startTest();
		CreateSurveyQuestionResponseData('Infiniti Feedback Requested: Your Email Inquiry');
		Test.stopTest();

		List <Stage_FF_SFDC_SurveyResponse__c > result = [Select Id, EmailInquiry_Infiniti_RepExp_NPS__c,
		                                                  EmailInquiry_Infiniti_Rep_Comments__c, EmailInquiry_Infiniti_ExpBrand_NPS__c, EmailInquiry_Infiniti_ExpBrand_Comments__c
		                                                  FROM Stage_FF_SFDC_SurveyResponse__c WHERE SurveyID__c = :taker.Id];

		system.assertequals(1, result.size());
		system.assertequals('test1', result.get(0).EmailInquiry_Infiniti_RepExp_NPS__c);
		system.assertequals('test2', result.get(0).EmailInquiry_Infiniti_Rep_Comments__c);
		system.assertequals('test3', result.get(0).EmailInquiry_Infiniti_ExpBrand_NPS__c);
		system.assertequals('test4', result.get(0).EmailInquiry_Infiniti_ExpBrand_Comments__c);
	}

	static testMethod void SurveyQuestionResponseAfterTrigger_ShouldCreateSurveyResponseRecord_WhenSurveysBeenInserted() {
		Test.startTest();
		CreateSurveysData();
		Test.stopTest();

		List <Stage_FF_SFDC_SurveyResponse__c > result = [Select Id FROM Stage_FF_SFDC_SurveyResponse__c WHERE SurveyID__c = :surveys.Id];

		system.assertequals(1, result.size());
	}

	private static void CreateSurveysData() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
		User u = new User(Alias = 'TCS-MW', Email='standarduser@testorg.com', 
		      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		      LocaleSidKey='en_US', ProfileId = p.Id, 
		      TimeZoneSidKey='America/Los_Angeles', UserName='tst@testorg.com');
		insert u;

		surveys = new Surveys__c();
		surveys.RecordTypeId = liveagentRecordType.Id;
		surveys.Live_Agent_Concern_Comments__c = 'test1';
		surveys.Live_Agent_Concern_Satisfied__c = 'test2';
		surveys.Live_Agent_Experience_Comments__c = 'test3';
		surveys.Live_Agent_Experience_Satisfied__c = 'test4';
		surveys.Live_Agent_Recommended_Comments__c = 'test5';
		surveys.Live_Agent_Recommended__c = '02';
		insert surveys;

		LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor; 

		LiveChatTranscript transc = new LiveChatTranscript();
		transc.Survey__c = surveys.Id;
		transc.OwnerId = u.Id;
		transc.LiveChatVisitorId = visitor.Id;
		insert transc;
	}

	private static void CreateSurveyQuestionResponseData(String surveyName) {
		survey = new Survey__c();
		survey.Name = surveyName;
		survey.Submit_Response__c = 'message';
		insert survey;

		taker = new SurveyTaker__c();
		taker.Survey__c = survey.Id;
		insert taker;

		List <Survey_Question__c > questions = new List <Survey_Question__c > ();
		Survey_Question__c q1 = new Survey_Question__c();
		q1.Survey__c = survey.Id;
		q1.OrderNumber__c = 1;
		q1.Question__c = 'questiontesst1';
		questions.add(q1);

		Survey_Question__c q2 = new Survey_Question__c();
		q2.Survey__c = survey.Id;
		q2.OrderNumber__c = 2;
		q2.Question__c = 'questiontesst2';
		questions.add(q2);

		Survey_Question__c q3 = new Survey_Question__c();
		q3.Survey__c = survey.Id;
		q3.OrderNumber__c = 3;
		q3.Question__c = 'questiontesst3';
		questions.add(q3);

		Survey_Question__c q4 = new Survey_Question__c();
		q4.Survey__c = survey.Id;
		q4.OrderNumber__c = 4;
		q4.Question__c = 'questiontesst4';
		questions.add(q4);

		insert questions;

		resps = new List <SurveyQuestionResponse__c > ();

		SurveyQuestionResponse__c resp1 = new SurveyQuestionResponse__c();
		resp1.SurveyTaker__c = taker.Id;
		resp1.Response__c = 'test1';
		resp1.Survey_Question__c = questions.get(0).Id;
		resps.add(resp1);

		SurveyQuestionResponse__c resp2 = new SurveyQuestionResponse__c();
		resp2.SurveyTaker__c = taker.Id;
		resp2.Response__c = 'test2';
		resp2.Survey_Question__c = questions.get(1).Id;
		resps.add(resp2);

		SurveyQuestionResponse__c resp3 = new SurveyQuestionResponse__c();
		resp3.SurveyTaker__c = taker.Id;
		resp3.Response__c = 'test3';
		resp3.Survey_Question__c = questions.get(2).Id;
		resps.add(resp3);

		SurveyQuestionResponse__c resp4 = new SurveyQuestionResponse__c();
		resp4.SurveyTaker__c = taker.Id;
		resp4.Response__c = 'test4';
		resp4.Survey_Question__c = questions.get(3).Id;
		resps.add(resp4);

		insert resps;
	}
}