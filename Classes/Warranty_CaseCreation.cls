/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Controller for the Warranty Case Creation page

Class:              Warranty_CaseCreation
Author:             Rohdenburg S.
Date:               04/24/2014
Version:            1.0
Last Updated:       07/08/2014
* 04/24/2014    SR - Created
* 04/28/2014    SR - Addapted to Warranty
* 07/08/2014    TH - Added Work Order search
* 07/30/2014    TH - Page redesigned to accomodate Warranty project
* 08/18/2014    AAB - Updates to add Dealer/VIN Alerts
* 09/04/2014    AAB - Updates to the case creation screen and search params
* 09/12/2014    AAB - Adding Vehicle Related Warranty Cases
* 09/18/2014    AAB - Adding additional search fields and VCAN search
* 09/24/2014    AAB - WPS Authentication error messages
* 09/29/2014    AAB - Added Sub-Reason
* 09/29/2014    AAB - Added Dealer Suspended Claims
* 10/28/2014    AAB - Dealer Comments, NESNA Alerts and re-arranging
*/

public class Warranty_CaseCreation
{
    // -------- Constants --------
    private final String RECORD_TYPE_DEALER = 'Dealer';
    private final String RECORD_TYPE_WARRANTY = 'Warranty';
    private final String RECORD_TYPE_GENERAL_INQUIRY = 'General Inquiry';
    private final String RECORD_TYPE_WCC = 'WCC VCAN';
    private final String RECORD_TYPE_TRANS = 'Trans VCAN';
    private final String RECORD_TYPE_ENGINE = 'Engine VCAN';
    private final String ERROR_CASE_NUMBER = '* The Case Number is invalid';
    private final String ERROR_PARAMETERS = '* Please enter a Dealer Code, ' + 
        ' a VIN, HOST Reference Number or a Work Order Number';
    private final String ERROR_UNKNOWN_DEALER = '* There is no dealer ' + 
        'with the provided information';
    
    
    private final String FIELD_DEALER = '00NF0000008Mvxy';
    private final String FIELD_VEHICLE = '00NA00000070W35';
    private final String FIELD_VIN = '00NA0000007h1yM';
    
    private final String FIELD_ARCH_MAKE = '00NF0000008Mw2A';
    private final String FIELD_ARCH_MODEL = '00NF0000008Mw25';
    private final String FIELD_ARCH_YEAR = '00NF0000008Mvy9';
    private final String FIELD_CUSTOMER_NAME = '00NF0000008NeII';
    //private final String FIELD_ACCOUNT = 'cas4';
    
    /* Warranty - SCC - PROD Environments */ 
    
    private String FIELD_DTS_FULL_NAME = '00NF0000008sF9C';
    private String FIELD_DTS_EMAIL = '00NF0000008sF4t';
    private String FIELD_DTS_CELL_PHONE = '00NF0000008sF4s';
    private String FIELD_DTS_OFFICE_PHONE = '00NF0000008sF4u';
    private String FIELD_WCC_INSTRUCTIONS = '00Nc0000000wjp0';
    //private String FIELD_DEALER_CODE ='00Nc0000000yMNH';
    private String WC_FIELD_WO_NUMBER ='00Nc0000000yMLu';
    private String WC_FIELD_WO_LINE ='00Nc0000000yMLz';
    private String WC_FIELD_VIN ='00Nc0000000yMDl';
    private String WC_FIELD_CALLER_NAME ='00Nc0000000yMXv';
    private String WC_FIELD_WO_DATE ='00Nc0000000yMM4';
    private String WC_FIELD_MILES ='00Nc0000000yMMT';
    private String WC_FIELD_CUSTOMER_NAME ='00Nc00000017gNA';
    private String WC_FIELD_DEALER_NAME ='00Nc0000000yMNC';
    private String WC_FIELD_NOTES = '00Nc00000017icq';
    private String WCC_TYPE_ID = 'a1m';
    private String WC_FIELD_VCAN_TYPE = '00Nc00000017Shz';
    private String WC_FIELD_REQUESTORS_TITLE = '00Nc00000017SSp';
    private String WC_FIELD_REQUESTORS_PHONE = '00Nc0000000yRP3';
    private String WC_FIELD_REASON = '00Nc00000017JZD';
    private String WC_FIELD_SUBREASON = '00Nc00000018LjS';
    private String WC_FIELD_ERROR_CODE = '00Nc00000017bzY';
    private String WC_FIELD_DESCRIPTION = '00Nc0000001808F';
    private String WC_FIELD_STATUS= '00Nc00000017Shk';    
    private String WC_FIELD_ADD_VCAN_COMMENT = '00Nc0000000yMfk'; 
    private String WC_FIELD_PARTS = '00Nc0000000yMfL';  
    private String WC_FIELD_LABOR = '00Nc0000000yMfQ'; 
    private String WC_FIELD_EXPENSES = '00Nc0000000yMfV';
    
    private String WC_FIELD_PFPO = '00Nc0000000yROy';
    private String WC_FIELD_APPROVAL_STATUS = '00Nc0000000yROo';
    private String WC_FIELD_NORMAL_APPROVAL = '00Nc00000017RB4';
    private String WC_FIELD_MILEAGE_REVIEW = '00Nc00000017RG4';
    private String WC_FIELD_REPEAT_REPAIR_REVIEW = '00Nc00000017RBE';
    private String WC_FIELD_DUPLICATE_CAMPAIGN = '00Nc00000017RG9';
    private String WC_FIELD_GOODWILL_APPROVAL = '00Nc00000017RGE';
    private String WC_FIELD_FORCE_GOODWILL_APPROVAL = '00Nc0000000yROj';
    private String WC_FIELD_PARTS_AT_COST = '00Nc0000000yROK';    
    
    private String GI_RECORD_TYPE = '012c00000004hHr';
    private String WCC_RECORD_TYPE = '';
    private String TRANS_RECORD_TYPE = '';
    private String ENGINE_RECORD_TYPE = '';
    
    // -------- Constructor --------
    public Warranty_CaseCreation(){
        
        warrantyId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(
            RECORD_TYPE_WARRANTY).getRecordTypeId();
        GI_RECORD_TYPE = Schema.Sobjecttype.Warranty_Case__c.getRecordTypeInfosByName().get( 
            RECORD_TYPE_GENERAL_INQUIRY).getRecordTypeId();
        WCC_RECORD_TYPE = Schema.Sobjecttype.Warranty_Case__c.getRecordTypeInfosByName().get( 
            RECORD_TYPE_WCC).getRecordTypeId();
        TRANS_RECORD_TYPE = Schema.Sobjecttype.Warranty_Case__c.getRecordTypeInfosByName().get( 
            RECORD_TYPE_TRANS).getRecordTypeId();
        ENGINE_RECORD_TYPE = Schema.Sobjecttype.Warranty_Case__c.getRecordTypeInfosByName().get( 
            RECORD_TYPE_ENGINE).getRecordTypeId();
        wc = new Warranty_Case__c();
        wc.RecordTypeId = GI_RECORD_TYPE;
        
        String ProfileName = UserInfo.getProfileId();
        
        List<Profile> profiles = [select id, Name from profile where name in ('Warranty Agent',
                                                                              'Warranty Manager',
                                                                              'PCC Agent',
                                                                              'PCC Manager', 'System Administrator', 'System Admin Config', 'System Admin Integration') ];
        for(Profile oProfile : profiles)
        {
            if(oProfile.Id==ProfileName)
            {
                allowGeneralInquiry = true;
            }
        }
        
        //Populate from custom setting
        
        WCCSettings__c setting = WCCSettings__c.getOrgDefaults();
        if (setting != null)
        {
            FIELD_DTS_FULL_NAME = setting.WCC_DTS_Full_name__c;
            FIELD_DTS_EMAIL = setting.WCC_DTS_Email__c;
            FIELD_DTS_CELL_PHONE = setting.WCC_DTS_Cell_Phone__c;
            FIELD_DTS_OFFICE_PHONE = setting.WCC_DTS_Office_Phone__c;
            FIELD_WCC_INSTRUCTIONS = setting.WCC_Instructions__c;
            WC_FIELD_WO_NUMBER = setting.WCC_WO_Number__c;
            WC_FIELD_WO_LINE = setting.WCC_WO_Line__c;
            WC_FIELD_VIN = setting.WCC_VIN__c;
            WC_FIELD_CALLER_NAME = setting.WCC_Caller_Name__c;
            WC_FIELD_WO_DATE = setting.WCC_WO_Date__c;
            WC_FIELD_MILES = setting.WCC_Miles__c;
            WC_FIELD_CUSTOMER_NAME = setting.WCC_Customer_Name__c;
            WC_FIELD_DEALER_NAME = setting.WCC_Dealer_Name__c;
            WC_FIELD_NOTES = setting.WCC_Notes__c;
            WCC_TYPE_ID = setting.WCC_Type_Id__c;
            WC_FIELD_VCAN_TYPE = setting.WCC_VCAN_Type__c;
            WC_FIELD_REQUESTORS_TITLE = setting.WCC_Requestors_Title__c;
            WC_FIELD_REQUESTORS_PHONE = setting.WCC_Requestors_Phone__c;
            WC_FIELD_REASON = setting.WCC_Reason__c;
            WC_FIELD_SUBREASON = setting.WCC_Subreason__c;
            WC_FIELD_ERROR_CODE = setting.WCC_Error_Code__c;
            WC_FIELD_DESCRIPTION = setting.WCC_Description__c;
            WC_FIELD_STATUS= setting.WCC_Status__c;
            WC_FIELD_ADD_VCAN_COMMENT = setting.WCC_Add_VCAN_Comment__c;
            WC_FIELD_PARTS = setting.WCC_Parts__c;
            WC_FIELD_LABOR = setting.WCC_Labor__c;
            WC_FIELD_EXPENSES = setting.WCC_Expenses__c;
            
            //NEw Fields
            WC_FIELD_PFPO = setting.WCC_PFPO__c;
            WC_FIELD_APPROVAL_STATUS = setting.WCC_APPROVAL_STATUS__c;
            WC_FIELD_NORMAL_APPROVAL = setting.WCC_NORMAL_APPROVAL__c;
            WC_FIELD_MILEAGE_REVIEW = setting.WCC_MILEAGE_REVIEW__c;
            WC_FIELD_REPEAT_REPAIR_REVIEW = setting.WCC_REPEAT_REPAIR_REVIEW__c;
            WC_FIELD_DUPLICATE_CAMPAIGN = setting.WCC_DUPLICATE_CAMPAIGN__c;
            WC_FIELD_GOODWILL_APPROVAL = setting.WCC_GOODWILL_APPROVAL__c;
            WC_FIELD_FORCE_GOODWILL_APPROVAL = setting.WCC_FORCE_GOODWILL_APPROVAL__c;
            WC_FIELD_PARTS_AT_COST = setting.WCC_PARTS_AT_COST__c; 
        }
        
        //AAB - 9/24/2014 - Params for password errors
        VCAN_Account_Locked_Error = Label.VCAN_Account_Locked_Error;
        VCAN_Account_Locked_Error_String = Label.VCAN_Account_Locked_Error_String;
        VCAN_Password_Error = Label.VCAN_Password_Error;
        VCAN_Password_Error_String = Label.VCAN_Password_Error_String;
    }
    
