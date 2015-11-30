/**********************************************************************
Name: Form_After
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
Upon creating a new Form IIR record, need to update the related Case to populate the "IIR__c" field with the Form ID.

======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Yuli FIntescu 09/20/2011 Created
***********************************************************************/
trigger Form_After on Form__c (after insert) {
	RecordType iirRT = [select id, name from recordtype where name = 'IIR' and sobjecttype = 'Form__c' limit 1];
	Map<ID, Form__c> relatedCases = new Map<ID, Form__c>();
	for (Form__c b : Trigger.New) {
		if (b.RecordTypeId == iirRT.Id)
			relatedCases.put(b.Case__c, b);
	}
	
	List<Case> casesToUpdate = new List<Case>();
	for (Case c : [Select Form__c From Case WHERE ID in: relatedCases.keySet() and Form__c = NULL]) {
		c.IIR__c = relatedCases.get(c.ID).ID;
		casesToUpdate.add(c);
	}
	
	try {
		if(casesToUpdate.size() > 0)
			update casesToUpdate;
	} catch (DMLException e) {
    	relatedCases.get(e.getDmlId(0)).addError('Exception occured while updating case IIR: ' + e.getMessage());
	}
}