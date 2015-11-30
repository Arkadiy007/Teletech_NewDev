/**********************************************************************
Name: Warranty_case_Trigger
Copyright © notice: Nissan Motor Company., TeleTech eLoyalty
======================================================
Purpose:
Whenever a warranty case is updated and the VCAN fields change we will,
call the host system with an update VCAN call

Related Class : Warranty_Case__c
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Aaron Bessey 8/14/2014 - Created                     

***********************************************************************/

trigger Warranty_Case_Trigger on Warranty_Case__c (before update) {
    Warranty_Case__c oldCase;
    Warranty_Case__c newCase;
    
    Set<Id> caseIds = new Set<Id>();
    Map<Id, Warranty_Case__c> caseMap = new Map<Id, Warranty_Case__c>();
    List<Warranty_Case__c> cases;    
    
    String ZCA_Id;
    String CaseName;
    Double approvalLimit;    
    //Log in the debug logs
    Boolean isTestRunning = (Label.VCAN_Debug_VCAN_Errors=='true' || Test.isRunningTest()) ? true : false;
    
    User thisUser = [select ID, warranty_app_amount__c, warranty_vcan_delete__c, ZCA_Id__c from User where Id=:System.UserInfo.getUserId()];
    
    String tmpLimit = thisUser.warranty_app_amount__c;
    if(tmpLimit!= null && tmpLimit != '')
    {
        approvalLimit = Double.valueOf(thisUser.warranty_app_amount__c);
    }
    else
    {
        approvalLimit = 0;
    }
    if(isTestRunning)
    {
        System.debug('ZCA ID:' + ZCA_Id + ' Approval Limit:' + approvalLimit);
    }
    
    for (Integer i = 0; i < Trigger.new.size(); i++) 
    {
        caseIds.Add(Trigger.new[i].Id);
    }
    
    cases = [select ID, Name, Dealer_Code__c, Vehicle__r.Name, Repair_Work_Order__c, 
             Job_Line_Number__c, Customer_Concern__c,
             Repair_Work_Order_Open_Date__c,
             Vehicle_Mileage__c,
             Primary_Failed_Part__c,
             Vehicle_Campaign1__c,
             Requestor_s_Name__c,
             Customer_Name__c,
             Parts_at_Cost__c,
             Force_Goodwill_Coverage__c,
             Parts__c,
             Labor__c,
             Expenses__c,
             Total_Amount_Approved__c,
             Requestor_s_Phone_Number__c,
             Internal_Comments__c,
             Approval_Information__c,
             Approval_Status__c, 
             Normal_Approval__c,
             Repeat_Repair_Review__c,
             Mileage__c,
             Duplicate_Campaign_Different_Dealer__c,
             Goodwill_Approval__c,
             HOST_Error_Message__c, HOST_Reference_Number__c,
             Host_Comments__c, LastModifiedDate, LastModifiedById, LastModifiedBy.Name,
             isVCANUpdate__c, isSystemUpdate__c, isApprovalStatusChanged__c
             from Warranty_Case__c where Id in :caseIds];
    
    for (Integer i = 0; i < cases.size(); i++) 
    {
        caseMap.put(cases[i].Id, cases[i]);
    }
    
    Warranty_Case__c wc;
    
    if (Trigger.isUpdate) 
    {
        Boolean onlyCommentUpdated = false;
        for (Integer i = 0; i < Trigger.new.size(); i++) 
        {
            oldCase = Trigger.old[i];
            newCase = Trigger.new[i];
            
            wc = caseMap.get(newCase.Id);
            
            CaseName = wc.Name;

			if(newCase.isApprovalStatusChanged__c == true)
            {
                newCase.isApprovalStatusChanged__c = false;
            }
            
            if(newCase.Repair_Work_Order__c!=oldCase.Repair_Work_Order__c
               || newCase.Job_Line_Number__c!=oldCase.Job_Line_Number__c
               || newCase.Vehicle__c!=oldCase.Vehicle__c
               || newCase.Dealer_Code__c!=oldCase.Dealer_Code__c
              )
            {
                newCase.HOST_Reference_Number__c = '';
                newCase.HOST_Comments__c = '';
                newCase.HOST_Error_Message__c = '';
                newCase.isVCANUpdate__c = false;
                newCase.isSystemUpdate__c = false;
                if(isTestRunning)
                {
                    system.debug('Trigger ended due to: Key Field Value Changes');
                }
                continue;
            }
            
            if(newCase.isSystemUpdate__c)
            {
                newCase.isSystemUpdate__c = false;
                if(isTestRunning)
                {
                    system.debug('Trigger ended due to: System Update');
                }
                continue;
            }
            
            if(wc.HOST_Reference_Number__c==null)
            {
                if(isTestRunning)
                {
                    system.debug('Trigger ended due to: HOST_Reference_Number__c==null');
                }
                continue;
            }
            
            if(wc.isVCANUpdate__c==true)
            {
                if(isTestRunning)
                {
                    system.debug('Trigger ended due to: isVCANUpdate already true');
                }
                continue;
            }
            
            if(newCase.Approval_Information__c != null && newCase.Approval_Information__c.indexOf('**SFDCUPDATE**')>-1)
            {
                newCase.Approval_Information__c = newCase.Approval_Information__c.substring(14);
                newCase.isVCANUpdate__c = true;
                if(isTestRunning)
                {
                    system.debug('Trigger ended due to: Approval Information contains **SFDCUPDATE**');
                }
                continue;
            } 
            
            onlyCommentUpdated = false;
            if(newCase.Repair_Work_Order_Open_Date__c==oldCase.Repair_Work_Order_Open_Date__c
               && newCase.Vehicle_Mileage__c==oldCase.Vehicle_Mileage__c
               && newCase.Primary_Failed_Part__c==oldCase.Primary_Failed_Part__c
               && newCase.Vehicle_Campaign1__c==oldCase.Vehicle_Campaign1__c
               && newCase.Requestor_s_Name__c==oldCase.Requestor_s_Name__c
               && newCase.Customer_Name__c==oldCase.Customer_Name__c
               && newCase.Parts_at_Cost__c==oldCase.Parts_at_Cost__c
               && newCase.Normal_Approval__c==oldCase.Normal_Approval__c
               && newCase.Repeat_Repair_Review__c==oldCase.Repeat_Repair_Review__c
               && newCase.Mileage__c==oldCase.Mileage__c
               && newCase.Duplicate_Campaign_Different_Dealer__c==oldCase.Duplicate_Campaign_Different_Dealer__c
               && newCase.Goodwill_Approval__c==oldCase.Goodwill_Approval__c
               && newCase.Parts__c==oldCase.Parts__c
               && newCase.Labor__c==oldCase.Labor__c
               && newCase.Expenses__c==oldCase.Expenses__c
               && newCase.Total_Amount_Approved__c==oldCase.Total_Amount_Approved__c
               && newCase.Force_Goodwill_Coverage__c==oldCase.Force_Goodwill_Coverage__c
               && newCase.Requestor_s_Phone_Number__c==oldCase.Requestor_s_Phone_Number__c
               && newCase.Approval_Status__c==oldCase.Approval_Status__c)
            {
                if(newCase.Approval_Information__C==null)
                {
                    if(isTestRunning)
                    {
                        system.debug('Trigger ended due to: VCAN Fields all equal to previous values and VCAN Comments=Null');
                    }
                    continue;
                }
                else if(newCase.Approval_Information__c!=oldCase.Approval_Information__c)
                {
                    if(isTestRunning)
                    {
                        system.debug('Only change was a new comment:' + newCase.Approval_Information__c);
                    }
                    onlyCommentUpdated = true;
                }
                else
                {
                    //Nothing at all changed exit loop
                    if(isTestRunning)
                    {
                        system.debug('Trigger ended due to: VCAN Fields all equal to previous values and VCAN Comments equal to previous comments');
                    }
                    continue;
                }
            }
            
            if(newCase.Repair_Work_Order__c==null 
               || newCase.Job_Line_Number__c==null 
               || newCase.Vehicle__c==null 
               || newCase.Dealer_Code__c==null
               || newCase.Repair_Work_Order_Open_Date__c==null
               || newCase.Vehicle_Mileage__c==null 
               || (newCase.Primary_Failed_Part__c==null && newCase.Vehicle_Campaign1__c==null)
               || newCase.Customer_Name__c == null)
            {        
                if(isTestRunning)
                {
                    system.debug('Null Case Fields: ' + 
                                 (newCase.Repair_Work_Order__c==null?'WO':'') + '|' +
                                 (newCase.Job_Line_Number__c==null?'Line':'') +'|' +
                                 (newCase.Vehicle__c==null?'Vehicle':'') +'|' +
                                 (newCase.Dealer_Code__c==null?'Dealer Code':'') +'|' +
                                 (newCase.Repair_Work_Order_Open_Date__c==null?'WODate':'') +'|' +
                                 (newCase.Vehicle_Mileage__c==null?'Miles':'') +'|' +
                                 (newCase.Primary_Failed_Part__c==null?'Part':'') +'|' +
                                 (newCase.Vehicle_Campaign1__c==null?'Campaign':'') +'|' +
                                 (newCase.Customer_Name__c==null?'Cust Name':'') + '|'
                                );
                    system.debug('Trigger ended due to: Null VCAN Fields');
                }
                continue;
            }           
            
            if(newCase.Total_Amount_Approved__c>approvalLimit)
            {
                if(!onlyCommentUpdated)
                {
                    if(newCase.Approval_Status__c!='Pending')
                    {
                        newCase.Approval_Status__c = 'Pending';  
                        newCase.isApprovalStatusChanged__c = true;
                    }
                }
                else
                {
                    if(isTestRunning)
                    {
                        system.debug('Total Amount Approved > approvalLimit but comments are the only changed values');
                    }
                }
            }   
            else
            {
                if(isTestRunning)
                {
                    system.debug('ApprovalLimit:' + approvalLimit + ' NewCase Total:' + newCase.Total_Amount_Approved__c);
                    system.debug('WC Total:' + wc.Total_Amount_Approved__c);
                }
            }
            
            if(newCase.Approval_Information__c==null || newCase.Approval_Information__c=='')
            {
                newCase.Approval_Information__c = Label.VCAN_Auto_Update_Comment;
            }
            
            newCase.isVCANUpdate__c = true;
        }
    }
}