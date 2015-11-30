public class SurveyGizmo_Utils {

  public String cloneCampaign(String thisSurveyNumber, String thisCampaignNumber, String newName) {
        // clones the given Campaign and returns the ID to the caller.
        String retval = '';    
        HttpRequest req = new HttpRequest();
        SurveyGizmoSettings__c sg = SurveyGizmoSettings__c.getOrgDefaults();
        req.setMethod('POST');
        // need to modify to change survey and campaign numbers based on brand
        String endpointUrl = 'https://restapi.surveygizmo.com/v4/survey/' + thisSurveyNumber + 
                             '/surveycampaign/' + thisCampaignNumber + 
                             '/?user:pass=' + sg.SurveyGizmoUserName__c + ':'+ sg.surveyGizmoPassword__c + 
                             '&_method=POST&copy=true&name=' + EncodingUtil.urlEncode(newName,'UTF-8');
        req.setEndpoint(endpointUrl);
        req.setBody('body'); 
        req.setTimeout(120000);
        Http http = new Http();
         try {  
              HTTPResponse res = http.send(req);   
              JSONParser parser = JSON.createParser(res.getBody());

            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')) {
                    // Get the value.
                    parser.nextToken();
                    retval = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'message')) {
                    // Get the value.
                    parser.nextToken();
                    //retval = 'Error' + parser.getText();
                    retval = thisCampaignNumber;   // clone didn't work use last campaign
                }
            }

              
         } catch(System.CalloutException e) {
              //retval = e.getMessage(); 
              retval = thisCampaignNumber;   // clone didn't work use last campaign
         }  

         return retval;

    }
    
    
