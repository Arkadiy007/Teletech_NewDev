public class Report_Cases_Controller { 
	public Case[] cases {get; set;}

	public Report_Cases_Controller() {
		String query = 'SELECT Id, Name, Type, (SELECT Account.Name FROM Case.Servicing_Dealer__c), Model_Line__c, Model_Year__c, VIN__c, ClosedDate, CreatedDate FROM Case ';

		///String condition = 

		//Concern_Description__c, Category_Description__c, Subcategory_Description__c, Symptom_Description__c
	}
}