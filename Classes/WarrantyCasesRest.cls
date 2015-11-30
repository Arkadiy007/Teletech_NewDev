@RestResource(urlMapping = '/warrantyCase/api/v1/cases/*')
global class WarrantyCasesRest {
    
    @HttpPost
    global static WarrantyCaseRest.ResponseWrapper[] createCases(WarrantyCaseRest.RequestWrapper[] requests){
        List<Warranty_Case__c> casesToInsert = new List<Warranty_Case__c>();
        List<WarrantyCaseRest.ResponseWrapper> responses = new List<WarrantyCaseRest.ResponseWrapper>();

        Set<WarrantyCaseRest.RequestWrapper> badRequests = new Set<WarrantyCaseRest.RequestWrapper>();
        List<WarrantyCaseRest.ResponseWrapper> badResponses = new List<WarrantyCaseRest.ResponseWrapper>();

        for(WarrantyCaseRest.RequestWrapper request : requests){
            WarrantyCaseRest.ResponseWrapper response = WarrantyCaseRest.validateCase(request);
            if(response.code == 400){
                badRequests.add(request);
                badResponses.add(response);
            }
            else{
                responses.add(WarrantyCaseRest.validateCase(request));
            }
        }


        for(WarrantyCaseRest.RequestWrapper request : requests){
            if(!badRequests.contains(request)){
                casesToInsert.add(WarrantyCaseRest.caseBuilder(request));
            }
        }

        try{            
            insert casesToInsert;


       

            for(Integer i = 0; i < casesToInsert.size(); i++){
                responses[i].sfdcId = casesToInsert[i].id;
                responses[i].code = 200;
                responses[i].status = 'success';
                responses[i].message = 'OK';
            }
        }
        catch(DMLException e){
            for(WarrantyCaseRest.ResponseWrapper rw : responses){
                rw.code = 500;
                rw.status = 'error';
                rw.message = 'Internal error on insert: ' + e.getMessage();
            }
            System.debug(e);
        }
        responses.addAll(badResponses); 
        return responses;
    }
    

}