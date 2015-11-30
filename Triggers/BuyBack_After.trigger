/**********************************************************************
Name: BuyBack_After
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
Upon creating a new Buyback record, need to update the related Case to populate the "Buyback" field with the Buyback ID.

======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Yuli FIntescu 09/20/2011 Created
1.1 - Yuli FIntescu 02/24/2012 Task Creation when VPP Claim # is populated
***********************************************************************/
trigger BuyBack_After on Buyback__c (after insert, after update) {
	ID bbRTid = '012F0000000yCk4';
	RecordType taskCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Task' limit 1];
	Map<ID, Buyback__c> relatedCases = new Map<ID, Buyback__c>();
	
	RecordType vppRT = [select id, name from recordtype where name = 'Goodwill VPP' and sobjecttype = 'Buyback__c' limit 1];
	Map<ID, Buyback__c[]> caseToBBs = new Map<ID, Buyback__c[]>();
	for (Buyback__c b : Trigger.New) {
		//1.0 Upon creating a new Buyback record, need to update the related Case to populate the "Buyback" field with the Buyback ID.
		if (Trigger.isInsert && b.RecordTypeId == bbRTid)
			relatedCases.put(b.Case__c, b);
		
		//1.1 - Task Creation when VPP Claim # is populated
		if (Trigger.isUpdate && b.RecordTypeId == vppRT.Id && Trigger.oldMap.get(b.ID).CAVPP_Claim_No__c == null && b.CAVPP_Claim_No__c != null) {
			if (caseToBBs.containsKey(b.Case__c))
				caseToBBs.get(b.Case__c).add(b);
			else
				caseToBBs.put(b.Case__c, new Buyback__c[]{b});
		}
	}
	
	//1.0 Upon creating a new Buyback record, need to update the related Case to populate the "Buyback" field with the Buyback ID.
	if (relatedCases.size() > 0) {
		List<Case> casesToUpdate = new List<Case>();
		for (Case c : [Select Buyback__c From Case WHERE Vehicle_Name__c <> NULL and ID in: relatedCases.keySet() and Buyback__c = NULL]) {
			c.Buyback__c = relatedCases.get(c.ID).ID;
			casesToUpdate.add(c);
		}
		
		try {
			if(casesToUpdate.size() > 0)
				update casesToUpdate;
		} catch (DMLException e) {
	    	relatedCases.get(e.getDmlId(0)).addError('Exception occured while updating case BuyBack: ' + e.getMessage());
		}
	}
	
	if (caseToBBs.size() > 0) {
		//1.1 - Task Creation when VPP Claim # is populated
		List<Task> tasksToCreate = new List<Task>();
		Map<ID, Buyback__c> errorTasks = new Map<ID, Buyback__c>();
		for (Case c : [Select OwnerID, ContactID From Case WHERE ID in: caseToBBs.keySet()]) {
			Buyback__c[] bbs = caseToBBs.get(c.ID);
			for (Buyback__c b : bbs) {
		        Task t = new Task();
		        t.OwnerId = c.OwnerID;
		        t.Subject = 'Complete VPP Goodwill Process - ' + b.Name;
		        t.WhatID = c.Id;
		        t.ActivityDate = System.today();
		        t.Status = 'Not Started';
		        t.Priority = 'N/A';
		        t.WhoId = c.ContactID;
		        t.RecordTypeID = taskCART.Id;
		        
		        tasksToCreate.add(t);
		        errorTasks.put(t.ID, b);
			}
		}
		
		try {
			if(tasksToCreate.size() > 0)
				insert tasksToCreate;
		} catch (DMLException e) {
	    	errorTasks.get(e.getDmlId(0)).addError('Exception occured while create Complete VPP Goodwill Process task: ' + e.getMessage());
		}
	}
}