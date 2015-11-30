/**********************************************************************
  Name: FooterEditController
  Copyright � notice: NMAC.
  ======================================================
  Purpose:
  This is a controller for FooterEdit page
 
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL
  1.0 - Arshakyan Georgiy 6/11/2015 Created 
  ***********************************************************************/
public class FooterEditController {
    public Document d { get; set; }
    public String errorMsg { get; set; }
    public String commentsMsg { get; set; }
    public String currentDocumentLink {get; set;}
    private Footer__c footerTest {get; set;}
    private Reviewer_Email__c reviewerEmail { get; set; }
    private Set<String> validTypes {get; set;}

    public FooterEditController() {
        d = new Document();
        errorMsg = '';

        footerTest = [SELECT Id, Document__c, Document__r.Link__c, Comments__c FROM Footer__c WHERE State__c = 'Sent For Review'][0];

        initializeComments();
        initializeDocumentLink();
        initializeValidTypes();
        

        
        reviewerEmail = Reviewer_Email__c.getOrgDefaults();
        
    }

    
    public Pagereference save() {
        errorMsg = '';
        Document_Proxy__c proxy;
        Folder companyPageFilesFolder = [select id from Folder where name = 'Company Page Files'] [0];
        if (d != null) {
            if (d.name != null) {
                if (!validTypes.contains(d.Name.right(3))) {
                    addErrorMsg(d.Name);
                    return null;
                }
                d.folderid = companyPageFilesFolder.id;
                d.IsPublic = true;
                insert d;

                proxy = new Document_Proxy__c(Name = d.Name, Link__c = '/servlet/servlet.FileDownload?file=' + d.Id, Document_Extension__c = d.Name.right(3));

                d.Body = null;
                d = new Document();

                insert proxy;
                footerTest.Document__c = proxy.id;
                update footerTest;
            }
        }

        return pageRefBuilder('/apex/PagesEditSelector?sfdc.tabName=01rM00000009E97');
    }

    public Pagereference saveAndSubmit() {
        this.save(); 
        sendEmail();
        return pageRefBuilder('/apex/PagesEditSelector?sfdc.tabName=01rM00000009E97');
    }

    public Pagereference saveAndPreview(){
        this.save();
        return pageRefBuilder('javascript: var params = [\'height=\'+screen.height,\'width=\'+screen.width, \'fullscreen=yes\'].join(\',\'); var popup = window.open(\'/apex/Terms_And_Conditions?version=test\', \'\', params); popup.moveTo(0,0); popup.resizeTo(screen.availWidth,screen.availHeight); window.open(\'/apex/FooterEdit?sfdc.tabName=01rM00000009E97\',\'_self\',false);');
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
        mail.setSubject('Investor Relations Footer Requires Approval');
        mail.setPlainTextBody('Please use the link below to view and Approve/Reject Footer ' + baseUrl + '/apex/FooterApproval');
        mail.setHtmlBody('Please use the link below to view and Approve/Reject Footer ' + '<a href="' + baseUrl + '/apex/FooterApproval' + '"> LINK </a>');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    private void initializeComments(){
        if (footerTest.Comments__c != null) {
            commentsMsg = 'Reviewer comments: ' + footerTest.Comments__c;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, commentsMsg));
        }
        else {
            commentsMsg = '';
        }
    }
    private void initializeDocumentLink(){
        if(footerTest.Document__c != null && footerTest.Document__r.Link__c != null){
            currentDocumentLink = footerTest.Document__r.Link__c;
        }
        else{
            currentDocumentLink = '';
        }

    }
    private void initializeValidTypes(){
        validTypes = new Set<String>();
        validTypes.add('pdf');
    }

}