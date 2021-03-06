trigger CaseCategoryDependency_BeforeInsert on CaseCategory_Dependency__c (before insert)  { 
	List<CaseCategory_Dependency__c> noCode = new List<CaseCategory_Dependency__c>();
	for(CaseCategory_Dependency__c dependency: Trigger.new){
		List<Code__c> codes = [SELECT Id, Code__c FROM Code__c WHERE (Type__c='Major Component Code' OR Type__c='TREAD Code')  AND Code__c=:dependency.Major_Component_Code__c];
		if(codes.size() == 0){
			noCode.add(dependency);
		}
	}

	if(noCode.size() > 0){
		for(CaseCategory_Dependency__c dependency : noCode){
			dependency.addError('The Case Category Dependency cannot be created because there is no matching TREAD or Major Component Code.');
		}
	}
}