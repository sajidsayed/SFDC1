/*=======================================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR          DESCRIPTION                               

 |  ====          =========                ==          =========== 

 |  18 Aug 2011    Arif                    3809        This class will be used to populate Related Account Local Info on corresponding DRs,
                                                        
+=======================================================================================================================================*/
public class PRM_DEALREG_UpdateLocalFieldsOnDR{
    
    public void updateAddressOnDR(Map<Id,Account> mapAccount){
        system.debug('mapAccount--->'+mapAccount);
        List<Lead> lstlead1 = new List<Lead>();        
        Map<Id,List<Lead>> mapAccountLead = new Map<Id,List<Lead>>();
        List<Lead> lstlead = new List<Lead>();
        lstlead1 = [Select Id, Related_Account__c,State_Province_Local__c,Street_Local__c,Zip_Postal_Code_Local__c,
                   DealReg_Address_Local__c,City_Local__c,Country_Local__c,CompanyLocal from Lead where DealReg_Deal_Registration__c = true
                   and Related_Account__c in :mapAccount.keyset()];
        
        system.debug('lstlead --->'+lstlead1);
        for(Lead lead:lstLead1){
            if(mapAccount.containskey(lead.Related_Account__c)){
                mapAccountLead.get(lead.Related_Account__c).add(lead);    
            }
            else {
                mapAccountLead.put(lead.Related_Account__c,lstlead);
                mapAccountLead.get(lead.Related_Account__c).add(lead);   
            }
        } 
        for(Account account: mapAccount.values()){
        //system.debug('mapAccountLead.get(account.Id).size()--->'+mapAccountLead.get(account.Id).size());
            if( mapAccountLead.containskey(account.Id)&& mapAccountLead.get(account.Id).size()>0 ){
                for(Lead lead: mapAccountLead.get(account.Id)){
                    lead.State_Province_Local__c = account.State_Province_Local__c;
                    lead.CompanyLocal = account.NameLocal;
                    lead.City_Local__c = account.City_Local__c;
                    lead.Street_Local__c = account.Street_Local__c;
                    lead.Country_Local__c = account.Country_Local__c;
                    lead.Zip_Postal_Code_Local__c = account.Zip_Postal_Code_Local__c;
                    lead.DealReg_Account_Category__c= account.EMC_Classification__c;
                }
                update mapAccountLead.get(account.Id);
            }
        }                   
    }
/* @Method <This method is used to set the value of Partner type Field for
            accounts whose Record Type has been updated>.
   @param <This method is taking List of updated Account records>   
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void updateAccountType (List<Account> lstAccount){
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getall();
        String recordId='';        
        for(Account acctObj : lstAccount){
            
            recordId=String.ValueOf(acctObj.RecordTypeId).substring(0,15);
            if(DataValueMap.get('Standard Account Record Type').DataValue__c.contains(recordId))
            {
                acctObj.Type = '';
            }
            else
            {
                acctObj.Type = 'Partner';
            }            
        }
    
    }   
}