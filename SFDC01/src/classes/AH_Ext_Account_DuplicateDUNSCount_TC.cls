@isTest
private class AH_Ext_Account_DuplicateDUNSCount_TC {

    // this method tests the custom account controller extension as part of the overall
    // account hierarchy solution
    static testMethod void testControllerExtension() {
        
        // declare local vars
        String totalCount = '';
        String myCount = '';
        String matchURL = '';
        String DUNS = 'A1B2C3';
        
        // initialize the test by getting handles to the desired page
        PageReference pageRef = Page.AH_DuplicateDUNSCount;
        Test.setCurrentPage(pageRef);
      
        // get user profile ids for the users that shall be created
        String standardUserProfileId = [select id from profile where name = 'CMA Standard User'].Id;

        // create some test data
        User standardUser = createNewUser(standardUserProfileId);
        Account acct1 = createNewAccount(DUNS);
        Account acct2 = createNewAccount(DUNS);
        // create an account share for the standard user
        AccountShare share = new AccountShare(UserOrGroupId = standardUser.Id, OpportunityAccessLevel = 'Read', 
            CaseAccessLevel = 'Read', AccountId = acct1.Id, AccountAccessLevel = 'Read');
        insert share;
        
        // now get a handle to the controller extension we are testing
        ApexPages.StandardController ctlr = new ApexPages.standardController(acct1);
        AH_Ext_Account_DuplicateDUNSCount ctlrExt = new AH_Ext_Account_DuplicateDUNSCount(ctlr);
        
        // run through the duplicate methods as a standard user
        System.RunAs(standardUser) {
            totalCount = ctlrExt.getTotalMatchCount();
            myCount = ctlrExt.getMyMatchCount();
            matchURL = ctlrExt.getMatchViewURL();
        }
        System.debug('match URL: ' + matchURL);
        System.assertEquals('There are <b>2 duplicates</b> present, of which ', totalCount,'Total count is incorrect.');
     //   System.assertEquals('<b>you have access to 1</b>', myCount,'Personal count is incorrect.');
        System.assertEquals(Page.AH_ViewDuplicateDUNS.getUrl() + '?duns=' + DUNS,matchURL,'The match URL is incorrect');
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
        System.debug('Test user info( Id: ' + testUser.Id + '; username: ' + testUser.username + ')');          
        */
        return returnUser(profileId);    
    }  
   private static User returnUser(String profilesId) {
        User testUser = [Select Alias,email,lastname,username,ProfileId,BU__c, Employee_Number__c from User where ProfileId=:profilesId and IsActive =true limit 1];       
        return testUser;    
    }         
}