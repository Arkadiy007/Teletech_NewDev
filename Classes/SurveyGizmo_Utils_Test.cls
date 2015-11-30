@isTest
private class SurveyGizmo_Utils_Test {
    //private Static UnitTestUtil oUtil = UnitTestUtil.getInstance();
    
      static Account account = new Account();
    static Lead lead = new Lead();
    static Account dealer = new Account();
    static Dealer_Quotes_Request__c dqr;
    static final String CUSTOMER_ID = '987654321';
    static final String DEALER_ID = '123456789';
    
    static void testdata() {
        String personType = System.Label.AccRTMaritz;
        String dealerType = System.Label.AccRTDealer;
        RecordType personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];
        RecordType dealerTypeRT = [select id, name from recordtype where name =: dealerType and sobjecttype = 'Account' limit 1];
        
        account.lastName = 'personAccTest';
        account.RecordTypeId = personTypeRT.id;
        account.Customer_ID__c = CUSTOMER_ID;
        insert account;

        lead.lastname = 'leadTest';
        lead.Customer_ID__c = CUSTOMER_ID;
        insert lead;

        dealer.name = 'dealerAccTest';
        dealer.RecordTypeId = dealerTypeRT.id;
        dealer.Dealer_Code__c = DEALER_ID;
        dealer.Dealer_External_Id__c = DEALER_ID + System.label.Dealer_USA;
        insert dealer;
   }
    
    
    
    
    static testmethod void testcreateContact() {
        test.startTest();
        
        testData();
         Case thisSurveyCase = new Case();
         
          //thisSurveyCase.DQR_Number__c
          //thisSurveyCase.Maritz_Customer_Id__c;
          thisSurveyCase.Dealer__r = dealer;
          thisSurveyCase.Considered_Vehicle_Make__c = 'NISSAN';
          thisSurveyCase.Account= account;
          //thisSurveyCase.Contact.FirstName;
          //thisSurveyCase.Contact.LastName;
        
        
        
        
        
        Surveys__c thisSurvey = new Surveys__c();
        thisSurvey.Lead_Id__c = '1111111111';
        thisSurvey.Customer_Id__c = '1111111111';
        thisSurvey.Case_Id__c ='12221111111';
        //thisSurvey.SurveyGizmoCase__c = thisSurveyCase.Id;
        thisSurvey.Dealer__c = dealer.id;
        thisSurvey.Brand__c = 'NISSAN';
        thisSurvey.Customer__c = account.id;
        thisSurvey.First_Name__c = 'William';
        thisSurvey.Last_Name__c = 'Test ';
        
        insert thisSurvey;
        
               
        
        try {
            SurveyGizmo_Utils sgUtils = new SurveyGizmo_Utils();
            String createResult = sgUtils.createSurveyGizmoContact('1594543','1445226', thisSurvey,'12312312312312','DealerName','Considered V. MOdel', '2013', '2-22-2013');
                
        }
        catch(Exception e) {
          System.debug('error:' + e.getMessage());
          
        }
        test.stopTest();
    }
}