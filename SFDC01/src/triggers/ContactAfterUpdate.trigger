/*===================================================================================================================================
|22/01/2011      Accenture                              Updated trigger to incorporate ByPass Logic
|                                                       NOTE: Please write all the code after BYPASS Logic 
 ===================================================================================================================================*/trigger ContactAfterUpdate on Contact (after update) {
   
    //Trigger BYPASS Logic
    if(CustomSettingBypassLogic__c.getInstance()!=null){
         if(CustomSettingBypassLogic__c.getInstance().By_Pass_Contact_Triggers__c){
                return;
         }
    }     
        // update the related Account records' contact counts
        AH_ChildObjectCounters.ProcessContactUpdates(trigger.new, trigger.old);
        List<Contact> lstUpdatedContacts = new List<Contact>();
        // Update the related Account records' contact - EMC Central Partner users Counts
        PRM_PartnerUsersCount.ProcessContactUpdates(trigger.new, trigger.old);
        for(contact conObj :trigger.Old){
            if(conObj.Email != trigger.newMap.get(conObj.Id).Email ||
               conObj.Phone != trigger.newMap.get(conObj.Id).Phone){
               lstUpdatedContacts.add(trigger.newMap.get(conObj.Id));   
            }
        }
        if(lstUpdatedContacts.size()>0){
            new PartnerInfoIntegrationOperation().insertInetgrationLogforContactUpdate(lstUpdatedContacts);
        }
    }