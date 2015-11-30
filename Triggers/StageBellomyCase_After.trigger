trigger StageBellomyCase_After on StageBellomyCases__c (after insert)  { 
	StageBellomyCaseAfter_Helper helper = new StageBellomyCaseAfter_Helper();
	helper.BellomySurveys(Trigger.new);
}