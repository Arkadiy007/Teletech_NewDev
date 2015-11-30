public class EmailTemplateImages_Controller { 
	public String makeVehicle{
		get; set;
	}
	public String day_of_sale{
		get; set;
	}
	public String First_Name{
		get; set;
	}
	public String year_Make_Model{
		get; set;
	}
	public String dealer_Name{
		get; set;
	}
	public String survey_Id{
		get; set;
	}
	public boolean NissanOrInfiniti{
		get{
			if(makeVehicle.toUpperCase().contains('NISSAN')){
				return true;
			}
			return false;
		}
	}
	public String LogoUrl{
		get {
			string SFInstance = URL.getSalesforceBaseUrl().toExternalForm();
			id orgId = UserInfo.getOrganizationId();
			String idDocument;
				if(makeVehicle.toUpperCase().contains('NISSAN')){
					String docName = 'Nissan Header';
					idDocument = [Select Id,Name from Document where Name LIKE :docName limit 1][0].id;			
				}else if(makeVehicle.toUpperCase().contains('INFINITI')){
					String docName = 'Infiniti Header';
					idDocument = [Select Id,Name from Document where Name LIKE :docName limit 1][0].id;	
				}
			
			return SfInstance + '/servlet/servlet.ImageServer?id=' + idDocument  + '&oid=' + orgId ;
		}
	}
	public String YesButtonUrl{
		get {
			string SFInstance = URL.getSalesforceBaseUrl().toExternalForm();
			id orgId = UserInfo.getOrganizationId();
			String idDocument;
				if(makeVehicle.toUpperCase().contains('NISSAN')){
					String docName = 'Nissan yes button';
					idDocument = [Select Id,Name from Document where Name LIKE :docName limit 1][0].id;			
				}else if(makeVehicle.toUpperCase().contains('INFINITI')){
					String docName = 'Infiniti yes button';
					idDocument = [Select Id,Name from Document where Name LIKE :docName limit 1][0].id;	
				}
			
			return SfInstance + '/servlet/servlet.ImageServer?id=' + idDocument  + '&oid=' + orgId ;
		}
	}
	public String NoButtonUrl{
		get {
			string SFInstance = URL.getSalesforceBaseUrl().toExternalForm();
			id orgId = UserInfo.getOrganizationId();
			String idDocument;
				if(makeVehicle.toUpperCase().contains('NISSAN')){
					String docName = 'Nissan no button';
					idDocument = [Select Id,Name from Document where Name LIKE :docName limit 1][0].id;			
				}else if(makeVehicle.toUpperCase().contains('INFINITI')){
					String docName = 'Infiniti no button';
					idDocument = [Select Id,Name from Document where Name LIKE :docName limit 1][0].id;	
				}
			
			return SfInstance + '/servlet/servlet.ImageServer?id=' + idDocument  + '&oid=' + orgId ;
		}
	}
}