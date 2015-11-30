/**********************************************************************
  Name: CaseAfterHelper
  Copyright � notice: Nissan Motor Company
  ======================================================
  Purpose: 
  Helper for Case_After trigger
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL 
  1.0 - Anna Koseikina    2/2/2015 Created, moved all code from Case_After trigger into this separate class
  1.1 - Arkadiy Sychev    03/27/2015 Add logic for process 'Ignored Case recordTypes' (list of recordTypes for which notification aren't created) 
  and 'Users Who Can View All Updates' (list of users, who can get update nofifications for Cases with ignored recordTypes) 
  fields of MCC Custom Setting.
 ***********************************************************************/
public class CaseAfterHelper {
	// 1.1 Arkadiy Sychev - custom settings for Case Notification Logic
	private static Case_Notification_Settings__c caseNotifSettings;
	private static MCC_Custom_Setting__c mccCustomSetting;
	private static Map<Id, User> allowedUsersMap;
	public static boolean firstRun = true;

	private static Map<Id, Case> caseWithRetrievedLookupInfo = new Map<Id, Case> (); // retains Cases with Names of related loockup records. 
	//The tracked lookups are determines by customLookupsThatMayBeTracked
	private static Map<String, String> customLookupsThatMayBeTracked = new Map<String, string> { // the map of possibly tracked lookup fields of Case object
		'ownerid' => 'owner.name',
		'accountid' => 'account.name',
		'contactid' => 'contact.name',
		'dealer__c' => 'dealer__r.name',
		'escalated_user__c' => 'escalated_user__r.name'
	};

	public void notifications(boolean isUpdate, List<Case> cases, Map<ID, Case> oldMap) {
		// 1.18 - Notifications creation for Case updates.
		// 1.19 - Implemented additional logic on notifications creation for updated Cases
		if (isUpdate) {
			createNotificationsForCases(cases, oldMap);
		}
	}

