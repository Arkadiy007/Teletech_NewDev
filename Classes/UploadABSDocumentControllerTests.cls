/**********************************************************************
Name: UploadABSDocumentControllerTests
Copyright � notice: NMAC.
======================================================
Purpose:
This is a tests for UploadABSDocumentController.cls
 
======================================================
History: 

VERSION AUTHOR DATE DETAIL
1.0 - Arshakyan Georgiy 5/13/2015 Created 
***********************************************************************/
@isTest
public class UploadABSDocumentControllerTests {
    public static User u {get; set;}public static Document testDoc {get; set;}

    static{
        populateTestData();
    }
    
    @isTest
    static void testDocumentUploadingForQData(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','QData');
            ApexPages.currentPage().getParameters().put('id',[SELECT Id FROM Ws_Tab_Quarterly_Data_Item__c WHERE Document__c = null LIMIT 1][0].id);
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForQData, true);
            System.assertNotEquals(up.qItem, null);

            up.d = new Document(Name = 'test.pdf', Body = Blob.valueof('test'));
            up.uploadDoc();
                
            Test.stopTest();

        }
    }

    @isTest
    static void testDocumentUploadingForQDataOrderNumberInvalid(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','QData');
            ApexPages.currentPage().getParameters().put('id',[SELECT Id FROM Ws_Tab_Quarterly_Data_Item__c WHERE Document__c = null LIMIT 1][0].id);
            
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForQData, true);
            System.assertNotEquals(up.qItem, null);

            up.orderNumber = 3;
            up.d = new Document(Name = 'test.pdf', Body = Blob.valueof('test'));
            up.uploadDoc();



        
            Test.stopTest();
            
        }
    }
    
    @isTest
    static void testDocumentUploadingForQDataOrderNumberOutOfRange(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','QData');
            ApexPages.currentPage().getParameters().put('id',[SELECT Id FROM Ws_Tab_Quarterly_Data_Item__c WHERE Document__c = null LIMIT 1][0].id);
        
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForQData, true);
            System.assertNotEquals(up.qItem, null);

            up.orderNumber = 333;
            up.d = new Document(Name = 'test.pdf', Body = Blob.valueof('test'));
            up.uploadDoc();

            
            
            Test.stopTest();

        }
    }

    @isTest
    static void testDocumentUploadingForQDataNewLine(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','QData');
            ApexPages.currentPage().getParameters().put('oid',[SELECT Id FROM Ws_Tab_Quarterly_Data__c WHERE State__c = 'Sent For Review'][0].id);
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForQData, true);

            up.d = new Document(Name = 'test.pdf', Body = Blob.valueof('test'));
            up.qItem.InfoText = 'Test';
            up.orderNumber = 11;
            up.uploadDoc();
                
            Test.stopTest();

            System.assertEquals(11, [SELECT Count() FROM Ws_Tab_Quarterly_Data_Item__c]);
        }
    }

    @isTest
    static void testDocumentUploadingForQDataNewLineInvalidOrderNum(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','QData');
            ApexPages.currentPage().getParameters().put('oid',[SELECT Id FROM Ws_Tab_Quarterly_Data__c WHERE State__c = 'Sent For Review'][0].id);
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForQData, true);

            up.d = new Document(Name = 'test.pdf', Body = Blob.valueof('test'));
            up.qItem.InfoText = 'Test';
            up.orderNumber = 3;
            up.uploadDoc();
                
            Test.stopTest();

            System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Quarterly_Data_Item__c]);
        }
    }

    @isTest
    static void testDocumentUploadingForQDataNewLineBigOrderNum(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','QData');
            ApexPages.currentPage().getParameters().put('oid',[SELECT Id FROM Ws_Tab_Quarterly_Data__c WHERE State__c = 'Sent For Review'][0].id);
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForQData, true);

            up.d = new Document(Name = 'test.pdf', Body = Blob.valueof('test'));
            up.qItem.InfoText = 'Test';
            up.orderNumber = -623;
            up.uploadDoc();
                
            Test.stopTest();

            System.assertEquals(10, [SELECT Count() FROM Ws_Tab_Quarterly_Data_Item__c]);
        }
    }


    @isTest
    static void testDocumentUploadingForPresentation(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','pres');
            ApexPages.currentPage().getParameters().put('id',[SELECT Id FROM Ws_Tab_Presentation_Item__c LIMIT 1][0].id);
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForPresentation, true);
            System.assertNotEquals(up.pItem, null);

            up.d = new Document(Name = 'test.pdf', Body = Blob.valueof('test'));
            up.img = new Document(Name = 'test.jpg', Body = Blob.valueOf('Image'));
            up.uploadDoc();
                
            Test.stopTest();

        }
    }

    @isTest
    static void testDocumentUploadingForPresentationWrongOrderNum(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','pres');
            ApexPages.currentPage().getParameters().put('id',[SELECT Id FROM Ws_Tab_Presentation_Item__c LIMIT 1][0].id);
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForPresentation, true);
            System.assertNotEquals(up.pItem, null);
            up.orderNumber = 232;
            up.d = new Document(Name = 'test.pdf', Body = Blob.valueof('test'));
            up.img = new Document(Name = 'test.jpg', Body = Blob.valueOf('Image'));
            up.uploadDoc();

                
            Test.stopTest();

        }
    }

    @isTest
    static void testDocumentUploadingForPresentationWrongOrderNumOnlyImg(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','pres');
            ApexPages.currentPage().getParameters().put('id',[SELECT Id FROM Ws_Tab_Presentation_Item__c LIMIT 1][0].id);
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForPresentation, true);
            System.assertNotEquals(up.pItem, null);
            up.orderNumber = 232;
            
            up.img = new Document(Name = 'test.jpg', Body = Blob.valueOf('Image'));
            up.uploadDoc();

                
            Test.stopTest();

        }
    }
    @isTest
    static void testDocumentUploadingForPresentationInvalid(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','pres');
            ApexPages.currentPage().getParameters().put('id',[SELECT Id FROM Ws_Tab_Presentation_Item__c LIMIT 1][0].id);
            
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForPresentation, true);
            System.assertNotEquals(up.pItem, null);
            up.orderNumber = 2;
            up.d = new Document(Name = 'test.pdf', Body = Blob.valueof('test'));
            up.img = new Document(Name = 'test.jpg', Body = Blob.valueOf('Image'));
            up.uploadDoc();

            
            
            Test.stopTest();

        }
    }

    @isTest
    static void testDocumentUploadingForPresentationInvalidOnlyImg(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','pres');
            ApexPages.currentPage().getParameters().put('id',[SELECT Id FROM Ws_Tab_Presentation_Item__c LIMIT 1][0].id);
            
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForPresentation, true);
            System.assertNotEquals(up.pItem, null);
            up.orderNumber = 2;
            
            up.img = new Document(Name = 'test.jpg', Body = Blob.valueOf('Image'));
            up.uploadDoc();

            
            
            Test.stopTest();

        }
    }


    @isTest
    static void testDocumentUploadingForPresentationNewLine(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','pres');
            ApexPages.currentPage().getParameters().put('oid', [SELECT Id, Name FROM Ws_Tab_Presentations__c WHERE State__c = 'Sent For Review'][0].id);
            
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForPresentation, true);
            System.assertNotEquals(up.pItem, null);
            up.d = new Document(Name = 'test.pdf', Body = Blob.valueOf('Doc'));
            up.img = new Document(Name = 'test.jpg', Body = Blob.valueOf('Image'));
            up.uploadDoc();
                
            Test.stopTest();
            
        }
    }
    

    @isTest
    static void testDocumentUploadingForPresentationNewLineOnlyImg(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','pres');
            ApexPages.currentPage().getParameters().put('oid', [SELECT Id, Name FROM Ws_Tab_Presentations__c WHERE State__c = 'Sent For Review'][0].id);
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForPresentation, true);
            System.assertNotEquals(up.pItem, null);
            
            up.img = new Document(Name = 'test.jpg', Body = Blob.valueOf('Image'));
            up.uploadDoc();
                
            Test.stopTest();

        }
    }

    @isTest
    static void testDocumentUploadingForPresentationNewLineOnlyDocASImg(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','pres');
            ApexPages.currentPage().getParameters().put('oid', [SELECT Id, Name FROM Ws_Tab_Presentations__c WHERE State__c = 'Sent For Review'][0].id);
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForPresentation, true);
            System.assertNotEquals(up.pItem, null);
            
            up.img = new Document(Name = 'test.pdf', Body = Blob.valueOf('Image'));
            up.uploadDoc();
            
            List<Apexpages.Message> pageMessages = ApexPages.getMessages();
            Boolean isMsgShown = false;
            for(Apexpages.Message msg : pageMessages){
                if(msg.getSummary().contains('needs to be an image. Available extensions are: .png, .jpg, .jpeg ')){
                    isMsgShown = true;
                }
            }

            System.assert(isMsgShown);

            Test.stopTest();

        }
    }


    @isTest
    static void testUploadingForPresentationNewLineWithNoDocumentsSelected(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','pres');
            ApexPages.currentPage().getParameters().put('oid', [SELECT Id, Name FROM Ws_Tab_Presentations__c WHERE State__c = 'Sent For Review'][0].id);
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForPresentation, true);
            System.assertNotEquals(up.pItem, null);
            
            up.uploadDoc();
            
            List<Apexpages.Message> pageMessages = ApexPages.getMessages();
            Boolean isMsgShown = false;
            for(Apexpages.Message msg : pageMessages){
                if(msg.getSummary().contains('Select')){
                    isMsgShown = true;
                }
            }

            System.assert(isMsgShown);

            Test.stopTest();

        }
    }
    
    @isTest
    static void testUploadingForQDataNewLineWithNoDocumentsSelected(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','qdata');
            ApexPages.currentPage().getParameters().put('oid', [SELECT Id, Name FROM Ws_Tab_Presentations__c WHERE State__c = 'Sent For Review'][0].id);
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForQData, true);
            System.assertNotEquals(up.qItem, null);
            
            up.uploadDoc();
            
            List<Apexpages.Message> pageMessages = ApexPages.getMessages();
            Boolean isMsgShown = false;
            for(Apexpages.Message msg : pageMessages){
                if(msg.getSummary().contains('Please, select document for item')){
                    isMsgShown = true;
                }
            }

            System.assert(isMsgShown);

            Test.stopTest();

        }
    }

    @isTest
    static void testUploadingForABSNewLineWithNoDocumentsSelected(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('id',[SELECT Id FROM Ws_Tab_Abs_Line__c LIMIT 1][0].id);
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForABS, true);
            System.assertNotEquals(up.item, null);
            
            up.uploadDoc();
            
            List<Apexpages.Message> pageMessages = ApexPages.getMessages();
            Boolean isMsgShown = false;
            for(Apexpages.Message msg : pageMessages){
                if(msg.getSummary().contains('Select Document To Upload')){
                    isMsgShown = true;
                }
            }

            System.assert(isMsgShown);

            Test.stopTest();

        }
    }
    

    @isTest
    static void testDocumentUploadingForPresentationNewLineOnlyDoc(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('page','pres');
            ApexPages.currentPage().getParameters().put('oid', [SELECT Id, Name FROM Ws_Tab_Presentations__c WHERE State__c = 'Sent For Review'][0].id);
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForPresentation, true);
            System.assertNotEquals(up.pItem, null);
            up.d = new Document(Name = 'test.pdf', Body = Blob.valueOf('Doc'));
        
            up.uploadDoc();
                
            Test.stopTest();

        }
    }
    

    @isTest
    static void testDocumentUploadingForABSNewLine(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('id',[SELECT Id FROM Ws_Tab_Abs_Line__c LIMIT 1][0].id);
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForABS, true);
            System.assertNotEquals(up.item, null);

            up.d = new Document(Name = 'test.pdf', Body = Blob.valueof('test'));
            up.uploadDoc();
                
            Test.stopTest();

        }
    }

    @isTest
    static void testDocumentUploadingForABSNewLineInvalidNum(){
        System.runAs(u){
            PageReference pageRef = Page.UploadABSDocument;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('id',[SELECT Id FROM Ws_Tab_Abs_Line__c LIMIT 1][0].id);
            Test.startTest();
            
            UploadABSDocumentController up = new UploadABSDocumentController();
            
            System.assertEquals(up.uploadForABS, true);
            System.assertNotEquals(up.item, null);

            up.orderNumber = -222;
            up.d = new Document(Name = 'test.pdf', Body = Blob.valueof('test'));
            up.uploadDoc();

            List<Apexpages.Message> pageMessages = ApexPages.getMessages();
            Boolean isMsgShown = false;
            for(Apexpages.Message msg : pageMessages){
                if(msg.getSummary().contains('Order number is out of range')){
                    isMsgShown = true;
                }
            }

            System.assert(isMsgShown);
                
            Test.stopTest();

        }
    }       


    private static void populateTestData(){
        Helper.insertRecords();

        Ws_Tab_Quarterly_Data__c testQ = [SELECT Id, Name FROM Ws_Tab_Quarterly_Data__c WHERE State__c = 'Sent For Review'][0];
        Ws_Tab_Presentations__c  presTest = [SELECT Id, Name FROM Ws_Tab_Presentations__c WHERE State__c = 'Sent For Review'][0];

        Ws_Tab_Abs__c abs = [SELECT Id FROM Ws_Tab_Abs__c WHERE State__c = 'Sent For Review'][0];
        Ws_Tab_Abs_Line__c lineABS = new Ws_Tab_Abs_Line__c(Name = 'Test', Major_Heading__c = 'Retail', Order_Number__c = 12, Ws_Tab_Abs__c= abs.id);

        insert lineABS;

        List<Ws_Tab_Abs_Line_Item__c> items = new List<Ws_Tab_Abs_Line_Item__c>();

        List<Ws_Tab_Quarterly_Data_Item__c> testItems = new List<Ws_Tab_Quarterly_Data_Item__c>();  
        List<Ws_Tab_Presentation_Item__c> testItemsPres = new List<Ws_Tab_Presentation_Item__c>();
        
        
        Document_Proxy__c dp1 = new Document_Proxy__c(Name = 'Document', Link__c = '/servlet/servlet.FileDownload?file=xc2sasdaxczs', Document_Extension__c = 'xls');
        Document_Proxy__c dp2 = new Document_Proxy__c(Name = 'Document', Link__c = '/servlet/servlet.FileDownload?file=xsdc2sasdaxczs', Document_Extension__c = 'pdf');
        Document_Proxy__c dp3 = new Document_Proxy__c(Name = 'Document', Link__c = '/servlet/servlet.FileDownload?file=xzxcxc2sasdaxczs', Document_Extension__c = 'lsx');

        insert dp1;
        insert dp2;
        insert dp3;


        for(Integer i = 0; i < 10; i++){
            Ws_Tab_Quarterly_Data_Item__c testTmp = new Ws_Tab_Quarterly_Data_Item__c(Ws_Tab_Quarterly_Data__c = testQ.id, Order_Number__c = i);
            testItems.add(testTmp);

            Ws_Tab_Presentation_Item__c  testPresTmp = new Ws_Tab_Presentation_Item__c(Ws_Tab_Presentation__c = presTest.id, Order_Number__c = i);
            testItemsPres.add(testPresTmp);
            
            Ws_Tab_Abs_Line_Item__c testAbsItem = new Ws_Tab_Abs_Line_Item__c(Ws_Tab_Abs_Line__c = lineABS.id, Order_Number__c = i, Subheading__c = 'test');
            items.add(testAbsItem);
        }
        
        testItems[3].Document__c = dp1.id;
        

        insert testItems;
        insert testItemsPres;
        insert items;
        System.DEBUG(items);
    

    
        Profile p = [select id
                      from profile
                      where Name = 'System Administrator'
                      limit 1];  
        
        if(u == null){
            u = new User(profileId = p.id, username = 'test12xzcxzcxzc22@test.com', email = 'test12232asdx22@test.com',
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname');
        

        
            insert u;
        }
    }
 
 

 }