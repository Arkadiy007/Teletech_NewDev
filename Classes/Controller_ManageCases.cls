/**********************************************************************
Name: Controller_ManageCases
Copyright ¬© notice: Nissan Motor Company
======================================================
Purpose:
Controller of ManageCases page

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Anna Koseikina - 12/24/2014 - Created
***********************************************************************/
public with sharing class Controller_ManageCases {
	public boolean canLogCases{get;set;}
	public String myCasesFilter{get;set;}
	public String myDeptCasesFilter{get;set;}
	private Department_Cases_Access__c departCasesAccess = Department_Cases_Access__c.getOrgDefaults();
	private User currentuser = new User();
	private Contact cont = new Contact();
	private Map<Integer,Case> myCases = new Map<Integer,Case>();
	private Map<Integer,Case> myDeptCases = new Map<Integer,Case>();
    public Map<Integer,Case> openCases{
        get{			
					
			if(!String.isEmpty(currentuser.Assigned_Department__c)){
				return myDeptCases;
			}else{
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Assigned Department of User is not defined.');
				ApexPages.addMessage(myMsg);
				return null;
			}
        } 
        set;
    }

	public Map<Integer,Case> myOpenCases{
        get{	
			if(!String.isEmpty(currentuser.Assigned_Department__c)){
				return myCases;					
			} else{
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Assigned Department of User is not defined.');
				ApexPages.addMessage(myMsg);
				return null;
			}
		}
        set;
    }
    public Controller_ManageCases() {

    }

    public Controller_ManageCases(ApexPages.StandardController controller) {
        // retrieve the Default Organization Level Value of 'Department Cases Access' custom setting
		if ((departCasesAccess==null) || (departCasesAccess.id == null)) {
			departCasesAccess = new Department_Cases_Access__c();
			insert departCasesAccess;
			departCasesAccess = Department_Cases_Access__c.getOrgDefaults();
		}
		
		String CurrentUserId = userinfo.getuserid();
        currentuser = [SELECT Id, Assigned_Department__c, Name, Email FROM User WHERE Id=:CurrentUserId LIMIT 1];
		List<Contact> contacts = [SELECT Id, AccountId, Email, Name FROM Contact WHERE Name=:currentuser.Name AND Email=:currentuser.Email];
		if (contacts.size() > 0){
			cont = contacts[0];
		}
		myCasesFilter = 'My Open Cases';
		myDeptCasesFilter = 'My Department\'s Open Cases';
		queryMyCases();
		queryMyDeptCases();
    }

	public PageReference createNewCase()
	{
		if (canLogCases){
			return Page.CreateNewCase;
		}else{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Contact is not found or cannot log Cases.');
			ApexPages.addMessage(myMsg);
			return null;
		}
		
	}

	public List<SelectOption> getMyCasesOptions() {
        List<SelectOption> casesOptions = new List<SelectOption>();
        casesOptions.add(new SelectOption('My Open Cases','My Open Cases'));
        casesOptions.add(new SelectOption('My Closed Cases','My Closed Cases'));
 
        return casesOptions;
    }

	public void queryMyCases(){
		myCases = new Map<Integer,Case>();
		// id of Nissan Internal Account
		String nissanAccId = departCasesAccess.Nissan_Internal_Account_Id__c;			           
			
		if(cont != null && cont.AccountId.equals(nissanAccId)){
			canLogCases = true;
		}else{
			canLogCases = false;
		}
		Integer i = 0;
		RecordType rt = [select Id from RecordType where Name = 'Managed Services' and SobjectType = 'Case' limit 1];
				
		if(myCasesFilter.equals('My Open Cases')){		
			for(Case c : [SELECT ID, CaseNumber, Subject, Origin, Status, Issue_Type__c, Issue_Details__c, CreatedDate, Requesting_Department__c FROM Case WHERE Requesting_Department__c=:currentuser.Assigned_Department__c AND Status!='Closed' AND RecordTypeId=:rt.Id AND OwnerId=:currentuser.Id]){
				myCases.put(i,c);
				i++;
			}
		}else{
			for(Case c : [SELECT ID, CaseNumber, Subject, Origin, Status, Issue_Type__c, Issue_Details__c, CreatedDate, Requesting_Department__c FROM Case WHERE Requesting_Department__c=:currentuser.Assigned_Department__c AND Status='Closed' AND RecordTypeId=:rt.Id AND OwnerId=:currentuser.Id]){
				myCases.put(i,c);
				i++;
			}
		}			
	}

	public List<SelectOption> getMyDeptCasesOptions() {
        List<SelectOption> casesOptions = new List<SelectOption>();
        casesOptions.add(new SelectOption('My Department\'s Open Cases','My Department\'s Open Cases'));
        casesOptions.add(new SelectOption('My Department\'s Closed Cases','My Department\'s Closed Cases'));
 
        return casesOptions;
    }

	public void queryMyDeptCases(){
		myDeptCases = new Map<Integer,Case>();
		// id of Nissan Internal Account
		String nissanAccId = departCasesAccess.Nissan_Internal_Account_Id__c;			
		if(cont != null && cont.AccountId.equals(nissanAccId)){
				canLogCases = true;
		}else{
				canLogCases = false;
		}
		Integer i = 0;
		RecordType rt = [select Id from RecordType where Name = 'Managed Services' and SobjectType = 'Case' limit 1];
		if(myDeptCasesFilter.equals('My Department\'s Open Cases')){					
			for(Case c : [SELECT ID, CaseNumber, Subject, Origin, Status, Issue_Type__c, Issue_Details__c, CreatedDate, Requesting_Department__c FROM Case WHERE Requesting_Department__c=:currentuser.Assigned_Department__c AND Status!='Closed' AND RecordTypeId=:rt.Id]){
				myDeptCases.put(i,c);
				i++;
			}
			
		}else{						
			for(Case c : [SELECT ID, CaseNumber, Subject, Origin, Status, Issue_Type__c, Issue_Details__c, CreatedDate, Requesting_Department__c FROM Case WHERE Requesting_Department__c=:currentuser.Assigned_Department__c AND Status='Closed' AND RecordTypeId=:rt.Id]){
				myDeptCases.put(i,c);
				i++;
			}		
		}	
	}
}