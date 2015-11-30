/**********************************************************************
Name: Account_Vehicle_Recall
Copyright © notice: Nissan Motor Company
======================================================
Purpose: Look up any open vehicle recalls for an Account
in order to display a message with that information to
an agent in a Visualforce page.

Related Page : VehicleRecallByVINsInAccount 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 10/07/2011 Created
***********************************************************************/

public with sharing class Account_Vehicle_Recall {
	private String accountId;
	public String recallMessage {
		get;set;
	}

	/* Save the AccountId passed in for the record being used */
    public Account_Vehicle_Recall (ApexPages.StandardController controller) {
		accountId = controller.getRecord().Id;
    }

	/* Determine if the account passed in has an open recalls for Vehicles associated with it.
	   Set the recallMessage to be displayed on the VisualForce page. */
    public void doLookupRecalls() {
    	List<Vehicle_Ownership_History__c> vehicleRecalls = [select id, Vehicle__c 
    	                                                     from Vehicle_Ownership_History__c 
    	                                                     where Owner__c = :accountId 
    	                                                     and Vehicle__r.Open_Recall__c = true];

		if (vehicleRecalls.size() > 0) {
			recallMessage = System.Label.Vehicle_Recall_Message;
		} else {
			recallMessage = '';
		}
    }
}