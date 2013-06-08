/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 19/7/2010       Karthik Shivprakash     141592     This class update the profile accounts with grouping
                                                      and master grouping and similar account which has same SITE DUNS/ENTITY ID.
                                                      If the group becomes inactive, then it remove the grouping and 
                                                      master grouping names from both the profiled accounts and its similar account
                                                      which has same SITE DUNS/ENTITY ID.
 | 
 
 | 27/7/2010       Karthik Shivprakash     Defect#24  Added on condition in the updateOfGrouping() method.
 
 | 29/7/2010       Karthik Shivprakash     Defect#30  Updated the masterGroupingUpdate method.
 
 | 02/08/2010      Karthik Shivprakash     CR         Added one method updateRelatedPartnerType to update the related accounts 
                                                      with the Partner Type value when Partner Type field on profiled Account changes.
 0
 | 05/08/2010      Karthik Shivprakash     Defect#70,71 Added one method validate() to validate grouping field on account, if the 
                                                        grouping is active on that grouping not allowing to change it.
 
 |                                             --       And added on more method removeGroupingFromAccount() to remove the grouping details
                                                        from the related accounts based on SiteDuns. 
                                               --       removeAllRelatedGrouping() to remove all the accounts which has same 
                                                        grouping of profiled account. 
                                               
 | 09/09/2010      Ashwini Gowda            Req # 991   Fix for DML Exceptions in case if its exceeding the DML Limits. 
                                                        Scenarios: While Updating Non Profiled Account,
                                                        Creating Grouping, Updating Grouping, Deactivating Grouping.
 | 27/09/2010      Karthik Shivprakash      WR#1077     Once account is added into
                                                        the grouping, making the
 |                                                      suggested field null.
   28/09/2010      Ashwini Gowda           Defect #119  When a profiled account on inactive grouping is getting added directly or 
 |                                                      indirectly(by same site duns) the profiled account flag should get change. 
                                                        Please note that on grouping deactiavation is not unchecking the profiled account flag.
 | 30/09/2010      Ashwini Gowda                        Updated Methods modifyProfiledAccounts(),updateOfGrouping(),createGrouping() to
                                                        remove duplicate Associations.  
 | 12/10/2010      Ashwini Gowda           WR#1179      Updated Method updateRelatedPartnerType() to remove
                                                        too many rows error when a Partner Type field is updated
 |                                                      on Account.   
   17/02/2011      Anirudh Singh           WR#2119      Updated removeAllRelatedGrouping Method to set the Value of the 
 |                                                      Profiled Account Flag to False if Grouping becomes inactive. 
   23/12/2011      Accenture               WR#183066    Updated Code to set Velocity Tier Field Values on Non Profiled Account Based on Profiled Account
 | 
   27/02/2012      Anil                                 Fixed System.StringException: Invalid id: null  
 | 
   09/05/2012      Accenture               WR#183066    Updated Code to set Velocity Tier Field Values on Non Profiled Account Based on Profiled Account
 | 
 | 22/05/2013      Suresh Dornadula        WR#239600    Added the Isilon_Track_Specialty__c to the queries and respective methods                                                    
 +===============================================================================*/

 
public class PRM_GroupingOfAssignment{

public static boolean PRM_Logic_Executed=false;
//Used for bypassing DML Limit in Trigger on Account
public static boolean isRelatedSiteDunsExceedingLimit=false;
//Here we are creating the instance for creating and removing association for accounts.
PRM_RecordsVisibility associationObj = new PRM_RecordsVisibility();
//This flage is set to avoid the execution of the trigger AfterUpdateOfAccountGrouping
public Static boolean PartnerGroupingCreation=false;
//This map contains the siteDuns with corresponding Profiled Account
public static Map<String,Id> siteDunsAndProfiledAccount = new Map<String,Id>();
public static List<Account> siteDunsAccountList = new List<Account>();

public Map<String,String> siteDunsOfAccount = new Map<String,String>();
public Static Set<String> processedSiteDuns = new Set<String>();
public static Set<Id> accountIdSet = new Set<Id>();

/* @Method <This method is used to update the profiled accounts with grouping name and master grouping names>.
   @param <This is taking two maps one Profiled account,sitedDuns with its corresponding account id's>
   <ProfiledAccountWithSiteDuns -- Which contains profiled account and grouping details>
   <siteDunsWithGrouping -- which contains siteDuns and along with grouping details>
   @return boolean <boolean value>
                        Returns True if the size of the AccountMap is Greater than DML Limit else False.
   @throws exception - <No Exception>
*/

    public boolean modifyProfiledAccounts(Map<Id,String> profieldAccountWithSiteDuns,Map<String,String> siteDunsWithGrouping,String Operation){
        System.debug('Profiled Account Map'+profieldAccountWithSiteDuns);
         //Contains the SITE_DUNS/ENTITY_ID of profiled account along with grouping+master grouping value
        Map<String,String> siteDunsOfAccount = new Map<String,String>();
        //This list is used to update the account with grouping value+master grouping value+ profiled account flage
        Map<id,Account> accountMap = new Map<id,Account>([select Partner_Type__c,id,name,Site_DUNS_Entity__c,Profiled_Account__c,VSI_Approved_Delivery_Products__c,
                                                          PROFILED_ACCOUNT_FLAG__c,Grouping__c,Master_Grouping__c,VSI_Approved_Delivery_Products_TA__c,
                                                          Velocity_Specialties_Achieved_TA__c,Velocity_Specialties_Achieved__c,Affiliate_Services_TA__c,Affiliate_Services__c
                                                          from account 
                                                          where Site_DUNS_Entity__c in :siteDunsWithGrouping.keySet()]);
        //Iterating through profiled accounts for updation
        //Added for DML Exception fix
        //Check whether the size of the result is under DML Limit or not
        boolean UpdateUnderLimit = isUnderLimit(accountMap);
        System.debug('UpdateUnderLimit----->'+UpdateUnderLimit);
        Set<Id> profiledId = profieldAccountWithSiteDuns.keySet();
        System.debug('ProfileID'+profiledId);
        List<Account> ProfiledAccountsToUpdate= new List<Account>();
        Map<Id,List<Id>> createAssociationMap = new Map<Id,List<Id>>();
        
        for(Account acct: accountMap.values()){
            // if crossing limit then update profiled accounts only
            if(!UpdateUnderLimit && profiledId.contains(acct.Id)){
                /*If Operation is grouping creation during bulkification Grouping_Batch_Operation__c
                 is set to 'UpdateRelatedSiteDuns' else 'MasterGroupingUpdated'*/                           
                acct.Grouping_Batch_Operation__c=(Operation =='Creation')? 'UpdateRelatedSiteDuns': 'MasterGroupingUpdated';
                System.debug('acct.Grouping_Batch_Operation__c-->'+acct.Grouping_Batch_Operation__c);
                //seting grouping details  
                String groupingValue = siteDunsWithGrouping.get(acct.Site_DUNS_Entity__c);
                acct.PROFILED_ACCOUNT_FLAG__c=true;           
                Account profiledAccount = setGroupingDetails(acct,groupingValue,accountMap); 
                profiledAccount.Profiled_Account__c=null;
                System.debug('profiledAccount--->'+profiledAccount);
                ProfiledAccountsToUpdate.add(profiledAccount);
                continue; // no need to process as batch job will take care       
            }
            //Process profiled Accounts
            else if(UpdateUnderLimit){
                if(profiledId.contains(acct.Id)){
                    System.debug('coming here');    
                    acct.PROFILED_ACCOUNT_FLAG__c=true;
                    String groupingValue = siteDunsWithGrouping.get(acct.Site_DUNS_Entity__c); 
                    Account profiledAccount = setGroupingDetails(acct,groupingValue,accountMap);                    
                    profiledAccount.Profiled_Account__c=null;
                    profiledAccount.VSI_Approved_Delivery_Products_TA__c=null;
                                           
                }else{ //Process non profiled Accounts
                    System.debug('coming here....');  
                    String groupingValue = siteDunsWithGrouping.get(acct.Site_DUNS_Entity__c); 
                    setGroupingDetails(acct,groupingValue,accountMap);
                }  
            }              
         }        
        //updating the profiled account with grouping+mastergrouping values
        //Added for DML Exception fix
        System.debug('ProfiledAccountsToUpdate.size()---->'+ProfiledAccountsToUpdate.size());
        if(ProfiledAccountsToUpdate.size()>0){
            update ProfiledAccountsToUpdate;
            //System.debug('ProfiledAccountsToUpdate-->'+ProfiledAccountsToUpdate);
        }else{
            update accountMap.values(); 
            //Commented this to remove duplication in association for def 119
            /*createAssociationMap=fetchRelatedSiteDuns(profieldAccountWithSiteDuns);
            associationObj.createAccountAssociation(createAssociationMap);*/
        }    
        //Returning the map siteDunsOfAccount which contains siteDuns of profiled account 
        //along with group and master grouping name. return siteDunsOfAccount;
        return UpdateUnderLimit;
        }
        
