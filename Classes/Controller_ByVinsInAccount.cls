/**********************************************************************
Name: Controller_ByVinsInAccount
Copyright ¬© notice: Nissan Motor Company
======================================================
Purpose:
Controller of ByVINsInAccount page

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 01/16/2012 Created
***********************************************************************/
/*
Controller_ByVinsInAccount.DeleteVehicles('001Z0000001xPQs');
001Z0000002GYhF
Controller_ByVinsInAccount.DeleteVehicles('001Z0000001xPqu');
*/
public class Controller_ByVinsInAccount {
	private static final Integer BATCHSIZE = 10;
	public String ResponseOutput { get; set; }
	public Integer BatchNumber { get; set; }
	public Controller_ByVinsInAccount getThis() {return this;}
	private List<Vehicle_Ownership_History__c> allVehicles;
    private Account inputAccount;
	private String Title = 'Vehicle Related Records';
	
    public Controller_ByVinsInAccount(ApexPages.StandardController controller) {
    	BatchNumber = 1;
        inputAccount = [Select a.ID, 
        					(Select Owner__c, 
                                Vehicle__c, 
                                Vehicle__r.Vehicle_identification_Number__c,
	                            Vehicle__r.Last_Claim_Retrieve_Date__c,
	                            Vehicle__r.Last_Recall_Retrieve_Date__c,
	                            Vehicle__r.Last_RepairOrder_Retrieve_Date__c,
	                            Vehicle__r.Last_Warranty_Retrieve_Date__c,
	                            Vehicle__r.Last_VSC_Retrieve_Date__c,
	        					Primary_Owner_Indicator__c, Original_Owner_Indicator__c, Claimed_Owner_Indicator__c, 
	        					Current_Owner_Indicator__c
                            From Vehicle_Ownership_Historys__r) 
            From Account a 
            where ID =: controller.getRecord().ID];
            
        allVehicles = inputAccount.Vehicle_Ownership_Historys__r;
    }

