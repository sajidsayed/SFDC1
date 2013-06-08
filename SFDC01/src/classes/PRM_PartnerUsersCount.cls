/*============================================================================================+
 |  HISTORY      
 |                          
 |  DATE       DEVELOPER      REQ/WR   DESCRIPTION                               
 |  ====       =========     ========  =========== 
 |  25-May-11  Saravanan C   REQ-2879  Initial creation
 |     
 +==========================================================================================*/

public class PRM_PartnerUsersCount {

  public static void ProcessContactInserts(List <Contact> inboundContacts) {
  System.debug('************ PROCESS PARTNER USER COUNT INSERT ************');
   Map <String, Integer> acctIncrementMap = new Map <String, Integer>();
   
    for (Contact contact : inboundContacts) {
      if (contact.Partner_User2__c) {
         if (contact.accountId != null) {
           acctIncrementMap.put(contact.accountId,1);
         }
      }
    }
    System.debug(' acctIncrementMap :: ' + acctIncrementMap);
    // COUNT ITERATION & Update Accounts
    UpdateAccounts(CountIteration(acctIncrementMap));
    // DONE
  }
  
  public static void ProcessContactUpdates(List <Contact> inboundNewContacts, List <Contact> inboundOldContacts) {       
   System.debug('************ PROCESS PARTNER USER COUNT UPDATE ************');
   // declare local vars
   Map <String, Integer> acctIncrementMap = new Map <String, Integer>();
   Map <String, Decimal> OrgTotalCount = new Map <String, Decimal>();
   Map <String, String> ProfiledAccount = new Map <String, String>();
  
    for (Integer x = 0; x < inboundNewContacts.size(); x++) {
       // declare local vars
        Boolean oldStatus = inboundOldContacts[x].Partner_User2__c;
        Boolean newStatus = inboundNewContacts[x].Partner_User2__c;
        String oldAccount = inboundOldContacts[x].accountId;
        String newAccount = inboundNewContacts[x].accountId;
        
      // Update contact counters if either account relationship has changed
      // or if contact status has changed 
      if (oldStatus != newStatus || oldAccount != newAccount) {
      
        if (oldStatus != newStatus && oldAccount == newAccount) {
        
          if (newAccount != null) { 
           
             if ( newStatus ) {
                acctIncrementMap.put(newAccount, 1); 
             }  else {
                acctIncrementMap.put(newAccount, -1);             
             }

          }
        
        } 
             
      }
      
      if (oldAccount != newAccount) {
      
        if (oldAccount != null && oldStatus) {
           acctIncrementMap.put(oldAccount, -1);    
        } 
        
        if (newAccount != null && newStatus) {
           acctIncrementMap.put(newAccount, 1);
        }
    
      }
      
   }
   System.debug(' acctIncrementMap :: ' + acctIncrementMap);
    // COUNT ITERATION & Update Accounts
    UpdateAccounts(CountIteration(acctIncrementMap));
    // DONE
  }
  
  public static void ProcessContactDeletes(List <Contact> inboundContacts) {
  System.debug('************ PROCESS PARTNER USER COUNT INSERT ************');
   Map <String, Integer> acctIncrementMap = new Map <String, Integer>();
   
    for (Contact contact : inboundContacts) {
      if (contact.Partner_User2__c) {
         if (contact.accountId != null) {
           acctIncrementMap.put(contact.accountId,-1);
         }
      }
    }
    System.debug(' acctIncrementMap :: ' + acctIncrementMap);
    // COUNT ITERATION & Update Accounts
    UpdateAccounts(CountIteration(acctIncrementMap));
    // DONE
  }
  
  public static List<Account> CountIteration(Map <String, Integer> acctIncrementMap){
   System.debug('************ PROCESS COUNT ITERATION ************');
   // declare local vars
  // Set <String> distinctAccountIds = new Set <String>();
   Map <String, Decimal> OrgTotalCount = new Map <String, Decimal>();
   Map <String, String> ProfiledAccount = new Map <String, String>();
  
   System.debug(' acctIncrementMap :: ' + acctIncrementMap);
   // Find the Grouped Accounts
   List <Account> groupedAccounts = null;
    groupedAccounts = [select Id, Grouping__c, Grouping__r.Id, PROFILED_ACCOUNT_FLAG__c, 
                               Profiled_Account__c 
                       from Account where Id IN :acctIncrementMap.keySet()];
    
   Set <String> groupingId = new Set <String>();
    
    for ( Account a : groupedAccounts ) {
     if( a.Grouping__r.Id != null ) {
       groupingId.add(a.Grouping__r.Id);
     }  
    }         
    
    List <Account> accounts2Update = new List <Account> (); 
    
    if ( groupingId.size() >0 ){
              
    Map<String,Account> AllGroupedAccs = New Map<String,Account> ([SELECT Site_DUNS_Entity__c, PROFILED_ACCOUNT_FLAG__c,
                                                                             Child_Partner_Users_Count__c,Grouping__c,
                                                                             Licensed_Partners_for_a_Partner_Org__c ,Grouping__r.Id,
                                                                   (SELECT Id,Partner_User2__c FROM contacts)
                                                                   FROM Account 
                                                                   WHERE Grouping__c in: groupingId]);   
                    System.Debug('AllGroupedAccsbyAnirudh-->' + AllGroupedAccs);                                                      
       
      for ( String grpId : groupingId) {
         Decimal PartnerUsersforGroup = 0; 
         for ( Account acc: AllGroupedAccs.Values() ) {  
            if ( acc.PROFILED_ACCOUNT_FLAG__c ){
               ProfiledAccount.put(grpId,acc.id); 
            }
            if ( grpId == acc.Grouping__r.Id ) { 
                Integer PartnerUsersforAcc = 0;
               for ( Contact cont : acc.contacts) {
                  PartnerUsersforAcc = cont.Partner_User2__c ? PartnerUsersforAcc +1: PartnerUsersforAcc;
               }
               
               acc.Child_Partner_Users_Count__c = PartnerUsersforAcc ;
               PartnerUsersforGroup += PartnerUsersforAcc ;
               if ( acc.Child_Partner_Users_Count__c == null ) {
                  acc.Child_Partner_Users_Count__c = 0;
               }
                accounts2Update.add(acc); 
              // add only the associate account to update 
               /*if ( acctIncrementMap.get(acc.id) != null ) {
                  accounts2Update.add(acc); 
               }  */ 
            }   
            System.debug(' acc :: ' + acc );
         }
       OrgTotalCount.put(grpId,PartnerUsersforGroup);  
      }
                                                                     
    }        
    
    System.debug(' OrgTotalCount :: ' + OrgTotalCount );
    System.debug(' accounts2Update :: ' + accounts2Update);
    
    
    for ( String grpId : groupingId) { 
     for ( Account acc: accounts2Update ) {
      if ( grpId == acc.Grouping__r.Id ) {
        if ( ProfiledAccount.get(grpId) != null ){
        // add only the profiled account to update
           acc.Licensed_Partners_for_a_Partner_Org__c = OrgTotalCount.get(grpId);
           System.Debug('Licensed_Partners_for_a_Partner_Org__c-->' +acc.Licensed_Partners_for_a_Partner_Org__c);
        }
      }
     }
    }                                                       
   
   
   return (accounts2Update);
   
  }

  private static void UpdateAccounts(List <Account> accounts2Update) {
    System.debug('accounts2Update :: ' + accounts2Update);
        // declare local vars
        Database.SaveResult[] results = null;
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
            }
        }
        
    }  //UpdateAccounts
}