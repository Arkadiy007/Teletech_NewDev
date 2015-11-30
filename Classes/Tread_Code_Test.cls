@isTest(SeeAllData=true)
private Class Tread_Code_Test {
	static testMethod void testTread() {
		test.startTest();
		Set<String> codes = new Set<String>();
		for(Code__c code : [SELECT Id, Code__c FROM Code__c WHERE (Type__c='Major Component Code' OR Type__c='TREAD Code')]){
			codes.add(code.Code__c);
		}
		integer i = 0;
		integer j = 0;
		for(CaseCategory_Dependency__c dependency : [SELECT Id, Major_Component_Code__c FROM CaseCategory_Dependency__c]){			
		i++;
			if(dependency.Major_Component_Code__c == null || !codes.contains(dependency.Major_Component_Code__c)){			
				System.debug('No code for these subcategory and symptom ');
				j++;
			}
		}

		test.stoptest();

	}
		
}