	/*
	 * Notification is created when Case is updated or owner is changed.
	 * If owner is changed Case_Notification_Settings__c custom setting determines if notification should be created for old owner, new owner or both.
	 * If no owner preferences set in Case_Notification_Settings__c - notification is created for new owner only.
	 * Additionally Case_Notification_Settings__c specifies changes from what users should be ignored. By default these users are: Services,NNAINT,NNAETL
	 * Additionally Case_Notification_Settings__c specifies should notification be created when any Case record fields are changed or only when tracked fields are changed.
	 * Additionally Case_Notification_Settings__c specifies should notification show tracked fields changes history or not.
	 * List of fielde which should be tracked is determined in Fields_Tracked_Per_Update Case Field Set.
	 */
	private static void createNotificationsForCases(List<Case> updatedCases, Map<Id, Case> oldMap) {
		caseWithRetrievedLookupInfo = new Map<Id, Case> ([SELECT Id, Owner.Name, Account.name, Contact.Name, Dealer__r.Name, Escalated_User__r.Name
		                                                 FROM Case WHERE Id IN :oldMap.keySet()]);

		//1.1 Arkadiy Sychev - List of updatedCases's Recordtype ids
		Set<Id> recordTypeIds = new Set<Id> ();
		for (case c : updatedCases) {
			recordTypeIds.add(c.RecordTypeId);
		}
		//1.1 Arkadiy Sychev - retrieving Map of updatedCases's RecordType
		Map<id, RecordType> recordTypeMap = new Map<Id, RecordType> ([SELECT Id, Name FROM RecordType WHERE Id IN :recordTypeIds]);


		// retrieve the Default Organization Level Value of 'Case Notification Settings' custom setting
		caseNotifSettings = Case_Notification_Settings__c.getOrgDefaults();
		if ((caseNotifSettings == null) || (caseNotifSettings.id == null)) {
			caseNotifSettings = new Case_Notification_Settings__c();
			insert caseNotifSettings;
			caseNotifSettings = Case_Notification_Settings__c.getOrgDefaults();
		}

		// 1.1 Arkadiy Sychev - retrieve the Default Organization Level Value of 'MCC Custom Setting' custom setting
		mccCustomSetting = MCC_Custom_Setting__c.getOrgDefaults();
		if ((mccCustomSetting == null) || (mccCustomSetting.id == null)) {
			mccCustomSetting = new MCC_Custom_Setting__c();
			insert mccCustomSetting;
			mccCustomSetting = MCC_Custom_Setting__c.getOrgDefaults();
		}

		// set of all Case fields 
		Set<String> schemaCaseFields = Schema.SObjectType.Case.fields.getMap().keySet();

		// set of the tracked Case fields
		Set<String> trackedFeilds = new Set<String> ();
		//List<Schema.FieldSetMember> trackedFields = SObjectType.Case.FieldSets.Fields_Tracked_Per_Update.getFields();
		//There is possibility that Fields_Tracked_Per_Update fieldset on Case aren't presented
		try {
			for (Schema.FieldSetMember fieldMember : SObjectType.Case.FieldSets.Fields_Tracked_Per_Update.getFields()) {
				trackedFeilds.add(fieldMember.getFieldPath().toLowerCase());
			}
		}
		catch(Exception e) {
			System.debug('There are some issues with Fields_Tracked_Per_Update fieldset : ' + e.getMessage());
		}
		// set of the ignored users
		Set<String> ignoredUsers = new Set<String> ();
		try {
			ignoredUsers.addAll(caseNotifSettings.Ignored_Users__c.split(','));
			ignoredUsers.addAll(caseNotifSettings.Ignored_Users_2__c.split(','));
		} catch(Exception e) {
		}

		// 1.1 Arkadiy Sychev - set of the MCC RecordTypes
		Set<String> mCCRecordTypes = new Set<String> ();
		try {
			mCCRecordTypes.addAll(mccCustomSetting.MCC_Case_recordTypes__c.split(','));
		} catch(Exception e) {
		}

		// 1.1 Arkadiy Sychev - set of the users who can get notifications from MCC RecordTypes
		Set<String> allowedUsers = new Set<String> ();
		try {
			allowedUsers.addAll(mccCustomSetting.Users_Who_Can_View_MCC_Updates__c.split(','));
		} catch(Exception e) {
		}
		allowedUsersMap = new Map<Id, User> ([SELECT Id FROM USER WHERE Name In :allowedUsers]);

		// set of all LastModifiedById for Trigger.new and Trigger.old Cases
		// 1.1 Arkadiy Sychev - lastModUsersIds is changed to lastModUsersAndOwnersIds
		Set<Id> lastModUsersAndOwnersIds = new Set<Id> ();
		for (Case c : updatedCases) {
			lastModUsersAndOwnersIds.add(c.LastModifiedById);
			lastModUsersAndOwnersIds.add(oldMap.get(c.Id).LastModifiedById);
			lastModUsersAndOwnersIds.add(c.OwnerId);
			lastModUsersAndOwnersIds.add(oldMap.get(c.Id).OwnerId);
		}

		// map of all useers whom Ids are in lastModUsersAndOwnersIds map
		// 1.1 Arkadiy Sychev - lastModUsers is changed to lastModUsersAndOwners
		Map<Id, User> lastModUsersAndOwners = new Map<Id, User> ([SELECT Id, Name, LastName FROM User WHERE Id IN :lastModUsersAndOwnersIds]);

		List<Notification__c> notificationList = new List<Notification__c> ();
		if (caseNotifSettings.Create_Notification_On_Update__c) {
			for (case cCase : updatedCases) {
				Set<String> modifiedFields = setOfChangedFields(cCase, oldMap.get(cCase.Id), schemaCaseFields);
				String currentRecordType = recordTypeMap.get(cCase.RecordTypeId).Name;

				if (mCCRecordTypes.contains(currentRecordType)) {
					notifyOnAnyFieldUpdateProcessingForMCC(trackedFeilds, modifiedFields, ignoredUsers, cCase, oldMap, notificationList, lastModUsersAndOwners);
				} else {
					notifyOnAnyFieldUpdateProcessing(trackedFeilds, modifiedFields, ignoredUsers, cCase, oldMap, notificationList, lastModUsersAndOwners);
				}
			}
			try {
				insert notificationList;
			}
			catch(Exception e) {
				System.debug('Exception occured on notification creation: ' + e.getMessage());
			}
		}
	}

