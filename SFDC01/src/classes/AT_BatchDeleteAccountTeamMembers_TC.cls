@isTest
private class AT_BatchDeleteAccountTeamMembers_TC {
/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER       WR       DESCRIPTION                               
 |  ====       =========       ==       =========== 
 |  17-JUN-09  S Douglas                Created
 +===========================================================================*/
  static testMethod void testBatch()
  {
    //setup data for test -- we can test a maximum of 200 records for Batch Apex
    //Note that we are subject to the 500 DML governor limit and the 500 query row governor limit 
    //We will create 3 accounts and select 100 users
    //We will add the all 100 users to the account team for each of the accounts created
    //We will add the following interface table rows (to be deleted):
    //  first 75 users for account 1
    //  last 75 users for account 2
    //  no rows for account 3
    
    //Accounts
    List <Account> accounts = new List <Account>();
    accounts.add (new Account(name = 'BatchDeleteAccount1', 
                                     Site_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8)),
                                     Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8)),
                                     Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8))
                                     ));
    accounts.add (new Account(name = 'BatchDeleteAccount2', 
                                     Site_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8)),
                                     Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8)),
                                     Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8))
                                     ));
    accounts.add (new Account(name = 'BatchDeleteAccount3', 
                                     Site_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8)),
                                     Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8)),
                                     Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8))
                                     ));
    insert accounts;

    //Just query to get some users--we don't seem to be able to add them programmatically
    List<User> users = [SELECT ID FROM user where isActive = true LIMIT 100];

    //Create Account Team Records
    List <AccountTeamMember> members = new List<AccountTeamMember>();
    for (Integer x=0; x<3;x++) {
        for (Integer y=0; y<100; y++) {
            members.add (new AccountTeamMember(accountId=accounts[x].Id,
                                                userId=users[y].Id,
                                                teammemberrole='Sales-Sales Rep'));
        }
    }
    insert members; 
    
    
    //Create Interface Table records
    List <AccountTeamDelete__c> oitRecs = new List <AccountTeamDelete__c>();

    //Account 1
    for (Integer y=0; y<75; y++) {
        oitRecs.add (new AccountTeamDelete__c(accountId__c=accounts[0].Id,
                                                userId__c=users[y].Id));
    }
    //Account 2
    for (Integer y=25; y<100; y++) {
        oitRecs.add (new AccountTeamDelete__c(accountId__c=accounts[1].Id,
                                                userId__c=users[y].Id));
    }

    insert oitRecs;

    List<String> testAccts = new List<String>();
    testAccts.add(accounts[0].id);
    testAccts.add(accounts[1].id);
    String acct3id = accounts[2].id;

    //Note:  we can't check the record counts of the interface table here or we will exceed the 500 query row governor limit
    //       the 100 users we queried for counts against the limit
    //System.AssertEquals(150, Database.countQuery('SELECT count() FROM AccountTeamDelete__c WHERE AccountId__c IN :testAccts'), 'Rows Inserted into Interface Table is incorrect for accounts 1 and 2');
    //System.AssertEquals(0, Database.countQuery('SELECT count() FROM AccountTeamDelete__c WHERE AccountId__c = :acct3id'), 'Rows Inserted into Interface Table is incorrect for account 3');
    //System.AssertEquals(200, Database.countQuery('SELECT count() FROM AccountTeamMember WHERE AccountId IN :testAccts'), 'Rows Inserted into AccountTeamMembers table is incorrect for accounts 1 and 2');
    //System.AssertEquals(100, Database.countQuery('SELECT count() FROM AccountTeamMember WHERE AccountId = :acct3id'), 'Rows Inserted into AccountTeamMembers table is incorrect for account 3');
    


    AT_BatchDeleteAccountTeamMembers deleteAcctBatch =  new AT_BatchDeleteAccountTeamMembers();
    deleteAcctBatch.unitTestAccounts = testAccts;
    deleteAcctBatch.query = 'SELECT Id, AccountId__c, UserId__c, LastModifiedDate FROM AccountTeamDelete__c WHERE ProcessedFlag__c = false AND AccountId__c IN :unitTestAccounts LIMIT 200';
    Test.startTest();
    ID batchprocessid = Database.executeBatch(deleteAcctBatch);
    System.Debug('Batch Process Id = ' + batchprocessid);
    Test.stopTest(); 
    System.AssertEquals(50, Database.countQuery('SELECT count() FROM AccountTeamMember WHERE AccountId IN :testAccts'),'AccountTeam Member record count incorrect after Batch Apex program for accounts 1 and 2');
    System.AssertEquals(100, Database.countQuery('SELECT count() FROM AccountTeamMember WHERE AccountId = :acct3id'),'AccountTeam Member record count incorrect after Batch Apex program for account 3');
    
  }


}