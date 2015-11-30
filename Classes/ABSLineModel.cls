/**********************************************************************
Name: ABSLineModel
Copyright � notice: NMAC.
======================================================
Purpose:
This is an apex representation of Ws_Tab_Abs_Line sObject
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/21/2015 Created 
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev
***********************************************************************/
public class ABSLineModel implements Comparable{
public final Ws_Tab_Abs_Line__c Implementation { get; private set; }

	public String MHeading { get; set; }
	public Decimal OrderNumber { get; set; }
	public Boolean IsDeleted {get; set;}
	public Id AbsId {get; set;}
	public String Name {get; set;}
	public Id ObjectId {get; set;}

	public ABSLineModel(Ws_Tab_Abs_Line__c obj) {
		Implementation = obj;
		parseFromObject();
	}

	public ABSLineModel() {
		Implementation = new Ws_Tab_Abs_Line__c();
		parseFromObject();
	}

	private void parseFromObject() {
		MHeading=Implementation.Major_Heading__c;
		OrderNumber=Implementation.Order_Number__c;
		AbsId=Implementation.Ws_Tab_Abs__c;
		Name = Implementation.Name;
		IsDeleted = false;
		ObjectId = Implementation.Id;
	}

	public Ws_Tab_Abs_Line__c toObject() {
		Implementation.Major_Heading__c=MHeading;
		Implementation.Order_Number__c=OrderNumber;
		Implementation.Ws_Tab_Abs__c=AbsId;
		Implementation.Name = Name;
		

		return Implementation;
	}

	public static ABSLineModel fromObject(Ws_Tab_Abs_Line__c obj) {
		return new ABSLineModel(obj);
	}

	public Integer compareTo(Object compareTo) {
			ABSLineModel cmpTo = (ABSLineModel) compareTo;

			if(cmpTo.OrderNumber > this.OrderNumber){
				return -1;
			}
			else{
				return 1;
			}
		}

}