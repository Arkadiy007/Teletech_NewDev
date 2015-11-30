/**********************************************************************
Name: HerokuApiTests
Copyright © notice: Nissan Motor Company.
======================================================
Purpose
Tests class for HerokuApi
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Vlad Martynenko 01/08/2015 Created
***********************************************************************/
@isTest
public class HerokuApiTests { 
	@IsTest(SeeAllData=true)
	static void testsaveCallout() {
	Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new HerokuAppSaveCalloutMockImpl());

        Boolean res = HerokuApi.SaveRecords('csv', 'Task');

        System.assertEquals(true, res);
	Test.stopTest();
    }

	@IsTest(SeeAllData=true)
	static void testselectCallout() {
	Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new HerokuAppSelectCalloutMockImpl());

        String res = HerokuApi.GetRecords(new Map<String,String>());

        System.assertEquals('Success', res);
	Test.stopTest();
    }

	public class HerokuAppSaveCalloutMockImpl implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			Heroku_Credentials__c saveSetting = [SELECT Name, Api_Link__c, Access_Key__c FROM Heroku_Credentials__c WHERE Name='Save'];
			
			HttpResponse res = new HttpResponse();

			System.assertEquals('POST', req.getMethod());
		
			res.setBody('Success');
			res.setStatusCode(200);
			res.setStatus('OK');

			return res;
		}
	}

	public class HerokuAppSelectCalloutMockImpl implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			Heroku_Credentials__c selectSetting = [SELECT Name, Api_Link__c, Access_Key__c FROM Heroku_Credentials__c WHERE Name='Select'];
			
			HttpResponse res = new HttpResponse();
			
			System.assertEquals('GET', req.getMethod());
		
			res.setBody('Success');
			res.setStatus('OK');
			res.setStatusCode(200);

			return res;
		}
	}
}