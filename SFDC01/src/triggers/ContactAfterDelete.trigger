/*===================================================================================================================================
|22/01/2011      Accenture                              Updated trigger to incorporate ByPass Logic
|                                                       NOTE: Please write all the code after BYPASS Logic 
 ===================================================================================================================================*/

trigger ContactAfterDelete on Contact (after delete) {
    //Trigger BYPASS Logic
   if(CustomSettingBypassLogic__c.getInstance()!=null){
         if(CustomSettingBypassLogic__c.getInstance().By_Pass_Contact_Triggers__c){
                return;
         }
    }
        // decrement the related Account records' contact counts
        AH_ChildObjectCounters.ProcessContactDeletes(trigger.old);
        
        // Update the related Account records' contact - EMC Central Partner users Counts
        PRM_PartnerUsersCount.ProcessContactDeletes(trigger.old);
   }