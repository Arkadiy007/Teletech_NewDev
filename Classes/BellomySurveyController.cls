public class BellomySurveyController {
	public string brand { get; set; }
	public string brandPrivacy { get; set; }
	public List<Boolean> questions { get; set; }
	public Boolean introText { get; set; }
	private integer questionIndex = - 1;
	public string recommended { get; set; }
	public string recommendedComments { get; set; }
	public string surveyId { get; set; }
	public string caseId { get; set; }
	public Boolean refuseQOne { get; set; }
	public Boolean refuseQFour { get; set; }
	public Boolean refuseQTen { get; set; }
	public Boolean readySubmit { get; set; }
	private ApexPages.StandardController controller { get; set; }
	public string questionThree { get; set; }
	public string questionFive { get; set; }
	public Integer questionTen { get; set; }
	public Integer questionFour { get; set; }
	public string dealer { get; set; }
	public Boolean nissanBrand { get; set; }
	public Boolean infinitiBrand { get; set; }
	public BellomySurveySettings__c settings { get; set; }
	private String[] currentQSix { get; set; }
	public Map<String,String> answersQSix { get; set; }
	private String[] currentQSeven { get; set; }
	public Map<String,String> answersQSeven { get; set; }
	private String questionSixOptOne = 'Length of time you were on hold before you spoke to a representative';
	private String questionSixOptTwo = 'Ease of using the automated telephone system';
	private String questionSixOptThree = 'Number of times you were transferred';
	private String questionSevenOptOne = 'Courtesy shown towards you';
	private String questionSevenOptTwo = 'Listening and showing concern for your needs';
	private String questionSevenOptThree = 'Doing his or her best to help you';
	private String questionSevenOptFour = 'Ability to answer your questions';
	private String questionSevenOptFive = 'Overall timeliness in resolving your issue';
	private String questionSevenOptSix = 'Following through on what he/she promised';
//	private String questionSevenOptSeven = 'Length of time you were on hold while the representative was dealing with your question/issue';

	public BellomySurveyController(ApexPages.StandardController stdController) {
		// Get url parameters
		surveyId = Apexpages.currentPage().getParameters().get('id');
		caseId = Apexpages.currentPage().getParameters().get('caId');
		brand = ApexPages.currentPage().getParameters().get('brand');
		questions = new List<Boolean> { false, false, false, false, false, false, false, false, false, false, false, false };
		introText = true;
		controller = stdController;
		readySubmit = false;
		nissanBrand = false;
		infinitiBrand = false;
		settings = BellomySurveySettings__c.getOrgDefaults();
		if (!String.isEmpty(caseId)) {
			StageBellomyCases__c caseItem = [select id, Related_vehicle_Make__c from StageBellomyCases__c where Id = :caseId limit 1];
			brand = caseItem.Related_vehicle_Make__c;
		}
		if (!String.isEmpty(brand)) {
			if (brand.toLowerCase().contains('nissan')) {
				if (settings != null) {
					dealer = settings.NissanDealer__c;
					brandPrivacy = settings.PrivacyNissan__c;
				} else {
					dealer = 'Nissan Sales and Service Dealer';
					brandPrivacy = 'www.nissanusa.com';
				}

				nissanBrand = true;

			} else if (brand.toLowerCase().contains('infiniti')) {
				if (settings != null) {
					dealer = settings.InfinitiDealer__c;
					brandPrivacy = settings.PrivacyInfiniti__c;
				} else {
					dealer = 'Infiniti Sales and Service Retailer';
					brandPrivacy = 'www.infinitiusa.com';
				}

				infinitiBrand = true;

			}
		} else {
			dealer = 'Dealer';
			nissanBrand = true;
		}
		answersQSix = new Map<String,String>();
		currentQSix = randomize(new String[] { questionSixOptOne, questionSixOptTwo, questionSixOptThree });
		currentQSix = randomize(currentQSix);

		answersQSeven = new Map<String,String>();
		currentQSeven = randomize(new String[] { questionSevenOptOne, questionSevenOptTwo, questionSevenOptThree, questionSevenOptFour, questionSevenOptFive, questionSevenOptSix });
		currentQSeven = randomize(currentQSeven);
		//bellomy stage case, related vehicle make, if empty - nissan

	}
	public BellomySurveyController() { }
	public PageReference goToNextQuestion() {
		if (questionIndex == 4 && (questionFour < 1 || questionFour > 25)) {
			if (settings != null && settings.Message_for_Valid_Range__c != null) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, settings.Message_for_Valid_Range__c));
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Value can be from 1 to 25'));
			}
			return null;
		}

		questions[questionIndex] = false;
		if (questionIndex == 3 && questionThree == 'No') {
			questionIndex++;
		}
		if (questionIndex == 5 && questionFive == 'Not Applicable') {
			questionIndex++;
		}
		if (questionIndex == questions.size() - 2) {
			readySubmit = true;
		}
		questionIndex++;
		questions[questionIndex] = true;

		return null;
	}
	public void startSurvey() {
		questions[0] = true;
		questionIndex = 0;
		introText = false;
	}
	public String[] getQuestionSixScales() {
		
		for(String q : currentQSix){
			answersQSix.put(q, 'an');
		}
		return currentQSix;
	}
	public String[] getQuestionSevenScales() {
		
		for(String q : currentQSeven){
			answersQSeven.put(q, 'an');
		}
		return currentQSeven;
	}
	public void submit() {
		if (surveyId != null && surveyId != '') {
			Surveys__c survey = [Select id from Surveys__c where Id = :surveyId limit 1];
			survey.ResolveBeforeContact__c = questionFive;
			survey.Question_resolved_CA__c = questionThree;
			survey.EffortToResolve__c = questionTen;
			survey.TimesContact__c = questionFour;
			survey.LengthTime__c = answersQSix.get(questionSixOptOne);
			survey.EaseOfUse__c = answersQSix.get(questionSixOptTwo);
			survey.TimesTransferred__c = answersQSix.get(questionSixOptThree);

			survey.CourtesyShown__c = answersQSeven.get(questionSevenOptOne);
			survey.ListeningShowingConcern__c = answersQSeven.get(questionSevenOptTwo);
			survey.DoingBestToHelp__c = answersQSeven.get(questionSevenOptThree);
			survey.AbilityToAnswer__c = answersQSeven.get(questionSevenOptFour);
			survey.OverallTimeliness__c = answersQSeven.get(questionSevenOptFive);
			survey.FollowingThroughPromised__c = answersQSeven.get(questionSevenOptFive);
			update survey;
			
		/*	PageReference pageRef = new PageReference(newPageReference); //pageExitName));
			pageRef.setRedirect(true);
			return pageRef;*/
		}

		//return null;
	}
	public string returnThank {
		get {
			return '\\Bellomy_ThankYou?brand=' + brand;
		} set;
	}
	private static list<String> randomize(list<String> lst) {
		integer currentIndex = lst.size();
		String temporaryValue;
		integer randomIndex;
		// While there remain elements to shuffle...
		while (0 != currentIndex) {
			// Pick a remaining element...
			randomIndex = integer.valueOf(Math.floor(Math.random() * currentIndex));
			currentIndex -= 1;
			// And swap it with the current element.
			temporaryValue = lst[currentIndex];
			lst[currentIndex] = lst[randomIndex];
			lst[randomIndex] = temporaryValue;
		}
		return lst;
	}

}