        private Account setGroupingDetails(Account acc,String groupingValue,Map<id,Account> accountMap){
            //fetching the grouping value and master grouping value from the map            
            Integer indexValue1 = groupingValue.indexOf('=');
            Integer indexValue2 = groupingValue.indexOf('@');
            String groupingName = groupingValue.substring(0,indexValue1);
            String masterGroupingName = groupingValue.substring(indexValue1+1,indexValue2);
            String profiledAccountName = groupingValue.substring(indexValue2+1);
            /*System.debug('Grouping Name'+groupingName);
            System.debug('Master Grouping Name'+masterGroupingName);
            System.debug('Profile Account'+profiledAccountName);*/
            acc.Grouping__c = groupingName;
            acc.Profiled_Account__c=profiledAccountName;
            acc.IsPartner=true;
            //Added for the WR1077
            acc.Suggested_Partner_Grouping__c=null;
            acc.Partner_Type__c=accountMap.get(profiledAccountName).Partner_type__c;
            acc.VSI_Approved_Delivery_Products_TA__c= accountMap.get(profiledAccountName).VSI_Approved_Delivery_Products__c;
            acc.Velocity_Specialties_Achieved_TA__c=accountMap.get(profiledAccountName).Velocity_Specialties_Achieved__c;
            acc.Affiliate_Services_TA__c=accountMap.get(profiledAccountName).Affiliate_Services_TA__c;
            System.debug('Groupname in Account'+acc.grouping__c);
            //Checking whether the master grouping value is same as grouping value
            if(masterGroupingName !='null'){ 
                //System.debug('Updating the Mastring grouping');
                acc.Master_Grouping__c=masterGroupingName;
                }
            else{
                //System.debug('Updating the master grouping with same grouping name');
                acc.Master_Grouping__c=groupingName; 
                }  
            System.debug('Account value----->'+acc);              
            return acc;
        }        
   
/* @Method <isUnderLimit(): This method is used to check the size of accountMap.If its greater than or 
                            equal to DML Limit bypass the regular process of association and call scheduler>
   @param <accountMap>
   <accountMap--Which contains profiled account and all accounts with same SiteDuns as that of Profiled Account>
    @return <boolean > - <boolean value>
                        Returns True if the size of the AccountMap is Greater than DML Limit else False.
   @throws exception - <No Exception>
*/
   public boolean isUnderLimit(Map<id,Account> accountMap){
       boolean notUnderLimit=true;
       if(accountMap.values().size()>= Limits.getLimitDMLRows()){
       //if(accountMap.values().size()>= 10){
           notUnderLimit=false;
       }       
       return notUnderLimit;
   }
      
/* @Method <This method is used to update the accounts once any account grouping is changed>
   @param <AccountsGroupMap,accounts>
   <AccountsGroupMap -- Which contains profiled account and grouping details>
   <accounts -- which contains account details>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

   public void updateAccounts(Map<String,String> AccountsGroupMap,List<Account> accounts){     
      Map<Id,Account_Groupings__c> GroupMap= new Map<Id,Account_Groupings__c>([select id,Active__c,Profiled_Account_Site_Duns__c,
                                                                                Profiled_Account__c,Master_Grouping__c,
                                                                                Profiled_Account__r.VSI_Approved_Delivery_Products__c,
                                                                                Profiled_Account__r.Advanced_Consolidate_Specialty__c,Profiled_Account__r.Consolidate_Specialty__c,
																				Profiled_Account__r.Governance_and_Archive_Specialty__c,Profiled_Account__r.Isilon_Track_Specialty__c,
																				Profiled_Account__r.Backup_and_Recovery_Speciality__c,
																				Profiled_Account__r.Affiliate_Services__c,Profiled_Account__r.Master_Agreement__c,
																				Profiled_Account__r.Master_Site_ID__c,Profiled_Account__r.Velocity_Solution_Provider_Tier__c,
																				Profiled_Account__r.Velocity_Services_Implement__c,Profiled_Account__r.Velocity_Specialties_Achieved__c
                                                                                from Account_Groupings__c 
                                                                                where id in :AccountsGroupMap.values()]);//added Isilon_Track_Specialty__c as part of 239600
      Map<Id,List<Id>> createAssociationOnAccount = new Map<Id,List<Id>>();
      Map<Id,String> profiledAccountWithGroup = new Map<Id,String>();
      List<Account> accountToUpdate = new List<Account>();
      System.debug('Group Map in update of accounts'+GroupMap);
      for(Account acc : accounts){
          //Defect#70 added condition to check grouping null and making related fields null here.
          if(acc.Grouping__c==null){
              acc.Master_Grouping__c=null;
              acc.Profiled_Account__c=null;          
              continue;
          }
          Account_Groupings__c grp = GroupMap.get(acc.Grouping__c);
          acc.Master_Grouping__c = grp.Master_Grouping__c;
          acc.Profiled_Account__c =  grp.Profiled_Account__c;
          //Added for WR1077
          acc.Suggested_Partner_Grouping__c=null;
          acc.VSI_Approved_Delivery_Products__c=grp.Profiled_Account__r.VSI_Approved_Delivery_Products__c;
          acc.Advanced_Consolidate_Specialty__c=grp.Profiled_Account__r.Advanced_Consolidate_Specialty__c;
          acc.Consolidate_Specialty__c= grp.Profiled_Account__r.Consolidate_Specialty__c;
          acc.Governance_and_Archive_Specialty__c= grp.Profiled_Account__r.Governance_and_Archive_Specialty__c;
          acc.Backup_and_Recovery_Speciality__c= grp.Profiled_Account__r.Backup_and_Recovery_Speciality__c;
          acc.Isilon_Track_Specialty__c= grp.Profiled_Account__r.Isilon_Track_Specialty__c;
          acc.Velocity_Specialties_Achieved__c = grp.Profiled_Account__r.Velocity_Specialties_Achieved__c;
          acc.Affiliate_Services__c= grp.Profiled_Account__r.Affiliate_Services__c;
          acc.Master_Agreement__c= grp.Profiled_Account__r.Master_Agreement__c;
          acc.Master_Site_ID__c= grp.Profiled_Account__r.Master_Site_ID__c;
          acc.Velocity_Solution_Provider_Tier__c= grp.Profiled_Account__r.Velocity_Solution_Provider_Tier__c;
          acc.Velocity_Services_Implement__c= grp.Profiled_Account__r.Velocity_Services_Implement__c;
          acc.isPartner=true;
          System.Debug('accValueto update---->' +acc);
          accountToUpdate.add(acc);
          String groupDetails = grp.id+'='+grp.Master_Grouping__c+'@'+grp.Profiled_Account__c;
          System.debug('Group Details in updateAccounts'+groupDetails);
          //Changes done here
          if(grp.Profiled_Account__c!=null){
              profiledAccountWithGroup.put(acc.Id,groupDetails);
          }
      }
      	
      //Defect#71 creating association for the accounts.

        if(profiledAccountWithGroup.size()>0){
            createAssociationOnAccount=fetchRelatedSiteDuns(profiledAccountWithGroup);
            //System.debug('createAssociationOnAccount-->'+createAssociationOnAccount.values()[0].size());
            integer AssocotionsToCreate=0;
            for(integer i=createAssociationOnAccount.values().size()-1;i>=0;i--){
                AssocotionsToCreate=AssocotionsToCreate+createAssociationOnAccount.values()[i].size();
            }
            if(AssocotionsToCreate>=Limits.getLimitDMLRows()){
                for(Account account: accounts){
                    account.Grouping_Batch_Operation__c = 'updateGroupingOnAccount';
                    System.debug('account.Grouping_Batch_Operation__c-->'+account.Grouping_Batch_Operation__c);
                }
                PRM_GroupingOfAssignment.isRelatedSiteDunsExceedingLimit = true;
            }  
            else{   
                associationObj.createAccountAssociation(createAssociationOnAccount);
            }
         }
       
   }

/* @Method <This method is used to  the fields grouping,master grouping and
             profiled account based on related SiteDuns>
   @param <accountSiteDuns,accountsId>
   <accountSiteDuns -- Which contains SiteDuns of the account after validate method>
   <accountsId -- which contains account Ids which got updated>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

    public void removeGroupingFromAccount(Set<String> accountSiteDuns,Set<Id> accountsId){
        List<Account> accountsWithSiteDuns = [select id,Master_Grouping__c,Grouping__c,Profiled_Account__c,
                                               Site_DUNS_Entity__c,Profiled_Account_Flag__c
                                               from account 
                                               where Site_DUNS_Entity__c in :accountSiteDuns and id not in:accountsId];
        System.debug('Accounts to remove on accountupdate'+accountsWithSiteDuns);        
        if(accountsWithSiteDuns.size()>=Limits.getLimitDMLRows()){
            List<Account> accountsWithNullifiedGrouping = [select id,Master_Grouping__c,Grouping__c,Profiled_Account__c,
                                                           Site_DUNS_Entity__c,Profiled_Account_Flag__c 
                                                           from account 
                                                           where id in:accountsId];
            for(Account account: accountsWithNullifiedGrouping){
                account.Grouping_Batch_Operation__c = 'Grouping Nullified';
            }   
            update accountsWithNullifiedGrouping;           
        }
        else{
            Map<String,String> relatedSiteDuns = new Map<String,String>();
            Map<Id,String> AccountWithoutGroup = new Map<Id,String>();
            List<Account> accountToRemove = new List<Account>();
            for(Account acct: accountsWithSiteDuns){
                AccountWithoutGroup.put(acct.Id,acct.Profiled_Account__c);
                System.debug('AccountWithoutGroup'+AccountWithoutGroup);
                acct.Grouping__c=null;
                acct.Master_Grouping__c=null;
                acct.Profiled_Account__c=null;
                accountToRemove.add(acct);
            }
            if(AccountWithoutGroup.size()>0){
              Map<Id,List<Id>> removeAssociationOnAccount = new Map<Id,List<Id>>();
              removeAssociationOnAccount=fetchRelatedSiteDuns(AccountWithoutGroup);
              associationObj.deleteAccountAssociation(removeAssociationOnAccount);
            }
            update accountToRemove;
        }
    }

/* @Method <This method is used to validate the grouping field before updating on the account>
   @param <TriggeroldMap,TriggernewMap,TriggernewMap.keySet()>
   @return <Set<Id>> - <Account Id's>
   @throws exception - <No Exception>
*/
//Defect#70,71 added method to validate the grouping field during the update.

