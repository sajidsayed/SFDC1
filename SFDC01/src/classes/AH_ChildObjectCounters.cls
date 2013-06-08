/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |             L Jovanovic            Initial Creation.  Procedures for updating contact counter.               
 |  26-MAY-09  S Douglas              Updated to add procedures for updating lead counter.
 |  20-AUG-09  S Douglas              Updated ProcessContactUpdates to handle contact move from one account to another
 |                                    (change of related_account__c)
 |  23-Sep-10  Saravanan C            Updated ProcessContactUpdates to add the req 1128 (update the '# Partner Users'
 |                                    field in Account when the partner user is being activated or disabled)
 |  29-Sep-10  Saravanan C            updated ProcessContactUpdates to fix Defect 133                   
 | 
 |  09/10/2010 Prasad        --       Added try and catch to catch the future
 |                                    call exception in the method ProcessContactUpdates()
 |  22/12/2010 Anirudh       1789     Updated  code to include check for the Contacts
 |                                    moving from one account to another account.
 |  16-Feb-2011 Saravanan C  1815     Added method - ProcessPartnersforPtnrOrg(Set<String> siteDuns) for updating 
 |                                    the licensed partners for partner org.
 |  31-Mar-2011 Saravanan C  1815     Updated method - ProcessPartnersforPtnrOrg(Set<String> siteDuns) Defect #338
 |
 |  20-May-2011 Saravanan C           Moved the functionaly-Patner Users count to class: PRM_PartnerUsersCount 
 +===========================================================================*/
public class AH_ChildObjectCounters {
    
    // (Kluge) Static flag variable which is used so we know that we are firing the second time
    // as a result of workflow updates (we do not want the trigger code to run a second time
    // since the trigger.old and trigger.new are the same as the first time 
    // which will result in double-counting)
    // The static variable only lives within the context of this transaction so we do not have
    // to worry about re-setting it
    static Boolean processLeadUpdatesHasRun = false;

    // function to receive newly created contact records and update the overall 
    // contact count stored on the related Account records
    public static void ProcessContactInserts(List <Contact> inboundContacts) {
        System.debug('****************************************PROCESS CONTACT INSERT*****************************************');

        // declare local vars
        Set <String> distinctAccountIds = new Set <String>();
        Map <String, Integer> acctIncrementMap = new Map <String, Integer>();
        
        // get the distinct set of accounts, and the associated amount we need to increment
        // the count by
        for (Contact contact : inboundContacts) {
            System.debug('Processing Contact Id: ' + contact.id);
            System.debug('Account Id value: ' + contact.accountId);
            // exclude inactive contacts
            if (contact.Active__c) {
                // exclude contacts not associated to an account 
                if (contact.accountId != null) {
                    System.debug('Account ID was non-null');
                    // if we have already encountered the current account id, we need to increment
                    // the amount the counter needs to be increased by
                    if (distinctAccountIds.contains(contact.accountId)) {
                        System.debug('Duplicate Account Id found, incrementing the current count');
                        Integer currentCount = acctIncrementMap.get(contact.accountId);
                        System.debug('Current Count: ' + currentCount);
                        currentCount += 1;
                        acctIncrementMap.put(contact.accountId,currentCount);
                    } 
                    // else we add it to the set & map
                    else {
                        System.debug('Distinct Account Id found, adding it to the map');
                        distinctAccountIds.add(contact.accountId);
                        acctIncrementMap.put(contact.accountId, 1);
                    }
                    System.debug('New Count: ' + acctIncrementMap.get(contact.accountId));
                }
            }
        }
        // at this point we have a map that contains the ids of the Accounts to be updated 
        // with the appropriate amounts by which the current counts needs to be updated 
        
        // call the contact incrementer to update the associated accounts
        UpdateContactCount(acctIncrementMap);
    }  //ProcessContactInserts
    
