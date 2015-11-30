/**********************************************************************
Name: DeleteInactiveImagesBatchController
Copyright � notice: NMAC.
======================================================
Purpose:
This is batch job to find all unused Image Proxies -> Documents and delete them

======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/22/2015 Created 
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev 
***********************************************************************/
global class DeleteInactiveImagesBatchController implements Database.Batchable<sObject> {
	private final String QUERY = 'SELECT Id, Link__c, (SELECT Id FROM Ws_Tabs_Home__r), (SELECT Id FROM Ws_Tabs_Home1__r), (SELECT Id FROM Ws_Tab_Presentation_Items__r) FROM Image_Proxy__c';
	private List<Image_Proxy__c> dpToDelete {get; set;}
	private Set<Id> docsToDeleteIds  {get; set;}

	global DeleteInactiveImagesBatchController() {
		dpToDelete = new List<Image_Proxy__c>();
		docsToDeleteIds = new Set<Id>();
		}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		for(Image_Proxy__c d : (List<Image_Proxy__c>) scope){

			if(d.Ws_Tabs_Home__r.isEmpty()){
				if(d.Ws_Tabs_Home1__r.isEmpty()){
					if(d.Ws_Tab_Presentation_Items__r.isEmpty()){
						dpToDelete.add(d);
						if(d.Link__c.substringBetween('id=', '&oid') != null){
							if(d.Link__c.substringBetween('id=', '&oid').length() >= 15 ){ //prevention from wrong id here
								docsToDeleteIds.add(Id.valueOf(d.Link__c.right(18)));
							} 
						}
					}
				}
			}

		}
		if(dpToDelete.size() > 0){
			delete dpToDelete;
		}

		List<Document> docs = [SELECT ID FROM Document WHERE Id in : docsToDeleteIds];
		if(docs.size() > 0){
			delete docs;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
}