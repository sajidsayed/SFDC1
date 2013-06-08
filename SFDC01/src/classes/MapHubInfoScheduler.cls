/*======================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |   
 |  03/21/13   Krishna Pydavula         241804      commented the corntrigger code to exectue the scheduler for everyday
 |                                                  AND Aborting the existing batch job.
 +=======================================================================================*/
global class MapHubInfoScheduler implements Schedulable {
    public Boolean isTest=false;
    global void execute(SchedulableContext SC)
    {
         /* try 
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
        }*/
      
     	 List<AsyncApexJob> activejobs = [SELECT Id, Status,ApexClassId,ApexClass.Name from AsyncApexJob WHERE ApexClass.Name like'%MapHubInfoPopulation%'];
        system.debug('--------------'+activejobs);
        if(activejobs.size()>0)
        {
            //Abort the existing Batch job 
            for(AsyncApexJob a:activejobs)
            {   
                if(a.status=='Queued'||a.status=='Processing'||a.status=='Preparing'||isTest==true)
                {
                    system.abortJob(a.id);
                }
                
                isTest=false;
            }
        }
        
            MapHubInfoPopulation hubInfoBatch = new MapHubInfoPopulation();
            database.executebatch(hubInfoBatch);
        
    }
}