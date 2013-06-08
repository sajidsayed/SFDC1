/*====================================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  03-Apr-2012   Anand Sharma                      This class has been scheduled for Champions jobs run. 
 +==================================================================================================================*/
global class PRM_CalculateChampion_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc){
    	List<SequencialBatchJob>LstSeqJobs=new List<SequencialBatchJob>();	        
       PRM_CalculateChampionsBatch objChampBatch =  new PRM_CalculateChampionsBatch();
       LstSeqJobs.add(new SequencialBatchJob('CalculateCampions', objChampBatch,10));     
       SequencialBatchJobScheduler.executeSequence(LstSeqJobs);

    } 
}