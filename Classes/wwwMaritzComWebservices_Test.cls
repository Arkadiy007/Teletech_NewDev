/**********************************************************************
Name: wwwMaritzComWebservices_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for wwwMaritzComWebservicesr.
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Sonali Bhardwaj 02/07/2011 Created 
***********************************************************************/
@isTest
private class wwwMaritzComWebservices_Test  {
    
    static  testmethod void testSubmitRecord() {
        wwwMaritzComWebservices.SubmitSoap obj = new wwwMaritzComWebservices.SubmitSoap();
        obj.SubmitRecord('', '');
        obj.SubmitPerson('', '', '', '', '');
    }
    
    static  testmethod void testSubmitPerson() {
        wwwMaritzComWebservices.SubmitRecordResponse_element obj1 = new wwwMaritzComWebservices.SubmitRecordResponse_element();
        wwwMaritzComWebservices.SubmitPersonResponse_element obj2 = new wwwMaritzComWebservices.SubmitPersonResponse_element();
        
        wwwMaritzComWebservices.SubmitSoap obj = new wwwMaritzComWebservices.SubmitSoap();
        obj.SubmitPerson('', '', '', '', '');
    }
}