/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |             L Jovanovic            Initial Creation.  Procedures for updating profile indicator on account.               
 |  01-JUN-09  S Douglas              Updated to add procedures for updating account plan indicator on account.
 |                                    (Commented out as they do not go live until August)
 |                                 
 +===========================================================================*/
public class AH_ChildObjectPresenceIndicators {

    // function to receive newly created profile records and update the overall 
    // presence indicator stored on the related Account records
    public static void ProcessProfileCustomInserts(List <ProfileCustom__c> inboundProfiles) {
        
        // declare local vars
        List <Account> accounts2Update = new List <Account>(); 
        Set <String> distinctAcctIds2Process = new Set <String>();
        
        // loop through the new profiles and pull those that are associated to an account out
        for (ProfileCustom__c profile : inboundProfiles) {
            System.debug('Process ProfileCustom__c: ' + profile.Id);
            if (profile.Account_del__c != null) {
                System.debug('Related Account Found: ' + profile.Account_del__c);
                if (!distinctAcctIds2Process.contains(profile.Account_del__c)) {
                    System.debug('New Account found, adding it to the update stack...');
                    distinctAcctIds2Process.add(profile.Account_del__c);
                    accounts2Update.add(new Account(id = profile.Account_del__c, Child_Record_Presence_Profile__c = true)); 
                }
            }
        }
        // at this point we have a list that contains the Accounts that need to be 
        // updated to indicate the presence of a profile 
        
        // call the update routine to update the associated accounts' presence indicators
        UpdateProfilePresence(accounts2Update);
    }  //ProcessProfileCustomInserts
    
    
    // function to receive newly updated profile records and update the overall 
    // presence indicator stored on the related Account records
    public static void ProcessProfileCustomUpdates(List <ProfileCustom__c> inboundNewProfiles, List <ProfileCustom__c> inboundOldProfiles) {
        
        // delcare local vars
        Set <String> accountsToAddPresence = new Set <String>();
        Set <String> accountsToRemovePresence = new Set <String>();
        Set <String> accountsToCheckPresence = new Set <String>();
        List <ProfileCustom__c> profilesOnAccounts = null; 
        List <Account> accounts2Update = new List <Account>();
        
        System.debug('Looking through Profile updates to find account assignment changes...');
        
        // loop through and look for change in ownership to impact presence
        for (Integer x = 0; x < inboundNewProfiles.size(); x++) {
            // get handles on the new and old account ids
            String newAccountId = inboundNewProfiles[x].Account_del__c;
            String oldAccountId = inboundOldProfiles[x].Account_del__c;
            
            // if they are different, add the new account id to have presence set
            // capture the old account for a presence check
            if (newAccountId != oldAccountId ) {
                System.debug('Located an account assignment change.  Profile Id: ' + 
                inboundNewProfiles[x].Id + ', Old Account Id: ' + oldAccountId + ', New Account Id: ' + 
                newAccountId);
                
                if (!accountsToAddPresence.contains(newAccountId) && newAccountId!=null ) {
                    accountsToAddPresence.add(newAccountId);
                }
                if (!accountsToRemovePresence.contains(oldAccountId) && oldAccountId!=null ) {
                    accountsToCheckPresence.add(oldAccountId);
                }
            }
        }
        
        System.debug('Comparing add & remove lists to handle duplicates...');
        // to further pair down the list of accounts we need to check, we remove any that are in our 
        // list of accounts to add presence to
        for (String acctId : accountsToCheckPresence) {
            if (!accountsToAddPresence.contains(acctId)) {
                accountsToRemovePresence.add(acctId);
            }
        }
        System.debug('After compare there remain ' + accountsToRemovePresence.size() + ' accounts to check');
        
        System.debug('Querying for existing profiles...');
        // query to see if any profiles exist on the accounts to check presence
        System.debug(' accountsToRemovePresence '+accountsToRemovePresence.size());
        if(accountsToRemovePresence.size()>0){
        for (List<ProfileCustom__c> profileList : 
            [select Id, Account_del__c from ProfileCustom__c where Account_del__c in :accountsToRemovePresence]) {
        for(ProfileCustom__c profile:profileList)
            // if a profile exists we remove the account so the presence is not wiped
            accountsToRemovePresence.remove(profile.Account_del__c);
        }
        System.debug('After query there remain ' + accountsToRemovePresence.size() + ' accounts to remove presence from');
        System.debug('Adding presence to ' + accountsToAddPresence.size() + ' accounts');
       } 
        // at this point we have a set of ids to add presence and a set to remove presence from
        // we combine these updates into a single collection and call the update method
        for (String acctId : accountsToAddPresence) {
            accounts2Update.add(new Account(Id = acctId, Child_Record_Presence_Profile__c = true));
        }
        for (String acctId : accountsToRemovePresence) {
            accounts2Update.add(new Account(Id = acctId, Child_Record_Presence_Profile__c = false));
        }
        
        // call the update routine to update the associated accounts' presence indicators
        UpdateProfilePresence(accounts2Update);
    }  //ProcessProfileCustomUpdates
    
    
    // This function receives a list of Accounts and an associated profile presence indicator 
    // NOTE:  To make this method an asynchronous method, simply add the '@future' annotation below
    private static void UpdateProfilePresence(List <Account> accounts2Update) {
    
        // declare local vars
        Database.SaveResult[] results = null;
        List <EMCException> errors = new List <EMCException>();
        
        // now we update the accounts with the new values
        results = database.update(accounts2Update);
        // look for any errors
        String dataErrs = '';
        for (Database.Saveresult sr : results) {
            if (!sr.isSuccess()) {
                // if the particular record did not get updated, we log the data error 
                for (Database.Error err : sr.getErrors()) {
                    dataErrs += err.getMessage();
                }
                System.debug('An exception occurred while attempting an update on ' + sr.getId());
                System.debug('ERROR: ' + dataErrs);
                errors.add(new EMCException(dataErrs, EMC_CONSTANTS.ACCOUNT_HIER_PROFILE_PRESENCE_IND, new String [] {sr.getId()}));
            }
        }
        
        // log any errors that occurred
        if (errors.size() > 0) { 
            EMC_UTILITY.logErrors(errors); 
        }
    }  //UpdateProfilePresence

