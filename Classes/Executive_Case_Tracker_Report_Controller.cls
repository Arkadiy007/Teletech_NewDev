public class Executive_Case_Tracker_Report_Controller {
    //Filters
    public List < String > recordTypes { get; set; }
    public Boolean executiveFlag { get; set; }
    public Date lastModifiedDate { get; set; }

    //Case Description color flags
    public Boolean isColor {get; set;}
    //
    Map < Id, Case > casesMap = new Map < Id, Case >();
    Map<Id, List<Case_Categorization__c>> caseCategorizationsMap = new Map<Id, List<Case_Categorization__c>>();

    public List < SelectOption > recordTypesSO { get; set; }
    private transient Map < String, Schema.RecordTypeInfo > recordTypesMap { get; set; }

    public Executive_Case_Tracker_Report_Settings__c setting { get; set; }

    public Executive_Case_Tracker_Report_Controller() {
        recordTypesSO = fillRecordTypesSelectOptions();
        executiveFlag = true;
        
        //setting = getSettings();
        recordTypes = tryGetExistingRecordTypesSet();

    }
    /**
     * @description Main method which is invoked by "Generate Report" button 
     */
    public PageReference generateReport() {
        System.debug('******** recordTypes = ' + recordTypes);

        if (isValidationPassed()) {
			setRecordTypesSettings(recordTypes);
			update setting;

            List < Id > recordTypesIdsList = grtRecTypeIdsFromNames();
            Set<Id> recordTypesIdsSet = new Set<Id> (recordTypesIdsList);
            String idString = '(\'';
            for (Id thisId : recordTypesIdsList) {
                idString += thisId + '\',\'';
            }
            idString = idString.substring(0, idString.length() - 2); //<--this is the bit I hate doing
            idString += ')';

            String queryString = 'SELECT Id, Customer_Name__c, Dealer__r.Name, Servicing_Dealer_Region__c, Exec_Received_Date__c, ' +
            'Date_Closed__c, Description, Executive_Referral__c, Executive_Actions_To_Resolve__c, Vehicle_Mileage_Prior_Value__c FROM Case WHERE ';

            queryString += 'RecordTypeId IN :recordTypesIdsSet';
            queryString += ' AND Executive_Referral__c = ' + executiveFlag;
            //queryString += ' AND LastModifiedDate > ' + setting.Last_Modified_Date_Filter__c;

            System.debug('******** queryString = ' + queryString);
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, queryString));

            List <Case> cases = [SELECT Id, Customer_Name__c, Dealer__r.Name, Servicing_Dealer_Region__c, Exec_Received_Date__c, 
								Date_Closed__c, Description, Executive_Referral__c, Executive_Actions_To_Resolve__c, Vehicle_Mileage_Prior_Value__c,
								Vehicle_Name__r.Model_Name__c, Vehicle_Name__r.Model_Year__c 
								FROM Case 
								WHERE RecordTypeId IN :recordTypesIdsSet
								AND Executive_Referral__c =: executiveFlag
								AND LastModifiedDate >=: setting.Last_Modified_Date_Filter_From__c
								AND LastModifiedDate <=: setting.Last_Modified_Date_Filter_To__c];
			//Database.query(queryString);
            if (cases.size() > 0) {
                //Create Map with Ids as keys and cases as values
                casesMap = new Map < Id, Case > ();
                for (Case c : cases) {
                    casesMap.put(c.Id, c);
                }

                List < Case_Categorization__c > caseCategorizations = [SELECT Id, Case__c, Concern_Description__c, Category_Description__c FROM Case_Categorization__c WHERE Case__c IN :casesMap.keySet()];
                System.debug('******** caseCategorizations = ' + caseCategorizations);
                caseCategorizationsMap = new Map<Id, List<Case_Categorization__c>>();
                if(caseCategorizations.size() > 0) {
                    //Create Map with Case records ids as keys and Lists of Case_Categorization__c which are related to particular Case records as values
                    caseCategorizationsMap = getCaseToCaseCategorizationMap(caseCategorizations); 
                    System.debug('******** caseCategorizationsMap = ' + caseCategorizationsMap);
                }

                //ApexPages.PageReference excelPage = new ApexPages.PageReference('Executive_Case_Tracker_Report_Excel');
                PageReference pageRef = Page.Executive_Case_Tracker_Report_Excel;
                //Executive_Case_Tracker_Report_Excel_Cont excelController = new Executive_Case_Tracker_Report_Excel_Cont();
                initializeData(casesMap, caseCategorizationsMap);

                //ApexPages.PageReference excelPage = new ApexPages.PageReference('Executive_Case_Tracker_Report_Excel');

                return pageRef;
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'There isn\'t any Case records which are matched the filters criterias.'));
            }
            System.debug('******** cases = ' + cases);


            
        }
        return ApexPages.currentPage();
    }

    /**
     * @description Revert changed filters to the original state
     * @return PageReference 
     */
    public PageReference revertSettings() {
        //TODO
        return ApexPages.currentPage();
    }


    /*---------------------------------------------------------------HELPERS------------------------------------------------------------------*/
    /**
     * @description Retrieves Case Record Types and put it to Record Types select option
     * @return List<SelectOption> 
     */
    private List < SelectOption > fillRecordTypesSelectOptions() {
        recordTypesMap = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
        List < SelectOption > SO = new List < SelectOption > ();
        if (recordTypesMap.size() > 1) {
            for (String recTypeLabel : recordTypesMap.keySet()) {
                if (recordTypesMap.get(recTypeLabel).isAvailable()) {
                    SO.add(new SelectOption(recTypeLabel, recTypeLabel));
                }
            }
        }
        return SO;
    }

    /**
     * @description Tries to retrieve exixting set of Record Types names from Record Types Set 1 and 
      Record Types Set 2 fields of Executive Case Tracker Report Settings 
     * @return List<String> 
     */
    private List < String > tryGetExistingRecordTypesSet() {
        List < String > result = new List < String > ();

        try {
            result.addAll(setting.Record_Types_Set_1__c.split(','));
            result.addAll(setting.Record_Types_Set_2__c.split(','));
        } catch(Exception e) {
        }

        return result;
    }

    /**
     * @description Retrieves Default Organization Level Value of Executive_Case_Tracker_Report_Settings__c 
      or creates one
     * @return Executive_Case_Tracker_Report_Controller 
     */
    public void getSettings() {
        setting = Executive_Case_Tracker_Report_Settings__c.getOrgDefaults();
        if ((setting == null) || (setting.id == null)) {
			setting = new Executive_Case_Tracker_Report_Settings__c();
			insert setting;
			setting = Executive_Case_Tracker_Report_Settings__c.getOrgDefaults();
		}
        System.debug('********** + ' + setting);
        
    }

    /**
     * @description Fills Record_Types_Set_1__c (and Record_Types_Set_2__c if it is needed) of 
      Executive_Case_Tracker_Report_Settings__c custom setting
     * @param recTypes selected Record Types
     */
    private void setRecordTypesSettings(List < String > recTypes) {
        //TODO Optimize for filling Record_Types_Set_2__c too 
        setting.Record_Types_Set_1__c = '';
		setting.Record_Types_Set_2__c = '';
        for (String rt : recTypes) {
			if ((setting.Record_Types_Set_1__c.length() + rt.length()) <=255) {
				setting.Record_Types_Set_1__c = setting.Record_Types_Set_1__c + rt;
				if (setting.Record_Types_Set_1__c.length() < 255) {
					setting.Record_Types_Set_1__c += ',';
				}
			} else if ((setting.Record_Types_Set_2__c.length() + rt.length()) <=255) {
				setting.Record_Types_Set_2__c = setting.Record_Types_Set_2__c + rt;
				if (setting.Record_Types_Set_2__c.length() < 255) {
					setting.Record_Types_Set_2__c += ',';
				}
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Too much Record Types are selected'));
			}
        }
    }

    /**
     * @description Retrieve Ids of Selected Record Types
     */
    private List < Id > grtRecTypeIdsFromNames() {
        List < Id > result = new List < String > ();
        recordTypesMap = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
        System.debug('******** recordTypes = ' + recordTypes);
        System.debug('******** recordTypesMap = ' + recordTypesMap);
        if (null != recordTypes && null != recordTypesMap) {


            for (String rt : recordTypes) {
                //System.debug('******** recordTypesMap.get(rt).getRecordTypeId() = ' + recordTypesMap.get(rt).getRecordTypeId());
                result.add(recordTypesMap.get(rt).getRecordTypeId());
            }

            return result;
        }
        return result;
    }

    /**
     * @description Performs validation of the filters values
     * @returns True if validation is passes otherwise false 
     */
    private Boolean isValidationPassed() {
        if(!(recordTypes.size() > 0)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'At least one Record Type should be selected'));
            return false;
        } else if (null == setting.Last_Modified_Date_Filter_From__c)  {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Last Modified Date Filter From should be filled'));
            return false;
        } else if (null == setting.Last_Modified_Date_Filter_To__c)  {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Last Modified Date Filter To should be filled'));
            return false;
        }
		return true;
    }

    private Map<Id, List<Case_Categorization__c>> getCaseToCaseCategorizationMap(List<Case_Categorization__c> caseCategorizations) {
        Map<Id, List<Case_Categorization__c>> result = new  Map<Id, List<Case_Categorization__c>>();
        for (Case_Categorization__c cc : caseCategorizations) {
            if(result.containsKey(cc.Case__c)) {
                List<Case_Categorization__c> tempList = new List<Case_Categorization__c>(result.get(cc.Case__c));
                tempList.add(cc);
                result.put(cc.Case__c,tempList);
            } else {
                result.put(cc.Case__c, new List<Case_Categorization__c> {cc});
            }
        }
        return result;
    }

    /*****************************************************ExcelPage****************************************************/
	public Integer secondTableRowIndex {get; set;} 

	final static String DEFAULT_STYLE_NAME_FOR_CASE_DESCRIPTION = 'NormalTextLeftAlignment';

	final static String DEFAULT_UINDENTIFIED_REGION_NAME = 'Unidentified Region';
	final static String SOUTHEAST_REGION_NAME = 'Southeast Region';
	final static String NORTHEAST_REGION_NAME = 'Northeast Region';
	final static String MIDWEST_REGION_NAME = 'Midwest Region';
	final static String CENTRAL_REGION_NAME = 'Central Region';
	final static String WEST_REGION_NAME = 'West Region';
	final static String MOUNTAIN_REGION_NAME = 'Mountain Region';
	final static String NISSAN_MID_ATHLANTIC_REGION_NAME = 'Nissan Mid Atlantic Region';
	final static String NISSAN_NORTHWEST_REGION_NAME = 'Nissan Northwest Region';
	final static String WESTERN_REGION_NAME = 'Western Region';

	final static String INF_EAST_REGION_NAME = 'INF East  Region';
	final static String INF_WEST_REGION_NAME = 'INF West Region';
	final static String INF_NORTH_REGION_NAME = 'INF North  Region';
	final static String INF_SOUTH_REGION_NAME = 'INF South Region';

	final static String INF_EAST_REGION_STRING= 'Infiniti East Region';
	final static String INF_WEST_REGION_STRING = 'Infiniti West Region';
	final static String INF_NORTH_REGION_STRING = 'Infiniti North Region';
	final static String INF_SOUTH_REGION_STRING = 'Infiniti South Region';

	final static String DEALER_STATISTIC_NAME = 'Dealer';
	final static String CVT_STATISTIC_NAME = 'CVT';
	final static String NISSAN_DEALER_ISSUES_STRING = 'NISSAN DEALER ISSUES';

	// Strings of xml for excel which should be dynamically generated
	Public String xlsHeader {get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
	}

	public String rowFirstPart {get {
			return '<Cell ss:StyleID="NormalText"><Data ss:Type="String">';
		} set;} 
	public String rowSecondPart {get {
			return '</Data></Cell>';
		} set;} 

	public String worksheetOptionsOpenTag {get {
			return '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">';
		} set;}

	public String worksheetOptionsCloseTag {get {
			return '</WorksheetOptions>';
		} set;}
	//Highlighting
	public List<String> stylesList {get; set;}
	private Map<String, String> usersToColorsMap {get; set;}
	
	//For the last Statistic Table
	public Map<String, Integer> regionStatisticMap {get; set;}
	public Map<String, Integer> dealerAndCVTStatisticMap {get; set;}
	public String statisticString {get; set;}
	//

	public String weekDate {get; set;}
	public String myModelMileageColumnName {get; set;}
	
	//Map
    Public List<TabelRepresentation> casesReportData {get; set;}

    public void initializeData(Map <Id, Case> c, Map<Id, List<Case_Categorization__c>> cc) {
        if(null != c && !c.isEmpty()) {
            casesReportData = new List<TabelRepresentation>();
            isColor = true;
			weekDate = setting.Last_Modified_Date_Filter_From__c.format('MM/dd');
			myModelMileageColumnName = 'MY &#10; Model &#10; Mileage';

			if (null != setting && null != setting.Highlighted_Persons__c && null != setting.Highlighting_Colors__c && 
					setting.Highlighted_Persons__c.length() > 0 && setting.Highlighting_Colors__c.length() > 0) {
				//creation styles for highlighting Case Descriptions
				usersToColorsMap = retrieveHightlightedUsersToColorsMap();
				stylesList = createStylesMarkup();
			}

			//Initialize regionStatisticMap for Region Statistic and dealerAndCVTStatisticMap
			regionStatisticMap = new Map<String, Integer>{
				SOUTHEAST_REGION_NAME => 0,
				NORTHEAST_REGION_NAME => 0,
				MIDWEST_REGION_NAME => 0,
				CENTRAL_REGION_NAME => 0,
				WEST_REGION_NAME => 0,
				MOUNTAIN_REGION_NAME => 0,
				NISSAN_MID_ATHLANTIC_REGION_NAME => 0,
				NISSAN_NORTHWEST_REGION_NAME => 0,
				WESTERN_REGION_NAME => 0,
				INF_WEST_REGION_NAME => 0,
				INF_EAST_REGION_NAME => 0,
				INF_NORTH_REGION_NAME => 0,
				INF_SOUTH_REGION_NAME => 0,
				DEFAULT_UINDENTIFIED_REGION_NAME => 0
			};
			dealerAndCVTStatisticMap = new Map<String, Integer>{
				CVT_STATISTIC_NAME => 0,
				DEALER_STATISTIC_NAME => 0
			};

            for (Id i : c.keySet()) {
				String color = getColorOfCurrentCaseDescription(c.get(i));
                casesReportData.add(new TabelRepresentation(c.get(i), cc.get(i), color));

				addRegionToStatisticMap(c.get(i).Servicing_Dealer_Region__c);
				addToDealerAndCVTStatisticMap(cc.get(i)); 
            }   

			statisticString = '';
			populateStatisticString(regionStatisticMap);
			statisticString += '&#10;';
			populateStatisticString(dealerAndCVTStatisticMap);

            System.debug('******** casesReportData = ' + casesReportData);

			secondTableRowIndex = 4 + casesReportData.size() + 7;
						
        }
    }

	private String getColorOfCurrentCaseDescription (Case c) {
		//string result = '';
		if (null != usersToColorsMap && !usersToColorsMap.isEmpty()){
			for (String name : usersToColorsMap.keySet()) {
				if (c.Description.contains(name)) {
					return usersToColorsMap.get(name);
				}
			}
		}
		return DEFAULT_STYLE_NAME_FOR_CASE_DESCRIPTION;
	}
	
	/**
	* @description Method which generates style code bits for highlighting particular Case Description
	*/
	private List<String> createStylesMarkup () {
		List<String> result = new List<String>();
		List<String> colorsList = usersToColorsMap.values();

		for (String color : colorsList) {
			String style = '';
			style += '<Style ss:ID="';
			style += color;
			style += '">' +
                    '<Alignment ss:Vertical="Top" ss:Horizontal="Left" ss:WrapText="1"/ >' + 
                    '<Borders > ' +
                        '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/ >' + 
                    '</Borders > <Font ss:FontName="Calibri" x:Family="Swiss"/ >' + 
                    '<Interior ss:Color="';
			style += color;
			style += '" ss:Pattern="Solid"/ >' + 
                    '<NumberFormat/ >' +
                    '<Protection/ >' +
					'</Style>';
			result.add(style);
		}
		return result;
	}
	/**
	* @description This method splits Highlighted_Persons__c and Highlighting_Colors__c and then connect it to Map<String, String> usersToColorsMap
	*/
	private Map<String, String> retrieveHightlightedUsersToColorsMap() {
		// Split Highlighted_Persons__c
		List <String> usersList = new List <String> ();

        try {
            usersList.addAll(setting.Highlighted_Persons__c.split(','));
        } catch(Exception e) {
        } 	

		// Split Highlighting_Colors__c
		List <String> colorsList = new List <String> ();

        try {
            colorsList.addAll(setting.Highlighting_Colors__c.split(','));
        } catch(Exception e) {
        } 	

		Map<String, String> result = new Map<String, String>();
		for (Integer i = 0; i < usersList.size(); i++) {
			result.put(usersList[i], colorsList[i]);
		}

		return result;
	}
	
	class TabelRepresentation {
        public String customerName {get; set;}
        public String dealer {get; set;}
        public String region {get; set;}
        public String execRecievedDate {get; set;}
        public String dateClosed {get; set;}
        public String myModelMileage {get; set;}
        public String concernDescription {get; set;}
        public String subcategoryDescription {get; set;}
        public String caseDescriptionWithXMLMarkup {get; set;}
        public String executiveActionsToResolve {get; set;}
		//public String 

        public TabelRepresentation(Case c, List<Case_Categorization__c> cc, String highlightColor) {
            this.customerName = c.Customer_Name__c;
			this.dealer = c.Dealer__r.Name;
			this.region = c.Servicing_Dealer_Region__c;
			if (null != c.Exec_Received_Date__c) {
				this.execRecievedDate = c.Exec_Received_Date__c.format();
			}
			if (null != c.Date_Closed__c) {
				this.dateClosed = c.Date_Closed__c.format('MM/dd/yyyy');
			}
            this.myModelMileage = c.Vehicle_Name__r.Model_Year__c + '&#10;' + c.Vehicle_Name__r.Model_Name__c + '&#10;' + c.Vehicle_Mileage_Prior_Value__c;
            this.concernDescription = '';
            this.subcategoryDescription = '';
            if(null != cc && cc.size() > 0) {
                for(Case_Categorization__c caseCat : cc) {
                    this.concernDescription += caseCat.Concern_Description__c + '&#10;';
                    this.subcategoryDescription += caseCat.Category_Description__c + '&#10;';
                }
            }

            this.caseDescriptionWithXMLMarkup = createCaseDescriptionMarkup(highlightColor, c.Description);
            this.executiveActionsToResolve = c.Executive_Actions_To_Resolve__c;
        }

		private String createCaseDescriptionMarkup (String color,  String caseDescr){
			String result = '';
			result += '<Cell ss:StyleID="';
			result += color;
			result += '"><Data ss:Type="String">';
			result += caseDescr;
			result += '</Data></Cell>';

			return result;
		}
	}

	/**************************Helpers*************************/
	/**
	* @description Calculate region statistic for the last table
	* @param region 
	*/
	private void addRegionToStatisticMap(String region) {
		System.debug('************* regionStatisticMap = ' + regionStatisticMap);
		if(null == region || region.length() == 0) {
			regionStatisticMap.put(DEFAULT_UINDENTIFIED_REGION_NAME, regionStatisticMap.get(DEFAULT_UINDENTIFIED_REGION_NAME) + 1);
		} else if (region.equalsIgnoreCase(SOUTHEAST_REGION_NAME)) {
			regionStatisticMap.put(SOUTHEAST_REGION_NAME, regionStatisticMap.get(SOUTHEAST_REGION_NAME) + 1);
		} else if (region.equalsIgnoreCase(NORTHEAST_REGION_NAME)) {
			regionStatisticMap.put(NORTHEAST_REGION_NAME, regionStatisticMap.get(NORTHEAST_REGION_NAME) + 1);
		} else if (region.equalsIgnoreCase(MIDWEST_REGION_NAME)) {
			regionStatisticMap.put(MIDWEST_REGION_NAME, regionStatisticMap.get(MIDWEST_REGION_NAME) + 1);
		} else if (region.equalsIgnoreCase(CENTRAL_REGION_NAME)) {
			regionStatisticMap.put(CENTRAL_REGION_NAME, regionStatisticMap.get(CENTRAL_REGION_NAME) + 1);
		} else if (region.equalsIgnoreCase(WEST_REGION_NAME)) {
			regionStatisticMap.put(WEST_REGION_NAME, regionStatisticMap.get(WEST_REGION_NAME) + 1);
		} else if (region.equalsIgnoreCase(MOUNTAIN_REGION_NAME)) {
			regionStatisticMap.put(MOUNTAIN_REGION_NAME, regionStatisticMap.get(MOUNTAIN_REGION_NAME) + 1);
		} else if (region.equalsIgnoreCase(NISSAN_MID_ATHLANTIC_REGION_NAME)) {
			regionStatisticMap.put(NISSAN_MID_ATHLANTIC_REGION_NAME, regionStatisticMap.get(NISSAN_MID_ATHLANTIC_REGION_NAME) + 1);
		} else if (region.equalsIgnoreCase(NISSAN_NORTHWEST_REGION_NAME)) {
			regionStatisticMap.put(NISSAN_NORTHWEST_REGION_NAME, regionStatisticMap.get(NISSAN_NORTHWEST_REGION_NAME) + 1);
		} else if (region.equalsIgnoreCase(WESTERN_REGION_NAME)) {
			regionStatisticMap.put(WESTERN_REGION_NAME, regionStatisticMap.get(WESTERN_REGION_NAME) + 1);
		} else if (region.equalsIgnoreCase(INF_EAST_REGION_STRING)) {
			regionStatisticMap.put(INF_EAST_REGION_NAME, regionStatisticMap.get(INF_EAST_REGION_NAME) + 1);
		} else if (region.equalsIgnoreCase(INF_WEST_REGION_STRING)) {
			regionStatisticMap.put(INF_WEST_REGION_NAME, regionStatisticMap.get(INF_WEST_REGION_NAME) + 1);
		} else if (region.equalsIgnoreCase(INF_NORTH_REGION_STRING)) {
			regionStatisticMap.put(INF_NORTH_REGION_NAME, regionStatisticMap.get(INF_NORTH_REGION_NAME) + 1);
		} else if (region.equalsIgnoreCase(INF_SOUTH_REGION_STRING)) {
			regionStatisticMap.put(INF_SOUTH_REGION_NAME, regionStatisticMap.get(INF_SOUTH_REGION_NAME) + 1);
		} else {
			regionStatisticMap.put(DEFAULT_UINDENTIFIED_REGION_NAME, regionStatisticMap.get(DEFAULT_UINDENTIFIED_REGION_NAME)+ 1);
		}
	}

	private void addToDealerAndCVTStatisticMap(List<Case_Categorization__c> caseCategorezations) {
		if(null != caseCategorezations && caseCategorezations.size() > 0) {
			//List<String> concatStr = concern + category;
			for (Case_Categorization__c caseCategor : caseCategorezations) {
				if (caseCategor.Category_Description__c.contains(CVT_STATISTIC_NAME)) {
					dealerAndCVTStatisticMap.put(CVT_STATISTIC_NAME, dealerAndCVTStatisticMap.get(CVT_STATISTIC_NAME) + 1);
				} 
				if(caseCategor.Concern_Description__c.contains(NISSAN_DEALER_ISSUES_STRING)) {
					dealerAndCVTStatisticMap.put(DEALER_STATISTIC_NAME, dealerAndCVTStatisticMap.get(DEALER_STATISTIC_NAME) + 1);
				}
			}
		}
	}

	/**
	* @description 
	* @param statisticMap 
	*/
	public void populateStatisticString(Map<String, Integer> statisticMap) {
		for (String key : statisticMap.keySet()) {
			statisticString += key + ': ' + statisticMap.get(key) + '&#10;';
		}
	}
	   
}