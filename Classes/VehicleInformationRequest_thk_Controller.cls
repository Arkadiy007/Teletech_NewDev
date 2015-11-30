public class VehicleInformationRequest_thk_Controller { 
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
    
    public VehicleInformationRequest_thk_Controller() {
             dealername = 'your dealership ';
             customername = '';
             dealerorretailer = 'Dealer';
             nissanBrand = false;
             infinitiBrand = false;
             dealerContacted = false;
             String nissanEmail = 'NissanHQ@Nissan-USA.com';
             String nissanPhone = '(800)-826-6500';
             String infinitiEmail = 'InfinitiHQ@infiniti.com';
             String infinitiPhone = '(800)-235-8880';
             
          if (ApexPages.currentPage().getParameters().get('brand') != null) {
              //  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'found surveyid')); 
              dealerContacted = ApexPages.currentPage().getParameters().get('answer') == 'no' ? false : true; 
              
                  if (ApexPages.currentPage().getParameters().get('brand') .toUpperCase() == 'NISSAN') {
                       nissanBrand = true;
                       ContactPhone = nissanPhone;
                       ContactEmail = nissanEmail;
                       
                   }
                  if (ApexPages.currentPage().getParameters().get('brand') .toUpperCase() == 'INFINITI') {
                       infinitiBrand = true;
                       dealerorretailer = 'Retailer';
                       ContactPhone = infinitiPhone;
                       ContactEmail = infinitiEmail;
                   }
                    
               
           } else {
           
           
           }

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