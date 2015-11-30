public class VehicleInformationRequest_Controller { 
    public String recomend{get;set;}
    public String reasonsForRating{get;set;}
    public Surveys__c survey {get; set;}
    public String dealername {get; set;}
    public String customername {get; set;}
    public String year {get; set;}
    public String make {get; set;}
    public string model {get; set;}
    public Boolean nissanBrand {get; set;}
    public Boolean infinitiBrand {get; set;}
    public String dealerorretailer {get; set;}
    public Boolean dealerContacted {get; set;}
    public String ContactPhone {get; set;}
    public String ContactEmail {get; set;}
    public String stringId {get;set;}
    public Boolean isValidLink {get;set;}
    
    SurveyConfiguration__c sg = SurveyConfiguration__c.getOrgDefaults();
     String nissanEmail = sg.nissanEmail__c;
     String nissanPhone = sg.nissanPhone__c;
     String infinitiEmail = sg.infinitiEmail__c;
     String infinitiPhone = sg.infinitiPhone__c;
    
    
    
    
    public VehicleInformationRequest_Controller() {
     dealername = 'your dealership ';
     customername = '';
     dealerorretailer = 'Dealer';
     nissanBrand = false;
     infinitiBrand = false;
     dealerContacted = false;
     isValidLink = false;
     
          if (ApexPages.currentPage().getParameters().get('sid') != null) {
              
              
              //  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'found surveyid')); 
              dealerContacted = ApexPages.currentPage().getParameters().get('answer') == 'no' ? false : true; 
              
              List<Surveys__c> surveyl = [Select id, First_Name__c, name, brand__c, dealer__r.name from surveys__c where id=:ApexPages.currentPage().getParameters().get('sid')];
              if (surveyl.size() > 0) {
                  isValidLink = true;
                  survey = surveyl[0];
                  String brandString = survey.brand__c == null ? '' : survey.brand__c;
                  
                  if (brandString.toUpperCase() == 'NISSAN') {
                       nissanBrand = true;
                       ContactPhone = nissanPhone;
                       ContactEmail = nissanEmail;
                       
                   }
                  if (brandString.toUpperCase() == 'INFINITI') {
                       infinitiBrand = true;
                       dealerorretailer = 'Retailer';
                       ContactPhone = infinitiPhone;
                       ContactEmail = infinitiEmail;
                   }
                    
               }
           
               dealername = survey.dealer__r.Name;
               customername = survey.first_name__c;
               
           } else {
           
           
           }

    }

    public PageReference submitForm()
    {

        return submitSurvey();
    }
    private PageReference submitSurvey()//(string pageExitName)
    {
        //update survey();

        if (dealerContacted) {
            survey.DQR_Dealer_Contacted__c = 'yes';
        } else {
            survey.DQR_Dealer_Contacted__c = 'no';
        }
        survey.DQR_Dealer_Rating__c = Decimal.valueOf(recomend);
        survey.DQR_Dealer_Comments__c = reasonsForRating;
        update survey;

        PageReference pageRef = new PageReference(getExitUrl());//pageExitName));
        pageRef.setRedirect(true);
        return pageRef;

        
        
        
    }
        //It obtains the URL of the Exit Page dynamically 
    private String getExitUrl(){//(string pageExitName) {
        String exitUrl = URL.getCurrentRequestUrl().toExternalForm();
        Integer lastIndex = exitUrl.lastIndexOf('/');
        exitUrl = exitUrl.substring(0, lastIndex + 1);
        if(infinitiBrand && dealerContacted){
            exitUrl += 'Vehicle_Information_Request_thk?brand=infiniti&answer=yes';
        }else if(infinitiBrand && !dealerContacted){ 
            exitUrl += 'Vehicle_Information_Request_thk?brand=infiniti&answer=no';
        }else if(!infinitiBrand && dealerContacted){ 
            exitUrl += 'Vehicle_Information_Request_thk?brand=nissan&answer=no';
        }else if(!infinitiBrand && !dealerContacted){ 
            exitUrl += 'Vehicle_Information_Request_thk?brand=nissan&answer=no';
        }
        return exitUrl;
    }

	//It obtains the URL of the livechat dynamically 
    public String getChatUrl(){//(string pageExitName) {
        String exitUrl = URL.getCurrentRequestUrl().toExternalForm();
        Integer lastIndex = exitUrl.lastIndexOf('/');
        exitUrl = exitUrl.substring(0, lastIndex + 1);
        if(infinitiBrand && dealerContacted){
            exitUrl += 'LiveAgent_NewInfiniti?routingGroup=InfinitiDC';
        }else if(infinitiBrand && !dealerContacted){ 
            exitUrl += 'LiveAgent_NewInfiniti?routingGroup=InfinitiNC';
        }else if(!infinitiBrand && dealerContacted){ 
            exitUrl += 'LiveAgent_NewNissan?routingGroup=NissanDC';
        }else if(!infinitiBrand && !dealerContacted){ 
            exitUrl += 'LiveAgent_NewNissan?routingGroup=NissanNC';
        }
        return exitUrl;
    }
}