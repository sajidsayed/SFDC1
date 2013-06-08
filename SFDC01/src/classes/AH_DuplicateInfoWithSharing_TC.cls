@isTest
private class AH_DuplicateInfoWithSharing_TC {
    /* test duplicate info functions without sharing */
    static testMethod void runDuplicateTests() {
        
        // declare local vars
        String DUNS = '1A2B3C';
        String adminUserProfileId = '';
        String standardUserProfileId = '';
        Integer adminCt = 0;
        Integer standardCt = 0;
        List <Account> adminDupes = null;
        List <Account> standardDupes = null;
        
        // get user profile ids for the users that shall be created
        standardUserProfileId = [select id from profile where name = 'CMA Standard User'].Id;
        adminUserProfileId = [select id from profile where name = 'System Administrator'].Id;
        
        // create an admin and standard user
        User adminUser = createNewUser(adminUserProfileId);
        System.debug('Test admin user info( Id: ' + adminUser.Id + '; username: ' + adminUser.username + ')');
        User standardUser = createNewUser(standardUserProfileId);
        System.debug('Test standard user info( Id: ' + standardUser.Id + '; username: ' + standardUser.username + ')');

        // create 2 test account records
        Account acct1 = createNewAccount(DUNS);
        Account acct2 = createNewAccount(DUNS);

        // create an account share for the standard user
        AccountShare share = new AccountShare(UserOrGroupId = standardUser.Id, OpportunityAccessLevel = 'Read', 
            CaseAccessLevel = 'Read', AccountId = acct1.Id, AccountAccessLevel = 'Read');
        insert share;

        // run through the duplicate methods as a standard user
        System.RunAs(standardUser) {
            standardCt = AH_DuplicateInfo_WithSharing.getDuplicateCount(DUNS);
            standardDupes = AH_DuplicateInfo_WithSharing.getDuplicates(DUNS);
        }
     //   System.assertEquals(1, standardCt, 'Standard user count is incorrect');
     //   System.assertEquals(standardDupes[0].Id, acct1.Id,'Standard duplicate set is incorrect');

        // run through the duplicate methods as an admin user
        System.RunAs(adminUser) {
            adminCt = AH_DuplicateInfo_WithSharing.getDuplicateCount(DUNS);
            adminDupes = AH_DuplicateInfo_WithSharing.getDuplicates(DUNS);
        }
        System.assertEquals(2, adminCt, 'Admin user count is incorrect');
        for (Integer x = 0; x < adminDupes.size(); x++) {
            System.assert((adminDupes[x].Id == acct1.Id) || (adminDupes[x].Id == acct2.Id),'Admin duplicate set is incorrect');
        }
    }
    
    /* helper functions */
    private static Account createNewAccount(String DUNS) {
        Account account = new Account();
        account.name = EMC_UTILITY.generateRandomString(20);
        account.Site_DUNS_Entity__c = DUNS;
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
    
    private static User createNewUser(String profileId) {
        /*User testUser = new User(emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/Los_Angeles');
        testUser.Alias = EMC_UTILITY.generateRandomString(5);
        testUser.email = EMC_UTILITY.generateRandomString(10) + '@email.com';
        testUser.lastname = EMC_UTILITY.generateRandomString(10);
        testUser.username = testUser.email;
        testUser.ProfileId = profileId;
        testUser.BU__c = EMC_UTILITY.generateRandomString(5);
        testUser.Employee_Number__c = EMC_UTILITY.generateRandomString(10);
        
        insert testUser;
        */          
        return returnUser(profileId);    
    }
    private static User returnUser(String profilesId) {
        User testUser = [Select Alias,email,lastname,username,ProfileId,BU__c, Employee_Number__c from User where ProfileId=:profilesId and IsActive =true limit 1];       
        return testUser;    
    }         
}