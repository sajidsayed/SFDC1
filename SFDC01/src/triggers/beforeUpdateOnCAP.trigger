/*================================================================================
Name            WR       Description
Ashwini Gowda    -       This trigger Flips the RecordTypes of CAP and Objectives to
                         Locked if CAP is Approved.  
===================================================================================*/
trigger beforeUpdateOnCAP on SFDC_Channel_Account_Plan__c (before update) {
    Map<id,SFDC_Channel_Account_Plan__c> channelPlanMap = new Map<Id,SFDC_Channel_Account_Plan__c>();
    Map<id,SFDC_Channel_Account_Plan__c> unlockChannelPlanMap = new Map<Id,SFDC_Channel_Account_Plan__c>();
    Map<id,SFDC_Channel_Account_Plan__c> lockChannelPlanMap = new Map<Id,SFDC_Channel_Account_Plan__c>();
    for(SFDC_Channel_Account_Plan__c channelPlan: trigger.new){
        if(channelPlan.Status__c=='Approved' && Trigger.oldMap.get(channelPlan.Id).Status__c !='Approved'){
            channelPlanMap.put(channelPlan.id,channelPlan);
            channelPlan.Lock_CAP__c=true;
        }
        if(channelPlan.Lock_CAP__c==false && Trigger.oldMap.get(channelPlan.Id).Lock_CAP__c==true){
                if (channelPlan.EMC_CAM__c == UserInfo.getUserId()  ){
                    unlockChannelPlanMap.put(channelPlan.id,channelPlan);
                }
        }
        else if(channelPlan.Lock_CAP__c==true && Trigger.oldMap.get(channelPlan.Id).Lock_CAP__c==false ){
            if (channelPlan.EMC_CAM__c == UserInfo.getUserId()  ){
                lockChannelPlanMap.put(channelPlan.id,channelPlan);
            }
        }
    } 
    
    if(channelPlanMap.size()>0){
        PRM_CAPLockProcess capLockProcess = new PRM_CAPLockProcess();    
        capLockProcess.lockChannelAccountPlans(channelPlanMap);
    }  
    if(unlockChannelPlanMap.size()>0){
        PRM_CAPLockProcess capLockProcess = new PRM_CAPLockProcess();
        capLockProcess.unlockChannelAccountPlans(unlockChannelPlanMap);
    }
    if(lockChannelPlanMap.size()>0){
        PRM_CAPLockProcess capLockProcess = new PRM_CAPLockProcess();
        capLockProcess.lockChannelAccountPlans(lockChannelPlanMap);
    }
}