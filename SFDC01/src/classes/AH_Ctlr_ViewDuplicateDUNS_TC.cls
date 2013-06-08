@isTest
private class AH_Ctlr_ViewDuplicateDUNS_TC {

    static testMethod void testDuplicateDUNSView() {
        
        // declare local vars
        List <Account> myDupes;
        List <Account> hiddenDupes;
        String DUNS = 'A1B2C3';
        
        // initialize the page reference
        PageReference pageRef = Page.AH_ViewDuplicateDUNS;
        ApexPages.currentPage().getParameters().put('duns', DUNS);
        
        // set the contect for the controller
        AH_Ctlr_ViewDuplicateDUNS ctlr = new AH_Ctlr_ViewDuplicateDUNS();
        
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

        // run through the duplicate methods as a standard user
        System.RunAs(standardUser) {
            myDupes = ctlr.getMyDupes();
            hiddenDupes = ctlr.getHiddenDupes();
        }
       // System.assertEquals(1,myDupes.size(),'The returned collection size of visible dupes was incorrect');
       // System.assertEquals(acct1.Id,myDupes[0].Id,'The returned collection of visible dupes was incorrect');
       // System.assertEquals(1,hiddenDupes.size(),'The returned collection size of hidden dupes was incorrect');
       // System.assertEquals(acct2.Id,hiddenDupes[0].Id,'The returned collection of hidden dupes was incorrect');
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