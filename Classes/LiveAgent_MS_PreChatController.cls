/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2015, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Controller used by the pre-chat form (live agent feature)

Class:              LiveAgent_MS_PreChatController
Author:             Koseykina A.
Date:               01/13/2015
Version:            1.0
Last Updated:       01/13/2015
    * 01/13/2015    AK - Created
*/
public class LiveAgent_MS_PreChatController {
	// -------- Constants --------
    private final String ERROR_FIRST_NAME_MANDATORY = '* First name is a ' + 
    	'mandatory field';
    private final String DAY_MONDAY = 'Monday';
    private final String DAY_TUESDAY = 'Tuesday';
    private final String DAY_WEDNESDAY = 'Wednesday';
    private final String DAY_THURSDAY = 'Thursday';
    private final String DAY_FRIDAY = 'Friday';
    private final String DAY_SATURDAY = 'Saturday';
    private final String DAY_SUNDAY = 'Sunday';
    private final String URL_DEPARTMENT = 'routingGroup';
    private final String COOKIE_NAME = 'LiveAgentSession';
    private final Integer COOKIE_DURATION = 30;
    private final String IP_PARAMETER_1 = 'True-Client-IP';
    private final String IP_PARAMETER_2 = 'X-Salesforce-SIP';
    private final String URL_FIRST_NAME = 'firstName';
    private final String URL_LAST_NAME = 'lastName';
    private final String URL_ERROR_CODE = 'errorCode';
    private final Integer MAX_LENGTH_FIRST_NAME = 30;
    private final Integer MAX_LENGTH_LAST_NAME = 30;
    private final Integer MAX_LENGTH_ZIP_CODE = 10;
    private final Integer MAX_LENGTH_ERROR_CODE = 50;
    
    /* PROD 
	
    private final String NISSAN_CHAT_BUTTON_ID_1 = '573F00000008OiR';
    private final String NISSAN_CHAT_BUTTON_ID_2 = '573F00000008OiH';
    private final String INFINITI_CHAT_BUTTON_ID_1 = '573F00000008OiM';
    private final String INFINITI_CHAT_BUTTON_ID_2 = '573F00000008OhY';
    private final String INFINITI_CHAT_BUTTON_ID_3 = '573F00000008OhT';    
    private final String LEAF_CHAT_BUTTON_ID_1 = '573F00000008Ohn';
    private final String LEAF_CHAT_BUTTON_ID_2 = '573F00000008Oj5';
    private final String LEAF_CHAT_BUTTON_ID_3 = '573F00000008Oiq';
    */

    /* DEV */
    private final String NISSAN_CHAT_BUTTON_ID_2 = '573M000000000KM';
	private final String MANAGED_SERVICES_CHAT_BUTTON_ID = '573M000000000KM';
    // -------- Constructor --------
    public LiveAgent_MS_PreChatController() {
    	showErrorMessage = false;
		preChatData = new Pre_Chat_Data__c();
		isSuccess = false;
		isDepartmentOpen = true;
        showAwayMessage = false;
                
        loadChatButtonIds();
                
        Blob blobKey = crypto.generateAesKey(128);
        customSessionId = EncodingUtil.convertToHex(blobKey);
                
        Map<String, String> urlParameters = 
							Apexpages.CurrentPage().getParameters();
                         
        if (urlParameters.containsKey(URL_DEPARTMENT) && 
			!dataCheck.IsStringNullOrEmpty(urlParameters.get(URL_DEPARTMENT))){
            routingGroup = urlParameters.get(URL_DEPARTMENT);
            selectedDepartment = routingGroup;
            retrieveDepartmentValues(routingGroup);
			isDepartmentOpen = isSelectedDepartmentOpen();
        }
        else {
			selectedDepartment = System.Label.LiveAgent_DefaultDepartment;
            setDefaultValues();
			isDepartmentOpen = isSelectedDepartmentOpen();
        }
        precompleteValuesWithParameters(urlParameters);
                
        clientIP = ApexPages.currentPage().getHeaders().get(IP_PARAMETER_1);
                
        if (datacheck.IsStringNullOrEmpty(clientIP) || clientIP == 'null') {
			clientIP = ApexPages.currentPage().getHeaders().get(IP_PARAMETER_2);
        }
	}
	
	// -------- Variables --------
	private ValidationUtility dataCheck = new ValidationUtility();
	
	// -------- Properties --------
	public String contactId {get; set;}
	public String accountId {get; set;}
	public String customSessionId {get; set;}
    public String errorMessage {get; set;}
    public Boolean isSuccess {get; set;}
    public Boolean showErrorMessage {get; set;}
        
