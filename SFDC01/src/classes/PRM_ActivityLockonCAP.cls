/*=======================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 

 |  12/8/2010     Ashwini Gowda                     This class is used to display validation
                                                    error Message when trying to insert or 
                                                    update activities associated to a locked
                                                    Channel Account Plan or Objective.
 +======================================================================================*/
public class PRM_ActivityLockonCAP {
/* @Method <getTaskUpdatesOnCAP(): This method would fetch all Tasks associated to Locked
                                   CAP and display error message when trying to update
                                   or insert a Task.>
   @param - <void>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

public void getTaskUpdatesOnCAP(List<Task> taskIds){
    Map<Id,Task> channelPlanIds = new Map<Id,Task>();
    for(Task task:taskIds){
        channelPlanIds.put(task.WhatId,task); 
    }
    Map<Id,SFDC_Channel_Account_Plan__c> channelPlans = new Map<Id,SFDC_Channel_Account_Plan__c>(
                                                        [Select s.Id,s.Lock_CAP__c 
                                                        from SFDC_Channel_Account_Plan__c s  
                                                        where Lock_CAP__c = true and 
                                                        Id in:channelPlanIds.KeySet()]);    
    if(channelPlans.KeySet().size()>0){
        getTaskErrorMessage(channelPlanIds,channelPlans.KeySet());
    }
    Map<Id,SFDC_Objective__c> objectives = new Map<Id,SFDC_Objective__c>(
                            [Select s.Channel_Account_Plan__c, s.Channel_Account_Plan__r.Lock_CAP__c,
                             s.Id from SFDC_Objective__c s where Channel_Account_Plan__r.Lock_CAP__c=true 
                             and Id in:channelPlanIds.KeySet()]);
    if(objectives.KeySet().size()>0){
        getTaskErrorMessage(channelPlanIds,objectives.KeySet());
    }
    
    
}

/* @Method <getTaskUpdatesOnCAP(): This method would fetch all Events associated to Locked
                                   CAP and display error message when trying to update
                                   or insert a Event.>
   @param - <void>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

public void getEventUpdatesOnCAP(List<Event> eventIds){
    Map<Id,Event> channelPlanIds = new Map<Id,Event>();
    for(Event event:eventIds){
        channelPlanIds.put(event.WhatId,event); 
    }
    Map<Id,SFDC_Channel_Account_Plan__c> channelPlans = new Map<Id,SFDC_Channel_Account_Plan__c>(
                                                        [Select s.Id,s.Lock_CAP__c 
                                                        from SFDC_Channel_Account_Plan__c s  
                                                        where Lock_CAP__c = true and 
                                                        Id in:channelPlanIds.KeySet()]);    
    if(channelPlans.KeySet().size()>0){
        getEventErrorMessage(channelPlanIds,channelPlans.KeySet());
    }
    Map<Id,SFDC_Objective__c> objectives = new Map<Id,SFDC_Objective__c>(
                            [Select s.Channel_Account_Plan__c, s.Channel_Account_Plan__r.Lock_CAP__c,
                             s.Id from SFDC_Objective__c s where Channel_Account_Plan__r.Lock_CAP__c=true 
                             and Id in:channelPlanIds.KeySet()]);
    if(objectives.KeySet().size()>0){
        getEventErrorMessage(channelPlanIds,objectives.KeySet());
    }
}

/* @Method <getTaskErrorMessage(): This method would display error message when trying to update
                                   or insert a Task for Locked CAP.>
   @param - <Map<Id,Task>,Set<Id> lockedObjectId>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

public void getTaskErrorMessage(Map<Id,Task> objectId,Set<Id> lockedObjectId){
    for(Id channelPlanId: objectId.KeySet()){
        for(Id lockedChannelId: lockedObjectId){
            if(lockedChannelId==channelPlanId){
                Task taskLocked = objectId.get(lockedChannelId);
                taskLocked.addError(System.Label.Cannot_insert_or_update_Task);
            }
        }
    }
}

/* @Method <getEventErrorMessage(): This method would display error message when trying to update
                                   or insert a Event for Locked CAP.>
   @param - <Map<Id,Task>,Set<Id> lockedObjectId>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

public void getEventErrorMessage(Map<Id,Event> objectId,Set<Id> lockedObjectId){
    for(Id channelPlanId: objectId.KeySet()){
        for(Id lockedChannelId: lockedObjectId){
            if(lockedChannelId==channelPlanId){
                Event eventLocked = objectId.get(lockedChannelId);
                eventLocked.addError(System.Label.Cannot_insert_or_update_Event);
            }
        }
    }
}
}