/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |  22-JUL-09  S Douglas              Initial Creation. Test class for CTCT_DuplicateInfo_WithSharing
 |  11-Jun-10  Prasad K               Commented unwnated check
 |                                  
 +===========================================================================*/
@isTest
private class CTCT_PreventDuplicates_TC {

    /////////////////////////////////////////////////////////////////////////////////////
    // test functions 
    /////////////////////////////////////////////////////////////////////////////////////
    static testMethod void runTests() {

        String standardUserProfileId = '';
        String emailContact1 = 'testcontact1@bogusco.com';
        String emailContact2 = 'testcontact2@bogusco.com';


        
        //Id CustomUserProfileId = '00e70000001FaZG'; // Profile - AMER Inside Sales/SMB User
        Id CustomUserProfileId = '00e70000001FaZGAA0';
       
        User standardUser = getTestUser(CustomUserProfileId); 
        
        system.debug(' standardUser ===>'+ standardUser  );
        
        // create 3 test account records
        Account acct1 = createNewAccount();
        Account acct2 = createNewAccount();
        Account acct3 = createNewAccount();
        
        //create a contact for each account   
        Contact cont1 = createNewContact(acct1.id,emailContact1);    
        Contact cont2 = createNewContact(acct2.id,emailContact2);
        Contact cont3;
        Contact cont4; 
        Contact cont5;
           

        //create an account share for the standard user
        //Note: user will have access to accounts 1 and 3
        List<AccountShare> shares = new List <AccountShare>(); 
        shares.add (new AccountShare(UserOrGroupId = standardUser.Id, OpportunityAccessLevel = 'Read', 
                                        CaseAccessLevel = 'Read', AccountId = acct1.Id, AccountAccessLevel = 'Read'));
        shares.add (new AccountShare(UserOrGroupId = standardUser.Id, OpportunityAccessLevel = 'Read', 
                                        CaseAccessLevel = 'Read', AccountId = acct3.Id, AccountAccessLevel = 'Read'));
        insert shares;

        System.runAs(standardUser) {
            Test.startTest();
            //Since user does not have access to account 2, he should be able to 
            //add a contact with the same email address as contact 2
            cont3 = createNewContact(acct3.id, emailContact2);
            
             //The user should not be able to add a contact with the same email address as contact 1
            try {
           
                cont4 = createNewContact(acct3.id, emailContact1);
            } catch (Exception e) {
                System.assert(e.getMessage().contains('An active contact with this email address already exists in Salesforce.com'), 'Contact creation allowed for duplicate contact');
            }
            
            //Should be able to add a contact with null email address
            cont5 = createNewContact(acct3.id, NULL);
            Test.stopTest();
        }
        
        Integer contCount = [SELECT count() FROM Contact WHERE AccountId = :acct3.id and email = :emailContact2];
        System.AssertEquals(1, contCount, 'Contact Not inserted for unshared account duplicate');
       //11-Jun-10  Prasad K 
        //contCount = [SELECT count() FROM Contact WHERE AccountId = :acct3.id and email = null];
        //System.AssertEquals(1, contCount, 'Contact Not inserted for null email address');

    }
    
    
   
    static testMethod void runTests_Bulk() {

        String standardUserProfileId = '';
        String emailContact1 = 'testcontact1@bogusco.com';
        String emailContact2 = 'testcontact2@bogusco.com';
        //Id CustomUserProfileId = '00e70000001FaZG'; // Profile - AMER Inside Sales/SMB User\
        Id CustomUserProfileId = '00e70000001FaZGAA0';        
        User standardUser = getTestUser(customUserProfileId); 
       system.debug(' standardUser ===>'+ standardUser  );
        // create 3 test account records
        Account acct1 = createNewAccount();
        Account acct2 = createNewAccount();
        Account acct3 = createNewAccount();

        List<Contact> contList = new List<Contact>();
        
        //create contacts 
        for (Integer i = 1; i <= 75; i++) {
            //cont = createNewContact(acct1.id, 'TESTContact' + i + '@bogus1co.com');    
            //cont = createNewContact(acct2.id, 'TESTContact' + i + '@bogus2co.com');
            contList.add(new Contact(accountId=acct1.id, lastname='Bogus1_'+i,email='TESTContact'+i+'@bogus1co.com', active__c = true));        
            contList.add(new Contact(accountId=acct2.id, lastname='Bogus2_'+i,email='TESTContact'+i+'@bogus2co.com', active__c = true));        
        }
        
        insert contList;
        contList.clear();

        //create an account share for the standard user
        //Note: user will have access to accounts 1 and 3
        List<AccountShare> shares = new List <AccountShare>(); 
        shares.add (new AccountShare(UserOrGroupId = standardUser.Id, OpportunityAccessLevel = 'Read', 
                                        CaseAccessLevel = 'Read', AccountId = acct1.Id, AccountAccessLevel = 'Read'));
        shares.add (new AccountShare(UserOrGroupId = standardUser.Id, OpportunityAccessLevel = 'Read', 
                                        CaseAccessLevel = 'Read', AccountId = acct3.Id, AccountAccessLevel = 'Read'));
        insert shares;

        System.runAs(standardUser) {
            
            //Since user does not have access to account 2, he should be able to add contacts that exist in account2
            //But should not be able to add contacts that exist in account1
            for (Integer i = 1; i <= 73; i++) {
                //these should be added successfully
                contList.add(new Contact(accountId=acct3.id, lastname='NBogus2_'+i,email='testcontact'+i+'@Bogus2co.com', active__c = true));
                contList.add(new Contact(accountId=acct3.id, lastname='NullName'+i,email=null, active__c = true));
                //these should fail to be added
                if (i <= 50) {
                    contList.add(new Contact(accountId=acct3.id, lastname='NBogus1_'+i,email='testcontact'+i+'@Bogus1co.com', active__c = true));
                }
            }
            //These should not be added as they are duplicates within the batch
            contList.add(new Contact(accountId=acct3.id, lastname='NBogus2_74',email='testcontact1@Bogus2co.com', active__c = true));
            contList.add(new Contact(accountId=acct3.id, lastname='NBogus2_75',email='testcontact55@Bogus2co.com', active__c = true));
            contList.add(new Contact(accountId=acct3.id, lastname='NBogus2_76',email='testcontact70@Bogus2co.com', active__c = true));
            //This should be added
            contList.add(new Contact(accountId=acct3.id, lastname='NBogus2_77',email='testcontact77@Bogus2co.com', active__c = true));
            
            Test.startTest();
            //Insert Contacts - allow partial success of transaction since we know there are duplicates that should fail.
            Database.SaveResult[] results = null;
            results = database.insert(contList, false);
            Test.stopTest();
        }
        
        Integer contCount = [SELECT count() FROM Contact WHERE AccountId = :acct3.id and email = null];
        System.AssertEquals(73, contCount, 'Contact Not inserted for null email');
         //11-Jun-10  Prasad K 
        //contCount = [SELECT count() FROM Contact WHERE AccountId = :acct3.id and email != null];
        //System.AssertEquals(74, contCount, 'Contacts Not inserted for unshared duplicates');
                
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