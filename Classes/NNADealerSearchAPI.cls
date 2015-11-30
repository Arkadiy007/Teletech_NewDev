public class NNADealerSearchAPI { 
	public static String getDealerList(Map <String, String > params) {
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		
		String parametersString = '';
		for (String key : params.keySet()) {
			String value = params.get(key);
			if (value != null && value != '') {
				parametersString += String.format('{0}={1}&', new String[] { key.tolowercase(), value.tolowercase() });
			}
		}

		req.setEndpoint('https://cs7.salesforce.com/services/apexrest/casl/api/v1/vendors/' + '?' + parametersString + 'consentType=Nissan');
		req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
		req.setMethod('GET');

		// Send the request, and return a response
		HttpResponse res = h.send(req);
		return res.getBody();
	}
}