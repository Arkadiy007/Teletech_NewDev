@isTest
private class WarrantyCaseRestTests {



	@isTest static void validResponseWillInsertOneSurvey() {
		System.assertEquals(0, [SELECT Count() FROM Warranty_Case__c]);
		System.assertEquals(0, [SELECT Count() FROM Case]);
		Test.startTest();
		WarrantyCaseRest.ResponseWrapper response = WarrantyCaseRest.createCases(formJSONMessageCvt(TRUE));
		Test.stopTest();
		System.assertEquals(1, [SELECT Count() FROM Warranty_Case__c]);
		System.assertEquals(200, response.code);
		System.assertEquals('success', response.status);
	}

	@isTest static void validJSONMsgWillInsertOneSurvey() {
		WarrantyCaseRest.RequestWrapper request = formJSONMessageLeaf(TRUE);
		String jsonMsg = JSON.serialize(request);

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/warrantyCase/api/v1/case'; //Request URL
		req.httpMethod = 'POST'; //HTTP Request Type
		req.requestBody = Blob.valueof(jsonMsg);
		RestContext.request = req;
		RestContext.response = res;

		System.assertEquals(0, [SELECT Count() FROM Warranty_Case__c]);
		System.assertEquals(0, [SELECT Count() FROM Case]);
		Test.startTest();
		WarrantyCaseRest.ResponseWrapper response = WarrantyCaseRest.createCases(request);
		Test.stopTest();
		System.assertEquals(1, [SELECT Count() FROM Warranty_Case__c]);
		System.assertEquals(200, response.code);
		System.assertEquals('success', response.status);
	}


	@isTest static void validResponseWillInsertMultipleSurvey() {
		System.assertEquals(0, [SELECT Count() FROM Warranty_Case__c]);
		System.assertEquals(0, [SELECT Count() FROM Case]);
		Test.startTest();
		List<WarrantyCaseRest.ResponseWrapper> responses = WarrantyCasesRest.createCases(formJSONArrayMessage(TRUE));
		Test.stopTest();

		System.assertEquals(20, [SELECT Count() FROM Warranty_Case__c]);

		for (WarrantyCaseRest.ResponseWrapper response : responses) {
			System.assertEquals(200, response.code);
			System.assertEquals('success', response.status);
		}
	}

	@isTest static void validJSONMsgWillInsertMultipleSurvey() {
		List<WarrantyCaseRest.RequestWrapper> request = formJSONArrayMessage(TRUE);
		String jsonMsg = JSON.serialize(request);

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/warrantyCase/api/v1/case'; //Request URL
		req.httpMethod = 'POST'; //HTTP Request Type
		req.requestBody = Blob.valueof(jsonMsg);
		RestContext.request = req;
		RestContext.response = res;

		System.assertEquals(0, [SELECT Count() FROM Warranty_Case__c]);
		System.assertEquals(0, [SELECT Count() FROM Case]);
		Test.startTest();
		List<WarrantyCaseRest.ResponseWrapper> responses = WarrantyCasesRest.createCases(request);
		Test.stopTest();

		System.assertEquals(20, [SELECT Count() FROM Warranty_Case__c]);

		for (WarrantyCaseRest.ResponseWrapper response : responses) {
			System.assertEquals(200, response.code);
			System.assertEquals('success', response.status);
		}
	}


	private static WarrantyCaseRest.RequestWrapper formJSONMessageEngine(Boolean isValid) {
		WarrantyCaseRest.RequestWrapper request = new WarrantyCaseRest.RequestWrapper();
		request.token = Label.Warranty_Case_Integration_Security_Token;

		if (isValid) {
			request.Customer_Name = 'Test Customer';
			request.techNameFirstLast = 'Test Technician';
		}

		return request;
	}
	private static WarrantyCaseRest.RequestWrapper formJSONMessageLeaf(Boolean isValid) {
		WarrantyCaseRest.RequestWrapper request = new WarrantyCaseRest.RequestWrapper();
		request.token = Label.Warranty_Case_Integration_Security_Token;

		if (isValid) {
			request.Customer_Name = 'Test Customer';
			request.techNameFirstLast = 'Test Technician';
		}

		return request;
	}
	private static WarrantyCaseRest.RequestWrapper formJSONMessageCvt(Boolean isValid) {
		WarrantyCaseRest.RequestWrapper request = new WarrantyCaseRest.RequestWrapper();
		request.token = Label.Warranty_Case_Integration_Security_Token;

		if (isValid) {
			request.Customer_Name = 'Test Customer';
			request.techNameFirstLast = 'Test Technician';
		}

		return request;
	}

	private static List<WarrantyCaseRest.RequestWrapper> formJSONArrayMessage(Boolean isValid) {
		List<WarrantyCaseRest.RequestWrapper> requests = new List<WarrantyCaseRest.RequestWrapper> ();
		for (Integer i = 0; i < 20; i++) {
			WarrantyCaseRest.RequestWrapper request = formJSONMessageEngine(true);

			requests.add(request);
		}

		if (!isValid) {
			requests.add(formJSONMessageEngine(false));
		}


		return requests;
	}


}