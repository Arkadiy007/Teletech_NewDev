trigger recordMerge_Before on MergeRelationships__c (before insert, before update) {
	// Update Survivor Salesforce ID
    Set<String> customerIds = new Set<String>();
    
    // Construct a Set of Customer_IDs from the Merge Relationships input through Trigger.new
    for (MergeRelationships__c mRel : Trigger.new) {
        if (mRel.survivorID__c != null)
            customerIds.add(mRel.survivorID__c);
    }  

    List<Account> accList = new List<Account>([select id, Customer_ID__c
                                               from Account 
                                               where Customer_ID__c  in: customerIds]);
    
    Map<String,Id> customerIdMap = new Map<String,Id>();
    for (Account acct : accList) {
        customerIdMap.put(acct.Customer_ID__c, acct.Id);
    }
    
    // Loop through Models of Interest in Trigger.new and set the Account__c for each
    for (MergeRelationships__c mRel : Trigger.new) {
        mRel.Survivor_Account__c = customerIdMap.get(mRel.survivorID__c);
    }
    
    // Update Child Salesforce ID
    customerIds = new Set<String>();
    
    // Construct a Set of Customer_IDs from the Merge Relationships input through Trigger.new
    for (MergeRelationships__c mRel : Trigger.new) {
        if (mRel.childID__c != null)
            customerIds.add(mRel.childID__c);
    }  

    accList = new List<Account>([select id, Customer_ID__c
                                               from Account 
                                               where Customer_ID__c  in: customerIds]);
    
    customerIdMap = new Map<String,Id>();
    for (Account acct : accList) {
        customerIdMap.put(acct.Customer_ID__c, acct.Id);
    }
    
    // Loop through Models of Interest in Trigger.new and set the Account__c for each
    for (MergeRelationships__c mRel : Trigger.new) {
        mRel.Child_Account__c = customerIdMap.get(mRel.childID__c);
    } 
}