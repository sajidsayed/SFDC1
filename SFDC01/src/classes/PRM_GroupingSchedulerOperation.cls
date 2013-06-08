/*===============================================================================================================================+

 |  HISTORY  |                                                                           

 | DATE          DEVELOPER            WR             DESCRIPTION                               

 | ====          =========            ==             =========== 

 | 9/9/2010      Ashwini Gowda        Req # 991      This class updates the profile accounts with grouping 
                                                     and master grouping and similar account which has same 
 |                                                   SITE DUNS/ENTITY ID as that of Profiled Account when 
                                                     exceeding the DML Limits.
 |                                                   If the group becomes inactive, then it remove the grouping
                                                     and master grouping names from both the profiled accounts 
 |                                                   and its similar accounts which has same SITE DUNS/ENTITY ID.
                                                     Its coming across this limit as there are would be multiple Accounts
 |                                                   with same SITE_DUNS/ENTITY_ID
  12/10/2010     Ashwini Gowda        Req#1179       updated Method operateSimilarAccounts() and created 
 |                                                   bulkifiedUpdateRelatedPartnerType() to remove
                                                     too many rows error when a Partner Type field is updated
 |                                                   on Account. 
  12/25/2010     Prasad Kothawade                    Test class error - Added query Limit 150  
 |23/12/2011     Accenture            WR#183066      Updated Code to set Velocity Tier Field Values on Non Profiled Account Based on Profiled Account                                                 
 +==============================================================================================================================*/

