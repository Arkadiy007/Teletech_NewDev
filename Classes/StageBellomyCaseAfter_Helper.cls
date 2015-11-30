public class StageBellomyCaseAfter_Helper {
	public void BellomySurveys(List<StageBellomyCases__c> newCases) {
		List<Surveys__c> createSurveys = new List<Surveys__c> ();
		
		Id bellomy = Schema.SObjectType.Surveys__c.getRecordTypeInfosByName().get('Bellomy Survey').getRecordTypeId();
		Set<Id> casesWithExistSurv = new Set<Id> ();
		for (Surveys__c survey :[Select Id, StageBellomyCase__c from Surveys__c where recordtypeid = :bellomy and StageBellomyCase__c != null]) {
			casesWithExistSurv.add(survey.StageBellomyCase__c);
		}
		System.debug('****newCases ' + newCases);
		for (StageBellomyCases__c caseitem : newCases) {
			if (!casesWithExistSurv.contains(caseitem.id)) {
				Surveys__c survey = new Surveys__c(StageBellomyCase__c = caseItem.ID,
				                                   recordTypeId = bellomy,
				                                   Email__c = caseitem.Person_Account_Email__c,
				                                   Bellomy_Case_Account_Name__c = caseitem.Account_Name__c,
												   Brand__c = caseItem.Related_vehicle_Make__c,
												   Case_Id__c = caseItem.Id);
				
				createSurveys.add(survey);
			}
		}

		if (createSurveys.size() > 0) {
			insert createSurveys;
		}
	}
}