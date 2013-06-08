/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 23/11/2010     Karthik Shivprakash      846       This is used to select all the sites   
                                                     within a group when creating an
 |                                                   association.
 
 | 02/12/2010     Karthik Shivprakash      846       Updated the class to create association
                                                     on all the accounts which comes under
                                                     same grouping.
 | 25/02/2011     Anirudh Singh            1598      This is used to select all the accounts
                                                     when grouping is made between the profiled accounts.
 | 04/05/2011     Anirudh Singh            2827      Updated class and Create PopulatePreferredDistributor
                                                     method to populate preffred dsitributor on Profiled Account
 |                                                   if any Preferred Association is created.
 | 05/07/2011     Suman B                            Added to check Profiled Account not null. 
 | 14 Feb 2012    Arif                               Adding Null Check(For removing exception) in createAccountMap method
 | 19 Feb 2012	  Anil								 kept Null Check to remove Producation exceptions   
 +=============================================================================================*/

public with sharing class PRM_GroupingAssociation {

public static boolean isInsertEventExecuted = false;
Set<id> setPreferredDistyAccountstoProcess = New set<id>();
//Here creating the instance of the util class PRM_RecordVisibility
PRM_RecordsVisibility association = new PRM_RecordsVisibility();

//Using this map to store the profiled accounts with its related grouping Id
Map<Id,Account> ProfiledAccountWithGrouping = new Map<Id,Account>();

//Using this map to store the account Id against the associated account Id
Map<Id,Id> AccountAndAssociatedAccountMap = new Map<Id,Id>(); 

//Using this map to store the profiled account Id against the associated account Id 
Map<Id,Id> ProfiledAccountAndAccountMap = new Map<Id,Id>();


/* @Method <This method is used to fetch the new account Id against the associated account Id>
   @param <This is taking list of newly created associated accounts>
   <AccountAssociationList -- Which contains newly associated accounts>
   @return <void> -- <Returns nothing>.
   @throws exception - <No Exception>
*/
    
    public void fetchAssociatedAccount(List<APPR_MTV__RecordAssociation__c> AccountAssociationList){
        
            
        System.debug('AccountAssociationList-->'+AccountAssociationList);
        for(APPR_MTV__RecordAssociation__c associationObj: AccountAssociationList){
            AccountAndAssociatedAccountMap.put(associationObj.APPR_MTV__Associated_Account__c,associationObj.APPR_MTV__Account__c);
        }
        System.debug('AccountAndAssociatedAccountMap'+AccountAndAssociatedAccountMap);
        if(AccountAndAssociatedAccountMap.size()>0){
            processAccountAssociation(AccountAndAssociatedAccountMap);
        }
    }

/* @Method <This method is used to process the accounts which got newly associated
             and get the profiled accounts of type Distributor or Distribution VAR>
   @param <This is taking Map which contains Associated account Id and Account Id>
   <AccountAndAssociatedAccountMap -- Map which contains Associated account Id and Account Id>
   @return <void> -- <Returns nothing>.
   @throws exception - <No Exception>
*/
    
    public void processAccountAssociation(Map<Id,Id> AccountAndAssociatedAccountMap){
        
       Map<Id,Account> AssociatedAccountMap = new Map<Id,Account>([select id,Partner_Type__c,Lead_Oppty_Enabled__c,
                                                PROFILED_ACCOUNT_FLAG__c,Grouping__c ,
                                                Site_DUNS_Entity__c     
                                                from account
                                                where Id=:AccountAndAssociatedAccountMap.keySet()
                                                or Id=:AccountAndAssociatedAccountMap.values()]);
        
       System.debug('Query Result'+AssociatedAccountMap);
                                                
        for(ID assocObjId: AccountAndAssociatedAccountMap.keySet()){
            ID AssociatedAccount = AccountAndAssociatedAccountMap.get(assocObjId);
            Account ProfiledAccount = AssociatedAccountMap.get(assocObjId);
          if(ProfiledAccount != Null){
            System.debug('Profiled Site Duns'+ProfiledAccount.Site_DUNS_Entity__c);
            System.debug('Associated Site Duns'+AssociatedAccountMap.get(AssociatedAccount).Site_DUNS_Entity__c);
            ProfiledAccountAndAccountMap.put(AccountAndAssociatedAccountMap.get(assocObjId),assocObjId);
            System.debug('ProfiledAccountAndAccountMap'+ProfiledAccountAndAccountMap);
            
            if(ProfiledAccount.Site_DUNS_Entity__c!=null || AssociatedAccountMap.get(AssociatedAccount).Site_DUNS_Entity__c!=null){
                if(ProfiledAccount.Site_DUNS_Entity__c != AssociatedAccountMap.get(AssociatedAccount).Site_DUNS_Entity__c){
                    if(ProfiledAccount.PROFILED_ACCOUNT_FLAG__c==true){
                        if(ProfiledAccount.Partner_Type__c == 'Distributor' && AssociatedAccountMap.get(AssociatedAccount).Partner_Type__c == 'Distribution VAR'){
                            //ProfiledAccountWithSiteDuns.put(ProfiledAccount.Site_DUNS_Entity__c,ProfiledAccount);
                            ProfiledAccountWithGrouping.put(ProfiledAccount.Grouping__c,ProfiledAccount);
                            System.debug('ProfiledAccountWithGrouping in First condition'+ProfiledAccountWithGrouping);
                        }
                        else if(ProfiledAccount.Partner_Type__c == 'Distribution VAR' && AssociatedAccountMap.get(AssociatedAccount).Partner_Type__c == 'Distributor')
                        {
                            //ProfiledAccountWithSiteDuns.put(ProfiledAccount.Site_DUNS_Entity__c,ProfiledAccount);
                            ProfiledAccountWithGrouping.put(ProfiledAccount.Grouping__c,ProfiledAccount);
                            System.debug('ProfiledAccountWithGrouping in Second condition'+ProfiledAccountWithGrouping);
                        }
                    }
                    else
                    {
                        System.debug('If Association is from Profiled Account');
                        if(ProfiledAccount.Partner_Type__c == 'Distributor' && AssociatedAccountMap.get(AssociatedAccount).Partner_Type__c == 'Distribution VAR'){
                            //ProfiledAccountWithSiteDuns.put(AssociatedAccountMap.get(AssociatedAccount).Site_DUNS_Entity__c,ProfiledAccount);
                            ProfiledAccountWithGrouping.put(AssociatedAccountMap.get(AssociatedAccount).Grouping__c,ProfiledAccount);
                            System.debug('ProfiledAccountWithGrouping in First condition'+ProfiledAccountWithGrouping);
                        }
                        else if(ProfiledAccount.Partner_Type__c == 'Distribution VAR' && AssociatedAccountMap.get(AssociatedAccount).Partner_Type__c == 'Distributor')
                        {
                            //ProfiledAccountWithSiteDuns.put(AssociatedAccountMap.get(AssociatedAccount).Site_DUNS_Entity__c,ProfiledAccount);
                            ProfiledAccountWithGrouping.put(AssociatedAccountMap.get(AssociatedAccount).Grouping__c,ProfiledAccount);
                            System.debug('ProfiledAccountWithGrouping in Second condition'+ProfiledAccountWithGrouping);
                        }
                    }
                }
            }
          } // Added to check Null condition for Account.
        }
            
        if(ProfiledAccountWithGrouping.size()>0){
            //creatingAssociation(ProfiledAccountWithGrouping);
        }
    }

/* @Method <isUnderLimit(): This method is used to check the size of accountMap.
                            If its greater than or equal to DML Limit bypass the
                             regular process of association and call scheduler>
   @param <This method takes Map as parameter>
   <AccountMap -- Which contains profiled account and all accounts with same 
                    SiteDuns as that of Profiled Account>
    @return <boolean> - <Returns True if the size of the AccountMap is Greater 
                        than DML Limit else False>
   @throws exception - <No Exception>
*/

    public Boolean isUnderLimit(Map<Id,Account> AccountMap){
       Boolean notUnderLimit=true;
       if(AccountMap.values().size()>= (Limits.getLimitDMLRows())/2){
           notUnderLimit=false;
       }       
       return notUnderLimit;
   }


/* @Method <This method is used to create the accounts association with the related
             accounts of same siteDuns of the profiled accounts of type Distributor 
             or Distribution VAR>
   @param <This is taking Map which contains Grouping Id and related Accounts>
   <ProfiledAccountWithGrouping -- Map which contains Grouping Id and related Accounts>
   @return <void> -- <Returns nothing>.
   @throws exception - <No Exception>

    
    public void creatingAssociation(Map<Id,Account> ProfiledAccountWithGrouping){
        
        Map<Id,Account> AccountsWithSameGrouping = new Map<Id,Account>();
        Map<Id,List<Id>> AccountWithRelatedAccounts = new Map<Id,List<Id>>();
        List<Id> RelatedAccountsId = new List<Id>();
        List<Account> RelatedAccounts = new List<Account>();
        String GroupingAssociation;
        
        AccountsWithSameGrouping=queryOnAccount(ProfiledAccountWithGrouping);
        Boolean BatchProcess = isUnderLimit(AccountsWithSameGrouping);
        if(BatchProcess==false){
            System.debug('AccountsWithSameGrouping over limit'+AccountsWithSameGrouping);
            for(Account accObj: AccountsWithSameGrouping.values()){
                if(accObj.PROFILED_ACCOUNT_FLAG__c==true){
                    GroupingAssociation = 'Association'+'&'+AccountAndAssociatedAccountMap.get(accObj.Id);
                    accObj.Grouping_Batch_Operation__c=GroupingAssociation;
                    RelatedAccounts.add(accObj);
                    System.debug('Account Details'+RelatedAccounts);
                }
            }
            update RelatedAccounts;
        }
        else{
            AccountsWithSameGrouping=queryOnAccount(ProfiledAccountWithGrouping);
            System.debug('AccountsWithSameGrouping'+AccountsWithSameGrouping);
            for(Account acctObj: AccountsWithSameGrouping.values()){
                if(acctObj.PROFILED_ACCOUNT_FLAG__c!=true && AccountAndAssociatedAccountMap.get(acctObj.Profiled_Account__c)!=null){
                    RelatedAccountsId.add(acctObj.Id);
                    AccountWithRelatedAccounts.put(AccountAndAssociatedAccountMap.get(acctObj.Profiled_Account__c),RelatedAccountsId);
                    System.debug('Account to Assoc in Profiled'+AccountAndAssociatedAccountMap.get(acctObj.Profiled_Account__c));
                }
                else if(acctObj.PROFILED_ACCOUNT_FLAG__c!=true && ProfiledAccountAndAccountMap.get(acctObj.Profiled_Account__c)!=null){
                    RelatedAccountsId.add(acctObj.Id);
                    AccountWithRelatedAccounts.put(ProfiledAccountAndAccountMap.get(acctObj.Profiled_Account__c),RelatedAccountsId);
                    System.debug('Account to Assoc in Non Profiled'+ProfiledAccountAndAccountMap.get(acctObj.Profiled_Account__c));
                }
                System.debug('AccountWithRelatedAccounts Map'+AccountWithRelatedAccounts);
            }
            if(AccountWithRelatedAccounts.size()>0){
               // association.createAccountAssociation(AccountWithRelatedAccounts);
            }
        }
    }   
*/

/* @Method <This method is used to query on accounts to fetch the related accounts
             of the profiled account with which the newly association has got created>
   @param <This is taking Map which contains Grouping Id and related Accounts>
   <ProfiledAccountWithGrouping -- Map which contains Grouping Id and related Accounts>
   @return <Map<Id,Account>> -- <Returns Map which contains accounts Id and Accounts>.
   @throws exception - <No Exception>
*/
    public Map<Id,Account> queryOnAccount(Map<Id,Account> ProfiledAccountWithGrouping){
        
        Map<Id,Account> AccountsWithSameGrouping = new Map<Id,Account>();
        AccountsWithSameGrouping = new Map<Id,Account>([Select a.Grouping__c, 
                                        a.Grouping_Batch_Operation__c, a.Id,
                                        a.PROFILED_ACCOUNT_FLAG__c ,a.Site_DUNS_Entity__c ,
                                        a.Profiled_Account__c ,Lead_Oppty_Enabled__c 
                                        from Account a
                                        where a.Grouping__c=:ProfiledAccountWithGrouping.keySet()
                                        and a.Lead_Oppty_Enabled__c=true and Child_Partner_Users_Count__c>0]);
        
        System.debug('AccountsWithSameGrouping'+AccountsWithSameGrouping);
        return AccountsWithSameGrouping;
    }
    // Created By Anirudh
/* @Method <This method is used to create Maps for the associations and process
        the associations at the grouping level>
   @param <This is taking List of Associations from PRM_AfterInsert trigger>
   @return <void> -- <Returns nothing>.
   @throws exception - <No Exception>
*/

    public void createAccountMap(List<APPR_MTV__RecordAssociation__c> ListAfterInsert){
        PRM_RecordsVisibility objPRMVisibility = new PRM_RecordsVisibility();        
        PRM_RecordsVisibility.isInsertEventExecuted = true;
        List<APPR_MTV__RecordAssociation__c> AfterInsertAssociation = New List<APPR_MTV__RecordAssociation__c>();
        Map<Id,Id> AccountWithAssociatedAccounts = new Map<Id,Id>();
        set<Id> DistributionVarPfAccounts = New set<Id>();
        set<Id> DistributorPfAccounts= New set<Id>();
        boolean PreferredFlag;
        List<Account> NonProfiledAccounts = New List<Account>();
        List<Id> DistyAccountstoProcess = New List<Id>();
        List<Id> DistyVarAccountstoProcess = New List<Id>();       
        List<Id> PreferredDistyAccountstoProcess = New List<Id>();        
        MaP<Id,List<Id>> AccountsWithPfAccount = New MaP<Id,List<Id>>();
        MaP<Id,List<Id>> AccountsWithDistyPfAccount = New MaP<Id,List<Id>>();
        MaP<Id,List<Id>> AccountsWithDistyVarPfAccount = New MaP<Id,List<Id>>();
        Map <Id,Id> MapAccountWithPreferredDistyAcc = New Map <Id,Id>();
         
       
       if(ListAfterInsert.size()>0){
        
          for(APPR_MTV__RecordAssociation__c association :ListAfterInsert){
            AccountWithAssociatedAccounts.put(association.APPR_MTV__Associated_Account__c,association.APPR_MTV__Account__c);
                  
            System.Debug('AccountWithAssociatedAccounts------->' +AccountWithAssociatedAccounts);
        }
        Map<Id,Account> MapId_AssociatedAccounts = New Map<Id,Account>([select id,Partner_Type__c,Lead_Oppty_Enabled__c,
                                                PROFILED_ACCOUNT_FLAG__c,Grouping__c ,
                                                Site_DUNS_Entity__c     
                                                from account
                                                where (PROFILED_ACCOUNT_FLAG__c=true)and 
                                                (Id in:AccountWithAssociatedAccounts.keySet()
                                                or Id in:AccountWithAssociatedAccounts.values())]);
        System.Debug('MapId_AssociatedAccounts---->'+MapId_AssociatedAccounts);
        
        for(Id acct :AccountWithAssociatedAccounts.keyset()){
            Account acc_key= MapId_AssociatedAccounts.get(acct);
            Account acc_value=   MapId_AssociatedAccounts.get(AccountWithAssociatedAccounts.get(acct));
            Id DistiAccId = null;
            Id DistiVARId = null;
            if(acc_value !=null &&  acc_key!=null ){ 
                if(acc_value.Partner_Type__c != '' && acc_value.Partner_Type__c != null){               
                    if(acc_value.Partner_Type__c.indexof('Distribution VAR')!=-1 && acc_key.Partner_Type__c.indexof('Distributor')!=-1){
                        DistiVARId = acc_value.Id;
                        DistiAccId = acc_key.Id;                   
                    } 
                    if(acc_value.Partner_Type__c.indexof('Distributor')!=-1 && acc_key.Partner_Type__c.indexof('Distribution VAR')!=-1){
                        DistiVARId = acc_key.Id;
                        DistiAccId = acc_value.Id;
                    }
                }     
                    if(DistiVARId!=Null && DistiAccId!= Null){
                        
                        DistributionVarPfAccounts.add(DistiVARId);
                        DistributorPfAccounts.add(DistiAccId);                  
                    
                }
            }
            system.debug('Size of Disty List-->' +DistributorPfAccounts);
            system.debug('Size of Var List-->' +DistributionVarPfAccounts);
        }
    
            
            
         NonProfiledAccounts = [select id,Partner_Type__c,Lead_Oppty_Enabled__c,
                               PROFILED_ACCOUNT_FLAG__c,Grouping__c ,
                               Site_DUNS_Entity__c,Profiled_Account__c   
                               from account
                               where (PROFILED_ACCOUNT_FLAG__c=false and Child_Partner_Users_Count__c>0)
                               and (Profiled_Account__c in:DistributionVarPfAccounts
                               or Profiled_Account__c in:DistributorPfAccounts)];
                               
        if(NonProfiledAccounts.size()>0){
            
        
        for(Account acct: NonProfiledAccounts){           
            
                List<Id> LstNonPfAccounts = AccountsWithPfAccount.get(acct.Profiled_Account__c);
                if(LstNonPfAccounts==null){
                    LstNonPfAccounts = new List<Id>();
                }
                LstNonPfAccounts.add(acct.Id);                
                AccountsWithPfAccount.put(acct.Profiled_Account__c,LstNonPfAccounts);
                
            }
        }
        else {
              objPRMVisibility.createAssociationDistributorT2VAR(ListAfterInsert);
        }
            
            
       for(APPR_MTV__RecordAssociation__c association :ListAfterInsert){
           System.Debug('FlagValueofIF' +DistributionVarPfAccounts.contains(association.APPR_MTV__Account__c));
           if(DistributionVarPfAccounts.contains(association.APPR_MTV__Account__c) && DistributorPfAccounts.contains(association.APPR_MTV__Associated_Account__c)){
              if((AccountsWithPfAccount.get(association.APPR_MTV__Account__c))!=null){
              DistyVarAccountstoProcess =AccountsWithPfAccount.get(association.APPR_MTV__Account__c) ;
              System.Debug('DistyVarAccountstoProcess-->' +DistyVarAccountstoProcess);
                                
              }if(association.APPR_MTV__Primary__c){
                     MapAccountWithPreferredDistyAcc.put(association.APPR_MTV__Account__c,association.APPR_MTV__Associated_Account__c);
                     if(MapAccountWithPreferredDistyAcc.size()>0){
                         PopulatePreferredDistributor(MapAccountWithPreferredDistyAcc);
                     }
                if((AccountsWithPfAccount.get(association.APPR_MTV__Associated_Account__c))!=null){
                 PreferredDistyAccountstoProcess =AccountsWithPfAccount.get(association.APPR_MTV__Associated_Account__c) ;
                 MapAccountWithPreferredDistyAcc.put(association.APPR_MTV__Account__c,association.APPR_MTV__Associated_Account__c);
                 if(MapAccountWithPreferredDistyAcc.size()>0){
                    PopulatePreferredDistributor(MapAccountWithPreferredDistyAcc);
                 }
                    
                 }if(PreferredDistyAccountstoProcess.size()>0){
                    for(id preffrddisty :PreferredDistyAccountstoProcess){
                        setPreferredDistyAccountstoProcess.add(preffrddisty);
                    }
                 }
                System.Debug('PreferredDistyAccountstoProcess---->' +PreferredDistyAccountstoProcess);  
              }
              
              if(!association.APPR_MTV__Primary__c){
                if((AccountsWithPfAccount.get(association.APPR_MTV__Associated_Account__c))!=null){
                DistyAccountstoProcess =AccountsWithPfAccount.get(association.APPR_MTV__Associated_Account__c) ;
              System.Debug('DistyAccountstoProcess-->' +DistyAccountstoProcess);
                }
              }
              if(PreferredDistyAccountstoProcess.size()>0){
           AccountsWithDistyVarPfAccount.put(association.APPR_MTV__Account__c,PreferredDistyAccountstoProcess);
           }if(DistyAccountstoProcess.size()>0){
            AccountsWithDistyVarPfAccount.put(association.APPR_MTV__Account__c,DistyAccountstoProcess);
           }
           
           AccountsWithDistyPfAccount.put(association.APPR_MTV__Associated_Account__c,DistyVarAccountstoProcess);
           }
           //System.Debug('Valueof 2ndIf--->' + DistributionVarPfAccounts.contains(association.APPR_MTV__Associated_Account__c) && DistributorPfAccounts.contains(association.APPR_MTV__Account__c));
           if(DistributionVarPfAccounts.contains(association.APPR_MTV__Associated_Account__c) && DistributorPfAccounts.contains(association.APPR_MTV__Account__c)){
              if((AccountsWithPfAccount.get(association.APPR_MTV__Associated_Account__c))!=null){
              DistyVarAccountstoProcess =AccountsWithPfAccount.get(association.APPR_MTV__Associated_Account__c) ;
              System.Debug('DistyVarAccountstoProcess-->' +DistyVarAccountstoProcess);
              }              
              if(!association.APPR_MTV__Primary__c){
                 if((AccountsWithPfAccount.get(association.APPR_MTV__Account__c))!=null){
                DistyAccountstoProcess =AccountsWithPfAccount.get(association.APPR_MTV__Account__c) ;
              System.Debug('DistyAccountstoProcess-->' +DistyAccountstoProcess);
              }
              }
              if(DistyAccountstoProcess.size()>0){
            AccountsWithDistyVarPfAccount.put(association.APPR_MTV__Associated_Account__c,DistyAccountstoProcess);
           }
           
           AccountsWithDistyPfAccount.put(association.APPR_MTV__Account__c,DistyVarAccountstoProcess);
           }
           /*if(DistributorPfAccounts.contains(AccountWithAssociatedAccounts.get(assacct))){
              DistyAccountstoProcess =AccountsWithPfAccount.get(AccountWithAssociatedAccounts.get(assacct)) ;
              System.Debug('DistyAccountstoProcess-->' +DistyAccountstoProcess);
           }*/
           
           system.debug('AccountsWithDistyPfAccount---->' +AccountsWithDistyPfAccount);
           system.debug('AccountsWithDistyVarPfAccount---->' +AccountsWithDistyVarPfAccount);
       }
       
       
       List<APPR_MTV__RecordAssociation__c> lstAssociationAccount = new List<APPR_MTV__RecordAssociation__c> ();
       if(DistyVarAccountstoProcess.size()>0 && DistyAccountstoProcess.size()>0){
            system.debug('DistyVarAccountstoProcess--->' +DistyVarAccountstoProcess);
            system.debug('DistyAccountstoProcess--->'+DistyAccountstoProcess);
             lstAssociationAccount.addAll(CreateGroupingAssociation(DistyVarAccountstoProcess,DistyAccountstoProcess));  
       }
       if(DistyVarAccountstoProcess.size()>0 && PreferredDistyAccountstoProcess.size()>0){      
            system.debug('DistyVarAccountstoProcess--->' +DistyVarAccountstoProcess);
            system.debug('PreferredDistyAccountstoProcess--->'+PreferredDistyAccountstoProcess);
            lstAssociationAccount.addAll(CreateGroupingAssociation(DistyVarAccountstoProcess,PreferredDistyAccountstoProcess));
       }
       
       lstAssociationAccount.addAll(createAccountAssociations(AccountsWithDistyPfAccount,'Distribution VAR'));
       lstAssociationAccount.addAll(createAccountAssociations(AccountsWithDistyVarPfAccount,'Distributor'));
        
        if(lstAssociationAccount.size()>0){
           
            insert lstAssociationAccount;
            lstAssociationAccount.addall(AfterInsertAssociation);
            system.debug('ListAfterInsert'+ListAfterInsert);
            lstAssociationAccount.addall(ListAfterInsert);
            objPRMVisibility.createAssociationDistributorT2VAR(lstAssociationAccount);
        }
        
       }                   
                                                                  
        
    }
   
/* @Method <This Method is used to Create Association between Non Profiled Accounts of Two Groups>
   @param <This is taking Two List of Accounts to Process>
   @return <void> -- List<APPR_MTV__RecordAssociation__c>.
   @throws exception - <No Exception>
*/    
    
    public List<APPR_MTV__RecordAssociation__c> CreateGroupingAssociation(List<Id>DistyVarAccounts,List<id>DistyAccounts){
        List<APPR_MTV__RecordAssociation__c> associationAccountList = new List<APPR_MTV__RecordAssociation__c>();
        System.Debug('DistyVarAccounts--->' +DistyVarAccounts);
        System.Debug('DistyAccounts---->' +DistyAccounts);
        for(id distyVarid :DistyVarAccounts){
            for(id distyid :DistyAccounts){
                associationAccountList.add(new APPR_MTV__RecordAssociation__c(APPR_MTV__Account__c=distyVarid,APPR_MTV__Associated_Account__c=distyid,APPR_MTV__Account_Role__c='Distributor'));
                System.Debug('AllAssociations tobe Made--->' +associationAccountList);  
            }   
        }
        return associationAccountList;
    }
/* @Method <This Method is used to Create Association between Profiled account and 
            Non Profiled Accounts of other group>
   @param <This is taking Map of Profiled Acct Id and List of Non Profiled Acct to Process>
   @return <void> -- List<APPR_MTV__RecordAssociation__c>.
   @throws exception - <No Exception>
*/
    public List<APPR_MTV__RecordAssociation__c> createAccountAssociations(Map<Id,List<Id>> AccountWithPfAccount,String Role){
        List<APPR_MTV__RecordAssociation__c> associationAccountList = new List<APPR_MTV__RecordAssociation__c>();
        List<Id> associatedacct = new List<Id>();
        for(Id acct: AccountWithPfAccount.keySet()){
            associatedacct = AccountWithPfAccount.get(acct);
            for(Id acctId: associatedacct){
                if(setPreferredDistyAccountstoProcess.contains(acctId)){
                associationAccountList.add(new APPR_MTV__RecordAssociation__c(APPR_MTV__Account__c=acct,APPR_MTV__Associated_Account__c=acctId,APPR_MTV__Account_Role__c=Role,APPR_MTV__Primary__c=false));                
                System.debug('Association Record after adding'+associationAccountList);
                }else{
                 associationAccountList.add(new APPR_MTV__RecordAssociation__c(APPR_MTV__Account__c=acct,APPR_MTV__Associated_Account__c=acctId,APPR_MTV__Account_Role__c=Role,APPR_MTV__Primary__c=false));    
                System.Debug('Value of list in else--' +associationAccountList);
                }
                
            }
        }
        System.Debug('List of Records insertedfor PF Accts-->'+associationAccountList);
        return associationAccountList;
    }
/* @Method <This Method is used to Check if there is already a Preferred Distributor
            on Distribution VAR account>
   @param <This is List of Newly Inserted or Updated Association Record>
   @return <void> -- List<APPR_MTV__RecordAssociation__c>.
   @throws exception - <No Exception>
*/  
     public void PreferredDistributorCheck(List<APPR_MTV__RecordAssociation__c> ListBeforeInsert){        
        Map<Id,Id> AccountwithPreferredAccount = New Map<Id,Id>();
        List<APPR_MTV__RecordAssociation__c> associationAccountList = new List<APPR_MTV__RecordAssociation__c>();
        List<Account> PreferredProfiledAccount = New List<Account>();
        List<Id> ListProfiledAssociatedAccounts = New List<Id>();
        List<Id> ListAssociatedAccount = New List<Id>();
        List<Id> PreferredAccts = New List<Id>();
        for(APPR_MTV__RecordAssociation__c newassociation :ListBeforeInsert){
            if(newassociation.APPR_MTV__Primary__c){
                AccountwithPreferredAccount.put(newassociation.APPR_MTV__Account__c,newassociation.APPR_MTV__Associated_Account__c);
            }
        }
        associationAccountList = [Select APPR_MTV__Associated_Account__c from APPR_MTV__RecordAssociation__c
                                 where (APPR_MTV__Account__c in :AccountwithPreferredAccount.keyset())
                                 and (APPR_MTV__Primary__c=true) and (APPR_MTV__Associated_Account__r.PROFILED_ACCOUNT_FLAG__c =true)];
        if(associationAccountList.size()>0){
            for(APPR_MTV__RecordAssociation__c newassociation :ListBeforeInsert){
                newassociation.adderror(System.Label.Preferred_Distributor_Error);
            }   
        }    
          
        
           
     }
/* @Method <This method is used to delete assocition between distributor and T2 VAR partners.>
   @param <this method is taking List of Updated Partner accounts as arguments>
   @return <void> - <returning nothing>
   @throws exception - <No Exception>
*/
    public void deleteAssociation(List<Id> listtriggerUpdate){      
                
        // fetch the record using Accountids and associated account id's            
        Map<Id, APPR_MTV__RecordAssociation__c> updateRecordAsso = new Map<Id,APPR_MTV__RecordAssociation__c>(
                                                [Select Id, APPR_MTV__Account__c, APPR_MTV__Associated_Account__c, 
                                                        APPR_MTV__Account_Role__c, APPR_MTV__Primary__c from  APPR_MTV__RecordAssociation__c 
                                                 where APPR_MTV__Account__c in:listtriggerUpdate Or APPR_MTV__Associated_Account__c in:listtriggerUpdate limit 1000]);
        if(updateRecordAsso.size()>0){
            delete updateRecordAsso.values();
        }       
    }    
    
/* @Method <This method is used to create assocition between distributor and T2 VAR partners when Accounts
            are Updated>
    @param <this method is taking List of Updated Partner accounts as arguments>
    @return <void> - <returning nothing>
    @throws exception - <No Exception>
*/
    
    public void createAssociationsforUpdate(List<Account> ListAfterUpdateAccount){
        List<APPR_MTV__RecordAssociation__c> AssociationstoCreate = New List<APPR_MTV__RecordAssociation__c>();
        List<APPR_MTV__RecordAssociation__c> AssociationOnPfAcct = New List<APPR_MTV__RecordAssociation__c>();
        List<APPR_MTV__RecordAssociation__c> NewAssociations = New List<APPR_MTV__RecordAssociation__c>();
        Set<Id> SetProfiledAccts = New Set<Id>();
        Map<Id,List<APPR_MTV__RecordAssociation__c>> AssociationWithPfAccount = New Map<Id,List<APPR_MTV__RecordAssociation__c>>();
        
        Map<Id,Id> AcctWithProfiledAcct = New Map<Id,Id>();
        
        if( ListAfterUpdateAccount.size()>0){
          for(Account acct :ListAfterUpdateAccount){
                if(acct.Profiled_Account__c!=null){
              AcctWithProfiledAcct.put(acct.id,acct.Profiled_Account__c);
              SetProfiledAccts.add(acct.Profiled_Account__c);
              System.Debug('SetProfiledAccts--->' +SetProfiledAccts);
                }
          }
          AssociationOnPfAcct = [Select Id, APPR_MTV__Account__c, APPR_MTV__Associated_Account__c, 
                                 APPR_MTV__Account_Role__c, APPR_MTV__Primary__c from  APPR_MTV__RecordAssociation__c 
                                 where APPR_MTV__Account__c in:AcctWithProfiledAcct.Values() and (APPR_MTV__Account_Role__c = 'Distributor' or APPR_MTV__Account_Role__c = 'Distribution VAR')];
          if(AssociationOnPfAcct.size()>0){
             for(APPR_MTV__RecordAssociation__c association: AssociationOnPfAcct){           
            
                 List<APPR_MTV__RecordAssociation__c> AssociatedAccts = AssociationWithPfAccount.get(association.APPR_MTV__Account__c);
                 if(AssociatedAccts==null){
                    AssociatedAccts = new List<APPR_MTV__RecordAssociation__c>();
                 }
                    AssociatedAccts.add(association);                
                    AssociationWithPfAccount.put(association.APPR_MTV__Account__c,AssociatedAccts);
                    System.Debug('AssociationWithPfAccount--->' +AssociationWithPfAccount);
              }
          }
            if(AcctWithProfiledAcct.size()>0 && AssociationWithPfAccount.size()>0){
                for(id acct :AcctWithProfiledAcct.keyset()){
                    if(SetProfiledAccts.contains(AcctWithProfiledAcct.get(acct))){
                        AssociationstoCreate = AssociationWithPfAccount.get(AcctWithProfiledAcct.get(acct));
                        System.Debug('AssociationstoCreate--->' +AssociationstoCreate);
                        if(AssociationstoCreate!=null && AssociationstoCreate.size()>0){
                           for (APPR_MTV__RecordAssociation__c asst :AssociationstoCreate){
                                NewAssociations.add(new APPR_MTV__RecordAssociation__c(APPR_MTV__Account__c=acct,APPR_MTV__Associated_Account__c=asst.APPR_MTV__Associated_Account__c,APPR_MTV__Account_Role__c=asst.APPR_MTV__Account_Role__c,APPR_MTV__Primary__c=False));
                           }
                        }
                        
                    }
                    
                }
                insert NewAssociations;
                association.createAssociationDistributorT2VAR(NewAssociations);
            }                        
       }
        
    }
/* @Method <This method is used to populate Preferred Distributor on Distribution VAr Accountsd>
    @param <This method is taking Map of Id's of Account for which association is created>
    @return <void> - <returning nothing>
    @throws exception - <No Exception>
*/
    
    public void populatePreferredDistributor(Map<Id,Id> AccountWithPreferredDisty){ 
        Map<Id,Account> lstDistributionVarAccount=New Map<id,Account>([Select Id,Preferred_Distributor__c from Account
                                                 where Id in :AccountWithPreferredDisty.keyset() and Profiled_Account_Flag__c=true]);
        List<Account> lstAccountToUpdate= New List<Account>();                       
        for(Id distyVarId :AccountWithPreferredDisty.keyset()){
            if(lstDistributionVarAccount.get(distyVarId)!= null){
                lstDistributionVarAccount.get(distyVarId).Preferred_Distributor__c=AccountWithPreferredDisty.get(distyVarId);
            }
            lstAccountToUpdate.add(lstDistributionVarAccount.get(distyVarId));
        }   
        if (lstAccountToUpdate.size()>0){  
            Update lstAccountToUpdate;
        }
    } 
    
}