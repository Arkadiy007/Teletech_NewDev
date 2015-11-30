/*
    Page Title: UserTrigger
    Author: Aaron Bessey
    Create Date: 7/25/2015
    Last Update: 7/25/2014
    Updated By: Aaron Bessey

    Revisions:
    AAB - Initial Creation
  
*/
trigger UserTrigger on User (before insert, before update) {
    
    // Generate the data to be encrypted.
	Blob key = Blob.valueOf('ABC1234DEF9012GHIJKLZZZYYY123465');
	Blob IV = Blob.valueOf('123456ZCBDE4YAGH');
	Blob cipherText;
    String encodedCipherText;
    Blob encodedEncryptedBlob;
    
	if(Trigger.isInsert)
    {
        for(User u : Trigger.new)
        {
    		if(u.VCAN_Password__c!=null)
            {
                cipherText = Crypto.encrypt('AES256', key, IV, Blob.valueOf(u.VCAN_Password__c));
                encodedCipherText = EncodingUtil.base64Encode(cipherText); 
    
                u.VCAN_Password__c = encodedCipherText;
            }
    	}
    }   
    else
    {
        for(User u: Trigger.new)
        {
            if(u.VCAN_Password__c!=null && Trigger.oldMap.get(u.Id).VCAN_Password__c!=u.VCAN_Password__c)
            {
                //Crypto using key and IV
                cipherText = Crypto.encrypt('AES256', key, IV, Blob.valueOf(u.VCAN_Password__c));
                encodedCipherText = EncodingUtil.base64Encode(cipherText); 
                u.VCAN_Password__c = encodedCipherText;
            }    
        }
    }
}