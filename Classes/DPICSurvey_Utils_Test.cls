@isTest(SeeAllData=true)
private class DPICSurvey_Utils_Test {
    //private Static UnitTestUtil oUtil = UnitTestUtil.getInstance();
    

    static Account account = new Account();
    static Lead lead = new Lead();
    static Account dealer = new Account();
    static Dealer_Quotes_Request__c dqr;
    static final String CUSTOMER_ID = '987654321';
    static final String DEALER_ID = '123456789';
    static testmethod void testCallsToSG1() {
        Case thisSurveyCase = new Case();
        RecordType dpicRT = [select id from recordtype where name = 'DPIC' and SObjecttype='Case'];
         thisSurveyCase.recordtypeid = dpicRT.id;
         thisSurveyCase.Origin = 'Email to Case';
 
         insert thisSurveyCase;
         test.startTest();
thisSurveyCase.Resolution_Notes__c = 'notes';
         thisSurveyCase.Status = 'Closed';
         
         update thisSurveyCase;
         test.stopTest();
         
    }
    static testmethod void testCallsToSG2() {
        test.startTest();
        RecordType dpicRT = [select id from recordtype where name = 'DPIC' and SObjecttype='Case'];


         Case thisSurveyCase = new Case();
         thisSurveyCase.recordtypeid = dpicRT.id;
         thisSurveyCase.Origin = 'Email to Case';

         insert thisSurveyCase;
         

        try {
        
         DPICSUrvey_Utils.createDPICContact(thisSurveyCase.id, '500xxxxxxxxxx', 'wrmtyr@gmail.com', 'Infiniti','test contact name', 'test agent name');
         DPICSurvey_UTILS.cloneCampaignDPIC('1797220','2027178','test method campaign');
         
        }
        catch(Exception e) {
          System.debug('error:' + e.getMessage());
          
        }
        test.stopTest();
    }
}