    // -------- Variables --------
    private ValidationUtility datacheck = new ValidationUtility();
    
    // -------- Properties --------
    public Warranty_Case__c wc {get;set;}   
    public String VCANRefNumber  {get; set;}
    public String AffiliateCode  {get; set;}
    public String WONumber  {get; set;}
    public String WOLine  {get; set;}
    public String ServiceFacility  {get; set;}
    public String VIN  {get; set;}
    public String WOOpenDate  {get; set;}
    public String Miles  {get; set;}
    public String PFPPO  {get; set;}
    public String CallerName  {get; set;}
    public String CallerPhone  {get; set;}
    public String CallerExt  {get; set;}
    public String CustomerName  {get; set;}
    public String PartsAtCost  {get; set;}
    public String[] ApprovalComments  {get; set;}
    public String ForceGoodwill  {get; set;}
    public String ApprovalStatus  {get; set;}
    public String ApprId  {get; set;}
    public String ApprDate  {get; set;}
    public String EnteredByUserId  {get; set;}
    public String EnteredDate  {get; set;}
    public String ChangedByUserId  {get; set;}
    public String ChangedDate  {get; set;}
    public String LanId  {get; set;}
    public String Message  {get; set;}
    public String ExecutionTime {get; set;}
    
    
    public String paramNotes {get; set;}   
    public String paramCallerName {get; set;}
    public String ResponseOutput {get; set;}
    public String paramDealerCode {get; set;}
    public String paramDealerName {get; set;}
    public String paramWorkOrderNumber {get; set;}
    public string paramWOLine {get; set;}
    public String paramCaseNumber {get; set;}
    public String paramVCAN {get; set;}
    public String paramVIN {get; set;}
    public String paramHOSTRefNum {get; set;}
    public String paramRecordType {get; set;}
    public String errorMessage {get; set;}
    public String redirectURL {get; set;}
    public Boolean redirectToPage {get; set;}
    public Boolean allowGeneralInquiry {get;set;}
    public Boolean showErrorMessage {get; set;}
    public Boolean showVehicleSection {get; set;}
    public Boolean showDealerSection {get; set;}
    public Boolean showVehicleRelatedCases {get; set;}
    public Boolean showVehicleRelatedWarrantyCases {get; set;}
    public Boolean showReferenceSection {get; set;}
    public Boolean showReferenceRelatedWarrantyCases {get; set;}
    public Boolean showDealerRelatedCases {get; set;}
    //AAB 9/29/2014 - Dealer Suspended Claims
    public Boolean showDealerSuspendedClaims {get; set;}
    public Boolean showVehicleSuspendedClaims {get; set;}
    public Boolean vehicleCall {get; set;}
    
    public Boolean showWorkOrderSection {get; set;}
    public Boolean showVCANSection {get; set;}
    public Boolean showHOSTVCANSection {get;set;}
    public Boolean showCaseSection {get; set;}
    public Boolean showVCANResult {get; set;}
    public Boolean showRecall {get; set;}
    public Boolean showSearch { get { if(showSearch == null) showSearch = true; return showSearch; } set; }
    public Boolean showSummary {get; set;}
    public VCANJSONResponse oResponse {get; set;}
    public List<Account> dealers {get; set;}
    public Vehicle__c foundVehicle {get; set;}
    public Account foundDealer {get; set;}
    public Dealer_VIN_Alerts__c foundDealerAlert {get;set;}
    public List<Dealer_VIN_Alerts__c> dealerVINAlerts {get;set;}
    public Boolean DealerVINAlert {get;set;}
    public Boolean showDealerComments {get;set;}
    public List<Dealer_VIN_Alerts__c> dealerComments {get;set;}
    public Service_Repair_History__c foundWorkOrder {get; set;}
    public List<Case> vehicleRelatedCases {get; set;}
    public List<Warranty_Case__c> vehicleRelatedWarrantyCases {get; set;}
    public List<Warranty_Case__c> hostRelatedWarrantyCases {get; set;}
    public List<Warranty_Case__c> dealerRelatedCases {get; set;}
    //AAB 9/29/2014 - Dealer Suspended Claims
    public List<Service_Repair_History__c> dealerSuspendedClaims {get; set;}
    public List<Service_Repair_History__c> vehicleSuspendedClaims {get; set;}
    
    public List<ServiceHistoryWrapper> dealerSuspendedClaimsWrapperList {get; set;}
    public List<Service_Repair_History__c> workorder {get; set;}
    public List<Service_Repair_History__c> VCAN {get; set;}
    public List<Warranty_Case__c> warrantyCases {get; set;}
    public List<Vehicle__c> vehicles {get; set;}
    public List<Vehicle_Recall__c> foundRecall {get; set;}
    public String selectedDealerId {get; set;}
    private String warrantyId {get; set;}
    private Vehicle_Ownership_History__c lastOwner {get; set;}
    public string VINErrorMessage {get; set;}
    public Nna360VCANMasterServiceSoap.VCANDetails details {get; set;}
    
    public string VCAN_Account_Locked_Error {get; set;}
    public string VCAN_Account_Locked_Error_String {get; set;}
    public string VCAN_Password_Error {get; set;}
    public string VCAN_Password_Error_String {get; set;}    
    
    // -------- Methods --------
    // It performs the search of the initial screen
    
    public void initialSearch()
    {
        vehicleCall = false;
        oResponse = null;
        
        if(paramVIN!=null && paramVIN.length()>0)
        {
            paramVIN = paramVIN.deleteWhitespace();
        }
        
        showSearch = true;
        showSummary = false;
        showDealerSection = false;
        showDealerRelatedCases = false;
        showDealerSuspendedClaims = false;
        showVehicleSuspendedClaims = false;
        showVehicleSection = false;
        showVehicleRelatedCases = false;
        showReferenceSection = false;
        showReferenceRelatedWarrantyCases = false;
        showWorkOrderSection = false;
        showVCANSection = false;
        showCaseSection = false;
        showVCANResult = false;
        showHOSTVCANSection = false;
        showRecall = false;
        errorMessage = '';
        showErrorMessage = false;
        redirectToPage = false;
        DealerVINAlert = false;
        showDealerComments = false;
        
        redirectToPage = false;
        showErrorMessage = false;
        VINErrorMessage = '';
        
        dealerVINAlerts = new List<Dealer_VIN_Alerts__c>();
        dealerComments = new List<Dealer_VIN_Alerts__c>();
        
        /*if(datacheck.IsStringNullOrEmpty(paramVIN)){
VINErrorMessage = 'Please input a valid VIN';
return;
}*/
        
        
        if (!datacheck.IsStringNullOrEmpty(paramCaseNumber)) 
        {
            redirectToAnExistingCase();
            return;
        }
        
        if (!validateParameters()) {
            showErrorMessage = true;
            return;
        }
        else 
        {
            searchHostReference();
            searchDealer();
            searchVehicle();
            //Removed as per Sarah
            //searchWorkorder();
            searchRecall();
            searchHostReference();
            searchVCAN();
            //AAB removing search screen locking
            //showSearch = False;
            showSummary = True;  
        }
    }
    
    // It checks the values of the filters
    private Boolean validateParameters() {
        
        if (datacheck.IsStringNullOrEmpty(paramDealerCode) &&
            datacheck.IsStringNullOrEmpty(paramWorkOrderNumber) &&
            datacheck.IsStringNullOrEmpty(paramVIN) &&
            datacheck.IsStringNullOrEmpty(paramHOSTRefNum) &&
            //datacheck.IsStringNullOrEmpty(paramCaseNumber) &&
            datacheck.IsStringNullOrEmpty(paramVCAN)) {
                errorMessage = ERROR_PARAMETERS;
                return false;
            }
        
        return true;
    }
    
