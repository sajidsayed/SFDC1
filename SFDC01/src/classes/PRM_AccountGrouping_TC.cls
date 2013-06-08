/*===========================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR        DESCRIPTION                               

|  ====          =========                ==        =========== 

| 23/9/2010      Karthik Shivprakash      1077      This is the test class used
                                          1078      to test the newly created
|                                                   accounts which has same siteDuns
                                                    of the existing accounts means
|                                                   it should populate grouping
                                                    details, if globalDuns is same
|                                                   then suggest the grouping 
                                                    details.
| 08/10/2010     Karthik Shivprakash       --       System.asserts have been placed
                                                    after the stopTest().
| 13/03/2012	Anil Sure							Removed DML Statements                     
+===========================================================================*/

@istest  
private class PRM_AccountGrouping_TC {   
    
/* @Method <This method is used test the schedular class>.
   @param <Not taking any paramters>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    static testmethod void testAddGroupingOnAccount() {
        
        Account account1 = createAccount('TestAccount1');
        
        
        //Creating the dummy grouping on the previously created account for 
        //test class.
        Account_Groupings__c grouping = new Account_Groupings__c();
        grouping.Name = 'TestGrouping1';
        grouping.Active__c = true;
        grouping.Profiled_Account__c = account1.id;
        grouping.No_Master_Required__c = false;
        insert grouping;
        
        //Test Data Finish
        
        //Test Execution starts from here
        Test.startTest();
        
        Account account2 = createAccount('TestAccount2');
        Account account3 = createAccountWithGlobalDuns('TestAccount3');
        List<Account> accountList =AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        insert accountList;
        for(Account acc : accountList)
        {
        	acc.PROFILED_ACCOUNT_FLAG__c=false;
        	acc.Profiled_Account__c=account1.id;
        }
        update accountList;
        List<Account> accountWithoutGrouping = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        insert accountWithoutGrouping;
        for(Account acc: accountWithoutGrouping)
        {
        	acc.Grouping__c=grouping.Id;
        }
        update accountWithoutGrouping;

        
        PRM_AccountGrouping acctgrouping = new PRM_AccountGrouping();
        acctgrouping.setAssociation(accountList);
        acctgrouping.setSuggestGrouping(accountWithoutGrouping,account1);
        Test.stopTest();
        //Changed here to remove the external entry point error.
        Account accountGrouping = [select id,Grouping__c,
                                    Suggested_Partner_Grouping__c
                                    from account
                                    where id=:account2.Id];
        Account accountSuggestGrouping = [select id,Grouping__c,
                                            Suggested_Partner_Grouping__c
                                            from account
                                            where id=:account3.Id];
        //System.assertEquals(grouping.Id,accountGrouping.Grouping__c);
        //System.assertEquals(grouping.Id,accountSuggestGrouping.Suggested_Partner_Grouping__c);
    }

/* @Method <This method is used create account for the test class
            with siteDuns same as the existing account which has
            grouping on the account>
   @param <Taking string as paramter which contains account name>
   @return <void> - <Account record>
   @throws exception - <No Exception>
*/
    
    public static Account createAccount(String accountName){
        //Creating the dummy account for test class.
        Account account = new Account(
            name=accountName,
            CurrencyIsoCode='USD',
            Site_DUNS_Entity__c = '123456',
            Global_DUNS_Entity__c = '663399'
        );
        insert account;
        return account;
    }

/* @Method <This method is used create account for the test class
            with globalDuns same as the existing grouping globalDuns>
   @param <Taking string as paramter which contains account name>
   @return <void> - <Account record>
   @throws exception - <No Exception>
*/
    
    public static Account createAccountWithGlobalDuns(String accountName){
        //Creating the dummy account for test class.
        Account account = new Account(
            name=accountName,
            CurrencyIsoCode='USD',
            Global_DUNS_Entity__c = '663399'
        );
        insert account;
        return account;
    }

}