   ///****************************Code updated By Shipra Misra*****************************//
 // function to update the Profile exist checkbox in account to determine whether Profile exist or not.
   
public static void ProcessProfileCustomDelete(List <ProfileCustom__c> inboundOldProfiles){



    // declare local vars
     Set<Id> acctIds = new Set<Id>();
     List <Account> Account2Count = new List <Account> ();
    
     for (ProfileCustom__c profile : inboundOldProfiles) 
     {
         if(!acctIds.contains(profile.Account_del__c))
             acctIds.add(profile.Account_del__c);
     }
     //Selecting Account Id which need's to be updated for child_Record_presence_profile__c field to be set "TRUE" or "FALSE".
     List<ProfileCustom__c> prList = [select Id, Account_del__c from ProfileCustom__c where Account_del__c in :acctIds];
    for (Id acId : acctIds)
    {
        Boolean acctFound = false;
        for(ProfileCustom__c pr: prList)
        {
            if(pr.Account_del__c == acId)
            {
                acctFound = true;
               
                break;
            }
        }
        if(acctFound == false)
        {
    // Updating the profile exist checkbox (child_Record_presence_profile__c) for the related Account records
               Account2Count.add(new Account(id = acId,child_Record_presence_profile__c=false));
        }
    }

    if(Account2Count.size() > 0)
    // Updating the related Account records for the profile exist checkbox
    //call the update routine to update the associated accounts' Profile exist checkbox(child_Record_presence_profile__c).
       
               UpdateProfilePresence(Account2Count);
}   //ProcessProfileCustomDelete



/////////******************************undelete***************************//
// function update the profile exist checkbox in the Account page for the profile which have been undeleted from Recycle bin.
    
 public static void ProcessProfileCustomUnDelete(List <ProfileCustom__c> inboundProfiles) {
        
        // declare local vars
        List <Account> accounts2Update = new List <Account>(); 
        Set <String> distinctAcctIds2Process = new Set <String>();
        
        // loop through the new profiles and pull those that are associated to an account out
        for (ProfileCustom__c profile : inboundProfiles) {
            System.debug('Process ProfileCustom__c: ' + profile.Id);
            if (profile.Account_del__c != null) {
                System.debug('Related Account for Profile Found: ' + profile.Account_del__c);
                if (!distinctAcctIds2Process.contains(profile.Account_del__c)) {
                    System.debug('Undeleted profile for Account found, adding it to the update stack...');
                    distinctAcctIds2Process.add(profile.Account_del__c);
                    accounts2Update.add(new Account(id = profile.Account_del__c, Child_Record_Presence_Profile__c = true)); 
                }
            }
        }
        // at this point we have a list that contains the Accounts that need to be 
        // updated to indicate the presence of a profile 
        
        // call the update routine to update the associated accounts' presence indicators
        UpdateProfilePresence(accounts2Update);
    }  //ProcessProfileCustomUndeletes
    
    

