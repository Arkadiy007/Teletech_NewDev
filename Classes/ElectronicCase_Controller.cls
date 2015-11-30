public class ElectronicCase_Controller {
	public String dealerName { get; set; }
	public String dealerCode { get; set; }
	public integer screenIndex { get; set; }
	private String errorMessage { get; set; }
	public boolean renderFirst { get { return screenIndex == 0; } set; }
	public boolean renderSecond { get { return screenIndex == 1; } set; }
	public boolean renderThird { get { return screenIndex == 2; } set; }
	public String techName { get; set; }
	public String lmsId { get; set; }
	public String profLevel { get; set; }
	public String cellNumber { get; set; }
	public String emailAddr { get; set; }
	public String prefMethod { get; set; }
	public String vin { get; set; }
	public String customerName { get; set; }
	public String mileage { get; set; }

	public ElectronicCase_Controller() {
		screenIndex = 0;
	}

	public PageReference goToNextScreen() {
		Boolean success = false;
		errorMessage = '';
		if (screenIndex == 0) {
			success = checkFirstQuestion();
		}
		else if (screenIndex == 1) {
			success = true;
		}else if (screenIndex == 2) {
			success = checkThirdQuestion();
		}

		if (success) {
			screenIndex++;
		} else {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errorMessage));

		}
		return null;
	}

	private boolean checkFirstQuestion() {
		Id dealerRecordType = RecordTypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer');
		List<Account> dealer = [SELECT ID from Account WHERE RecordTypeId = :dealerRecordType AND name = :dealerName AND Dealer_Code__c = :dealerCode];
		if (dealer.size() > 0) {

			return true;
		}
		errorMessage = 'Dealer cannot be found';
		return false;
	}

	private boolean checkThirdQuestion() {
		
		List<Vehicle__c> vehicle = [SELECT ID from Vehicle__c WHERE Vehicle_identification_Number__c = :vin];
		if (vehicle.size() > 0) {

			return true;
		}
		errorMessage = 'Vehicle cannot be found';
		return false;
	}

}