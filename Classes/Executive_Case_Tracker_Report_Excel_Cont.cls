public class Executive_Case_Tracker_Report_Excel_Cont { 
	public Map <Id, Case> casesMap {get; set;}
	public Map<Id, List<Case_Categorization__c>> caseCategorizationsMap {get; set;}

	public List<TabelRepresentation> casesReportData {get; set;}

	public void initializeData(Map <Id, Case> c, Map<Id, List<Case_Categorization__c>> cc) {
		if(null != c && !c.isEmpty()) {
			this.casesMap = c;
			this.caseCategorizationsMap = cc; 
			casesReportData = new List<TabelRepresentation>();

			for (Id i : casesMap.keySet()) {
				casesReportData.add(new TabelRepresentation(casesMap.get(i), caseCategorizationsMap.get(i)));
			}	
		}
	}


	class TabelRepresentation {
		public String customerName {get; set;}
		public String dealer {get; set;}
		public String region {get; set;}
		public String execRecievedDate {get; set;}
		public DateTime dateClosed {get; set;}
		public String myModelMileage {get; set;}
		public String concernDescription {get; set;}
		public String subcategoryDescription {get; set;}
		public String caseDescription {get; set;}
		public Boolean executiveActionsToResolve {get; set;}

		public TabelRepresentation(Case c, List<Case_Categorization__c> cc) {
			this.customerName = c.Customer_Name__c;
			this.dealer = c.Dealer__c;
			this.region = c.Region_d__c;
			this.execRecievedDate = c.Exec_Received_Date__c;
			this.dateClosed = c.Date_Closed__c;
			//this.myModelMileage
			this.concernDescription = '';
			this.subcategoryDescription = '';
			if(null != cc && cc.size() > 0) {
				for(Case_Categorization__c caseCat : cc) {
					this.concernDescription += caseCat.Concern_Description__c + '<br/>';
					this.subcategoryDescription += caseCat.Category_Description__c + '\n';
				}
			}
			this.caseDescription = c.Description;
			this.executiveActionsToResolve = c.Executive_Referral__c;
		}
	}
}