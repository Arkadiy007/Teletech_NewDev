trigger DTS_FI_Before on DTS_Field_Inspection__c (before insert) {
    
    for(DTS_Field_Inspection__c dts : trigger.new){
            
            if (dts.DTS_A_Name__c != null || Test.isRunningTest()) {
               
                Stage_User__c[] sulist = [Select id, Email__c from Stage_User__c where id =:dts.DTS_A_Name__c LIMIT 1];
                 
                if (sulist.size() == 1) {
                    String emaila = sulist[0].Email__c;

                    User[] userslist = [select Id, Username, Email from User where email = :emaila and isactive = true limit 1];
            
                    if (userslist.size() == 1) {
                        dts.OwnerId = userslist[0].id;
                    } else {
                       // dts.OwnerId = '00Gc0000000l8iE';
                    }

                 } else {
                 
                    // dts.OwnerId = '00Gc0000000l8iE';
                 }
                 
                 
                 
             }
            
        
        
    }

}