    // It redirects to an existing Warranty Case
    private void redirectToAnExistingCase() {
        
        if(paramCaseNumber != null && paramCaseNumber != ''){
            warrantyCases = [SELECT Id, Name
                             FROM Warranty_Case__c
                             WHERE Name = :paramCaseNumber];
        }
        else
        {
            warrantyCases = [SELECT Id, Name
                             FROM Warranty_Case__c
                             WHERE Dealer_Code__c = :paramDealerCode
                             LIMIT 5];
        }
        
        showCaseSection = true;
        
        if (warrantyCases != null && warrantyCases.size() > 0) {
            redirectURL = URL.getCurrentRequestUrl().toExternalForm();
            if (redirectURL.contains('/apex')) {
                redirectURL = redirectURL.substring(0, 
                                                    redirectURL.indexOf('/apex'));
                redirectURL += '/' + warrantyCases[0].Id;
                redirectToPage = true;  
            }           
        }
        else {
            errorMessage = ERROR_CASE_NUMBER;
            showErrorMessage = true;
        }
    }
    //AAB 9/18/2014 - Search HOST for VCANS
    private void searchVCAN() 
    {
        if (datacheck.IsStringNullOrEmpty(paramDealerCode) ||
            datacheck.IsStringNullOrEmpty(paramVIN) ||
            datacheck.IsStringNullOrEmpty(paramWorkOrderNumber) ||
            datacheck.IsStringNullOrEmpty(paramWOLine)) {
                return;
            }
        
        searchVCANs(paramVIN, paramWorkOrderNumber, paramWOLine, paramDealerCode);
        
    }
    //AAB 9/18/2014 - Search for WCC by Ref Number
    private void searchHostReference() 
    {
        if (datacheck.IsStringNullOrEmpty(paramHOSTRefNum)) {
            return;
        }
        
        searchRelatedWarrantyCasesToTheReferenceNumber(paramHOSTRefNum);
        
    }
    
    // It searches for Dealer using the Dealer Code
    private void searchDealer() {
        showDealerSection = false;
        
        if (datacheck.IsStringNullOrEmpty(paramDealerCode) &&
            datacheck.IsStringNullOrEmpty(paramDealerName)) {
                return;
            }
        
        String dealerRecordTypeId = 
            Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(
                RECORD_TYPE_DEALER).getRecordTypeId();
        Set<Id> dealerIds = new Set<Id>();
        
        //AAB Recordtypes for search
        String NESNARecordTypeId = Schema.Sobjecttype.Dealer_VIN_Alerts__c.getRecordTypeInfosByName().get(
                'NESNA Alerts').getRecordTypeId();
        String DealerCommentsTypeId = Schema.Sobjecttype.Dealer_VIN_Alerts__c.getRecordTypeInfosByName().get(
                'Dealer Comments').getRecordTypeId();
        
        for(Account acc : [select Id from Account WHERE RecordTypeId =:dealerRecordTypeId and Dealer_Code__c=:paramDealerCode])
        {
            dealerIds.add(acc.Id);
        }
        
        if(dealerIds.size()<1)
        {
            errorMessage = ERROR_UNKNOWN_DEALER;
            showErrorMessage = true;
            return;
        }
        
        dealers = [SELECT Id, Name, BillingStreet, BillingCity, BillingState,
            BillingPostalCode, Phone, DTS_A_Stage_User__r.Full_Name__c, 
            DTS_A_Stage_User__r.Email__c, DTS_A_Stage_User__r.Cell_Phone__c, 
            DTS_A_Stage_User__r.Office_Phone__c, 
            FOM_Stage_User__r.Full_Name__c, 
            FOM_Stage_User__r.Email__c, 
            FOM_Stage_User__r.Cell_Phone__c, 
            FOM_Stage_User__r.Office_Phone__c, 
            WCC_Dealer_Handling_Instructions__c, 
            Dealer_Limit__c, 
            Dealer_Inactive_Indicator__c, 
            Dealer_Code__c
            FROM Account 
            WHERE Id in :dealerIds and RecordTypeId =:dealerRecordTypeId];
        
        if (dealers != null && dealers.size() > 0) {
            foundDealer = dealers[0];
            showDealerSection = true;
            
            if (dealers.size() > 0) {
                searchRelatedCasesToTheDealer(dealers[0].Id);                
                List<Dealer_VIN_Alerts__c> alerts = [select Alert_Comments__c, Dealer__c, Dealer__r.Name, Special_Instructions__c, VIN__c, VIN__r.Name, Type__c from Dealer_VIN_Alerts__c where Dealer__c=:dealers[0].Id 
                                                     and RecordTypeId=:NESNARecordTypeId
                                                     and Status__c='Active' order by Added_Date__c desc];
                
                if(alerts != null && alerts.size()>0)
                {
                    for(Dealer_VIN_Alerts__c alert : alerts)
                    {
                        dealerVINAlerts.Add(alert);
                    }
                    DealerVINAlert = true;
                }
                
                alerts = [select Alert_Comments__c, Added_Date__c, Alert_Inactive_Date__c, CPIA_ID__c, Dealer__c, Dealer__r.Name, Special_Instructions__c, VIN__c, VIN__r.Name, Type__c from Dealer_VIN_Alerts__c where Dealer__c=:dealers[0].Id 
                                                     and RecordTypeId=:DealerCommentsTypeId
                                                     and Status__c='Active' order by Added_Date__c desc];
                
                if(alerts != null && alerts.size()>0)
                {
                    for(Dealer_VIN_Alerts__c alert : alerts)
                    {
                        dealerComments.Add(alert);
                    }
                    showDealerComments = true;
                }
                
                searchDealerSuspendedClaims(dealers[0].Dealer_Code__c, dealers[0].Id);
                
            }
        }
        else {
            errorMessage = ERROR_UNKNOWN_DEALER;
            showErrorMessage = true;
        }
    }
    
