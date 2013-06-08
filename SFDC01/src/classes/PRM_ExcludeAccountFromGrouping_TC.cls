/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  14/12/2011      Anil                        Removed Queries for fetching Account and contacts and used Custom setting Data Halper
 +=========================================================================================================================*/
@isTest
private class PRM_ExcludeAccountFromGrouping_TC {
    private static testMethod void excludeAccountFromGrouping(){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        List<Account> accounts = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        insert accounts;
        for(Account account:accounts)
        {
        account.Site_DUNS_Entity__c='001017545';
        account.Grouping__c=null;
        }
        update accounts;      
        
        Account_Groupings__c grouping = new Account_Groupings__c();
        grouping.Name = 'TestClass';
        grouping.Active__c = true;
        grouping.Profiled_Account__c = accounts[0].id;
        grouping.No_Master_Required__c = false;
        insert grouping;
        
        Account_Groupings__c grouping01 = [Select id,id__c from Account_Groupings__c where id =:grouping.id ];
        
        System.debug('grouping---->'+grouping);
        System.debug('grouping01---->'+grouping01);
        System.debug('grouping01.id__c---->'+grouping01.id__c);

        List<Account> accountlist = new List<Account>();

        for(Account acct: accounts){
            acct.Grouping__c = grouping.id;
            accountlist.add(acct);
        }
        update accountlist;
        
        List<Account> accountlist01 = new List<Account>();
        for(Account acct01: accountlist){
            acct01.Selected__c=true;
            accountlist01.add(acct01);
        }
        update accountlist01;
             
        System.debug('grouping.id__c'+grouping01.id__c);
        System.currentPageReference().getParameters().put('groupingId',grouping01.Id__c);
        PRM_ExcludeAccountFromGrouping excludeAcctGrouping = new PRM_ExcludeAccountFromGrouping();        
        excludeAcctGrouping.GroupingID = grouping01.Id__c;
        System.debug('excludeAcctGrouping.GroupingID'+excludeAcctGrouping.GroupingID);
        PRM_ExcludeAccountFromGrouping.AccountWrapper accs = new PRM_ExcludeAccountFromGrouping.AccountWrapper(accountlist01[0],true); 
        accs.setChecked(true);
        accs.getChecked();
        accs.getAccountRec();
        accs.setAccountRec(accountlist01[1]);
        accs.getResult();
        accs.setResult('Success');
        
        List<PRM_ExcludeAccountFromGrouping.AccountWrapper> acctwrper = new List<PRM_ExcludeAccountFromGrouping.AccountWrapper>();
        acctwrper.add(accs);
        
        Map<Id,String> accountResult = new Map<Id,String>();
        accountResult.put(accountlist01[0].id,'error');
        
        excludeAcctGrouping.populateResult(accountResult);
        
        excludeAcctGrouping.getGroupingRecord();
        excludeAcctGrouping.getAccountWrapperlist();
        excludeAcctGrouping.getCountOfExclude();
        excludeAcctGrouping.getTotalCountOfExclude();
        excludeAcctGrouping.setAccountWrapper(acctwrper);
        excludeAcctGrouping.getAccountWrapper();
        
        System.debug('getAccountWrapper()---->'+excludeAcctGrouping.getAccountWrapper().size());
        
        excludeAcctGrouping.selectedAccounts();
        excludeAcctGrouping.setSelectedProfiledAccount(accountlist01);
        excludeAcctGrouping.getSelectedProfiledAccount();
        
        excludeAcctGrouping.deSelectAll();
        excludeAcctGrouping.selectAll();
        excludeAcctGrouping.back();
        excludeAcctGrouping.cancel();
        excludeAcctGrouping.exclude();
    }
}