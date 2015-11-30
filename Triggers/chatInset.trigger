trigger chatInset on is1__Chat__c (before insert, before update) {
     List<String> emailList = new List<String>();
     Map<String, is1__Chat__c> chatToEmailMap = new Map<String, is1__Chat__c>();
     
     for(is1__Chat__c chat: Trigger.new){
        if(chat.is1__Email__c != null){
            emailList.add(chat.is1__Email__c);
            chatToEmailMap.put(chat.is1__Email__c, chat);
        }
     }  
        
        List<Account> accountlist = new List<Account>([select id, PersonEmail, Alternate_Email__c FROM Account WHERE (PersonEmail!=null OR Alternate_Email__c != null) AND (PersonEmail in: emailList OR Alternate_Email__c in: emailList) ORDER BY Customer_ID__c ASC]);
     	System.debug('accountlist: ' + accountlist);
        for(Account a: accountList){
            for(Integer i=0; i < emailList.size(); i++ ){ 
                System.debug('a.Alternate_Email__c: ' + a.Alternate_Email__c);
                System.debug('emailList[i] ' +emailList[i]);
                System.debug('a.PersonEmail ' +a.PersonEmail);
                if(a.Alternate_Email__c == emailList[i] || a.PersonEmail == emailList[i]){
                    is1__Chat__c updateChat = chatToEmailMap.get(emailList[i]); 
                   	System.debug(updateChat);
                    updateChat.is1__Account__c = a.id;
                    emailList.remove(i);
                    
                }
                
            }
        }   
        
            
        List<Lead> leadList = new List<Lead>();
        leadList = [select id, Email FROM Lead where Email in: emailList  ORDER BY Customer_ID__c]; 
            for(Lead l: leadList){
                for(Integer i=0; i < emailList.size(); i++ ){ 
                    if(l.Email == emailList[i]){
                        is1__Chat__c updateChat = chatToEmailMap.get(emailList[i]);
                        updateChat.is1__Lead__c = l.id;
                        emailList.remove(i);
                    
                }
                
            }
            
            
        }
        
}