/**********************************************************************
  Name: LiveChatTranscript_After
  Copyright � notice: Nissan Motor Company.
  ======================================================
  Purpose:
  This trigger is for following purposes:
  - Make the relation against Survey;
  - Make the relation against the Pre-Chat Object;
  - Copy the transcript to the related case as case comments;
  - Populate PostChat_Agent and CaseId fields for Stage_FF_SFDC_SurveyResponse records.
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0
  1.1 - Arkadiy Sychev    03/20/2015 Add logic for live agent surveys to populate PostChat_Agent and CaseId fields for Stage_FF_SFDC_SurveyResponse records.
  1.2 - Arkadiy Sychev  03/25/2015 Code refactoring in accordance with the best practice practice (Avoid SOQL Queries or DML statements inside FOR Loops)
  1.3 - Vladimir Martynenko 06/15/2015 Maritz Backfeet Object Creation
 ***********************************************************************/
trigger LiveChatTranscript_After on LiveChatTranscript(after insert) {
    private final Integer COMMENT_CHARS_LIMIT = 4000;
    private Surveys__c survey = new Surveys__c();

    // 1.2 Arkadiy Sychev - Lists for Surveys__c, Pre_Chat_Data__c, CaseComment, Stage_FF_SFDC_SurveyResponse__c records which will be updated or inserted
    List <Surveys__c > survaysToUpdate = new List <Surveys__c > ();
    List <Pre_Chat_Data__c > preChatdatatoUpdate = new List <Pre_Chat_Data__c > ();
    List <CaseComment > caseCommentToInsert = new List <CaseComment > ();
    List <Stage_FF_SFDC_SurveyResponse__c > surveyResponseToUpdate = new List <Stage_FF_SFDC_SurveyResponse__c > ();

    // 1.2 Arkadiy Sychev - Retrieving and adding to set all Ids of Owners, Survays, Pre_Chat_Data__c
    Set<Id> ownerIds = new Set<Id> ();
    Set<Id> survaysIds = new Set<Id> ();
    Set<Id> preChatdataIds = new Set<Id> ();
    Set<ID> caseIds = new Set<Id> ();

    for (LiveChatTranscript chat : Trigger.new) {
        ownerIds.add(chat.OwnerId);
        survaysIds.add(chat.Survey__c);
        preChatdataIds.add(chat.Pre_Chat_Data__c);
        caseIds.add(chat.CaseId);
    }

    // 1.2 Arkadiy Sychev - Retrieving all owners of the LiveChatTranscript records
    Map <Id, User > chatOwnersMap = new Map <Id, User > ([SELECT Id, Name
                                                         FROM User
                                                         WHERE Id IN :ownerIds]);

    // 1.2 Arkadiy Sychev - Retrieving all related Surveys__c record
    Map <Id, Surveys__c > surveysMap = new map <Id, Surveys__c > ([SELECT Id,
                                                                  Live_Chat_Transcript__c, Customer__c
                                                                  FROM Surveys__c
                                                                  WHERE Id IN :survaysIds]);

    // 1.2 Arkadiy Sychev - Retrieving all related Pre_Chat_Data__c records
    Map <Id, Pre_Chat_Data__c > preChatDataMap = new Map <Id, Pre_Chat_Data__c > ([SELECT Live_Chat_Transcript__c
                                                                                  FROM Pre_Chat_Data__c
                                                                                  WHERE Id IN :preChatdataIds]);

    //1.2 Arkadiy Sychev - Retrieving related all Case records
    Map <Id, Case > caseMap = new Map <Id, Case > ([SELECT Id,
                                                   Contact_ID__c,
                                                   OwnerId,
                                                   CreatedDate,
                                                   Dealer_Code__c,
                                                   Model1__c,
                                                   Model_Year__c,
                                                   VIN__c,
                                                   DealerCode__c,
                                                   Model_of_Interest_1st__c,
                                                   Survey_NPS_Score_1__c,
                                                   Survey_NPS_Score_2__c,
                                                   Alert_Trigger_Verbatim__c,
                                                   Lead_Date__c,
                                                   Owner.Name,
                                                   CaseNumber,
                                                   IsClosed,
                                                   Case_Type__c,
                                                   Description,
                                                   Subject,
                                                   NNA_Net_Hot_Alert_Type__c,
                                                   Survey_ID__c,
                                                   ClosedDate
                                                   FROM Case
                                                   WHERE Id IN :caseIds]);

    // 1.2 Arkadiy Sychev - Retrieving appropriate Stage_FF_SFDC_SurveyResponse__c records which should be updated
    Map <Id, Stage_FF_SFDC_SurveyResponse__c > surveyResponseMap = new Map <Id, Stage_FF_SFDC_SurveyResponse__c > ([SELECT id,
                                                                                                                   Case_Owner_Name__c,
                                                                                                                   Contact_ID__c,
                                                                                                                   Date_Closed__c,
                                                                                                                   Dealer_Code__c,
                                                                                                                   Model_of_Interest_1st__c,
                                                                                                                   Model_Year__c,
                                                                                                                   VIN__c,
                                                                                                                   Survey_NPS_Score_1__c,
                                                                                                                   Survey_NPS_Score_2__c,
                                                                                                                   Alert_Trigger_Verbatim__c,
                                                                                                                   Lead_Date__c,
                                                                                                                   Date_Opened__c,
                                                                                                                   Case_Number__c,
                                                                                                                   PostChat_Agent__c, SurveyID__c, CaseId__c
                                                                                                                   FROM Stage_FF_SFDC_SurveyResponse__c
                                                                                                                   WHERE SurveyID__c IN :survaysIds]);
    //1.2 Arkadiy Sychev - surveyResponseMapBySurveysId map contains SurveyID as key and Stage_FF_SFDC_SurveyResponse__c object as value
    Map <String, Stage_FF_SFDC_SurveyResponse__c > surveyResponseMapBySurveysId = new Map <String, Stage_FF_SFDC_SurveyResponse__c > ();
    for (Stage_FF_SFDC_SurveyResponse__c sr : surveyResponseMap.values()) {
        surveyResponseMapBySurveysId.put(sr.SurveyID__c, sr);
    }

    for (LiveChatTranscript chat : Trigger.new) {

        // Make the relation against Survey
        if (chat.Survey__c != null) {
            survey = surveysMap.get(chat.Survey__c);

            if (survey != null) {
                survey.Live_Chat_Transcript__c = chat.Id;
                survey.Customer__c = chat.AccountId;
                survaysToUpdate.add(survey);
            }
        }


        //Make the relation against the Pre-Chat Object
        if (chat.Pre_Chat_Data__c != null) {
            Pre_Chat_Data__c relatedPreChat = preChatDataMap.get(chat.Pre_Chat_Data__c);

            if (relatedPreChat != null) {
                if (relatedPreChat.Live_Chat_Transcript__c == null) {
                    relatedPreChat.Live_Chat_Transcript__c = chat.Id;
                    preChatdatatoUpdate.add(relatedPreChat);
                }
            }
        }

        //Copy the transcript to the related case as case comments
        if (chat.CaseId != null && chat.Body != null) {

            Case associatedCase = caseMap.get(chat.CaseId);

            if (associatedCase != null) {
                if (associatedCase.IsClosed && associatedCase.ClosedDate.Date().daysBetween(System.Today()) > 30) {
                    // Closed Case older than 30 days
                    // TODO: Define action
                }
                else {
                    String transcriptText;
                    transcriptText = chat.Body.replaceAll('<br>', '\n\b');
                    transcriptText = transcriptText.replaceAll('<[^>]+>', ' ');

                    List <String > caseCommentCollection = Text_Util.splitStringExtended(
                                                                                         transcriptText, COMMENT_CHARS_LIMIT);

                    if (caseCommentCollection.size() > 0) {
                        String transcriptFirstLine = caseCommentCollection[0].substring(
                                                                                        caseCommentCollection[0].indexOf('Chat Started:'),
                                                                                        caseCommentCollection[0].indexOf('(') - 1);

                        String query = '';
                        query += 'SELECT Id ';
                        query += 'FROM CaseComment ';
                        query += 'WHERE ParentId = \'' + chat.CaseId + '\' ';
                        query += 'AND CommentBody LIKE \'' + transcriptFirstLine + '%\'';

                        List <CaseComment > alreadyExistComment = Database.query(query);

                        if (alreadyExistComment.size() == 0) {
                            for (String commentBlock : caseCommentCollection) {
                                CaseComment comment = new CaseComment();
                                comment.ParentId = chat.CaseId;
                                comment.IsPublished = true;
                                comment.CommentBody = commentBlock;
                                caseCommentToInsert.add(comment);
                            }
                        }
                    }
                }
            }
        }

        //1.1 Arkadiy Sychev - Populating PostChat_Agent and CaseId fields for Stage_FF_SFDC_SurveyResponse records.
        if (survey != null) {
            Stage_FF_SFDC_SurveyResponse__c ffSurvayResponse = surveyResponseMapBySurveysId.get((String) survey.Id);
            User chatOwner = chatOwnersMap.get(chat.OwnerId);

            if (ffSurvayResponse != null) {
                ffSurvayResponse.PostChat_Agent__c = chatOwner.Name;
                ffSurvayResponse.CaseId__c = chat.CaseId;

                UpdateSurveyResponseWithParsedChatText(chat, ffSurvayResponse);

                if (chat.CaseId != null) {
                    Case relatedCase = caseMap.get(chat.CaseId);
                    ffSurvayResponse.Case_Owner_Name__c = relatedCase.Owner.Name;
                    ffSurvayResponse.Contact_ID__c = relatedCase.Contact_ID__c;
                    ffSurvayResponse.Date_Closed__c = relatedCase.ClosedDate;
                    ffSurvayResponse.Dealer_Code__c = relatedCase.DealerCode__c;
                    ffSurvayResponse.Model_of_Interest_1st__c = relatedCase.Model_of_Interest_1st__c;
                    ffSurvayResponse.Model_Year__c = relatedCase.Model_Year__c;
                    ffSurvayResponse.VIN__c = relatedCase.VIN__c;
                    ffSurvayResponse.Survey_NPS_Score_1__c = relatedCase.Survey_NPS_Score_1__c;
                    ffSurvayResponse.Survey_NPS_Score_2__c = relatedCase.Survey_NPS_Score_2__c;
                    ffSurvayResponse.Alert_Trigger_Verbatim__c = relatedCase.Alert_Trigger_Verbatim__c;
                    ffSurvayResponse.Lead_Date__c = relatedCase.Lead_Date__c;
                    ffSurvayResponse.Date_Opened__c = relatedCase.CreatedDate;
                    ffSurvayResponse.Case_Number__c = relatedCase.CaseNumber;
                    ffSurvayResponse.Case_Type__c = relatedCase.Case_Type__c;
                    ffSurvayResponse.Case_Description__c = relatedCase.Description;
                    ffSurvayResponse.Subject__c = relatedCase.Subject;
                    ffSurvayResponse.NNA_Net_Hot_Alert_Type__c = relatedCase.NNA_Net_Hot_Alert_Type__c;
                    ffSurvayResponse.Case_Survey_ID__c = relatedCase.Survey_ID__c;
                }

                surveyResponseToUpdate.add(ffSurvayResponse);
            }
        }
    }

    //1.2 Arkadiy Sychev - insert and update Surveys__c, Pre_Chat_Data__c, CaseComment, Stage_FF_SFDC_SurveyResponse__c records
    update survaysToUpdate;
    update preChatdatatoUpdate;
    insert caseCommentToInsert;
    update surveyResponseToUpdate;


    //1.3 Vladimir Martynenko - maritz backfeet object creation:
    if(Trigger.isInsert){
        if(Maritz_Backfeed_Trigger_Enabled__c.getInstance() != null){
            if(Maritz_Backfeed_Trigger_Enabled__c.getInstance().EnabledForChat__c){
                Maritz_Backfeed_TaskTriggerHelper helper = new Maritz_Backfeed_TaskTriggerHelper(Trigger.NEW);
            }
        }
    }

    private void UpdateSurveyResponseWithParsedChatText(LiveChatTranscript chat, Stage_FF_SFDC_SurveyResponse__c response) {
        //response.Team__c = chat.OwnerId;
        response.Chat_date__c = chat.RequestTime;
        response.chat_number__c = chat.Name;

        String chatText = chat.body;
        if (chatText != '' && chatText != null) {
            String[] chatlines = chatText.split('</p>');
            if (chatlines.size() >= 4) {
                response.chat_origin__c = chatlines.get(1).replace('<p align="center">Chat Origin: ', '');
                response.Chat_Content__c = chatlines.get(3).replace('<br>', '\n');
            }
        }
    }
}