    // function to receive newly deleted contact records and update the overall 
    // contact count stored on the related Account records
    public static void ProcessContactDeletes(List <Contact> inboundContacts) {
        System.debug('*****************************************PROCESS CONTACT DELETE****************************************');

        // declare local vars
        Set <String> distinctAccountIds = new Set <String>();
        Map <String, Integer> acctIncrementMap = new Map <String, Integer>();
        
        // get the distinct set of accounts, and the associated amount we need to increment
        // the count by
        for (Contact contact : inboundContacts) {
            System.debug('Processing Contact Id: ' + contact.id);
            System.debug('Account Id value: ' + contact.accountId);
            // exclude inactive contacts
            if (contact.Active__c) {
                // exclude contacts not associated to an account 
                if (contact.accountId != null) {
                    System.debug('Account ID was non-null');
                    // if we have already encountered the current account id, we need to increment
                    // the amount the counter needs to be increased by
                    if (distinctAccountIds.contains(contact.accountId)) {
                        System.debug('Duplicate Account Id found, decrementing the current count');
                        Integer currentCount = acctIncrementMap.get(contact.accountId);
                        System.debug('Current Count: ' + currentCount);
                        currentCount -= 1;
                        acctIncrementMap.put(contact.accountId,currentCount);
                    } 
                    // else we add it to the set & map
                    else {
                        System.debug('Distinct Account Id found, adding it to the map');
                        distinctAccountIds.add(contact.accountId);
                        acctIncrementMap.put(contact.accountId, -1);
                    }
                    System.debug('New Count: ' + acctIncrementMap.get(contact.accountId));
                }
            }
        }
        // at this point we have a map that contains the ids of the Accounts to be updated 
        // with the appropriate amounts by which the current counts needs to be updated 
        
        // call the contact incrementer to update the associated accounts
        UpdateContactCount(acctIncrementMap);
    }  //ProcessContactDeletes
  
    /* @Method <This method is used to receive newly updated contact records and update the overall contact
            count stored on the related Account records if the active status has been changed>
    @param <    List <Contact> inboundNewContacts, List <Contact> inboundOldContacts    >
    @return <void> - <Not Returning anything>
    @throws exception - <DML Exception>
    */
    // function to receive newly updated contact records and update the overall contact  
    // count stored on the related Account records if the active status has been changed
    public static void ProcessContactUpdates(List <Contact> inboundNewContacts, List <Contact> inboundOldContacts) {        
        System.debug('****************************************PROCESS CONTACT UPDATE****************************************');
        
        // declare local vars
        Set <String> distinctAccountIds = new Set <String>();
        Map <String, Integer> acctIncrementMap = new Map <String, Integer>();
       // get the distinct set of accounts, and the associated amount we need to increment
        // the count by
        for (Integer x = 0; x < inboundNewContacts.size(); x++) {
            
            // declare local vars
            Boolean oldStatus = inboundOldContacts[x].Active__c;
            Boolean newStatus = inboundNewContacts[x].Active__c;
            String oldAccount = inboundOldContacts[x].accountId;
            System.Debug('OldACCOUNTvALUE--->'  + inboundOldContacts[x].accountId);
            String newAccount = inboundNewContacts[x].accountId;
            System.Debug('NewACCOUNTvALUE--->'  + inboundNewContacts[x].accountId);
           
            // Update contact counters if either account relationship has changed
            // or if contact status has changed 
            if (oldStatus != newStatus || oldAccount != newAccount) {
                
                if (oldStatus != newStatus && oldAccount == newAccount) {
            
                    // exclude contacts not associated to an account 
                    if (newAccount != null) {
                        System.debug('Account ID was non-null');
                        // if we have already encountered the current account id, we need to increment
                        // the amount the counter needs to be increased by
                        if (distinctAccountIds.contains(newAccount)) {
                            System.debug('Duplicate Account Id found, updating the current count');
                            Integer currentCount = acctIncrementMap.get(newAccount);
                            System.debug('Current Count: ' + currentCount);
                            if (newStatus) {
                                currentCount += 1;
                            } else {
                                currentCount -= 1;  
                            }
                            acctIncrementMap.put(newAccount,currentCount);
                        } 
                        // else we add it to the set & map
                        else {
                            System.debug('Distinct Account Id found, adding it to the map');
                            distinctAccountIds.add(newAccount);
                            if (newStatus) {
                                acctIncrementMap.put(newAccount, 1);
                            } else {
                                acctIncrementMap.put(newAccount, -1);    
                            }
                        }
                        System.debug('New Count: ' + acctIncrementMap.get(newAccount));
                    }
                }

                //If the account association has changed, need to adjust counters on both accounts
                //Note that the status could have changed at the same time
                if (oldAccount != newAccount) {

                    System.debug('Account Association has been changed');
                    //Decrement the count for the old account (unless old status was inactive),
                    //Increment the count for the new account (unless new status is inactive)
                    //
                    if (oldAccount != null && oldStatus) {
                        System.debug('Old Account ID was non-null, Decrementing count');
                        // if we have already encountered the current account id, we need to decrement
                        // the amount the counter needs to be increased by
                        if(distinctAccountIds.contains(oldAccount)) {
                            System.debug('Duplicate Account Id found, updating the current count');
                            Integer currentCount = acctIncrementMap.get(oldAccount);
                            System.debug('Current Count: ' + currentCount);
                            currentCount -= 1;
                            System.debug('New Count: ' + currentCount);
                            acctIncrementMap.put(oldAccount,currentCount);
                        }
                        // else we add it to the set & map
                        else {
                            System.debug('Distinct Account Id found, adding it to the map with count : -1'); 
                            distinctAccountIds.add(oldAccount);
                            acctIncrementMap.put(oldAccount, -1);    
                        }
                    }
                    if (newAccount != null && newStatus) {
                        System.debug('New Account ID is non-null, Incrementing count');
                        // if we have already encountered the current account id, we need to increment
                        // the amount the counter needs to be increased by
                        if(distinctAccountIds.contains(newAccount)) {
                            System.debug('Duplicate Account Id found, updating the current count');
                            Integer currentCount = acctIncrementMap.get(newAccount);
                            System.debug('Current Count: ' + currentCount);
                            currentCount += 1;
                            System.debug('New Count: ' + currentCount);
                            acctIncrementMap.put(newAccount,currentCount);
                        }
                        // else we add it to the set & map
                        else {
                            System.debug('Distinct Account Id found, adding it to the map with count: 1');
                            distinctAccountIds.add(newAccount);
                            acctIncrementMap.put(newAccount, 1);    
                        }
                    }
                }
            
            } //if (contact.accountId != null)
        }
        // at this point we have a map that contains the ids of the Accounts to be updated 
        // with the appropriate amounts by which the current counts needs to be updated 
        
        // call the contact incrementer to update the associated accounts
        UpdateContactCount(acctIncrementMap);       
        
        
       
    }  //ProcessContactUpdates
 
