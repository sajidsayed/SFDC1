/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  3/12/2010        Arif      Req#1477    This method is used to create a location with the 
                                           name of the Profiled Account when the Profiled
                                           Account site is "Published".                                          
 +==================================================================================================================**/

public class PRM_PartnerFinderLocation{

    /* @Method <checkPartnerFinder(): This method is used to create a list of account Id 
                                      if the new value of Profiled Account Flag is 'True'
                                      and old value is 'False'>
       @param - <This method will take Trigger.NewMap and Trigger.OldMap as arguments>
       @return <void> - <returning nothing>
       @throws exception - <No Exception>
    */
    Static Integer index = 0;
    public void createListOfAccountId(Map<Id,Account> mapTriggerNew,Map<Id,Account> mapTriggerOld){
        System.Debug('Index--->' +index++);
        List<Id> lstaccountId = new List<Id>(); 
        if(index==1){
            for(Id obj:mapTriggerNew.keyset()){
                System.Debug('Trigger.NewValue--->' +maptriggernew.get(obj).Profiled_Account_Flag__c);
                System.Debug('Trigger.OldValue--->' +maptriggerold.get(obj).Profiled_Account_Flag__c);
                if( mapTriggerNew.get(obj).PROFILED_ACCOUNT_FLAG__c && 
                    mapTriggerOld.get(obj).PROFILED_ACCOUNT_FLAG__c==False ){
                     lstaccountId.add(obj);
                }
            }
         
            if(lstaccountId.size()>0){
                createPartnerLocation(lstaccountId);
            }
        }    
    }                  
    /* @Method <createPartnerLocation(): This method is used to create a location with the 
                                         name of the Profiled Account when the Profiled
                                         Account site is "Published".>
       @param - <This method will take List of Profiled Accounts as arguments>
       @return <void> - <returning nothing>
       @throws exception - <No Exception>
    */
    public void createPartnerLocation(List<Id> profiledAccountsId){
        List<Partner_Location__c> partnerLocationsList = new List<Partner_Location__c>();
        List<Account> lstprofiledAccountNew = [Select a.BillingCity, a.BillingCountry, 
                                               a.BillingPostalCode, a.BillingState, 
                                               a.BillingStreet,a.Grouping__c, 
                                               a.Grouping__r.Name, a.Id, a.Website 
                                               from Account a where a.Id in:profiledAccountsId];
                                                  
        for(Account profiledAccount :lstprofiledAccountNew){
            Partner_Location__c partnerLocation = new Partner_Location__c(
                                                       Name = profiledAccount.Grouping__r.Name,
                                                       Account__c = profiledAccount.Id,
                                                       City__c = profiledAccount.BillingCity,
                                                       Country__c = profiledAccount.BillingCountry,
                                                       Is_Primary__c = True,
                                                       Postal_Code__c = profiledAccount.BillingPostalCode,
                                                       State_Province__c = profiledAccount.BillingState,
                                                       Street__c = profiledAccount.BillingStreet,
                                                       Website__c = profiledAccount.Website);
            partnerLocationsList.add(partnerLocation);                                         
        }
        
        Insert partnerLocationsList;
    }
}