    public Set<Id> validate(Map<Id,Account> newAccountValues,Map<Id,Account> oldAccountValues,Set<Id> newAccountId){
        if(oldAccountValues.size()==0){
            return null;
        }
        Set<Id> validatedAccountId = new Set<Id>();
        Map<Id,String> accountGroupIdWithSiteDuns = new Map<Id,String>();
        for(Id accountId: oldAccountValues.keySet()){
            Account newValue = newAccountValues.get(accountId);
            Account oldValue = oldAccountValues.get(accountId);
            if(newValue.Grouping__c==null || newValue.Grouping__c!=oldValue.Grouping__c){
                accountGroupIdWithSiteDuns.put(oldValue.Grouping__c,newValue.Site_DUNS_Entity__c);
                System.debug('Map after checking Grouping'+accountGroupIdWithSiteDuns);
            }
        }
        if(accountGroupIdWithSiteDuns.size()>0){
            Map<Id,Account_Groupings__c> GroupMap= new Map<Id,Account_Groupings__c>([select id,Active__c,
                                                        Profiled_Account_Site_Duns__c,Profiled_Account__c, Master_Grouping__c 
                                                        from Account_Groupings__c 
                                                        where id in :accountGroupIdWithSiteDuns.keySet()]);
            
            for(Account acc: oldAccountValues.values()){
                Account_Groupings__c grp= GroupMap.get(acc.Grouping__c);
                System.debug('Grouping Object'+grp);
                System.debug('Site Duns value'+acc.site_duns_entity__c);
                if(processedSiteDuns.contains(acc.site_duns_entity__c)){
                    continue;
                }else{
                    processedSiteDuns.add(acc.site_duns_entity__c);
                    accountIdSet.add(acc.Id);
                }
                if(grp!=null && grp.Active__c==true && grp.Profiled_Account_Site_Duns__c==acc.Site_DUNS_Entity__c){
                    account accountRecord = newAccountValues.get(acc.Id);
                    accountRecord.addError(System.Label.Grouping_Error);
                }
                else{
                    validatedAccountId.add(acc.Id);
                }
            }
        }
           
        return validatedAccountId;
    }
    

/* @Method <Updates accounts with Partner Type value as that of the Update Partner Type of the Profiled Accouont, 
            if it has the same profiled account field populated on Account.>
   @param <accountIdWithPartnerType>
   <accountIdWithPartnerType -- which contains Profiled account Id and along with Partner Type value>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    
    public void updateRelatedPartnerType(Map<Id,Account> accountIdWithPartnerType){
        List<Account> accountWithPartner = [select Partner_Type__c,id,name,Site_DUNS_Entity__c,Grouping__c,VSI_Approved_Delivery_Products_TA__c,Consolidate_Specialty__c,
                                            Master_Grouping__c,Profiled_Account__c,PROFILED_ACCOUNT_FLAG__c,VSI_Approved_Delivery_Products__c,Advanced_Consolidate_Specialty__c,
                                            Velocity_Services_Implement__c,Velocity_Solution_Provider_Tier__c,Master_Site_ID__c,Master_Agreement__c,
                                            Governance_and_Archive_Specialty__c,Backup_and_Recovery_Speciality__c
                                            from account 
                                            where Profiled_Account__c in :accountIdWithPartnerType.keySet()];
        System.debug('List of Accounts to update partner Type'+accountWithPartner);
        //check if the accounts to update are greater than or equal to DML Limits, if its greater
        //Then update the Grouping_Batch_Operation__c field on Account with value 'updateRelatedPartnerTypes'
        if(accountWithPartner.size()>=Limits.getLimitDMLRows()){
            List<Account> ProfiledAccounts = [select Partner_Type__c,id,name,Site_DUNS_Entity__c,Grouping__c,VSI_Approved_Delivery_Products__c,Consolidate_Specialty__c,
                                              Master_Grouping__c,Profiled_Account__c,PROFILED_ACCOUNT_FLAG__c,VSI_Approved_Delivery_Products_TA__c,Grouping_Batch_Operation__c,
                                              Velocity_Services_Implement__c,Velocity_Solution_Provider_Tier__c,Master_Site_ID__c,Master_Agreement__c,Advanced_Consolidate_Specialty__c,
                                              Governance_and_Archive_Specialty__c,Backup_and_Recovery_Speciality__c
                                              from account 
                                              where id in :accountIdWithPartnerType.keySet()];
            for(Account profiledAccount: ProfiledAccounts){
                profiledAccount.Grouping_Batch_Operation__c='updateRelatedPartnerTypes';
            }
            update ProfiledAccounts;
        }
        else{
            List<Account> accountAfterUpdate = new List<Account>();
            for(Account accObj: accountWithPartner){
                accObj.Partner_Type__c=accountIdWithPartnerType.get(accObj.Profiled_Account__c).Partner_Type__c;
                accobj.VSI_Approved_Delivery_Products__c = accountIdWithPartnerType.get(accObj.Profiled_Account__c).VSI_Approved_Delivery_Products__c;
                accobj.Advanced_Consolidate_Specialty__c = accountIdWithPartnerType.get(accObj.Profiled_Account__c).Advanced_Consolidate_Specialty__c;
                accobj.Consolidate_Specialty__c = accountIdWithPartnerType.get(accObj.Profiled_Account__c).Consolidate_Specialty__c;
                accobj.Governance_and_Archive_Specialty__c = accountIdWithPartnerType.get(accObj.Profiled_Account__c).Governance_and_Archive_Specialty__c;
                accobj.Backup_and_Recovery_Speciality__c = accountIdWithPartnerType.get(accObj.Profiled_Account__c).Backup_and_Recovery_Speciality__c;
                accobj.Affiliate_Services__c = accountIdWithPartnerType.get(accObj.Profiled_Account__c).Affiliate_Services__c;
                accobj.Master_Agreement__c = accountIdWithPartnerType.get(accObj.Profiled_Account__c).Master_Agreement__c;
                accobj.Master_Site_ID__c = accountIdWithPartnerType.get(accObj.Profiled_Account__c).Master_Site_ID__c;
                accobj.Velocity_Solution_Provider_Tier__c = accountIdWithPartnerType.get(accObj.Profiled_Account__c).Velocity_Solution_Provider_Tier__c;
                accobj.Velocity_Services_Implement__c = accountIdWithPartnerType.get(accObj.Profiled_Account__c).Velocity_Services_Implement__c;
                accountAfterUpdate.add(accObj);
            }
            update accountAfterUpdate;
        }
    }
    
   
/* @Method <Updating accounts with grouping details for the Accounts which has same SITE_DUNS/ENTITY_ID 
      of profiled account>
   @param <assignmentOfGroupName>
   <assignmentOfGroupName -- which contains siteDuns and along with grouping details>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void updateRelatedGrouping(Map<String,String> assignmentOfGroupName){
        //This flage is set here to avoid the execution of the trigger AfterUpdateOfAccountGrouping
        PRM_GroupingOfAssignment.PartnerGroupingCreation=true;
        System.debug('Partner Grouping Creation'+PRM_GroupingOfAssignment.PartnerGroupingCreation);
        System.debug('Account from Trigger'+assignmentOfGroupName);
        //New list to assign group name on accounts
        List<Account> updatingGroupOnAccounts = new List<Account>();
        //List which contains the same SITE_DUNS/ENTITY_ID as the profiled account
        Set<String> ProfiledAccountIds=new Set<String>();
        for(String groupDetail:assignmentOfGroupName.values()){
           Integer indexValue2 = groupDetail.indexOf('@');
           ProfiledAccountIds.add(groupDetail.substring(indexValue2+1));
        }
        Map<Id,Account> AccountMap = 
             new Map<Id,Account>( [select partner_type__c,id,name,Site_DUNS_Entity__c,Grouping__c,VSI_Approved_Delivery_Products_TA__c,
                                    Master_Grouping__c,Profiled_Account__c,Grouping_Batch_Operation__c,VSI_Approved_Delivery_Products__c,
                                    PROFILED_ACCOUNT_FLAG__c ,Velocity_Specialties_Achieved_TA__c,Velocity_Specialties_Achieved__c,
                                    Affiliate_Services_TA__c,Affiliate_Services__c,Velocity_Services_Implement__c,Velocity_Solution_Provider_Tier__c,
                                    Velocity_Service_Provider_Tier__c,Master_Site_ID__c,Master_Agreement__c,Backup_and_Recovery_Speciality__c,Governance_and_Archive_Specialty__c,
                                    Advanced_Consolidate_Specialty__c,Consolidate_Specialty__c
                                    from account 
                                    where Site_DUNS_Entity__c in:assignmentOfGroupName.keySet() or 
                                    id in:ProfiledAccountIds ] );
        System.debug('AccountMap.values().size()-->'+AccountMap.values().size());
        if(AccountMap.values().size()>=Limits.getLimitDMLRows()){
            System.debug('AccountMap.values().size()-->'+AccountMap.values().size());
        }        
        else{
            for(Account accObj:AccountMap.values()){
                if(ProfiledAccountIds.contains(accObj.Id)){
                    continue;
                } 
                 //fetching the grouping value and master grouping value from the map
                String groupingValue=assignmentOfGroupName.get(accObj.Site_DUNS_Entity__c);
                Integer indexValue1 = groupingValue.indexOf('=');
                Integer indexValue2 = groupingValue.indexOf('@');
                String groupingName = groupingValue.substring(0,indexValue1);
                String masterGroupingName = groupingValue.substring(indexValue1+1,indexValue2);
                String profiledAccountName = groupingValue.substring(indexValue2+1);
                if(accObj.PROFILED_ACCOUNT_FLAG__c!=true){
                    accObj.Profiled_Account__c = profiledAccountName;
                }
                //Fix for Def 119
                if(accObj.PROFILED_ACCOUNT_FLAG__c && accObj.Grouping__c==null){
                    accObj.PROFILED_ACCOUNT_FLAG__c=false;
                    accObj.Profiled_Account__c = profiledAccountName;
                }
                accObj.Grouping__c=groupingName;
                //Added for WR1077
                accObj.Suggested_Partner_Grouping__c=null;
                accObj.IsPartner=true;
                accObj.Partner_Type__c=AccountMap.get(profiledAccountName).partner_type__c; 
                accobj.VSI_Approved_Delivery_Products__c=AccountMap.get(profiledAccountName).VSI_Approved_Delivery_Products__c;               
                accObj.Affiliate_Services__c= AccountMap.get(profiledAccountName).Affiliate_Services__c;
                accObj.Master_Agreement__c= AccountMap.get(profiledAccountName).Master_Agreement__c;
                accObj.Master_Site_ID__c= AccountMap.get(profiledAccountName).Master_Site_ID__c;
                accObj.Velocity_Solution_Provider_Tier__c= AccountMap.get(profiledAccountName).Velocity_Solution_Provider_Tier__c;
                accObj.Velocity_Services_Implement__c= AccountMap.get(profiledAccountName).Velocity_Services_Implement__c;
                accobj.Advanced_Consolidate_Specialty__c = AccountMap.get(profiledAccountName).Advanced_Consolidate_Specialty__c;
                accobj.Consolidate_Specialty__c = AccountMap.get(profiledAccountName).Consolidate_Specialty__c;
                accobj.Governance_and_Archive_Specialty__c = AccountMap.get(profiledAccountName).Governance_and_Archive_Specialty__c;
                accobj.Backup_and_Recovery_Speciality__c = AccountMap.get(profiledAccountName).Backup_and_Recovery_Speciality__c;
                //Checking whether the master grouping value is same as grouping value
                if(masterGroupingName!='null'){ 
                    System.debug('Inside If');
                    accObj.Master_Grouping__c=masterGroupingName;
                }
                else
                {
                    System.debug('Inside else');
                    accObj.Master_Grouping__c=groupingName;
                }
                //adding the accounts into the list which as same SITE_DUNS/ENTITY_ID
                updatingGroupOnAccounts.add(accObj);
                System.debug('Before update of related SITE DUNS'+updatingGroupOnAccounts);
            }
            //updating the accounts with the grouping name same as profiled account
            System.debug('Before update the acc with similar site duns'+updatingGroupOnAccounts);
            try{
                update updatingGroupOnAccounts;
            }
            catch(Exception e){
             System.debug('#### Received an error'+e);
            }
            System.debug('After update of the accounts similar site Duns'+updatingGroupOnAccounts);
        }
    }

/* @Method <Here we are removing the grouping from the Accounts, based on related SiteDuns>
   @param <profieldAccountMap,siteDunsOfAccount>
   <profieldAccountMap -- Which contains profiled account and grouping details>
   <siteDunsOfAccount -- which contains siteDuns and along with grouping details>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
   
    public void removeGrouingFromAccount(Map<Id,String> profieldAccountMap,Map<String,String> siteDunsOfAccount){            
        //This flage is set here to avoid the execution of the trigger AfterUpdateOfAccountGrouping
        PRM_GroupingOfAssignment.PartnerGroupingCreation=true;
        System.debug('Account from Trigger for remove1'+profieldAccountMap);
        System.debug('Account from Trigger for remove2'+siteDunsOfAccount);
        List<Account> accountsToUpdate = new List<Account>();//List used to remove the groupings from the account
        List<Account> partnerAccountsToUpdate = new List<Account>();
        //Fetching the accounts which is of profiled account and accounts with same siteDuns value of profiled account
        List<Account> profileAccountList = [select id,name,Partner_Type__c,Profiled_Account__c,Site_DUNS_Entity__c,
                                            PROFILED_ACCOUNT_FLAG__c,Grouping__c,Master_Grouping__c 
                                            from account 
                                            where id in :profieldAccountMap.keySet() or 
                                            Site_DUNS_Entity__c in :siteDunsOfAccount.keySet()];
        for(Account remObj: profileAccountList){
            if(remObj.PROFILED_ACCOUNT_FLAG__c!=true){
                    remObj.Partner_Type__c=NULL;
            }
            remObj.Grouping__c=NULL;
            //Defect#77 removed the condition of checking master grouping with grouping.
            remObj.Master_Grouping__c=NULL;
            remObj.Profiled_Account__c=NULL;
            System.debug('After making grouping null in remove'+remObj.Grouping__c);
            //Adding the each record into list for removing the grouping values
            accountsToUpdate.add(remObj);
            }
            System.debug('Before the update of remove'+accountsToUpdate);
            update accountsToUpdate;
            System.debug('After the update of remove'+accountsToUpdate);
        }


/* @Method <Here we are removing the grouping from the Accounts, if grouping becomes inactive>
   @param <accountWithGrouping>
   <accountWithGrouping -- Which contains profiled account and grouping details>
   @return <Map<Id,String>> - <Returning Map of Profile ID and Grouping details>
   @throws exception - <No Exception>
   This method is getting called in PRM_GroupingSchedulerOperation Class as well.
*/

