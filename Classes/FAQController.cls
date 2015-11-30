/**********************************************************************
  Name: FAQController
  Copyright � notice: NMAC.
  ======================================================
  Purpose:
  This is a controller for "FAQ" page
 
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL
  1.0 - Arshakyan Georgiy 5/12/2015 Created 
  1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev 
  ***********************************************************************/
public class FAQController {
	public FAQModel faq { get; set; }
	public Ws_Tab_Faq_Line__c faqLine { get; set; }
	public List <FAQLineItemModel > items { get; set; }

	public Boolean isProd { get; set; }

	public QD_Components_Available__c qd { get; set; }


	public String AbsLink {
		get {
			if (isProd) {
				return LinksManager.GetUrlForPage('ABS');
			}
			else {
				return LinksManager.GetUrlForPage('ABS?version=test');
			}
		}
	}

	public String HomeLink {
		get {
			if (isProd) {
				return LinksManager.GetUrlForPage('Home');
			}
			else {
				return LinksManager.GetUrlForPage('Home?version=test');
			}
		}
	}

	public String QuarterlyDataLink {
		get {
			if (isProd) {
				return LinksManager.GetUrlForPage('Quarterly_Data');
			}
			else {
				return LinksManager.GetUrlForPage('Quarterly_Data?version=test');
			}
		}
	}
	public String PresentationsLink {
		get {
			if (isProd) {
				return LinksManager.GetUrlForPage('Presentations');
			}
			else {
				return LinksManager.GetUrlForPage('Presentations?version=test');
			}
		}
	}

	public String FAQLink {
		get {
			if (isProd) {
				return LinksManager.GetUrlForPage('FAQ');
			}
			else {
				return LinksManager.GetUrlForPage('FAQ?version=test');
			}
		}
	}


	public FAQController() {
		Ws_Tab_Faq__c faqObject;
		if (LinksManager.IsPublicSite()) {
			String absRecordTypeId = Schema.SObjectType.Ws_Tab_Faq__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
			faqObject = [SELECT Id, Comments__c, State__c FROM Ws_Tab_Faq__c WHERE RecordtypeId = :absRecordTypeId AND State__c = 'Approved'] [0];
			isProd = true;
		} else if (ApexPages.currentPage().getParameters().get('id') != null) {
			faqObject = [SELECT Id, Comments__c, State__c FROM Ws_Tab_Faq__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')] [0];
			isProd = false;
		}
		else {
			if (ApexPages.currentPage().getParameters().get('version') == 'test') {
				String absRecordTypeId = Schema.SObjectType.Ws_Tab_Faq__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
				faqObject = [SELECT Id, Comments__c, State__c FROM Ws_Tab_Faq__c WHERE RecordtypeId = :absRecordTypeId AND State__c = 'Sent For Review'] [0];
				isProd = false;
			}
			else {
				String absRecordTypeId = Schema.SObjectType.Ws_Tab_Faq__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
				faqObject = [SELECT Id, Comments__c, State__c FROM Ws_Tab_Faq__c WHERE RecordtypeId = :absRecordTypeId AND State__c = 'Approved'] [0];
				isProd = true;
			}
		}

		faq = FAQModel.fromObject(faqObject);
		getFaqLine();
		getItems();

		qd = QD_Components_Available__c.getOrgDefaults();

	}

	private void getFaqLine() {
		List <Ws_Tab_Faq_Line__c > faqLines = [SELECT Id, Ws_Tab_Faq__c FROM Ws_Tab_Faq_Line__c WHERE Ws_Tab_Faq__c = :faq.Implementation.id];
		if (!faqLines.isEmpty()) {
			faqLine = faqLines[0];
		}
	}

	private void getItems() {
		items = new List <FAQLineItemModel > ();

		for (Ws_Tab_Faq_Line_Item__c item :[SELECT Id, Answer__c, Order_Number__c, Question__c, Ws_Tab_Faq_Line__c FROM Ws_Tab_Faq_Line_Item__c WHERE Ws_Tab_Faq_Line__c = :faqLine.id ORDER BY Order_Number__c]) {
			items.add(FAQLineItemModel.fromObject(item));
		}
	}

}