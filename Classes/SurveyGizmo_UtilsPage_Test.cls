/**********************************************************************
Name: SurveyGizmo_UtilsPage_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for SG Utils Page
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - William Taylor 10/14/14 created

***********************************************************************/
@isTest
private class SurveyGizmo_UtilsPage_Test  {

    static testmethod void testPage() {
            RecordType rt = [select id from RecordType where SObjectType = 'Case' and Name = 'Customer Connection Follow Up' LIMIT 1];
RecordType rt2 = [select id from RecordType where SObjectType = 'Surveys__c' and Name = 'SurveyGizmoSurvey' LIMIT 1];

        Case c = new Case();
        c.RecordTypeId = rt.id;
        c.Surveyable__c = true;

        insert(c);
        Surveys__c s = new SUrveys__c();
        s.recordtypeid=rt2.id;
        s.dqr_dealer_contacted__c ='yes';
        insert(s);
    
        Test.startTest();
        SurveyGizmo_UtilsPage sp = new SurveyGizmo_UtilsPage();
        sp.refreshState();
        Test.stopTest();
    }

}