    public Map<Id,String> removeAllRelatedGrouping(Map<Id,String> accountWithGrouping){
        Map<Id,String> accountsToRemoveAssociation = new Map<Id,String>();
        List<String> accountGroupingId = new List<String>();
        List<Account> accountsAfterUpdate = new List<Account>();
        Set<Id> GroupingIds = new Set<Id>();
        List<Account_Groupings__c> accountGroupingDetails = new List<Account_Groupings__c>(); 
        
        for(Id accId: accountWithGrouping.keySet()){
            String groupingDetails = accountWithGrouping.get(accId);
            Integer indexValue1 = groupingDetails.indexOf('=');
            String groupingName = groupingDetails.substring(0,indexValue1);
            if(groupingName!=null){
                accountGroupingId.add(groupingName);
            }
        }

        List<Account> removeAccountList = [select id,name,Partner_Type__c,Profiled_Account__c,Site_DUNS_Entity__c,
                                            PROFILED_ACCOUNT_FLAG__c,Grouping__r.Grouping_Update__c,VSI_Approved_Delivery_Products_TA__c,
                                            Master_Grouping__c,Grouping_Batch_Operation__c,Velocity_Specialties_Achieved_TA__c,Affiliate_Services_TA__c
                                            from account 
                                            where Grouping__c in :accountGroupingId];
        //Check if the size of the removeAccountList is exceeding the DML Limit
        if(removeAccountList.size()>=Limits.getLimitDMLRows()){
            /*for(Account accountupdate: removeAccountList){
                //For Batch Process
                accountupdate.Grouping_Batch_Operation__c='InactivateGrouping';
            }
            update removeAccountList;
            System.debug('removeAccountList--->'+removeAccountList.size());*/
            System.debug('removeAccountList--->'+removeAccountList.size());
            accountsToRemoveAssociation = null;
        }          
                 
        else {
            PRM_GroupingOfAssignment.PartnerGroupingCreation=true;
            for(Account remove: removeAccountList){
                String groupDetails = remove.Grouping__c+'='+remove.Master_Grouping__c+'@'+remove.Profiled_Account__c;
                if(remove.Profiled_Account__c!=null){
                    accountsToRemoveAssociation.put(remove.Id,groupDetails);
                }
                System.debug('Account to remove asscociation'+accountsToRemoveAssociation);
                if(remove.PROFILED_ACCOUNT_FLAG__c!=true){
                        remove.Partner_Type__c=NULL;
                }
                //Added by Anirudh 
                //Setting the Profiled Account Flag to False for inactive Grouping
                if(remove.PROFILED_ACCOUNT_FLAG__c){
                        remove.PROFILED_ACCOUNT_FLAG__c=False;
                }
                remove.Grouping__c=NULL;
                remove.Master_Grouping__c=NULL;
                remove.Profiled_Account__c=NULL;                
                //PROFILED_ACCOUNT_FLAG is not nullified as per the business requirement.
                System.debug('After making grouping null in removeAll'+remove.Grouping__c);
                //Adding the each record into list for removing the grouping values
                accountsAfterUpdate.add(remove);
                
            }
            System.debug('Before the update of remove'+accountsAfterUpdate);
            update accountsAfterUpdate;
            System.debug('After the update of remove'+accountsAfterUpdate);       
           
        }
        return accountsToRemoveAssociation;
   }
        

/* @Method <This method is used fetch the SITE_DUNS/ENTITY_ID by passing the Profiled Account as map>
   @param <profiledAccountMap>
   <profieldAccountMap -- Which contains profiled account and grouping details>
   @return Map<String,String> - <siteDuns values and grouping(groupingId+masterGrouping+profiledAccount>
   @throws exception - <No Exception>
*/
  
