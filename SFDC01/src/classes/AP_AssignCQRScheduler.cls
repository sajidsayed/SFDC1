/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE           DEVELOPER                WR                DESCRIPTION                               
 |  ====           =========                ==                =========== 
 |  18 Dec 2012   Hemavathi N M         Account Presentation  To Schedule Batch Job to Assing the Core Quota Rep records 
 +======================================================================================================================================*/

global  class AP_AssignCQRScheduler implements Schedulable{
 public Job_Scheduler__c js;
 public Boolean isRunTest = false;
 
 global AP_AssignCQRScheduler(Job_Scheduler__c js){
 this.js = js;
 }
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
       try {
       String Query;
     Query = 'Select Id, Account__c,Account_Id__c,Badge_ID__c,Batch_ID__c,Core_Quota_Rep_Id__c,Core_Quota_Rep_Name__c,District_Name__c ,External_ID__c,Oracle_District_ID__c,Role_Name__c,SFDC_User_ID__c from CQR_Delta_Log__c order by Account__c';
     if(isRunTest){
     Query = 'Select Id, Account__c,Account_Id__c,Badge_ID__c,Batch_ID__c,Core_Quota_Rep_Id__c,Core_Quota_Rep_Name__c,District_Name__c ,External_ID__c,Oracle_District_ID__c,Role_Name__c,SFDC_User_ID__c from CQR_Delta_Log__c order by Account__c limit 100'; }
      //        String Query = 'Select Id, Account__c,Account_Id__c,Badge_ID__c,Batch_ID__c,Core_Quota_Rep_Id__c,Core_Quota_Rep_Name__c,District_Name__c ,External_ID__c,Oracle_District_ID__c,Role_Name__c,SFDC_User_ID__c from CQR_Delta_Log__c order by Account__c';
        //AP_AssignCQRtoAccount addignCQRAccount = new AP_AssignCQRtoAccount(js,Query);
        database.executebatch(new AP_AssignCQRtoAccount(js,Query));
    }
      catch (Exception e) {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
        } 
       }
}