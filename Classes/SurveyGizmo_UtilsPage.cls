public class SurveyGizmo_UtilsPage {
  public String outputHTML {get; set;}
   public List<Error_Log__c> errs {get;set;}   
    
  public SurveyGizmo_UtilsPage() {
      outputHTML='loading..';
      errs = [select id, createddate, error_message__c from error_log__c where 
      operation_name__c like 'SurveyGizmo%' and createddate=last_n_days:5 ORDER BY Createddate DESC];
  }
  
  public PageReference refreshState() {
  
  
    //String outputHTML;
    Map<String,String> dataMap = new Map<String,String>();

    
    // maritz surveys flagged to send
    List<AggregateResult> casesl = [select DAY_ONLY(CREATEDDATE) crt, 
    HOUR_IN_DAY(createddate) thehour, 
    count(id) thecount from case 
    where recordtype.name IN ('Customer Connection Follow Up','Lead Survey') 
    and surveyable__c=true 
    and createddate=last_n_days:5 
    group by  HOUR_IN_DAY(createddate), DAY_ONLY(CREATEDDATE) 
    order by day_only(createddate), hour_in_day(createddate)];
    
    if(casesl.size() > 0) {
        for (Integer x = 0; x < casesl.size(); x++) {
            dataMap.put(casesl[x].get('crt')+'*'+casesl[x].get('thehour'),''+casesl[x].get('thecount'));
           
        }
    }
    // martizs surveys sent
    List<AggregateResult> cases2 = [select DAY_ONLY(CREATEDDATE) crt, 
    HOUR_IN_DAY(createddate) thehour, 
    count(id) thecount from case 
    where recordtype.name IN ('Customer Connection Follow Up','Lead Survey') 
    and surveyable__c=true and surveygizmosurveysent__c=true 
    and createddate=last_n_days:5 
    group by  HOUR_IN_DAY(createddate), DAY_ONLY(CREATEDDATE) 
    order by day_only(createddate), hour_in_day(createddate)];
    if(cases2.size() > 0) {
        for (Integer x = 0; x < cases2.size(); x++) {
            dataMap.put(cases2[x].get('crt')+'*'+cases2[x].get('thehour'),dataMap.get(cases2[x].get('crt')+'*'+cases2[x].get('thehour'))+','+cases2[x].get('thecount'));
           
        }
    }
// reponses received

    List<AggregateResult> surveysa = [select DAY_ONLY(createddate) crt, HOUR_IN_DAY(createddate) thehour, 
    count(id) thecount from surveys__c where recordtypeid='012F0000000zXjN' and dqr_dealer_contacted__c != null 
    and createddate=last_n_days:5 
    group by HOUR_IN_DAY(createddate), DAY_ONLY(CREATEDDATE) 
    order by day_only(createddate),hour_in_day(createddate)];
    if(surveysa.size() > 0) {
        for (Integer x = 0; x < surveysa.size(); x++) {
            dataMap.put(surveysa[x].get('crt')+'*'+surveysa[x].get('thehour'),dataMap.get(surveysa[x].get('crt')+'*'+surveysa[x].get('thehour'))+';'+surveysa[x].get('thecount'));
           
        }
    }
    
    
    
    
    List<String> aList = new List<String>();
    aList.addAll(dataMap.keySet());
    
    aList.sort();
    outputHTML = '<table class=\'list\'><tr><td>Date</td><td>Hour</td><td>Surveys Flagged</td><td>Surveys Sent</td>' +
    '<td>Percentage Complete</td><td>Responses Received</td></tr>';
    for (String datepart : aList){
            String[] dmp;
            String aResponse = '';
    
            if (dataMap.get(datepart).contains(';')) {
                // has responses, parse out responses, set first part back to the datamap
                dmp = dataMap.get(datepart).split(';');
                if (dmp.size() == 1) {
                    // only has afterwords part, (responses) set that
                    aResponse = dmp[0];
                }
                if (dmp.size() > 1) {
                    // has reponses and other part, set responses and setback datamap.
                    //dataMap.put(datepart,dmp[0]);
                    aResponse = dmp[1];
                }
            }
            String[] ss;
            String preess;          
            String flaggedNum = '0';
            String sentNum = '0';
        if (dataMap.get(datepart).contains(';')) {
             preess = dmp[0];   
        } else {
            preess = dataMap.get(datepart);   
        }
            if (preess.contains(',')) {
                ss = preess.split(',');
                flaggedNum = ss[0];
                sentNum = ss[1];
            } else {
                flaggedNum = preess;
                sentNum = '0';
            }

        Decimal pctg = 0;
        System.debug('is the string blank: ' + String.isBlank(flaggedNum));
        System.debug('is the string blank2: ' + String.isEmpty(flaggedNum));
        System.debug('is the string blank3:***'+flaggedNum+'***');
        
        
        if (String.isBlank(flaggedNum) || flaggedNum == 'null') {
            flaggedNum = '0';
        }
        if (Decimal.valueOf(flaggedNum) > 0) {
            pctg = 100*Decimal.valueOf(sentNum).divide(Decimal.valueOf(flaggedNum),2);
            
        }
        String[] dps = datepart.split('\\*');
        Decimal pctg2 = (pctg / 100) * 155;
            pctg2 = pctg2.intValue() + 100; // gives us some hue
            String pctg2s = String.valueOf(pctg2).replace('.00','');
            outputHTML = outputHTML + '<tr><td>'+dps[0].replace(' 00:00:00','')+'</td><td>'+dps[1]+'</td><td>'+flaggedNum+'</td><td>'+sentNum +'</td><td style=\'background-color: rgb(0,'+pctg2s+',0)\'>'+pctg+'</td><td>'+aResponse+'</td></tr>';
            
    }
    outputHTML = outputHTML + '</table>';
      //outputHTML='Tester1';
    
   // outputHTML = '<br><br>test';
    // System.debug(outputHTML);
    
   // outputHTML = '<br><br>test';
    return null;
  }
}