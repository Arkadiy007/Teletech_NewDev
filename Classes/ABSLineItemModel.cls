/**********************************************************************
Name: ABSLineItemModel
Copyright � notice: NMAC.
======================================================
Purpose:
This is an apex representation of Ws_Tab_Abs_Line_Item sObject
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/21/2015 Created 
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev
***********************************************************************/
public class ABSLineItemModel {
public final Ws_Tab_Abs_Line_Item__c Implementation { get; private set; }

	public String Subheading { get; set; }
	public Decimal OrderNumber { get; set; }
	public Boolean IsDeleted {get; set;}
	public Id Document {get; set;}
	public Id AbsLineId {get; set;}
	public String Name {get; set;}
	public String link {get; set;}
	public Boolean isDocument {get; set;}
	public Boolean isPdf {get; set;}
	public Boolean isExcel {get; set;}

	public ABSLineItemModel(Ws_Tab_Abs_Line_Item__c obj) {
		isDocument = true;
		isPdf = false;
		isExcel = false;
		Implementation = obj;
		parseFromObject();
	}

	public ABSLineItemModel() {
		Implementation = new Ws_Tab_Abs_Line_Item__c();
		parseFromObject();
	}

	private void parseFromObject() {
		Subheading=Implementation.Subheading__c;
		OrderNumber=Implementation.Order_Number__c;
		Document=Implementation.Document__c;
		AbsLineId=Implementation.Ws_Tab_Abs_Line__c;
		link = LinksManager.GetUrlForDocument(Implementation.Document__r.Link__c);
		IsDeleted = false;

		if(Document != null){
			if(Implementation.Document__r.Document_Extension__c.contains('pdf')){
					isPdf = true;
					isDocument = false;
			}
			if(Implementation.Document__r.Document_Extension__c.contains('xls')){
					isExcel = true;
					isDocument = false;
			}
			if(Implementation.Document__r.Document_Extension__c.contains('lsx')){
					isExcel = true;
					isDocument = false;
			}
		}
	}

	public Ws_Tab_Abs_Line_Item__c toObject() {
		Implementation.Subheading__c=Subheading;
		Implementation.Order_Number__c=OrderNumber;
		Implementation.Document__c=Document;
		Implementation.Ws_Tab_Abs_Line__c=AbsLineId;

		return Implementation;
	}

	public static ABSLineItemModel fromObject(Ws_Tab_Abs_Line_Item__c obj) {
		return new ABSLineItemModel(obj);
	}

}