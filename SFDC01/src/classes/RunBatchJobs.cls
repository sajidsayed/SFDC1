/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  13-Apr-2011    Suman                            Created for handling the Batchjobs and can be executed
                                                     from UI.
 +=======================================================================================================*/

public class RunBatchJobs {

    public String SelectedJob { get; set; }
   

/** ADDED FOR DELETE JOBS. **/   
   public List<SelectOption> getJobOperations(){
     List<SelectOption> runoptions = new List<SelectOption>();
        
        runoptions.add(new SelectOption('Delete All','Delete All'));
        return runoptions;
   }

   public void runSelectedJob() {
     if(SelectedJob == 'Delete All'){
        runDeleteAllJob() ;
      }
    }
     
  public PageReference runDeleteAllJob(){
     system.debug('INSIDE runDeleteAllJob()') ; 
     Map<String,CleanupTableData__c> mapTables = CleanupTableData__c.getall();
     List<CleanupTableData__c> activeTables = new  List<CleanupTableData__c>();
       
      for(CleanupTableData__c tablename : mapTables.values()){
         if(tablename.Active__c){
            activeTables.add(tablename);
         }
       }
       
     if(!(activeTables.size()>5)){
      for(CleanupTableData__c tablename : activeTables){
        String objName = tablename.ObjectAPIName__c ;
        Decimal days = tablename.Number_of_Days__c ;
        String query ;
        if(days != Null) {
          DateTime delDate = System.now()- days ;  
          query = 'Select Id FROM '+ objName + ' where LastModifiedDate  < '+ new PRM_CommonUtils().getQueryFormattedDate(delDate) ;
        }else {
          query = 'Select Id FROM '+ objName ;
       }
       database.executebatch( new BatchDeleteData(query,objName) );
     }
    } //End of if Condition.
    else {
        ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.Error,'We can process only five job, so please remove some job');
        ApexPages.addMessage(msg2);
        system.debug('CANNOT EXECUTE MORE THAN -5 BATCH JOBS');
    }
    return null;
   } // End of runDeleteAllJob.
    
}