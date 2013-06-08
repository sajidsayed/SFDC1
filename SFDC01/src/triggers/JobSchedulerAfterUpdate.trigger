trigger JobSchedulerAfterUpdate on Job_Scheduler__c (after update) {

    System.debug('****************************************JobSchedulerAfterUpdate*****************************************');
    SCH_SchedulerOperations.ProcessScheduleUpdates(trigger.new, trigger.old);
}