	public PageReference doSearch() {
		ResponseOutput = '';
		
		if (allVehicles == null)
			return null;
		
		List<Service_Repair_History__c> SRHs = new List<Service_Repair_History__c>();
		List<Vehicle_Recall__c> VRs = new List<Vehicle_Recall__c>();
		List<Service_Repair_History__c> ROs = new List<Service_Repair_History__c>();
		List<Vehicle_Service_Contract__c> VSCs = new List<Vehicle_Service_Contract__c>();
		List<Generic_Text__c> wsComments = new List<Generic_Text__c>();
		List<Warranty_Information__c> WRTs = new List<Warranty_Information__c>();
		Boolean CL = false;
		Boolean RC = false;
		Boolean RO = false;
		Boolean VSC = false;
		Boolean WI = false;
		Map<ID, Vehicle__c> vehiclesToUpdate = new Map<ID, Vehicle__c>();
		
		//preparing ***************************
		List<Vehicle_Ownership_History__c> owners = new List<Vehicle_Ownership_History__c>();
		String stringList = '';
		Integer endNo = BATCHSIZE * BatchNumber, startNo = endNo - BATCHSIZE;
		Integer counts = allVehicles.size() > endNo ? endNo : allVehicles.size();
		for (Integer i = startNo; i < counts; i++) {
			stringList = Text_Util.valueConcatenation(allVehicles[i].Vehicle__r.Vehicle_identification_Number__c, stringList);
			owners.add(allVehicles[i]);
		}
		Title = 'Vehicle #' + String.ValueOf(startNo + 1) + '-' + counts + ': ' + stringList + '.';
		ResponseOutput = Title;
		
//Web Services ========================================

		//Claim call-out  ***************************
		Map<String, ID> mapVINs = new Map<String, ID>();
		for (Vehicle_Ownership_History__c v : owners) {
		    String vin = v.Vehicle__r.Vehicle_identification_Number__c;
		    if (!Text_Util.isSameDay(v.Vehicle__r.Last_Claim_Retrieve_Date__c) && vin != null && vin.length() > 0 && !mapVINs.containsKey(vin))
		        mapVINs.put(vin, v.Vehicle__c);
		}
		if (mapVINs.size() > 0) {
		    try {
		        Controller_ByVinsInAccount_Claims.callout(mapVINs, SRHs);
		    	CL = true;
		    } catch (CalloutException ex) {
		        ResponseOutput = ResponseOutput + ' Status: Claims CalloutException ' + ex.getMessage() + '.';
		    }
		}

		//Recall call-out ***************************
		mapVINs = new Map<String, ID>();
		for (Vehicle_Ownership_History__c v : owners) {
		    String vin = v.Vehicle__r.Vehicle_identification_Number__c;
		    if (!Text_Util.isSameDay(v.Vehicle__r.Last_Recall_Retrieve_Date__c) && vin != null && vin.length() > 0 && !mapVINs.containsKey(vin))
		        mapVINs.put(vin, v.Vehicle__c);
		}
		if (mapVINs.size() > 0) {
		    try {
		    	Controller_ByVinsInAccount_Recalls.callout(mapVINs, VRs);
		        RC = true;
		    } catch (CalloutException ex) {
		        ResponseOutput = ResponseOutput + ' Status: Recalls CalloutException ' + ex.getMessage() + '.';
		    }
		}

		//Repair Order call-out ***************************
		mapVINs = new Map<String, ID>();
		for (Vehicle_Ownership_History__c v : owners) {
		    String vin = v.Vehicle__r.Vehicle_identification_Number__c;
		    if (!Text_Util.isSameDay(v.Vehicle__r.Last_RepairOrder_Retrieve_Date__c) && vin != null && vin.length() > 0 && !mapVINs.containsKey(vin))
		        mapVINs.put(vin, v.Vehicle__c);
		}
		if (mapVINs.size() > 0) {
		    try {
		    	Controller_ByVinsInAccount_RepairOrders.callout(mapVINs, ROs);
		    	RO = true;
		    } catch (Controller_ByVinsInAccount_RepairOrders.NNACalloutException ex) {
		        ResponseOutput = ResponseOutput + 'Repair Orders NNACalloutException ' + ex.getMessage() + '.';
		    } catch (CalloutException ex) {
		        ResponseOutput = ResponseOutput + ' Status: Repair Orders CalloutException ' + ex.getMessage() + '.';
		    }
		}

		//VSC call-out ***************************
		mapVINs = new Map<String, ID>();
		Map<String, Vehicle_Ownership_History__c> mapOwners = new Map<String, Vehicle_Ownership_History__c>();
		for (Vehicle_Ownership_History__c v : owners) {
		    String vin = v.Vehicle__r.Vehicle_identification_Number__c;
		    if (!Text_Util.isSameDay(v.Vehicle__r.Last_VSC_Retrieve_Date__c) && vin != null && vin.length() > 0 && !mapVINs.containsKey(vin)) {
		        mapVINs.put(vin, v.Vehicle__c);
		        mapOwners.put(vin, v);
		    }
		}
		if (mapVINs.size() > 0) {
		    try {
		    	Controller_ByVinsInAccount_VSC.callout(mapVINs, mapOwners, VSCs, wsComments);
		    	VSC = true;
		    } catch (CalloutException ex) {
		        ResponseOutput = ResponseOutput + ' Status: Vehicle Service Contracts CalloutException ' + ex.getMessage() + '.';
		    }
		}
		
		//Warranty call-out ***************************
		mapVINs = new Map<String, ID>();
		for (Vehicle_Ownership_History__c v : owners) {
		    String vin = v.Vehicle__r.Vehicle_identification_Number__c;
		    if (!Text_Util.isSameDay(v.Vehicle__r.Last_Warranty_Retrieve_Date__c) && vin != null && vin.length() > 0 && !mapVINs.containsKey(vin))
		        mapVINs.put(vin, v.Vehicle__c);
		}
		if (mapVINs.size() > 0) {
		    try {
		    	Controller_ByVinsInAccount_Warranties.callout(mapVINs, WRTs);
		    	WI = true;
		    } catch (CalloutException ex) {
		        ResponseOutput = ResponseOutput + ' Status: Warranties CalloutException ' + ex.getMessage() + '.';
		    }
		}
        
//DML ========================================
        
        //Claim upsert ***************************
        try {
        	if (CL) {
        		Controller_ByVinsInAccount_Claims.dmlOperations(SRHs);
        		
		    	for (Service_Repair_History__c v : SRHs) {
	        		Vehicle__c vehicle = mapVehicleByID(v.Vehicle_ID__c, vehiclesToUpdate);
					vehicle.Last_Claim_Retrieve_Date__c = datetime.now();
		    	}
        	}
        } catch (DMLException ex) {
            ResponseOutput = ResponseOutput + ' Status: Claims DMLException ' + ex.getMessage() + '.';
           	CL = false;
        }

        //Recall upsert ***************************
        try {
        	if (RC) {
        		Controller_ByVinsInAccount_Recalls.dmlOperations(VRs);
        		
		    	for (Vehicle_Recall__c v : VRs) {
	        		Vehicle__c vehicle = mapVehicleByID(v.Vehicle__c, vehiclesToUpdate);
					vehicle.Last_Recall_Retrieve_Date__c = datetime.now();
		    	}
        	}
        } catch (DMLException ex) {
            ResponseOutput = ResponseOutput + ' Status: Recalls DMLException ' + ex.getMessage() + '.';
            RC = false;
        }
        
        //Repair Order upsert ***************************
        try {
        	if (RO) {
        		Controller_ByVinsInAccount_RepairOrders.dmlOperations(ROs);
        		
		    	for (Service_Repair_History__c v : ROs) {
	        		Vehicle__c vehicle = mapVehicleByID(v.Vehicle_ID__c, vehiclesToUpdate);
					vehicle.Last_RepairOrder_Retrieve_Date__c = datetime.now();
		    	}
        	}
        } catch (DMLException ex) {
            ResponseOutput = ResponseOutput + ' Status: Repair Orders DMLException ' + ex.getMessage() + '.';
            RO = false;
        }

        //VSC upsert ***************************
        try {
        	if (VSC) {
        		Controller_ByVinsInAccount_VSC.dmlOperations(VSCs, wsComments);
        		
		    	for (Vehicle_Service_Contract__c v : VSCs) {
	        		Vehicle__c vehicle = mapVehicleByID(v.Vehicle_Id__c, vehiclesToUpdate);
					vehicle.Last_VSC_Retrieve_Date__c = datetime.now();
		    	}
        	}
        } catch (DMLException ex) {
            ResponseOutput = ResponseOutput + ' Status: Vehicle Service Contracts  DMLException ' + ex.getMessage() + '.';
            VSC = false;
        }
        
        //Warrranty upsert ***************************
        try {
        	if (WI) {
        		Controller_ByVinsInAccount_Warranties.dmlOperations(WRTs);
        		Vehicle__c vehicle;
        		Map<String, DateTime> latestDates = new Map<String,DateTime>();	    	

		    	for (Warranty_Information__c v : WRTs) {
		    		if ((!latestDates.containsKey(v.Vehicle_ID__c) && v.Source_Last_Update_Date__c != null) || 
		    		    	v.Source_Last_Update_Date__c > latestDates.get(v.Vehicle_ID__c)) {
		    			latestDates.put(v.Vehicle_ID__c, v.Source_Last_Update_Date__c);
	    				vehicle = mapVehicleByID(v.Vehicle_ID__c, vehiclesToUpdate);
	    				vehicle.Last_Warranty_Retrieve_Date__c = datetime.now();
		    		} else if (!latestDates.containsKey(v.Vehicle_ID__c) && v.Source_Last_Update_Date__c == null) {
		    			vehicle = mapVehicleByID(v.Vehicle_ID__c, vehiclesToUpdate);
		    		}
		    	}
        	}
        } catch (DMLException ex) {
            ResponseOutput = ResponseOutput + ' Status: Warranties DMLException ' + ex.getMessage() + '.';
            WI = false;
        }
        
//Update Vehicle Last Retrieve Date ========================================
        try {
        	if (vehiclesToUpdate.size() > 0)
            	update vehiclesToUpdate.values();
        	if (CL && RC && RO && VSC && WI)
        		ResponseOutput = ResponseOutput + ' Status: Successful.';
        } catch (DMLException ex) {
            ResponseOutput = ResponseOutput + ' Status: Update Vehicle DMLException ' + ex.getMessage() + '.';
        }
        
        return null;
	}	

