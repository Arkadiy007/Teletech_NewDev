/**********************************************************************
Name: MaritzCreditCardTransactionHistory_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is a test for MaritzCreditCardTransactionHistory.
 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Sonali Bhardwaj 02/28/2011 Created 
***********************************************************************/
@isTest
private class MaritzCreditCardTransactionHistory_Test {
    
    static testmethod void testCreate() {
        MaritzCreditCardTransactionHistory.NNA360ServiceSoap obj = new MaritzCreditCardTransactionHistory.NNA360ServiceSoap();
        MaritzCreditCardTransactionHistory.GetCCTransactionHistoryResponse_element obj1 = new MaritzCreditCardTransactionHistory.GetCCTransactionHistoryResponse_element();
        MaritzCreditCardTransactionHistory.ArrayOfCCTransaction  obj2 = new MaritzCreditCardTransactionHistory.ArrayOfCCTransaction();
        MaritzCreditCardTransactionHistory.CCTransactionsResponse   obj3 = new MaritzCreditCardTransactionHistory.CCTransactionsResponse();
        MaritzCreditCardTransactionHistory.CCTransaction obj4 = new MaritzCreditCardTransactionHistory.CCTransaction();
        test.startTest();
        obj.GetCCTransactionHistory('referenceId', 'SessionToken', 11);
        test.stopTest();
    }
}