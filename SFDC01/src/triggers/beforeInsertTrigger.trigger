/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  13/04/2011     Shalabh Sharma        Req#162077 This trigger used to invoke methods of PRM_PartnerOnBoardingUpdates class                                          
 +==================================================================================================================**/
trigger beforeInsertTrigger on Partner_Onboarding__c (before insert,before update) {
    PRM_PartnerOnBoardingUpdates obj = new PRM_PartnerOnBoardingUpdates();
        if(Trigger.isInsert){
            obj.step1updatePartnerOnBoardingOwner(Trigger.new);
            obj.UpdateLocalLanguageFields(Trigger.new);
        }
}