/*=====================================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 

| 17/12/2010    Karthik Shivprakash       1314          This scheduler class is used to schedule 
                                                        the batch class PRM_PopulateEducationMasterBatch
                                                        to populate the data on education master.  
|
+=====================================================================================================*/

global class PRM_PopulateEducationMasterScheduler implements Schedulable{
	
	/* @Method <This method execute is used to schedule to populate the data on education master>
	   @param <SchedulableContext to keep track of the scheduled job once it's scheduled>
	   @return <void> - <Not Returning anything>
	   @throws exception - <No Exception>
	*/
	
 	global void execute(SchedulableContext SC){
 		
 		try {
        	//Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null){
                System.abortJob(ct.Id);
            }
        } catch (Exception e) {
			System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
		}
 		
 		//Here we are instantiating the batch class PRM_PopulateEducationMasterBatch to schedule.
 		PRM_PopulateEducationMasterBatch Obj = new PRM_PopulateEducationMasterBatch();
 		database.executebatch(Obj);
    }
}