    //AAB - Search VCAN
    private void searchVCANs(string paramVIN, string paramWorkOrderNumber, string paramWOLine, string paramDealerCode)
    {
        oResponse = new VCANJSONResponse();
        Blob key = Blob.valueOf('ABC1234DEF9012GHIJKLZZZYYY123465');
        Blob IV = Blob.valueOf('123456ZCBDE4YAGH');
        //string authKey = 'X987147' + ':' + '90NissanT';
        string authKey = Label.VCAN_Auth_Key;
        string username = Label.VCAN_Service_User;
        Blob cipherText = Crypto.encrypt('AES256', key, IV, Blob.valueOf(username));
        username = EncodingUtil.base64Encode(cipherText);
        string password = Label.VCAN_Service_Password;
        cipherText = Crypto.encrypt('AES256', key, IV, Blob.valueOf(password));
        password = EncodingUtil.base64Encode(cipherText);         
        
        Nna360VCAN2MasterServiceSoap.VCANMasterServiceHttpPort service = new Nna360VCAN2MasterServiceSoap.VCANMasterServiceHttpPort();
        service.inputHttpHeaders_x=new Map<String,String>();
        service.timeout_x = 120000;
        Blob headerValue = Blob.valueOf(authKey);  //X987147   -90NissanT
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.debug('Authorization - '+authorizationHeader);
        service.inputHttpHeaders_x.put('Authorization',authorizationHeader);
        String tmplistVins = paramVIN;
        
        if(tmplistVins.indexOf(' ')!=11 && tmplistVins.length()>=12)
        {
            tmplistVins = tmplistVins.substring(0,11) + ' ' + tmplistVins.substring(11);
        }
        
        String tmpWONumber = paramWorkOrderNumber;
        String tmpWOLine = paramWOLine;
        String tmpServiceFacility = paramDealerCode;
        Nna360VCAN2MasterServiceSoap.viewVCANResp response;
        
        if(Label.VCAN_Disable_Logins=='true')
        {
            System.debug('VCAN Host Logins disabled');
            return;
        }
        if(Test.isRunningTest())
        {
            return;
        }
        response = service.viewVCAN(tmplistVINs,tmpWONumber,tmpWOLine,tmpServiceFacility, username, password);
        if(response != null)
        {
            system.debug('VCAN Returned');
            Nna360VCAN2MasterServiceSoap.VCANDetails details = response.viewVCANResp.vcanDetails;
            if(details!=null)
            {
                oResponse.VCANRefNumber=details.VCANRefNumber;
                oResponse.AffiliateCode=details.AffiliateCode;               
                oResponse.WONumber=details.WONumber;
                oResponse.WOLine=details.WOLine;
                oResponse.ServiceFacility=details.ServiceFacility;                
                oResponse.VIN=details.VIN;                
                oResponse.WOOpenDate=details.WOOpenDate;                
                oResponse.Miles=details.Miles;
                oResponse.PFPPO=details.PFPPO;
                oResponse.CallerName=details.CallerName;
                oResponse.CallerPhone=details.CallerPhone;
                oResponse.CallerExt=details.CallerExt;
                oResponse.CustomerName=details.CustomerName;
                oResponse.PartsAtCost=details.PartsAtCost;                
                oResponse.ForceGoodwill=details.ForceGoodwill;
                oResponse.ApprovalStatus=details.ApprovalStatus;
                if(oResponse.ApprovalStatus != null)
                {
                    String hApprovalStatus = oResponse.ApprovalStatus.substring(0,1);
                    if(hApprovalStatus=='P')
                    {
                        oResponse.ApprovalStatus = 'Pending';
                    }
                    else if(hApprovalStatus=='A')
                    {
                        oResponse.ApprovalStatus = 'Approved';
                    }
                    else if(hApprovalStatus=='D')
                    {
                        oResponse.ApprovalStatus = 'Denied';
                    }
                }
                oResponse.ApprId=details.ApprId;
                oResponse.ApprByName=details.ApprId;
                if(oResponse.ApprId!=null && oResponse.ApprId!='')
                {
                    List<User> approvers = [Select Name from user where ZCA_Id__c=:oResponse.ApprId];
                    if(approvers!=null && approvers.size()>0)
                    {
                        oResponse.ApprByName = approvers[0].Name;
                    }
                }
                oResponse.ApprDate=details.ApprDate;
                oResponse.EnteredByUserId=details.EnteredByUserId;
                oResponse.EnteredDate=details.EnteredDate;
                oResponse.ChangedByUserId=details.ChangedByUserId;
                oResponse.ChangedByName=details.ChangedByUserId;
                if(oResponse.ChangedByUserId!=null && oResponse.ChangedByUserId!='')
                {
                    List<User> updaters = [Select Name from user where ZCA_Id__c=:oResponse.ChangedByUserId];
                    if(updaters!=null && updaters.size()>0)
                    {
                        oResponse.ChangedByName = updaters[0].Name;
                    }
                }
                oResponse.ChangedDate=details.ChangedDate;
                oResponse.LanId=details.LanId;   
                
                Nna360VCAN2MasterServiceSoap.ApprovalAmounts apAmounts = details.ApprovalAmounts;
                if(apAmounts != null)
                {
                    oResponse.Parts = apAmounts.Parts;
                    oResponse.LBR = apAmounts.LBR;
                    oResponse.Expense = apAmounts.Expense;
                    oResponse.Total = apAmounts.Total;
                }
                
                Nna360VCAN2MasterServiceSoap.ActApprovalCondition actCond = details.ActApprovalCondition;
                if(actCond != null)
                {
                    oResponse.NormalApproval = actCond.NormalApproval;
        			oResponse.RepairReview = actCond.RepairReview;
        			oResponse.MileageProgressReview = actCond.MileageProgressReview;
        			oResponse.CampaignDiffDealer = actCond.CampaignDiffDealer;
        			oResponse.GoodwillApproval = actCond.GoodwillApproval;
                }
                
                
                List<String> comments = new List<String>(details.ApprovalComments);
                String commentString = '';
                if(!comments.isEmpty())
                {
                    //parse out date and updatedby
                    //[comments in line] 080114 DWH001L
                    string tmpComment = comments[0];                    
                    if(tmpComment.lastIndexOf(' ')>0)
                    {
                        tmpComment = tmpComment.substring(0, tmpComment.lastIndexOf(' '));
                    }
                    if(tmpComment.lastIndexOf(' ')>0)
                    {
                        tmpComment = tmpComment.substring(0, tmpComment.lastIndexOf(' '));
                    } 
                    commentString = tmpComment;                    
                    
                    comments.remove(0);
                    while(!comments.isEmpty())
                    {
                        tmpComment = comments[0];
                        if(tmpComment.lastIndexOf(' ')>0)
                        {
                            tmpComment = tmpComment.substring(0, tmpComment.lastIndexOf(' '));
                        }
                        if(tmpComment.lastIndexOf(' ')>0)
                        {
                            tmpComment = tmpComment.substring(0, tmpComment.lastIndexOf(' '));
                        }
                        commentString += '<br/>' + tmpComment;
                        comments.remove(0);
                    }
                }                
                oResponse.ApprovalComments=commentString;
                
                oResponse.message = details.message;
                oResponse.success = true;
                showHOSTVCANSection = true;
            }
            else
            {
                Nna360VCAN2MasterServiceSoap.viewVCAN_Output errorOutput = (Nna360VCAN2MasterServiceSoap.viewVCAN_Output) response.viewVCANResp;
                if(errorOutput != null)
                {
                    if(errorOutput.MessageDescription != null)
                    {
                        String errorMsg = errorOutput.MessageDescription;
                        if(errorMsg.indexOf(VCAN_Password_Error_String)>-1)
                        {
                            errorMessage = VCAN_Password_Error;
                            showErrorMessage = true;
                        }
                        else if(errorMsg.indexOf(VCAN_Account_Locked_Error_String)>-1)
                        {
                            errorMessage = VCAN_Account_Locked_Error;
                            showErrorMessage = true;
                        }
                        else
                        {
                            errorMessage = errorOutput.MessageDescription;
                            showErrorMessage = true;
                        }
                    }
                }
                oResponse.message = 'Unexpected Error';
                oResponse.success = false;
            }          
        }        
        else
        {
            oResponse.message = 'Unexpected Error';
            oResponse.success = false;
            errorMessage = 'Unexpected Error';
            showErrorMessage = true;
        }  
    }
    
    //AAB Related WCC Search for reference numbers
    private void searchRelatedWarrantyCasesToTheReferenceNumber(String refNumber)
    {
        showReferenceSection = true;
        hostRelatedWarrantyCases = [SELECT Id, Name, Repair_Work_Order__c,
                                    Job_Line_Number__c, Dealer_Code__c, Parts__c,
                                    Expenses__c, Total_Amount_Approved__c, HOST_Reference_Number__c, Owner.Name, CreatedDate
                                    FROM Warranty_Case__c
                                    WHERE HOST_Reference_Number__c = :refNumber
                                    ORDER BY Name DESC
                                    LIMIT 5];
        
        showReferenceRelatedWarrantyCases = hostRelatedWarrantyCases != null && 
            hostRelatedWarrantyCases.size() > 0;
    }
    
    //AAB Related WCC Search for vehciles
    private void searchRelatedWarrantyCasesToTheVehicle(Id vehicleId)
    {
        vehicleRelatedWarrantyCases = [SELECT Id, Name, Repair_Work_Order__c,
                                       Job_Line_Number__c, Dealer_Code__c, Parts__c,
                                       Expenses__c, Total_Amount_Approved__c, HOST_Reference_Number__c, Owner.Name, CreatedDate
                                       FROM Warranty_Case__c
                                       WHERE Vehicle__c = :vehicleId
                                       ORDER BY Name DESC
                                       LIMIT 5];
        
        showVehicleRelatedWarrantyCases = vehicleRelatedWarrantyCases != null && 
            vehicleRelatedWarrantyCases.size() > 0;
    }
    
    //AAB Search for Suspended Dealer Claims
    private void searchDealerSuspendedClaims(String dealerCode, Id dealerId)
    {
        dealerSuspendedClaims = [Select Id, Name,
                                 Work_Order_Number__c,
                                 Claim_Line_Number__c,
                                 Dealer_Number__c,
                                 Vehicle_ID__c,
                                 Vehicle_ID__r.Name,
                                 Claim_Customer_First_Name__c,
                                 Claim_Customer_Last_Name__c
                                 from Service_Repair_History__c
                                 where
                                 Dealer_ID__c =:dealerId and
                                 //Dealer_Number__c =:dealerCode and
                                 Work_Order_Line_Status_Code__c = 'S'
                                 order by Work_Order_number__c desc nulls last, Claim_Line_Number__c desc nulls last
                                ];
        
        if(dealerSuspendedClaims!=null && dealerSuspendedClaims.size()>0)
        {
            showDealerSuspendedClaims = true;
            List<ServiceHistoryWrapper> dealerSuspendedClaimsWrapperList = buildSRHList(dealerSuspendedClaims);
            dealerSuspendedClaimsWrapperList.sort();
            
            dealerSuspendedClaims.clear();
            
            for(ServiceHistoryWrapper shw : dealerSuspendedClaimsWrapperList)
            {
                dealerSuspendedClaims.add(shw.srh);
            }
        }
    }
    
    //WFT Search for Vehicle Suspended Claims
    private Boolean searchVehicleSuspendedClaims(String VIN)
    {
        
        
        vehicleSuspendedClaims = [Select Id, Name,
                                  Work_Order_Number__c,
                                  Claim_Line_Number__c,
                                  Dealer_Number__c,
                                  Vehicle_ID__c,
                                  Vehicle_ID__r.Name,
                                  Complaint_Description__c,
                                  Vehicle_Claim_Authorization_Number__c,
                                  Work_Order_Line_Status_Code__c,
                                  Transaction_Date__c, 
                                  Vehicle_Mileage_Number__c,
                                  Claim_Customer_First_Name__c,
                                  Claim_Customer_Last_Name__c,
                                  Vehicle_Repair_Open_Date__c,
                                  LastModifiedDate, LastModifiedBy.Name, Claim_Type_Code__c
                                  from Service_Repair_History__c
                                  where
                                  //Dealer_ID__c =:dealerId and
                                  //Dealer_Number__c =:dealerCode and
                                  Vehicle_identification_Number__c =:VIN and
                                  Work_Order_Line_Status_Code__c = 'S'
                                  order by Work_Order_number__c desc nulls last, Claim_Line_Number__c desc nulls last
                                 ];
        
        
        
        if(vehicleSuspendedClaims !=null && vehicleSuspendedClaims.size()>0)
        {
            showVehicleSuspendedClaims = true;
            List<ServiceHistoryWrapper> vehicleSuspendedClaimsWrapperList = buildSRHList(vehicleSuspendedClaims);
            vehicleSuspendedClaimsWrapperList.sort();
            
            vehicleSuspendedClaims.clear();
            
            for(ServiceHistoryWrapper shw : vehicleSuspendedClaimsWrapperList)
            {
                vehicleSuspendedClaims.add(shw.srh);
            }
        }
        return showVehicleSuspendedClaims;
    }
    
    
    
