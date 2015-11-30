public with sharing class Controller_AgentConsoleLandingPage {
    public String IncludeString{get;set;}
    public Contact Cont{get;set;}   
    
    
     public Controller_AgentConsoleLandingPage(ApexPages.StandardController controller) {
        String userRoleName = null;
        
        CampaignMember camp = null;
        List<Task> taskList = new List<Task>();
        Id cId = ((Contact) controller.getRecord()).Id;
        Cont = (Contact) controller.getRecord();
             
        List<User> userList = [Select id,name,UserRoleId,IsActive From User where Id =: UserInfo.getUserId() and IsActive = TRUE limit 1];
        
        if(userList.size() > 0) {
	    	if (userList[0].UserRoleId != Null) {
	    		UserRole userRole = [Select Name, Id From UserRole  where Id = :userList[0].UserRoleId limit 1]; 
				userRoleName = userRole.Name;
	    	}
        }
        
        try {  
            
			camp = [select id, CampaignMember.Campaign.CreatedDate FROM CampaignMember WHERE CampaignMember.Campaign.isActive = TRUE AND CampaignMember.ContactId =: cId order by CampaignMember.Campaign.CreatedDate desc limit 1];
			
			//sjd Commented Below
			//taskList = [select id, WhoId FROM Task WHERE Task.WhoId =: cId];
			//if (taskList != null && taskList.size() > 0 && camp != null)
			//sjd Commented Above
			
			/*
			  If the logged in user's role is "Service Marketing" then only page should be redirected to Agent Console
			  page or else redirect to standard contact page.
			*/
		    
		    if (( camp != null )&& ((userRoleName != null)&& (userRoleName.equalsIgnoreCase(System.Label.ServiceMarketing)))) { //sjd added this line
				IncludeString =  system.label.AgentConsole;
		    }
		    else {
		   	  	IncludeString = system.label.StandardContact;
		    }
   		} 
        catch(Exception e) {
            IncludeString = system.label.StandardContact;   
        }
        
        system.debug('IncludeString:  '  +  IncludeString); 
        system.debug('camp:  '  + camp);
        //sjd commented below
        //system.debug('taskList:  '  + taskList);
     }
    
    public Contact getContact(){
        return Cont;
        
    }
    
    
    public String getIncludeString(){
        return IncludeString;
        
    }
    

}