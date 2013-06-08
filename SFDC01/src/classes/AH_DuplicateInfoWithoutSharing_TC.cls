@isTest
private class AH_DuplicateInfoWithoutSharing_TC {

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
        User standardUser = createNewUser(standardUserProfileId);
        
        // create two accounts, one owned by each user
        Account acct1 = createNewAccount(adminUser.Id,DUNS);
        Account acct2 = createNewAccount(standardUser.Id,DUNS);
        
        // execute the Duplicate info queries as each user  
        System.RunAs(adminUser) {
            adminCt = AH_DuplicateInfo_WithoutSharing.getDuplicateCount(DUNS);
            adminDupes = AH_DuplicateInfo_WithoutSharing.getDuplicates(DUNS);
        }
        System.RunAs(standardUser) {
            standardCt = AH_DuplicateInfo_WithoutSharing.getDuplicateCount(DUNS);
            standardDupes = AH_DuplicateInfo_WithoutSharing.getDuplicates(DUNS);
        }
        // ensure the results match
        System.assertEquals(2, standardCt, 'Standard user count is incorrect');
        System.assertEquals(adminCt, standardCt, 'User counts do not match');
        System.assertEquals(adminDupes.size(),standardDupes.size(),'Duplicate list sizes are different');
        for (Integer x = 0; x < adminDupes.size(); x++) {
            System.assertEquals(adminDupes[x].Id, standardDupes[x].Id, 'Accounts do not match');
        }
        
    }
    
    /* helper functions */
    private static Account createNewAccount(String ownerId, String DUNS) {
        Account account = new Account();
        account.name = EMC_UTILITY.generateRandomString(20);
        account.Site_DUNS_Entity__c = DUNS;
        account.Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account.Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account.ownerId = ownerId;
        insert account;
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