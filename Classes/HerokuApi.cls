/**********************************************************************
Name: HerokuApi
Copyright © notice: Nissan Motor Company.
======================================================
Purpose
Heroku application api helper class used to call archive-db application hosted on Heroku.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Vlad Martynenko 01/08/2015 Created
***********************************************************************/
public class HerokuApi {
	// Used to call 'Save' endpoint of Heroku app, recieves csv and base64 encoded objects and type of object that we will be saving
	public static Boolean SaveRecords(String csv, String objectType){
		Heroku_Credentials__c setting = [SELECT Name, Api_Link__c, Access_Key__c FROM Heroku_Credentials__c WHERE Name='Save'];

		// Post request parameters
		String body = String.format('key={0}&table_name={1}&data={2}', new String[]{Base64Encode(setting.Access_Key__c), objectType, csv});

		Http http = new Http();

		HttpRequest req = new HttpRequest();
		req.setEndpoint(setting.Api_Link__c);
		req.setMethod('POST');
		req.setBody(body);

		HTTPResponse res = http.send(req);

		if(res.getStatus() == 'OK'){
			return true;
		}
		else{
			return false;
		}
	}

	// Used to call 'Select' endpoint of Heroku app, recieves key/value pair for all parameters that will be attached to request string.
	public static String GetRecords(Map<String, String> params){
		Heroku_Credentials__c setting = [SELECT Name, Api_Link__c, Access_Key__c FROM Heroku_Credentials__c WHERE Name='Select'];
		String encodedKey = Base64Encode(setting.Access_Key__c);
		params.put('key',encodedKey);

		Http http = new Http();

		HttpRequest req = new HttpRequest();
		req.setMethod('GET');

		// Get request parameters
		String body = '';
        for (String param : params.keySet()){
			if(body != ''){
				body += '&';
			}
			body += param + '=' + params.get(param);
        }
		req.setEndpoint(setting.Api_Link__c + '?' + body);

		HTTPResponse res = http.send(req);
		if(res.getStatus() == 'OK'){
			return res.getbody();
		}
		else{
			return '';
		}
	}

	// Used to call 'Select' endpoint of Heroku app, recieves key/value pair for all parameters that will be attached to request string.
	public static String GetCaseRecords(Map<String, Object> params){
		Http http = new Http();

		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');


		String body = JSON.serialize(params);
		req.setBody(body);
		req.setEndpoint('https://archive-db.herokuapp.com/getprevioussolutions');

		HTTPResponse res = http.send(req);
		System.debug(res);
		System.debug(res.getBody());
		if(res.getStatus() == 'OK'){
			return res.getbody();
		}
		else{
			return '';
		}
	}

	// Used to call 'Select' endpoint of Heroku app, recieves key/value pair for all parameters that will be attached to request string.
	public static String CreateRecords(Map<String, Object> params){
		Http http = new Http();

		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');


		String body = JSON.serialize(params);
		req.setBody(body);
		req.setEndpoint('https://archive-db.herokuapp.com/createcase');

		HTTPResponse res = http.send(req);
		System.debug(res);
		System.debug(res.getBody());
		if(res.getStatus() == 'OK'){
			return res.getbody();
		}
		else{
			return '';
		}
	}


	// Helper method for string base64 encoding
	private static String Base64Encode(String valueToBeEncrypted){
		Blob encodedBlob = Blob.valueOf(valueToBeEncrypted);
		return EncodingUtil.base64Encode(encodedBlob);
	}
}