/**********************************************************************
  Name:OnetimeTreadMigrationCode_Before
  Copyright ? notice: Nissan Motor Company.
  ======================================================
  Purpose:
  This trigger updates Case Categories, whenever new record created for OnetimeTreadMigration_Code__c object
  ======================================================
  History:
 
  VERSION AUTHOR DATE DETAIL 
  1.0 - Anna Koseikina 02/24/2015 Created
 ***********************************************************************/
trigger OnetimeTreadMigrationCode_Before on OnetimeTreadMigration_Code__c (before insert)  {
	List<String> caseIds = new List<String>();
	//get existing TREAD and Major Component codes
	Set<String> codes = new Set<String>();
	for(Code__c code : [SELECT Id, Code__c FROM Code__c WHERE (Type__c='Major Component Code' OR Type__c='TREAD Code')]){
		codes.add(code.Code__c);
	}
	//get all case Ids
	for(OnetimeTreadMigration_Code__c onetimeMigration : trigger.new){
		if(onetimeMigration.Salesforce_Case_Id__c != null && onetimeMigration.Salesforce_Case_Id__c != ''){
			caseIds.add(onetimeMigration.Salesforce_Case_Id__c);
		}
	}
	//map cases and its ids
	
	Map<String, Case> mapCases = new Map<String, Case>();	
	for(Case caseItem : [SELECT ID FROM Case WHERE ID IN :caseIds]){
		if(mapCases.get(String.valueOf(caseItem.Id).substring(0, 15)) == null){
			mapCases.put(String.valueOf(caseItem.Id).substring(0, 15), caseItem);
		}
	}
	//map for storing migration codes
	Map<Integer, OnetimeTreadMigration_Code__c> migrationCodes= new Map<Integer, OnetimeTreadMigration_Code__c>();
	Integer counter = 0;
	//map categories and migration codes
	Map<Integer, Integer> categoriesCodes= new Map<Integer, Integer>();
	Integer counterCategoriesCodes = 0;
	//list of categories to update
	Set<Case_Categorization__c> categoriesToUpdate = new Set<Case_Categorization__c>();
	List<Case_Categorization__c> categoriesToUpdateList = new List<Case_Categorization__c>();
	List<Case_Categorization__c> categories = [SELECT ID, Concern_Code__c, Category_Code__c, Subcategory_Code__c, Subcategory__c, Symptom__c, Symptom_Code__c, Case__c FROM Case_Categorization__c WHERE Case__c IN :mapCases.values()];
	//get subcategories, will be used later
	List<String> subcat = new List<String>();
	for(Case_Categorization__c category : categories){
		if(category.Subcategory__c != null){
			subcat.add(category.Subcategory__c);
		}
	}
	//get case category dependencies which have major component code and are in range by subcategories
	List<CaseCategory_Dependency__c> dependencies = [SELECT Id, Major_Component_Code__c ,Subcategory__c,Symptom__c FROM CaseCategory_Dependency__c WHERE Major_Component_Code__c != null AND Major_Component_Code__c != '' AND Subcategory__c IN :subcat];	
		
	for(OnetimeTreadMigration_Code__c onetimeMigration : trigger.new){
		if(onetimeMigration.Tread_Effective_Date__c != null && onetimeMigration.Incident_Open_Date__c <= onetimeMigration.Tread_Effective_Date__c){
			if (onetimeMigration.Salesforce_Case_Id__c == null || onetimeMigration.Salesforce_Case_Id__c == '') {

				// If Case Id is empty, then we log an error and skip to next record in trigger
				onetimeMigration.Successful__c = false;
				onetimeMigration.Error_Description__c = 'Case ID is empty, cannot find a Case';	
				counter++;
				continue;
			}
			Case ca;
			if(onetimeMigration.Salesforce_Case_Id__c.length() == 15){
				ca = mapCases.get(onetimeMigration.Salesforce_Case_Id__c);
			}else if(onetimeMigration.Salesforce_Case_Id__c.length() == 18){
				ca = mapCases.get(onetimeMigration.Salesforce_Case_Id__c.substring(0, 15));
			}		
			if(ca != null){
				Integer categoriesForCurrentCase = 0;
				for(Case_Categorization__c category : categories){
					if(category.Concern_Code__c.equals(onetimeMigration.Concern_Code__c) && 
							category.Category_Code__c.equals(onetimeMigration.Category_Code__c) &&
							category.Subcategory_Code__c.equals(onetimeMigration.Subcategory_Code__c) &&
							category.Symptom_Code__c.equals(onetimeMigration.Symptom_Code__c) &&
							category.Case__c.equals(ca.Id) &&
							!categoriesToUpdate.contains(category)){

						Boolean dependencyExists = false;
						//if category is found, set it's fields, add to update list, map counters, populate case id 
						if(onetimeMigration.Tread_Code__c != null && onetimeMigration.Tread_Code__c != 'NP' && onetimeMigration.Tread_Code__c != ''){
							if(onetimeMigration.Tread_Code__c.length() == 1 && onetimeMigration.Tread_Code__c.isNumeric()){
								category.Major_Component_Code__c = '0' + onetimeMigration.Tread_Code__c;
							}else{
								category.Major_Component_Code__c = onetimeMigration.Tread_Code__c;
							}
							dependencyExists = true;
						}else if(onetimeMigration.Tread_Code__c == null || onetimeMigration.Tread_Code__c == ''){
							onetimeMigration.Successful__c = false;
							onetimeMigration.Error_Description__c = 'TREAD Code is empty';
							categoriesForCurrentCase++;
							continue;
						}else{						
							for(CaseCategory_Dependency__c dependency : dependencies){
							//take only corresponding case category dependencies
								if(dependency.Subcategory__c == category.Subcategory__c && dependency.Symptom__c == category.Symptom__c){
								//check that category doesn't have assigned major component code or it is different from dependency's code
									if(codes.contains(dependency.Major_Component_Code__c)){																
										category.Major_Component_Code__c = dependency.Major_Component_Code__c;
									}
									dependencyExists = true;	
									break;		
								}
							}						
						}
						
						if(!dependencyExists){
							onetimeMigration.Successful__c = false;
							onetimeMigration.Error_Description__c = 'Case Category does not have matching TREAD Code';
							categoriesForCurrentCase++;
						}else{
							category.Category_Date__c = onetimeMigration.Tread_Effective_Date__c;
							category.CASunsetMigrationDocumentID__c = onetimeMigration.Document_ID_Case_Number__c;
							categoriesToUpdate.add(category);
							categoriesToUpdateList.add(category);
							categoriesCodes.put(counterCategoriesCodes, counter);
							counterCategoriesCodes++;
							categoriesForCurrentCase++;
						}
					}
				}
				//if no categories - log error
				if(categoriesForCurrentCase == 0){
					onetimeMigration.Successful__c = false;
					onetimeMigration.Error_Description__c = 'Case Category not found';
				}
			}else{
			//if case not found - log error
				onetimeMigration.Successful__c = false;
				onetimeMigration.Error_Description__c = 'Case not found';
			}
		}else if (onetimeMigration.Tread_Effective_Date__c == null){
			onetimeMigration.Successful__c = false;
			onetimeMigration.Error_Description__c = 'TREAD effective date is empty';
		}else{
			onetimeMigration.Successful__c = false;
			onetimeMigration.Error_Description__c = 'Case categorization cannot be before Incident Open Date';
		}
		onetimeMigration.Salesforce_Case_Categorization_Id__c = '';
		migrationCodes.put(counter, onetimeMigration);
		counter++;
	}
	// Update  Case Categorizations
	if (!categoriesToUpdateList.isEmpty()) {
		// Insert rows
		Database.SaveResult[] dbResults = Database.update(categoriesToUpdateList, false);
		// If there are any results, handle the errors
		if (!dbResults.isEmpty())
		{
			// Loop through results returned
			for (integer row = 0; row <categoriesToUpdateList.size(); row++)
			{
			System.debug('****dbResults[row] ' + dbResults[row] + ' row ' + row + ' category id ' + dbResults[row].getId());
				// If the current row was not sucessful, handle the error.
				if (!dbResults[row].isSuccess())
				{
					// Get the error for this row and populate corresponding fields
					Database.Error err = dbResults[row].getErrors() [0];
					migrationCodes.get(categoriesCodes.get(row)).Successful__c = false;
					migrationCodes.get(categoriesCodes.get(row)).Error_Description__c = err.getMessage();			
				}else{
					if(categoriesToUpdateList[row].Major_Component_Code__c != null && !categoriesToUpdateList[row].Major_Component_Code__c.equals('')){
						migrationCodes.get(categoriesCodes.get(row)).Successful__c = true;
						migrationCodes.get(categoriesCodes.get(row)).Error_Description__c = '';
						migrationCodes.get(categoriesCodes.get(row)).Salesforce_Case_Categorization_Id__c = migrationCodes.get(categoriesCodes.get(row)).Salesforce_Case_Categorization_Id__c + ' ' + dbResults[row].getId() + ', ';
					}else{
						migrationCodes.get(categoriesCodes.get(row)).Successful__c = false;
						migrationCodes.get(categoriesCodes.get(row)).Error_Description__c = 'Case Category is not TREAD Reportable';
						migrationCodes.get(categoriesCodes.get(row)).Salesforce_Case_Categorization_Id__c = migrationCodes.get(categoriesCodes.get(row)).Salesforce_Case_Categorization_Id__c + ' ' + dbResults[row].getId() + ', ';
					}			
					
				}
			}
		}
	}

}