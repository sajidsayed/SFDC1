/*=====================================================================================================+

|  HISTORY  |                       

|  DATE          DEVELOPER               WR         DESCRIPTION                          

 
  ====          =========               ==         =========== 

 27 Feb 2012    Arif
 +=====================================================================================================*/
global class PRM_CalculateGAFandVelocityFieldsBatch extends SequencialBatchJobScheduler{
  
  public string batchQuery = '';
  public PRM_CalculateGAFandVelocityFieldsBatch(){
      batchQuery = 'select Id,PROFILED_ACCOUNT_FLAG__c from account where PROFILED_ACCOUNT_FLAG__c = true'; 
  }
  
   public PRM_CalculateGAFandVelocityFieldsBatch(string Query){
      this.batchQuery = Query; 
  }
/*@Method <This method gets executed acutomatically when the batch job is started.>
    @param <Database.BatchableContext BC - Batchable context>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
*/
    global override Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(batchQuery);
    }
     
/*@Method <This method gets executed acutomatically when the batch job is execution mode.>
    @param <Database.BatchableContext BC - Batchable context>
    @param <List<Sobject> scope - scope>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
*/
    global override void execute(Database.BatchableContext BC, list<SObject> scope){
      list<account> lstAccount = (list<account>)scope;
      if(lstAccount.size()>0){
          PRM_RevenueGAFVROperations obj = new PRM_RevenueGAFVROperations(); 
          obj.calculateRevenueForAccount(lstAccount);
      }    
    }  
}