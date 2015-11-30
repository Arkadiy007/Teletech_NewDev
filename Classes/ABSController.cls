/**********************************************************************
  Name: ABSController
  Copyright � notice: NMAC.
  ======================================================
  Purpose:
  This is a controller for "ABS" page
 
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL
  1.0 - Arshakyan Georgiy 5/12/2015 Created 
  1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev
  ***********************************************************************/
public class ABSController {
	public ABSModel abs { get; set; }
	public Map <HeadingWrapper, Map <ABSLineModel, List <ABSLineItemModel > > > absLines { get; set; }
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

	public ABSController() {
		if (LinksManager.IsPublicSite()) {
			String absRecordTypeId = Schema.SObjectType.Ws_Tab_abs__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
			Ws_Tab_abs__c absPage = [SELECT Id, Comments__c, Name, Overview__c, RecordTypeId, State__c FROM Ws_Tab_abs__c WHERE RecordtypeId = :absRecordTypeId AND State__c = 'Approved'] [0];
			abs = ABSModel.fromObject(absPage);
			isProd = true;
		} else if (ApexPages.currentPage().getParameters().get('id') != null) {
			Ws_Tab_abs__c absPage = [SELECT Id, Comments__c, Name, Overview__c, RecordTypeId, State__c FROM Ws_Tab_abs__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')] [0];
			abs = ABSModel.fromObject(absPage);
			isProd = false;
		}
		else {
			if (ApexPages.currentPage().getParameters().get('version') == 'test') {
				String absRecordTypeId = Schema.SObjectType.Ws_Tab_abs__c.getRecordTypeInfosByName().get('Test').getRecordTypeId();
				Ws_Tab_abs__c absPage = [SELECT Id, Comments__c, Name, Overview__c, RecordTypeId, State__c FROM Ws_Tab_abs__c WHERE RecordtypeId = :absRecordTypeId AND State__c = 'Sent For Review'] [0];
				abs = ABSModel.fromObject(absPage);
				isProd = false;
			}
			else {
				String absRecordTypeId = Schema.SObjectType.Ws_Tab_abs__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
				Ws_Tab_abs__c absPage = [SELECT Id, Comments__c, Name, Overview__c, RecordTypeId, State__c FROM Ws_Tab_abs__c WHERE RecordtypeId = :absRecordTypeId AND State__c = 'Approved'] [0];
				abs = ABSModel.fromObject(absPage);
				isProd = true;
			}
		}

		absLines = new Map<HeadingWrapper, Map<ABSLineModel, List<ABSLineItemModel>>> ();
		Map <Id, List <ABSLineItemModel > > lineItemsByLines = fillLineItemsByLines();
		Map <String, Map <ABSLineModel, List <ABSLineItemModel > > > tmpAbsLines = fillABSLinesByHeading(lineItemsByLines);
		fillABSLines(tmpAbsLines);
		tmpAbsLines.clear();

		qd = QD_Components_Available__c.getOrgDefaults();

	}
	private Map<Id, List <ABSLineItemModel>> fillLineItemsByLines() {
		Map<Id, List<ABSLineItemModel>> lineItemsByLines = new Map<Id, List<ABSLineItemModel>> ();

		for (Ws_Tab_Abs_Line_Item__c lineItem :[SELECT Id, Ws_Tab_Abs_Line__c, Order_Number__c, Name, Document__c, Document__r.Link__c, Document__r.Document_Extension__c, Subheading__c FROM Ws_Tab_Abs_Line_Item__c WHERE Ws_Tab_Abs_Line__c IN(SELECT Id FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_abs__c = :abs.Implementation.id) ORDER BY Order_Number__c ASC]) {
			if (lineItemsByLines.get(lineItem.Ws_Tab_Abs_Line__c) == null) {
				List<ABSLineItemModel> temp = new List<ABSLineItemModel> ();
				temp.add(ABSLineItemModel.fromObject(lineItem));
				lineItemsByLines.put(lineItem.Ws_Tab_Abs_Line__c, temp);
			}
			else {
				lineItemsByLines.get(lineItem.Ws_Tab_Abs_Line__c).add(ABSLineItemModel.fromObject(lineItem));
			}
		}

		return lineItemsByLines;
	}

	private Map <String, Map <ABSLineModel, List <ABSLineItemModel > > > fillABSLinesByHeading(Map<Id, List<ABSLineItemModel>> lineItemsByLines) {
		Map <String, Map <ABSLineModel, List <ABSLineItemModel > > > tmpAbsLines = new Map <String, Map <ABSLineModel, List <ABSLineItemModel > > > ();

		for (Ws_Tab_Abs_Line__c al :[SELECT Id, Major_Heading__c, Ws_Tab_Abs__c, Order_Number__c, Name FROM Ws_Tab_Abs_Line__c WHERE Ws_Tab_Abs__c = :abs.Implementation.id ORDER BY Order_Number__c]) {
			if (tmpAbsLines.get(al.Major_Heading__c) == null) {
				Map <ABSLineModel, List <ABSLineItemModel > > temp = new Map <ABSLineModel, List <ABSLineItemModel > > ();
				if (lineItemsByLines.get(al.id) != null) {
					temp.put(ABSLineModel.fromObject(al), lineItemsByLines.get(al.id));
				}
				else {
					temp.put(ABSLineModel.fromObject(al), new List <ABSLineItemModel > ());
				}
				tmpAbsLines.put(al.Major_Heading__c, temp);
			}
			else {
				if (lineItemsByLines.get(al.id) != null) {
					tmpAbsLines.get(al.Major_Heading__c).put(ABSLineModel.fromObject(al), lineItemsByLines.get(al.id));
				}
				else {
					tmpAbsLines.get(al.Major_Heading__c).put(ABSLineModel.fromObject(al), new List <ABSLineItemModel > ());
				}
			}
		}

		return tmpAbsLines;
	}

	private void fillABSLines(Map<String, Map<ABSLineModel, List<ABSLineItemModel>>> tmpAbsLines) {
		for (String mHeading : tmpAbsLines.keySet()) {
			absLines.put(new HeadingWrapper(mHeading), tmpAbsLines.get(mHeading));
		}
	}

	public class HeadingWrapper implements Comparable {
		public String heading { get; set; }

		public HeadingWrapper(String i) {
			heading = i;
		}

		public Integer compareTo(Object compareTo) {
			HeadingWrapper cmpTo = (HeadingWrapper) compareTo;

			if (cmpTo.heading > this.heading) {
				return 1;
			}
			else {
				return - 1;
			}
		}
	}

}