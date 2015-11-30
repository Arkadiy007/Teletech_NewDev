@istest
public class DTSRequest_Controller_Test {

 public static testMethod void testDTStechline() {
        // Instantiate a new controller with all parameters in the page

    Case c = new Case(
      Description='UNIT TESTING',
      Origin='Phone',
      Priority='Medium',
      Status='New',
      RecordTypeId='012F0000000yFmQ',DTS_Notes__c='test'
      );        
    insert c;
      ApexPages.currentPage().getParameters().put('id', c.id);
        
        ApexPages.StandardController sc = new ApexPages.standardController(c);

        DTSRequest_Controller controller = new DTSRequest_Controller(sc); 

        controller.go();
        
        
    }    
public static testMethod void testDTSca() {

    Case c = new Case(
      Description='UNIT TESTING',
      Origin='Phone',
      Priority='Medium',
      Status='New' ,
      RecordTypeId='012F0000000y9y7',DTS_Notes__c='test'
      );        
    insert c;
      ApexPages.currentPage().getParameters().put('id', c.id);
        
       ApexPages.StandardController sc = new ApexPages.standardController(c);

        DTSRequest_Controller controller = new DTSRequest_Controller(sc); 

        controller.go();
        
        
    }    


}