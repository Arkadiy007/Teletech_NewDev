/*************************************************************************************
Name: EmailMessage_After 
=======================================================================================
History: 

VERSION AUTHOR         DATE         DETAIL 
1.02 - Arkadiy Sychev  12/12/2014  Added notifications creation when user replies on email
1.03 - Vivek Batham   1/23/2015    Created Helper class for EmailMessage Triggers.
                                   Added logic for reopening/creating a Case 
                                   based on a Customer reply on 30 days duration
1.04 - Arkadiy Sychev  04/03/2015  Added logic for notifications creation for MCC case RecordTypes 
                                   when user replies on email
1.05 - Vladimir Martynenko 08/06/2015 Added Maritz Backfeet Stage Object Creation logic;
****************************************************************************************/

public with sharing class EmailMessageHelper {

    public static void handleAfterInsertEvent(List<EmailMessage> emailMsges){
    
        //get the next workday
        DateTime createDate = System.now();
        HolidayCalculator holidayDates = new HolidayCalculator(createDate.date());
        DateTime targetDate = holidayDates.nextWorkDay(createDate);
        targetDate = targetDate.addDays(1);
        targetDate = holidayDates.nextWorkDay(targetDate);
        
        List<Case> casesToUpsert = new List<Case>();  
        List<Case> parrentCases = new List<Case>();  
        List<Notification__c> notificationList = new List<Notification__c>();
        Map<String, Schema.RecordTypeInfo> recorTypemap = Schema.Sobjecttype.Case.getRecordTypeInfosByName(); 
        String nissanRecordTypeId = recorTypemap.get(Label.CA_Email_Nissan).getRecordTypeId();
        String infinityRecordTypeId = recorTypemap.get(Label.CA_Email_Infiniti).getRecordTypeId();
        String caSalesServiceRecordTypeId = recorTypemap.get(Label.CA_Sales_Service).getRecordTypeId();
        String t5RecordTypeId = recorTypemap.get(Label.T5).getRecordTypeId();
        String caRecordTypeId = recorTypemap.get(Label.CA).getRecordTypeId();
        MCC_Custom_Setting__c mccCustomSetting;    

        Map<Id, EmailMessage> parrentCaseIds = new  Map<Id, EmailMessage>();    

        //012K00000008XjuIAE Manage Services, 012K00000008XjuIAE Part, 012A0000000OkbxIAC General, 012F0000000y9yCIAQ DPIC
        List<EmailMessage> emails = [select TextBody, FromAddress, FromName, Subject, ActivityId, CreatedDate, Parent.ContactId, Parent.Origin, Parent.RecordTypeId from EmailMessage where Incoming = true and ID in: Trigger.new];
    
        Map<ID, EmailMessage> taskIDs = new Map<ID, EmailMessage>();
        for (EmailMessage e : emails) {
            parrentCaseIds.put(e.ParentId, e);
            if (e.Parent.RecordTypeId == CaseClass.DPIC_RT && e.ActivityId != null)
                taskIDs.put(e.ActivityId, e);
        }

        List<Task> tasksToUpdate = new List<Task>();
        List<Task> relatedTasks = [Select ActivityDate From Task Where ID in: taskIDs.keySet()];
        for (Task t : relatedTasks) {
            EmailMessage e = taskIDs.get(t.ID);
        
            //If the Date that calls the method occurs after the compDate, the return value is negative.
            t.ActivityDate = targetDate.Date();
            t.Subject = '24hr Email Reply Required';
            tasksToUpdate.add(t);
        }
        try {
            if (tasksToUpdate.size() > 0)
                update tasksToUpdate;
        } catch (DMLException e) {
            taskIDs.get(e.getDmlId(0)).addError('Exception occured while updating Task related to the email message: ' + e.getMessage());
        }
    
        CaseClass.Email2Case_CreateAccountByEmailMessage(emails);
    
        //1.02 Notifications creation when user replies on email
    
        parrentCases = [SELECT Id, OwnerId, CaseNumber, LastModifiedById, Owner.Name, LastModifiedBy.Name, Days_Closed__c, 
                               RecordTypeId, RecordType.Name, Status, CA_CaseReopenCount__c, ContactId, AccountId, Make__c, Type
                        FROM Case WHERE Id IN: parrentCaseIds.keySet()];
    
        // 1.04 Arkadiy Sychev - retrieve the Default Organization Level Value of 'MCC Custom Setting' custom setting
        mccCustomSetting = MCC_Custom_Setting__c.getOrgDefaults();
        if ((mccCustomSetting==null) || (mccCustomSetting.id == null)) {
            mccCustomSetting = new MCC_Custom_Setting__c();
            insert mccCustomSetting;
            mccCustomSetting = MCC_Custom_Setting__c.getOrgDefaults();
        }
        // 1.04 Arkadiy Sychev - set of the MCC RecordTypes
        Set<String> mCCRecordTypes = new Set<String> ();
        try {
            mCCRecordTypes.addAll(mccCustomSetting.MCC_Case_recordTypes__c.split(','));
        } catch(Exception e) {
        }

        // 1.04 Arkadiy Sychev - set of the users who can get notifications from MCC RecordTypes
        Set<String> allowedUsers = new Set<String> ();
        try {
            allowedUsers.addAll(mccCustomSetting.Users_Who_Can_View_MCC_Updates__c.split(','));
        } catch(Exception e) {
        }
        Map<Id, User> allowedUsersMap = new Map<Id, User>([SELECT Id FROM USER WHERE Name In : allowedUsers]);
    
        Case casobj;
        for (Case c : parrentCases) {
            if(c.RecordType.Name.containsIgnoreCase('CA Closed Case')){
            if(c.Status.equalsIgnoreCase('Closed')){
                if(c.Days_Closed__c <= 30){
                    casobj = new Case(Id = c.Id, Status='Open', CA_CaseReopenCount__c = c.CA_CaseReopenCount__c + 1, RecordTypeId = caRecordTypeId, Follow_Up_Date__c = Date.today());
                    if(c.Type.equalsIgnoreCase(Label.CA_Email_Nissan)){
                        casobj.RecordTypeId = nissanRecordTypeId;
                    }
                    if(c.Type.equalsIgnoreCase(Label.CA_Email_Infiniti)){
                        casobj.RecordTypeId = infinityRecordTypeId;
                    } 
                    if(c.Type.equalsIgnoreCase('Sales & Service')){
                        casobj.RecordTypeId = caSalesServiceRecordTypeId;
                    } 
                    if(c.Type.equalsIgnoreCase(Label.T5)){
                        casobj.RecordTypeId = t5RecordTypeId;
                    }               
                    casesToUpsert.add(casobj);
                }
                else{
                    EmailMessage prevEmail = parrentCaseIds.get(c.Id);
                    casesToUpsert.add(new Case(Status='Open', OwnerId = c.OwnerId, ContactId = c.ContactId, AccountId = c.AccountId, ParentId =c.Id,Subject = prevEmail.Subject, Description = prevEmail.TextBody,
                                        RecordtypeId = (c.Make__c != null && c.Make__c.ContainsIgnoreCase('NISSAN')) ? nissanRecordTypeId : infinityRecordTypeId));
                
                                    
                    //tasksToCreate.add(new Task(OwnerId = c.OwnerId, Subject = prevEmail.))                    
                }   
            }
            }

            // 1.04 Arkadiy Sychev
            if (!mCCRecordTypes.contains(c.RecordType.Name)) {
                createNotification(c, notificationList, parrentCaseIds, c.OwnerId);
            } else {
                for (User u : allowedUsersMap.values()) {
                    createNotification(c, notificationList, parrentCaseIds, u.Id);
                }
            }
        }

        //1.05 - Vladimir Martynenko 08/06/2015 Added Maritz Backfeet Stage Object Creation logic:
       if(Maritz_Backfeed_Trigger_Enabled__c.getInstance() != null){
            if(Maritz_Backfeed_Trigger_Enabled__c.getInstance().EnabledForEmail__c){
                Maritz_Backfeed_TaskTriggerHelper helper = new Maritz_Backfeed_TaskTriggerHelper(emailMsges);
            }
        }
    
        Database.insert(notificationList, false);  
    
        if(casesToUpsert.size() > 0){
            Database.upsert(casesToUpsert, false);
        }  
    
    }

    // 1.04 Arkadiy Sychev - method for notification creation
    private static void createNotification (Case cLocal, List<Notification__c> notificationListLocal, Map<Id, EmailMessage> parrentCaseIdsLocal, Id assegnedTo) {
        Notification__c notification = new Notification__c (Assigned_To__c = assegnedTo,
                                                            Related_Object_ID__c = String.valueOf(cLocal.Id),
                                                            Status__c = 'Open',
                                                            Allow_Dismiss__c = true,
                                                            Related_Object_Type__c = 'Case',
                                                            Subject__c = 'Email for LINK[Case-' + cLocal.CaseNumber + ',' + cLocal.Id + '] received',
                                                            LongDescription__c = 'Email received from ' + parrentCaseIdsLocal.get(cLocal.Id).FromName + ' email:  ' + parrentCaseIdsLocal.get(cLocal.Id).FromAddress);
        notificationListLocal.add(notification);
    }

    // Before Insert event
     public static void handleBeforeInsertEvent(List<EmailMessage> emailMsges){
        Map<String, Schema.RecordTypeInfo> recorTypemap = Schema.Sobjecttype.Case.getRecordTypeInfosByName(); 
        List<Case> casesToUpsert = new List<Case>();  
        List<Case> parrentCases = new List<Case>();  
        Map<Id, EmailMessage> parrentCaseIds = new  Map<Id, EmailMessage>();
        Map<Id, EmailMessage> parentEmails = new Map<Id, EmailMessage>();
        List<EmailMessage> eMsgToUpdate = new List<EmailMessage>(); 
        String nissanQueueId;
        String infinityQueueId;
        
        String nissanRecordTypeId = recorTypemap.get(Label.CA_Email_Nissan).getRecordTypeId();
        String infinityRecordTypeId = recorTypemap.get(Label.CA_Email_Infiniti).getRecordTypeId();
        String caSalesServiceRecordTypeId = recorTypemap.get(Label.CA_Sales_Service).getRecordTypeId();
        String t5RecordTypeId = recorTypemap.get(Label.T5).getRecordTypeId();
        String caRecordTypeId = recorTypemap.get(Label.CA).getRecordTypeId();
        
        
          
        for(QueueSObject queObj : Database.query('Select Queue.Name, QueueId, Id From QueueSobject where Queue.Name IN '+Label.Queue_Name)){
            if(queObj.Queue.Name == Label.CA_Email_Nissan){
                nissanQueueId = queObj.QueueId;
            }
            if(queObj.Queue.Name == Label.CA_Email_Infiniti){
                infinityQueueId = queObj.QueueId;
            }
        }
         for (EmailMessage e : emailMsges) {           
            parrentCaseIds.put(e.ParentId, e);
         }
         
         parrentCases = [SELECT Id, OwnerId, CaseNumber, LastModifiedById, Owner.Name, LastModifiedBy.Name, Days_Closed__c, 
                                RecordTypeId, RecordType.Name, Status, CA_CaseReopenCount__c, ContactId, AccountId, Make__c, Type
                         FROM Case WHERE Id IN: parrentCaseIds.keySet()];
        
         Case casobj;                
          for (Case c : parrentCases) {
            if(c.RecordType.Name.containsIgnoreCase('CA Closed Case')){
            if(c.Status.equalsIgnoreCase('Closed')){
                if(c.Days_Closed__c <= 30){
                    casobj = new Case(Id = c.Id, Status='Open', CA_CaseReopenCount__c = c.CA_CaseReopenCount__c + 1, RecordTypeId = caRecordTypeId, Follow_Up_Date__c = Date.today());
                    if(c.Type.equalsIgnoreCase(Label.CA_Email_Nissan)){
                        casobj.RecordTypeId = nissanRecordTypeId;
                    }
                    if(c.Type.equalsIgnoreCase(Label.CA_Email_Infiniti)){
                        casobj.RecordTypeId = infinityRecordTypeId;
                    } 
                    if(c.Type.equalsIgnoreCase('Sales & Service')){
                        casobj.RecordTypeId = caSalesServiceRecordTypeId;
                    } 
                    if(c.Type.equalsIgnoreCase(Label.T5)){
                        casobj.RecordTypeId = t5RecordTypeId;
                    }               
                    casesToUpsert.add(casobj);
                }
                else{
                    EmailMessage prevEmail = parrentCaseIds.get(c.Id);
                    System.debug('prevEmail::'+prevEmail);
                    casesToUpsert.add(new Case(Status='Open',  ContactId = c.ContactId, AccountId = c.AccountId, ParentId =c.Id,Subject = prevEmail.Subject, Description = prevEmail.TextBody,
                                        OwnerId = (c.Make__c != null && c.Make__c.ContainsIgnoreCase('NISSAN')) ? nissanQueueId : infinityQueueId,
                                        RecordtypeId = (c.Make__c != null && c.Make__c.ContainsIgnoreCase('NISSAN')) ? nissanRecordTypeId : infinityRecordTypeId));

                    parentEmails.put(prevEmail.ParentId, prevEmail);
                                                    
                    //tasksToCreate.add(new Task(OwnerId = c.OwnerId, Subject = prevEmail.))                    
                }   
            }
            }
          }

          if(casesToUpsert.size() > 0){
            Database.upsert(casesToUpsert, false);
            System.debug('casesToUpsert::'+casesToUpsert);
            
            for(Case cas : casesToUpsert){
                if(cas.ParentId != null && parentEmails.get(cas.ParentId) != null){                 
                    if(cas.ParentId == parentEmails.get(cas.ParentId).ParentId){
                        parentEmails.get(cas.ParentId).ParentId = cas.Id;
                    }
                }
            }       
        }   
    }
    }