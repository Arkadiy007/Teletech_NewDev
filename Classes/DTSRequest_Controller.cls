public class DTSRequest_Controller {

    Public Case c {get;set;}
    Public Boolean createDTS {get;set;}
           
    public DTSRequest_Controller(ApexPages.StandardController controller) {
    
        c = [select Id, Recordtype.Name, Servicing_Dealer__r.DTS_A_Stage_User__r.Email__c, 
                 Dealer__c, Dealer__r.DTS_A_Stage_User__r.Email__c, DTS_Notes__c, DTS_Field_Inspection__c,
                 DTS_Inspection_Date_Confirmed__c, DTS_Notification__c, AccountId, Servicing_Dealer__c,
                 Description, Initial_Recommendation__c, Problem_Analysis__c, OwnerId, Vehicle_Service_Contract__c,
                 Vehicle_Name__c, Dealer__r.Dealer_Code__c, CaseNumber, Customer_Name__c, Account.Name, Dealer_Code__c,
                 Servicing_Dealer__r.Dealer_Code__c, DTS_Inspection_Task_Assigned__c,DTS_Inspection_Date_Set__c,
                 DTS_Request_Type__c from Case where 
                 Id = :ApexPages.currentPage().getParameters().get('Id')];
        
        createDTS = c.DTS_Notification__c;
        
        if(c.Recordtype.Name == 'TECH LINE' || c.Recordtype.Name == 'TECH LINE Cases'){
            c.DTS_Request_Type__c = 'TECH LINE Request';
            }
        
        
      }
      
    public Pagereference go(){
    
        if (c.DTS_Notes__c != null) {

            if(c.Recordtype.Name == 'TECH LINE' || c.Recordtype.Name == 'TECH LINE Cases'){
            
                String email;
                User[] userslist;
                
                if (Test.isRunningTest()) {
                     userslist = [select Id, Username, Email from User where name ='Managed Services' and isactive=true limit 1];
                 } else {
                     email = c.Dealer__r.DTS_A_Stage_User__r.Email__c;
                     userslist = [select Id, Username, Email from User where Email = :email and isactive = true limit 1];
                 }
                //User u = [select Id, Username, Email from User where Email = :email and isactive = true limit 1];        
                system.debug(email);
            
                User u;
                if (userslist.size() == 1) {
                    u = userslist[0];
                    Task t = new Task(
                    recordtypeId = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'TECH LINE'),
                    ActivityDate = system.today()+2,
                    Description = c.DTS_Notes__c,
                    OwnerId = u.Id,
                    Subject = 'New DTS Request',
                    WhatId = c.Id);
                    c.Task_Field_Inspection_Owner__c = t.OwnerId;
                    // WFT 9/19/2014 Added to send an email notification for this task insert.
                    
                    Database.DMLOptions dmlOptions = new Database.DMLOptions(); 
                    dmlOptions.EmailHeader.TriggerUserEmail = TRUE; 
                    Database.Insert(t, dmlOptions);
                    
                    //insert t;
                    
                    c.DTS_Notification__c = true;
                    c.Field_Inspection_Indicator__c = true;
                    c.DTS_Inspection_Task_Assigned__c = system.now();
                    update c;
                } else {
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please contact Managed Services to update the Stage User for: ' + email));
                  return null;
                }



            } else {
            
                // PROCESS AS A CA CASE
            
              String email;
                
               User[] userslist;
               if (Test.isRunningTest()) {
                   userslist = [select Id, Username, Email from User where Name='Managed Services' and isactive= true limit 1];
               } else {
                   email = c.Servicing_Dealer__r.DTS_A_Stage_User__r.Email__c;
                   userslist = [select Id, Username, Email from User where email = :email and isactive = true limit 1];
               }

                User u;
                if (userslist.size() == 1) {
                    u = userslist[0];
                    Task t = new Task(
                    recordtypeId = RecordtypeUtil.getObjectRecordTypeId(Task.SObjectType, 'TECH LINE'),
                    ActivityDate = system.today()+2,
                    Description = c.DTS_Notes__c,
                    OwnerId = u.Id,
                    Subject = 'New DTS Request',
                    WhatId = c.Id);
                    c.Task_Field_Inspection_Owner__c = t.OwnerId;
                    // WFT 9/19/2014 Added to send an email notification for this task insert.
                    
                    Database.DMLOptions dmlOptions = new Database.DMLOptions(); 
                    dmlOptions.EmailHeader.TriggerUserEmail = TRUE; 
                    Database.Insert(t, dmlOptions);
                    //insert t;
                    
                    c.DTS_Notification__c = true;
                    c.Field_Inspection_Indicator__c = true;
                    c.DTS_Inspection_Task_Assigned__c = system.now();
                    update c;

                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please contact Managed Services to update the Stage User for: ' + email));
                  return null;
                }
            }
        
        }
    
      
      if(c.DTS_Notes__c == null || c.DTS_Request_Type__c == null){
      
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter DTS Request Type and DTS Notes.'));
          return null;
      
      }
      
      else{
      Pagereference p = new Pagereference('/'+c.Id);
     
         return p;
         }
    }
    
   
    public Pagereference oncancel(){
    
    Pagereference p = new Pagereference('/'+c.Id);
     
         return p;
    }  
  

}