	private Vehicle__c mapVehicleByID(ID vid, Map<ID, Vehicle__C> vehiclesToUpdate) {
		Vehicle__c vehicle;
		if (vehiclesToUpdate.containsKey(vid))
			vehicle = vehiclesToUpdate.get(vid);
		else {
			vehicle = new Vehicle__c(ID = vid);
			vehiclesToUpdate.put(vid, vehicle);
		}
		
		return vehicle;
	}
   	
    /**
    	test Controller_ByVinsInAccount
    */
    static testMethod void testByVinsInAccount() {
    	ByVinsInAccount_TestUtil.TestData();
    	Test.startTest();
    	Controller_ByVinsInAccountComponent component = new Controller_ByVinsInAccountComponent();
    	
    	Controller_ByVinsInAccount controller = new Controller_ByVinsInAccount(new ApexPages.StandardController(ByVinsInAccount_TestUtil.testAccount));
    	
    	component.ByVinsInAccountController = controller.getThis();
    	System.Debug(component.ByVinsInAccountController);
    	
    	component.BatchNumber = 1;
    	
    	component.ResponseOutput = 'There is error';
    	System.Debug(component.ResponseOutput);
    	
    	component.doSearch();

    	Test.stopTest();
    	/*
	    //test Controller_ByVinsInAccount_Claims
    	List<Service_Repair_History__c> claims = [Select Vehicle_Identification_Number__c, Vehicle_ID__c, Dealer_ID__c From Service_Repair_History__c Where Vehicle_Identification_Number__c in: testVINs];
    	System.assert(claims.size() == 1);
    	for (Service_Repair_History__c c : claims) {
    		System.assert(c.Vehicle_ID__c == testVehicles[1].ID);
    		System.assert(c.Dealer_ID__c == testDealer.ID);
    	}

	    //test Controller_ByVinsInAccount_Recalls
    	List<Master_Recall_Campaign__c> masters = [Select Dealer__c, TSB_Number__c, Recall_Identifier__c From Master_Recall_Campaign__c Where Recall_Identifier__c = 'RC0!!'];
    	System.assert(masters.size() == 1);
    	for (Master_Recall_Campaign__c m : masters) {
    		System.assert(m.Dealer__c == testDealer.ID);
    		System.assert(m.TSB_Number__c == 'ITB10-YYY');
    	}
		
    	List<Vehicle_Recall__c> recalls = [Select Vehicle_Identification_Number__c, Vehicle__c, Dealer__c, TSB_Number__c, Recall_Identifier__c, Master_Recall_Campaign__c From Vehicle_Recall__c Where Vehicle_Identification_Number__c in: testVINs];
    	System.assert(recalls.size() == 1);
    	for (Vehicle_Recall__c r : recalls) {
    		System.assert(r.Vehicle__c == testVehicles[1].ID);
    		System.assert(r.Dealer__c == testDealer.ID);
    		System.assert(r.TSB_Number__c == 'ITB10-YYY');
    		System.assert(r.Master_Recall_Campaign__c == masters[0].ID);
    	}

	    //test Controller_ByVinsInAccount_RepairOrders: getRepairOrders	
    	List<Service_Repair_History__c> claims = [Select Vehicle_Identification_Number__c, Vehicle_ID__c, Dealer_ID__c, Primary_Operation_Code__c From Service_Repair_History__c Where Vehicle_Identification_Number__c in: testVINs];
    	System.assert(claims.size() == 1);
    	for (Service_Repair_History__c c : claims) {
    		System.assert(c.Vehicle_ID__c == testVehicles[1].ID);
    		System.assert(c.Dealer_ID__c == testDealer.ID);
    		System.assert(c.Primary_Operation_Code__c == 'OpCode1 OpCode2');
    	}

	    //test Controller_ByVinsInAccount_VSC	
    	List<Vehicle_Service_Contract__c> VSCs = [Select VIN__c, Vehicle_ID__c, Dealer__c, Account_Id__c From Vehicle_Service_Contract__c Where VIN__c in: testVINs];
    	System.assert(VSCs.size() == 1);
    	for (Vehicle_Service_Contract__c v : VSCs) {
    		System.assert(v.Vehicle_ID__c == testVehicles[1].ID);
    		System.assert(v.Dealer__c == testDealer.ID);
    		System.assert(v.Account_Id__c == testAccount.ID);
    	}
    	
    	List<Generic_Text__c> comments = [Select VIN__c, Line_Number__c, Comment_Text__c From Generic_Text__c Where VIN__c in: testVehicles];
    	System.assert(comments.size() == 2);
    	System.assert(comments[0].Comment_Text__c == 'CommentText1 In WS');

	    //test Controller_ByVinsInAccount_Warranties	
    	List<Warranty_Information__c> warranties = [Select Vehicle_Identification_Number__c, Vehicle_ID__c From Warranty_Information__c Where Vehicle_Identification_Number__c in: testVINs];
    	System.assert(warranties.size() == 3);
    	for (Warranty_Information__c w : warranties)
    		System.assert(w.Vehicle_ID__c == testVehicles[1].ID);*/
    }
}