/*======================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  05/04/2011    Suman B                      Delete data from Specified table. 
 |  14/04/2011    Suman B                      Modified as per the change in requirement
 |  21/03/2013    Krishna Pydavula		241804     commented the corntrigger code to exectue the scheduler for every weekly
 |												   AND Aborting the existing batch jobs.
 +=======================================================================================*/
global class BatchDeleteData implements Database.Batchable<sObject>, Schedulable{

  public Boolean isTest=false;
  global String Query;
  global String objectName ;
  Map<String,CleanupTableData__c> mapTables = CleanupTableData__c.getall();  
  
  global BatchDeleteData (String query, String objectName ){
    this.Query = query ;
    this.objectName = objectName ;
    system.debug('QUERY ### :' + query );  
   }
   
  global BatchDeleteData (){
    system.debug('DEFAULT - QUERY ### :' + query );  
   } 
     
    //create batch of records which is passed to execute method for processing
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    // Deleting the records. 
   global void execute(Database.BatchableContext BC, LIST<SObject> scope) {
      Database.DeleteResult[] deleteResult = Database.Delete(scope) ;
      if(deleteResult != Null){
        system.debug('###objectName  ::: ' + objectName );
        createErrorLogs(deleteResult ,objectName ) ;
      }
    }

   global void finish(Database.BatchableContext BC){
     if(objectName != Null){
     CleanupTableData__c cleanObj = mapTables.get(objectName);
      if(cleanObj != Null && cleanObj.isRecurringExecute__c == False ){
       system.debug('ObjectName ### '+ cleanObj.ObjectAPIName__c); 
        cleanObj.Active__c = FALSE; 
        update cleanObj;
      } 
    } 
   } // End of finish() method.

   //Execute batch class with default constructor from scheduler    
   global void execute(SchedulableContext sc){
     system.debug('INSIDE BatchDeleteData - execute(schedulable)###'); 
      /*try {
        //Abort the existing schedule 
        CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
        if(ct != null) {
          System.abortJob(ct.Id);
         }
       }catch (Exception e) {
         System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
      }*/
      //Added by Krishna
      List<AsyncApexJob> activejobs = [SELECT Id, Status,ApexClassId,ApexClass.Name from AsyncApexJob WHERE ApexClass.Name like'%BatchDeleteData%'];
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
        
      List<CleanupTableData__c> listActiveTables = new List<CleanupTableData__c>();
      Map<String,CustomSettingDataValueMap__c> dataValueMap = CustomSettingDataValueMap__c.getall();
      integer allowedBatchJobs = (integer)dataValueMap.get('AllowedBatchJobsForOneUser').DateValue__c;
      integer counter = 1;
        for(CleanupTableData__c tablename : mapTables.values()) {
	           if(counter <=allowedBatchJobs){
		           if(tablename.Active__c) {
		            listActiveTables.add(tablename);
		          }
		          counter = counter+1;
	           }
	           if(counter > allowedBatchJobs ){
	           	  break;
	           }          
        }
              
     if(listActiveTables.size()>0){
      for(CleanupTableData__c tablename : listActiveTables){
        String objName = tablename.ObjectAPIName__c ;
        String FilterCriteria = tablename.Filter_Criteria__c;
        Decimal days = tablename.Number_of_Days__c ;
        String query ;
        //Update by Shipra  for TA Sync "Sync Complete" and "Error" records deletion. 
        if(FilterCriteria != '' || FilterCriteria != null   )
        {
        	if(days != Null)
        	{
	        	DateTime delDateforTA = System.now()- days ;
	        	query = 'Select Id FROM '+ objName + ' where ' + FilterCriteria +' and  LastModifiedDate  < '+ new PRM_CommonUtils().getQueryFormattedDate(delDateforTA);
        	}
	        else 	
	        {
	        	query = 'Select Id FROM '+ objName + ' where ' + FilterCriteria;
	        }
        }
        else if(days != Null) {
          DateTime delDate = System.now()- days ;  
          query = 'Select Id FROM '+ objName + ' where LastModifiedDate  < '+ new PRM_CommonUtils().getQueryFormattedDate(delDate) ;
        }else {
          query = 'Select Id FROM '+ objName ;
       }
       
       this.Query = query ;
       database.executebatch( new BatchDeleteData(query,objName) );
     }
    } //End of if Condition.
    else {
     system.debug('CANNOT EXECUTE MORE THAN -5 BATCH JOBS');
    }
   } // End of method - execute()
  
  Public static void createErrorLogs(Database.DeleteResult[] deleteResult, String objectName ) {
     List <EMCException> errors = new List <EMCException>();
         /* HANDLING EXCEPTION LOG*/
        for (Database.DeleteResult dr : deleteResult) {
            String dataErrs = '';
            if (!dr.isSuccess()) {
                // if the particular record did not get deleted, we log the data error 
                for (Database.Error err : dr.getErrors()) {
                    dataErrs += err.getMessage();
                }
                System.debug('An exception occurred while attempting an update on ' + dr.getId());
                System.debug('ERROR: ' + dataErrs);
                errors.add(new EMCException(dataErrs, 'ERROR_DELETION_'+objectName, new String [] {dr.getId()}));
            }
        }
      // log any errors that occurred
       if (errors.size() > 0) { 
            EMC_UTILITY.logErrors(errors);  
       }
  } 
}