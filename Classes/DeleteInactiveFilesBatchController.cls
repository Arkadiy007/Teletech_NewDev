/**********************************************************************
Name: DeleteInactiveFilesBatchController
Copyright � notice: NMAC.
======================================================
Purpose:
This is batch job to find all unused Document Proxies -> Documents and delete them
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/22/2015 Created
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev 
***********************************************************************/
global class DeleteInactiveFilesBatchController implements Database.Batchable<sObject> {	
	private final String QUERY = 'SELECT Id, Link__c, (SELECT Id, Document__c FROM Ws_Tab_Presentation_Items__r), (SELECT Id, Document__c FROM Footers__r), (SELECT Id, Document__c FROM Ws_Tab_Abs_Line_Items__r), (SELECT Id, Document__c FROM Ws_Tab_Quarterly_Data_Item__r) FROM Document_Proxy__c';
	private List<Document_Proxy__c> dpToDelete {get; set;}
	private Set<Id> docsToDeleteIds  {get; set;}

	global DeleteInactiveFilesBatchController() {
		dpToDelete = new List<Document_Proxy__c>();
		docsToDeleteIds = new Set<Id>();
		}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		for(Document_Proxy__c d : (List<Document_Proxy__c>) scope){

			if(d.Ws_Tab_Abs_Line_Items__r.isEmpty()){
				if(d.Ws_Tab_Presentation_Items__r.isEmpty()){
					if(d.Ws_Tab_Quarterly_Data_Item__r.isEmpty()){
						if(d.Footers__r.isEmpty()){
							dpToDelete.add(d);
							if(d.Link__c.right(18).length() >= 18 ){ //prevention from wrong id here
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