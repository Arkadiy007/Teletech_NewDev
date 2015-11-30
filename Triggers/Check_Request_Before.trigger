/**********************************************************************
Name: Check_Request_Before
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
Set Stage_Status__c value on the Check Request appropriately
when it is inserted or updated so it will be picked
up by batch processing.
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 -  Bryan Fry        10/21/2011 Created
1.1 -  Yuli Fintescu    02/09/2012 No new check requests after case is closed
***********************************************************************/
trigger Check_Request_Before on Check_Request__c (before insert, before update) {
    Map<Id, Check_Request__c> checkRequestMap = new Map<Id, Check_Request__c>();
    Map<Id, Case> caseMap = new Map<Id, Case>();
    List<Case> cases = new List<Case>();
    Set<Case> updateCases = new Set<Case>();
    List<Case> updateCasesList = new List<Case>();
    
    for (Check_Request__c cr: Trigger.new) {
        checkRequestMap.put(cr.Case__c, cr);
    }
    
    cases = [select Id, Stage_Status__c, IsClosed from Case where Id in :checkRequestMap.keySet()];
    if(System.label.TurnOffStageStatus != 'Yes') {
        for(Case c: cases) {
            caseMap.put(c.Id, c);
        }
        
        for (Check_Request__c cr: Trigger.new) {
            if (cr.Stage_Status__c != System.label.Stage_Status_Never) {
                Case c = caseMap.get(cr.Case__c);
                
                // Batch processing sets state to done, this trigger sets state
                // back to initial in that case.
                if (cr.Stage_Status__c == System.Label.Stage_Status_Done  || cr.Stage_Status__c == System.Label.Stage_Status_Extracted  || cr.Stage_Status__c == System.Label.Stage_Status_Acknowledged  ){
                //  cr.Stage_Status__c = System.Label.Stage_Status_None;
                } 

                // Otherwise this is not a change as a result of batch processing
                // so set state to indicate a change has been made and needs to be
                // processed. If this is an insert, indicate this will be an Add.
                else if (Trigger.isInsert) {
                    cr.Stage_Status__c = System.Label.Stage_Status_Add;
                    if (c.Stage_Status__c != System.Label.Stage_Status_Add) {
                        c.Stage_Status__c = System.Label.Stage_Status_Update;
                        updateCases.add(c);
                    }
                }
                // If this is an update, we need to indicate it is an Update unless
                // the record is already flagged as an Add, meaning it was created
                // since the last time the batch process ran and should be reported
                // as an Add even with the updated changes being made.
                else if (Trigger.isUpdate && cr.Stage_Status__c != System.Label.Stage_Status_Add) {
                    cr.Stage_Status__c = System.Label.Stage_Status_Update;
                    if (c.Stage_Status__c != System.Label.Stage_Status_Add) {
                        c.Stage_Status__c = System.Label.Stage_Status_Update;
                        updateCases.add(c);
                    }
                }
            }
        }
        
        updateCasesList.addAll(updateCases);
        
        update updateCasesList;
    }
    
    // Check Requests cannot be added to a closed case.
    if (Trigger.isInsert && system.label.TurnOffValidation != 'Yes') {
        Map<ID, Case> mapCases = new Map<ID, Case>(cases);
        for (Check_Request__c t: Trigger.new) {
            if (mapCases.containsKey(t.Case__c) && mapCases.get(t.Case__c).IsClosed)
                t.addError('Check Requests cannot be added to a closed case.');
        }
    }
}