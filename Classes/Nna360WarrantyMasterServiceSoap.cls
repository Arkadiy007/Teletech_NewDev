//Generated by wsdl2apex

public class Nna360WarrantyMasterServiceSoap {
    public class WarrantyExclusions {
        public String WarrantyExclusionCode;
        public String WarrantyExclusionDescription;
        private String[] WarrantyExclusionCode_type_info = new String[]{'WarrantyExclusionCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] WarrantyExclusionDescription_type_info = new String[]{'WarrantyExclusionDescription','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/WarrantyMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'WarrantyExclusionCode','WarrantyExclusionDescription'};
    }
    public class VehicleCoverage_Input {
        public String[] Vin;
        private String[] Vin_type_info = new String[]{'Vin','http://www.w3.org/2001/XMLSchema','string','1','10','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/WarrantyMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'Vin'};
    }
    public class ApplicableWarrantyType {
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/WarrantyMasterService','false','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class BrandedInfo {
        public String StateCode;
        public String ModelYear;
        public String SourceRecordDate;
        public String RecordTypeCode;
        public String PolkRunDate;
        public String SourceIDCode;
        public String BrandedCode;
        public String DuplicateCode;
        public String TitleNumber;
        public String BrandedDescription;
        public String OverrideExpirationDate;
        public String SourceLastUpdateDate;
        private String[] StateCode_type_info = new String[]{'StateCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ModelYear_type_info = new String[]{'ModelYear','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] SourceRecordDate_type_info = new String[]{'SourceRecordDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] RecordTypeCode_type_info = new String[]{'RecordTypeCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PolkRunDate_type_info = new String[]{'PolkRunDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] SourceIDCode_type_info = new String[]{'SourceIDCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] BrandedCode_type_info = new String[]{'BrandedCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DuplicateCode_type_info = new String[]{'DuplicateCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] TitleNumber_type_info = new String[]{'TitleNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] BrandedDescription_type_info = new String[]{'BrandedDescription','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] OverrideExpirationDate_type_info = new String[]{'OverrideExpirationDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] SourceLastUpdateDate_type_info = new String[]{'SourceLastUpdateDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/WarrantyMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'StateCode','ModelYear','SourceRecordDate','RecordTypeCode','PolkRunDate','SourceIDCode','BrandedCode','DuplicateCode','TitleNumber','BrandedDescription','OverrideExpirationDate','SourceLastUpdateDate'};
    }
    public class WarrantyMasterService_IG_VehicleWarrantyCoverageServiceHttpPort {
        public String endpoint_x = System.label.Nna360_EndPoint_Warranty;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/WarrantyMasterService', 'Nna360WarrantyMasterServiceSoap'};
        public Nna360WarrantyMasterServiceSoap.VehicleCoverage[] getVehicleCoverageData(String[] Vin) {
            Nna360WarrantyMasterServiceSoap.VehicleCoverage_Input request_x = new Nna360WarrantyMasterServiceSoap.VehicleCoverage_Input();
            Nna360WarrantyMasterServiceSoap.VehicleCoverage_Output response_x;
            request_x.Vin = Vin;
            Map<String, Nna360WarrantyMasterServiceSoap.VehicleCoverage_Output> response_map_x = new Map<String, Nna360WarrantyMasterServiceSoap.VehicleCoverage_Output>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://xmlns.nissan.com/scm/nna/WarrantyMasterService',
              'getVehicleCoverageDataRequest',
              'http://xmlns.nissan.com/scm/nna/WarrantyMasterService',
              'getVehicleCoverageDataResponse',
              'Nna360WarrantyMasterServiceSoap.VehicleCoverage_Output'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.VehicleCoverageData;
        }
    }
    public class VehicleCoverage {
        public String Vin;
        public Nna360WarrantyMasterServiceSoap.ApplicableWarranty[] ApplicableWarrantyData;
        public Nna360WarrantyMasterServiceSoap.WarrantyExclusions[] WarrantyExclusionsData;
        public Nna360WarrantyMasterServiceSoap.BrandedInfo[] BrandedInfoData;
        private String[] Vin_type_info = new String[]{'Vin','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] ApplicableWarrantyData_type_info = new String[]{'ApplicableWarrantyData','http://xmlns.nissan.com/scm/nna/WarrantyMasterService','ApplicableWarranty','0','-1','false'};
        private String[] WarrantyExclusionsData_type_info = new String[]{'WarrantyExclusionsData','http://xmlns.nissan.com/scm/nna/WarrantyMasterService','WarrantyExclusions','0','-1','false'};
        private String[] BrandedInfoData_type_info = new String[]{'BrandedInfoData','http://xmlns.nissan.com/scm/nna/WarrantyMasterService','BrandedInfo','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/WarrantyMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'Vin','ApplicableWarrantyData','WarrantyExclusionsData','BrandedInfoData'};
    }
    public class ApplicableWarranty {
        public String WarrantyDescription;
        public String WarrantyExpirationDate;
        public String WarrantyExpirationMiles;
        private String[] WarrantyDescription_type_info = new String[]{'WarrantyDescription','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] WarrantyExpirationDate_type_info = new String[]{'WarrantyExpirationDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] WarrantyExpirationMiles_type_info = new String[]{'WarrantyExpirationMiles','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/WarrantyMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'WarrantyDescription','WarrantyExpirationDate','WarrantyExpirationMiles'};
    }
    public class VehicleCoverage_Output {
        public Nna360WarrantyMasterServiceSoap.VehicleCoverage[] VehicleCoverageData;
        private String[] VehicleCoverageData_type_info = new String[]{'VehicleCoverageData','http://xmlns.nissan.com/scm/nna/WarrantyMasterService','VehicleCoverage','0','10','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.nissan.com/scm/nna/WarrantyMasterService','false','false'};
        private String[] field_order_type_info = new String[]{'VehicleCoverageData'};
    }
}