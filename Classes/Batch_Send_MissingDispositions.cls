/**********************************************************************
  Name: Batch_Send_MissingDispositions
  Copyright © notice: Nissan Motor Company.
  ======================================================
  Purpose
  Updates task objects with missing fields / dispositions to be sent back to TMS
  ======================================================
  History:

  VERSION  AUTHOR         DATE         DETAIL
  1.0      William Taylor 5/20/2015    Created
 
 ***********************************************************************/
global class Batch_Send_MissingDispositions implements Database.Batchable <sObject > {

  global Batch_Send_MissingDispositions() {
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    //1.  Selects all event and task records which fall into defined criteria
    
    
    String query = 'select id,  customer_experience__c, createddate, whoid, calldisposition__c, service_marketing_call_id__c, '+
    'call_end_time__c, call_start_time__c, calldurationinseconds, TMS_Disposition__c, ' +
    'Dialer_Disposition__c, comment_audience__c, satisfaction__c from task where recordtype.name=\'Service Marketing\' ' +
    'and CallType=\'OutBound\' and (Customer_Experience__c = null or CampaignName__c = null or call_end_time__c = null or  ' +
    'calldurationinseconds = null or Agent_Id__c = null OR Call_Centre_Id__c = null OR ' +
    'TMS_Disposition__c = null OR CallDurationInSeconds = null OR Call_Start_Time__c = null OR ' +
    'Call_Phone__c = null OR Customer_Experience__c = null OR First_Name__c = null OR ' +
    'Last_Name__c = null OR Street__c = null OR City__c = null OR State__c = null OR  ' +
    'Postal_Code__c = null OR Language__c = null) and createddate >= YESTERDAY';

   /* String query = 'SELECT ID, OwnerId, Call_End_Time__c, TMS_Disposition__c, Dialer_Disposition__c, CallDisposition__c, Call_Centre_Id__c, Customer_Experience__c, CallDurationInSeconds, Call_Recording_ID__c';
    query = query + ' FROM Task WHERE RecordTypeID = :ServiceMarketingRecordTypeId AND (CallDisposition__c = NULL OR CallDisposition__c = \'\') AND Dialer_Disposition__c = NULL';
    query = query + ' AND (TMS_Disposition__c = null OR TMS_Disposition__c = \'\') AND (NOT Subject LIKE \'%Inbound%\') AND (CallType != \'Internal\' OR CallType != \'Inbound\')';
    query = query + ' AND (CallDurationInSeconds = 0 OR CallDurationInSeconds = null) AND CreatedDate >= YESTERDAY'; */
    
    return Database.getQueryLocator(query);
  }

  // Empty finish method
  global void finish(Database.BatchableContext BC) {
  }

  global void execute(Database.BatchableContext BC, List <Task > tasks) {
    
    List<ServiceMarketingFailed__c> fails = new List<ServiceMarketingFailed__c>();
    ServiceMarketingFailed__c fail;
      
    try {

      User_Role_Check_Enabled__c userRoleCusomSetting = User_Role_Check_Enabled__c.getOrgDefaults();
      userRoleCusomSetting.Is_User_Validation_Enabled__c = false;
      update userRoleCusomSetting;
      
      for (Task taskItem : tasks) {
          taskItem.CallDurationInSeconds = taskItem.CallDurationInSeconds == null ? 0 : taskItem.callDurationInSeconds;
          
          fail = new ServiceMarketingFailed__c();
          
          fail.calldurationinseconds__c = taskItem.CallDurationInSeconds == null ? null : String.valueOf(taskItem.CallDurationInSeconds);
          fail.callendtime__c = taskItem.call_end_time__c;
          fail.callstarttime__c = taskItem.call_start_time__c;
          fail.Contact__c = taskItem.whoId;
          fail.taskcreateddate__c = taskItem.createddate;
          fail.taskid__c = taskitem.id;
          fail.dialer_disposition__c = String.valueOf(taskItem.dialer_disposition__c);
          fail.tms_disposition__c = taskItem.tms_disposition__c;
          fail.calldisposition__c = taskitem.calldisposition__c;
          fails.add(fail);
          
          
          if (taskItem.Satisfaction__c != null && (taskItem.Comment_Audience__c == null || taskItem.Comment_Audience__c == '')) {
              taskItem.Comment_Audience__c = '1 - General';
          }
           
          if (taskItem.Call_End_Time__c == null) {
          
              if (taskItem.Call_Start_Time__c == null) {
                  taskItem.Call_End_Time__c = taskItem.createdDate;
                  taskItem.Call_Start_Time__c = taskItem.createdDate;
              } else {
                  taskItem.Call_End_Time__c = taskItem.call_start_time__c.addSeconds(taskItem.calldurationinseconds);
              }
          } else {
                   taskItem.Call_Start_Time__c = taskItem.Call_Start_Time__c == null ? taskItem.call_end_time__c.addSeconds(taskItem.calldurationinseconds*-1) : taskItem.call_start_time__c;
          }
          
          if (taskItem.CallDisposition__c == null || taskItem.CallDisposition__c == '') {
              
              if (taskItem.CallDurationInSeconds <= 10) {
                  taskItem.CallDisposition__c = 'No Answer (7 Rings)';
                  taskItem.TMS_Disposition__c = '10';
                  taskItem.Dialer_Disposition__c = 9;
              } else {
                  taskItem.CallDisposition__c = 'Not Available (Left Message)';
                  taskItem.TMS_Disposition__c = '13';
                  taskItem.Dialer_Disposition__c = 24;
              }
         }     
      }
      update tasks;
      insert fails;
      
      //10.  Updates User_Role_Check_Enable value to YES. 
      userRoleCusomSetting.Is_User_Validation_Enabled__c = true;
      update userRoleCusomSetting;
    }
    catch(Exception ex) {
      User_Role_Check_Enabled__c userRoleCusomSetting = User_Role_Check_Enabled__c.getOrgDefaults();
      userRoleCusomSetting.Is_User_Validation_Enabled__c = true;
      update userRoleCusomSetting;
    }
  }
}