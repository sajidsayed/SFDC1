/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE           DEVELOPER                WR                DESCRIPTION                               
 |  ====           =========                ==                =========== 
 
 +======================================================================================================================================*/

global  class AP_BatchDeleteDataScheduler implements Schedulable{
 
global void execute(SchedulableContext SC){
        Integer batchSize =200; 
        try{
            //Abort the existing schedule 
           CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            System.debug('ct-------->'+ct);
            if(ct != null) {
                System.abortJob(ct.Id); 
            }
        } catch (Exception e) {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
        }   
        String Query = 'Select Id from CQR_Delta_Log__c';
        BatchDeleteData delCQRlog = new BatchDeleteData(Query,'CQR_Delta_Log__c');
        database.executebatch(delCQRlog,batchSize);
    }
}