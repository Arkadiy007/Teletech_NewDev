/**********************************************************************
Name: CSVHandler
Copyright © notice: Nissan Motor Company.
======================================================
Purpose
Helper class for serialization and deserialization of sObjects to CSV format
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Vlad Martynenko 01/08/2015 Created
***********************************************************************/
public class CSVHandler{

	// Encodes list of objects into the .csv formated string
	public static String getEncodedCsvByObjectType(List<Schema.SObjectField> fields, List<sObject> objects){		
		String csvResult = '';

		for(Schema.SObjectField field : fields){
		 String name = field.getDescribe().getName();
		 if(csvResult != '') {
			csvResult += ',';
		 }

			csvResult += name.escapeCsv();
		}
		
		csvResult += '\r\n';

		for(sObject obj : objects){
		 string lineValue = '';
		 Integer counter = 0;
			for(Schema.SObjectField field : fields){
				if(counter > 0) {
				lineValue += ',';
			}

			if(obj.get(field) !=null) {
				lineValue += String.valueOf(obj.get(field)).escapeCsv();
			}
			counter += 1;
		 }
		 csvResult += lineValue;
		 csvResult += '\r\n';
		}

		return encodedCsv(csvResult);
	}

	// Parses string formated as .csv to the list of object records
	public static List<sObject> getDecodedObjectsFromCsv(String encodedCsv, String objectType){
		List<sObject> result = new List<sObject>();
		
		String decodedCsv = decodeCsv(encodedCsv);
		
		SSSCsvReader reader = new SSSCsvReader(decodedCsv);
		String[] header = reader.readLine();
		Boolean isFileParsed = false;
		Map<String,DescribeFieldResult> fields = getFields(objectType);
		Integer columnsCount = header.size();

		while(!isFileParsed){
			String[] row = reader.readLine();
			if(row !=null){
				sObject resObject = (sObject) Type.forName(objectType).newInstance();
				for(Integer i = 0; i < columnsCount; i++){
					String field = header.get(i);
					DescribeFieldResult fieldDescribe = fields.get(field);
					if(fieldDescribe != null && fieldDescribe.isUpdateable()){
						Object value = convertValue(fieldDescribe, row.get(i));
						resObject.put(field,value);
					}
				}

				result.add(resObject);
			}
			else{
				isFileParsed = true;
			}
		}

		return result;
	}

// Parses string formated as .csv to the list of object records
	public static List<CaseWrapper> getDecodedCasesFromCsv(String encodedCsv) {
		List<CaseWrapper> result = new List<CaseWrapper> ();

		String decodedCsv = decodeCsv(encodedCsv);
		CaseWrapper wrapperFactory = new CaseWrapper();


		SSSCsvReader reader = new SSSCsvReader(decodedCsv);
		String[] header = reader.readLine();
		Boolean isFileParsed = false;
		Integer columnsCount = header.size();

		while (!isFileParsed) {
			String[] row = reader.readLine();

			if (row != null) {
				Map<String, String> fieldsWithValues = new Map<String, String>();
				for (Integer i = 0; i < columnsCount; i++) {
					String field = header.get(i);
					if(row.size() > i){
						fieldsWithValues.put(field, row.get(i));
					}
				}
				
				if(!fieldsWithValues.isEmpty()){
					result.add(wrapperFactory.generate(fieldsWithValues));
				}
			}
			else {
				isFileParsed = true;
			}
		}

		return result;
	}

	// Encodes string into Base64 format
	private static String encodedCsv(String csvResult){
		Blob csvBlob = Blob.valueOf(csvResult);
		return EncodingUtil.base64Encode(csvBlob);
	}

	// Decodes string from base64 to the original format
	private static String decodeCsv(String base64Encoded){
		Blob decodedBlob = EncodingUtil.base64Decode(base64Encoded);
		return decodedBlob.toString();
	}

