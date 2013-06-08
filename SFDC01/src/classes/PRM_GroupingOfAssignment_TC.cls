@isTest

/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 02/02/2012      Anil Sure                         Fixed Test class for Feb'12 Release and Increased Coverage
   6 April 2012    Arif                              Commented 'removeGroupingFromAccount' method call.
   
================================================================================*/
private class PRM_GroupingOfAssignment_TC{
    private static testMethod void GroupingOfAssignment(){
        PRM_GroupingOfAssignment groupingObj = new PRM_GroupingOfAssignment();
        
        Map<Id,Account_Groupings__c> triggerNewMap = new Map<Id,Account_Groupings__c>();
        Map<Id,Account_Groupings__c> triggerOldMap = new Map<Id,Account_Groupings__c>();
        
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        List<Account> accout = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        insert accout;
          
        Account_Groupings__c grouping = new Account_Groupings__c();
        grouping.Name = 'TestClass323';
        grouping.Active__c = true;
        grouping.Profiled_Account__c = accout[0].id;
        grouping.No_Master_Required__c = false;
        
        insert grouping;
        grouping.Active__c = false;
        
        List<Account_groupings__c> groupingList= [select id,id__c,profiled_account__c,Profiled_Account_Site_Duns__c,master_grouping__c,active__c from account_groupings__c where id=:grouping.id];
      
        for(Account_groupings__c grp :groupingList){
            triggerOldMap.put(grp.id,grp);
            grp.master_grouping__c=grp.id;
            triggerNewMap.put(grp.Id,grp);
        }
        
        List<Account> accounts = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        insert accounts;        
        
        List<Account> accountList = new List<Account>();
        Set<String> accountSiteDuns = new Set<String>();
        Set<Id> accountIds = new Set<Id>();
        for(Account acc: accout){
            acc.Selected__c=true;
            accountSiteDuns.add(acc.Site_DUNS_Entity__c);
            accountList.add(acc);
            accountIds.add(acc.id);
        }
        update accountList;
        
        Map<String,String> AccountsGroupMap =  new Map<String,String>();
        String groupingValues = groupingList[0].id+'='+groupingList[0].master_grouping__c+'@'+groupingList[0].Profiled_Account__c;        
        String groupingId = accounts[0].Site_DUNS_Entity__c;
        
        AccountsGroupMap.put(groupingId,groupingValues);
        Test.StartTest();
        groupingObj.createGrouping(groupingList);
        groupingObj.beforeInsertOnGrouping(groupingList);
               
        Map<Id,String> accountIdWithPartnerType = new Map<Id,String>();
        accountIdWithPartnerType.put(groupingList[0].profiled_account__c,groupingValues);
        
        Map<Id,Account> accountIdWithPartnerType1 = new Map<Id,Account>();
        accountIdWithPartnerType1.put(groupingList[0].profiled_account__c,accout[0]);

        
        //groupingObj.removeGroupingFromAccount(accountSiteDuns,accountIds);
        groupingObj.updateAccounts(AccountsGroupMap,accounts);
        groupingObj.updateRelatedGrouping(AccountsGroupMap);
        groupingObj.updateRelatedPartnerType(accountIdWithPartnerType1);
        groupingObj.isUnderLimit(accountIdWithPartnerType1);
        
        groupingObj.removeGrouingFromAccount(accountIdWithPartnerType,AccountsGroupMap);
        groupingObj.fetchRelatedAccounts(accountIdWithPartnerType);
        
        groupingObj.removeAllRelatedGrouping(accountIdWithPartnerType);
        groupingObj.excludeFromGrouping(accountList,groupingList[0].id__c);
        System.debug('groupingList[0].id__c '+ groupingList[0].id__c);
        groupingObj.includeInGrouping(accountList,groupingList[0].id__c);
        groupingObj.masterGroupingUpdate(triggerNewMap, triggerOldMap);
        groupingObj.createGrouping(groupingList);
        groupingObj.updateOfGrouping(groupingList, triggerNewMap, triggerOldMap);
        groupingObj.beforeInsertOnGrouping(groupingList);
        
        Test.StopTest();
    }
}