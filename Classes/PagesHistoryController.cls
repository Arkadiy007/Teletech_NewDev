/**********************************************************************
Name: PagesHistoryController
Copyright � notice: NMAC.
======================================================
Purpose:
This is a controller for "PagesHistory" page
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/13/2015 Created 
***********************************************************************/
public class PagesHistoryController {
    public static String restoreLinkFormat = '/apex/{0}?id={1}&restore=true';
    public static String previewLinkFormat = '/apex/{0}?id={1}';
    public String soqlFormat = 'SELECT Id, LastModifiedDate, Comments__c, Name, State__c, RecordtypeId FROM {0} WHERE (RecordtypeId = :testRecordTypeId OR RecordtypeId = :prodRecordTypeId) AND State__c = :state ORDER BY LastModifiedDate DESC';
    public static Map <String, String > pageRestoreLinks = new Map <String, String > { 'ABS' => 'ABSpageEdit', 'Home' => 'HomepageEdit',  'Presentation' => 'PresentationsEdit', 'QuarterlyData' => 'QuarterlyDataEdit',  'FAQ' => 'FAQEdit'  };
    public static Map <String, String > pagePreviewLinks = new Map <String, String > { 'ABS' => 'ABS', 'Home' => 'Home',  'Presentation' => 'Presentations', 'QuarterlyData' => 'Quarterly_Data', 'FAQ' => 'FAQ'  };
    public static Map <String, String > pageObjects = new Map <String, String > { 'ABS' => 'Ws_Tab_abs__c', 'Home' => 'Ws_Tab_Home__c',  'Presentation' => 'Ws_Tab_Presentations__c', 'QuarterlyData' => 'Ws_Tab_Quarterly_Data__c', 'FAQ' => 'Ws_Tab_Faq__c'};
    public static Map <String, String > pageNames = new Map <String, String > { 'ABS' => 'ABS', 'Home' => 'Home',  'Presentation' => 'Presentations', 'QuarterlyData' => 'Quarterly Data', 'FAQ' => 'FAQ' };

    public Boolean IsPageDefined {
        get {
            return(SelectedPage != null) && (SelectedPage != '');
        }
    }

    public String SelectedPage { get; set; }

    public String PageName { 
        get {
            return pageNames.get(SelectedPage);
        }
    }

    public String linkToEditPage { get; set; }

    public List <SelectOption > pages { get; set; }

    public List <HistoryEntry > records { get; set; }

    public PagesHistoryController() {
        SelectedPage = ApexPages.currentPage().getParameters().get('page');

        if (IsPageDefined) {
            FillHistory();
        } else {
            pages = new List <SelectOption > ();
        

            Pages_Available__c settings = Pages_Available__c.getOrgDefaults();

            if(settings.Is_Home_Available__c){
                pages.add(new SelectOption('Home' , 'Home'));
            }
            if(settings.Is_ABS_Available__c){
                pages.add(new SelectOption('ABS', 'ABS'));
            }
            if(settings.Is_FAQ_Available__c){
                pages.add(new SelectOption('FAQ', 'FAQ'));
            }
            if(settings.Is_Presentations_Available__c){
                pages.add(new SelectOption('Presentation', 'Presentation'));
            }
            if(settings.Is_QD_Available__c){
                pages.add(new SelectOption('QuarterlyData', 'Quarterly Data'));
            }   

        }
    }

    public Pagereference redirectToEditPage() {
        if (linkToEditPage == null) {
            return null;
        }
        else {
            string url = '/apex/PagesHistory?page='+linkToEditPage+'&sfdc.tabName=01rM00000009E9C';
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);

            return pageRef;
        }

    }

    private void FillHistory() {
        String objectName=pageObjects.get(SelectedPage);
        records = new List <HistoryEntry > ();
        Populate(objectName);
    }

    private void Populate(String objectName)
    {
        String testRecordTypeId = Schema.describeSObjects(new String[] {objectName})[0].getRecordTypeInfosByName().get('Test').getRecordTypeId();
        String prodRecordTypeId = Schema.describeSObjects(new String[] {objectName})[0].getRecordTypeInfosByName().get('Production').getRecordTypeId();
        String soql = String.format(soqlFormat, new String[] { objectName});
        String state='Rejected';

        for (sObject obj : Database.query(soql)) {
            String recordTypeName = 'Test';
            if (((String)obj.get('RecordTypeId'))==prodRecordTypeId)
            {
                recordTypeName='Production';
            }

            records.add((new HistoryEntry()).Fill(obj, SelectedPage, recordTypeName));
        }
    }

    public class HistoryEntry {
        public String Link { get; set; }
        public String RestorationLink { get; set; }
        public String RecordTypeName { get; set; }
        public String LastModified { get; set; }
        public String Comments { get; set; }

        public HistoryEntry Fill(sObject obj, String SelectedPage, String recordType) {
            RestorationLink = String.Format(PagesHistoryController.restoreLinkFormat, new List <String > { PagesHistoryController.pageRestoreLinks.get(SelectedPage), String.valueOf(obj.Id) });
            Link = String.Format(PagesHistoryController.previewLinkFormat, new List <String > { PagesHistoryController.pagePreviewLinks.get(SelectedPage), String.valueOf(obj.Id) });
            LastModified = ((DateTime) obj.get('LastModifiedDate')).format();
            Comments = obj.get('Comments__c') == null ? '' : (String) obj.get('Comments__c');
            RecordTypeName = recordType;
            RestorationLink += '&sfdc.tabName=01rM00000009E97';
            return this;
        }

    }


}