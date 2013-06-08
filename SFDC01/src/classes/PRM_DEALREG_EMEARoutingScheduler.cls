/*==========================================================================================================+

|  HISTORY  |                       

|  DATE          DEVELOPER               WR         DESCRIPTION                          

 
  ====          =========               ==         =========== 

| 08/06/2011    Ashwini Gowda                     This Scheduler class is used EMEA Routing Approval Process.
| 20/07/2011    Anand Sharma					   Added batch size for batch job. 
 +=============================================================================================================*/
global class PRM_DEALREG_EMEARoutingScheduler implements Schedulable{
	
	/* @Method <This method execute is used to create sharing records between the associated accounts.
        This is schedular class which is scheduled automatically using custom setting>
		@param <SchedulableContext to keep track of the scheduled job once it's scheduled>
		@return <void> - <Not Returning anything>
		@throws exception - <No Exception>
	*/

    global void execute(SchedulableContext SC){
    	Integer batchSize = 20; // this will be overwritten in try block
    	Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
    	
        try {        
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null){
                System.abortJob(ct.Id);
            }
        }
        catch(Exception e) {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
        }
        try
        {            
            batchSize  = Integer.valueOf(DataValueMap.get('DealRegEMEABatchSize').DataValue__c);
        }
        catch(Exception e)
        {
            batchSize = 1;
        }
        PRM_DEALREG_EMEARoutingBatch emeaRoutingBatch = new PRM_DEALREG_EMEARoutingBatch();
        database.executebatch(emeaRoutingBatch, batchSize);
    }

}