	// 1.1 Arkadiy Sychev
	// First Condition
	private static void notifyOnAnyFieldUpdateProcessing(Set<String> trackedFeildsLocal, Set<String> modifiedFieldsLocal, Set<String> ignoredUsersLocal, case cCaseLocal,
	                                                     Map<Id, Case> oldMapLocal, List<Notification__c> notificationListLocal, Map<Id, User> lastModUsersLocal) {
		if (!caseNotifSettings.Notify_On_Any_Field_Update__c) {
			Boolean isTrackingFieldsChanges = isSetsIntersection(trackedFeildsLocal, modifiedFieldsLocal);
			trackedFeildsLocal.retainAll(modifiedFieldsLocal);
			if (isTrackingFieldsChanges) {
				if (ignoredUsersLocal.isEmpty() || (ignoredUsersLocal == null) || (!ignoredUsersLocal.contains(UserInfo.getName()))) {
					Case oldCCase = oldMapLocal.get(cCaseLocal.Id);
					ownerChangedProcessing(cCaseLocal, oldCCase, caseNotifSettings, notificationListLocal, lastModUsersLocal, trackedFeildsLocal);


				}
			}
		} else {
			trackedFeildsLocal.retainAll(modifiedFieldsLocal);
			if (ignoredUsersLocal.isEmpty() || (ignoredUsersLocal == null) || (!ignoredUsersLocal.contains(UserInfo.getName()))) {
				Case oldCCase = oldMapLocal.get(cCaseLocal.Id);
				ownerChangedProcessing(cCaseLocal, oldCCase, caseNotifSettings, notificationListLocal, lastModUsersLocal, trackedFeildsLocal);

			}
		}
	}
	// 1.1 Arkadiy Sychev - First condition method for MCC
	private static void notifyOnAnyFieldUpdateProcessingForMCC(Set<String> trackedFeildsLocal, Set<String> modifiedFieldsLocal, Set<String> ignoredUsersLocal, case cCaseLocal,
	                                                           Map<Id, Case> oldMapLocal, List<Notification__c> notificationListLocal, Map<Id, User> lastModUsersLocal) {
		if (!caseNotifSettings.Notify_On_Any_Field_Update__c) {
			Boolean isTrackingFieldsChanges = isSetsIntersection(trackedFeildsLocal, modifiedFieldsLocal);
			trackedFeildsLocal.retainAll(modifiedFieldsLocal);
			if (isTrackingFieldsChanges) {
				if (ignoredUsersLocal.isEmpty() || (ignoredUsersLocal == null) || (!ignoredUsersLocal.contains(UserInfo.getName()))) {
					Case oldCCase = oldMapLocal.get(cCaseLocal.Id);
					//ownerChangedProcessing(cCaseLocal, oldCCase, caseNotifSettings, notificationListLocal, lastModUsersLocal, trackedFeildsLocal);
					showFieldHistoryProcessingForMCC(caseNotifSettings, cCaseLocal, notificationListLocal, lastModUsersLocal, trackedFeildsLocal);

				}
			}
		} else {
			trackedFeildsLocal.retainAll(modifiedFieldsLocal);
			if (ignoredUsersLocal.isEmpty() || (ignoredUsersLocal == null) || (!ignoredUsersLocal.contains(UserInfo.getName()))) {
				Case oldCCase = oldMapLocal.get(cCaseLocal.Id);
				//ownerChangedProcessing(cCaseLocal, oldCCase, caseNotifSettings, notificationListLocal, lastModUsersLocal, trackedFeildsLocal);
				showFieldHistoryProcessingForMCC(caseNotifSettings, cCaseLocal, notificationListLocal, lastModUsersLocal, trackedFeildsLocal);
			}
		}
	}
	// Second Condition
	private static void ownerChangedProcessing(Case c, Case oldCase, Case_Notification_Settings__c cCaseNotifSettings, List<Notification__c> cNotificationList, Map<Id, User> cLastModUsers, Set<String> cTrackedFeildsSet) {
		if (isOwnerChanged(oldCase, c)) {
			if (cCaseNotifSettings.Attach_To_New_Owner__c || !(cCaseNotifSettings.Attach_To_New_Owner__c || cCaseNotifSettings.Attach_To_Previous_Owner__c)) {
				if (!UserInfo.getUserId().equals(c.OwnerId)) {
					showFieldHistoryProcessing(cCaseNotifSettings, c, cNotificationList, cLastModUsers, cTrackedFeildsSet);
				}
			}

			if (cCaseNotifSettings.Attach_To_Previous_Owner__c) {
				if (!UserInfo.getUserId().equals(oldCase.OwnerId)) {
					showFieldHistoryProcessing(cCaseNotifSettings, oldCase, cNotificationList, cLastModUsers, cTrackedFeildsSet);
				}
			}
		} else if (!UserInfo.getUserId().equals(c.OwnerId)) {
			showFieldHistoryProcessing(cCaseNotifSettings, c, cNotificationList, cLastModUsers, cTrackedFeildsSet);
		}
	}

