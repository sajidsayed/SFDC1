/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  15-Apr-2011    Suman                            Created for handling the Batchjobs and can be executed
                                                     from UI.
 +=======================================================================================================*/
@istest
private class RunBatchJobs_TC {
   
 private static testmethod void  testRunBatchJobs() {
  Test.startTest();
    Map<String,CleanupTableData__c> mapTables = CleanupTableData__c.getall();
     CleanupTableData__c  tabledata = mapTables.get('EMC_Exception__c');
     if(tabledata != null && (!tabledata.Active__C) ){
       tabledata.Active__c = TRUE;
       update tabledata ;
     }
    RunBatchJobs runjobObj = new RunBatchJobs();
    runjobObj.SelectedJob ='Delete All' ;
    runjobObj.runSelectedJob();
    
    runjobObj.getJobOperations();
    Test.stopTest();  
 
 }
 
 
 
 
}