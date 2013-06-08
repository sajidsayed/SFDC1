/*==========================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER         WR       DESCRIPTION                               

 |  ====          =========         ==       =========== 

 |  18/03/2011     Anil Sure         2517     This trigger gets the last modified date of the Revenue filed
                                             from the valocity revenue related to particuler account and same
                                             will be updated on the Account field called Revenue Refresh Date.
 |============================================================================================================*/

trigger Revenue_TimeStamp on Velocity_Revenue__c (after insert,after update) { 

   
    Map<Id,Velocity_Revenue__c> reveneuAcctMap = new Map<Id,Velocity_Revenue__c>();
    for (Velocity_Revenue__c vel : Trigger.new)
    {        
    reveneuAcctMap.put(vel.Partner_Profiled_Account__c,vel);
    }


 if(reveneuAcctMap.keyset().size()>0){
  List<Account> accountsListToUpdate = [select Revenue_Refresh_Date__c from account where id in:reveneuAcctMap.keyset()];
   for(Account acct:accountsListToUpdate ){
    acct.Revenue_Refresh_Date__c=reveneuAcctMap.get(acct.id).LastModifiedDate;
   }
   update accountsListToUpdate;
  }

    
}