/*=====================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER           WR          DESCRIPTION                               
 |  ====            =========           ==          =========== 
 |  07.01.2013      Smitha Thomas       213868      Initial Creation.  Checks if the new selected CQR is in the Account related List, belongs
                                                    another District (if yes updates Account's District Lookup) and blanks out the 
                                                    Core Quota House Name field if the previous CQR was a House Account.
    18 Mar 2013     Avinash Kaltari     239205      Modified the code to 
                                                    (a) Check whether the ID of Account and CQR record match before updating 
                                                    the District Lookup on Account
                                                    (b) Ignore the equality of Account's Core_Quota_Rep__c field and Core Quota Rep's
                                                    SFDC_User_ID__c when the new Core Quota Rep on Account is a House Account (however, the 
                                                    Core Quota Rep's Bagde ID must begin with 'D')
 +=====================================================================================================================*/

public class AP_AccountBeforeUpdate 
{
    public static boolean blnBeforeUpdateCode = false;    

    public static void updateCoreQuotaRep(Map<Id,Account> mapTriggerNew, Map<Id,Account> mapTriggerOld) 
    {
        if(blnBeforeUpdateCode == false)
        {
            blnBeforeUpdateCode = true;  
            //Set<Id> setHouseAccount = new Set<Id>();
            Set<Id> setBatchAdmin = new Set<Id>();          
            List<Account> lstAcctoUpdate = new List<Account>();     
            Set<Id> setCQRUserId = new Set<Id>();
            Id houseAccUser;    
            List<Core_Quota_Rep__c> lstCQR = new List<Core_Quota_Rep__c>();
            Set<string> setOracleDistrictIds = new Set<String>();   
            List<District_Lookup__c> lstDLookup = new List<District_Lookup__c>();                           
            Map<String, District_Lookup__c> mapDistrictIdDLookup = new Map<String,District_Lookup__c>();
            
            /*Map<Id,User> mapIdUser = new Map<Id, User>([Select Id, Name From User WHERE name like '%System Integration%' OR name like '%Integration%'OR name like '%Batch Admin%' limit 50000]);*/

// The following query retrieves the House Account Users
            Map<Id,User> mapIdHouseUser = new Map<Id, User>([Select Id, Name From User WHERE name like '%House Account%' limit 50000]);
// system.debug('#### MAP House Users : '+mapIdHouseUser);            

            Set<Id> setHouseUserId = new Set<iD>();

            if(mapIdHouseUser != null && mapIdHouseUser.values() != null)
                setHouseUserId.addAll(mapIdHouseUser.keyset());
// system.debug('#### SET HOuse User Ids:'+setHouseUserId);


            /*for (User u : mapIdUser.values()) 
            {                
                    setBatchAdmin.add(u.id);             
            }*/
            
            // if(!setBatchAdmin.contains(Userinfo.getUserId()))
            // {
// system.debug('#### Inside Non System Admin section');
                lstCQR = [SELECT Account_ID__c, Badge_ID__c, Batch_ID__c, Name,District_Name__c, External_ID__c,Oracle_District_ID__c, Id, Role_Name__c, SFDC_User_ID__c from Core_Quota_Rep__c where Account_ID__c in:mapTriggerNew.keyset() limit 50000];
                
// system.debug('#### List of CQRS for the Account : '+lstCQR);
                for(Core_Quota_Rep__c cqr: lstCQR)
                {
                    setCQRUserId.add(cqr.SFDC_User_ID__c);  
                    setOracleDistrictIds.add(cqr.Oracle_District_ID__c);
                }
                
                
                lstDLookup = [select id,Oracle_District_ID__c, name from District_Lookup__c where Oracle_District_ID__c IN :setOracleDistrictIds limit 50000];
// system.debug('#### List of DLookups: '+lstDLookup);

                for (District_Lookup__c dl : lstDLookup)
                {
                    mapDistrictIdDLookup.put(dl.Oracle_District_ID__c, dl);
                }
                
                for(Account acc: mapTriggerNew.values())
                {                                                   
                    for(Core_Quota_Rep__c cqrdist: lstCQR)
                    {
                        if(acc.id == cqrdist.Account_ID__c && 
                            (acc.Core_Quota_Rep__c==cqrdist.SFDC_User_ID__c || 
                                (setHouseUserId.contains(acc.Core_Quota_Rep__c) && cqrdist.Badge_ID__c.startsWith('D'))))
                        {
                            if(cqrdist.Oracle_District_ID__c!=null)
                            {
// system.debug('#### Inside if that checks if D id in cqr is not null');
                                String strDistrictId;
                                strDistrictId = cqrdist.Oracle_District_ID__c;
                                if(mapDistrictIdDLookup.get(strDistrictId).id!=null)
                                {
// system.debug('#### Below acc DLookup change');
                                    acc.District_Lookup__c = mapDistrictIdDLookup.get(strDistrictId).id;
                                }
                            }
                            if(cqrdist.Badge_ID__c.startsWith('D'))
                            {
                                acc.Core_Quota_House_Name__c = cqrdist.name;                                
                            }
                            else
                            {
                                acc.Core_Quota_House_Name__c = null;
                            }
                        }
                    }                   
                    if(!setHouseUserId.contains(acc.Core_Quota_Rep__c) && (setCQRUserId == null || setCQRUserId.size() <= 0 || !setCQRUserId.contains(acc.Core_Quota_Rep__c)) && acc.Core_Quota_Rep__c != null)
                    {
                        acc.addError(System.Label.Account_Core_Quota_Rep_Error_Msg);
                    }
                    else if(setCQRUserId != null && setCQRUserId.size() > 0 && acc.Core_Quota_Rep__c == null)
                    {
                        acc.addError(System.Label.Account_Blank_Core_Quota_Rep_Error_Msg);
                    }                               
                }
                
            // }
        }
    }
}