/**********************************************************************
Name: Account_After_Lead_Migration
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Migrate objects linked to Leads to the inserted/updated
Account objects associated with them.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 05/02/2011 Created
***********************************************************************/
trigger Account_After_LeadMigration on Account (after insert, after update) {
    // Get List of customer ids
    Map<String,Id> customerIdMap = new Map<String,Id>();
    for (Account acct :Trigger.new) {
        if (acct.customer_ID__c != null)
            customerIdMap.put(acct.Customer_ID__c, acct.Id);
    }
    
    // Use new customer ids to look up Lead rows and create a Map of Customer_Id__c to Lead.id
    List<Lead> leadList = [select id, customer_id__c 
                           from Lead
                           where Customer_Id__c in :customerIdMap.keySet()];
                           
    Map<Id,Lead> leadMap = new Map<Id,Lead>();
    for (Lead lead : leadList)
        leadMap.put(lead.id, lead);
    
    // Use new customer ids to look up Contact Ids and create a Map of Customer_Id__c to Contact.id
    List<Account> accounts = [select Id, PersonContactId 
                              from Account 
                              where Customer_Id__c in :customerIdMap.keySet()];
                                
    Map<String,Id> contactMap = new Map<String,Id>();
    for(Account acct :accounts) {
        contactMap.put(acct.id, acct.PersonContactId);
    }
    
    // Get brochure requests and migrate Lead lookup to Account lookup
    List<Brochure_Request__c> requests = [select Id, Account_Name__c, Lead_Name__c 
                                    from Brochure_Request__c 
                                    where Lead_Name__c in :leadMap.keySet()];
    
    for (Brochure_Request__c request :requests) {
        request.Account_Name__c = customerIdMap.get(leadMap.get(request.Lead_Name__c).Customer_Id__c);
        request.Lead_Name__c = null;
    }
    
    // Get dealer quotes requests and migrate Lead lookup to Account lookup
    List<Dealer_Quotes_Request__c> dqrs = [select Id, Account__c, Lead__c 
                                           from Dealer_Quotes_Request__c 
                                           where Lead__c in :leadMap.keySet()];
    
    for (Dealer_Quotes_Request__c dqr :dqrs) {
        dqr.Account__c = customerIdMap.get(leadMap.get(dqr.Lead__c).Customer_Id__c);
        dqr.Lead__c = null;
    }

    // Get Tasks and migrate Lead ids to contact ids
    List<Task> tasks = [select Id, WhoId 
                        from Task 
                        where WhoId in :leadMap.keySet()];
    
    for (Task task :tasks) {
        task.WhoId = contactMap.get(customerIdMap.get(leadMap.get(task.WhoId).Customer_Id__c));
    }

    // Get usernames and migrate Lead lookup to Account lookup
    List<Username__c> usernames = [select Id, Customer_Name__c, Lead_Name__c 
                             from Username__c 
                             where Lead_Name__c in :leadMap.keySet()];
    
    for (Username__c username :usernames) {
        username.Customer_Name__c = customerIdMap.get(leadMap.get(username.Lead_Name__c).Customer_Id__c);
        username.Lead_Name__c = null;
    }
    
    // Update lists of related objects
    update requests;
    update dqrs;
    update tasks;
    update usernames;
}