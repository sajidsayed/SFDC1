/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 25/11/2010      Karthik Shivprakash     846       This class is used to select all 
                                                     the sites within a group when 
 |                                                   creating an association if it 
                                                     is exceeding DML limits.
 |                                                                       
 +===========================================================================*/

public with sharing class PRM_GroupingAssociationOperation {

//Here creating the instance of the util class PRM_RecordVisibility
PRM_RecordsVisibility associationObj = new PRM_RecordsVisibility();

//Use to store SiteDuns and Profiled Accounts
Map<String,Account> ProfiledAccountSiteDuns = new Map<String,Account>();

//Use to store Account Id and Associated account Id
Map<Id,Id> AccountAndAssociatedAccountMap = new Map<Id,Id>();


/* @Method <This method is used to fetch the related account Ids against 
            the profiled account's Site Duns>
   @param <This is not taking any parameters>
   @return <void> -- <Returns nothing>.
   @throws exception - <No Exception>
*/

    public void fetchingOfBulkAccounts(){
        
        List<Account> ProfiledAccountList;
        //List<Id> ProfiledAccountsId = new List<Id>();
        Integer IndexValue;
                
        ProfiledAccountList = new List<Account>([select a.Site_DUNS_Entity__c,  
                                                a.Grouping_Batch_Operation__c, a.Id,
                                                a.PROFILED_ACCOUNT_FLAG__c ,
                                                a.Profiled_Account__c
                                                from Account a
                                                where a.Grouping_Batch_Operation__c like 'Association%']);
        
        for(Account accObj: ProfiledAccountList){
            String GroupingAssociation = accObj.Grouping_Batch_Operation__c;
            IndexValue = GroupingAssociation.indexOf('&');
            ID AssociationAccountID = GroupingAssociation.substring(IndexValue+1);
            System.debug('AssociationAccount ID'+AssociationAccountID); 
            AccountAndAssociatedAccountMap.put(accObj.Id,AssociationAccountID);
            System.debug('AccountAndAssociatedAccountMap'+AccountAndAssociatedAccountMap);
            ProfiledAccountSiteDuns.put(accObj.Site_DUNS_Entity__c,accObj);
            //ProfiledAccountsId.add(accObj.Id);
        }
        
        if(ProfiledAccountSiteDuns.size()>0){
            creatingAssociationOnBulk(ProfiledAccountSiteDuns);
        }
    }


/* @Method <This method is used to create the accounts association with the related
             accounts of same siteDuns of the profiled accounts of type Distributor 
             or Distribution VAR>
   @param <This is taking Map of String and Accounts>
   <ProfiledAccountSiteDuns -- Map which contains Profiled account Site Duns and
                                account details>
   @return <void> -- <Returns nothing>
   @throws exception - <No Exception>
*/

    public void creatingAssociationOnBulk(Map<String,Account> ProfiledAccountSiteDuns){
        
        Map<Id,Account> RelatedAccountsMap;
        Map<Id,List<Id>> AccountsWithAssociationAccount = new Map<Id,List<Id>>();
        List<Id> RelatedAccountsId = new List<Id>();
        
        RelatedAccountsMap = new Map<Id,Account>([select a.Site_DUNS_Entity__c,  
                                                    a.Grouping_Batch_Operation__c, a.Id,
                                                    a.PROFILED_ACCOUNT_FLAG__c ,
                                                    a.Profiled_Account__c
                                                    from Account a
                                                    where a.Site_DUNS_Entity__c=:ProfiledAccountSiteDuns.keySet()]);
        
        System.debug('RelatedAccountsMap'+RelatedAccountsMap);
        
        for(Account acct: RelatedAccountsMap.values()){
            if(acct.PROFILED_ACCOUNT_FLAG__c!=true){
                RelatedAccountsId.add(acct.Id);
                AccountsWithAssociationAccount.put(AccountAndAssociatedAccountMap.get(acct.Profiled_Account__c),RelatedAccountsId);
            }
        }
        System.debug('AccountsWithAssociationAccount'+AccountsWithAssociationAccount);
        System.debug('RelatedAccountsId'+RelatedAccountsId);
        
        if(AccountsWithAssociationAccount.size()>0){
            associationObj.createAccountAssociation(AccountsWithAssociationAccount);
        }
    }

}