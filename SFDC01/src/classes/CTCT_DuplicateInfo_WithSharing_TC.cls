/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |  22-JUL-09  S Douglas              Initial Creation. Test class for CTCT_DuplicateInfo_WithSharing
 |                             
 +===========================================================================*/
@isTest
private class CTCT_DuplicateInfo_WithSharing_TC {

    ////////////////////////////////////////////////////////////////////////////////////
    // test functions 
    /////////////////////////////////////////////////////////////////////////////////////
    static testMethod void runDuplicateTests() {
        
        // declare local vars
      
        Integer adminCt = 0;
        Integer standardCt = 0;
        List <Contact> contact1Dupes = null;
        List <Contact> contact2Dupes = null;
        
        // get user profile ids for the users that shall be queried
        Id AdminUserProfileId= '00e70000000wBza';  // Profile Id - System Administrator
        
        // get an admin and standard user
        User adminUser = getTestUser(adminUserProfileId);

        //Id CustomUserProfileId= '00e70000001FaZG'; // Profile - AMER Inside Sales/SMB User
        Id CustomUserProfileId = '00e70000001FaZGAA0';
        User standardUser = getTestUser(customUserProfileId);
        System.debug('standardUser '+standardUser);

         

        // create 2 test account records
        Account acct1 = createNewAccount();
        Account acct2 = createNewAccount();
        
        //create a contact for each account   
        Contact cont1 = createNewContact(acct1.id,'testcontact1@bogusco.com');    
        Contact cont2 = createNewContact(acct2.id,'testcontact2@bogusco.com');     

        // create an account share for the standard user
        AccountShare share = new AccountShare(UserOrGroupId = standardUser.Id, OpportunityAccessLevel = 'Read', 
            CaseAccessLevel = 'Read', AccountId = acct1.Id, AccountAccessLevel = 'Read');
        insert share;

        //Test.startTest();  //Not included because it causes error in Eclipse:  Too many System.runAs() invocations
        
        // run through the duplicate methods as a standard user
        System.RunAs(standardUser) {
            contact1Dupes = CTCT_DuplicateInfo_WithSharing.getDuplicateContacts('testcontact1@bogusco.com');
            contact2Dupes = CTCT_DuplicateInfo_WithSharing.getDuplicateContacts('testcontact2@bogusco.com');
        }
        System.assert(contact1Dupes != null && contact1Dupes.size() == 1, 'getDuplicateContacts return size is incorrect for contact in shared account');
        System.assert(contact2Dupes == null || contact2Dupes.size() == 0, 'getDuplicateContacts return size is incorrect for contact in unshared account');

        // run through the duplicate methods as an admin user
        System.RunAs(adminUser) {
            contact1Dupes = CTCT_DuplicateInfo_WithSharing.getDuplicateContacts('testcontact1@bogusco.com');
            contact2Dupes = CTCT_DuplicateInfo_WithSharing.getDuplicateContacts('testcontact2@bogusco.com');
        }
        System.assert(contact1Dupes != null && contact1Dupes.size() == 1, 'getDuplicateContacts return size is incorrect for contact in shared account');
        System.assert(contact2Dupes != null || contact2Dupes.size() == 1, 'getDuplicateContacts return size is incorrect for contact in unshared account');

        //Test.stopTest();
    }

    /////////////////////////////////////////////////////////////////////////////////////
    // helper functions 
    /////////////////////////////////////////////////////////////////////////////////////
    private static Account createNewAccount() {
        Account account = new Account();
        account.name = EMC_UTILITY.generateRandomString(20);
        account.Site_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account.Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account.Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        
        Database.Saveresult[] sr = Database.insert(new Account[] {account});
        System.debug('Account save result: ' + sr[0].isSuccess());
        if (!sr[0].isSuccess()) {
            System.debug(sr[0].getErrors());
        } else {
            System.debug(sr[0].Id);
        }
        return account;
    }
    private static Contact createNewContact(String acctId, String email) {
        Contact contact = new Contact();
        contact.accountId = acctId;
        contact.email = email;
        contact.lastname = EMC_UTILITY.generateRandomString(5);
        contact.active__c = true;
        insert contact;
        return contact;
    } //createNewContact 
    
   
   
    //Get a user with which to test
    //If we try to create both a user and an account, we get the error:
    //  MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa) 
    //We ONLY see the error when running within Salesforce and not from Eclipse
    private static User getTestUser(String profileId) {
        User testUser = [SELECT Id FROM User WHERE profileId = :profileId AND isActive = true LIMIT 1];
        System.debug('test user'+testUser);
        return testUser;
    }

}