    // It searches for the Cases related to the Dealer
    //TH - Updated to pull from new Warranty Case object
    private void searchRelatedCasesToTheDealer(Id dealerId) {
        dealerRelatedCases = [SELECT Id, Name, Repair_Work_Order__c,
                              Job_Line_Number__c, Dealer_Code__c, Parts__c,
                              Expenses__c, Total_Amount_Approved__c, HOST_Reference_Number__c, Owner.Name, CreatedDate
                              FROM Warranty_Case__c
                              WHERE Dealer__c = :dealerId
                              ORDER BY Name DESC
                              LIMIT 5];
        
        showDealerRelatedCases = dealerRelatedCases != null && 
            dealerRelatedCases.size() > 0;
    }
    
    //Search for Work Order Number
    //Search for W/O, if no results invokes an update webservice based on VIN and then requeries.
    private void searchWorkorder(){
        showWorkOrderSection = false;      
        foundWorkOrder = new Service_Repair_History__c();
        
        if (!datacheck.IsStringNullOrEmpty(paramWorkOrderNumber)){
            
            try {
            
                Map<String, ID> mapVINs = new Map<String, ID>();
                List<Service_Repair_History__c> SRHs = new List<Service_Repair_History__c>();
                mapVINs.put(paramVIN, null);
                Controller_ByVinsInAccount_Claims.callout(mapVINs, SRHs);
                
                //AAB 9/4/2014 - Work Orders should filter by Line Number and Dealer Code if applicable
                if(datacheck.IsStringNullOrEmpty(paramWOLine) && datacheck.IsStringNullOrEmpty(paramDealerCode))
                {
                    workorder = [SELECT Id, Name, Vehicle_ID__c, Work_Order_Number__c, Claim_Line_Number__c, 
                                 Dealer_Number__c, Complaint_Description__c, Vehicle_Claim_Authorization_Number__c,
                                 Work_Order_Line_Status_Code__c, Transaction_Date__c, Vehicle_Mileage_Number__c,
                                 Claim_Customer_First_Name__c, Claim_Customer_Last_Name__c, Vehicle_Repair_Open_Date__c,
                                 LastModifiedDate, LastModifiedBy.Name, Claim_Type_Code__c
                                 FROM Service_Repair_History__c
                                 WHERE Work_Order_Number__c = :paramWorkOrderNumber];
                }
                else if(datacheck.IsStringNullOrEmpty(paramDealerCode)==false && datacheck.IsStringNullOrEmpty(paramWOLine))
                {
                    workorder = [SELECT Id, Name, Vehicle_ID__c, Work_Order_Number__c, Claim_Line_Number__c, 
                                 Dealer_Number__c, Complaint_Description__c, Vehicle_Claim_Authorization_Number__c,
                                 Work_Order_Line_Status_Code__c, Transaction_Date__c, Vehicle_Mileage_Number__c,
                                 Claim_Customer_First_Name__c, Claim_Customer_Last_Name__c, Vehicle_Repair_Open_Date__c,
                                 LastModifiedDate, LastModifiedBy.Name, Claim_Type_Code__c
                                 FROM Service_Repair_History__c
                                 WHERE Work_Order_Number__c = :paramWorkOrderNumber and Dealer_Number__c=:paramDealerCode];
                }
                else if(datacheck.IsStringNullOrEmpty(paramDealerCode) && datacheck.IsStringNullOrEmpty(paramWOLine)==false)
                {
                    workorder = [SELECT Id, Name, Vehicle_ID__c, Work_Order_Number__c, Claim_Line_Number__c, 
                                 Dealer_Number__c, Complaint_Description__c, Vehicle_Claim_Authorization_Number__c,
                                 Work_Order_Line_Status_Code__c, Transaction_Date__c, Vehicle_Mileage_Number__c,
                                 Claim_Customer_First_Name__c, Claim_Customer_Last_Name__c, Vehicle_Repair_Open_Date__c,
                                 LastModifiedDate, LastModifiedBy.Name, Claim_Type_Code__c
                                 FROM Service_Repair_History__c
                                 WHERE Work_Order_Number__c = :paramWorkOrderNumber and Claim_Line_Number__c=:paramWOLine];
                }
                else
                {
                    workorder = [SELECT Id, Name, Vehicle_ID__c, Work_Order_Number__c, Claim_Line_Number__c, 
                                 Dealer_Number__c, Complaint_Description__c, Vehicle_Claim_Authorization_Number__c,
                                 Work_Order_Line_Status_Code__c, Transaction_Date__c, Vehicle_Mileage_Number__c,
                                 Claim_Customer_First_Name__c, Claim_Customer_Last_Name__c, Vehicle_Repair_Open_Date__c,
                                 LastModifiedDate, LastModifiedBy.Name, Claim_Type_Code__c
                                 FROM Service_Repair_History__c
                                 WHERE Work_Order_Number__c = :paramWorkOrderNumber and Dealer_Number__c=:paramDealerCode and Claim_Line_Number__c=:paramWOLine];
                }
                
            } catch (CalloutException ex) {
                ResponseOutput = ResponseOutput + ' Status: Claims CalloutException ' + ex.getMessage() + '.';
            }
        }
        
        if(workorder != null && workorder.size() > 0){
            
            foundWorkOrder = workorder[0];
            showWorkOrderSection = true;
            
        }
        
    }
    
    // It searches for the Vehicle using the VIN
    private void searchVehicle() {
        showVehicleSection = false;
        foundVehicle = new Vehicle__c();
        
        if (!datacheck.IsStringNullOrEmpty(paramVIN)) {
            if(paramVIN.length()== 6){
                vehicles = [SELECT Id, Name,
                            Model_Year__c, Model_Line_Name__c , Make_Name__c,
                            Open_Recall__c, Branded_Title__c, OwnerId
                            FROM Vehicle__c
                            WHERE trimVIN__c = :paramVIN];
            }
            else{
                String thisVin = paramVIN.deleteWhitespace();
                vehicles = [SELECT Id, Name,
                            Model_Year__c, Model_Line_Name__c , Make_Name__c,
                            Open_Recall__c, Branded_Title__c, OwnerId
                            FROM Vehicle__c
                            WHERE Name = :thisVin];
            }
            
            if (vehicles != null && vehicles.size() > 0) {
                foundVehicle = vehicles[0];
                
                /*String thisVin = paramVIN;
                Vehicle__c v = [select id from vehicle__c where vehicle_identification_number__c=:thisVin];
                Controller_ByVinsInVehicle controller = new Controller_ByVinsInVehicle(new ApexPages.StandardController(v));
                controller.doSearch();*/
                
                
                showVehicleSection = true;
                
                searchRelatedWarrantyCasesToTheVehicle(vehicles[0].Id);
               // searchVehicleSuspendedClaims(paramVIN);
               // //AAB Recordtypes for search
        		String VINRecordTypeId = Schema.Sobjecttype.Dealer_VIN_Alerts__c.getRecordTypeInfosByName().get(
                'VIN Alert').getRecordTypeId();
                
                List<Dealer_VIN_Alerts__c> alerts = [select Alert_Comments__c, 
                                                     Added_Date__c, Alert_Inactive_Date__c, CPIA_ID__c,                                                     
                                                     Dealer__c, Dealer__r.Name, Special_Instructions__c, VIN__c, VIN__r.Name, Type__c from Dealer_VIN_Alerts__c where VIN__c=:vehicles[0].Id and Type__c<>'Dealer' and Status__c='Active' order by ID desc];
                
                if(alerts != null && alerts.size()>0)
                {
                    for(Dealer_VIN_Alerts__c alert : alerts)
                    {
                        dealerVINAlerts.Add(alert);
                    }
                    
                    DealerVINAlert = true;
                }
                
                searchRelatedCasesToTheVehicle(vehicles[0].Id);
                lastOwner = searchLastOwner(vehicles[0].Id);
            }
        }
    }
    
    public PageReference refreshVinInfo() {
       if (paramVIN != null && paramVIN.length() > 0) {
        String thisVin = paramVIN.deleteWhitespace();
        List<Vehicle__c> v = [select id from vehicle__c where vehicle_identification_number__c=:thisVin];
         if (v.size() > 0) {
            Controller_ByVinsInVehicle controller = new Controller_ByVinsInVehicle(new ApexPages.StandardController(v[0]));
            controller.doSearch();
            vehicleCall = true;
            searchVehicleSuspendedClaims(thisVin);
        }
       }
        return null;
    }
    
    
    
    private void searchRecall(){
        showRecall = false;
        system.debug('found vehicle:' + foundVehicle.Id);
        if(foundVehicle != null && !datacheck.IsStringNullOrEmpty(paramVIN) && foundVehicle.Name != null)
        {
            foundRecall = [SELECT Id, Name, Campaign_Type__c,
                           Campaign_Primary_Description__c,
                           Recall_Secondary_Description__c,
                           Effective_Date__c, TSB_Number__c, GL_Code__c,
                           Recall_Identifier__c, Recall_Status__c
                           FROM Vehicle_Recall__c
                           WHERE vehicle__r.Name = :foundVehicle.Name
                           AND Recall_Status__c = 'Open'];
        }
        
        if(foundRecall != null && foundRecall.size()>0){
            showRecall = true;
        }
        system.debug('show recall:' + showRecall);
    }
    // It searches for the Cases related to the Vehicle
    private void searchRelatedCasesToTheVehicle(Id vehicleId) {
        vehicleRelatedCases = [SELECT Id, CaseNumber, Subject,
                               Description, CreatedDate, ClosedDate, RecordType.Name
                               FROM Case
                               WHERE Vehicle_Name__c = :vehicleId
                               AND RecordTypeId IN ('012F0000000y9y7', '012F0000000yCuE',
                                                    '012F0000000yC0B', '012F0000000yBIr', '012F0000000yF8R',
                                                    '012F0000000yFmQ')
                               ORDER BY CaseNumber DESC
                               LIMIT 10];
        
        showVehicleRelatedCases = vehicleRelatedCases != null && 
            vehicleRelatedCases.size() > 0;
    }
    
