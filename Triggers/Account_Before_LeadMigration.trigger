/**********************************************************************
Name: Account_Before_Lead_Migration
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Do migration of Lead fields to Account fields on
Lead migration.  Account fields win so keep their
values unless there was no previous Account value.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 05/02/2011 Created
***********************************************************************/
trigger Account_Before_LeadMigration on Account (before insert, before update) {
    // Only overwrite account fields on update if the Lead field is populated
    // and the Account field is empty.
    Account oldAcct;
    Account newAcct;
    
    static final String FALSE_STRING = 'false';
    static final String TRUE_STRING = 'true';
    static final String YES = 'Yes';
    static final String NO = 'No';
    static final String HANDRAISER = 'Handraiser';
    static final String HANDRAISERS = 'Handraisers';
    static final String RESERVATIONISTS = 'Reservationists';
    
    for (Integer row = 0; row < Trigger.new.size(); row++) {
        newAcct = Trigger.new[row];

        // For updates and inserts       
        if (newAcct.Lead_Type__c == HANDRAISER || newAcct.Lead_Record_Type__c == HANDRAISERS) {
            newAcct.Handraiser__c = true;
            newAcct.Reservationist__c = false;
            newAcct.Lead__c = false;
        } else if (newAcct.Lead_Record_Type__c == RESERVATIONISTS) {
            newAcct.Reservationist__c = true;
            newAcct.Handraiser__c = false;
            newAcct.Lead__c = false;
        } else {
            newAcct.Lead__c = true;
            newAcct.Handraiser__c = false;
            newAcct.Reservationist__c = false;
        }
        
        // For updates only 
        if (Trigger.isUpdate) {
            oldAcct = Trigger.old[row];

            // For update, Account record already existed so set Customer__c to true.
            newAcct.Customer__c = true;
    
            // AnnualRevenue
            if (oldAcct.AnnualRevenue != null)
                newAcct.AnnualRevenue = oldAcct.AnnualRevenue;
            // Business_Indicator__c
            if (oldAcct.Business_Indicator__c == false) {
                if (newAcct.Business_Indicator_Temp__c == YES)
                    newAcct.Business_Indicator__c = true;
                else if (newAcct.Business_Indicator_Temp__c == NO)
                    newAcct.Business_Indicator__c = false;
            }
            // Do_Not_Contact_Indicator__c
            if (oldAcct.Do_Not_Contact_Indicator__c != null)
                newAcct.Do_Not_Contact_Indicator__c = oldAcct.Do_Not_Contact_Indicator__c;
            // Do_Not_Mail_Indicator__c
            if (oldAcct.Do_Not_Mail_Indicator__c != null)
                newAcct.Do_Not_Mail_Indicator__c = oldAcct.Do_Not_Mail_Indicator__c;
            // FirstName
            if (oldAcct.FirstName != null)
                newAcct.FirstName = oldAcct.FirstName;
            // Household_ID__c
            if (oldAcct.Household_ID__c != null)
                newAcct.Household_ID__c = oldAcct.Household_ID__c;
            // Language_Preference__c
            if (oldAcct.Language_Preference__c != null)
                newAcct.Language_Preference__c = oldAcct.Language_Preference__c;
            // LastName
            if (oldAcct.LastName != null)
                newAcct.LastName = oldAcct.LastName;
            // MiddleName__c
            if (oldAcct.MiddleName__c != null)
                newAcct.MiddleName__c = oldAcct.MiddleName__c;
            // OwnerId
            if (oldAcct.OwnerId != null)
                newAcct.OwnerId = oldAcct.OwnerId;
            // Salutation
            if (oldAcct.Salutation != null)
                newAcct.Salutation = oldAcct.Salutation;
            // Undeliverable_Email_Address_In__c
            if (oldAcct.Undeliverable_Email_Address_In__c != null)
                newAcct.Undeliverable_Email_Address_In__c = oldAcct.Undeliverable_Email_Address_In__c;
    
            // PersonMailingCity
            if (oldAcct.PersonMailingCity != null)
                newAcct.PersonMailingCity = oldAcct.PersonMailingCity;
            // PersonMailingCountry
            if (oldAcct.PersonMailingCountry != null)
                newAcct.PersonMailingCountry = oldAcct.PersonMailingCountry;
            // Do_Not_Email_In__c
            if (oldAcct.Do_Not_Email_In__c != null) 
                newAcct.Do_Not_Email_In__c = oldAcct.Do_Not_Email_In__c;
            else if (newAcct.Do_Not_Email_In__c == FALSE_STRING)
                newAcct.Do_Not_Email_In__c = NO.toUpperCase();
            else if (newAcct.Do_Not_Email_In__c == TRUE_STRING)
                newAcct.Do_Not_Email_In__c = YES.toUpperCase();
            // PersonEmail
            if (oldAcct.PersonEmail != null)
                newAcct.PersonEmail = oldAcct.PersonEmail;
            // Federal_Home_Phone_Do_Not_Call_In__c
            if (oldAcct.Federal_Home_Phone_Do_Not_Call_In__c != null)
                newAcct.Federal_Home_Phone_Do_Not_Call_In__c = oldAcct.Federal_Home_Phone_Do_Not_Call_In__c;
            else if (newAcct.Federal_Home_Phone_Do_Not_Call_In__c == FALSE_STRING)
                newAcct.Federal_Home_Phone_Do_Not_Call_In__c = NO;
            else if (newAcct.Federal_Home_Phone_Do_Not_Call_In__c == TRUE_STRING)
                newAcct.Federal_Home_Phone_Do_Not_Call_In__c = YES;
            // Federal_Mobile_Phone_Do_Not_Call_In__c
            if (oldAcct.Federal_Mobile_Phone_Do_Not_Call_In__c != null)
                newAcct.Federal_Mobile_Phone_Do_Not_Call_In__c = oldAcct.Federal_Mobile_Phone_Do_Not_Call_In__c;
            else if (newAcct.Federal_Mobile_Phone_Do_Not_Call_In__c == FALSE_STRING)
                newAcct.Federal_Mobile_Phone_Do_Not_Call_In__c = NO;
            else if (newAcct.Federal_Mobile_Phone_Do_Not_Call_In__c == TRUE_STRING)
                newAcct.Federal_Mobile_Phone_Do_Not_Call_In__c = YES;
            // Federal_Other_Phone_Do_Not_Call_In__c
            if (oldAcct.Federal_Other_Phone_Do_Not_Call_In__c != null)
                newAcct.Federal_Other_Phone_Do_Not_Call_In__c = oldAcct.Federal_Other_Phone_Do_Not_Call_In__c;
            else if (newAcct.Federal_Other_Phone_Do_Not_Call_In__c == FALSE_STRING)
                newAcct.Federal_Other_Phone_Do_Not_Call_In__c = NO;
            else if (newAcct.Federal_Other_Phone_Do_Not_Call_In__c == TRUE_STRING)
                newAcct.Federal_Other_Phone_Do_Not_Call_In__c = YES;
            // Mobile_Phone_Do_Not_Call_Indicator__c
            if (oldAcct.Mobile_Phone_Do_Not_Call_Indicator__c != null)
                newAcct.Mobile_Phone_Do_Not_Call_Indicator__c = oldAcct.Mobile_Phone_Do_Not_Call_Indicator__c;
            else if (newAcct.Mobile_Phone_Do_Not_Call_Indicator__c == FALSE_STRING)
                newAcct.Mobile_Phone_Do_Not_Call_Indicator__c = NO.toUpperCase();
            else if (newAcct.Mobile_Phone_Do_Not_Call_Indicator__c == TRUE_STRING)
                newAcct.Mobile_Phone_Do_Not_Call_Indicator__c = YES.toUpperCase();
            // Other_Phone_Do_Not_Call_In__c
            if (oldAcct.Other_Phone_Do_Not_Call_In__c != null)
                newAcct.Other_Phone_Do_Not_Call_In__c = oldAcct.Other_Phone_Do_Not_Call_In__c;
            else if (newAcct.Other_Phone_Do_Not_Call_In__c == FALSE_STRING)
                newAcct.Other_Phone_Do_Not_Call_In__c = NO.toUpperCase();
            else if (newAcct.Other_Phone_Do_Not_Call_In__c == TRUE_STRING)
                newAcct.Other_Phone_Do_Not_Call_In__c = YES.toUpperCase();
            // PersonOtherPhone
            if (oldAcct.PersonOtherPhone != null)
                newAcct.PersonOtherPhone = oldAcct.PersonOtherPhone;
            // PersonHomePhone
            if (oldAcct.PersonHomePhone != null)
                newAcct.PersonHomePhone = oldAcct.PersonHomePhone;
            // PersonDoNotCall
            if (oldAcct.PersonDoNotCall != null)
                newAcct.PersonDoNotCall = oldAcct.PersonDoNotCall;
            // PersonMailingPostalCode
            if (oldAcct.PersonMailingPostalCode != null)
                newAcct.PersonMailingPostalCode= oldAcct.PersonMailingPostalCode;
            // PersonMailingState
            if (oldAcct.PersonMailingState != null)
                newAcct.PersonMailingState= oldAcct.PersonMailingState;
            // PersonMailingStreet
            if (oldAcct.PersonMailingStreet != null)
                newAcct.PersonMailingStreet= oldAcct.PersonMailingStreet;
            // Undeliverable_Address_Indicator__c
            if (oldAcct.Undeliverable_Address_Indicator__c != null)
                newAcct.Undeliverable_Address_Indicator__c = oldAcct.Undeliverable_Address_Indicator__c;
            // Preferred_Dealer_Id__c
            if (oldAcct.Preferred_Dealer_Id__c != null)
                newAcct.Preferred_Dealer_Id__c= oldAcct.Preferred_Dealer_Id__c;
        }
        if (Trigger.isInsert) {
            // Do_Not_Email_In__c
            if (newAcct.Do_Not_Email_In__c == FALSE_STRING)
                newAcct.Do_Not_Email_In__c = NO.toUpperCase();
            else if (newAcct.Do_Not_Email_In__c == TRUE_STRING)
                newAcct.Do_Not_Email_In__c = YES.toUpperCase();
            // Federal_Home_Phone_Do_Not_Call_In__c
            if (newAcct.Federal_Home_Phone_Do_Not_Call_In__c == FALSE_STRING)
                newAcct.Federal_Home_Phone_Do_Not_Call_In__c = NO;
            else if (newAcct.Federal_Home_Phone_Do_Not_Call_In__c == TRUE_STRING)
                newAcct.Federal_Home_Phone_Do_Not_Call_In__c = YES;
            // Federal_Mobile_Phone_Do_Not_Call_In__c
            if (newAcct.Federal_Mobile_Phone_Do_Not_Call_In__c == FALSE_STRING)
                newAcct.Federal_Mobile_Phone_Do_Not_Call_In__c = NO;
            else if (newAcct.Federal_Mobile_Phone_Do_Not_Call_In__c == TRUE_STRING)
                newAcct.Federal_Mobile_Phone_Do_Not_Call_In__c = YES;
            // Federal_Other_Phone_Do_Not_Call_In__c
            if (newAcct.Federal_Other_Phone_Do_Not_Call_In__c == FALSE_STRING)
                newAcct.Federal_Other_Phone_Do_Not_Call_In__c = NO;
            else if (newAcct.Federal_Other_Phone_Do_Not_Call_In__c == TRUE_STRING)
                newAcct.Federal_Other_Phone_Do_Not_Call_In__c = YES;
            // Mobile_Phone_Do_Not_Call_Indicator__c
            if (newAcct.Mobile_Phone_Do_Not_Call_Indicator__c == FALSE_STRING)
                newAcct.Mobile_Phone_Do_Not_Call_Indicator__c = NO.toUpperCase();
            else if (newAcct.Mobile_Phone_Do_Not_Call_Indicator__c == TRUE_STRING)
                newAcct.Mobile_Phone_Do_Not_Call_Indicator__c = YES.toUpperCase();
            // Other_Phone_Do_Not_Call_In__c
            if (newAcct.Other_Phone_Do_Not_Call_In__c == FALSE_STRING)
                newAcct.Other_Phone_Do_Not_Call_In__c = NO.toUpperCase();
            else if (newAcct.Other_Phone_Do_Not_Call_In__c == TRUE_STRING)
                newAcct.Other_Phone_Do_Not_Call_In__c = YES.toUpperCase();
            // Business_Indicator__c
            if (newAcct.Business_Indicator_Temp__c == YES)
                newAcct.Business_Indicator__c = true;
            else if (newAcct.Business_Indicator_Temp__c == NO)
                newAcct.Business_Indicator__c = false;
        }
    }
}