	// Check that field is Null or Emty
	public static Boolean IsEmptyOrBlank(String value) {
		return value == null || value == '';
	}

	// Converts field value based on definition described in DescribeFieldResult
	@testVisible public static Object convertValue(DescribeFieldResult resultField, Object data) {
    Object result;
    Schema.DisplayType resultType = resultField.getType();
    String value = String.valueOf(data);
    try {
      if (resultType == Schema.DisplayType.DATETIME) {
        try {
          result = (!IsEmptyOrBlank(value)) ? DateTime.valueOf(value) : null;
        } catch(Exception e) {
          result = JSON.deserialize('"' + value + '"', DateTime.class);
        }
      } else if (resultType == Schema.DisplayType.DATE) {
        try {
          result = (!IsEmptyOrBlank(value)) ? Date.valueOf(value) : null;
        } catch(Exception e) {
          DateTime dt = (DateTime) JSON.deserialize('"' + value + '"', DateTime.class);
          result = date.newInstance(dt.Year(), dt.Month(), dt.Day());
        }
      } else if (resultType == Schema.DisplayType.BOOLEAN) {
        result = (!IsEmptyOrBlank(value)) ? Boolean.valueOf(value) : null;
      } else if (resultType == Schema.DisplayType.INTEGER) {
        result = (!IsEmptyOrBlank(value)) ? Integer.valueOf(value) : null;
      } else if ((resultType == Schema.DisplayType.DOUBLE) ||
      (resultType == Schema.DisplayType.PERCENT)) {
        result = (!IsEmptyOrBlank(value)) ? Double.valueOf(value) : null;
      } else if (resultType == Schema.DisplayType.CURRENCY) {
        result = (!IsEmptyOrBlank(value)) ? Decimal.valueOf(value) : null;
      } else if ((resultType == Schema.DisplayType.STRING) ||
      (resultType == Schema.DisplayType.TEXTAREA) ||
      (resultType == Schema.DisplayType.PICKLIST) ||
      (resultType == Schema.DisplayType.ID) ||
      (resultType == Schema.DisplayType.PHONE) ||
      (resultType == Schema.DisplayType.EMAIL) ||
      (resultType == Schema.DisplayType.URL)) {
        if (!IsEmptyOrBlank(value)) {
          final Integer length = resultField.getLength();
          result = (value.length() > length) ? value.substring(0, length) : value;
        } else {
          result = null;
        }
      } else {
      }
    } catch(Exception ex) {

    }

    return result;
  }

  // get all fields for the particular object type
  public static Map<String,DescribeFieldResult> getFields(String objectName) {

    Map<String,DescribeFieldResult> result = new Map<String,DescribeFieldResult> ();

    try {
      Map<String,Schema.SObjectField> fields = Schema.describeSObjects(new String[] { objectName }) [0].fields.getMap();

      for (String key : fields.keySet()) {
        final DescribeFieldResult fieldDescribe = fields.get(key).getDescribe();
        result.put(fieldDescribe.getName(), fieldDescribe);
      }
    } catch(Exception ex) {
      // no such object - return an empty list
    }

    return result;
  }

	public class CaseWrapper{
		public String country {get; set;}
		public String dealer_code {get; set;}
		public String district_code {get; set;}
		public String regiona {get; set;}
		public String age {get; set;}
		public String subject {get; set;}
		public String bose_or_surround_sound {get; set;}
		public String model_year {get; set;}
		public String model_variation {get; set;}
		public String model_name {get; set;}
		public String model_line {get; set;}
		public String manufacture_date {get; set;}
		public String engine {get; set;}
		public String make {get; set;}
		public String head_unit {get; set;}
		public String symptom_action {get; set;}
		public String symptomatic_object {get; set;}

		public CaseWrapper(){}

		public CaseWrapper generate(Map<String, String> fieldsAndValues){
			return (CaseWrapper) JSON.deserialize(JSON.serialize(fieldsAndValues), CaseWrapper.class);
		}
	}

}