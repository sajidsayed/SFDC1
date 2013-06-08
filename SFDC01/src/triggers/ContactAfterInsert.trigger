/*===================================================================================================================================
|22/01/2011      Accenture                              Updated trigger to incorporate ByPass Logic
|                                                       NOTE: Please write all the code after BYPASS Logic 
 ===================================================================================================================================*/

trigger ContactAfterInsert on Contact (after insert) {
    if(CustomSettingBypassLogic__c.getInstance()!=null){
         if(CustomSettingBypassLogic__c.getInstance().By_Pass_Contact_Triggers__c){
                return;
         }
    }
        // increment the related Account records' contact counts
        AH_ChildObjectCounters.ProcessContactInserts(trigger.new);
        
        // Update the related Account records' contact - EMC Central Partner users Counts
        PRM_PartnerUsersCount.ProcessContactInserts(trigger.new);
     }