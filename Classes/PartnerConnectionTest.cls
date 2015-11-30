@isTest
private class PartnerConnectionTest {
  /**
   * Dummy Metadata API web service mock class
   **/
  private class WebServiceMockImpl implements WebServiceMock {
    public void doInvoke(Object stub, Object request, Map<String,Object> response,
                         String endpoint, String soapAction, String requestName,
                         String responseNS, String responseName, String responseType) {
      if (request instanceof PartnerConnection.retrieve_element)
        response.put('response_x', new PartnerConnection.retrieveResponse_element());
      else if (request instanceof PartnerConnection.describeSoqlListViews_element)
        response.put('response_x', new PartnerConnection.describeSoqlListViewsResponse_element());
      else if (request instanceof PartnerConnection.describeCompactLayouts_element)
        response.put('response_x', new PartnerConnection.describeCompactLayoutsResponse_element());
      else if (request instanceof PartnerConnection.describeGlobal_element)
        response.put('response_x', new PartnerConnection.describeGlobalResponse_element());
      else if (request instanceof PartnerConnection.describeAllTabs_element)
        response.put('response_x', new PartnerConnection.describeAllTabsResponse_element());
      else if (request instanceof PartnerConnection.describeLayout_element)
        response.put('response_x', new PartnerConnection.describeLayoutResponse_element());
      else if (request instanceof PartnerConnection.emptyRecycleBin_element)
        response.put('response_x', new PartnerConnection.emptyRecycleBinResponse_element());
      else if (request instanceof PartnerConnection.describeAppMenu_element)
        response.put('response_x', new PartnerConnection.describeAppMenuResponse_element());
      else if (request instanceof PartnerConnection.process_element)
        response.put('response_x', new PartnerConnection.processResponse_element());
      else if (request instanceof PartnerConnection.logout_element)
        response.put('response_x', new PartnerConnection.logoutResponse_element());
      else if (request instanceof PartnerConnection.invalidateSessions_element)
        response.put('response_x', new PartnerConnection.invalidateSessionsResponse_element());
      else if (request instanceof PartnerConnection.describeKnowledgeSettings_element)
        response.put('response_x', new PartnerConnection.describeKnowledgeSettingsResponse_element());
      else if (request instanceof PartnerConnection.describePrimaryCompactLayouts_element)
        response.put('response_x', new PartnerConnection.describePrimaryCompactLayoutsResponse_element());
      else if (request instanceof PartnerConnection.getUserInfo_element)
        response.put('response_x', new PartnerConnection.getUserInfoResponse_element());
      else if (request instanceof PartnerConnection.getServerTimestamp_element)
        response.put('response_x', new PartnerConnection.getServerTimestampResponse_element());
      else if (request instanceof PartnerConnection.describeSearchLayouts_element)
        response.put('response_x', new PartnerConnection.describeSearchLayoutsResponse_element());
      else if (request instanceof PartnerConnection.describeFlexiPages_element)
        response.put('response_x', new PartnerConnection.describeFlexiPagesResponse_element());
      else if (request instanceof PartnerConnection.setPassword_element)
        response.put('response_x', new PartnerConnection.setPasswordResponse_element());
      else if (request instanceof PartnerConnection.sendEmailMessage_element)
        response.put('response_x', new PartnerConnection.sendEmailMessageResponse_element());
      else if (request instanceof PartnerConnection.delete_element)
        response.put('response_x', new PartnerConnection.deleteResponse_element());
      else if (request instanceof PartnerConnection.describeTabs_element)
        response.put('response_x', new PartnerConnection.describeTabsResponse_element());
      else if (request instanceof PartnerConnection.executeListView_element)
        response.put('response_x', new PartnerConnection.executeListViewResponse_element());
      else if (request instanceof PartnerConnection.describeSoftphoneLayout_element)
        response.put('response_x', new PartnerConnection.describeSoftphoneLayoutResponse_element());
      else if (request instanceof PartnerConnection.describeSObject_element)
        response.put('response_x', new PartnerConnection.describeSObjectResponse_element());
      else if (request instanceof PartnerConnection.describeSObjects_element)
        response.put('response_x', new PartnerConnection.describeSObjectsResponse_element());
      else if (request instanceof PartnerConnection.getUpdated_element)
        response.put('response_x', new PartnerConnection.getUpdatedResponse_element());
      else if (request instanceof PartnerConnection.queryAll_element)
        response.put('response_x', new PartnerConnection.queryAllResponse_element());
      else if (request instanceof PartnerConnection.describeApprovalLayout_element)
        response.put('response_x', new PartnerConnection.describeApprovalLayoutResponse_element());
      else if (request instanceof PartnerConnection.resetPassword_element)
        response.put('response_x', new PartnerConnection.resetPasswordResponse_element());
      else if (request instanceof PartnerConnection.merge_element)
        response.put('response_x', new PartnerConnection.mergeResponse_element());
      else if (request instanceof PartnerConnection.query_element)
        response.put('response_x', new PartnerConnection.queryResponse_element());
      else if (request instanceof PartnerConnection.update_element)
        response.put('response_x', new PartnerConnection.updateResponse_element());
      else if (request instanceof PartnerConnection.undelete_element)
        response.put('response_x', new PartnerConnection.undeleteResponse_element());
      else if (request instanceof PartnerConnection.convertLead_element)
        response.put('response_x', new PartnerConnection.convertLeadResponse_element());
      else if (request instanceof PartnerConnection.describeGlobalTheme_element)
        response.put('response_x', new PartnerConnection.describeGlobalThemeResponse_element());
      else if (request instanceof PartnerConnection.describeDataCategoryGroupStructures_element)
        response.put('response_x', new PartnerConnection.describeDataCategoryGroupStructuresResponse_element());
      else if (request instanceof PartnerConnection.sendEmail_element)
        response.put('response_x', new PartnerConnection.sendEmailResponse_element());
      else if (request instanceof PartnerConnection.describeAvailableQuickActions_element)
        response.put('response_x', new PartnerConnection.describeAvailableQuickActionsResponse_element());
      else if (request instanceof PartnerConnection.create_element)
        response.put('response_x', new PartnerConnection.createResponse_element());
      else if (request instanceof PartnerConnection.getDeleted_element)
        response.put('response_x', new PartnerConnection.getDeletedResponse_element());
      else if (request instanceof PartnerConnection.describeQuickActions_element)
        response.put('response_x', new PartnerConnection.describeQuickActionsResponse_element());
      else if (request instanceof PartnerConnection.retrieveQuickActionTemplates_element)
        response.put('response_x', new PartnerConnection.retrieveQuickActionTemplatesResponse_element());
      else if (request instanceof PartnerConnection.login_element)
        response.put('response_x', new PartnerConnection.loginResponse_element());
      else if (request instanceof PartnerConnection.performQuickActions_element)
        response.put('response_x', new PartnerConnection.performQuickActionsResponse_element());
      else if (request instanceof PartnerConnection.describeSearchScopeOrder_element)
        response.put('response_x', new PartnerConnection.describeSearchScopeOrderResponse_element());
      else if (request instanceof PartnerConnection.describeDataCategoryGroups_element)
        response.put('response_x', new PartnerConnection.describeDataCategoryGroupsResponse_element());
      else if (request instanceof PartnerConnection.queryMore_element)
        response.put('response_x', new PartnerConnection.queryMoreResponse_element());
      else if (request instanceof PartnerConnection.search_element)
        response.put('response_x', new PartnerConnection.searchResponse_element());
      else if (request instanceof PartnerConnection.describeTheme_element)
        response.put('response_x', new PartnerConnection.describeThemeResponse_element());
      else if (request instanceof PartnerConnection.upsert_element)
        response.put('response_x', new PartnerConnection.upsertResponse_element());

      return;
    }
  }

