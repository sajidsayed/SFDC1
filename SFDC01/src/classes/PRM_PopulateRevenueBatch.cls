/*=====================================================================================================+

|  HISTORY  |                       

|  DATE          DEVELOPER               WR         DESCRIPTION                          

 
  ====          =========               ==         =========== 
  27 Feb 2012   Arif

 +=====================================================================================================*/
global class PRM_PopulateRevenueBatch extends SequencialBatchJobScheduler{
  
  public string batchQuery = '';
  public decimal BatchId = 1.0;
  public PRM_PopulateRevenueBatch(){
      map<string,CustomSettingDataValueMap__c> mapCustomSetting = CustomSettingDataValueMap__c.getall();
      if(mapCustomSetting.containsKey('Batch Id')){
          if(mapCustomSetting.get('Batch Id').DateValue__c != null){
              BatchId = mapCustomSetting.get('Batch Id').DateValue__c;
          }    
      }    
      batchQuery = 'select Batch_Id__c,Text1__c,Text2__c,Text3__c,Text4__c,Text5__c,Text6__c,Text7__c,Text8__c,Text9__c,Text10__c,Object_Name__c'+ 
                   ' from Staging_Data__c where Object_Name__c = \'Revenue\' and Batch_Id__c =:BatchId';
  }
  
  public PRM_PopulateRevenueBatch(string Query){
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
      list<Staging_Data__c> lstStagingData = (list<Staging_Data__c>)scope; 
      system.debug('lstStagingData ---->' +lstStagingData);
      if(lstStagingData.size()>0){
          PRM_RevenueGAFVROperations obj = new PRM_RevenueGAFVROperations();
          obj.insertUpdateRevenue(lstStagingData);
      }
    } 
}