	//Third Condition
	private static void showFieldHistoryProcessing(Case_Notification_Settings__c caseNotificationSettings, Case processedCase,
	                                               List<Notification__c> notificList, Map<Id, User> lastModUsersMap, Set<String> trackedFeildsSet) {
		if (caseNotificationSettings.Show_Field_History__c) {
			if (string.valueOf(processedCase.OwnerId).startsWith('005'))
			notificList.add(createNotificationWithFieldHistory(processedCase, processedCase.OwnerId, lastModUsersMap, trackedFeildsSet));
		} else {
			if (string.valueOf(processedCase.OwnerId).startsWith('005'))
			notificList.add(createNotification(processedCase, processedCase.OwnerId, lastModUsersMap));
		}
	}

	// 1.1 Arkadiy Sychev - Third condition method for MCC
	private static void showFieldHistoryProcessingForMCC(Case_Notification_Settings__c caseNotificationSettings, Case processedCase,
	                                                     List<Notification__c> notificList, Map<Id, User> lastModUsersMap, Set<String> trackedFeildsSet) {
		if (caseNotificationSettings.Show_Field_History__c) {
			notificList.addAll(createNotificationsWithFieldHistoryForMCC(processedCase, allowedUsersMap.keySet(), lastModUsersMap, trackedFeildsSet));
		} else {
			notificList.addAll(createNotificationsForMCC(processedCase, allowedUsersMap.keySet(), lastModUsersMap));
		}
	}

	// Create simple Notification
	private static Notification__c createNotification(Case updatedCase, Id assigneeId, Map<Id, User> usersMap) {
		Notification__c notification = new Notification__c(Assigned_To__c = assigneeId,
		                                                   Related_Object_ID__c = String.valueOf(updatedCase.Id),
		                                                   Status__c = 'Open',
		                                                   Allow_Dismiss__c = true,
		                                                   Related_Object_Type__c = 'Case',
		                                                   Subject__c = 'LINK[Case-' + updatedCase.CaseNumber + ',' + updatedCase.Id + '] Update',
		                                                   LongDescription__c = 'Case updated by LINK[' + usersMap.get(updatedCase.LastModifiedById).Name + ',' + String.valueOf(updatedCase.LastModifiedById) + ']');

		return notification;
	}

	// 1.1 Arkadiy Sychev - Create list of simple Notifications for users which are in Users_Who_Can_View_All_Updates__c field of MCC Custom Settings
	private static List<Notification__c> createNotificationsForMCC(Case updatedCase, Set<Id> assigneeIdList, Map<Id, User> usersMap) {
		List<Notification__c> result = new List<Notification__c> ();
		for (Id aId : assigneeIdList) {
			result.add(createNotification(updatedCase, aId, usersMap));
		}

		return result;
	}

	// Create Notification with fields history. The method creates notification when it should contain tracked fields changing history in description.
	private static Notification__c createNotificationWithFieldHistory(Case updatedCase, Id assigneeId, Map<Id, User> usersMap, Set<String> modifFields) {
		String longDescription = 'Case updated by LINK[' + usersMap.get(updatedCase.LastModifiedById).Name + ',' + String.valueOf(updatedCase.LastModifiedById) + '] <br> ';
		Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Case.fields.getMap();

		for (String field : modifFields) {
			if (customLookupsThatMayBeTracked.containsKey(field)) {
				String lookupField = customLookupsThatMayBeTracked.get(field);
				String[] splitedFieldNameAndName = lookupField.split('\\.');
				String lookupObjectName = splitedFieldNameAndName[0];
				String lookupObjectFieldName = splitedFieldNameAndName[1];
				SObject caseWithLookupInfo = caseWithRetrievedLookupInfo.get(updatedCase.Id);
				SObject lookupObject = caseWithLookupInfo.getSObject(lookupObjectName);

				if (null == lookupObject) {
					longDescription += '<br> ' + fieldMap.get(field).getDescribe().getLabel().removeEndIgnoreCase('id') + ': not assigned';
				} else {
					longDescription += '<br> ' + fieldMap.get(field).getDescribe().getLabel().removeEndIgnoreCase('id') + ': ' + lookupObject.get(lookupObjectFieldName);
				}
			} else {
				longDescription += '<br> ' + fieldMap.get(field).getDescribe().getLabel() + ': ' + updatedCase.get(field);
			}
		}

		Notification__c notification = new Notification__c(Assigned_To__c = assigneeId,
		                                                   Related_Object_ID__c = String.valueOf(updatedCase.Id),
		                                                   Status__c = 'Open',
		                                                   Allow_Dismiss__c = true,
		                                                   Related_Object_Type__c = 'Case',
		                                                   Subject__c = 'LINK[Case-' + updatedCase.CaseNumber + ',' + updatedCase.Id + '] Update',
		                                                   LongDescription__c = longDescription);

		return notification;
	}

