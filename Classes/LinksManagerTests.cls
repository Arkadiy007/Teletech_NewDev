/**********************************************************************
Name: LinksManagerTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a test class for LinksManager.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/21/2015 Created 
***********************************************************************/
@isTest
public class LinksManagerTests {

    @isTest
    static void helperMethodsTests(){
        Test.startTest();
            System.assertEquals('/apex/x', LinksManager.GetUrlForPage('x'));
            System.assertEquals('z', LinksManager.GetUrlForDocument('z'));
        Test.stopTest();
    }

 }