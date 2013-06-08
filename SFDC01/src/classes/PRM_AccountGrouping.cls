/*================================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR        DESCRIPTION                               

|  ====          =========                ==        =========== 

| 22/9/2010      Karthik Shivprakash      1077      This class is used to create the 
                                          1078      grouping on newly created accounts
|                                                   if it has same siteDuns of the 
                                                    existing accounts and to suggest 
|                                                   grouping if the accounts has 
                                                    same globalDuns.
| 27/9/2010     Karthik Shivprakash       Def#124   Changed the query against grouping
                                                    to account.
| 30/9/2010     Karthik Shivprakash       Def#134   Added a new method setAssociation
                                                    to create association on accounts
|                                                   based on siteDuns/Profile Account.
  30/12/2011    Accenture                 183066    Updated setGrouping() method to set 
|                                                   velocity Tier field values for the 
													newly created accounts if they have same 
|													siteDUNS value as that of the existing accounts.																				  
+==================================================================================================*/

public with sharing class PRM_AccountGrouping {


PRM_RecordsVisibility associationObj = new PRM_RecordsVisibility();

//Used to store the newly created accounts which has the same siteDuns of the
//existing accounts.
List<Account> AccountsOfSameSiteDuns = new List<Account>();

//Used to store the newly created accounts which has the same globalduns 
//as of the partner grouping.
List<Account> AccountsOfSameGlobalDuns = new List<Account>();

/*@Method <This method processAccountForGrouping is used to fetch the newly 
            created accounts from the trigger and create 2 maps based on 
            siteDuns and globalDuns>
@param <This method take one List<Account> as parameters>
 AccountsFromTrigger -- <which contains the newly create accounts>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/

    public void processAccountForGrouping(List<Account> AccountsFromTrigger){
        Map<String,List<Account>> AccountsWithSiteDunsMap = new Map<String,List<Account>>();
        Map<String,List<Account>> AccountsWithGlobalDunsMap = new Map<String,List<Account>>();
        for(Account acct: AccountsFromTrigger){
            if(acct.Site_DUNS_Entity__c!=null){
                List<Account>  ExistingAccountsOfSiteDuns =AccountsWithSiteDunsMap.get(acct.Site_DUNS_Entity__c);
                if(ExistingAccountsOfSiteDuns==null){
                    ExistingAccountsOfSiteDuns = new List<Account>();
                }
                ExistingAccountsOfSiteDuns.add(acct);
                AccountsWithSiteDunsMap.put(acct.Site_DUNS_Entity__c,ExistingAccountsOfSiteDuns);
            }
            if(acct.Global_DUNS_Entity__c!=null){
                List<Account>  ExistingAccountsOfGlobalDuns =AccountsWithGlobalDunsMap.get(acct.Global_DUNS_Entity__c);
                if(ExistingAccountsOfGlobalDuns==null){
                    ExistingAccountsOfGlobalDuns = new List<Account>();
                }
                ExistingAccountsOfGlobalDuns.add(acct);
                AccountsWithGlobalDunsMap.put(acct.Global_DUNS_Entity__c,ExistingAccountsOfGlobalDuns);
            }
        }
        if(AccountsWithSiteDunsMap.size()>0 || AccountsWithGlobalDunsMap.size()>0){
            updateGroupingDetail(AccountsWithSiteDunsMap,AccountsWithGlobalDunsMap);
        }
    }


/*@Method <This method updateGroupingDetail is used to fetch the newly created
            accounts and store the accounts based on its siteDuns and globalDuns
            comparing with existing accounts and grouping>
@param <This method take 2 Map<String,List<Account>> as parameters>
 AccountsWithSiteDunsMap -- <which contains the siteDuns as key and List of 
                             account>
 AccountsWithGlobalDunsMap -- <which contains the globalDuns as key and List
                              of account>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/

    public void updateGroupingDetail(Map<String,List<Account>> AccountsWithSiteDunsMap,
                                          Map<String,List<Account>> AccountsWithGlobalDunsMap){
        
        System.debug('accountsWithSiteDunsMap-->'+accountsWithSiteDunsMap);
        System.debug('accountsWithGlobalDunsMap-->'+accountsWithGlobalDunsMap);
        //Changed the query for the defect#124
        for(Account accObject: [select Partner_Type__c,id,name,Site_DUNS_Entity__c,Profiled_Account__c,Affiliate_Services__c,Velocity_Specialties_Achieved__c,
                                    Global_DUNS_Entity__c,PROFILED_ACCOUNT_FLAG__c,Grouping__c,Master_Grouping__c ,VSI_Approved_Delivery_Products__c,
                                    Profiled_Account__r.Affiliate_Services__c,Profiled_Account__r.Velocity_Specialties_Achieved__c,Profiled_Account__r.VSI_Approved_Delivery_Products__c
                                    from account 
                                    where Grouping__c!=null 
                                       and ( Site_DUNS_Entity__c in :AccountsWithSiteDunsMap.keySet() or 
                                             Global_DUNS_Entity__c in :AccountsWithGlobalDunsMap.keySet())]){
            if(AccountsWithSiteDunsMap.containsKey(accObject.Site_DUNS_Entity__c)){
                if(accObject.Grouping__c!=null){
                    setGrouping(accountsWithSiteDunsMap.get(accObject.Site_DUNS_Entity__c),accObject);
                }
                AccountsWithSiteDunsMap.remove(accObject.Site_DUNS_Entity__c);
                AccountsWithGlobalDunsMap.remove(accObject.Site_DUNS_Entity__c);
            }
            else if(AccountsWithGlobalDunsMap.containsKey(accObject.Global_DUNS_Entity__c)){
                System.debug('accountsOfSameGlobalDuns--->'+accountsOfSameGlobalDuns);
                if(accObject.Grouping__c!=null){
                    setSuggestGrouping(AccountsWithGlobalDunsMap.get(accObject.Global_DUNS_Entity__c),accObject);
                }
                AccountsWithGlobalDunsMap.remove(accObject.Site_DUNS_Entity__c);    
            }
            if(AccountsWithSiteDunsMap.size()==0 && AccountsWithGlobalDunsMap.size()==0){
                break;  
           }
        }
    }

/*@Method <This method setGrouping is used to add the grouping for the
            new accounts based on its siteDuns, if it matches with any 
            existing accounts siteDuns which has parnter grouping on it.>
@param <This method takes one Map<Account,String> as parameter>
 AccountsOfSameSiteDuns -- <which contains the list of accounts of same siteDuns>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/

    public void setGrouping(List<Account> AccountsOfSameSiteDuns,Account AccountToReplicate){
        
        List<Id> NonProfiledAccountId = new List<Id>();
        for(Account accountObject: AccountsOfSameSiteDuns){
                accountObject.Grouping__c = AccountToReplicate.Grouping__c;
                //Checking whether account is profiled account or Non-profiled account.
                if(AccountToReplicate.PROFILED_ACCOUNT_FLAG__c !=true){
                    accountObject.Profiled_Account__c = AccountToReplicate.Profiled_Account__c;
                    accountObject.Velocity_Specialties_Achieved_TA__c=AccountToReplicate.Profiled_Account__r.Velocity_Specialties_Achieved__c;
                    accountObject.Affiliate_Services_TA__c=AccountToReplicate.Profiled_Account__r.Affiliate_Services__c;
                    accountObject.VSI_Approved_Delivery_Products_TA__c=AccountToReplicate.Profiled_Account__r.VSI_Approved_Delivery_Products__c;
                    System.debug('Profiled Account'+AccountToReplicate.Profiled_Account__c);
                }
                else{
                    accountObject.Profiled_Account__c = AccountToReplicate.Id;
                    accountObject.Velocity_Specialties_Achieved_TA__c=AccountToReplicate.Velocity_Specialties_Achieved__c;
                    accountObject.Affiliate_Services_TA__c=AccountToReplicate.Affiliate_Services__c;
                    accountObject.VSI_Approved_Delivery_Products_TA__c=AccountToReplicate.VSI_Approved_Delivery_Products__c;
                }
                accountObject.Master_Grouping__c = AccountToReplicate.Master_Grouping__c;
                //Added to update the account with partner type.
                accountObject.Partner_Type__c = AccountToReplicate.Partner_Type__c;
        }
    }

/*@Method <This method setSuggestGrouping is used to suggest the grouping 
            for the new accounts based on its globalDuns>
@param <This method takes one Map<Account,String> as parameter>
 AccountsOfSameGlobalDuns -- <which contains the account as key and partner
                              grouping name>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/
    
    public void setSuggestGrouping(List<Account> AccountsOfSameGlobalDuns,Account AccountToReplicate){
        for(Account accountObj: AccountsOfSameGlobalDuns){
            System.debug('AccountToReplicate in Suggested -->'+AccountToReplicate.Grouping__c);
            if(accountObj.Grouping__c==null){
                accountObj.Suggested_Partner_Grouping__c = AccountToReplicate.Grouping__c;
            }
        }
    }
    
/*@Method <This method setAssociation is used to create association 
            on the newly inserted accounts after adding into grouping>
@param <This method takes List<Account> as parameter>
 AfterInsertOfAccountList -- <which contains the newly inserted accounts>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/    
    //Added for the defect#134
    public void setAssociation(List<Account> AfterInsertOfAccountList){
        
        //Used to store the Profile account Id and list of non-profiled accounts
        //based on siteDuns.
        Map<Id,List<Id>> CreateAssociationMap = new Map<Id,List<Id>>();
        for(Account acct: AfterInsertOfAccountList){
            //The Profiled Account value is populate from the AccountBeforeInsert
            if(!acct.PROFILED_ACCOUNT_FLAG__c && acct.Profiled_Account__c!=null){
                List<Id> NonProfiledAccountIds = createAssociationMap.get(acct.Profiled_Account__c);
                if(NonProfiledAccountIds==null){
                    NonProfiledAccountIds = new List<Id>();
                }
                NonProfiledAccountIds.add(acct.Id);
                System.debug('NonProfiledAccountIds-->'+NonProfiledAccountIds);
                createAssociationMap.put(acct.Profiled_Account__c,NonProfiledAccountIds);
                System.debug('createAssociationMap-->'+createAssociationMap);
            }
        }
        if(createAssociationMap.size()>0){
            associationObj.createAccountAssociation(createAssociationMap);
        }
    }
}