Public class PRM_GroupingSchedulerOperation{
    
    public Static boolean PRM_GroupingScheduler_TestClass_Execution=false;
    
    PRM_GroupingOfAssignment groupingAssignment = new PRM_GroupingOfAssignment();
    PRM_RecordsVisibility associationObj = new PRM_RecordsVisibility();   
    
/* @Method <operateSimilarAccounts(): This Method is used while Updating Grouping,
                                      Master Grouping and Profiled Account Details to 
                                      all other Accounts which has same SITE_DUNS/ENTITY_ID 
                                      as that of the updated Account .
                                      Its coming across this limit as there are would be multiple
                                      Accounts with same SITE_DUNS/ENTITY_ID>
                                      Method called in Scheduler Class PRM_GroupingScheduler
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/       
    Public void operateSimilarAccounts(){
        
        List<Account_Groupings__c> updatedMasterGroupingsList=null;
        List<Account> accountsOfRelatedSiteDunsList =null;
        
        if(PRM_GroupingScheduler_TestClass_Execution){
            accountsOfRelatedSiteDunsList = [SELECT Grouping_Batch_Operation__c,Grouping__c,
                                                       Site_DUNS_Entity__c,Master_Grouping__c, IsPartner, 
                                                       Profiled_Account__c,PROFILED_ACCOUNT_FLAG__c,Partner_Type__c
                                                       FROM Account 
                                                       where (Grouping_Batch_Operation__c='UpdateRelatedSiteDuns' or 
                                                       Grouping_Batch_Operation__c = 'InactivateGrouping' or 
                                                       Grouping_Batch_Operation__c = 'Grouping Nullified'
                                                       or Grouping_Batch_Operation__c = 'updateGroupingOnAccount'
                                                       or Grouping_Batch_Operation__c = 'MasterGroupingUpdated'
                                                       or Grouping_Batch_Operation__c = 'updateRelatedPartnerTypes') and
                                                       name like 'TestAccount%' limit 4 ]; 
                                                    
            updatedMasterGroupingsList = [select id,Profiled_Account__c,Master_Grouping__c,
                                                                 Grouping_Update__c,Profiled_Account_Site_Duns__c 
                                                                 from account_groupings__c 
                                                                 where (Grouping_Update__c = 'updateMasterGrouping' or 
                                                                 Grouping_Update__c = 'Grouping Inactivated') and
                                                                 name like 'TestGroup%' limit 1 ];                                                 
        
        
        }else{
            accountsOfRelatedSiteDunsList = [SELECT Grouping_Batch_Operation__c,Grouping__c,
                                                       Site_DUNS_Entity__c,Master_Grouping__c, IsPartner, 
                                                       Profiled_Account__c,PROFILED_ACCOUNT_FLAG__c,Partner_Type__c,VSI_Approved_Delivery_Products__c
                                                       FROM Account 
                                                       where Grouping_Batch_Operation__c='UpdateRelatedSiteDuns' or 
                                                       Grouping_Batch_Operation__c = 'InactivateGrouping' or 
                                                       Grouping_Batch_Operation__c = 'Grouping Nullified'
                                                       or Grouping_Batch_Operation__c = 'updateGroupingOnAccount'
                                                       or Grouping_Batch_Operation__c = 'MasterGroupingUpdated'
                                                       or Grouping_Batch_Operation__c = 'updateRelatedPartnerTypes' limit 150 ]; 
                                                    
            updatedMasterGroupingsList = [select id,Profiled_Account__c,Master_Grouping__c,
                                                                 Grouping_Update__c,Profiled_Account_Site_Duns__c 
                                                                 from account_groupings__c 
                                                                 where Grouping_Update__c = 'updateMasterGrouping' or 
                                                                 Grouping_Update__c = 'Grouping Inactivated' limit 150 ];                                                 
                        
        }
        List<Account> groupingInactiveAccountsList = new List<Account>();
        List<Account> accountWithSameSiteDUNSList = new List<Account>();
        List<Account> groupingNullifiedAccountsList = new List<Account>();
        List<Account> groupingUpdatedOnAccountList = new List<Account>();
        List<Account> masterGroupingUpdatedOnAccountList = new List<Account>();
        List<Account> PartnerTypeUpdatedOnAccountList = new List<Account>();
        List<Account_Groupings__c> groupingDeactivatedList = new List<Account_Groupings__c>();
        List<Account_Groupings__c> MasterGroupingUpdatedList = new List<Account_Groupings__c>();
                        
        for(Account accountOperation: accountsOfRelatedSiteDunsList){
            if(accountOperation.Grouping_Batch_Operation__c=='InactivateGrouping'){
                groupingInactiveAccountsList.add(accountOperation);
            }
            if(accountOperation.Grouping_Batch_Operation__c=='UpdateRelatedSiteDuns'){
                accountWithSameSiteDUNSList.add(accountOperation);
            }
            if(accountOperation.Grouping_Batch_Operation__c=='Grouping Nullified'){
                groupingNullifiedAccountsList.add(accountOperation);
            }
            if(accountOperation.Grouping_Batch_Operation__c=='updateGroupingOnAccount'){
                groupingUpdatedOnAccountList.add(accountOperation);
            }
            if(accountOperation.Grouping_Batch_Operation__c=='MasterGroupingUpdated'){
                masterGroupingUpdatedOnAccountList.add(accountOperation);
            }
            if(accountOperation.Grouping_Batch_Operation__c=='updateRelatedPartnerTypes'){
                PartnerTypeUpdatedOnAccountList.add(accountOperation);
            }
        }
        
        for(Account_Groupings__c groupingOperation: updatedMasterGroupingsList){
            //Check if Master Grouping is updated
            if(groupingOperation.Grouping_Update__c == 'updateMasterGrouping'){
                MasterGroupingUpdatedList.add(groupingOperation);
            }
            //Check if Grouping is Inactivated
            if(groupingOperation.Grouping_Update__c == 'Grouping Inactivated'){
                groupingDeactivatedList.add(groupingOperation);
            }
        }
        
        if(accountWithSameSiteDUNSList.size()>0){
            List<Account_Groupings__c> updateGroupingList = [SELECT Master_Grouping__c, End_Date__c,
                                                             Profiled_Account__c, Active__c, ID__c, Id, 
                                                             Profiled_Account_Site_Duns__c 
                                                             FROM Account_Groupings__c 
                                                             where Profiled_Account__c in :accountWithSameSiteDUNSList];            
            bulkifiedUpdateRelatedSiteDunsAccount(updateGroupingList);
            //Nullify values after batch process 
            for(Account account:accountWithSameSiteDUNSList){
                account.Grouping_Batch_Operation__c = '  ';
            } 
            update accountWithSameSiteDUNSList;          
        }
        if(groupingInactiveAccountsList.size()>0){
            List<Account_Groupings__c> inactiveGroupingsList = [SELECT Master_Grouping__c, End_Date__c,
                                                             Profiled_Account__c, Active__c, ID__c, Id, 
                                                             Profiled_Account_Site_Duns__c 
                                                             FROM Account_Groupings__c 
                                                             where Profiled_Account__c in :groupingInactiveAccountsList];            
            bulkifiedInactiveGrouping(inactiveGroupingsList);  
            //Nullify values after batch process
            for(Account account:groupingInactiveAccountsList){
                account.Grouping_Batch_Operation__c = '  ';
            } 
            update groupingInactiveAccountsList;          
        }
        if(masterGroupingUpdatedOnAccountList.size()>0){
            List<Account_Groupings__c> updateMasterGroupingList = [SELECT Master_Grouping__c, End_Date__c,
                                                                  Profiled_Account__c, Active__c, ID__c, Id, 
                                                                  Profiled_Account_Site_Duns__c 
                                                                  FROM Account_Groupings__c 
                                                                  where Profiled_Account__c in 
                                                                  :masterGroupingUpdatedOnAccountList];            
            bulkifiedUpdateMasterGrouping(updateMasterGroupingList);
            //Nullify values after batch process 
            for(Account account:masterGroupingUpdatedOnAccountList){
                account.Grouping_Batch_Operation__c = '  ';
            } 
            update accountWithSameSiteDUNSList;          
        }
        if(MasterGroupingUpdatedList.size()>0){
            bulkifiedUpdateMasterGrouping(MasterGroupingUpdatedList);  
            //Nullify values after batch process
            for(Account_Groupings__c groupings: MasterGroupingUpdatedList){
                groupings.Grouping_Update__c = null;
            }    
            update MasterGroupingUpdatedList;    
        }
        
        if(groupingNullifiedAccountsList.size()>0){
            bulkifiedRemoveGroupingonAccount(groupingNullifiedAccountsList);
            //Nullify values after batch process
            for(Account account:groupingNullifiedAccountsList){
                account.Grouping_Batch_Operation__c = '  ';
            } 
            update groupingNullifiedAccountsList;
        }
        
        if(groupingDeactivatedList.size()>0){
            bulkifiedInactiveGrouping(groupingDeactivatedList); 
            //Nullify values after batch process
            for(Account_Groupings__c groupings:groupingDeactivatedList){
                groupings.Grouping_Update__c = null;
            } 
            update groupingDeactivatedList; 
        }
        
        if(groupingUpdatedOnAccountList.size()>0){
            bulkifiedUpdateGroupingOnAccount(groupingUpdatedOnAccountList);
            for(Account account:groupingUpdatedOnAccountList){
                account.Grouping_Batch_Operation__c = '  ';
            } 
            update groupingUpdatedOnAccountList;
        }
        if(PartnerTypeUpdatedOnAccountList.size()>0){
            bulkifiedUpdateRelatedPartnerType(PartnerTypeUpdatedOnAccountList);
            for(Account account:PartnerTypeUpdatedOnAccountList){
                account.Grouping_Batch_Operation__c = '  ';
            } 
            update PartnerTypeUpdatedOnAccountList;
        }
        
    }
    
/* @Method <bulkifiedUpdateRelatedSiteDunsAccount(): Updates Accounts with grouping details for all
                                                  Accounts which has same Site_Duns has that of the 
                                                  Updated one>
   @param <updateGroupingsList>
   <updateGroupingsList -- contains List of Groupings>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/    
    public void bulkifiedUpdateRelatedSiteDunsAccount(List<Account_Groupings__c> updateGroupingsList){
        Map<String,String> assignmentOfGroupNameMap = new Map<String,String>();
        Map<Id,String> associationCreationMap = new Map<Id,String>();
        Map<Id,List<Id>> createAssociationOnAccountMap = new Map<Id,List<Id>>();
        
        for(Account_Groupings__c groups :updateGroupingsList){
                String groupDetails = groups.id+'='+groups.Master_Grouping__c+'@'+groups.Profiled_Account__c;
                assignmentOfGroupNameMap.put(groups.Profiled_Account_Site_Duns__c,groupDetails);
                associationCreationMap.put(groups.Profiled_Account__c,groupDetails);
            }        
        groupingAssignment.updateRelatedGrouping(assignmentOfGroupNameMap);
        createAssociationOnAccountMap = groupingAssignment.fetchRelatedSiteDuns(associationCreationMap);
        associationObj.createAccountAssociation(createAssociationOnAccountMap);
    }
    
/* @Method <bulkifiedUpdateMasterGrouping(): Updates Master Grouping for all Accounts which has same 
                                    Grouping Details as that of the Updated Grouping when its scheduled>
   @param <accountGroupsList>
   <accountGroupsList-- contains List of Groupings in which Master Grouping was updated>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/    
    public void bulkifiedUpdateMasterGrouping(List<Account_Groupings__c> accountGroupsList){
        Map<Id,String> associationUpdation = new Map<Id,String>();
        Map<String,String> assignmentOfGroupName = new Map<String,String>();
               
        for(Account_Groupings__c groups:accountGroupsList){
            String groupDetails = groups.id+'='+groups.Master_Grouping__c+'@'+groups.Profiled_Account__c;
            associationUpdation.put(groups.Profiled_Account__c,groupDetails);
            assignmentOfGroupName.put(groups.Profiled_Account_Site_Duns__c,groupDetails);    
        } 
        groupingAssignment.updateRelatedGrouping(assignmentOfGroupName);  
         
    }
    
/* @Method <bulkifiedInactiveGrouping(): This Method is used while nullifying grouping,Master grouping and 
                                        Profiled Account details for all Accounts which has same Group Name 
                                        when a Grouping is deactivated>
   @param <deactivatedGroupingsList>
   <deactivatedGroupingsList -- List of Inactive Groupings>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/   
    public void bulkifiedInactiveGrouping(List<Account_Groupings__c> deactivatedGroupingsList){
        Map<Id,String> associationDeletionMap = new Map<Id,String>();
        Map<Id,List<Id>> removeAssociationOnAccountMap = new Map<Id,List<Id>>();
        Map<Id,String> accountsToDeleteAssociationMap = new Map<Id,String>();
        
        for(Account_Groupings__c inactiveGrouping: deactivatedGroupingsList){
            String GroupingDetails = inactiveGrouping.id+'='+inactiveGrouping.Master_Grouping__c+'@'+inactiveGrouping.Profiled_Account__c;
            System.debug('GroupingDetails --->'+GroupingDetails );
            associationDeletionMap.put(inactiveGrouping.Profiled_Account__c,GroupingDetails);
        }
        accountsToDeleteAssociationMap = groupingAssignment.removeAllRelatedGrouping(associationDeletionMap);
        removeAssociationOnAccountMap = groupingAssignment.fetchRelatedSiteDuns(accountsToDeleteAssociationMap);
        associationObj.deleteAccountAssociation(removeAssociationOnAccountMap);  
    } 
    
/* @Method <executeRemoveGrouping(): When Grouping on a non profiled account is nullified whose 
                                     SITE_DUNS/ENTITY_ID is not same as that of the profiled Account 
                                     associated to a Active Grouping , this Method is used to nullify
                                     grouping,Master grouping and Profiled Account details for all 
                                     other Accounts which has same SITE_DUNS/ENTITY_ID >
   @param <accountGroupingList>
   <accountGroupingList-- List of accounts for which group details needs to be nullified>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/    
    public void bulkifiedRemoveGroupingonAccount(List<Account> accountGroupingList){
        Set<String> SiteDuns = new Set<String>(); 
        Map<String,String> relatedSiteDuns = new Map<String,String>();
        Map<Id,String> AccountWithoutGroup = new Map<Id,String>();
        List<Account> accountToRemove = new List<Account>();
               
        for(Account acctSiteDun: accountGroupingList){
            SiteDuns.add(acctSiteDun.Site_DUNS_Entity__c);
        }
        List<Account> accountsForGroupingRemovalList = [SELECT Grouping_Batch_Operation__c,Grouping__c,VSI_Approved_Delivery_Products_TA__c,
                                                        Site_DUNS_Entity__c, Master_Grouping__c, IsPartner,Velocity_Specialties_Achieved_TA__c,
                                                        Profiled_Account__c, PROFILED_ACCOUNT_FLAG__c,Affiliate_Services_TA__c
                                                        FROM Account 
                                                        where Site_DUNS_Entity__c in :SiteDuns];        
        
        for(Account acct: accountsForGroupingRemovalList){
            String groupDetails = acct.Grouping__c+'='+acct.Master_Grouping__c+'@'+acct.Profiled_Account__c;
            //String groupDetails = ''+'='+''+'@'+acct.Profiled_Account__c;
            AccountWithoutGroup.put(acct.Profiled_Account__c,groupDetails);
            System.debug('AccountWithoutGroup 1-->'+AccountWithoutGroup);
            acct.Grouping__c=null;
            acct.Master_Grouping__c=null;
            acct.Profiled_Account__c=null;
            acct.VSI_Approved_Delivery_Products_TA__c=NULL;
            acct.Velocity_Specialties_Achieved_TA__c=NULL;
            acct.Affiliate_Services_TA__c=NULL;
            accountToRemove.add(acct);
        }
        if(AccountWithoutGroup.size()>0){
          Map<Id,List<Id>> removeAssociationOnAccount = new Map<Id,List<Id>>();
          System.debug('AccountWithoutGroup 2-->'+AccountWithoutGroup);
          removeAssociationOnAccount = groupingAssignment.fetchRelatedSiteDuns(AccountWithoutGroup);
          associationObj.deleteAccountAssociation(removeAssociationOnAccount);
        }
        
        update accountToRemove;
        
    } 
   
/* @Method <bulkifiedUpdateGroupingOnAccount(): When Grouping on a non profiled account is updated
                                                whose SITE_DUNS/ENTITY_ID is not same as that of 
                                                the profiled Account associated to a Active Grouping,
                                                this Method is used to update Grouping details for 
                                                all other Accounts which has same SITE_DUNS/ENTITY_ID >
   @param <updateGroupingOnAccountList>
   <updateGroupingOnAccountList-- List of accounts for which group details needs to be Updated>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/   
      public void bulkifiedUpdateGroupingOnAccount(List<Account> updateGroupingOnAccountList){
        Set<String> GroupingId = new Set<String>();
        for(Account account: updateGroupingOnAccountList){
            GroupingId.add(account.Grouping__c);
        }
        List<Account_Groupings__c> GroupingsList = [SELECT Master_Grouping__c, End_Date__c,
                                                     Profiled_Account__c, Active__c, ID__c, Id, 
                                                     Profiled_Account_Site_Duns__c 
                                                     FROM Account_Groupings__c 
                                                     where Id in :GroupingId];
        bulkifiedUpdateRelatedSiteDunsAccount(GroupingsList);
      }
      
/* @Method <bulkifiedUpdateRelatedPartnerType(): This method Updates accounts with 
                                                 Partner Type value  as that of the 
                                                 Update Partner Type of the Profiled Accouont,
                                                 if it has the same profiled account field 
                                                 populated on Account.>
       @param <updateGroupingOnAccountList>
       <updateGroupingOnAccountList-- List of accounts for which PartnerType needs to be Updated>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
*/   
      public void bulkifiedUpdateRelatedPartnerType(List<Account> updatePartnerTypeOnAccountList){
        Map<Id,Account> accountIdWithPartnerType = new Map<Id,Account>();
        for(Account profiledAccount: updatePartnerTypeOnAccountList){
            accountIdWithPartnerType.put(profiledAccount.id,profiledAccount);
        }
        if(accountIdWithPartnerType.size()>0){
            groupingAssignment.updateRelatedPartnerType(accountIdWithPartnerType);
        }
      }
      
}