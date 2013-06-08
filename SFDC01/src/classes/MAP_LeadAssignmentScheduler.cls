/*=======================================================================================================================================+
 
 |  DATE          DEVELOPER                WR          DESCRIPTION                               

 |  ====          =========                ==          =========== 

 |  05/08/2013    Sravanthi         	  249112  	   If condition has been added before calling executebacth method to check if 
 														there are jobs already running.
                                                      
+=======================================================================================================================================*/
global class MAP_LeadAssignmentScheduler implements Schedulable
{
	global void execute(SchedulableContext SC)
	{
		integer batchSize = 0;
		try
		{
		  batchSize = Integer.valueOf(MAP_LeadAssignmentUtils.getProfileOptionValue('Lead_Batch_Size'));
		}
		catch(Exception ex)
		{
			system.debug('MAP_LeadAssignmentScheduler.execute: Unable to set batchsize owing to ' + ex.getMessage());
			batchSize = 25;
		}
        try 
        {
        	//Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null)
            {
                System.abortJob(ct.Id);
            }
        } catch (Exception e) 
        {
			System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
		}
		try{
			Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
			Integer i =0 ;
			if(DataValueMap.get('Concurrent Batch Apex Job Limit') != null)
				i = Integer.valueof(DataValueMap.get('Concurrent Batch Apex Job Limit').DataValue__c);
			List<AsyncApexJob> lst = new List<AsyncApexJob> ();
			lst  = [Select Id, Status, JobType,NumberOfErrors, JobItemsProcessed FROM AsyncApexJob where JobType = 'BatchApex' AND Status in ('Processing','Queued','Preparing')];
			if(lst.size()<i){ //Condition has been added for WR 249112
				MAP_LeadAssignmentBatch leadBatch = new MAP_LeadAssignmentBatch();
				database.executebatch(leadBatch, batchSize);
			}else{
				//Schedule it after 5 min if there are already jobs running - WR 249112.
			   Datetime dt = System.now();
		       dt = dt.addMinutes(5);
		       String scheduleString='0';//0 seconds
		       scheduleString+=' '+ dt.minute();
		       scheduleString+=' '+ dt.hour();
		       scheduleString+=' '+ dt.day();
		       scheduleString+=' '+ dt.month();
		       scheduleString+=' ?';
		       scheduleString+=' '+ dt.year();
		       String jobName = 'Lead Routing Batch - ' + dt.format('MM-dd-yyyy-hh:');
			   MAP_LeadAssignmentScheduler nextBatchJob = new MAP_LeadAssignmentScheduler();
			   System.schedule(jobName,scheduleString,nextBatchJob); 	
			}
		}catch(Exception e){ 
			System.debug('From scheduler class unable to call executebatch method due to error:  ' + e.getMessage()); 
		}
		
		
	}
}