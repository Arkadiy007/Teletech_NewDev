/**********************************************************************
Name: Controller_PreCall_Forms
Copyright �� notice: Nissan Motor Company
======================================================
Purpose:
Controller of PreCall_Forms page which lanches the PreCall Fom flow

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Arkadiy Sychev 12/30/2014 Created
***********************************************************************/
public with sharing class Controller_PreCall_Forms {
    public Flow.Interview.PreCall_Forms myflow { get; set; }
    public String getVarValue() {
		
        if (myflow == null) { 
            return null; 
        }
        else {
			return string.valueOf(myflow.getVariableValue('varWarrantyCaseNumber'));
        }
    }
    
    public PageReference getOID(){
    PageReference p = new PageReference('/apex/PreCall_Forms_For_Attachment?id=' + getVarValue());
    p.setRedirect(true);
    return p;
    }
}