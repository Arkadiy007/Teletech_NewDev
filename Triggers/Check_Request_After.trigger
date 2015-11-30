//AAB - 01/19/2015 - Update to trigger second approval process

trigger Check_Request_After on Check_Request__c (after update) {
	RecordType taskCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Task' limit 1];
    //AAB Added First_Approver__c
    List<Check_Request__c> checks = [Select ID, Status__c, Case__c, Case__r.ContactID, CreatedById, First_Approver__c From Check_Request__c Where ID in: Trigger.new];
    
    List<Check_Request__c> approved = new List<Check_Request__c>();
    List<Check_Request__c> rejected = new List<Check_Request__c>();
    Check_Request__c old;
    //AAB List of Approvers
    List<Id> nextApprovers;
    Map<Id, Id> availableApprovers = new Map<Id,Id>();
    Map<Id, Id> unapprovedApprovers;
    
    List<Group> approversQueues = [Select Id from Group where type='Queue' and Name='Segment Z Approvers'];
    List<GroupMember> members;
    if(approversQueues!=null && approversQueues.size()>0)
    {
        members = [Select UserOrGroupId From GroupMember where GroupId =:approversQueues[0].Id];
        
        for(GroupMember member : members)
        {
            availableApprovers.put(member.UserOrGroupId, member.UserOrGroupId);
        }
    }
    
    List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();

    
    for (Check_Request__c c :checks) {
        old = Trigger.oldMap.get(c.ID);        
        if (c.Status__c == 'Approved' && old.Status__c != 'Approved')
            approved.add(c);
            
        if (c.Status__c == 'Denied' && old.Status__c != 'Denied')
            rejected.add(c);
        
        //AAB - Code block to start the second approval process
        if(old.First_Approver__c == null && c.First_Approver__c!=null)
        {
            nextApprovers = new List<Id>();
            unapprovedApprovers = availableApprovers.clone();
            unapprovedApprovers.remove(UserInfo.getUserId());
            for(String key : unapprovedApprovers.keySet())
            {
               nextApprovers.add(key);
                
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();             
                req.setComments('First Approval completed, moving to second approver.');             
                req.setObjectId(c.Id);   
                system.debug(nextApprovers.size());
                req.setNextApproverIds(new List<Id>{key});
                req.setProcessDefinitionNameOrId('Second_Approver_for_Seg_Z');
                requests.add(req); 
            }
        }
    }
    
    if(requests.size()>0)
    {
           List<Approval.ProcessResult> results = Approval.process(requests);
    }
    
    List<Task> tasksToCreate = new List<Task>();
    if (approved.size() > 0) {
        for (Check_Request__c c : approved) {
            Task t = new Task();
            t.OwnerId = c.CreatedById;
            t.Subject = 'Review Approved Check Request';
            t.WhatID = c.Case__c;
            t.ActivityDate = System.today();
            t.Status = 'Not Started';
            t.Priority = 'N/A';
            t.WhoId = c.Case__r.ContactID;
            t.RecordTypeID = taskCART.Id;
            
            tasksToCreate.add(t);
        }
    }
    
    if (rejected.size() > 0) {
        for (Check_Request__c c : rejected) {
            Task t = new Task();
            t.OwnerId = c.CreatedById;
            t.Subject = 'Review Rejected Check Request';
            t.WhatID = c.Case__c;
            t.ActivityDate = System.today();
            t.Status = 'Not Started';
            t.Priority = 'N/A';
            t.WhoId = c.Case__r.ContactID;
            t.RecordTypeID = taskCART.Id;
            
            tasksToCreate.add(t);
        }
    }
    
    if (tasksToCreate.size() > 0)
        insert tasksToCreate;
}