    // This function receives a map of Account Ids and an associated amount that the current 
    // contact count should be incremented by.
    // NOTE:  To make this method an asynchronous method, simply add the '@future' annotation below
    private static void UpdateContactCount(Map <String, Integer> AcctsAndIncrementAmounts) {
        System.debug('****************************************UpdateContactCount*****************************************');
        
        // declare local vars
        List <Account> accountsToUpdate = null;
        Database.SaveResult[] results = null;
        List <EMCException> errors = new List <EMCException>();
        
        // we first need to take the received account ids and retrieve their current counts
        accountsToUpdate = [select Id, Child_Record_Count_Contact__c from Account where Id IN :AcctsAndIncrementAmounts.keySet()];
        System.debug('Query returned ' + accountsToUpdate.size() + ' Account records to update');
        
        // then we update the amounts based on the receive amounts
        for (Account account : AccountsToUpdate) {
            System.debug('Process Account Id: ' + account.Id);
            // declare local var
            Integer count = 0;
            // get a handle on the current count
            if (account.Child_Record_Count_Contact__c != null) {
                count = account.Child_Record_Count_Contact__c.intValue();
            }
            System.debug('Current Contact count: ' + count);
            // increment the count by the appropriate amount
            System.debug('Incrementing the count by: ' + AcctsAndIncrementAmounts.get(account.Id));
            count += AcctsAndIncrementAmounts.get(account.Id);
            // update the record
            account.Child_Record_Count_Contact__c = count;
        }
        
        // now we update the accounts with the new values
        results = database.update(accountsToUpdate);
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
                errors.add(new EMCException(dataErrs, EMC_CONSTANTS.ACCOUNT_HIER_CONTACT_COUNT, new String [] {sr.getId()}));
            }
        }
        
        // log any errors that occurred
        if (errors.size() > 0) { 
            EMC_UTILITY.logErrors(errors);  
        }
    }  //UpdateContactCount
    


    // function to receive newly created lead records and update the overall 
    // Lead count stored on the related Account records
    public static void ProcessLeadInserts(List <Lead> inboundLeads) {
        System.debug('****************************************PROCESS LEAD INSERT****************************************');
            
        // declare local vars
        Set <String> distinctAccountIds = new Set <String>();
        Map <String, Integer> acctIncrementMap = new Map <String, Integer>();
        
        // get the distinct set of accounts, and the associated amount we need to increment
        // the count by
        for (Lead lead : inboundLeads) {
            System.debug('Processing Lead Id: ' + lead.id);
            System.debug('Account Id value: ' + lead.Related_Account__c);
                // exclude leads not associated to an account 
                if (lead.Related_Account__c != null) {
                    System.debug('Account ID was non-null');
                    // if we have already encountered the current account id, we need to increment
                    // the amount the counter needs to be increased by
                    if (distinctAccountIds.contains(lead.Related_Account__c)) {
                        System.debug('Duplicate Account Id found, incrementing the current count');
                        Integer currentCount = acctIncrementMap.get(lead.Related_Account__c);
                        System.debug('Current Count: ' + currentCount);
                        currentCount += 1;
                        acctIncrementMap.put(lead.Related_Account__c,currentCount);
                    } 
                    // else we add it to the set & map
                    else {
                        System.debug('Distinct Account Id found, adding it to the map with count: 1');
                        distinctAccountIds.add(lead.Related_Account__c);
                        acctIncrementMap.put(lead.Related_Account__c, 1);
                    }
                    System.debug('New Count: ' + acctIncrementMap.get(lead.Related_Account__c));
                }

        }
        // at this point we have a map that contains the ids of the Accounts to be updated 
        // with the appropriate amounts by which the current counts needs to be updated 
        
        // call the contact incrementer to update the associated accounts
        UpdateLeadCount(acctIncrementMap);
        
    }  //ProcessLeadInserts

    // function to receive newly deleted lead records and update the overall 
    // lead count stored on the related Account records
    public static void ProcessLeadDeletes(List <Lead> inboundLeads) {
        System.debug('****************************************PROCESS LEAD DELETE****************************************');
            
        // declare local vars
        Set <String> distinctAccountIds = new Set <String>();
        Map <String, Integer> acctIncrementMap = new Map <String, Integer>();
        
        // get the distinct set of accounts, and the associated amount we need to increment
        // the count by
        for (Lead lead : inboundLeads) {
            System.debug('Processing Lead Id: ' + lead.id);
            System.debug('Account Id value: ' + lead.Related_Account__c);
                // exclude leads not associated to an account 
                if (lead.Related_Account__c != null) {
                    System.debug('Account ID was non-null');
                    // if we have already encountered the current account id, we need to increment
                    // the amount the counter needs to be increased by
                    if (distinctAccountIds.contains(lead.Related_Account__c)) {
                        System.debug('Duplicate Account Id found, decrementing the current count');
                        Integer currentCount = acctIncrementMap.get(lead.Related_Account__c);
                        System.debug('Current Count: ' + currentCount);
                        currentCount -= 1;
                        acctIncrementMap.put(lead.Related_Account__c,currentCount);
                    } 
                    // else we add it to the set & map
                    else {
                        System.debug('Distinct Account Id found, adding it to the map with count: -1');
                        distinctAccountIds.add(lead.Related_Account__c);
                        acctIncrementMap.put(lead.Related_Account__c, -1);
                    }
                    System.debug('New Count: ' + acctIncrementMap.get(lead.Related_Account__c));
                }
        }
        // at this point we have a map that contains the ids of the Accounts to be updated 
        // with the appropriate amounts by which the current counts needs to be updated 
        
        // call the lead incrementer to update the associated accounts
        UpdateLeadCount(acctIncrementMap);
    
    }  //ProcessLeadDeletes

    // function to receive newly updated lead records and update the overall lead  
    // count stored on the related Account records if the active status has been changed
    public static void ProcessLeadUpdates(List <Lead> inboundNewLeads, List <Lead> inboundOldLeads) {
        System.debug('****************************************PROCESS LEAD UPDATE****************************************');
        if (!processLeadUpdatesHasRun)
        {
            System.debug('processLeadUpdatesHasRun is FALSE');
            processLeadUpdatesHasRun = true;
            
            // declare local vars
            Set <String> distinctAccountIds = new Set <String>();
            Map <String, Integer> acctIncrementMap = new Map <String, Integer>();
            
            // get the distinct set of accounts, and the associated amount we need to increment
            // the count by
            for (Integer x = 0; x < inboundNewLeads.size(); x++) {
                
                // declare local vars
                Lead lead = inboundNewLeads[x];
                String oldAccount = inboundOldLeads[x].Related_Account__c;
                String newAccount = inboundNewLeads[x].Related_Account__c;
                
                System.debug('Old Account ID: ' + oldAccount);
                System.debug('New Account ID: ' + newAccount);
                
                if (oldAccount != newAccount) {
                    System.debug('Account Association has been changed');
                    //New Account association has been made
                    //Decrement the count for the old account, Increment the count for the new account
                    if (oldAccount != null) {
                        System.debug('Old Account ID was non-null, Decrementing count');
                        // if we have already encountered the current account id, we need to decrement
                        // the amount the counter needs to be increased by
                        if(distinctAccountIds.contains(oldAccount)) {
                            System.debug('Duplicate Account Id found, updating the current count');
                            Integer currentCount = acctIncrementMap.get(oldAccount);
                            System.debug('Current Count: ' + currentCount);
                            currentCount -= 1;
                            System.debug('New Count: ' + currentCount);
                            acctIncrementMap.put(oldAccount,currentCount);
                        }
                        // else we add it to the set & map
                        else {
                            System.debug('Distinct Account Id found, adding it to the map with count : -1'); 
                            distinctAccountIds.add(oldAccount);
                            acctIncrementMap.put(oldAccount, -1);    
                        }
                    }
                    if (newAccount != null) {
                        System.debug('New Account ID is non-null, Incrementing count');
                        // if we have already encountered the current account id, we need to increment
                        // the amount the counter needs to be increased by
                        if(distinctAccountIds.contains(newAccount)) {
                            System.debug('Duplicate Account Id found, updating the current count');
                            Integer currentCount = acctIncrementMap.get(newAccount);
                            System.debug('Current Count: ' + currentCount);
                            currentCount += 1;
                            System.debug('New Count: ' + currentCount);
                            acctIncrementMap.put(newAccount,currentCount);
                        }
                        // else we add it to the set & map
                        else {
                            System.debug('Distinct Account Id found, adding it to the map with count: 1');
                            distinctAccountIds.add(newAccount);
                            acctIncrementMap.put(newAccount, 1);    
                        }
                    }
                
                }
            }
            // at this point we have a map that contains the ids of the Accounts to be updated 
            // with the appropriate amounts by which the current counts needs to be updated 
            
            // call the lead incrementer to update the associated accounts
            UpdateLeadCount(acctIncrementMap);
            
        }  //if (!processLeadUpdatesHasRun)
    }  //ProcessLeadUpdates      

    // This function receives a map of Account Ids and an associated amount that the current 
    // lead count should be incremented by.
    // NOTE:  To make this method an asynchronous method, simply add the '@future' annotation below
    private static void UpdateLeadCount(Map <String, Integer> AcctsAndIncrementAmounts) {
        System.debug('****************************************UpdateLeadCount*********************************');
        
        // declare local vars
        List <Account> accountsToUpdate = null;
        Database.SaveResult[] results = null;
        List <EMCException> errors = new List <EMCException>();
        
        // we first need to take the received account ids and retrieve their current counts
        accountsToUpdate = [select Id, Child_Record_Count_Lead__c from Account where Id IN :AcctsAndIncrementAmounts.keySet()];
        System.debug('Query returned ' + accountsToUpdate.size() + ' Account records to update');
        
        // then we update the amounts based on the receive amounts
        for (Account account : AccountsToUpdate) {
            System.debug('Process Account Id: ' + account.Id);
            // declare local var
            Integer count = 0;
            // get a handle on the current count
            if (account.Child_Record_Count_Lead__c != null) {
                count = account.Child_Record_Count_Lead__c.intValue();
            }
            System.debug('Current Lead count: ' + count);
            // increment the count by the appropriate amount
            System.debug('Incrementing the count by: ' + AcctsAndIncrementAmounts.get(account.Id));
            count += AcctsAndIncrementAmounts.get(account.Id);
            // update the record
            account.Child_Record_Count_Lead__c = count;
        }
        
        // now we update the accounts with the new values
        results = database.update(accountsToUpdate);
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
                errors.add(new EMCException(dataErrs, EMC_CONSTANTS.ACCOUNT_HIER_LEAD_COUNT, new String [] {sr.getId()}));
            }
        }
        
        // log any errors that occurred
        if (errors.size() > 0) { 
            EMC_UTILITY.logErrors(errors);  
        }
    }  //UpdateLeadCount 
     
    // Method used by the unit test code which will reset the HasRun flags
    // since test code must do inserts before testing updates
    public static void resetFlagsForUnitTest() {
        System.debug('****************************************resetFlagsForUnitTest*********************************');
        processLeadUpdatesHasRun = false;
    }  //resetFlagsForTest
}