/**********************************************************************
Name: Controller_ManageCases
Copyright ¬© notice: Nissan Motor Company
======================================================
Purpose:
Controller of CreateNewCase page

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Anna Koseikina - 12/24/2014 - Created
***********************************************************************/
public class Controller_CreateNewCase {
	public Case caseItem{get;set;}
    public Controller_CreateNewCase(ApexPages.StandardController controller) {
		String CurrentUserId = userinfo.getuserid();
        User currentuser = [SELECT Id, Assigned_Department__c, Email FROM User WHERE Id=:CurrentUserId LIMIT 1];
		caseItem = new Case();
		caseItem.ContactId = [SELECT Id FROM Contact WHERE Email=:currentuser.Email LIMIT 1].Id;
		caseItem.Requesting_Department__c = currentuser.Assigned_Department__c;
    }  

	public PageReference saveAction(){
		RecordType rt = [select Id from RecordType where Name = 'Managed Services' and SobjectType = 'Case' limit 1];
		caseItem.RecordTypeId = rt.Id;
		try {
			insert caseItem;
		} catch (Exception e) {
			return null;
		}
		
		return Page.ManageCases; 
	}
 }