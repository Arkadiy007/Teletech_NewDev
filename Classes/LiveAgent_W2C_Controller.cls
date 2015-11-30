public class LiveAgent_W2C_Controller {
	private final String ERROR_EMAILMANDARORY = '* Email is a mandatory field';
	private final String ERROR_COMMENTS = '* Comments is a mandatory field';
	private final String ERROR_EMAIL = '* The email address is invalid';
	private final String ERROR_FIRST_NAME_MANDATORY = '* First name is a ' + 'mandatory field';
	private final String STANDART_AFTER_HOURS_MSG =  System.Label.Default_After_Hours_Message;
	private final String INCORRECT_DEPARTMENT_ERROR = 'Incorrect Department Message';
	private final String STANDART_HEADER_MSG = 'WE APPRECIATE YOUR INTEREST IN NISSAN. SORRY WE MISSED YOU.';

	public String afterHoursMessage { get; set; }
	public String errorMessage { get; set; }
	public Boolean showErrorMessage { get; set; }
	public String headerMessage { get; set; }

	public Map<String, String> labelsByRountingGroup { get; Set; }

	public String userAgent { get; set; }
	public String browser { get; set; }

	public String parentSiteURL { get; set; }
	public String userIp { get; set; }
	public DateTime redirectTime { get; set; }
	public String clientIP { get; set; }

	private final String URL_FIRST_NAME = 'firstName';
	private final String URL_LAST_NAME = 'lastName';
	private final String URL_EMAIL = 'email';
	private final String URL_PHONE = 'phone';
	private final Integer MAX_LENGTH_FIRST_NAME = 30;
	private final Integer MAX_LENGTH_LAST_NAME = 30;

	public List<SelectOption> reasons { get; set; }
	private List<Department__c> departmentList;

	public Boolean renderReason{get; set;}

	// -------- Constructor --------
	public LiveAgent_W2C_Controller() {
		Map<String, String> urlParameters = Apexpages.CurrentPage().getParameters();
		reasons = new List<SelectOption> ();
		renderReason = true;
		precompleteValuesWithParameters(urlParameters);
		populateLabelsCustomSettings();

        if (urlParameters.containsKey('routingGroup') && 
            !dataCheck.IsStringNullOrEmpty(urlParameters.get('routingGroup'))){
				 selectedDepartment = urlParameters.get('routingGroup');
				
				 if (selectedDepartment.contains('&')){
						 selectedDepartment = selectedDepartment.substringBefore('&');
				 }
				
			if (labelsByRountingGroup.containsKey(selectedDepartment)){
                 reasons.add(new SelectOption(selectedDepartment, labelsByRountingGroup.get(selectedDepartment)));   
			}

			departmentList = [SELECT Id, After_Hours_Message__c, Pre_Chat_Header__c FROM Department__c WHERE URL_Parameter_Name__c = :selectedDepartment];	
			headerMessage = getHeaderMessageForRoutingGroup(departmentList);
			afterHoursMessage = getAfterHoursMessageForRoutingGroup(selectedDepartment);
		}
		else {
			if (ApexPages.currentPage().getUrl().contains('NewNissan_W2C')) {
				populatePicklistValuesForNissan();
				
				departmentList = [SELECT Id, After_Hours_Message__c, Pre_Chat_Header__c FROM Department__c WHERE URL_Parameter_Name__c = :selectedDepartment];
				headerMessage = getHeaderMessageForRoutingGroup(departmentList);
			} else if (ApexPages.currentPage().getUrl().contains('NewInfiniti_W2C')) {
				populatePicklistValuesForInfiniti();
				departmentList = [SELECT Id, After_Hours_Message__c, Pre_Chat_Header__c FROM Department__c WHERE URL_Parameter_Name__c = :selectedDepartment];
				headerMessage = getHeaderMessageForRoutingGroup(departmentList);
			}

			afterHoursMessage = STANDART_AFTER_HOURS_MSG;

		}
		if (urlParameters.containsKey('picklistAvail') && 
            !dataCheck.IsStringNullOrEmpty(urlParameters.get('picklistAvail'))){
			if(urlParameters.get('picklistAvail') == 'false'){
				renderReason = false;
		    }
		}
	}

	private ValidationUtility dataCheck = new ValidationUtility();

	public String firstName { get; set; }
	public String lastName { get; set; }
	public String emailAddress { get; set; }
	public String phone { get; set; }
	public String comments { get; set; }

	public String selectedDepartment { get; set; }
	public String selectedDepartmentLabel { get; set; }

	/*
	 * 02/17/2015     Arkadiy Sychev - Change afterhours message behavior when Chat is outside Hours of operation 
	 * This function creates Case record with 'Live Agent' record type when Chat is outside Hours of operation 
	 */
	public PageReference submitCaseCreation() {
		try {
			if (validateData() && validateEmail() && (validateDataForWebToCase())) {
				LiveAgent_Afterhours_Case_Ownership__c custSetting = LiveAgent_Afterhours_Case_Ownership__c.getInstance(selectedDepartment);
				if (null != custSetting) {
					String ownerQueueId = getQueueId(custSetting);
					Case laCase = new Case(RecordTypeId = custSetting.RecordTypeId__c, Origin = 'Chat', Priority = 'Medium', Status = 'Open', Subject = custSetting.Subject__c,
					                       First_Name__c = firstName, Last_Name__c = lastName, Email2__c = emailAddress, Mobile_Phone__c = phone, Description = comments,
					                       User_Agent__c = userAgent, Browser_Version__c = browser);

					if (null != ownerQueueId) {
						laCase.ownerId = ownerQueueId;
					}
					System.debug('in submitCaseCreation testCase = ' + laCase);
					insert laCase;
					System.debug('in submitCaseCreation testCase.id = ' + laCase.id);
					showErrorMessage = false;
					return new PageReference('javascript: self.close();');
				}
				else {
					showErrorMessage = true;
					return ApexPages.currentPage();
				}
			}

			else {
				showErrorMessage = true;
				return null;
			}
		}
		catch(Exception e) {
			System.debug(e);
			showErrorMessage = true;
			return null;
		}
	}

	private void populatePicklistValuesForNissan() {
		reasons.add(new SelectOption('NissanWebsite', labelsByRountingGroup.get('NissanWebsite')));
		reasons.add(new SelectOption('NissanConnect', labelsByRountingGroup.get('NissanConnect')));

		selectedDepartment = 'NissanWebsite';
	}

	private void populatePicklistValuesForInfiniti() {
		reasons.add(new SelectOption('InfinitiWebsite', labelsByRountingGroup.get('InfinitiWebsite')));
		reasons.add(new SelectOption('InfinitiConnection', labelsByRountingGroup.get('InfinitiConnection')));
		reasons.add(new SelectOption('InfinitiCA', labelsByRountingGroup.get('InfinitiCA')));

		selectedDepartment = 'InfinitiWebsite';
	}

	private Boolean validateDataForWebToCase() {
		if (dataCheck.IsStringNullOrEmpty(comments)) {
			errorMessage = ERROR_COMMENTS;
			return false;
		}
		return true;
	}

	private void populateLabelsCustomSettings() {
		labelsByRountingGroup = new Map<String, String> ();

		for (LiveAgent_Department_Labels__c label : LiveAgent_Department_Labels__c.getAll().values()) {
			labelsByRountingGroup.put(label.RoutingGroup__c, label.Label__c);
		}
	}

	private String getAfterHoursMessageForRoutingGroup(String routingGroup) {
		departmentList = [SELECT Id, After_Hours_Message__c, Pre_Chat_Header__c FROM Department__c WHERE URL_Parameter_Name__c = :routingGroup];

		if (departmentList.size() > 0) {
			return departmentList[0].After_Hours_Message__c;
		}

		return INCORRECT_DEPARTMENT_ERROR;
	}

	private String getHeaderMessageForRoutingGroup(List<Department__c> departmentList) {
		if (departmentList.size() > 0) {
			return departmentList[0].Pre_Chat_Header__c;
		}

		return STANDART_HEADER_MSG;
	}

	private Boolean validateEmail() {
		if (dataCheck.IsStringNullOrEmpty(emailAddress)) {
			errorMessage = ERROR_EMAILMANDARORY;
			return false;
		}
		return true;
	}

	private String getQueueId(LiveAgent_Afterhours_Case_Ownership__c custSetting) {
		String result;

		String queueName = custSetting.Queue_Name__c;
		Group[] ownerQueue = [SELECT Id FROM Group WHERE Name = :queueName AND Type = 'Queue' LIMIT 1];
		if (null != ownerQueue && !ownerQueue.isEmpty()) {
			result = String.valueOf(ownerQueue[0].Id);
		}

		return result;
	}

	private void precompleteValuesWithParameters(
	                                             Map<String, String> urlParameters) {

		if (urlParameters.containsKey(URL_FIRST_NAME) &&
		    !dataCheck.IsStringNullOrEmpty(urlParameters.get(URL_FIRST_NAME))) {
			firstName = urlParameters.get(URL_FIRST_NAME);

			if (firstName.length() > MAX_LENGTH_FIRST_NAME) {
				firstName = firstName.substring(0, MAX_LENGTH_FIRST_NAME);
			}
		}

		if (urlParameters.containsKey(URL_LAST_NAME) &&
		    !dataCheck.IsStringNullOrEmpty(urlParameters.get(URL_LAST_NAME))) {
			lastName = urlParameters.get(URL_LAST_NAME);

			if (lastName.length() > MAX_LENGTH_LAST_NAME) {
				lastName = lastName.substring(0, MAX_LENGTH_LAST_NAME);
			}
		}


		if (urlParameters.containsKey(URL_EMAIL) &&
		    !dataCheck.IsStringNullOrEmpty(urlParameters.get(URL_EMAIL))) {
			emailAddress = urlParameters.get(URL_EMAIL);
		}

		if (urlParameters.containsKey(URL_PHONE) &&
		    !dataCheck.IsStringNullOrEmpty(urlParameters.get(URL_PHONE))) {
			phone = urlParameters.get(URL_PHONE);
		}


	}

	/*
	 * 02/25/2015    Arkadiy Sychev - Implement tracking of information (Site URL, IP, time of redirect) about site from where user 
	  get to the PreChat pages when Chat is outside Hours of operation.

	 */
	@testVisible
	public void processParentSiteInformation() {
		try {
			// Retrieve LiveAgent_Afterhours_Connection_Data__c custom settings 
			LiveAgent_Afterhours_Connection_Data__c afterhoursConnectionSettings = LiveAgent_Afterhours_Connection_Data__c.getOrgDefaults();
			if ((afterhoursConnectionSettings == null) || (afterhoursConnectionSettings.id == null)) {
				afterhoursConnectionSettings = new LiveAgent_Afterhours_Connection_Data__c();
				insert afterhoursConnectionSettings;
				afterhoursConnectionSettings = LiveAgent_Afterhours_Connection_Data__c.getOrgDefaults();

			}

			if (afterhoursConnectionSettings.Is_Connection_Data_Tracking_Enabled__c) {
				DateTime now = DateTime.now();
				if (null == parentSiteURL) {
					parentSiteURL = '';
				}
				Afterhours_Connection_Data__c connectionData = new Afterhours_Connection_Data__c(Department__c = selectedDepartment, User_Ip__c = clientIP,

				                                                                                 Visit_Time__c = now, Parent_Site_Name__c = parentSiteURL);

				insert connectionData;

			}
		} catch(Exception e) {
			System.debug('LiveAgent Visit Counter logic failed. Error message: ' + e.getMessage());
		}
	}

	private Boolean validateData() {
		if (dataCheck.IsStringNullOrEmpty(firstName)) {
			errorMessage = ERROR_FIRST_NAME_MANDATORY;
			return false;
		}

		if (!dataCheck.IsStringNullOrEmpty(emailAddress) &&
		    !dataCheck.IsEmailFormat(emailAddress)) {
			errorMessage = ERROR_EMAIL;
			return false;
		}

		return true;
	}

}