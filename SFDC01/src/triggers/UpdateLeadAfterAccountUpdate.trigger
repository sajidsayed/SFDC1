/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  06.12.2010      Shipra Misra    151285      Add Install Base flag to Leads - Created trigger to update/flag all Leads 
                                                where Related Account is marked as Install Base 
 | 28/11/2011      Shipra Misra     180005      Checking if trigger is fired after TA Assignment status update then return.
 | 28.11.2011      Suman B          IM7312572�  Added conditon to check for the Account's Address and Name change.      
 | 23.12.2011      Suman B          WR-181921   updateInstallBaseAccount() method is now directly called from the trigger. 
 |                                              not through the future call (asynchUpdateInstallBaseAccount()), to bypass the 
 |                                              future call parameter limitations.
   03.02.2012      Arif             ByPass Trigger according to Custom Setting Logic.       
 +========================================================================================================================*/

trigger UpdateLeadAfterAccountUpdate on Account (after update) {
   //Trigger BYPASS Logic
    if(CustomSettingBypassLogic__c.getInstance()!=null){       
       if(CustomSettingBypassLogic__c.getInstance().By_Pass_Account_Triggers__c){
                return;
       }
    }
    if(Util.UPDATED_FROM_TO_TA_ASSIGNMENT_JOB_FLAG)return;
    //Hold Set Of Account Id's.
    Set<Id> accIdSet= new Set<Id>();
    Map<String,set<Id>> mapfield_setAccIds = new Map<String,set<Id>>(); 
    for(id accId:trigger.newMap.keySet())
    {
        Account accntNew =Trigger.newMap.get(accId);
        Account accntOld =Trigger.oldMap.get(accId);
        system.debug(' ==== '+accntNew.OwnerId+' ===== '+accntOld.OwnerId);
        //Checking if New Install Base Account value is not = Old Install Base Account field then only add value to set.
        // Added condtion  to check for Address field change -- IM7312572
        if(accntNew.Install_Base_Account__c != accntOld.Install_Base_Account__c ||
           accntNew.Address_Local__c        != accntOld.Address_Local__c || 
           accntNew.City_Local__c           != accntOld.City_Local__c ||
           accntNew.Country_Local__c        != accntOld.Country_Local__c ||
           accntNew.State_Province_Local__c != accntOld.State_Province_Local__c ||
           accntNew.Street_Local__c         != accntOld.Street_Local__c ||
           accntNew.NameLocal               != accntOld.NameLocal ||
           accntNew.Name                    != accntOld.Name ||                             
           accntNew.Zip_Postal_Code_Local__c!= accntOld.Zip_Postal_Code_Local__c ||
           accntNew.EMC_Classification__c != accntOld.EMC_Classification__c ||
           accntNew.BillingCity       != accntOld.BillingCity ||
           accntNew.BillingCountry    != accntOld.BillingCountry ||  
           accntNew.BillingPostalCode != accntOld.BillingPostalCode || 
           accntNew.BillingState      != accntOld.BillingState || 
           accntNew.BillingStreet     != accntOld.BillingStreet   
           //accntNew.OwnerId				!= accntOld.OwnerId
           )
        {
            if(mapfield_setAccIds.containskey('Address_InstallBase')){
               mapfield_setAccIds.get('Address_InstallBase').add(accntNew.id);
            }
            else{
               mapfield_setAccIds.put('Address_InstallBase',new set<Id>());
               mapfield_setAccIds.get('Address_InstallBase').add(accntNew.id);
            }
            //Adding Account Id to set.
            //accIdSet.add(accntNew.id);
        } // End of Address -if condition.

        // Account Owner change.
        if(accntNew.IsPartner && accntNew.OwnerId != accntOld.OwnerId ){
            if(mapfield_setAccIds.containskey('Owner_change')){
               mapfield_setAccIds.get('Owner_change').add(accntNew.id);
            }
            else{
               mapfield_setAccIds.put('Owner_change',new set<Id>());
               mapfield_setAccIds.get('Owner_change').add(accntNew.id);
            }
        } // End of Ownerchange -if condtion.   
    }    
    if(mapfield_setAccIds.size()>0)
    {
            //asynchUpdateInstallBaseAccount(accIdSet); 
            system.debug('before entering into method ');
            system.debug('mapfield_setAccIds==========='+mapfield_setAccIds);
            Acc_updateInstallBaseAccount.updateInstallBaseAccount(mapfield_setAccIds) ;
            system.debug(' after update trigger calling class');
    }
    
   
}