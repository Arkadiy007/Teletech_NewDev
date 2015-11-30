/**********************************************************************
Name: ABSModel
Copyright � notice: NMAC.
======================================================
Purpose:
This is an apex representation of Ws_Tab_Abs sObject
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/21/2015 Created 
1.1 - Arshakyan Georgiy 8/18/2015 Moved from NMAC sandbox to Newdev
***********************************************************************/
public class ABSModel {
public final Ws_Tab_abs__c Implementation { get; private set; }

  public String Comments { get; set; }
  public String Overview {get; set;}
  public String State {get; set;}
  public String Name {get; set;}
  public Id RecordTypeId {get; set;}



  public ABSModel(Ws_Tab_abs__c obj) {
    Implementation = obj;
    parseFromObject();
  }

  private void parseFromObject() {
    Comments = Implementation.Comments__c;
    Overview = Implementation.Overview__c;
  	State = Implementation.State__c;
  	Name = Implementation.Name;
  	RecordTypeId = Implementation.RecordTypeId;

  }

  public Ws_Tab_abs__c toObject() {
    Implementation.Comments__c=Comments;
    Implementation.Overview__c = Overview;
    Implementation.State__c = State;
    Implementation.Name = Name;
  	Implementation.RecordTypeId = RecordTypeId;
  	
    return Implementation;
  }

  public static ABSModel fromObject(Ws_Tab_abs__c obj) {
    return new ABSModel(obj);
  }

}