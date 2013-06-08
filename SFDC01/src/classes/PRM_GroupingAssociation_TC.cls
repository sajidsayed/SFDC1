/*===========================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR        DESCRIPTION                               

|  ====          =========                ==        =========== 

| 29/11/2010     Anirudh Singh            846      This is the test class used
                                                   to test the newly created
|                                                  association to include all the
                                                   accounts having same site Duns 
|                                                  as that of the profiled account.
  03-Mar-2011   Anirudh Singh            1598      Updated Test class to include 
  |                                                condtions for the new associations logic.  
+===========================================================================*/
@istest
private class PRM_GroupingAssociation_TC {

    static testmethod void testAssociationOnAccount() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        PRM_GroupingAssociation Association = New PRM_GroupingAssociation();
        Account accountPF1 = new Account (name = 'UNITTESTacc1', Site_DUNS_Entity__c = '448812', Partner_Type__c='Distributor',PROFILED_ACCOUNT_FLAG__c=true); 
        Insert accountPF1;
        
        Account accountPF2 = new Account (name = 'UNITTESTacc2', Site_DUNS_Entity__c = '223652', Partner_Type__c='Distribution VAR',PROFILED_ACCOUNT_FLAG__c=true); 
        Insert accountPF2;
        
        Account account1 = createDistributorAccount('TestAccount1');
        Account account2 = createDistributorAccount('TestAccount2');
        Account account5 = createDistributionVarAccount('TestAccount5');
        
        
        
        
        List<Account> lstAccount = new List<Account>();
        List<Account> account = new List<Account>();
        account.add(account1);
        List<Id> accountDistriVar = new List<Id>();
        accountDistriVar.add(account5.Id);
        List<Id> accountDistri = new List<Id>();
        accountDistri.add(account1.Id);
        Map<Id,Account> mapAccount = new Map<Id,Account>([Select Id,IsPartner,Lead_Oppty_Enabled__c 
                            from account 
                            where Id=:account1.Id
                            or Id=:account5.Id]);
       for(Account acnt:mapAccount.values()){
            acnt.IsPartner=true;
            acnt.Child_Partner_Users_Count__c = 2;
            lstAccount.add(acnt);
       }
             update lstAccount;     
       for(Account acc: [select Id,IsPartner,Lead_Oppty_Enabled__c 
                            from account 
                            where Id=:accountPF1.Id
                            or Id=:accountPF2.Id]){
            acc.IsPartner=true;
            acc.Lead_Oppty_Enabled__c=true;
            update acc;
        }
        //Creating the dummy grouping on the previously created account for 
        //test class.
        Account_Groupings__c TestGroup1 = createGrouping(accountPF1.Id);
        Account_Groupings__c TestGroup2 = createGrouping(accountPF2.Id);

        //Test Data Finish
        Test.startTest();

        List<APPR_MTV__RecordAssociation__c> NewAssociation = new  List<APPR_MTV__RecordAssociation__c>();

        APPR_MTV__RecordAssociation__c RecordAssociation = New APPR_MTV__RecordAssociation__c(APPR_MTV__Associated_Account__c=accountPF1.Id,APPR_MTV__Account__c=accountPF2.Id,
                               APPR_MTV__Account_Role__c='Distributor',APPR_MTV__Primary__c=true);
        Insert RecordAssociation;
        NewAssociation.add(RecordAssociation);
        Association.createAccountMap(NewAssociation);
        PRM_GroupingAssociation obj = new PRM_GroupingAssociation();
        List<APPR_MTV__RecordAssociation__c> lstRecordAssociation = obj.CreateGroupingAssociation(accountDistriVar,accountDistri);                                                              
        obj.createAssociationsforUpdate(account);
        Boolean flag = obj.isUnderLimit(mapAccount);
        Map<Id,Account> mapAcc = obj.queryOnAccount(mapAccount);
        
        obj.deleteAssociation(accountDistriVar);
        Test.stopTest();

        }



/* @Method <This method is used create Distributor accounts for the test class
            with same siteDuns Value>
@param <Taking string as paramter which contains account name>
@return <void> - <Account record>
@throws exception - <No Exception>
*/

        public static Account createDistributorAccount(String accountName){
        //Creating the dummy account for test class.
        Account account = new Account(
            name=accountName,
            Partner_Type__c='Distributor',
            Lead_oppty_enabled__c =True,
            
            APPR_MTV__Association_Account__c=True,
            CurrencyIsoCode='USD',
            Site_DUNS_Entity__c = '448812'
            
        );
        insert account;
        
        return account;
        }

/* @Method <This method is used to create Distribution VAR account 
             for the test class >
@param <Taking string as paramter which contains account name>
@return <void> - <Account record>
@throws exception - <No Exception>
*/

        public static Account createDistributionVarAccount(String accountName){
        //Creating the dummy account for test class.
        Account account = new Account(
            name=accountName,
            Partner_Type__c='Distribution Var',
            Lead_oppty_enabled__c =True,
            
            APPR_MTV__Association_Account__c=True,
            CurrencyIsoCode='USD',
            Site_DUNS_Entity__c = '223652'
            
        );
        insert account;
        
        return account;
        }
        
/* @Method <This method is used to create grouping Data 
            for the test class >
@param <Taking Id as paramter which contains account Id>
@return <void> - <Grouping record>
@throws exception - <No Exception>
*/
        public static Account_Groupings__c createGrouping(Id accountId){
            Account_Groupings__c grouping = new Account_Groupings__c();
            grouping.Name = 'TestGrouping1'+accountId;
            grouping.Active__c = true;
            grouping.Profiled_Account__c = accountId;
            grouping.No_Master_Required__c = False;

        insert grouping;
        return grouping;
    }

}