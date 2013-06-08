/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    15-Feb-2011     Srinivas Nallapati      139074          Sechdules Deletes_TA_Sync_log to delete TA Sync Log records 
                                                            
==============================================================================*/
global with sharing class Schedule_Delete_TA_SYNC_LOG implements Schedulable
{
    public String query;
    public Job_Scheduler__c js;
    global Schedule_Delete_TA_SYNC_LOG(Job_Scheduler__c js,String query){
       this.js = js;
       this.query=query;
       System.debug('query is ===>'+query);
       System.debug('js is---->'+js);
    }
    
    global void execute(SchedulableContext sc)
    {
    	
    	query = 'Select Sales_Resource__c, Status__c, LastModifiedDate, OwnerId, Name, Id, Error__c, Count__c From TA_Sync_Log__c ';
    	integer batchSize = 200;
    	try {
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null) {
                System.abortJob(ct.Id);
            }
        } catch (Exception e) {
            System.debug('There are no jobs currently  scheduled. ' + e.getMessage()); 
        } 
    	Delete_TA_Sync_Log_Batch TADeleteBactch = new Delete_TA_Sync_Log_Batch(query,js);
    	Database.executebatch(TADeleteBactch, batchSize);
    }
}