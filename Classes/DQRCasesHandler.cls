public class DQRCasesHandler {

  private static Map<String, Map<String, String>> businessRules {get; Set;}
  private static Set<Id> duplicateCasesId;
  private static Set<Case> duplicateCasesList {get; Set;}

  public static void processCases(Case[] triggerNew){
		DQR_Configuration__c configuration = getConfigurationSettings();
		duplicateCasesList = new Set<Case>();
		Case[] dqrCases = validateCases(triggerNew);
	

		if (dqrCases.size() > 0){
			Set<Case> dupFreeCases = checkForDuplicates(dqrCases, configuration);
		
			List<DQR_Stage_Object__c> stageObjects = new List<DQR_Stage_Object__c>();

			for(Case dqrCase : dqrCases){
				if (phoneAvailable(dqrCase) && dupFreeCases.contains(dqrCase)){
					configuration.Counter__c++;
					
					if (configuration.Counter__c >= configuration.Control_Group_Cases_Number__c && Math.mod( (Integer) configuration.Counter__c,  (Integer)  configuration.Control_Group_Cases_Number__c) == 0){
						applyBusinessRules(dqrCase, 'ControlGroup');
						configuration.Counter__c = 0;
					}
					else{
						applyBusinessRules(dqrCase, 'StandardDQRCase');
					}
				
				}

				else if(emailAvailable(dqrCase)  && !duplicateCasesId.contains(dqrCase.id)){
					stageObjects.add(createDQRStageObject(dqrCase));
					applyBusinessRules(dqrCase, 'EmailSent');
				}
				else if(!dupFreeCases.contains(dqrCase) && !duplicateCasesId.contains(dqrCase.id) ){
					applyBusinessRules(dqrCase, 'NoPhoneNoEmail');
				}
			}

			if (stageObjects.size() > 0){
				insert stageObjects;
			}
			
			if (dqrCases.size() > 0){
				update dqrCases;
			}

			if (duplicateCasesList.size() > 0){
				update new List<Case>(duplicateCasesList);
			}
			update configuration;
		}
  }

  private static Case[] validateCases(Case[] triggerNew){
		List<Case> dqrCases = new List<Case>();

		Id customerConnectionFollowUp = RecordtypeUtil.getObjectRecordTypeId(Case.sObjectType, 'Customer Connection Follow Up');
  
		for (Case dqrCase : [SELECT Id, RecordTypeId, Alternate_Email__c, Email2__c, Work_Phone__c, Account.PersonHomePhone, Account.Do_Not_Contact_Indicator__c, Account.Do_Not_Mail_Indicator__c, Home_Phone__c, Mobile_Phone__c, AccountId, Maritz_ID__c, Household_ID__c FROM Case WHERE Id IN: triggerNew]){
			if (dqrCase.RecordTypeId == customerConnectionFollowUp){
				dqrCases.add(dqrCase);
			}
		}

		if(dqrCases.size() > 0){
			selectBusinessRules();
		}

		return dqrCases;
  }

 
  public static void selectBusinessRules(){
		businessRules = new Map<String, Map<String, String>>();

		for (DQR_Cases_Business_Rules__c bRule : DQR_Cases_Business_Rules__c.getAll().values()){
			if (!businessRules.containsKey(bRule.BR_Name__c)){
				businessRules.put(bRule.BR_Name__c, new Map<String, String>());
			}
				businessRules.get(bRule.BR_Name__c).put(bRule.Field_API_Name__c, bRule.Field_Value__c);
		}
  }

  private static Boolean phoneAvailable(Case c){
	   return !isNullOrEmpty(c.Home_Phone__c) || !isNullOrEmpty(c.Account.PersonHomePhone) ||
			  !isNullOrEmpty(c.Work_Phone__c) || !isNullOrEmpty(c.Mobile_Phone__c);
  }

  private static Boolean emailAvailable(Case c){
	   return !isNullOrEmpty(c.Alternate_Email__c) || !isNullOrEmpty(c.Email2__c);
  }

  /*
  private static Boolean emailContactable(Case c){
	   return !c.Account.Do_Not_Contact_Indicator__c || !c.Account.Do_Not_Mail_Indicator__c;
  }
  */

   private static Set<Case> checkForDuplicates(Case[] triggerNew, DQR_Configuration__c config){
		duplicateCasesId = new Set<Id>();

		List<Case> phoneAvailableCases = getPhoneAvailableCases(triggerNew);
		
		Map<Id, Case> casesByPersonAccounts = getCasesByPersonAccounts(phoneAvailableCases);
		Map<String, Case> householdIds = getHouseHoldIds(phoneAvailableCases);
		Map<String, Case> maritzIds = getMaritzIds(phoneAvailableCases);

		TimeZone tz = UserInfo.getTimeZone();
        Integer offset = tz.getOffset(System.now()) / (60 * 60 * 1000);


		for(Case cs : [SELECT Id, AccountId, Home_Phone__c, Mobile_Phone__c, Account.PersonHomePhone, Work_Phone__c,  Maritz_ID__c, Household_ID__c FROM Case WHERE Id NOT IN :phoneAvailableCases AND CreatedDate >= :System.now().addHours(offset- (Integer) config.HoursToCheckDuplicates__c) AND (AccountId IN: casesByPersonAccounts.keySet() OR Maritz_ID__c IN :maritzIds.keySet() OR Household_ID__c IN :householdIds.keySet()) AND Reason != 'Duplicate']){
			if(phoneAvailable(cs)){
				if (casesByPersonAccounts.containsKey(cs.AccountId)){
					duplicateCasesList.add(casesByPersonAccounts.get(cs.AccountId));
					duplicateCasesId.add(casesByPersonAccounts.get(cs.AccountId).id);
				}
				else if (householdIds.containsKey(cs.Household_ID__c)){
					duplicateCasesList.add(householdIds.get(cs.Household_ID__c));
					duplicateCasesId.add(householdIds.get(cs.Household_ID__c).id);
				}
				else if (maritzIds.containsKey(cs.Maritz_ID__c)){
					duplicateCasesList.add(maritzIds.get(cs.Maritz_ID__c));
					duplicateCasesId.add(maritzIds.get(cs.Maritz_ID__c).id);
				}
			}
		}

		Set<Case> dupFreeCases = new Set<Case> ();

		for (Case dqrCase : phoneAvailableCases){
			if (!duplicateCasesId.contains(dqrCase.id)){
				dupFreeCases.add(dqrCase);
			}	
		}

		//Apply Business Rules On Duplicates
		for (Case cs : duplicateCasesList){
			applyBusinessRules(cs, 'Duplicate');
		}
				
		return dupFreeCases;
  }

   private static Map<Id, Case> getCasesByPersonAccounts(Case[] triggerNew){
	    Map<Id, Case>  casesByAccId = new Map<Id, Case> ();

		for (Case cs : triggerNew){
			if (casesByAccId.containsKey(cs.AccountId)){
			    duplicateCasesList.add(cs);
				duplicateCasesId.add(cs.Id);
			}
			casesByAccId.put(cs.AccountId, cs);
		}

		return casesByAccId;
  }

  private static Map<String, Case> getHouseHoldIds(Case[] triggerNew){
		Map<String, Case> houseHoldIds = new Map<String, Case>();
		for(Case cs : triggerNew){
			if (String.isNotBlank(cs.Household_ID__c)){
				if (houseHoldIds.containsKey(cs.Household_ID__c)){
					duplicateCasesList.add(cs);
					duplicateCasesId.add(cs.Id);
				}
				houseHoldIds.put(cs.Household_ID__c, cs);
			}
		}

		return houseHoldIds;
  }

  private static Map<String, Case> getMaritzIds(Case[] triggerNew){
		Map<String, Case> maritzIds = new Map<String, Case>();

		for(Case cs : triggerNew){
			if (String.isNotBlank(cs.Maritz_ID__c)){
				if (maritzIds.containsKey(cs.Maritz_ID__c)){
					duplicateCasesList.add(cs);
					duplicateCasesId.add(cs.Id);
				}

				maritzIds.put(cs.Maritz_ID__c, cs);
			}
		}

		return maritzIds;
  }

  public static void applyBusinessRules(sObject dqrCase, String ruleName){
		if (businessRules.containsKey(ruleName))
		{
			Map<String, String> noPhoneNoEmailBRules = businessRules.get(ruleName);

			for (String fieldApiName : noPhoneNoEmailBRules.keySet()){
				dqrCase.put(fieldApiName, noPhoneNoEmailBRules.get(fieldApiName));
			}
		}
  }

  private static DQR_Stage_Object__c createDQRStageObject(Case dqrCase){
		DQR_Stage_Object__c stageObject = new DQR_Stage_Object__c();
		stageObject.Case_Id__c = dqrCase.Id;
		stageObject.Status__c = 'New';
		
		if(String.isNotBlank(dqrCase.Email2__c)){
			stageObject.Email__c = dqrCase.Email2__c;
		}

		else if(String.isNotBlank(dqrCase.Alternate_Email__c)){
			stageObject.Email__c = dqrCase.Alternate_Email__c;
		}
		
		return stageObject;
  }

  private static Boolean isNullOrEmpty(String value){
		return value == null || String.isEmpty(value);
  }

  private static DQR_Configuration__c getConfigurationSettings(){
		DQR_Configuration__c configuration = DQR_Configuration__c.getOrgDefaults();
		
		if (configuration == null){
				configuration = new DQR_Configuration__c(Counter__c = 0, Control_Group_Cases_Number__c = 10);
				insert configuration;
				return configuration;
		}
		else{
			return configuration;
		}
  }

  private static List<Case> getPhoneAvailableCases(List<Case> triggerNew){
		List<Case> phoneAvailableCases = new List<Case>();

		for(Case cs : triggerNew){
			if(phoneAvailable(cs)){
				phoneAvailableCases.add(cs);
			}
		}

		return phoneAvailableCases;
  }

 }