    public Map<String,String> fetchRelatedAccounts(Map<Id,String> profiledAccountMap){
        Map<String,String> siteDunsWithGroup = new Map<String,String>();
        List<Account> accountWithSiteDuns = [select id,name,Site_DUNS_Entity__c,PROFILED_ACCOUNT_FLAG__c,Grouping__c,
                                            Master_Grouping__c 
                                            from account 
                                            where id in :profiledAccountMap.keySet()];
        for(Account acct: accountWithSiteDuns){
            if(acct.Site_DUNS_Entity__c!=null){
                String groupingValue = acct.grouping__c+'='+acct.Master_Grouping__c;
                siteDunsWithGroup.put(acct.Site_DUNS_Entity__c,groupingValue); 
                //Adding the records of profileaccount with same SITE_DUNS/ENTITY_ID
            }
        }
        return siteDunsWithGroup;
    }

/* @Method <This method is used to compare the mastergrouping old value with new value>
   @param <Map<Id,Account_Groupings__c> newMasterGrouping,Map<Id,Account_Groupings__c> oldMasterGrouping>
   <newMasterGrouping -- Which contains new grouping details>
   <oldMasterGrouping -- which contains old grouping details>
   @return <Map<Id,String> - <Which contains Profiled Account Id and groupings(groupingId+mastergrouping+profiledaccount>
   @throws exception - <No Exception>
*/

