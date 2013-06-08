/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    21-Jan-2013     Shipra Misra       		223457          Sechdules Deletes_TA_Sync to delete 30 day old TA Sync Log records 
                                                            
==============================================================================*/
global with sharing class Schedule_Delete_Old_TA_Sync implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
    	
    	String query = 'Select Sales_Resource__c, Status__c, LastModifiedDate, OwnerId, Name, Id, Error__c, Count__c From TA_Sync_Log__c ';
    	integer batchSize = 200;
    	try {
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null) {
                System.abortJob(ct.Id);
            }
        } catch (Exception e) {
            System.debug(' There are no jobs currently  scheduled. ' + e.getMessage()); 
        } 
    	Delete_Old_TA_Sync_Log TADeleteBactch = new Delete_Old_TA_Sync_Log(query);
    	Database.executebatch(TADeleteBactch, batchSize);
    }
}