public Boolean deleteCampaign(String thisSurveyNumber, String thisCampaignNumber) {
        // deletes the given Campaign and returns the result to the caller.
        Boolean retval = false;    
        HttpRequest req = new HttpRequest();
        SurveyGizmoSettings__c sg = SurveyGizmoSettings__c.getOrgDefaults();
        req.setMethod('POST');
       
        String endpointUrl = 'https://restapi.surveygizmo.com/v4/survey/' + thisSurveyNumber + 
                             '/surveycampaign/' + thisCampaignNumber + 
                             '/?_method=DELETE&user:pass=' + sg.SurveyGizmoUserName__c + ':'+ sg.surveyGizmoPassword__c;
        req.setEndpoint(endpointUrl);
        req.setBody('body'); 
        req.setTimeout(120000);
        Http http = new Http();
         try {  
              HTTPResponse res = http.send(req);   
              JSONParser parser = JSON.createParser(res.getBody());
            System.debug(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'result_ok')) {
                    // Get the value.
                    parser.nextToken();
                    retval = parser.getBooleanValue();
                }
            }
         } catch(System.CalloutException e) {
            System.debug('Error: ' + e.getMessage());
            retval = false;
         }  

         return retval;

    }




  public Map<String,DateTime> listCampaigns(String thisSurveyNumber) {
        // lists out the campaigns associated with a given survey and returns the result as list.
        List<DateTime> campDateTimes = new List<DateTime>();
        List<String> campIds = new List<String>();
        Map<String,DateTime> retval = new Map<String,DateTime>();

        HttpRequest req = new HttpRequest();
        SurveyGizmoSettings__c sg = SurveyGizmoSettings__c.getOrgDefaults();
        req.setMethod('POST');
        // need to modify to change survey and campaign numbers based on brand
        String endpointUrl = 'https://restapi.surveygizmo.com/v4/survey/' + thisSurveyNumber + 
                             '/surveycampaign/?user:pass=' + sg.SurveyGizmoUserName__c + ':'+ sg.surveyGizmoPassword__c + 
                             '&_method=GET&';
        req.setEndpoint(endpointUrl);
        req.setBody('body'); 
        req.setTimeout(120000);
        Http http = new Http();
         try {  
         
              HTTPResponse res = http.send(req);   
              System.debug(res.getBody());
              
              JSONParser parser = JSON.createParser(res.getBody());
              String thisResult = '';
            while (parser.nextToken() != null) {
            
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
            
                    while (parser.nextToken() != null) {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')) {
                            // Get the value.
                            parser.nextToken();
                            System.debug('getting next token for id' + thisResult);
                            campIds.add(parser.getText());
                        }
                        
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'datecreated')) {
                            // Get the value.
                            parser.nextToken();
                            String JSONContent = '{"thisDate":"' + parser.getText().replace(' ','T') + '"}';
                            JSONParser parser2 = JSON.createParser(JSONContent);
                            parser2.nextToken();
                            parser2.nextValue();
                            Datetime thisDate = 
                            parser2.getDatetimeValue();
                            campDateTimes.add(thisDate);
                        }
                    }
                    
                 }
             }
              
         } catch(System.CalloutException e) {
              System.debug(e.getMessage() + e.getLineNumber());
              campIds.add('Error: ' + e.getMessage() + '. Line Number: ' + e.getLineNumber());
              campDateTimes.add(DateTime.now());
              
              //retval.add('Salesforce Error: ' + e.getMessage()); 
         }  
         try {
         Integer x = 0;
            
         for (String thisCamp: campIds) {
               retval.put(thisCamp,campDateTimes[x]);
          x++;
         }
         } catch (Exception eee) {
             System.debug('exception: ' + eee.getMessage() + eee.getLineNumber());
         }
         return retval;

    }


    public String createSurveyGizmoContact(String thisSurveyNumber, String thisCampaignNumber, 
                                           Surveys__c thissurvey, String idOfSurvey, String dealerName, 
                                           String sgModel, String sgYear, String sgLeadDate) { 
                                           
         Http http = new Http();                                     
        List<Error_Log__c> errors = new List<Error_Log__c>();                      
        String retval = '';    
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        SurveyGizmoSettings__c sg = SurveyGizmoSettings__c.getOrgDefaults();
        try {
            req.setMethod('PUT');
            String endpointUrl = 'https://restapi.surveygizmo.com/v4/survey/' + thisSurveyNumber + '/surveycampaign/' + thisCampaignNumber + '/contact/?user:pass=' + sg.SurveyGizmoUserName__c + ':'+ sg.surveyGizmoPassword__c + '&_method=PUT&srole=Update';
             if (thissurvey.Email__c != null) {
               endpointUrl = endPointUrl + '&semailaddress=' + EncodingUtil.urlEncode(thissurvey.Email__c,'UTF-8');
             }
             if (thissurvey.Brand__c != null) {
                 endPointUrl = endPointUrl + '&sdivision=' + EncodingUtil.urlEncode(thissurvey.Brand__c,'UTF-8');
             }
             if (thissurvey.Case_Id__c != null) {
                 endPointUrl = endPointUrl + '&scustomfield1=' + EncodingUtil.urlEncode(thissurvey.Case_Id__c,'UTF-8');
             }
             if (thissurvey.Dealer__c != null) {
                 endPointUrl = endPointUrl + '&scustomfield2=' + EncodingUtil.urlEncode(thisSurvey.Dealer__c,'UTF-8'); 
             }
             if (dealerName != null) {
                 endPointUrl = endPointUrl + '&scustomfield3=' + EncodingUtil.urlEncode(dealerName,'UTF-8');
             }
             if (thisSurvey.First_Name__c != null) {
                 endPointUrl = endPointUrl + '&sfirstname=' + EncodingUtil.urlEncode(thisSurvey.First_Name__c,'UTF-8');
             }
             if (thisSurvey.Last_Name__c != null) {
                 endPointUrl = endPointUrl + '&slastname=' + EncodingUtil.urlEncode(thisSurvey.Last_Name__c,'UTF-8');
             }
             if (sgModel != null) {
                 endPointUrl = endPointUrl + '&scustomfield4=' + EncodingUtil.urlEncode(sgModel,'UTF-8');
             }
             if (sgYear != null) {
                 endPointUrl = endPointUrl + '&scustomfield5=' + EncodingUtil.urlEncode(sgYear,'UTF-8');
             }
             if (sgLeadDate != null) {
                 endPointUrl = endPointUrl + '&scustomfield6=' +  EncodingUtil.urlEncode(sgLeadDate,'UTF-8');
             }
             if (thisSurvey.Customer__c != null) {
                 endPointUrl = endPointUrl + '&scustomfield7=' +  EncodingUtil.urlEncode(thisSurvey.Customer__c,'UTF-8');
             }
             if (thisSurvey.Lead_Id__c != null) {                         
                 endPointUrl = endPointUrl + '&scustomfield8=' +  EncodingUtil.urlEncode(thisSurvey.Lead_Id__c,'UTF-8');
             }
             endPointUrl = endPointUrl + '&sdepartment=' +  EncodingUtil.urlEncode(DateTime.now().formatGmt('yyyy-MM-dd') + 'T' + DateTime.now().formatGmt('HH:mm:ss')+'-00:00','UTF-8');
             if (thisSurvey.SurveyGizmoExpireDateTime__c != null) {
                 endpointUrl = endPointUrl + '&scustomfield10=' + EncodingUtil.urlEncode(thisSurvey.SurveyGizmoExpireDateTime__c.formatGmt('yyyy-MM-dd'),'UTF-8');
             }
             if (thisSurvey.Customer_Id__c != null) {
                 endpointUrl = endPointUrl +  '&scustomfield9=' +  EncodingUtil.urlEncode(thisSurvey.Customer_Id__c,'UTF-8');
             }
             
             
            req.setEndpoint( endpointUrl);
            req.setBody('body'); 
			SurveyInvite__c invite = new SurveyInvite__c();
			invite.Email_address__c = thissurvey.Email__c;
			invite.Brand__c = thissurvey.Brand__c;
			invite.Case_Id__c = thissurvey.Case_Id__c;
			invite.Dealer_code__c = thissurvey.Dealer__c;
			invite.Dealer_Name__c = dealerName;
			invite.First_Name__c = thisSurvey.First_Name__c;
			invite.Last_Name__c = thisSurvey.Last_Name__c;
			invite.Model__c = sgModel;
			invite.Year__c = sgYear;
			invite.Lead_Date__c = sgLeadDate;
			invite.SurveyExpireDate__c = thisSurvey.SurveyGizmoExpireDateTime__c;
			invite.Lead_ID__c = thisSurvey.Lead_Id__c;
			invite.Customer__c = thisSurvey.Customer__c;

            insert invite;

        } catch (Exception ex) {
            errors.add(new Error_Log__c(
                        Error_Message__c = ex.getMessage() + ex.getLineNumber(), 
                        TimeStamp__c = System.now(), 
                        Operation_Name__c = 'SurveyGizmoUtils_Load Error', 
                        Source__c='Salesforce', 
                        Log_Type__c = 'Error', 
                        Log_Level__c = 1));
        
        }
        
        try {  
            HTTPResponse res = http.send(req);   
            retval = 'STATUS_CODE:' + res.getStatusCode();   // default return value,
             
            JSONParser parser = JSON.createParser(res.getBody());
            // need to try to return the id
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')) {
                    // Get the value.
                    parser.nextToken();
                    // Compute the grand total price for all invoices.
                    retval = parser.getText();
                }
            }
         } catch(Exception e) {
            retval = e.getMessage(); 
             errors.add(new Error_Log__c(
            Error_Message__c = e.getMessage() + e.getLineNumber(), 
            TimeStamp__c = System.now(), 
            Operation_Name__c = 'SurveyGizmoUtils_Load Error', 
            Source__c='Salesforce', 
            Log_Type__c = 'Error', 
            Log_Level__c = 1));

         }  

         return retval;
    }








}