    public Map<Id,String> masterGroupingUpdate(Map<Id,Account_Groupings__c> newMasterGrouping,Map<Id,Account_Groupings__c> oldMasterGrouping){ 
    Set<Id> newGroupingId = newMasterGrouping.keySet();
     Map<Id,String> masterGroupAfterUpdate = new Map<Id,String>();
        for(Id newGroupId: newGroupingId){
            Account_Groupings__c newGroupValue = newMasterGrouping.get(newGroupId);
            System.debug('New value of Group'+newGroupValue);
            Account_Groupings__c oldGroupValue = oldMasterGrouping.get(newGroupId);
            System.debug('Old value of Group'+oldGroupValue);
            //comparing old value with new value of grouping
            if(newGroupValue.Master_Grouping__c!=oldGroupValue.Master_Grouping__c){
                //assigning the new grouping value
                String groupNames = newGroupValue.Id+'='+newGroupValue.Master_Grouping__c+'@'+newGroupValue.Profiled_Account__c;
                //Adding the SITE_DUNS/ENTITY_ID and new grouping name
                //Defect#30 changed the parameter to Profiled Account
                masterGroupAfterUpdate.put(newGroupValue.Profiled_Account__c,groupNames);
                System.debug('After putting in map'+masterGroupAfterUpdate);
            }
            //Commented to remove duplicate Association for bulkification
            /*else{             
                String groupNames = newGroupValue.Id+'='+newGroupValue.Master_Grouping__c+'@'+newGroupValue.Profiled_Account__c;
                masterGroupAfterUpdate.put(newGroupValue.Profiled_Account__c,groupNames);                
            }*/
        }
        return masterGroupAfterUpdate;        
    }


/* @Method <This method is used to include the accounts into the grouping>
   @param <List<Account> selectedAccounts,String GroupingID>
   <selectedAccounts -- list of selected accounts from the page>
   <Grouping ID -- Which is a grouping Id for including the accounts into the grouping>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/


    public void includeInGrouping(List<Account> selectedAccounts,String GroupingID){
    PRM_GroupingOfAssignment.PartnerGroupingCreation=true;
    System.debug('From Include selected accounts'+selectedAccounts);
    System.debug('Group ID'+GroupingID);
    Map<String,String> relatedSiteDuns = new Map<String,String>();
    Map<Id,String> associationProfiledAcc = new Map<Id,String>();
    Map<Id,List<Id>> profileIdWithSiteDuns = new Map<Id,List<Id>>();
    List<Account> accountToInclude = new List<Account>();
    Account_Groupings__c GroupingRecord = [select id,Profiled_Account__c,Master_Grouping__c 
                                          from account_groupings__c 
                                          where Id__c=:GroupingID];
    System.debug('GroupingRecord'+GroupingRecord);
    String groupigValues;
     //Added a null Check by Anil
    if(GroupingRecord.Master_Grouping__c!=null  || GroupingRecord.Profiled_Account__c!=null)
    {                                     
    groupigValues = GroupingRecord.id+'='+GroupingRecord.Master_Grouping__c+'@'+GroupingRecord.Profiled_Account__c;
    System.debug('groupigValues@@@@@@@@@'+groupigValues);
    }
    
    for(Account includeObj: selectedAccounts){
            System.debug('Grouping Id Before assigning'+GroupingID);
                includeObj.Grouping__c=GroupingRecord.Id;
                //Added for the WR1077
                includeObj.Suggested_Partner_Grouping__c=null;
                System.debug('Master grouping value'+GroupingRecord.Master_Grouping__c);
                if(GroupingRecord.Master_Grouping__c!=null){
                    includeObj.Master_Grouping__c=GroupingRecord.Master_Grouping__c;
                }
                else{
                includeObj.Master_Grouping__c=GroupingRecord.Id;
                }
            System.debug('After Update of Master'+includeObj.Master_Grouping__c);
            accountToInclude.add(includeObj);
            System.debug('After adding into list'+accountToInclude);
            //Added a null Check by Anil
            if(groupigValues!=null)
            {
            relatedSiteDuns.put(includeObj.Site_DUNS_Entity__c,groupigValues);            
            associationProfiledAcc.put(includeObj.Id,groupigValues);
            }
        }
        update accountToInclude;
        System.debug('After update'+accountToInclude);
        System.debug('Before future call the map'+relatedSiteDuns);
        updateRelatedGrouping(relatedSiteDuns);
        profileIdWithSiteDuns=fetchRelatedSiteDuns(associationProfiledAcc);
        associationObj.createAccountAssociation(profileIdWithSiteDuns);
    }

/* @Method <This method is used to exclude the accounts from the grouping>
   @param <List<Account> selectedAccounts,String GroupingID>
   <selectedAccounts -- list of selected accounts from the page>
   <Grouping ID -- Which is a grouping Id for including the accounts into the grouping>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
   
    public void excludeFromGrouping(List<Account> selectedAccounts,String GroupingID){
    System.debug('Exclude Accounts List'+selectedAccounts);
    List<Account> accountToExclude = new List<Account>();
    Map<Id,String> profiledAccMap = new Map<Id,String>();
    Map<Id,List<Id>> profileAccWithSiteDunsId = new Map<Id,List<Id>>();
    Map<String,String> siteDunsWithGroupValues = new Map<String,String>();
    Account_Groupings__c groupingList = [select id,Profiled_Account__c,Master_Grouping__c 
                                        from account_groupings__c 
                                        where Id__c=:GroupingID];
    String groupValues = groupingList.Id+'='+groupingList.Master_Grouping__c+'@'+groupingList.Profiled_Account__c;
        for(Account excludeObj: selectedAccounts){
                excludeObj.Grouping__c=null;
                //Defect#77 removed the condition of checking master grouping with grouping.
                excludeObj.Master_Grouping__c=null;
                excludeObj.Profiled_Account__c=null;
                excludeObj.VSI_Approved_Delivery_Products_TA__c=null;
                excludeObj.Velocity_Specialties_Achieved_TA__c=null;
                excludeObj.Affiliate_Services_TA__c=null;
                accountToExclude.add(excludeObj);
                profiledAccMap.put(excludeObj.Id,groupValues);
                siteDunsWithGroupValues.put(excludeObj.Site_DUNS_Entity__c,groupValues);
        }
        removeGrouingFromAccount(profiledAccMap,siteDunsWithGroupValues);
        System.debug('Map for fetching for association'+profiledAccMap);
        profileAccWithSiteDunsId=fetchRelatedSiteDuns(profiledAccMap);
        associationObj.deleteAccountAssociation(profileAccWithSiteDunsId);
        update accountToExclude;
    }

/* @Method <This method is used to do the operation of trigger on insert of new group>
   @param <List<Account_Groupings__c> groupingList>
   <groupingList -- list of grouping details from trigger>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

    public void createGrouping(List<Account_Groupings__c> groupingList){
        //Map to store the list of profiled accounts along with grouping and master grouping value
        Map<Id,String> profieldAccountMap = new Map<Id,String>();
        Map<Id,List<Id>> createAssociationMap = new Map<Id,List<Id>>();
        Map<String,String> siteDunsWithGrouping = new Map<String,String>();
        for(Account_Groupings__c grp: groupingList){
            //Concatinating both grouping and master grouping values
            if(grp.Profiled_Account__c==null){
                continue;
            }
            String groupNames = grp.id+'='+grp.Master_Grouping__c+'@'+grp.Profiled_Account__c; 
            //Adding profile account Id along with concatednated(grouping+master grouping) value
            profieldAccountMap.put(grp.Profiled_Account__c,groupNames);
            if(grp.Profiled_Account_Site_Duns__c!=null){ 
                siteDunsWithGrouping.put(grp.Profiled_Account_Site_Duns__c,groupNames);
            }
        }
        //Calling method to update the Profiled acocunt and assigning the returned map to 
        //new map siteDunsOfAccount which contains SITE_DUNS/ENTITY_ID and concatenated values        
         if(profieldAccountMap.size()>0 && siteDunsWithGrouping.size()>0){
             System.debug('Profiled Account Map in Create grouping'+profieldAccountMap.size());
             System.debug('SiteDuns with Grouping Map in Create grouping'+siteDunsWithGrouping.size());
             boolean underLimit = modifyProfiledAccounts(profieldAccountMap,siteDunsWithGrouping,'Creation');
             System.debug('underLimit---->'+underLimit); 
            //Calling the method to update the accounts based on SITE_DUNS/ENTITY_ID
            //updateRelatedGrouping(siteDunsOfAccount);
            //Commented for DML Limit Fix to overcome association taken care in PRM_Schedular Operation class
             if(underLimit==true){
                 createAssociationMap=fetchRelatedSiteDuns(profieldAccountMap);
                 associationObj.createAccountAssociation(createAssociationMap);
             }
         }
    }

/* @Method <This method is used to do the operation of trigger on update>
   @param <List<Account_Groupings__c> updateListOfGroup,Map<Id,Account_Groupings__c> 
            newTriggerMap,Map<Id,Account_Groupings__c> oldTriggerMap>
   <updateListOfGroup -- list of grouping details which has got updated from trigger>
   <newTriggerMap -- Map which contains ID's of grouping and its values from trigger.newMap>
   <oldTriggerMap -- Map which contains ID's of grouping and its values from trigger.oldMap>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

    public void updateOfGrouping(List<Account_Groupings__c> updateListOfGroup,Map<Id,Account_Groupings__c> newTriggerMap,Map<Id,Account_Groupings__c> oldTriggerMap){
        //Map to store the list of profiled accounts along with grouping and master grouping value
        Map<Id,String> updationOfprofiledAccount = new Map<Id,String>();
        Map<String,String> siteDunsWithGroup = new Map<String,String>();
        Map<Id,String> masterGroupingForUpdate = new Map<Id,String>();
        Map<Id,List<Id>> deleteAssociationMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> createAssociationMap = new Map<Id,List<Id>>();
        Map<Id,String> accountsIdWithGrouping = new Map<Id,String>();
        Map<Id,String> profiledAccountWithGrouping = new Map<Id,String>();
        Map<Id,String> accountsToDeleteAssociation = new Map<Id,String>();
        //List<Account_Groupings__c> deactivatedGroupings = new List<Account_Groupings__c>();

        for(Account_Groupings__c grouping: updateListOfGroup){
            //Checking the group is inactive
            if(grouping.Active__c==false){
                System.debug('Inside the update method when grouping is false');
                //Concatenating grouping and master grouping values
                String groupNames = grouping.id+'='+grouping.Master_Grouping__c+'@'+grouping.Profiled_Account__c; 
                //Adding the profiled account id and concatenated values
                updationOfprofiledAccount.put(grouping.Profiled_Account__c,groupNames);
                grouping.Profiled_Account__c=null;
               
            }
            else if(grouping.Active__c!=false){
                System.debug('Inside the update method when grouping is not false');
                Map<Id,Account_Groupings__c> newMasterGrouping = newTriggerMap;
                Map<Id,Account_Groupings__c> oldMasterGrouping = oldTriggerMap;
                String groupValues = grouping.id+'='+grouping.Master_Grouping__c+'@'+grouping.Profiled_Account__c;
                //Defect#24 added one condition here i,e Site Duns not equal to null.
                if(grouping.Profiled_Account_Site_Duns__c!=null && grouping.Profiled_Account__c!=null || 
                      grouping.Master_Grouping__c!=null  ){
                    profiledAccountWithGrouping.put(grouping.Profiled_Account__c,groupValues);
                    siteDunsWithGroup.put(grouping.Profiled_Account_Site_Duns__c,groupValues);
                    masterGroupingForUpdate=masterGroupingUpdate(newMasterGrouping,oldMasterGrouping);
                }              
                    
                
            }  
        }
        if(updationOfprofiledAccount.size()>0){
            System.debug('Before removing the profileAccount'+updationOfprofiledAccount);
            siteDunsWithGroup = fetchRelatedAccounts(updationOfprofiledAccount);
            System.debug('Before remove is called siteDuns'+siteDunsWithGroup);
            //If group becomes inactive this method is called to remove the groupings on account
            accountsToDeleteAssociation=removeAllRelatedGrouping(updationOfprofiledAccount);
            if(accountsToDeleteAssociation!=null){
                deleteAssociationMap=fetchRelatedSiteDuns(accountsToDeleteAssociation);
                associationObj.deleteAccountAssociation(deleteAssociationMap); 
            }
            else{
                for(Account_Groupings__c grouping: updateListOfGroup){
                    //Checking the group is inactive
                    if(grouping.Active__c==false){
                        System.debug('assigning value----->');
                        grouping.Grouping_Update__c='Grouping Inactivated';
                    }
                }
            }
        }
        if(masterGroupingForUpdate.size()>0){
            System.debug('In mastergrouping update'+masterGroupingForUpdate);
            boolean underLimit = modifyProfiledAccounts(masterGroupingForUpdate,siteDunsWithGroup,'Update');
            System.debug('underLimit---->'+underLimit);
            //Commented to Remove duplication of Association for def 119
            /*if(underLimit==true){
                createAssociationMap=fetchRelatedSiteDuns(profiledAccountWithGrouping);
                associationObj.createAccountAssociation(createAssociationMap);
            }*/
        }
    }


