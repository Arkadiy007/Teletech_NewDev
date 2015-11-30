/**********************************************************************
  Name: Controller_PreCall_Forms_Finish
  Copyright ?? notice: Nissan Motor Company
  ======================================================
  Purpose:
  Controller of PreCall_Forms_Finish page

  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Arkadiy Sychev 04/23/2015 Created
  ***********************************************************************/
public with sharing class Controller_PreCall_Forms_Finish {
    private Id warrantyCaseId { get; set; }
	public String warCaseRecordName { get; set; }

    public List<Attachment> attachments { get; set; }
	private PageReference pagePDF;
	private List<Warranty_Case__c> warrantyCaseRecord;
	public Attachment pdf { get; set; }
	private String currentRecordTypeName;

	//CONSTANTS
	private static String RECORDTYPE_ENGINE = 'Engine VCAN';
	private static String RECORDTYPE_CVT = 'Trans VCAN';
	private static String RECORDTYPE_LEAF = 'Leaf Precall';

    public Controller_PreCall_Forms_Finish() {
        warrantyCaseId = apexpages.currentpage().getparameters().get('id');
        if (warrantyCaseId != null && !String.isEmpty(String.valueOf(warrantyCaseId))) {
			warrantyCaseRecord = Database.query('SELECT Id, Name, Dealer_Code__c, RecordTypeId FROM Warranty_Case__c WHERE Id =: warrantyCaseId');
			warCaseRecordName = warrantyCaseRecord[0].Name;
            attachments = Database.query('SELECT Id, BodyLength, ContentType, Description, Name, IsPrivate FROM Attachment WHERE ParentId =: warrantyCaseId');
			String recTypeId = warrantyCaseRecord[0].RecordTypeId;

			Map<Id,Schema.RecordTypeInfo> recordTypeInfo = Warranty_Case__c.SObjectType.getDescribe().getRecordTypeInfosById();
			currentRecordTypeName = recordTypeInfo.get(recTypeId).getName();
        }
    }

    public PageReference finish() {
		createPDF();
        return new PageReference('javascript: self.close();');
    }

	public PageReference new_PreCall_Form() {
		createPDF();
		PageReference p = new PageReference('/apex/PreCall_Forms');
		p.setRedirect(true);
		return p;
	}

	public PageReference redirectToPDF() {
		createPDF();
		return pagePDF;
    }

	@testVisible
	public void createPDF() {
		if(pagePDF == null) {
			//determination of what VF page template should be used
			if (currentRecordTypeName == RECORDTYPE_ENGINE) {
				pagePDF = Page.PreCall_Forms_PDF_Engine;
			} else if (currentRecordTypeName == RECORDTYPE_CVT) {
				 pagePDF = Page.PreCall_Forms_PDF_CVT;
			} else {
				 pagePDF = Page.PreCall_Forms_PDF_LEAF;
			}

			//generation and attaching PDF
			//pagePDF = Page.PreCall_Forms_PDF_Engine;
			pagePDF.getParameters().put('id', warrantyCaseId);
			Blob pdfBlob;

			// trick for unit tests 
			if (Test.IsRunningTest()) {
				pdfBlob = Blob.valueOf('UNIT.TEST');
			} else {
	 			pdfBlob = pagePDF.getContent();
			}

			String pdfName = 'Pre-call_Type_' + warrantyCaseRecord[0].Name+ '_' + warrantyCaseRecord[0].Dealer_Code__c + '_' + getDate() + '.pdf';
			pdf = new Attachment(parentId = warrantyCaseId, name = pdfName, body = pdfBlob); 
			insert pdf;
		}
    }

	//HELP METHODS--------------------------
	private String getDate() {
		DateTime now = DateTime.NOW();
		String month = checkLength(String.valueOf(now.month()));
		String day = checkLength(String.valueOf(now.day()));
		String year = checkLength(String.valueOf(now.year()));

		return month + day + year.substring(2);
	}

	private String checkLength(String val) {
		if (String.isNotBlank(val) && val.length()==1) {
			val = '0' + val;
		}
		return val;
	}
}