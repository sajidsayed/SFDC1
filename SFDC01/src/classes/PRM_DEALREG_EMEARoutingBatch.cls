/*=====================================================================================================+

|  HISTORY  |                       

|  DATE          DEVELOPER               WR         DESCRIPTION                          

 
  ====          =========               ==         =========== 

|  08/06/2011    Ashwini Gowda                     This Batch class is used EMEA Routing Approval Process. 
|  13/07/2011    Anand Sharma                      Added SLA Method to Finish method as well.
 +=====================================================================================================*/
global class PRM_DEALREG_EMEARoutingBatch implements Database.Batchable<SObject> {
  
  public string batchQuery = '';
  Map<String,CustomSettingDataValueMap__c> scheduleTime = CustomSettingDataValueMap__c.getall();
  
  public PRM_DEALREG_EMEARoutingBatch(){
    batchQuery = 'select id,DealReg_isProcessed__c,DealReg_ActorId__c,DealReg_ProcessId__c'+ 
                                ' from PRM_DealReg_EMEAProcessItem__c ';
  }
   
  
/*@Method <This method gets executed acutomatically when the batch job is started.>
    @param <Database.BatchableContext BC - Batchable context>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
*/
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(batchQuery);
    }
     
/*@Method <This method gets executed acutomatically when the batch job is execution mode.>
    @param <Database.BatchableContext BC - Batchable context>
    @param <List<Sobject> scope - scope>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
*/
    global void execute(Database.BatchableContext BC, list<SObject> scope){
      Set<String> setActorIDs = new Set<String>();    
      Set<String> setProcessIDs = new Set<String>(); 
      List<PRM_DealReg_EMEAProcessItem__c> emeaProcessItemList = (PRM_DealReg_EMEAProcessItem__c[]) scope; 
      Map<String, PRM_DealReg_EMEAProcessItem__c> mapEmeaProcessItem = new Map<String, PRM_DealReg_EMEAProcessItem__c>(); 
      List<ProcessInstanceWorkitem > lstProcessWorkItem = new List<ProcessInstanceWorkitem>();
      Database.SaveResult[] updatedRecords;
             
      for(PRM_DealReg_EMEAProcessItem__c objProcessItem: emeaProcessItemList){        
        if(objProcessItem.DealReg_ActorId__c != null && objProcessItem.DealReg_ProcessId__c != null){            
          Id DealRegId = objProcessItem.DealReg_ActorId__c;
          setActorIDs.add(DealRegId); 
          Id ProcessId =  objProcessItem.DealReg_ProcessId__c;          
          setProcessIDs.add( ProcessId);             
        mapEmeaProcessItem.put(objProcessItem.DealReg_ProcessId__c, objProcessItem);  
      } 
    } 
    System.Debug('setActorIDs ---> ' + setActorIDs);  
    System.Debug('setProcessIDs ---> ' + setProcessIDs);
    if(setProcessIDs.size()>0){     
      lstProcessWorkItem = [Select p.ActorId, p.Id, p.OriginalActorId, p.ProcessInstanceId 
                  from ProcessInstanceWorkitem p                 
                  where Id in: setProcessIDs];   
    }                                         
    if(lstProcessWorkItem.size() >0){        
      for(ProcessInstanceWorkitem objProcess: lstProcessWorkItem){  
        if(mapEmeaProcessItem.containsKey(objProcess.Id)){
          objProcess.ActorId = mapEmeaProcessItem.get(objProcess.Id).DealReg_ActorId__c;  
        }     
      }
      updatedRecords = Database.update(lstProcessWorkItem,false);    
      PRM_DEALREG_EMEARoutingBatch.deleteProcessedRecords(updatedRecords,emeaProcessItemList);
    }
        
    //For Auto Approval
    PRM_DEALREG_ApprovalRouting.updateSLAFieldRepExpirationDateForDR();
    PRM_DEALREG_ApprovalRouting.updateSLAFieldRepExpirationDateForER();
    }

/*@Method <This method gets executed to delete processed records.>
    @param <Database.SaveResult[] updatedRecords>
    @param <List<PRM_DealReg_EMEAProcessItem__c>>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
*/
    
    public static void deleteProcessedRecords(Database.SaveResult[] updatedRecords,List<PRM_DealReg_EMEAProcessItem__c> emeaProcessItemList){
       List<PRM_DealReg_EMEAProcessItem__c> processedRecordsList = new List<PRM_DealReg_EMEAProcessItem__c>();
        for (integer i = 0; i < updatedRecords.size(); i++) {
          for(PRM_DealReg_EMEAProcessItem__c emeaProcessItem :emeaProcessItemList){
        if (updatedRecords[i].isSuccess()) {
          if(updatedRecords[i].id == emeaProcessItem.DealReg_ProcessId__c){
            processedRecordsList.add(emeaProcessItem);
          }
            }
          }
        } 
        if(processedRecordsList.size()>0){
          delete processedRecordsList;
        }
   }   

    
/*@Method <This method gets executed acutomatically when the batch job is finised. We are deleting the job at the end.>
  @param <Database.BatchableContext BC - Batchable context>
  @return <void> - <Not returning anything>
  @throws exception - <No Exception>
*/
    global void finish(Database.BatchableContext BC){
    
        //For Auto Approval
        PRM_DEALREG_ApprovalRouting.updateSLAFieldRepExpirationDateForDR();
        PRM_DEALREG_ApprovalRouting.updateSLAFieldRepExpirationDateForER();
              
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems 
                 FROM AsyncApexJob 
                 where Id =:BC.getJobId()];
       //Schedule the next batch job to run for 5 minutes later:
       Datetime dt = System.now();
       Integer timeInMin = Integer.valueof(scheduleTime.get('EMEASchedularTimeInterval').DataValue__c);
       dt = dt.addMinutes(timeInMin);
       String scheduleString='0';//0 seconds
       scheduleString+=' '+ dt.minute();
       scheduleString+=' '+ dt.hour();
       scheduleString+=' '+ dt.day();
       scheduleString+=' '+ dt.month();
       scheduleString+=' ?';
       scheduleString+=' '+ dt.year();
       String jobName = 'EMEA Process Batch - ' + dt.format('MM-dd-yyyy-hh:');
            
       PRM_DEALREG_EMEARoutingScheduler nextBatchJob = new PRM_DEALREG_EMEARoutingScheduler();
       System.schedule(jobName,scheduleString,nextBatchJob); 
    }   
}