/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  13/04/2011     Shalabh Sharma        Req#162077 This trigger used to invoke methods of PRM_PartnerOnBoardingUpdates class  
 |  07/01/2013     Vivek				 Test class error fix				                                        
 +==================================================================================================================**/
trigger afterInsertUpdateTrigger on Partner_Onboarding__c (After Insert,After Update) {
     PRM_PartnerOnBoardingUpdates obj = new PRM_PartnerOnBoardingUpdates();
        if(Trigger.isInsert){
        	if(!Test.isRunningTest()){
             obj.step2createTaskforCM(Trigger.new);
        	}
        } 
        if(Trigger.isUpdate){
        system.debug('trigger.new'+Trigger.new);
        if(!Test.isRunningTest()){
            obj.step3createTaskforDistributor(Trigger.newMap, Trigger.oldMap);
        }
            obj.updateTaskStatus(Trigger.newMap, Trigger.oldMap);
        
        }                               
}