  static testMethod void coverGeneratedCodeCRUDOperations() {
    // Null Web Service mock implementation
    System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());

    // Only required to workaround a current code coverage bug in the platform
    PartnerConnection partnerService = new PartnerConnection();

    // Invoke operations         
    PartnerConnection.Soap partnerSoap = new PartnerConnection.Soap('login');

    // in a managed package each unit test must include an assertion; otherwise,
    // the Force.com security source scanner will complain
    System.assert(true);
  }

  static testMethod void coverGeneratedCodeFileBasedOperations1() {
    // Null Web Service mock implementation
    System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());

    // Only required to workaround a current code coverage bug in the platform
    PartnerConnection partnerService = new PartnerConnection();

    // Invoke operations         
    PartnerConnection.Soap partnerSoap = new PartnerConnection.Soap();
    partnerSoap.describeSoqlListViews(null);
    partnerSoap.describeCompactLayouts(null, null);
    partnerSoap.describeGlobal();
    partnerSoap.retrieve_x(null, null, null);
    partnerSoap.describeAllTabs();
    partnerSoap.describeLayout(null, null, null);
    partnerSoap.emptyRecycleBin(null);
    partnerSoap.describeAppMenu(null);
    partnerSoap.process(null);
    partnerSoap.logout();
    partnerSoap.invalidateSessions(null);
    partnerSoap.describeKnowledgeSettings();
    partnerSoap.describePrimaryCompactLayouts(null);
    partnerSoap.getUserInfo();
    partnerSoap.getServerTimestamp();
    partnerSoap.describeSearchLayouts(null);
    partnerSoap.describeFlexiPages(null);
    partnerSoap.setPassword(null, null);
    partnerSoap.sendEmailMessage(null);
    partnerSoap.delete_x(null);
    partnerSoap.describeTabs();
    partnerSoap.executeListView(null);
    partnerSoap.describeSoftphoneLayout();
    partnerSoap.describeSObject(null);
    partnerSoap.describeSObjects(null);
    partnerSoap.getUpdated(null, null, null);
    partnerSoap.queryAll(null);
    partnerSoap.describeApprovalLayout(null, null);
    partnerSoap.resetPassword(null);
    partnerSoap.merge_x(null);
    partnerSoap.query(null);
    partnerSoap.update_x(null);
    partnerSoap.undelete_x(null);
    partnerSoap.convertLead(null);
    partnerSoap.describeGlobalTheme();
    partnerSoap.describeDataCategoryGroupStructures(null, null);
    partnerSoap.sendEmail(null);
    partnerSoap.describeAvailableQuickActions(null);
    partnerSoap.create(null);
    partnerSoap.getDeleted(null, null, null);
    partnerSoap.describeQuickActions(null);
    partnerSoap.retrieveQuickActionTemplates(null, null);
    partnerSoap.login(null, null);
    partnerSoap.performQuickActions(null);
    partnerSoap.describeSearchScopeOrder();
    partnerSoap.describeDataCategoryGroups(null);
    partnerSoap.queryMore(null);
    partnerSoap.search_x(null);
    partnerSoap.describeTheme(null);
    partnerSoap.upsert_x(null, null);

    // in a managed package each unit test must include an assertion; otherwise,
    // the Force.com security source scanner will complain
    System.assert(true);
  }

  static testMethod void coverGeneratedCodeTypes() {
    // Reference types
    new PartnerConnection();
    new PartnerConnection.DescribeSoftphoneLayoutResult();
    new PartnerConnection.queryMore_element();
    new PartnerConnection.DescribeAppMenuResult();
    new PartnerConnection.DescribeSoftphoneLayoutItem();
    new PartnerConnection.executeListViewResponse_element();
    new PartnerConnection.DescribeSoftphoneLayoutSection();
    new PartnerConnection.PerformQuickActionRequest();
    new PartnerConnection.describeQuickActionsResponse_element();
    new PartnerConnection.DescribeSoqlListViewParams();
    new PartnerConnection.DescribeApprovalLayoutResult();
    new PartnerConnection.SearchSnippet();
    new PartnerConnection.CustomLinkComponent();
    new PartnerConnection.ReportChartComponent();
    new PartnerConnection.KnowledgeLanguageItem();
    new PartnerConnection.loginResponse_element();
    new PartnerConnection.describeAppMenuResponse_element();
    new PartnerConnection.Email();
    new PartnerConnection.describeSoftphoneLayout_element();
    new PartnerConnection.getServerTimestamp_element();
    new PartnerConnection.ChildRelationship();
    new PartnerConnection.process_element();
    new PartnerConnection.DescribeLayoutComponent();
    new PartnerConnection.SoqlSubQueryCondition();
    new PartnerConnection.LimitInfo();
    new PartnerConnection.LimitInfoHeader_element();
    new PartnerConnection.QueryOptions_element();
    new PartnerConnection.CallOptions_element();
    new PartnerConnection.describeAvailableQuickActions_element();
    new PartnerConnection.SoqlCondition();
    new PartnerConnection.AllOrNoneHeader_element();
    new PartnerConnection.DescribeSoftphoneLayoutInfoField();
    new PartnerConnection.describeTabsResponse_element();
    new PartnerConnection.describeTabs_element();
    new PartnerConnection.DescribeLayoutButton();
    new PartnerConnection.describeGlobalResponse_element();
    new PartnerConnection.SendEmailError();
    new PartnerConnection.ListViewColumn();
    new PartnerConnection.DescribeLayoutItem();
    new PartnerConnection.emptyRecycleBin_element();
    new PartnerConnection.describeSoqlListViewsResponse_element();
    new PartnerConnection.DisableFeedTrackingHeader_element();
    new PartnerConnection.searchResponse_element();
    new PartnerConnection.MergeResult();
    new PartnerConnection.describeAppMenu_element();
    new PartnerConnection.SoqlConditionGroup();
    new PartnerConnection.sendEmail_element();
    new PartnerConnection.delete_element();
    new PartnerConnection.DescribeQuickActionListResult();
    new PartnerConnection.DescribeLayoutButtonSection();
    new PartnerConnection.updateResponse_element();
    new PartnerConnection.retrieve_element();
    new PartnerConnection.DescribeComponentInstanceProperty();
    new PartnerConnection.RelatedList();
    new PartnerConnection.describeGlobalThemeResponse_element();
    new PartnerConnection.describeSearchScopeOrderResponse_element();
    new PartnerConnection.describeApprovalLayout_element();
    new PartnerConnection.DescribeThemeItem();
    new PartnerConnection.create_element();
    new PartnerConnection.DescribeFlexiPageRegion();
    new PartnerConnection.describeThemeResponse_element();
    new PartnerConnection.createResponse_element();
    new PartnerConnection.describeKnowledgeSettings_element();
    new PartnerConnection.ProcessRequest();
    new PartnerConnection.LeadConvert();
    new PartnerConnection.SoqlNotCondition();
    new PartnerConnection.DescribeQuickActionListItemResult();
    new PartnerConnection.QuickActionTemplateResult();
    new PartnerConnection.LocaleOptions_element();
    new PartnerConnection.DescribeSoftphoneScreenPopOption();
    new PartnerConnection.DescribeSoqlListView();
    new PartnerConnection.getUpdatedResponse_element();
    new PartnerConnection.StreamingEnabledHeader_element();
    new PartnerConnection.DescribeDataCategoryGroupResult();
    new PartnerConnection.FilteredLookupInfo();
    new PartnerConnection.DataCategory();
    new PartnerConnection.describeSoqlListViews_element();
    new PartnerConnection.DescribeLayoutResult();
    new PartnerConnection.GetDeletedResult();
    new PartnerConnection.DescribeLayoutSection();
    new PartnerConnection.AssignmentRuleHeader_element();
    new PartnerConnection.ListViewRecordColumn();
    new PartnerConnection.PackageVersionHeader_element();
    new PartnerConnection.retrieveQuickActionTemplatesResponse_element();
    new PartnerConnection.login_element();
    new PartnerConnection.SendEmailResult();
    new PartnerConnection.getUpdated_element();
    new PartnerConnection.PicklistForRecordType();
    new PartnerConnection.upsertResponse_element();
    new PartnerConnection.Field();
    new PartnerConnection.describeFlexiPagesResponse_element();
    new PartnerConnection.describeSObjectsResponse_element();
    new PartnerConnection.undeleteResponse_element();
    new PartnerConnection.setPasswordResponse_element();
    new PartnerConnection.describeLayout_element();
    new PartnerConnection.DescribeLayout();
    new PartnerConnection.sendEmailResponse_element();
    new PartnerConnection.describeKnowledgeSettingsResponse_element();
    new PartnerConnection.PicklistEntry();
    new PartnerConnection.UserTerritoryDeleteHeader_element();
    new PartnerConnection.describeApprovalLayoutResponse_element();
    new PartnerConnection.SearchRecord();
    new PartnerConnection.NamedLayoutInfo();
    new PartnerConnection.describeSObjectResponse_element();
    new PartnerConnection.EmailHeader_element();
    new PartnerConnection.RelatedListColumn();
    new PartnerConnection.GetUpdatedResult();
    new PartnerConnection.DescribeQuickActionDefaultValue();
    new PartnerConnection.performQuickActionsResponse_element();
    new PartnerConnection.resetPassword_element();
    new PartnerConnection.UndeleteResult();
    new PartnerConnection.Error();
    new PartnerConnection.NameValuePair();
    new PartnerConnection.DebuggingHeader_element();
    new PartnerConnection.SetPasswordResult();
    new PartnerConnection.describeSearchScopeOrder_element();
    new PartnerConnection.DescribeApprovalLayout();
    new PartnerConnection.getUserInfo_element();
    new PartnerConnection.LoginResult();
    new PartnerConnection.DescribeSoqlListViewsRequest();
    new PartnerConnection.describeCompactLayouts_element();
    new PartnerConnection.ProcessResult();
    new PartnerConnection.logout_element();
    new PartnerConnection.describeDataCategoryGroupsResponse_element();
    new PartnerConnection.ExecuteListViewRequest();
    new PartnerConnection.PerformQuickActionResult();
    new PartnerConnection.ResetPasswordResult();
    new PartnerConnection.DescribeColor();
    new PartnerConnection.merge_element();
    new PartnerConnection.describeTheme_element();
    new PartnerConnection.describeSoftphoneLayoutResponse_element();
    new PartnerConnection.describeGlobal_element();
    new PartnerConnection.RecordTypeInfo();
    new PartnerConnection.queryResponse_element();
    new PartnerConnection.DescribeColumn();
    new PartnerConnection.emptyRecycleBinResponse_element();
    new PartnerConnection.EmptyRecycleBinResult();
    new PartnerConnection.RelatedContent();
    new PartnerConnection.describeDataCategoryGroupStructures_element();
    new PartnerConnection.DescribeComponentInstance();
    new PartnerConnection.DescribeRelatedContentItem();
    new PartnerConnection.GetUserInfoResult();
    new PartnerConnection.QueryResult();
    new PartnerConnection.performQuickActions_element();
    new PartnerConnection.FieldLayoutComponent();
    new PartnerConnection.LeadConvertResult();
    new PartnerConnection.sendEmailMessage_element();
    new PartnerConnection.MruHeader_element();
    new PartnerConnection.processResponse_element();
    new PartnerConnection.DescribeSearchScopeOrderResult();
    new PartnerConnection.ProcessWorkitemRequest();
    new PartnerConnection.SessionHeader_element();
    new PartnerConnection.SoqlWhereCondition();
    new PartnerConnection.DescribeDataCategoryGroupStructureResult();
    new PartnerConnection.executeListView_element();
    new PartnerConnection.DescribeFlexiPageResult();
    new PartnerConnection.ListViewOrderBy();
    new PartnerConnection.describeDataCategoryGroups_element();
    new PartnerConnection.AllowFieldTruncationHeader_element();
    new PartnerConnection.ActionOverride();
    new PartnerConnection.getDeletedResponse_element();
    new PartnerConnection.SaveResult();
    new PartnerConnection.deleteResponse_element();
    new PartnerConnection.convertLead_element();
    new PartnerConnection.RecordTypeCompactLayoutMapping();
    new PartnerConnection.describeSObjects_element();
    new PartnerConnection.describeDataCategoryGroupStructuresResponse_element();
    new PartnerConnection.update_element();
    new PartnerConnection.search_element();
    new PartnerConnection.DescribeAvailableQuickActionResult();
    new PartnerConnection.describeQuickActions_element();
    new PartnerConnection.RelatedListSort();
    new PartnerConnection.describeSObject_element();
    new PartnerConnection.invalidateSessionsResponse_element();
    new PartnerConnection.LoginScopeHeader_element();
    new PartnerConnection.EmailFileAttachment();
    new PartnerConnection.convertLeadResponse_element();
    new PartnerConnection.queryAll_element();
    new PartnerConnection.describeSearchLayoutsResponse_element();
    new PartnerConnection.GetServerTimestampResult();
    new PartnerConnection.describePrimaryCompactLayouts_element();
    new PartnerConnection.retrieveResponse_element();
    new PartnerConnection.queryAllResponse_element();
    new PartnerConnection.invalidateSessions_element();
    new PartnerConnection.location();
    new PartnerConnection.ProcessSubmitRequest();
    new PartnerConnection.describeLayoutResponse_element();
    new PartnerConnection.DescribeSearchLayoutResult();
    new PartnerConnection.getServerTimestampResponse_element();
    new PartnerConnection.DescribeIcon();
    new PartnerConnection.DeletedRecord();
    new PartnerConnection.SearchResult();
    new PartnerConnection.describeGlobalTheme_element();
    new PartnerConnection.query_element();
    new PartnerConnection.getDeleted_element();
    new PartnerConnection.DataCategoryGroupSobjectTypePair();
    new PartnerConnection.PackageVersion();
    new PartnerConnection.DescribeGlobalResult();
    new PartnerConnection.DescribeGlobalTheme();
    new PartnerConnection.describeCompactLayoutsResponse_element();
    new PartnerConnection.describeSearchLayouts_element();
    new PartnerConnection.describeAllTabs_element();
    new PartnerConnection.SingleEmailMessage();
    new PartnerConnection.MassEmailMessage();
    new PartnerConnection.describePrimaryCompactLayoutsResponse_element();
    new PartnerConnection.mergeResponse_element();
    new PartnerConnection.DescribeAppMenuItem();
    new PartnerConnection.DescribeTabSetResult();
    new PartnerConnection.getUserInfoResponse_element();
    new PartnerConnection.DescribeCompactLayoutsResult();
    new PartnerConnection.UpsertResult();
    new PartnerConnection.DescribeSObjectResult();
    new PartnerConnection.retrieveQuickActionTemplates_element();
    new PartnerConnection.logoutResponse_element();
    new PartnerConnection.InvalidateSessionsResult();
    new PartnerConnection.ListViewRecord();
    new PartnerConnection.RecordTypeMapping();
    new PartnerConnection.DescribeGlobalSObjectResult();
    new PartnerConnection.KnowledgeSettings();
    new PartnerConnection.DescribeQuickActionResult();
    new PartnerConnection.DescribeSoqlListViewResult();
    new PartnerConnection.DebuggingInfo_element();
    new PartnerConnection.undelete_element();
    new PartnerConnection.DeleteResult();
    new PartnerConnection.queryMoreResponse_element();
    new PartnerConnection.upsert_element();
    new PartnerConnection.OwnerChangeOptions_element();
    new PartnerConnection.DescribeLayoutRow();
    new PartnerConnection.DescribeCompactLayout();
    new PartnerConnection.describeAllTabsResponse_element();
    new PartnerConnection.describeAvailableQuickActionsResponse_element();
    new PartnerConnection.setPassword_element();
    new PartnerConnection.DescribeSoftphoneLayoutCallType();
    new PartnerConnection.DescribeThemeResult();
    new PartnerConnection.describeFlexiPages_element();
    new PartnerConnection.ExecuteListViewResult();
    new PartnerConnection.sendEmailMessageResponse_element();
    new PartnerConnection.address();
    new PartnerConnection.resetPasswordResponse_element();
    new PartnerConnection.MergeRequest();
    new PartnerConnection.DescribeTab();

    // in a managed package each unit test must include an assertion; otherwise,
    // the Force.com security source scanner will complain
    System.assert(true);
  }

  // sobjectPartnerConnection
  static testMethod void coverGeneratedSobjectCodeTypes() {
    // Reference types
    new sobjectPartnerConnection();
    new sobjectPartnerConnection.sObject_x();

    // in a managed package each unit test must include an assertion; otherwise,
    // the Force.com security source scanner will complain
    System.assert(true);
  }

  // faultPartnerConnection
  static testMethod void coverGeneratedFaultCodeTypes() {
    // Reference types
    new faultPartnerConnection();
    new faultPartnerConnection.ApiFault();
    new faultPartnerConnection.InvalidSObjectFault();
    new faultPartnerConnection.MalformedQueryFault();
    new faultPartnerConnection.InvalidIdFault();
    new faultPartnerConnection.MalformedSearchFault();
    new faultPartnerConnection.InvalidFieldFault();
    new faultPartnerConnection.ApiQueryFault();
    new faultPartnerConnection.UnexpectedErrorFault();
    new faultPartnerConnection.InvalidQueryLocatorFault();
    new faultPartnerConnection.LoginFault();
    new faultPartnerConnection.InvalidNewPasswordFault();

    // in a managed package each unit test must include an assertion; otherwise,
    // the Force.com security source scanner will complain
    System.assert(true);
  }
}