/* @Method <For the trigger before insert to check if the selected account is profiled account or not>
   @param <List<Account_Groupings__c> listOfInsertGrouping>
   <listOfInsertGrouping -- list of grouping details which has got inserted from trigger>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

    public void beforeInsertOnGrouping(List<Account_Groupings__c> listOfInsertGrouping){
        Set<Id> AccountIds = new Set<Id>();
        for(Account_Groupings__c acctGrouping:listOfInsertGrouping){
            AccountIds.add(acctGrouping.Profiled_Account__c);
        }
        
        List<Account> accounts=[Select Id,Grouping__c 
                                from Account 
                                where Id in:AccountIds and Grouping__c!=null];
    
        for(Account_Groupings__c Grouping:listOfInsertGrouping){
            for(Account account:accounts){
                System.debug('Grouping.Profiled_Account__c'+Grouping.Profiled_Account__c);
                System.debug('account.id'+account.id);
                if(Grouping.Profiled_Account__c==account.id){
                    Grouping.addError('An account can be Profiled Account to only one Group ');
                }
            }
        }
    }
  

/* @Method <Fetching the Profiled account and SITE_DUNS/ENTITY_ID by passing the Profiled Account map>
   @param <Map<Id,String> profiledAccountMap>
   <profieldAccountMap -- Which contains profiled account and grouping details>
   @return <Map<Id,List<Id>>>-<Profiled account as key and List of related accounts which has same siteDuns in List>
   @throws exception - <No Exception>
   This Particular method is getting called  in PRM_GroupingSchedulerOperation Class as well. 
*/

        
    public Map<Id,List<Id>> fetchRelatedSiteDuns(Map<Id,String> profiledAccountMap){
        Map<Id,List<Id>> profiledIdWithSiteDuns = new Map<Id,List<Id>>();
        List<Id> siteDunsList = new List<Id>();
        Map<String,Id> siteDunsWithProfiledAccount = new Map<String,Id>();
        List<Account> accountSiteDuns = [select id,name,Site_DUNS_Entity__c,PROFILED_ACCOUNT_FLAG__c,Grouping__c,Master_Grouping__c 
                                        from account 
                                        where (id in :profiledAccountMap.keySet())];
        for(Account acc: accountSiteDuns){
            
            String profiledAccountValue = profiledAccountMap.get(acc.Id);
            Integer indexValue1 = profiledAccountValue.indexOf('@');
            Id profiledAccountId = profiledAccountValue.substring(indexValue1+1);
            if(acc.Site_DUNS_Entity__c!=null && profiledAccountId!=null){    
                siteDunsWithProfiledAccount.put(acc.Site_DUNS_Entity__c,profiledAccountId);
            }
        }
        List<Account> accountList = [select id,name,Site_DUNS_Entity__c,PROFILED_ACCOUNT_FLAG__c,Grouping__c,Master_Grouping__c 
                                    from account 
                                    where (Site_DUNS_Entity__c in :siteDunsWithProfiledAccount.keySet()) and (Child_Partner_Users_Count__c>0)];
        for(Account acct: accountList){
            if(acct.PROFILED_ACCOUNT_FLAG__c!=true){
                siteDunsList.add(acct.Id);
                profiledIdWithSiteDuns.put(siteDunsWithProfiledAccount.get(acct.Site_DUNS_Entity__c),siteDunsList);
                System.debug('Profiled Account for assosciaton'+profiledIdWithSiteDuns);
            }
        }
        
        return profiledIdWithSiteDuns;
    }
    
  
}