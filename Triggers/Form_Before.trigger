/**********************************************************************
Name: Form_Before
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
Forms cannot be added to a closed case.
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 -  Yuli Fintescu	02/09/2012 Created
1.1 -  Bryan Fry		12/19/2012 Added clause to allow DPIC closed cases to have Forms added
***********************************************************************/
trigger Form_Before on Form__c (before insert) {
    // ********** Forms cannot be added to a closed case
    if (Trigger.isInsert) {
	    Set<ID> caseIds = new Set<ID>();
		for (Form__c t: Trigger.new) {
			caseIds.add(t.Case__c);
		}
		
		List<Case> cases = [select Id from Case where Id in :caseIds and IsClosed = true and RecordType.Name not in ('DPIC','DPIC Supply Escalation','DPIC Technical Escalation')];
		Map<ID, Case> mapCases = new Map<ID, Case>(cases);
		for (Form__c t: Trigger.new) {
			if (mapCases.containsKey(t.Case__c))
				t.addError('Forms cannot be added to a closed case.');
		}
    }
}