/**********************************************************************
  Name: HomepageEditController
  Copyright � notice: NMAC.
  ======================================================
  Purpose:
  This is a controller for "HomepageEdit" page
 
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL
  1.0 - Arshakyan Georgiy 5/6/2015 Created 
  ***********************************************************************/
public class HomepageEditController {

    public HomeModel home { get; set; }
    public String homeTestRecordTypeId { get; set; }
    public Boolean isRestored { get; set; }

    public Document businessActivitiesImg { get; set; }
    public Document spreadsheetImg { get; set; }

    public Boolean showBAImgLoaderBlock { get; set; }
    public Boolean isBAImageAvailable { get; set; }
    public Boolean isSpreadsheetImageAvailable { get; set; }

    public String errorMsg { get; set; }
    public String commentsMsg { get; set; }

    public Set<String> validTypes { get; set; }

    private Reviewer_Email__c reviewerEmail { get; set; }

    public HomepageEditController() {
        homeTestRecordTypeId = Schema.SObjectType.Ws_Tab_Home__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
        isRestored = false;

        if (ApexPages.currentPage().getParameters().get('restore') == 'true') {
            if (ApexPages.currentPage().getParameters().get('id') != null) {
                Ws_Tab_Home__c homePage = [SELECT Id, Comments__c, Investor_Relations_Website__c, Business_Activities_Image__c, Business_Activities_Image__r.Link__c, Information_Text__c, Spreadsheat_Image__r.Link__c, Ratings_Text__c, Spreadsheat_Image__c FROM Ws_Tab_Home__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')] [0];
                home = HomeModel.fromObject(homePage);
                isRestored = true;
            }
        }

        if (!isRestored) {
            Ws_Tab_Home__c homePage = [SELECT Id, Comments__c, Business_Activities_Image__c, Business_Activities_Image__r.Link__c, Information_Text__c, Spreadsheat_Image__r.Link__c, Ratings_Text__c, Spreadsheat_Image__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review' AND RecordtypeId = :homeTestRecordTypeId] [0];
            home = HomeModel.fromObject(homePage);
        }

        initializeState();
        getValidTypes();
        checkForComments();

        reviewerEmail = Reviewer_Email__c.getOrgDefaults();

    }

    public Pagereference save() {
        Image_Proxy__c proxy;
        Folder companyPageFilesFolder = [select id from Folder where name = 'Company Page Files'] [0];
        if (businessActivitiesImg != null) {
            if (businessActivitiesImg.name != null) {
                if (!validTypes.contains(businessActivitiesImg.Name.right(3))) {
                    addErrorMsg(businessActivitiesImg.Name);
                    return null;
                }

                businessActivitiesImg.folderid = companyPageFilesFolder.id;
                businessActivitiesImg.IsPublic = true;
                insert businessActivitiesImg;


                string strOrgId = UserInfo.getOrganizationId();
                string strDocUrl = '/servlet/servlet.ImageServer?id=' + businessActivitiesImg.Id + '&oid=' + strOrgId;

                proxy = new Image_Proxy__c(
                                           Name = businessActivitiesImg.name,
                                           Link__c = strDocUrl
                );


                insert proxy;

                home.BusinessActivitiesImageId = proxy.id;

                businessActivitiesImg.Body = null;
                businessActivitiesImg = null;
            }
        }

        if (spreadsheetImg != null) {
            if (spreadsheetImg.Name != null) {
                if (!validTypes.contains(spreadsheetImg.Name.right(3))) {
                    addErrorMsg(spreadsheetImg.Name);
                    return null;
                }

                spreadsheetImg.folderid = companyPageFilesFolder.id;
                spreadsheetImg.IsPublic = true;
                insert spreadsheetImg;

                string strOrgId = UserInfo.getOrganizationId();
                string strDocUrl = '/servlet/servlet.ImageServer?id=' + spreadsheetImg.Id + '&oid=' + strOrgId;

                proxy = new Image_Proxy__c(
                                           Name = spreadsheetImg.name,
                                           Link__c = strDocUrl
                );

                insert proxy;

                spreadsheetImg.Body = null;
                spreadsheetImg = null;

                home.SpreadsheetImageId = proxy.id;
            }

        }

        if (isRestored) {
            setCurrentTestPageToRejected();
            restoreTestHomePage(ApexPages.currentPage().getParameters().get('id'));
        }
        else {
            update home.toObject();
        }
        return pageRefBuilder('/apex/PagesEditSelector?sfdc.tabName=01rM00000009E97');
    }

    public Pagereference saveAndSubmit() {
        this.save();

        sendEmail();

        return pageRefBuilder('/apex/PagesEditSelector?sfdc.tabName=01rM00000009E97');
    }

    public Pagereference saveAndPreview() {
        this.save();
        return pageRefBuilder('javascript: var params = [\'height=\'+screen.height,\'width=\'+screen.width, \'fullscreen=yes\'].join(\',\'); var popup = window.open(\'/apex/Home?version=test\', \'\', params); popup.moveTo(0,0); popup.resizeTo(screen.availWidth,screen.availHeight); window.open(\'/apex/HomepageEdit?sfdc.tabName=01rM00000009E97\',\'_self\',false);');
    }

    private PageReference pageRefBuilder(String redirectTo){
        if(errorMsg != ''){         
            return null;
        }

        PageReference pageRef = new PageReference(redirectTo);
        pageRef.setRedirect(true);

        return pageRef;
    }

    private void addErrorMsg(String filename) {
        errorMsg = 'File ' + filename + ' has incorrect extension.';
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
    }

    private void sendEmail() {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String[] toAddresses = new String[] { reviewerEmail.Email__c };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Investor Relations Page Requires Approval:' + 'Home');
        mail.setPlainTextBody('Please use the link below to view and Approve/Reject "Home" ' + baseUrl + '/apex/HomepageApproval');
        mail.setHtmlBody('Please use the link below to view and Approve/Reject "Home" ' + '<a href="' + baseUrl + '/apex/HomepageApproval' + '"> LINK </a>');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    private void initializeState() {
        businessActivitiesImg = new Document();
        spreadsheetImg = new Document();

        showBAImgLoaderBlock = false;
        isBAImageAvailable = home.Implementation.Business_Activities_Image__c != null;
        isSpreadsheetImageAvailable = home.Implementation.Spreadsheat_Image__c != null;

        errorMsg = '';
    }
        private void getValidTypes(){
            validTypes = new Set<String> ();
        validTypes.add('png');
        validTypes.add('jpg');

        }
        
        private void checkForComments(){
        if (home.Implementation.Comments__c != null) {
            commentsMsg = 'Reviewer comments: ' + home.Implementation.Comments__c;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, commentsMsg));
        }
        else {
            commentsMsg = '';
        }
        }
    

    private void setCurrentTestPageToRejected() {
        Ws_Tab_Home__c testHome = [SELECT Id, Comments__c, State__c, Business_Activities_Image__c, Business_Activities_Image__r.Link__c, Information_Text__c, Spreadsheat_Image__r.Link__c, Ratings_Text__c, Spreadsheat_Image__c FROM Ws_Tab_Home__c WHERE State__c = 'Sent For Review' AND RecordtypeId = :homeTestRecordTypeId] [0];
        delete testHome;
    }

    private void restoreTestHomePage(String recordId) {

        Ws_Tab_Home__c updatedTestHome = new Ws_Tab_Home__c();

        updatedTestHome.RecordtypeId = homeTestRecordTypeId;
        updatedTestHome.State__c = 'Sent For Review';
        updatedTestHome.Business_Activities_Image__c = home.BusinessActivitiesImageId;
        updatedTestHome.Information_Text__c = home.InformationText;
        updatedTestHome.Ratings_Text__c = home.RatingsText;
        updatedTestHome.Spreadsheat_Image__c = home.SpreadsheetImageId;
        updatedTestHome.Name = 'Home';
        updatedTestHome.Investor_Relations_Website__c = home.Implementation.Investor_Relations_Website__c;

        insert updatedTestHome;

    }
}