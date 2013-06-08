/*====================================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  03-Apr-2012   Anand Sharma                      This class has been scheduled for Champions jobs run. 
    12 Oct 2012   Arif                              Added Custom Setting 
 +==================================================================================================================*/
global class PRM_CalculateRevenueGAF_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc){
        List<SequencialBatchJob> SelectedRevenueJobs= new List<SequencialBatchJob> ();
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
         Integer revenuebatchSize = 10;
        try{            
            revenuebatchSize  = Integer.valueOf(DataValueMap.get('PRM_PopulateRevenueBatch').DataValue__c);
        }catch(Exception e){
            revenuebatchSize = 10;
        } 
        Integer GAFandVelocityBatchSize = 10;
        try{            
            GAFandVelocityBatchSize  = Integer.valueOf(DataValueMap.get('PRM_CalculateGAFandVelocityFieldsBatch').DataValue__c);
        }catch(Exception e){
            GAFandVelocityBatchSize = 10;
        }
        PRM_PopulateRevenueBatch objRevenueStagingBatch =  new PRM_PopulateRevenueBatch();
        SelectedRevenueJobs.add(new SequencialBatchJob('StagingtoRevenueCalculation', objRevenueStagingBatch,revenuebatchSize));
        
        PRM_CalculateGAFandVelocityFieldsBatch objCalGafVelocity = new PRM_CalculateGAFandVelocityFieldsBatch();
        SelectedRevenueJobs.add(new SequencialBatchJob('RevenueCalculation', objCalGafVelocity,GAFandVelocityBatchSize)); 
        
        SequencialBatchJobScheduler.executeSequence(SelectedRevenueJobs);

    } 
}