    public String chatWindowTitle {get; set;}
    public String buttonId {get; set;}
    public String nissanButtonId2 {get; set;}
	public String managedServicesButtonID {get; set;}
    public String deploymentId {get; set;}
    public String bottomMessage {get; set;}
    public String afterHoursMessage {get; set;}
    public String awayAgentsMessage {get; set;}
    public String chatRecordTypeId {get; set;}
    public Boolean isDepartmentOpen {get; set;}
    public Boolean showAwayMessage {get; set;}
        
    public String routingGroup {get; set;}
    public String chatButtonPressed {get; set;}
    public String selectedDepartment {get; set;}
    public String clientIP {get; set;}
    public Map<string,string> operationHours {get; set;}
    public String errorCode {get; set;}
    public String offset {get; set;}
	
	public String getCompletedName() {
		if (dataCheck.IsStringNullOrEmpty(preChatData.Last_Name__c))
			return preChatData.First_Name__c;
		else
			return preChatData.First_Name__c + ' ' + preChatData.Last_Name__c;
	}
	public Pre_Chat_Data__c preChatData {get; set;}
	 // -------- Methods --------
    // It submits the entered data of the form
    public void submitForm() {
		if (!isSelectedDepartmentOpen()) {
			return;
        }
                
        if (validateData()) {
			retrieveContact();
            //setCookie(customSessionId);
			isSuccess = true;
            showErrorMessage = false;
        }
        else {
			showErrorMessage = true;
        }
    }
        
    //It validates the format of the entered data
    private Boolean validateData() {
		if (dataCheck.IsStringNullOrEmpty(preChatData.First_Name__c)) {
			errorMessage = ERROR_FIRST_NAME_MANDATORY;
            return false;
        }             
                
        return true;            
    }
        
    // It retrieves the Contact associated to the informed email, the informed
    // phone or saves a pre chat data object
    private void retrieveContact() {
		if (dataCheck.IsStringNullOrEmpty(preChatData.First_Name__c) && !dataCheck.IsStringNullOrEmpty(preChatData.Last_Name__c)) {
			List<Contact> chatContact = [SELECT Id, AccountId FROM Contact WHERE firstName = :preChatData.First_Name__c AND lastName = :preChatData.Last_Name__c LIMIT 1];
                                
            if (chatContact.size() > 0) {
				contactId = chatContact[0].Id;
                accountId = chatContact[0].AccountId;
            }
        }       
                
        savePreChatForm(accountId);
    }
        
    // It records all the entered data on a Pre_Chat_Data__c object
    private void savePreChatForm(string personAccountId) {
		removeCachedSessions();
		preChatData.Name = getCompletedName();
		preChatData.Session_Id__c = customSessionId;
        preChatData.Client_IP__c = clientIP;                
                
        if (selectedDepartment == routingGroup) {
			preChatData.RecordTypeId = chatRecordTypeId;
            preChatData.Clicked_Chat_Button__c = buttonId;
        }
        else {
			List<Department__c> departmentList = [SELECT Chat_Button_Id__c, 
                                Record_Type_Id__c
                                FROM Department__c
                                WHERE URL_Parameter_Name__c = :selectedDepartment];
                        
            preChatData.Clicked_Chat_Button__c = departmentList[0].Chat_Button_Id__c;
            preChatData.RecordTypeId = departmentList[0].Record_Type_Id__c;
        }
                
        if (!dataCheck.IsStringNullOrEmpty(personAccountId)) {
			preChatData.AccountId__c = personAccountId;     
        }
                
        if (!dataCheck.IsStringNullOrEmpty(errorCode)) {
			preChatData.Error_Code__c = errorCode;  
        }
                
        insert preChatData;
    }
        
    //It cleans the sessionId from old pre-chat data objects
    private void removeCachedSessions() {
		List<Pre_Chat_Data__c> oldSessions = [SELECT Id, Session_Id__c 
                        FROM Pre_Chat_Data__c
                        WHERE Session_Id__c = :customSessionId];
                        
        if (oldSessions != null && oldSessions.size() > 0) {
			for (Pre_Chat_Data__c chatData: oldSessions) {
				chatData.Session_Id__c = '';
                update chatData; 
            }
        }
    }
        
