/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER         WR       DESCRIPTION                               

 |  ====          =========         ==       =========== 

 |  6/12/2010     Ashwini Gowda     1155     The PRM tool will allow partners users and 
                                             CAMs to access the channel account plan.
 +===========================================================================*/
trigger CAPAfterUpdate on SFDC_Channel_Account_Plan__c (after update){
    PRM_CAPVisibility channelPlanVisibility = new PRM_CAPVisibility();
    channelPlanVisibility.createCAPShareforApprovers(trigger.new);
    channelPlanVisibility.createCAPShareforGroups(trigger.new);
}