    // It searches the last owner of the informed Vehicle
    private Vehicle_Ownership_History__c searchLastOwner(Id vehicleId) {
        List<Vehicle_Ownership_History__c> owners = [SELECT Owner__r.Id,
                                                     Owner__r.Name
                                                     FROM Vehicle_Ownership_History__c
                                                     WHERE Vehicle__c = :vehicleId
                                                     ORDER BY End_Date__c DESC];
        
        if (owners != null && owners.size() > 0) {
            return owners[0]; 
        }
        else {
            return null;
        }
    }
    
    //Generates a new Warranty Case record URL and passes the appropriate parameters to that record.
    public void newCase(){
        
        //String strWODate = foundWorkOrder.Transaction_Date__c.format('MM/dd/yy');
        
        string returnURL = '';
        
        returnURL = URL.getCurrentRequestUrl().toExternalForm();
        if(Test.isRunningTest()==false)
        {
            returnURL = returnURL.substring(0,returnURL.indexOf('/apex'));
        }
        returnURL = returnURL + '/apex/warranty_casecreation';
        
        redirectURL = URL.getCurrentRequestUrl().toExternalForm();
        if(Test.isRunningTest()==false)
        {
            redirectURL = redirectURL.substring(0, redirectURL.indexOf('/apex'));
        }
        redirectURL += '/' + WCC_TYPE_ID + '/e?';
        redirectURL += '&' + WC_FIELD_WO_NUMBER + '=' + paramWorkOrderNumber;
        redirectURL += '&' + WC_FIELD_WO_LINE + '=' + paramWOLine;
        
        if(foundVehicle!=null && foundVehicle.Name != null)
        {
            redirectURL += '&CF' + WC_FIELD_VIN + '=' + foundVehicle.Name;
            redirectURL += '&CF' + WC_FIELD_VIN  + '_lkid=' + foundVehicle.Id;
        }
        redirectURL += '&' + WC_FIELD_CALLER_NAME + '=' + paramCallerName;
        //redirectURL += '&' + WC_FIELD_WO_DATE + '=' + strWODate ;
        //redirectURL += '&' + WC_FIELD_MILES + '=' + foundWorkOrder.Vehicle_Mileage_Number__c;
        redirectURL += '&' + WC_FIELD_VCAN_TYPE + '=' + (wc.VCAN_Type__c==null ? '' : wc.VCAN_Type__c);
        redirectURL += '&' + WC_FIELD_CUSTOMER_NAME + '=' + (wc.Customer_Name__c==null ? '' : wc.Customer_Name__c);
        redirectURL += '&' + WC_FIELD_REQUESTORS_PHONE + '=' + (wc.Requestor_s_Phone_Number__c==null ? '' : wc.Requestor_s_Phone_Number__c);
        redirectURL += '&' + WC_FIELD_REQUESTORS_TITLE + '=' + (wc.Requestor_Title__c==null ? '' : wc.Requestor_Title__c);
        
        //AAB 9/4/2014 - Reason, Description, Error Code, Sttaus added
        redirectURL += '&' + WC_FIELD_REASON + '=' + (wc.Reason__c==null ? '' : wc.Reason__c);        
        redirectURL += '&' + WC_FIELD_SUBREASON + '=' + (wc.Subreason__c==null ? '' : wc.Subreason__c);    
        redirectURL += '&' + WC_FIELD_ERROR_CODE + '=' + (wc.Error_Code__c==null ? '' : wc.Error_Code__c);
        redirectURL += '&' + WC_FIELD_DESCRIPTION + '=' + (wc.Description__c==null ? '' : wc.Description__c);
        redirectURL += '&' + WC_FIELD_STATUS + '=' + (wc.Status__c==null ? '' : wc.Status__c);
        
        if(foundDealer!=null && foundDealer.Name!=null)
        {
            redirectURL += '&CF' + WC_FIELD_DEALER_NAME + '=' + foundDealer.Name;
            redirectURL += '&CF' + WC_FIELD_DEALER_NAME + '_lkid=' + foundDealer.Id;
        }
        
        redirectURL += '&' + WC_FIELD_NOTES + '=' + (paramNotes==null ? '' : EncodingUtil.urlEncode(paramNotes,'UTF-8')) ;
        redirectURL += '&RecordType=' + GI_RECORD_TYPE;
        redirectURL += '&retURL=' + returnURL;
        
        system.debug(redirectURL);
        redirectToPage = true;
        
    }
    public void newVCANCase(){
        
        //String strWODate = foundWorkOrder.Transaction_Date__c.format('MM/dd/yy');
        
        string returnURL = '';
        returnURL = URL.getCurrentRequestUrl().toExternalForm();
        if(Test.isRunningTest()==false)
        {
            returnURL = returnURL.substring(0,returnURL.indexOf('/apex'));
        }
        returnURL = returnURL + '/apex/warranty_casecreation';
        
        redirectURL = URL.getCurrentRequestUrl().toExternalForm();
        if(Test.isRunningTest()==false)
        {
            redirectURL = redirectURL.substring(0, redirectURL.indexOf('/apex'));
        }
        redirectURL += '/' + WCC_TYPE_ID + '/e?';
        redirectURL += '&' + WC_FIELD_WO_NUMBER + '=' + paramWorkOrderNumber;
        redirectURL += '&' + WC_FIELD_WO_LINE + '=' + paramWOLine;
        if(foundVehicle!=null && foundVehicle.Name!=null)
        {
            redirectURL += '&CF' + WC_FIELD_VIN + '=' + foundVehicle.Name;
            redirectURL += '&CF' + WC_FIELD_VIN  + '_lkid=' + foundVehicle.Id;
        }
        
        redirectURL += (oResponse!=null && oResponse.WOOpenDate!=null && oResponse.WOOpenDate!='') ? '&' + WC_FIELD_WO_DATE + '=' + oResponse.WOOpenDate : '';
        redirectURL += (oResponse!=null && oResponse.Parts!=null && oResponse.Parts!='') ? '&' + WC_FIELD_PARTS + '=' + oResponse.Parts : '';
        redirectURL += (oResponse!=null && oResponse.LBR!=null && oResponse.LBR!='') ? '&' + WC_FIELD_LABOR + '=' + oResponse.LBR : '';
        redirectURL += (oResponse!=null && oResponse.Expense!=null && oResponse.Expense!='') ? '&' + WC_FIELD_EXPENSES + '=' + oResponse.Expense : '';
        redirectURL += (oResponse!=null && oResponse.Miles!=null && oResponse.Miles!='') ? '&' + WC_FIELD_MILES + '=' + oResponse.Miles : '';
        redirectURL += (oResponse==null || oResponse.Parts==null || oResponse.Parts=='') ? '&' + WC_FIELD_PARTS + '=0' : '';
        redirectURL += (oResponse==null || oResponse.LBR==null || oResponse.LBR=='') ? '&' + WC_FIELD_LABOR + '=0' : '';
        redirectURL += (oResponse==null || oResponse.Expense==null || oResponse.Expense=='') ? '&' + WC_FIELD_EXPENSES + '=0' : '';
        
        redirectURL += (oResponse!=null && oResponse.PFPPO!=null && oResponse.PFPPO!='') ? '&' + WC_FIELD_PFPO + '=' + oResponse.PFPPO : '';
        redirectURL += (oResponse!=null && oResponse.ApprovalStatus!=null && oResponse.ApprovalStatus!='') ? '&' + WC_FIELD_APPROVAL_STATUS + '=' + oResponse.ApprovalStatus : '';
        redirectURL += (oResponse!=null && oResponse.NormalApproval!=null && oResponse.NormalApproval!='') ? '&' + WC_FIELD_NORMAL_APPROVAL + '=' + oResponse.NormalApproval : '';
        redirectURL += (oResponse!=null && oResponse.MileageProgressReview!=null && oResponse.MileageProgressReview!='') ? '&' + WC_FIELD_MILEAGE_REVIEW + '=' + oResponse.MileageProgressReview : '';
        redirectURL += (oResponse!=null && oResponse.RepairReview!=null && oResponse.RepairReview!='') ? '&' + WC_FIELD_REPEAT_REPAIR_REVIEW + '=' + oResponse.RepairReview : '';
        redirectURL += (oResponse!=null && oResponse.CampaignDiffDealer!=null && oResponse.CampaignDiffDealer!='') ? '&' + WC_FIELD_DUPLICATE_CAMPAIGN + '=' + oResponse.CampaignDiffDealer : '';
        redirectURL += (oResponse!=null && oResponse.GoodwillApproval!=null && oResponse.GoodwillApproval!='') ? '&' + WC_FIELD_GOODWILL_APPROVAL + '=' + oResponse.GoodwillApproval : '';
        redirectURL += (oResponse!=null && oResponse.ForceGoodwill!=null && oResponse.ForceGoodwill!='') ? '&' + WC_FIELD_FORCE_GOODWILL_APPROVAL + '=' + (oResponse.ForceGoodwill=='Y' ? '1' : '') : '';        
        redirectURL += (oResponse!=null && oResponse.PartsAtCost!=null && oResponse.PartsAtCost!='') ? '&' + WC_FIELD_PARTS_AT_COST + '=' + (oResponse.PartsAtCost=='Y' ? '1' : '') : '';
        
        redirectURL += (oResponse!=null && oResponse.CallerName!=null && oResponse.CallerName!='') ? '&' + WC_FIELD_CALLER_NAME + '=' + oResponse.CallerName : '';
        redirectURL += (oResponse!=null && oResponse.CallerPhone!=null && oResponse.CallerPhone!='') ? '&' + WC_FIELD_REQUESTORS_PHONE + '=' + oResponse.CallerPhone : '';
        redirectURL += (oResponse!=null && oResponse.CustomerName!=null && oResponse.CustomerName!='') ? '&' + WC_FIELD_CUSTOMER_NAME + '=' + oResponse.CustomerName : '';
        
        
        redirectURL += (oResponse==null || oResponse.CallerName==null || oResponse.CallerName=='') && wc.Requestor_s_Name__c != null ? '&' + WC_FIELD_CALLER_NAME + '=' + wc.Requestor_s_Name__c: '';
        redirectURL += (oResponse==null || oResponse.CallerPhone==null || oResponse.CallerPhone=='') && wc.Requestor_s_Phone_Number__c != null ? '&' + WC_FIELD_REQUESTORS_PHONE + '=' + wc.Requestor_s_Phone_Number__c: '';
        redirectURL += (oResponse==null || oResponse.CustomerName==null || oResponse.CustomerName=='') && wc.Customer_Name__c != null ? '&' + WC_FIELD_CUSTOMER_NAME + '=' + wc.Customer_Name__c: '';
                
        redirectURL += '&' + WC_FIELD_VCAN_TYPE + '=' + (wc.VCAN_Type__c==null ? 'WCC' : wc.VCAN_Type__c);
        redirectURL += '&' + WC_FIELD_REQUESTORS_TITLE + '=' + (wc.Requestor_Title__c==null ? '' : wc.Requestor_Title__c);
           //AAB 9/4/2014 - Reason, Description, Error Code added
        redirectURL += '&' + WC_FIELD_REASON + '=' + (wc.Reason__c==null ? '' : wc.Reason__c);       
        redirectURL += '&' + WC_FIELD_SUBREASON + '=' + (wc.Subreason__c==null ? '' : wc.Subreason__c);  
        redirectURL += '&' + WC_FIELD_ERROR_CODE + '=' + (wc.Error_Code__c==null ? '' : wc.Error_Code__c);
        redirectURL += '&' + WC_FIELD_DESCRIPTION + '=' + (wc.Description__c==null ? '' : wc.Description__c);
        redirectURL += '&' + WC_FIELD_ADD_VCAN_COMMENT + '=' + (paramNotes==null ? '' : EncodingUtil.urlEncode(paramNotes,'UTF-8'));
        
        if(foundDealer!=null && foundDealer.Name!=null)
        {
            redirectURL += '&CF' + WC_FIELD_DEALER_NAME + '=' + foundDealer.Name;
            redirectURL += '&CF' + WC_FIELD_DEALER_NAME + '_lkid=' + foundDealer.Id;
        }
        
        redirectURL += '&' + WC_FIELD_NOTES + '=' + (paramNotes==null? '' : EncodingUtil.urlEncode(paramNotes,'UTF-8'));
        
        //Variable Record Type
        if(wc.VCAN_Type__c!=null)
        {
            if(wc.VCAN_Type__c=='Engine')
            {
                redirectURL += '&RecordType=' + ENGINE_RECORD_TYPE;
            }
            else if(wc.VCAN_Type__c=='Transmission')
            {
                redirectURL += '&RecordType=' + TRANS_RECORD_TYPE;
            }
            else
            {
                redirectURL += '&RecordType=' + WCC_RECORD_TYPE;
            }
        }
        else
        {
            redirectURL += '&RecordType=' + WCC_RECORD_TYPE;
        }
        
        redirectURL += '&retURL=' + returnURL;
        
        system.debug(redirectURL);
        redirectToPage = true;
        
    }
    
