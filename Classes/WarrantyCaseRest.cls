@RestResource(urlMapping = '/warrantyCase/api/v1/case/*')
global class WarrantyCaseRest {
	public static Id globalInquiryRt { get; set; }
	public static Id cvtRt { get; set; }
	public static Id leafrt { get; set; }

	global class ResponseWrapper {
		global String sfdcId { get; set; }
		global String pegaCaseId { get; set; }
		global Integer code { get; set; }
		global String status { get; set; }
		global String message { get; set; }

		global ResponseWrapper() {
		}


	}

	global class RequestWrapper {
		global String token { get; set; }		
		global String Customer_Name { get; set; }
		global String techNameFirstLast { get; set; }
		global String techCellPhone_Number { get; set; }		
		global String Vehicle { get; set; }		
		global String PegaArcCaseNumber { get; set; }
		global String PegaROCaseNumber { get; set; }
		global String CaseNotes { get; set; }
		global String DealerNumber { get; set; }
		global String pegaCaseId { get; set; }

		global RequestWrapper() {

		}
	}

	@HttpPost
	global static ResponseWrapper createCases(RequestWrapper request) {
		ResponseWrapper response = validateCase(request);
		RestResponse rest_Response = RestContext.response;


		if (rest_Response == null) {
			rest_Response = new RestResponse();
			RestContext.response = rest_Response;
			
			response.pegaCaseId = request.pegaCaseId;
		}

		if (response.status == 'error') {
			rest_Response.statusCode = 400;
			
			response.pegaCaseId = request.pegaCaseId;
			return response;
		}

		if (ifTokenWrong(request)) {
			response.message = 'Invalid security token';
			response.status = 'error';
			response.code = 403;
			
			response.pegaCaseId = request.pegaCaseId;
			rest_Response.statusCode = 403;
			return response;
		}
		try {
			List<Warranty_Case__c> cases = new List<Warranty_Case__c> ();
			cases.add(caseBuilder(request));

			insert cases;

			if (cases.size() > 0) {
				response.code = 200;
				rest_Response.statusCode = 200;
				response.status = 'success';
				response.message = 'OK';
				response.sfdcId = cases[0].id;
				response.pegaCaseId = request.pegaCaseId;
			}
			else {
				response.sfdcId = '';
				response.code = 202;
				response.status = 'success';
				response.message = 'Case cannot be created';
				
				response.pegaCaseId = request.pegaCaseId;
				rest_Response.statusCode = 202;
			}
		}
		catch(DMLException e) {
			response.code = 500;
			response.status = 'error';
			response.message = 'Internal error on insert: ' + e.getMessage();
			
			response.pegaCaseId = request.pegaCaseId;
			rest_Response.statusCode = 500;
		}
		return response;
	}


	public static Warranty_Case__c caseBuilder(RequestWrapper request) {
		if (globalInquiryRt == null) {
			globalInquiryRt = RecordTypeUtil.getObjectRecordTypeId(Warranty_Case__c.SObjectType, 'General Inquiry');
		}

		Warranty_Case__c caseItem = new Warranty_Case__c();
		Account acc = new Account();
		if (String.isNotBlank(request.Vehicle))
		{
			Vehicle__c vehicle = [select id from Vehicle__c where Vehicle_identification_Number__c = :request.Vehicle];
			caseItem.Vehicle__c = vehicle.id;
		}
		caseItem.Notes__c = request.PegaArcCaseNumber + '\n' + request.PegaROCaseNumber + '\n' + request.CaseNotes;
		if (String.isNotBlank(request.techNameFirstLast))
		{
			caseItem.Requestor_s_Name__c = request.techNameFirstLast;
		} else {
			caseItem.Requestor_s_Name__c = 'Technician';
		}
		caseItem.Requestor_s_Phone_Number__c = request.techCellPhone_Number;
		if (String.isNotBlank(request.DealerNumber))
		{
			Account dealer = [select Id, name from Account where Dealer_Code__c = :request.DealerNumber];
			caseItem.Dealer__c = dealer.Id;
		}
		caseItem.Customer_Name__c = request.Customer_Name;
		caseItem.recordTypeId = globalInquiryRt;
		caseItem.VCAN_Type__c = '';

		return caseItem;
	}

	public static ResponseWrapper validateCase(RequestWrapper request) {
		ResponseWrapper response = new ResponseWrapper();


		return response;
	}

	public static Boolean ifTokenWrong(RequestWrapper request) {
		if (request.token == Label.Warranty_Case_Integration_Security_Token) {
			return false;
		}
		return true;
	}

	public static ResponseWrapper addRequiredError(String fieldName, ResponseWrapper response) {
		if (String.isNotEmpty(response.message)) {
			response.message += ', ' + fieldName;
		}
		else {
			response.code = 400;
			response.status = 'error';
			response.message = 'Required fields are missing: ' + fieldName;
		}

		return response;
	}
}