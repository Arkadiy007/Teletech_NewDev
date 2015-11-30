/**********************************************************************
Name: ArchivedTasksControllerTests
Copyright © notice: Nissan Motor Company.
======================================================
Purpose
Tests class for ArchivedTasksController
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Vlad Martynenko 01/08/2015 Created
***********************************************************************/
@isTest
public class ArchivedTasksControllerTests { 
	private static Account acct;
	private static Archived_Activities_schedule__c schedule;
	private static Heroku_Credentials__c setting;
	
	static void  InitializeData() {

        acct = new Account();
        acct.FirstName = 'Test';
        acct.LastName = 'User1';
        insert acct;

		schedule = new Archived_Activities_schedule__c();
		schedule.Name='Task';
		schedule.Records_Per_Page__c = 10;
		insert schedule;

		setting = new Heroku_Credentials__c();
		setting.Name = 'Select';
		setting.Api_Link__c = 'link';
		setting.Access_Key__c = 'key';
		insert setting;
    }   

	static testmethod void testArchivedTasksController() {
        InitializeData();
        
        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new HerokuAppSelectCalloutMockImpl());
            ApexPages.currentPage().getParameters().put('sId',acct.id);
            ArchivedTasksController controller = new ArchivedTasksController();

            System.assertEquals(controller.Tasks.size(), 3);
        Test.stopTest();
    }

	public class HerokuAppSelectCalloutMockImpl implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {

			HttpResponse res = new HttpResponse();
			
			System.assertEquals('GET', req.getMethod());
		
			res.setBody('TmV3X0NvbnRhY3RfV29ya19QaG9uZV9fYyxBY3Rpdml0eURhdGUsTmV3X0NvbnRhY3RfQ291bnRyeV9fYyxNYWlsX1N0b3BfRW5kX0RhdGVfX2MsSXNBcmNoaXZlZCxDcmVhdGVkQnlJZCxDdXN0b21lcl9FeHBlcmllbmNlX19jLERDQl80OGhyX0NvbXBsaWFuY2VfX2MsRmVlZGJhY2tfX2MsUHJlZmVycmVkX0NhbGxfVGltZV9fYyxGYWlsZWRDYWxsX19jLElzRGVsZXRlZCxQcmVmZXJyZWRfRGVhbGVyX0NoYW5nZV9SZWFzb25fX2MsUmVjb3JkVHlwZUlkLEhvbWVfU2VxdWVuY2VfX2MsUmVjdXJyZW5jZUludGVydmFsLFN5c3RlbU1vZHN0YW1wLENvdW50cnlfX2MsQWN0aW9uX1R5cGVfX2MsUE1HX1R5cGVfX2MsTmV3X0NvbnRhY3RfSG9tZV9QaG9uZV9fYyxEQ0JfMjRocl9Db21wbGlhbmNlX19jLENhbXBhaWduTmFtZV9fYyxUZW1wX0F3YXlfRW5kX0RhdGVfX2MsRW1haWxfQ29uc2VudF9fYyxFbWFpbF9fYyxQaG9uZV9Db25zZW50X19jLENyZWF0ZWREYXRlLE1vYmlsZV9QaG9uZV9fYyxPd25lcklkLFJlY3VycmVuY2VUeXBlLENvbnRhY3RfQ2hhbmdlZF9fYyxFbWFpbF9UeXBlXzJfX2MsTmV3X0NvbnRhY3RfRmlyc3RfTmFtZV9fYyxXb3JrX1Bob25lX0V4dGVuc2lvbl9fYyxTTEFfQ29tcGxldGVfX2MsV2hhdElkLExhc3RNb2RpZmllZEJ5SWQsUmVjdXJyZW5jZURheU9mTW9udGgsTW9iaWxlX1Bob25lX0NvbnNlbnRfX2MsRGlhbGVkTnVtYmVyX19jLFN1YmplY3QsUmVjdXJyZW5jZURheU9mV2Vla01hc2ssTmV3X0NvbnRhY3RfQ2l0eV9fYyxXb3JrX1NlcXVlbmNlX19jLERpYWxlcl9EaXNwb3NpdGlvbl9fYyxMYW5ndWFnZV9fYyxOZXdfQ29udGFjdF9BZGRyZXNzX19jLENvbXBsZXRlZF9EYXRlX19jLE1pZGRsZV9OYW1lX19jLFBob25lX19jLENhbGxfQmFja19EYXl0aW1lX0luZGljYXRvcl9fYyxXaG9JZCxQb3N0YWxfQ29kZV9fYyxSZWN1cnJlbmNlU3RhcnREYXRlT25seSxPZG9tZXRlcl9Vbml0c19fYyxDYWxsRHVyYXRpb25JblNlY29uZHMsTmV3X0NvbnRhY3RfQWRkcmVzc19MaW5lXzJfX2MsUmVjdXJyZW5jZVRpbWVab25lU2lkS2V5LFdvcmtfUGhvbmVfX2MsVE1TX0Rpc3Bvc2l0aW9uX19jLENhbGxEaXNwb3NpdGlvbixOZXdfQ29udGFjdF9MYXN0X05hbWVfX2MsU2VydmljZV9NYXJrZXRpbmdfQ2FsbF9JRF9fYyxTZXJ2aWNlX01hcmtldGluZ19DYWxsX1R5cGVfX2MsQ2FsbF9DZW50cmVfSWRfX2MsQ29tbWVudF9BdWRpZW5jZV9fYyxTTEFfQ29tcGxpYW5jZV9fYyxNb2JpbGVfU2VxdWVuY2VfX2MsT2RvbWV0ZXJfUmVhZGluZ19fYyxDYWxsX1N0YXJ0X1RpbWVfX2MsUXVlc3Rpb25fMV9fYyxJc1Zpc2libGVJblNlbGZTZXJ2aWNlLFgyNGhyX0R1ZV9EYXRlX1RpbWVfX2MsUHJlZmVycmVkX01haWxfVHlwZV9fYyxOZXdfQ29udGFjdF9aaXBfX2MsV29ya19QaG9uZV9Db25zZW50X19jLFByZWZlcnJlZF9QaG9uZV9UeXBlX19jLFR5cGUsTWFpbF9TdG9wX1N0YXJ0X0RhdGVfX2MsQ2FsbERpc3Bvc2l0aW9uX19jLERlc2NyaXB0aW9uLFByaW9yaXR5LENhbGxPYmplY3QsQWN0aW9uX1Rha2VuX19jLFJlcXVlc3RfRGF0ZV9fYyxTZW5kX0VtYWlsX1JlcXVlc3RfSW5kaWNhdG9yX19jLFdvcmtfRW1haWxfQ29uc2VudF9fYyxBZ2VudF9JRF9fYyxSZW1pbmRlckRhdGVUaW1lLFNhbHV0YXRpb25fX2MsU3RhdHVzLExhc3RfTmFtZV9fYyxSZWN1cnJlbmNlRW5kRGF0ZU9ubHksV29ya19FbWFpbF9fYyxGaXJzdF9OYW1lX19jLENvbnRhY3RfT3JpZ2luX19jLE5ld19Db250YWN0X0hvbWVfRXh0X19jLFF1ZXN0aW9uXzJfX2MsWDQ4aHJfRHVlX0RhdGVfVGltZV9fYyxETklTX19jLElzUmVjdXJyZW5jZSxTYXRpc2ZhY3Rpb25fX2MsSXNDbG9zZWQsRW1haWxfVHlwZV8xX19jLFJlcXVlc3RfVGltZV9fYyxDYWxsX0JhY2tfVGltZV9fYyxDcmVhdGVkX0J5X1JvbGVfX2MsRGVjZWFzZWRfX2MsTGFzdE1vZGlmaWVkRGF0ZSxDYWxsX0VuZF9UaW1lX19jLElzUmVtaW5kZXJTZXQsSWQsU3RhdGVfX2MsU3RyZWV0X19jLExFVFRFUl9BVFRBQ0hFRF9fYyxDYWxsX0JhY2tfUGhvbmVfX2MsTmV3X0NvbnRhY3RfU3RhdGVfX2MsTmV3X0NvbnRhY3RfV29ya19FeHRfX2MsQWNjb3VudElkLERlYWxlcl9Db2RlX19jLFNlcnZpY2VfRGVzY3JpcHRpb25fX2MsQ3VzdG9tZXJJRF9fYyxDYWxsVHlwZSxSZWN1cnJlbmNlQWN0aXZpdHlJZCxBTklfX2MsVGVtcF9Bd2F5X1N0YXJ0X0RhdGVfX2MsQ2FsbF9QaG9uZV9fYyxSZWN1cnJlbmNlTW9udGhPZlllYXIsUmVjdXJyZW5jZUluc3RhbmNlLFBob25lX0V4dGVuc2lvbl9fYyxDYWxsX1JlY29yZGluZ19JRF9fYyxDaXR5X19jLFByZWZlcnJlZF9EZWFsZXJfQ2hhbmdlX19jLERlcGFydG1lbnRfX2MNCiwsLCxmYWxzZSwwMDVNMDAwMDAwNjgySkdJQVksLE4vQSwsLGZhbHNlLGZhbHNlLCwwMTJBMDAwMDAwMHd1NWpJQUEsLCwyMDE1LTAxLTA4IDEwOjUxOjQ5LCwsLCxOL0EsLCwsLE5PTkUsMjAxNS0wMS0wOCAxMDo1MTo0OSwsMDA1TTAwMDAwMDY4MkpHSUFZLCxmYWxzZSwsLCwsLDAwNU0wMDAwMDA2ODJKR0lBWSwsLCxUZXN0MSwsLCwsLCwsLCxmYWxzZSwsLCwsLCwsLCwsLCwsLCxOL0EsLCwsZmFsc2UsZmFsc2UsLCwsTk9ORSwsLCwsLE5vcm1hbCwsLCxmYWxzZSwsLCwsTm90IFN0YXJ0ZWQsLCwsLCwsZmFsc2UsLCxmYWxzZSwsZmFsc2UsLCwsTWFuYWdlZCBTZXJ2aWNlcyxmYWxzZSwyMDE1LTAxLTA4IDEwOjUxOjQ5LCxmYWxzZSwwMFRNMDAwMDAwR0lMSnJNQVAsLCxmYWxzZSwsLCwsLCwsLCwsLCwsLCwsLCxPdGhlcg0KLCwsLGZhbHNlLDAwNU0wMDAwMDA2ODJKR0lBWSwsTi9BLCwsZmFsc2UsZmFsc2UsLDAxMkEwMDAwMDAwd3U1aklBQSwsLDIwMTUtMDEtMDggMTA6NTE6NDksLCwsLE4vQSwsLCwsTk9ORSwyMDE1LTAxLTA4IDEwOjUxOjQ5LCwwMDVNMDAwMDAwNjgySkdJQVksLGZhbHNlLCwsLCwsMDA1TTAwMDAwMDY4MkpHSUFZLCwsLFRlc3QyLCwsLCwsLCwsLGZhbHNlLCwsLCwsLCwsLCwsLCwsLE4vQSwsLCxmYWxzZSxmYWxzZSwsLCxOT05FLCwsLCwsTm9ybWFsLCwsLGZhbHNlLCwsLCxOb3QgU3RhcnRlZCwsLCwsLCxmYWxzZSwsLGZhbHNlLCxmYWxzZSwsLCxNYW5hZ2VkIFNlcnZpY2VzLGZhbHNlLDIwMTUtMDEtMDggMTA6NTE6NDksLGZhbHNlLDAwVE0wMDAwMDBHSUxKc01BUCwsLGZhbHNlLCwsLCwsLCwsLCwsLCwsLCwsLE90aGVyDQosLCwsZmFsc2UsMDA1TTAwMDAwMDY4MkpHSUFZLCxOL0EsLCxmYWxzZSxmYWxzZSwsMDEyQTAwMDAwMDB3dTVqSUFBLCwsMjAxNS0wMS0wOCAxMDo1MTo0OSwsLCwsTi9BLCwsLCxOT05FLDIwMTUtMDEtMDggMTA6NTE6NDksLDAwNU0wMDAwMDA2ODJKR0lBWSwsZmFsc2UsLCwsLCwwMDVNMDAwMDAwNjgySkdJQVksLCwsVGVzdDMsLCwsLCwsLCwsZmFsc2UsLCwsLCwsLCwsLCwsLCwsTi9BLCwsLGZhbHNlLGZhbHNlLCwsLE5PTkUsLCwsLCxOb3JtYWwsLCwsZmFsc2UsLCwsLE5vdCBTdGFydGVkLCwsLCwsLGZhbHNlLCwsZmFsc2UsLGZhbHNlLCwsLE1hbmFnZWQgU2VydmljZXMsZmFsc2UsMjAxNS0wMS0wOCAxMDo1MTo0OSwsZmFsc2UsMDBUTTAwMDAwMEdJTEp0TUFQLCwsZmFsc2UsLCwsLCwsLCwsLCwsLCwsLCwsT3RoZXINCg==');
			res.setStatus('OK');
			res.setStatusCode(200);

			return res;
		}
	}
}