    // It redirects you to a new Case page with some auto-populated field
    public void selectDealer() {
        for (Account dealer : dealers) {
            if (dealer.Id == selectedDealerId) {
                redirectURL = getNewCaseURL(dealer, foundVehicle);
                
                /*ApexPages.Message msg = new ApexPages.Message(
ApexPages.Severity.INFO, redirectURL);
ApexPages.addMessage(msg);*/
                
                redirectToPage = true;
                break;
            }
        }
    }
    
    // It generates the New Case URL
    private String getNewCaseURL(Account dealer, Vehicle__c vehicle) {
        String caseURL = URL.getCurrentRequestUrl().toExternalForm();
        if (caseURL.contains('/apex')) {
            caseURL = caseURL.substring(0, caseURL.indexOf('/apex'));   
        }
        caseURL += '/500/e?RecordType=' + warrantyId;
        caseURL += '&CF' + FIELD_DEALER + '_lkid=' + dealer.Id;
        caseURL += '&CF' + FIELD_DEALER + '=' + dealer.Name;
        
        if (vehicle.Make_Name__c != null) {
            caseURL += '&' + FIELD_ARCH_MAKE + '=' + vehicle.Make_Name__c;
        }
        
        if (vehicle.Model_Line_Name__c != null) {
            caseURL += '&' + FIELD_ARCH_MODEL + '=' + 
                vehicle.Model_Line_Name__c;
        }
        
        if (vehicle.Model_Year__c != null) {
            caseURL += '&' + FIELD_ARCH_YEAR + '=' + vehicle.Model_Year__c;
        }
        
        if (lastOwner != null) {
            //caseURL += '&' + FIELD_ACCOUNT + '_lkid=' + lastOwner.Owner__r.Id;
            //caseURL += '&' + FIELD_ACCOUNT + '=' + lastOwner.Owner__r.Name;
            caseURL += '&' + FIELD_CUSTOMER_NAME + '=' + 
                lastOwner.Owner__r.Name;
        }
        
        if (!datacheck.IsStringNullOrEmpty(vehicle.Name)) {
            if (showVehicleSection) {
                caseURL += '&CF' + FIELD_VEHICLE + '_lkid=' + vehicle.Id;
                caseURL += '&CF' + FIELD_VEHICLE + '=' + vehicle.Name;
            }
            else {
                caseURL += '&' + FIELD_VIN + '=' + vehicle.Name;
            }
        }
        
        if (!datacheck.IsStringNullOrEmpty(
            dealer.DTS_A_Stage_User__r.Full_Name__c)) {
                caseURL += '&' + FIELD_DTS_FULL_NAME + '=' + 
                    dealer.DTS_A_Stage_User__r.Full_Name__c;
            }
        
        if (!datacheck.IsStringNullOrEmpty(
            dealer.DTS_A_Stage_User__r.Email__c)) {
                caseURL += '&' + FIELD_DTS_EMAIL + '=' + 
                    dealer.DTS_A_Stage_User__r.Email__c;
            }
        
        if (!datacheck.IsStringNullOrEmpty(
            dealer.DTS_A_Stage_User__r.Cell_Phone__c)) {
                caseURL += '&' + FIELD_DTS_CELL_PHONE + '=' + 
                    dealer.DTS_A_Stage_User__r.Cell_Phone__c;
            }
        
        if (!datacheck.IsStringNullOrEmpty(
            dealer.DTS_A_Stage_User__r.Office_Phone__c)) {
                caseURL += '&' + FIELD_DTS_OFFICE_PHONE + '=' + 
                    dealer.DTS_A_Stage_User__r.Office_Phone__c;
            }
        
        if (!datacheck.IsStringNullOrEmpty(
            //TODO: Sanitize ENTER chars
            dealer.WCC_Dealer_Handling_Instructions__c)) {
                caseURL += '&' + FIELD_WCC_INSTRUCTIONS + '=' +
                    EncodingUtil.urlEncode(
                        dealer.WCC_Dealer_Handling_Instructions__c, 'UTF-8');
            }
        
        return caseURL;
    }
    
    public void createVCAN (string id){
        
        if(id !=null && id != ''){
            system.debug(id);
        }
    }
    
    //AAB 9/18/2014 - Clearing Warranty Case Info
    public void clearCaseInformation() 
    {
        redirectToPage = false;
        redirectURL = '';
        paramCallerName = null;
        wc.Reason__c = null;
        wc.Requestor_Title__c = null;
        wc.Error_Code__c = null;
        wc.Requestor_s_Name__c = null;
        wc.Requestor_s_Phone_Number__c = null;
        wc.Description__c = null;
        wc.Customer_Name__c = null;
        wc.VCAN_Type__c = null;
        wc.Status__c = null;
        paramNotes = null;
    }
    // It cleans all the page parameters
    public void clearParameters() {
        paramDealerCode = '';
        paramWorkOrderNumber = '';
        paramCaseNumber = '';
        paramCallerName = '';
        paramVIN = '';
        paramVCAN = '';
        paramWOLine = '';        
        paramHOSTRefNum = '';
        
        showDealerSection = false;
        showDealerRelatedCases = false;
        showVehicleSection = false;
        showVehicleRelatedCases = false;
        showVehicleSuspendedClaims = false;
        showWorkOrderSection = false;
        showVCANSection = false;
        showCaseSection = false;
        showVCANResult = false;
        showRecall = false;
        showSummary = false;
        showSearch = true;
        
        VINErrorMessage = '';
        
        foundVehicle = new Vehicle__c();
        foundDealer = new Account();
        dealers = new List<Account>();
        vehicleRelatedCases = new List<Case>();
        dealerRelatedCases = new List<Warranty_Case__c>();
        foundRecall = new List<Vehicle_Recall__c>();
        if(vehicleSuspendedClaims!=null && vehicleSuspendedClaims.size()>0)
        {
          vehicleSuspendedClaims.clear();
        }
        lastOwner = null;
        selectedDealerId = '';
        
        errorMessage = '';
        showErrorMessage = false;
        
        redirectToPage = false;
        redirectURL = '';
    }
    