    // It looks for all the department settings
    private void retrieveDepartmentValues(String department) {
		List<Department__c> departmentList = [SELECT Id, Name,
                        Chat_Button_Id__c, Chat_Button_Id_P2__c, Chat_Button_Id_P3__c,
                        Chat_Button_Id_Queue__c, Chat_Window_Title__c, Deployment_Id__c,
                        Operation_Hours_Monday__c, Operation_Hours_Tuesday__c,
                        Operation_Hours_Wednesday__c, Operation_Hours_Thursday__c,
                        Operation_Hours_Friday__c, Operation_Hours_Saturday__c,
                        Operation_Hours_Sunday__c, Pre_Chat_Bottom_Message__c,
                        After_Hours_Message__c, Record_Type_Id__c, GMT_Offset__c,
                        Away_Agents_Message__c
                        FROM Department__c
                        WHERE URL_Parameter_Name__c = :department];

                        
		if (departmentList != null && departmentList.size() > 0) {
			chatWindowTitle = departmentList[0].Chat_Window_Title__c;
            buttonId = departmentList[0].Chat_Button_Id__c;
                        
            deploymentId = departmentList[0].Deployment_Id__c;
            bottomMessage = departmentList[0].Pre_Chat_Bottom_Message__c;
            chatRecordTypeId = departmentList[0].Record_Type_Id__c;
            afterHoursMessage = departmentList[0].After_Hours_Message__c;
                        
            if (dataCheck.IsStringNullOrEmpty(
				departmentList[0].Away_Agents_Message__c)) {
                awayAgentsMessage = departmentList[0].After_Hours_Message__c;
            } 
            else {
				awayAgentsMessage = departmentList[0].Away_Agents_Message__c;   
            }
                        
                        
            offset = departmentList[0].GMT_Offset__c;
            //TODO: Validate field format
            if (dataCheck.IsStringNullOrEmpty(offset)) {
				offset = 'GMT+00:00';
            }
            else {
				offset = 'GMT' + offset;
            }
                        
            operationHours = new Map<String,String>();
            operationHours.put(DAY_MONDAY, 
					departmentList[0].Operation_Hours_Monday__c);
            operationHours.put(DAY_TUESDAY, 
					departmentList[0].Operation_Hours_Tuesday__c);
            operationHours.put(DAY_WEDNESDAY, 
					departmentList[0].Operation_Hours_Wednesday__c);
            operationHours.put(DAY_THURSDAY, 
					departmentList[0].Operation_Hours_Thursday__c);
            operationHours.put(DAY_FRIDAY, 
					departmentList[0].Operation_Hours_Friday__c);
            operationHours.put(DAY_SATURDAY, 
					departmentList[0].Operation_Hours_Saturday__c);
            operationHours.put(DAY_SUNDAY, 
					departmentList[0].Operation_Hours_Sunday__c);
       } 
       else {
	       setDefaultValues();
       }
    }
        
    // It set the values when the department is not defined
    private void setDefaultValues() {
		routingGroup = System.Label.LiveAgent_DefaultDepartment;
        retrieveDepartmentValues(routingGroup);
    }
        
    //It creates a cookie for storing the session Id
    private void setCookie(String sessionId) {
		Cookie userCookie = new Cookie(COOKIE_NAME, sessionId, null,
                COOKIE_DURATION, true);
        ApexPages.currentPage().setCookies(new Cookie[] {userCookie});
    }
        
    // It looks for URL parameters and pre-complete the form values 
    private void precompleteValuesWithParameters(
		Map<String, String> urlParameters) {
                                         
        if (urlParameters.containsKey(URL_FIRST_NAME) && 
				!dataCheck.IsStringNullOrEmpty(urlParameters.get(URL_FIRST_NAME))){
            preChatData.First_Name__c = urlParameters.get(URL_FIRST_NAME);
                        
            if (preChatData.First_Name__c.length() > MAX_LENGTH_FIRST_NAME) {
				preChatData.First_Name__c = preChatData.First_Name__c.substring(0, MAX_LENGTH_FIRST_NAME);
            }                       
        }
                
        if (urlParameters.containsKey(URL_LAST_NAME) && 
				!dataCheck.IsStringNullOrEmpty(urlParameters.get(URL_LAST_NAME))){
			preChatData.Last_Name__c = urlParameters.get(URL_LAST_NAME);
                        
            if (preChatData.Last_Name__c.length() > MAX_LENGTH_LAST_NAME) {
				preChatData.Last_Name__c = preChatData.Last_Name__c.substring(0, MAX_LENGTH_LAST_NAME);
            }
        }
                                
        if (urlParameters.containsKey(URL_ERROR_CODE) && 
				!dataCheck.IsStringNullOrEmpty(urlParameters.get(URL_ERROR_CODE))){
			errorCode = urlParameters.get(URL_ERROR_CODE);
                        
            if (errorCode.length() > MAX_LENGTH_ERROR_CODE) {
				errorCode = errorCode.substring(0, MAX_LENGTH_ERROR_CODE);
			}
        }
    }
        
