/**********************************************************************
Name: Case_Before_Owner_Update
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
Update Case Owner email field

History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Will Taylor     4/14/2014 Created

***********************************************************************/
trigger Case_Before_OwnerIdUpdate on Case (before insert, before update) {
    Set<String> recordTypeList = new Set<String>();
    recordTypeList.add('012F0000000yCuIIAU');recordTypeList.add('012F0000000yC0BIAU');
    recordTypeList.add('012F0000000yBIrIAM');recordTypeList.add('012F0000000y9y7IAA');
    recordTypeList.add('012F0000000yF8RIAU');

    Map<String,User> users = new Map<String,User>([SELECT Id, Email, Location__c FROM User]);
    
    List<QueueSobject> queuesExcludeQ = [select id from QueueSobject where SobjectType = 'Case'];
    Set<ID> queuesExcludeList = new Set<ID>();
    
    for (QueueSobject r : queuesExcludeQ ) {
        queuesExcludeList.add(r.ID);
    }
    
    for (Case c: Trigger.new) {
      if (recordTypeList.contains(c.RecordTypeId) && c.Ownerid != null) {
            if (c.OwnerId == '005A0000001Y7EkIAK' || queuesExcludeList.contains(c.OwnerId)) {
            } else {
                User user = users.get(c.OwnerId);
                if (user != null && user.Email != null) {
                    c.Case_Owner_Email__c = user.Email;
                    c.Case_Owner_Location2__c = user.Location__c;
                }    
                    
            }
      }
    } 
    
    

    
}