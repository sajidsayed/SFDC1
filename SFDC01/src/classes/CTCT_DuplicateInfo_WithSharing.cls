/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |  20-JUL-09  S Douglas              Initial Creation - for prevention of duplicate contacts
 |                                    A contact may not be created if a user already has access to a contact
 |                                    with the same email address (so we must enforce user security)
 |                                 
 +===========================================================================*/
public with sharing class CTCT_DuplicateInfo_WithSharing {

    //Returns a list of duplicate contacts (20 max)
    public static List<Contact> getDuplicateContacts(String email) {
        
        List<Contact> contacts = [SELECT ID, name, accountId, email, phone, title, active__c  FROM contact 
                         WHERE email = :email
                         AND active__c = true 
                         LIMIT 20];
        
        return contacts;
    }


}