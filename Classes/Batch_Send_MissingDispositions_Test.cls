/**********************************************************************
  Name: Batch_Send_MissingDispositions_Test
  Copyright © notice: Nissan Motor Company.
  ======================================================
  Purpose
  Test for  Batch_Send_MissingDispositions
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Will Taylor  5/20/2015     Created
 ***********************************************************************/
@isTest
private class Batch_Send_MissingDispositions_Test
{
  /**
   *  Test method, to assure, that batch job work correctly by updating corresponding tasks
   */
  @isTest
  static void Missing_Fields_Test1()
  {
    User_Role_Check_Enabled__c userRoleCusomSetting = new User_Role_Check_Enabled__c();
    userRoleCusomSetting.Is_User_Validation_Enabled__c = false;
    insert userRoleCusomSetting;

    RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Service marketing'] [0];
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
    User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                      EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                      LocaleSidKey = 'en_US', ProfileId = p.Id,
                      TimeZoneSidKey = 'America/Los_Angeles', UserName = 'Zstandarduser@testorg.com', Call_Centre_Id__c = '11'
    );

    insert u;

/*create 1 completely null record, that matches recordtype
one record that has a disposition but no call start time
one record that has no disposition, but call duration > 10
one record that has no disposition, but a call duration <= 10 */

    List<Task> tasksToAdd = new List<Task>();

      Task m = new Task(Last_Name__c = 'Test1', RecordTypeId = rt.id,CreatedDate = Date.today(),OwnerId = u.id,CallType='Outbound',
          CallDisposition__c=null,CallDurationInSeconds=null,call_start_Time__c=null,
          call_end_time__c=null,
          TMS_Disposition__c = '',
          Dialer_Disposition__c = null,
          Satisfaction__c = '',
          Comment_Audience__c = ''
     );
     Task m2 = new Task(Last_Name__c = 'Test2', RecordTypeId = rt.id,CreatedDate = Date.today(),OwnerId = u.id, CallType='Outbound',
          CallDisposition__c='No Answer (7 Rings)',
          CallDurationInSeconds=12,
          call_start_Time__c=null,
          call_end_time__c=Date.today(),
          TMS_Disposition__c = '',
          Dialer_Disposition__c = null,
          Satisfaction__c = '2 - Neutral',
          Comment_Audience__c = ''
     );
     Task m3 = new Task(Last_Name__c = 'Test3', RecordTypeId = rt.id,CreatedDate = Date.today(),OwnerId = u.id, CallType='Outbound',
          CallDisposition__c=null,
          CallDurationInSeconds=0,
          call_start_Time__c=null,
          call_end_time__c=Date.today(),
          TMS_Disposition__c = '',
          Dialer_Disposition__c = null,
          Satisfaction__c = '2 - Neutral',
          Comment_Audience__c = ''
     );
    Task m4 = new Task(Last_Name__c = 'Test4', RecordTypeId = rt.id,CreatedDate = Date.today(),OwnerId = u.id, CallType='Outbound',
          CallDisposition__c=null,
          CallDurationInSeconds=30,
          call_start_Time__c=null,
          call_end_time__c=Date.today(),
          TMS_Disposition__c = '',
          Dialer_Disposition__c = null,
          Satisfaction__c = '2 - Neutral',
          Comment_Audience__c = ''
     );
    tasksToAdd.add(m);
    tasksToAdd.add(m4);
    tasksToAdd.add(m3);
    tasksToAdd.add(m2);

    insert tasksToAdd;

    Test.startTest();
    Batch_Send_MissingDispositions batch = new Batch_Send_MissingDispositions();
    Database.executeBatch(batch,10);

    Test.stopTest();


    // if everything worked there should be only one record with a blank comment audience (as no satisfaction)
    
    System.assertEquals([SELECT Count() FROM Task WHERE Comment_Audience__c = null], 1);
    
    // if everything worked shouldn't be any records with blank anything
    System.assertEquals([SELECT Count() FROM Task WHERE CallDisposition__c = null OR Call_Start_Time__c = null or call_end_time__c = null or calldurationinseconds = null LIMIT 1], 0);
    
    // if everything worked there should be two records now that are no answer seven ring
    System.assertEquals([SELECT Count() FROM Task WHERE CallDisposition__c = 'No Answer (7 Rings)'], 3);
    
    // and one record with Not Availalble (Left Message)
    System.assertEquals([SELECT Count() FROM Task WHERE CallDisposition__c = 'Not Available (Left message)'], 1);
    
    


  }
}