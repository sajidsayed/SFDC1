/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE           DEVELOPER                WR                DESCRIPTION                               
 |  ====           =========                ==                =========== 
 |  18 Dec 2012   Hemavathi N M         Account Presentation  To Schedule Batch Job to Delete Audit Reporting Data from Master Object 
 +======================================================================================================================================*/

global  class AP_BatchDeleteReportScheduler implements Schedulable{
 public Boolean isReportRunTest = false;
global void execute(SchedulableContext SC){
        //Integer batchSize =200; 
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
        
       DateTime n = datetime.now().addMinutes(2);
          String cron1 = '0 0 3 ? * 1'; //Run Every Sunday 3 AM EST
          String Query;
          //0 0 22 ? * 6
          System.debug('Cron1---->' + cron1);
          
        String jobName1 = 'Batch Job To Delete Master Record - ' + n.format('MM-dd-yyyy-hh:');
        System.debug('------------------Run Batch Audit Reproting Delete Master--------------------');   
        
        Query = 'Select Id from Customer_Profile_Audit_Master__c';
        if(isReportRunTest){
        Query = 'Select Id from Customer_Profile_Audit_Master__c limit 50';
        }
        
        String ObjName='Customer_Profile_Audit_Master__c';
        BatchDeleteData deleteCPA = new BatchDeleteData(Query,ObjName);
       //  database.executebatch(deleteCPA);
        String jobId1 = System.schedule(jobName1,cron1,deleteCPA);
        
         System.debug('------------------Run Batch Audit Reproting Insert Master--------------------');
          //To Schedule batch Job 2 on same day
       
          String cron = '0 0 5 ? * 1';
          System.debug('Cron---->' + cron);
          
         String jobName = 'Batch Job To Insert Master Record - ' + n.format('MM-dd-yyyy-hh:');
         // To schedule Batch Job 2
       //  String accountQuery =  'Select ID, Name, Account_District__c,District_Lookup__c, Customer_Profiled_Account__c, Account_Profiling_Warning_Counts__c From Account WHERE type != \'Partner\' and isPartner = false and Account_District__c != null';
      //   Id batchProcessId = Database.executeBatch(new AP_Customer_Profile_Auditing(accountQuery),15);  
        AP_Customer_Profile_Auditing batchSch = new AP_Customer_Profile_Auditing();
         batchSch.isRunTest = false;
         if(isReportRunTest){
            batchSch.isRunTest = true;
         }
         String jobId = System.schedule(jobName,cron,batchSch);
    }

}