   ///****************************End of Code Udation By shipra****************************// 

    
/*
    // function to receive newly created account plan records and updates the overall 
    // presence indicator stored on the related Account records
    public static void ProcessAccountPlanInserts(List <SFDC_Acct_Plan__c> inboundAcctPlans) {
        System.debug('*****************************************PROCESS ACCOUNT PLAN INSERT****************************************');
        
        // declare local vars
        List <Account> accounts2Update = new List <Account>(); 
        Set <String> distinctAcctIds2Process = new Set <String>();
        
        // loop through the new account plans and pull those that are associated to an account out
        for (SFDC_Acct_Plan__c plan : inboundAcctPlans) {
            System.debug('Process SFDC_Acct_Plan__c: ' + plan.Id);
            if (plan.Account__c != null) {
                System.debug('Related Account Found: ' + plan.Account__c);
                if (!distinctAcctIds2Process.contains(plan.Account__c)) {
                    System.debug('New Account found, adding it to the update stack...');
                    distinctAcctIds2Process.add(plan.Account__c);
                    accounts2Update.add(new Account(id = plan.Account__c, Child_Record_Presence_AccountPlan__c = true));    
                }
            }
        }
        // at this point we have a list that contains the Accounts that need to be 
        // updated to indicate the presence of a profile 
        
        // call the update routine to update the associated accounts' presence indicators
        UpdateAccountPlanPresence(accounts2Update);
    }  //ProcessAccountPlanInserts
    
    
    // NOT REQUIRED as account assocation should not be updated for account plans?
    // function to receive newly updated account plan records and update the overall 
    // presence indicator stored on the related Account records
    public static void ProcessAccountPlanUpdates(List <SFDC_Acct_Plan__c> inboundNewAcctPlans, List <SFDC_Acct_Plan__c> inboundOldAcctPlans) {
        System.debug('****************************************PROCESS ACCOUNT PLAN UPDATES****************************************');
        
        // delcare local vars
        Set <String> accountsToAddPresence = new Set <String>();
        Set <String> accountsToRemovePresence = new Set <String>();
        Set <String> accountsToCheckPresence = new Set <String>();
        List <Account> accounts2Update = new List <Account>();
        
        System.debug('Looking through account updates to find account assignment changes...');
        
        // loop through and look for change in ownership to impact presence
        for (Integer x = 0; x < inboundNewAcctPlans.size(); x++) {
            // get handles on the new and old account ids
            String newAccountId = inboundNewAcctPlans[x].Account__c;
            String oldAccountId = inboundOldAcctPlans[x].Account__c;
            
            // if they are different, add the new account id to have presence set
            // capture the old account for a presence check
            if (newAccountId != oldAccountId) {
                System.debug('Located an account assignment change.  Profile Id: ' + 
                inboundNewAcctPlans[x].Id + ', Old Account Id: ' + oldAccountId + ', New Account Id: ' + 
                newAccountId);
                
                if (!accountsToAddPresence.contains(newAccountId)) {
                    accountsToAddPresence.add(newAccountId);
                }
                if (!accountsToRemovePresence.contains(oldAccountId)) {
                    accountsToCheckPresence.add(oldAccountId);
                }
            }
        }
        
        System.debug('Comparing add & remove lists to handle duplicates...');
        // to further pair down the list of accounts we need to check, we remove any that are in our 
        // list of accounts to add presence to
        for (String acctId : accountsToCheckPresence) {
            if (!accountsToAddPresence.contains(acctId)) {
                accountsToRemovePresence.add(acctId);
            }
        }
        System.debug('After compare there remain ' + accountsToRemovePresence.size() + ' accounts to check');
        
        System.debug('Querying for existing account plans...');
        // query to see if any account plans exist on the accounts to check presence
        for (SFDC_Acct_Plan__c plan : 
            [select Id, Account__c from SFDC_Acct_Plan__c where Account__c in :accountsToRemovePresence]) {
        
            // if an account plan exists we remove the account so the presence is not wiped
            accountsToRemovePresence.remove(plan.Account__c);
        }
        System.debug('After query there remain ' + accountsToRemovePresence.size() + ' accounts to remove presence from');
        System.debug('Adding presence to ' + accountsToAddPresence.size() + ' accounts');
        
        // at this point we have a set of ids to add presence and a set to remove presence from
        // we combine these updates into a single collection and call the update method
        for (String acctId : accountsToAddPresence) {
            accounts2Update.add(new Account(Id = acctId, Child_Record_Presence_AccountPlan__c = true));
        }
        for (String acctId : accountsToRemovePresence) {
            accounts2Update.add(new Account(Id = acctId, Child_Record_Presence_AccountPlan__c = false));
        }
        
        // call the update routine to update the associated accounts' presence indicators
        UpdateAccountPlanPresence(accounts2Update);
    }  //ProcessAccountPlanUpdates

    
    // This function receives a list of Accounts and an associated account plan presence indicator 
    // NOTE:  To make this method an asynchronous method, simply add the '@future' annotation below
    private static void UpdateAccountPlanPresence(List <Account> accounts2Update) {
        System.debug('****************************************UpdateAccountPlanPresence****************************************');
    
        // declare local vars
        Database.SaveResult[] results = null;
        List <EMCException> errors = new List <EMCException>();
        
        // now we update the accounts with the new values
        results = database.update(accounts2Update);
        // look for any errors
        String dataErrs = '';
        for (Database.Saveresult sr : results) {
            if (!sr.isSuccess()) {
                // if the particular record did not get updated, we log the data error 
                for (Database.Error err : sr.getErrors()) {
                    dataErrs += err.getMessage();
                }
                System.debug('An exception occurred while attempting an update on ' + sr.getId());
                System.debug('ERROR: ' + dataErrs);
                errors.add(new EMCException(dataErrs, EMC_CONSTANTS.ACCOUNT_HIER_ACCT_PLAN_PRESENCE_IND, new String [] {sr.getId()}));
            }
        }
        
        // log any errors that occurred
        if (errors.size() > 0) { 
            EMC_UTILITY.logErrors(errors); 
        }
    }  //UpdateAccountPlanPresence
*/    
    
}