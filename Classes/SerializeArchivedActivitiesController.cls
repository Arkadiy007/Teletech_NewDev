public class SerializeArchivedActivitiesController {
	public String fileResult {get;set;}

    public SerializeArchivedActivitiesController() {
		String objType = 'Case';
		Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
		Schema.SObjectType sobjType = gd.get(objType); 
		Schema.DescribeSObjectResult describeResult = sobjType.getDescribe(); 
		List<Schema.SObjectField> fields = describeResult.fields.getMap().values();
		
		String request ='';
		
		for(Schema.SObjectField field : fields){
		 String name = field.getDescribe().getName();
		 if(request != '') {
			request += ',';
		 }
		 request += name;
		}
		
		String query =String.Format('SELECT {0} FROM {1} {2}', new List<String>{request, objType, 'Limit 6'});
		
		List<sObject> objects = Database.query(query);
		
		String csvResult = CSVHandler.getEncodedCsvByObjectType(fields, objects);

		Blob decodedBlob = EncodingUtil.base64Decode(csvResult);
		fileResult = decodedBlob.toString();
    }
}