/**********************************************************************
Name: CSVHandlerTests
Copyright © notice: Nissan Motor Company.
======================================================
Purpose
Tests class for CSVHandler
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Vlad Martynenko 01/08/2015 Created
***********************************************************************/
@isTest
public class CSVHandlerTests { 
	static testMethod void testConvertValue() {
	Test.startTest();
        // DateTime
        Schema.DescribeFieldResult d = Case.CreatedDate.getDescribe();
        Object o = CSVHandler.convertValue(d, '2014-06-17 13:12:34');
        System.assertEquals(DateTime.newInstance(2014, 6, 17, 13, 12, 34), o);
        o = CSVHandler.convertValue(d, '2014-06-17T13:12:34');
        System.assertEquals(DateTime.newInstance(2014, 6, 17, 13, 12, 34), o);
        o = CSVHandler.convertValue(d, '');
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, null);
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, 'junk');
        System.assertEquals(null, o);
        
        // Date
        d = Opportunity.CloseDate.getDescribe();
        o = CSVHandler.convertValue(d, '2014-06-17');
        System.assertEquals(DateTime.newInstance(2014, 6, 17).date(), o);
        o = CSVHandler.convertValue(d, '');
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, null);
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, 'junk');
        System.assertEquals(null, o);
        
        // Checkbox
        d = Opportunity.IsPrivate.getDescribe();
        o = CSVHandler.convertValue(d, 'true');
        System.assertEquals(true, o);
        o = CSVHandler.convertValue(d, 'TRUE');
        System.assertEquals(true, o);
        o = CSVHandler.convertValue(d, '');
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, null);
        System.assertEquals(null, o);

        // Integer
        d = Account.NumberOfEmployees.getDescribe();
        o = CSVHandler.convertValue(d, '123');
        System.assertEquals(123, o);
        o = CSVHandler.convertValue(d, '');
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, null);
        System.assertEquals(null, o);

        // Double
        d = Opportunity.Amount.getDescribe();
        o = CSVHandler.convertValue(d, '123.45');
        System.assertEquals(123.45, o);
        o = CSVHandler.convertValue(d, '');
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, null);
        System.assertEquals(null, o);

        // Percent
        d = Opportunity.Probability.getDescribe();
        o = CSVHandler.convertValue(d, '.12');
        System.assertEquals(.12, o);
        o = CSVHandler.convertValue(d, '');
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, null);
        System.assertEquals(null, o);

        // Currency
        d = Account.AnnualRevenue.getDescribe();
        o = CSVHandler.convertValue(d, '12.34');
        System.assertEquals(12.34, o);
        o = CSVHandler.convertValue(d, null);
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, '');
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, 'junk');
        System.assertEquals(null, o);

        // Text
        d = Account.AccountNumber.getDescribe();
        o = CSVHandler.convertValue(d, 'junk');
        System.assertEquals('junk', o);
        o = CSVHandler.convertValue(d, null);
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, ' ');
        System.assertEquals(' ', o);

        final String tooLong = '01234567890123456789012345678901234567890123456789';
        System.assert(d.getLength() < tooLong.length());
        o = CSVHandler.convertValue(d, tooLong);
        System.assertEquals(d.getLength(), ((String)o).length());
        
        // Text area
        d = Account.Description.getDescribe();
        o = CSVHandler.convertValue(d, 'junk');
        System.assertEquals('junk', o);
        o = CSVHandler.convertValue(d, null);
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, ' ');
        System.assertEquals(' ', o);
        
        // Pick list
        d = Account.AccountSource.getDescribe();
        o = CSVHandler.convertValue(d, 'junk');
        System.assertEquals('junk', o);
        o = CSVHandler.convertValue(d, null);
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, ' ');
        System.assertEquals(' ', o);
        
        // Id
        d = Account.Id.getDescribe();
        o = CSVHandler.convertValue(d, '123456789012345');
        System.assertEquals('123456789012345', o);
        o = CSVHandler.convertValue(d, null);
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, ' ');
        System.assertEquals(' ', o);
        
        // Email
        d = Contact.Email.getDescribe();
        o = CSVHandler.convertValue(d, 'junk@here.com');
        System.assertEquals('junk@here.com', o);
        o = CSVHandler.convertValue(d, null);
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, ' ');
        System.assertEquals(' ', o);
        
        // Phone
        d = Contact.Phone.getDescribe();
        o = CSVHandler.convertValue(d, '(812) 603-0704');
        System.assertEquals('(812) 603-0704', o);
        o = CSVHandler.convertValue(d, null);
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, ' ');
        System.assertEquals(' ', o);
        
        // URL
        d = Account.Website.getDescribe();
        o = CSVHandler.convertValue(d, 'http://junk.com');
        System.assertEquals('http://junk.com', o);
        o = CSVHandler.convertValue(d, null);
        System.assertEquals(null, o);
        o = CSVHandler.convertValue(d, ' ');
        System.assertEquals(' ', o);
	Test.stopTest();
    }

	static testMethod void testEncodingAndDecodingMethods(){
	Test.startTest();
		String objType = 'Task';
		Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
		Schema.SObjectType sobjType = gd.get(objType); 
		Schema.DescribeSObjectResult describeResult = sobjType.getDescribe(); 
		List<Schema.SObjectField> fields = describeResult.fields.getMap().values();

		List<Task> tasks = new List<Task>();
		tasks.add(new Task());
		tasks.add(new Task());
		tasks.add(new Task());
		insert tasks;

		String query = BuildQuery(fields, objType, 'WHERE Id IN :tasks');

		List<sObject> objects = Database.query(query);
		String encodedResult = CSVHandler.getEncodedCsvByObjectType(fields,objects);
		List<Task> decodedResult = CSVHandler.getDecodedObjectsFromCsv(encodedResult, objType);

		System.assertEquals(decodedResult.size(), 3);
	Test.stopTest();
	}

	private static String BuildQuery(List<Schema.SObjectField> fields, String objType, String whereClause){
		String request ='';

		for(Schema.SObjectField field : fields){
		 String name = field.getDescribe().getName();
		 if(request != '') {
			request += ',';
		 }
		 request += name;
		}

		return String.Format('SELECT {0} FROM {1} {2}', new List<String>{request, objType, whereClause});
	}
}