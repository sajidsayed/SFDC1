trigger JobSchedulerBeforeInsert on Job_Scheduler__c (before insert) {

    System.debug('****************************************JobSchedulerBeforeInsert*****************************************');
    SCH_SchedulerOperations.initScheduler(trigger.new);
    
}