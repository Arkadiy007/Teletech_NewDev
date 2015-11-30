/**********************************************************************
Name: VehicleRetailSale_After_Insert_Batch 
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
This trigger calls batch apex class to update few of its fields.

Related Apex Class: Vehicle_Retail_Sale_Batch
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Sonali Bhardwaj 03/16/2011 Created            
***********************************************************************/

trigger VehicleRetailSale_After_Insert_Batch on Vehicle_Retail_Sale__c (after insert) {
	List<String> dealerCodes = new List<String>();
	List<String> customerIds = new List<String>();
	List<String> VINs = new List<String>();
	List<Id> vehicleRetailSaleIds = new List<Id>();
	
	for (Vehicle_Retail_Sale__c rec : Trigger.new) {
		if (rec.External_Owner_Id__c != null)
			customerIds.add(rec.External_Owner_Id__c);
		if (rec.External_Selling_Dealer_Name__c != null)
			dealerCodes.add(rec.External_Selling_Dealer_Name__c);	
		if (rec.External_Vehicle_Identification_Number__c  != null)
			VINs.add(rec.External_Vehicle_Identification_Number__c );
	}
	
	List<Account> personAccounts = [Select Customer_ID__c, id from Account where Customer_ID__c in :customerIds];
	List<Account> businessAccounts = [Select Dealer_Code__c, id from Account where Dealer_Code__c in :dealerCodes];
	List<Vehicle__c> vehicles = [Select Vehicle_Identification_Number__c, id from Vehicle__c where Vehicle_Identification_Number__c in :VINs];	
	
	Map<Id, Vehicle_Retail_Sale_Batch.Vehicle_Retail_Sale_Data> dataMap = new Map<Id, Vehicle_Retail_Sale_Batch.Vehicle_Retail_Sale_Data>();
	
	for (Vehicle_Retail_Sale__c rec : Trigger.new) {
		Vehicle_Retail_Sale_Batch.Vehicle_Retail_Sale_Data data = new Vehicle_Retail_Sale_Batch.Vehicle_Retail_Sale_Data();
		for (Account personAccount : personAccounts) {
			if (rec.External_Owner_Id__c == personAccount.Customer_ID__c) {
				data.ownerId = personAccount.id;
				break;
			}
		}
		
		for (Account businessAccount : businessAccounts) {
			if (rec.External_Selling_Dealer_Name__c == businessAccount.Dealer_Code__c) {
				data.dealerName = businessAccount.Id;
				break;
			}
		}
		
		for (Vehicle__c vehicle : vehicles) {
			if (rec.External_Vehicle_Identification_Number__c == vehicle.Vehicle_Identification_Number__c) {
				data.VIN = vehicle.id;
				break;
			}
		}
		dataMap.put(rec.id, data);
		vehicleRetailSaleIds.add(rec.id);
	}
	
	String query = 'Select Id from Vehicle_Retail_Sale__c where id in (';
	Integer i = 1;
	for (Id id : vehicleRetailSaleIds) {
		if (i == vehicleRetailSaleIds.size())
			query = query + '\''+ id + '\''+ ' )';
		else
			query = query + '\''+ id + '\''+ ', ';
		i++;
	}
	
	id batchinstanceid = database.executeBatch(new Vehicle_Retail_Sale_Batch(query, dataMap), 1200000); 
}