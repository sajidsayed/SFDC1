/*===================================================================================================================================
|22/01/2011      Accenture                              Updated trigger to incorporate ByPass Logic
|                                                       NOTE: Please write all the code after BYPASS Logic
|18/05/2012 	 Anirudh				  192375	    Added Logic to flip record type based on PartnerType=DistiVAR 
 ===================================================================================================================================*/

trigger ContactBeforeInsert on Contact (before insert) {
    if(CustomSettingBypassLogic__c.getInstance()!=null){
         if(CustomSettingBypassLogic__c.getInstance().By_Pass_Contact_Triggers__c){
                return;
         }
    }
        //Prevent creation of duplicate contacts
        CTCT_PreventDuplicates.ProcessContactInserts(trigger.new);
        PRM_ContactUserSynchronization syncObj = new PRM_ContactUserSynchronization();
        syncObj.flipContactRecordTypetoDistiVar(trigger.new);
        
     }