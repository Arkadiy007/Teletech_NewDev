/**********************************************************************
Name: Vehicle_Trigger_Test 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
This class contains unit tests for validating the behavior of "Vehicle" Apex Trigger.

Related to: BuyBack Trigger
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Yuli Fintescu 02/04/2012 Created
***********************************************************************/
@isTest
private class Vehicle_Trigger_Test {

    static testMethod void Vehicle_SyncNameVINTest() {
    	System.Debug('***** Vehicle_SyncNameVINTest *****');
    	
    	List<Vehicle__c> testVehicles = new List<Vehicle__c> {new Vehicle__c(Name = '**VehicleName**'),
        													new Vehicle__c(Vehicle_Identification_Number__c = '**VehicleVIN**')};
        //sync when insert
        test.startTest();
        insert testVehicles;
        
        for (Vehicle__c v : [Select Name, Vehicle_Identification_Number__c From Vehicle__c Where ID in: testVehicles])
        	System.assert(v.Vehicle_Identification_Number__c == v.Name);
    }
    /*
        //sync when update
        testVehicles[0].Name = '**VehicleDiffName';
        testVehicles[1].Vehicle_Identification_Number__c = '**VehicleDiffVIN';
        update testVehicles;
        for (Vehicle__c v : [Select Name, Vehicle_Identification_Number__c From Vehicle__c Where ID in: testVehicles]) {
        	System.assert(v.Vehicle_Identification_Number__c.contains('**VehicleDiff'));
        	System.assert(v.Vehicle_Identification_Number__c == v.Name);
        }
        
        //behavior when update null values
        testVehicles[0].Name = null;
        testVehicles[1].Vehicle_Identification_Number__c = null;
        update testVehicles;
        List<Vehicle__c> vehicles = [Select Name, Vehicle_Identification_Number__c From Vehicle__c Where ID in: testVehicles];
        System.assert(vehicles[0].Vehicle_Identification_Number__c == null);
        System.assert(vehicles[1].Vehicle_Identification_Number__c == '**VehicleDiffVIN');
        
        test.stopTest();
    }

    static testMethod void Vehicle_UpdateNameTest() {
    	System.Debug('***** Vehicle_UpdateNameTest *****');
    	Vehicle__c testVehicle = new Vehicle__c(Name = '**VehicleName**');
        insert testVehicle;
        
		Case c = new Case(Vehicle_Name__c = testVehicle.Id);
		insert c;
		Buyback__c b = new Buyback__c(Vehicle__c = testVehicle.Id, Case__c = c.Id);
		insert b;
        
        test.startTest();
        testVehicle.Name = '**VehicleDiffName';
        update testVehicle;
        test.stopTest();
        
		//test buyback_after trigger
		c = [Select Buyback__c From Case WHERE ID =: c.ID];
		System.assert(c.Buyback__c == b.ID);
    }
*/
}