/*****************************************************
Name: EmailMessage_After 
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.02 - Arkadiy Sychev   12/12/2014 Added notifications creation when user replies on email
***********************************************************************/
trigger EmailMessage_After on EmailMessage (after insert, before insert) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        EmailMessageHelper.handleAfterInsertEvent(Trigger.New);
    }
	if(Trigger.isBefore && Trigger.isInsert){
        EmailMessageHelper.handleBeforeInsertEvent(Trigger.New);
    }
}