    //Edit Search after
    public void editSearch(){
        
        showSearch = true;
        showSummary = false;
        showDealerSection = false;
        showDealerRelatedCases = false;
        showVehicleSection = false;
        showVehicleRelatedCases = false;
        showWorkOrderSection = false;
        showVCANSection = false;
        showCaseSection = false;
        showVCANResult = false;
        showRecall = false;
        errorMessage = '';
        showErrorMessage = false;
        redirectToPage = false;
        DealerVINAlert = false;
        
    }
    
    // -------- Test --------
    static testMethod void ClassTest()
    {
        
        Warranty_CaseCreation cc = new Warranty_CaseCreation();
        
        //Insert test records
        Case c1 = new Case();
        c1.RecordTypeId = cc.warrantyId;
        c1.Type = 'FULL';
        insert c1;
        
        c1 = [SELECT CaseNumber
              FROM Case
              WHERE Id = :c1.Id];
        
        Account dealer = new Account();
        dealer.RecordTypeId = '012A0000000OfI0';
        dealer.Name = 'Sebastian';
        dealer.Dealer_Code__c = '1234';
        insert dealer;
        
        Vehicle__c veh = new Vehicle__c();
        veh.name = 'JN8AZ1FY5CW100145';
        veh.Model_Year__c = '2014';
        veh.Model_Line_Name__c = 'Altima';
        veh.Make_Name__c = 'Nissan';
        insert veh;
        
        // Search by an invalid caseNumber
        cc.paramCaseNumber = '1111';
        cc.initialSearch();
        System.assert(cc.showErrorMessage);
        
        // Search Dealer without the Code parameter
        cc.paramCaseNumber = null;
        cc.paramDealerCode = null;
        cc.initialSearch();
        System.assert(cc.showErrorMessage);
        
        // Search by Unknow Dealer
        cc.paramDealerCode = 'XXXXX';
        cc.initialSearch();
        System.assert(cc.showErrorMessage);
        
        // Search by a valid Dealer
        cc.paramDealerCode = '1234';
        cc.initialSearch();
        System.assert(!cc.showErrorMessage);
        
        // Search by a valid Dealer and an invalid VIN
        cc.paramDealerCode = '1234';
        cc.paramVIN = 'ZZZ';
        cc.initialSearch();
        System.assert(!cc.showErrorMessage);
        System.assert(!cc.showVehicleSection);
        
        // Search with a valid Dealer and Vehicle
        cc.paramDealerCode = '1234';
        cc.paramVIN = 'JN8AZ1FY5CW100145';
        cc.initialSearch();
        System.assert(!cc.showErrorMessage);
        System.assert(cc.showVehicleSection);
        
        // Select a Dealer and create a new Case
        cc.selectedDealerId = dealer.Id;
        cc.selectDealer();
        
        // General Tests
        cc.clearParameters();
        cc.clearCaseInformation();
        cc.editSearch();
        cc.searchVCAN();
        cc.paramWOLine = '1234';
        cc.paramWorkOrderNumber = '1234';
        cc.paramVIN = '123456789101213';
        cc.paramDealerCode = '1234';
        cc.searchVCAN();
        cc.searchVCANS('1234','1234','1234','1234');
        
        cc.searchRelatedWarrantyCasesToTheReferenceNumber('n123456');
        cc.newCase();
        cc.newVCANCase();
    }
    
    //AAB needed for VCAN search
    public class VCANJSONResponse {
        public string message {get;set;}
        public boolean success {get;set;}   
        public String VCANRefNumber {get;set;}
        public String AffiliateCode {get;set;}
        public String WONumber {get;set;}
        public String WOLine {get;set;}
        public String ServiceFacility {get;set;}
        public String VIN {get;set;}
        public String WOOpenDate {get;set;}
        public String Miles {get;set;}
        public String PFPPO {get;set;}
        public String CallerName {get;set;}
        public String CallerPhone {get;set;}
        public String CallerExt {get;set;}
        public String CustomerName {get;set;}
        public String PartsAtCost {get;set;}
        //Approval Amounts
        public String Parts {get;set;}
        public String LBR {get;set;}
        public String Expense {get;set;}
        public String Total {get;set;}
        public String ApprovalComments {get;set;}
        public String ForceGoodwill {get;set;}
        
        //Act Approval Condition
        public String NormalApproval {get;set;}
        public String RepairReview {get;set;}
        public String MileageProgressReview {get;set;}
        public String CampaignDiffDealer {get;set;}
        public String GoodwillApproval {get;set;}        
        
        public String ApprovalStatus {get;set;}
        public String ApprId {get;set;}
        public String ApprByName {get; set;}
        public String ApprDate {get;set;}
        public String EnteredByUserId {get;set;}
        public String EnteredDate {get;set;}
        public String ChangedByUserId {get;set;}
        public String ChangedByName {get; set;}
        public String ChangedDate {get;set;}
        public String LanId {get;set;}
    }
    
    public List<ServiceHistoryWrapper> buildSRHList (List<Service_Repair_History__c> lstSRH)
    {
        List<ServiceHistoryWrapper> lstSHW = new List<ServiceHistoryWrapper>();
        for(Service_Repair_History__c srh : lstSRH)
        {
            lstSHW.add(new ServiceHistoryWrapper(srh));
        }
        
        return lstSHW;
    }
    
    public class ServiceHistoryWrapper implements Comparable 
    {
        
        public Service_Repair_History__c srh {get; set;}
        
        // Constructor
        public ServiceHistoryWrapper(Service_Repair_History__c sh) {
            srh = sh;
        }
        
        // Compare Service History based on the work order number.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            ServiceHistoryWrapper compareToSrh = (ServiceHistoryWrapper)compareTo;
            
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            try
            {
                Integer originalWorkOrderNum = 0;
                Integer compareWorkOrderNum = 0;
                
                if(srh.Work_Order_Number__c!=null)
                {
                    originalWorkOrderNum = Integer.valueOf(srh.Work_Order_Number__c);
                }
                if(compareToSrh.srh.Work_Order_Number__c==null)
                {
                    compareWorkOrderNum= Integer.valueOf(compareToSrh.srh.Work_Order_Number__c);
                }                
                
                system.debug('Original' + originalWorkOrderNum + ' Compare' + compareWorkOrderNum);
                if (originalWorkOrderNum > compareWorkOrderNum) {
                    // Set return value to a positive value.
                    returnValue = -1;
                } else if (originalWorkOrderNum < compareWorkOrderNum) {
                    // Set return value to a negative value.
                    returnValue = 1;
                }
            }
            catch(Exception ex)
            {
                return 0;
            }
            
            return returnValue;       
        }
    }
    
    static testMethod void DateTests()
    {
        String sDate;
        Date myDate;
        myDate = convertMMDDYYToDate(sDate);
        
        sDate = '10/23/14';
        myDate = convertMMDDYYToDate(sDate);         
        sDate = '9-9-14';
        myDate = convertMMDDYYToDate(sDate);
        sDate = '10.23.14';
        myDate = convertMMDDYYToDate(sDate);
        sDate = '10-23';
        myDate = convertMMDDYYToDate(sDate);
        
        sDate = '10/23/9';
        myDate = convertMMDDYYToDate(sDate);     
        
        sDate = '10/23/97';
        myDate = convertMMDDYYToDate(sDate);    
        
        
        
    }
    
    public static Date convertMMDDYYToDate(String sDate)
    {
        if(sDate==null || sDate=='')
        {
            return null;
        }
        
        List<String> parts;
        if(sDate.contains('-'))
        {
            parts = sDate.split('-');
        }
        else if(sDate.contains('/'))
        {
            parts = sDate.split('/');
        }
        else
        {
            return null;
        }
        
        if(parts==null || parts.size()<3)
        {
            return null;
        }
        
        String SFDate = '';
        
        integer compareVal = Integer.valueOf(parts[2]);
        if(compareVal<30)
        {
            if(compareVal<10)
            {
                SFDate = '200' + compareVal;
            }
            else
            {
                SFDate = '20' + compareVal;
            }
        }
        else
        {
            SFDate = '19' + compareVal;
        }
        
        //Month
        compareVal = Integer.valueOf(parts[0]);
        if(compareVal<10)
        {
            SFDate += '-0' + compareVal;
        }
        else
        {
            SFDate += '-' + compareVal;
        }
        
        //Day
        compareVal = Integer.valueOf(parts[1]);
        if(compareVal<10)
        {
            SFDate += '-0' + compareVal;
        }
        else
        {
            SFDate += '-' + compareVal;
        }
        SFDate += ' 12:00:00';
        
        return Date.valueOf(SFDate);
    }
}