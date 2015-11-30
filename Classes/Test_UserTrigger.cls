/**
 * This class contains unit tests for UserTrigger
 * Author: Aaron Bessey
 * Date 9/12/2014
 */
@isTest
private class Test_UserTrigger {
    private static testmethod void main() {
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.nis', ZCA_Id__c='dwil', VCAN_Password__c='test1234' );
        insert u;
        
        u = [Select Id, VCAN_Password__c from user where id=:u.Id];
        
        System.assert(u.VCAN_password__c != 'test1234');    
        
        u.VCAN_Password__c = 'newPword1234';
        update u;
        
        u = [Select Id, VCAN_Password__c from user where id=:u.Id];
        
        System.assert(u.VCAN_Password__c != 'newPword1234');
        
        Test.stopTest();
    }
}