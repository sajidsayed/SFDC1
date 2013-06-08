/*===========================================================================+

 |  HISTORY  |                
                                                            

 |  DATE          DEVELOPER         WR       DESCRIPTION                               

 |  ====          =========         ==       =========== 

 |  6/12/2010     Ashwini Gowda     1155     The PRM tool will allow partners users and 
                                             CAMs to access the channel account plan.
    
 |  14/2/2011     Anirudh Singh     1746      This logic will fire when User clones an existing 
                                              channel plan and will call cloneobjective method of
 |                                            PRM_CloneChannelPlan class only if cloning is done
                                              from UI.                                         
 +===========================================================================*/
trigger CAPAfterInsert on SFDC_Channel_Account_Plan__c (after insert) {
    PRM_CAPVisibility channelPlanVisibility = new PRM_CAPVisibility();    
    channelPlanVisibility.createCAPShareforApprovers(trigger.new);
    channelPlanVisibility.createCAPShareforGroups(trigger.new);
    //Added By Anirudh for Req #1746.
    //Changes start
    List<SFDC_Channel_Account_Plan__c> clonedChannelPlan = New List<SFDC_Channel_Account_Plan__c> ();
    for(SFDC_Channel_Account_Plan__c channelPlan :Trigger.new){
        if(channelPlan.Clone__c!='' && channelPlan.Clone__c!= null){    
            clonedChannelPlan.add(channelPlan);
            PRM_CloneChannelPlan clonePlan = New PRM_CloneChannelPlan();
            clonePlan.cloneobjectives(clonedChannelPlan);
         }  
     } 
     //Changes End    
}