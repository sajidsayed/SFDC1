/*=====================================================================================================+

|  HISTORY  |                                                                            

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 
                                                       
| 04/10/2010     Prasad Kothawade         WR 1070       Moved the code from class PRM_AccountAssignmentScheduler.
                                                        This class is used to create the 
                                                        account share between the associated accounts.
                            
  05/10/2010	Ashwini Gowda 			Def#125			Calling disablingPartnerContactsBatch() Method 
  														from the execute() Method in the batch program to
  														Uncheck 'Partner User' checkbox when partner user
												        is disabled. Reusing the existing Batch Program.   
 04/24/12		Prasad									Contact sync -called from finish method												                                                                    
+=====================================================================================================*/

global with sharing class PRM_AccountAssociationBatch implements Database.Batchable<SObject> {
    
    public string batchName;
    public string batchQuery;
    
     //Used to store account id's and its role name by concatenating account
    //name with "Partner Executive".
    Map<Id,String> accountRoleNameMap = new Map<Id,String>();
    
    //Used to store the account Id's of the user along with group id.
    Map<Id,Id> AccountGroupMap = new Map<Id,Id>();
    
    //Used to store the account share records.
    List<AccountShare> accShareList = new List<AccountShare>();
    
    //Used to store account Id's from the newly created user.
    List<Id> AccountIds = new List<Id>();
    
    //Used to store the account record details using the previous accountIds which
    //contains newly created users.
    List<Account> Accounts = new List<Account>();
    
    //Used to store the timing for the scheduler to fetch the newly created user.
    Map<String,CustomSettingDataValueMap__c> scheduleTime = CustomSettingDataValueMap__c.getall();
    
    PRM_ContactUserSynchronization contactSynchronization = new PRM_ContactUserSynchronization();
    boolean contactsync=false;
    public PRM_AccountAssociationBatch(){
        batchName = 'Account Association Batch: ' + Datetime.now();
        system.debug(batchName + ' started ');
        
        Datetime dt = System.now();
        
        //Converting the value from string to integer for the custom 
        //setting DataValueMap.
        Integer timeInMin = Integer.valueof(scheduleTime.get('AccountShareSchedularTimeInterval').DataValue__c);
        System.debug('Time value'+timeInMin);
        
        //Here adding all the newly created user's into the list.
        dateTime dtThreshold  =system.now().addMinutes(-timeInMin);    
        batchQuery = 'select id,contactId,contact.AccountId '+ 
                                'from User '+
                                'where contactId!=null and  '+ 
                                'createdDate >'+ (dtThreshold.format('yyyy-MM-dd'))+'T'+dtThreshold.format('HH:mm:ss')+'z';

        system.debug(batchQuery);
    }
    
    /*@Method <This method gets executed acutomatically when the batch job is started.>
    @param <Database.BatchableContext BC - Batchable context>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(batchQuery);
    }
    
    /*@Method <This method gets executed acutomatically when the batch job is execution mode.>
    @param <Database.BatchableContext BC - Batchable context>
    @param <List<Sobject> scope - scope>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
    */
    global void execute(Database.BatchableContext BC, list<SObject> scope){
        //Checking if newly created users exits then next method is called.
        List<User> lstUsers=(User[]) scope;
        if(lstUsers.size()>0){
            AccountIds = getAccountsFromUser(lstUsers);
        }
    
        System.debug('AccountIds Size == '+AccountIds.size());
    
        System.debug('AccountIds == '+AccountIds);
        
        
    
        //Querying against accounts to get all the account details using the accountId list.
        //Changed the query for the Defect#129
        Accounts =[select id,name,Profiled_Account__c,profiled_account_flag__c 
                    from Account 
                    where Id in:AccountIds and Child_Partner_Users_Count__c=1];

        //Checking if the size of the accounts of the newly created users, if equal to zero then return
        //else the next method is called for the account share.
        if(Accounts.size()==0){
            return;
        }
        else
        {
            accountRoleNameMap=getPartnerAccountExecutiveRoles(Accounts);
        }

        //Checking the accountRoleNameMap size which contains the users accountid and its role name. 
        if(accountRoleNameMap.size()>0){
            AccountGroupMap=getPublicGroups(accountRoleNameMap);
        }
        
        //Checking the AccountGroupMap size, if it greater than zero then the
        //account share method is called and sharing is done between accounts.
        if(AccountGroupMap.size()>0){
            createAccountShare();
        }
        
        //Calling disablingPartnerContactsBatch()to Uncheck 'Partner User' checkbox
  		//when partner user is disabled. 												        
        contactSynchronization.disablingPartnerContactsBatch();
        contactsync=true;
    }
    
    /* @Method <This method getAccountsFromUser is used to get the accounts for the 
            newly created users>
@param <It is taking list of newly created users as the parameter>
@return <void> - <List<Id> which contains the account Id's of the respective users.>
@throws exception - <No Exception>
*/
    
    public List<Id> getAccountsFromUser(List<User> lstUsers){
        //Here iterating through the list of users to get the accountId's of the respective users.
        for(User nextUser :lstUsers){
            if(nextUser.contactId!=null){ 
                AccountIds.add(nextUser.contact.AccountId);
            }
        }
        return AccountIds;
    }

/*@Method <This method getPartnerAccountExecutiveRoles is used to get the partner 
            accounts Role name and account id's for the newly created users>.
@param <It is taking list of accounts for the newly created users as the parameter>
@return <void> - <Map<Id,String> which contains the account Id's and Role name for
                    the respective users.>
@throws exception - <No Exception>
*/

    public Map<Id,String> getPartnerAccountExecutiveRoles(List<Account> Accounts){
        //Used to store the non-profiled account Id and its respective profile account Id's.
        Map<Id,Id> nonProfiledAccountMap = new Map<Id,Id>();
        System.debug('Accounts Size == '+Accounts.size());   
        if(Accounts.size()>0){
        System.debug('Accounts '+Accounts); 
        for(Account acc : Accounts){
            //Concatenating account name with "Partner Executive" as this represents the Role name.
            String accountName = acc.name+' Partner Executive';
            accountRoleNameMap.put(acc.id,accountName);
                if(acc.PROFILED_ACCOUNT_FLAG__c!=true){
                    nonProfiledAccountMap.put(acc.Profiled_Account__c,acc.Id);
                }
            }
        }
        System.debug('accountRoleNameMap -->'+accountRoleNameMap);
        System.debug('Non-ProfiledAccountMap -->'+nonProfiledAccountMap);
        return accountRoleNameMap;
    }

/*@Method <This method getPublicGroups is used to get the public group details 
            of the newly created users>.
@param <It is taking map of account id's and role name for the newly created 
            users as the parameter>
@return <void> - <Map<Id,Id> which contains the account Id's and group Id's 
            for the respective users.>
@throws exception - <No Exception>
*/

    public Map<Id,Id> getPublicGroups(Map<Id,String> accountRoleNameMap){
        //Used to store userRole Id's and UserRole record in this map.
        Map<Id,UserRole> UserRoleMap = new Map<Id,UserRole>();

        //Used to store userRole Id's and Userrole portalAccountId.
        Map<Id,Id> UserRoleAccountIdMap = new Map<Id,Id>();
        //User the account id and its related role name, querying against 
        //userRole to get UserRole id's.
        List<UserRole> userRoleList = [Select u.Id,u.name,u.PortalAccountId 
                                        from UserRole u  
                                        where u.PortalAccountId in :accountRoleNameMap.keySet() 
                                        and u.Name in :accountRoleNameMap.values()];
        for(UserRole usrRole: userRoleList){
            UserRoleMap.put(usrRole.Id,usrRole);
            UserRoleAccountIdMap.put(usrRole.Id,usrRole.PortalAccountId);
        }
        System.debug('user role id Map'+userRoleMap);
        System.debug('UserRoleAccountIdMap'+UserRoleAccountIdMap);

        //Here querying to fetch the group Id's by using the UserRole Id's from
        //the map UserRoleAccountIdMap of type RoleAndSubordinates.
        List<Group> groupList = [Select g.Id,g.Type,g.RelatedId from Group g 
                                  where g.RelatedId in :UserRoleAccountIdMap.keySet() 
                                  and g.Type='RoleAndSubordinates'];
        System.debug('Group List'+groupList);

        for(Group grp: groupList){
            AccountGroupMap.put(UserRoleAccountIdMap.get(grp.RelatedId),grp.Id);
        }

        System.debug('AccountGroupMap'+AccountGroupMap);
        return AccountGroupMap;
    }

/*@Method <This method createAccountShare is used to create the account share for 
            the respective accounts based on the association between the accounts>
@param <It is not taking any parameters>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/

    //Querying against the association and creating share for accounts for defect#129
    public void createAccountShare(){
        for(APPR_MTV__RecordAssociation__c associationObj: 
                               [Select a.APPR_MTV__Account__c, a.APPR_MTV__Associated_Account__c,a.Id,APPR_MTV__Account_Role__c 
                                    from APPR_MTV__RecordAssociation__c a
                                    where a.APPR_MTV__Account__c in :AccountIds or
                                     a.APPR_MTV__Associated_Account__c in :AccountIds]){
                                        
            if(AccountGroupMap.get(associationObj.APPR_MTV__Associated_Account__c)!=null){
                      accShareList.add(new AccountShare(
                                    UserOrGroupId=AccountGroupMap.get(associationObj.APPR_MTV__Associated_Account__c),
                                    accountId=associationObj.APPR_MTV__Account__c,
                                    AccountAccessLevel='Read',
                                    OpportunityAccessLevel='None',
                                    CaseAccessLevel='None'));
            }
           //Added for Defect#135
             if(associationObj.APPR_MTV__Account_Role__c=='Profiled Account' && AccountGroupMap.get(associationObj.APPR_MTV__Account__c)!=null){
                      accShareList.add(new AccountShare(
                                    UserOrGroupId=AccountGroupMap.get(associationObj.APPR_MTV__Account__c),
                                    accountId=associationObj.APPR_MTV__Associated_Account__c,
                                    AccountAccessLevel='Read',
                                    OpportunityAccessLevel='None',
                                    CaseAccessLevel='None'));
            }
        }
        System.debug('Before Insert'+accShareList);
        insert accShareList;
        System.debug('After Insert'+accShareList);
   }
    
    /*@Method <This method gets executed acutomatically when the batch job is finised. We are deleting the job at the end.>
@param <Database.BatchableContext BC - Batchable context>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/
    global void finish(Database.BatchableContext BC){
    	
       //calling disabling partner contact method - as every time not getting called from execute
       if(!contactsync){
       	contactSynchronization.disablingPartnerContactsBatch();
       }
       
       system.debug('Batch ' + batchName + ' completed with following details');
       AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems FROM AsyncApexJob where Id =:BC.getJobId()];
       system.debug('Id: ' + a.Id);
       system.debug('Status: '+ a.Status);
       system.debug('Number of Errors: ' + a.NumberOfErrors);
       system.debug('Job Items Processed: ' + a.JobItemsProcessed);
       system.debug('Total Job Items: ' + a.TotalJobItems);
       //Schedule the next batch job to run for 5 minutes later:
       Datetime dt = System.now();
       Integer timeInMin = Integer.valueof(scheduleTime.get('AccountShareSchedularTimeInterval').DataValue__c);
       dt = dt.addMinutes(timeInMin);
       String scheduleString='0';//0 seconds
       scheduleString+=' '+ dt.minute();
       scheduleString+=' '+ dt.hour();
       scheduleString+=' '+ dt.day();
       scheduleString+=' '+ dt.month();
       scheduleString+=' ?';
       scheduleString+=' '+ dt.year();
       String jobName = 'Account Association Batch - ' + dt.format('MM-dd-yyyy-hh:');
  
       PRM_AccountAssignmentScheduler nextBatchJob = new PRM_AccountAssignmentScheduler();
       System.schedule(jobName,scheduleString,nextBatchJob);
    }   
}