    //Check the operation hours of the selected department
    private boolean isSelectedDepartmentOpen() {
        
		if (selectedDepartment != routingGroup) {
			//Retrieves the hours of the selected department
			List<Department__c> departmentList = [SELECT 
				Operation_Hours_Monday__c, Operation_Hours_Tuesday__c,
                Operation_Hours_Wednesday__c, Operation_Hours_Thursday__c,
                Operation_Hours_Friday__c, Operation_Hours_Saturday__c,
                Operation_Hours_Sunday__c, 
                After_Hours_Message__c, GMT_Offset__c,
                Away_Agents_Message__c
                FROM Department__c
                WHERE URL_Parameter_Name__c = :selectedDepartment];
                                
             if (departmentList != null && departmentList.size() > 0) {
				afterHoursMessage = departmentList[0].After_Hours_Message__c;
                                
                if (dataCheck.IsStringNullOrEmpty(
					departmentList[0].Away_Agents_Message__c)) {
                    awayAgentsMessage = departmentList[0].After_Hours_Message__c;
                } 
                else {
					awayAgentsMessage = departmentList[0].Away_Agents_Message__c;   
                }
                                
                offset = departmentList[0].GMT_Offset__c;
                                
                //TODO: Validate field format
                if (dataCheck.IsStringNullOrEmpty(offset)) {
					offset = 'GMT+00:00';
                }
                else {
					offset = 'GMT' + offset;
                }
                                
                operationHours = new Map<String,String>();
                operationHours.put(DAY_MONDAY, 
					departmentList[0].Operation_Hours_Monday__c);
                operationHours.put(DAY_TUESDAY, 
					departmentList[0].Operation_Hours_Tuesday__c);
                operationHours.put(DAY_WEDNESDAY, 
					departmentList[0].Operation_Hours_Wednesday__c);
                operationHours.put(DAY_THURSDAY, 
					departmentList[0].Operation_Hours_Thursday__c);
                operationHours.put(DAY_FRIDAY, 
					departmentList[0].Operation_Hours_Friday__c);
                operationHours.put(DAY_SATURDAY, 
					departmentList[0].Operation_Hours_Saturday__c);
                operationHours.put(DAY_SUNDAY, 
					departmentList[0].Operation_Hours_Sunday__c);
            }
       }
                                                        
       //Validate operation hours
       isDepartmentOpen = false;
                
       String todayHours = operationHours.get(
			DateTime.now().format('EEEE', offset));
                        
       String regEx = '([0-1]?[0-9]|2[0-3]):([0-5][0-9])' +
               '-([0-1]?[0-9]|2[0-3]):([0-5][0-9])';
       Pattern numeric = Pattern.compile(regEx);
       Matcher numericMatch = numeric.matcher(todayHours);
        
       if (numericMatch.matches()) {
			Integer hourGmt = Integer.valueOf(
                Datetime.now().format('HH', offset));
			Integer minuteGmt = Integer.valueOf(
                Datetime.now().format('mm', offset));
                        
			List<String> hours = todayHours.split('-');
			List<String> openHours = hours[0].split(':');
            List<String> closeHours = hours[1].split(':');
                        
            if ((hourGmt > Integer.valueOf(openHours[0]) || 
				(hourGmt == Integer.valueOf(openHours[0]) && 
				minuteGmt >= Integer.valueOf(openHours[1])))
                &&
                (hourGmt < Integer.valueOf(closeHours[0]) ||
                (hourGmt == Integer.valueOf(closeHours[0]) && 
                minuteGmt <= Integer.valueOf(closeHours[1])))) {
                isDepartmentOpen = true;
            }
        }       
                
        return isDepartmentOpen;
    }
        
    //It fills the FIXED chat button Ids
    private void loadChatButtonIds(){
		nissanButtonId2 = NISSAN_CHAT_BUTTON_ID_2;
		buttonId = MANAGED_SERVICES_CHAT_BUTTON_ID;
    } 
        
    //It shows the right Message (Closed HOOP or Away message)
    public void showClosedMessage() {
		if (isSelectedDepartmentOpen()) {
			//awayAgentsMessage = 'This is the away message';
            showAwayMessage = true;
        }
    }
 }