	// 1.1 Arkadiy Sychev - Create list of Notifications with fields history for users which are in Users_Who_Can_View_All_Updates__c field of MCC Custom Settings
	private static List<Notification__c> createNotificationsWithFieldHistoryForMCC(Case updatedCase, Set<Id> assigneeIdList, Map<Id, User> usersMap, Set<String> modifFields) {
		List<Notification__c> result = new List<Notification__c> ();
		for (Id aId : assigneeIdList) {
			result.add(createNotificationWithFieldHistory(updatedCase, aId, usersMap, modifFields));
		}

		return result;
	}

	private static boolean isOwnerChanged(Case caseA, Case caseB) {
		if (caseA != null && caseB != null) {
			return !caseA.OwnerId.equals(caseB.OwnerId);
		}
		// exception situation
		return false;
	}

	private static Set<String> setOfChangedFields(SObject caseA, SObject caseB, Set<String> fieldsSet) {
		Set<String> result = new Set<String> ();
		for (String field : fieldsSet) {
			if (caseA.get(field) != caseB.get(field)) {
				result.add(field);
			}
		}
		return result;
	}

	private static Boolean isSetsIntersection(Set<String> trackedFields, Set<String> changedFields) {
		changedFields.retainAll(trackedFields);
		return changedFields.size() > 0;
	}

	public void tigerTeamSurveys(List<Case> newCases, map<Id, Case> oldCases, boolean isUpdate) {
		List<Surveys__c> createSurveys = new List<Surveys__c> ();
		Id dpic = Schema.SObjectType.Case.getRecordTypeInfosByName().get('DPIC').getRecordTypeId();
		Id tigerTeam = Schema.SObjectType.Surveys__c.getRecordTypeInfosByName().get('TigerTeam Survey').getRecordTypeId();
		Set<Id> contactIds = new Set<Id> ();
		Set<Id> casesWithExistSurv = new Set<Id> ();
		for (Surveys__c survey :[Select Id, Tiger_Team_Case__c from Surveys__c where recordtypeid = :tigerTeam and Tiger_Team_Case__c != null]) {
			casesWithExistSurv.add(survey.Tiger_Team_Case__c);
		}
		Map<Id,User> caseOwners;
		Map<Id,Group> caseOwnersQueue;
		Map<Id, Contact> caseContacts;
		Set<Id> ownersId = new Set<Id>();
		for (Case c : newCases)
		{
			if (c.ContactId != null)
			{
				contactIds.Add(c.ContactId);
			}
			if(c.OwnerId != null){
				ownersId.add(c.OwnerId);
			}
		}
		
		caseContacts = new Map<Id, Contact> ([Select Id, FirstName, LastName, Email from Contact where Id in :contactIds]);
		caseOwners = new Map<Id, User> ([Select Id, Name from User where Id in :ownersId]);
		caseOwnersQueue = new Map<Id, Group > ([Select Id, Name from Group  where Id in :ownersId and Type='Queue']);
		for (Case caseitem : newCases) {
			if (caseItem.recordTypeId == dpic && caseitem.Reason == 'Tiger Team / STP' && caseItem.Status == 'Closed' && caseContacts.get(caseitem.ContactId) != null && isUpdate && oldCases.get(caseitem.Id) != null && oldCases.get(caseitem.Id).Status != 'Closed' && !casesWithExistSurv.contains(caseitem.id)) {
				Surveys__c survey = new Surveys__c(Case_Id__c = caseItem.Id,
				                                   recordTypeId = tigerTeam,
				                                   Email__c = caseContacts.get(caseitem.ContactId).Email,
				                                   First_Name__c = caseContacts.get(caseitem.ContactId).firstName,
				                                   Last_Name__c = caseContacts.get(caseitem.ContactId).lastName,
				                                   Case_Number_Discussed_with_TT__c = caseitem.CaseNumber,
				                                   Tiger_Team_Case__c = caseitem.Id);
				if (caseOwners.get(caseitem.OwnerId) != null)
				{
					survey.Case_Owner__c = caseOwners.get(caseitem.OwnerId).Name;
				}else if(caseOwnersQueue.get(caseitem.OwnerId) != null){
					survey.Case_Owner__c = caseOwnersQueue.get(caseitem.OwnerId).Name;
				}
												   
				if (String.isNotBlank(caseitem.Part_Number_1__c)) {
					survey.Part_Number__c = caseitem.Part_Number_1__c.toUpperCase();
				}
				createSurveys.add(survey);
			}
		}

		if(createSurveys.size() > 0){
			insert createSurveys;
		}
	}
}