/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE           DEVELOPER                WR                DESCRIPTION                               
 |  ====           =========                ==                =========== 
 |  14 Dec 2012   Hemavathi N M         Account Presentation  To Delete the Core Quota Rep records 
 +======================================================================================================================================*/
global class AP_BatchDeleteCQRData implements Database.Batchable<sObject>  {

  public String Query;
  global List<Id> varId;
  global Id jsId;
  public Decimal batchID;
  public static Boolean blnSendEmail = false;
  public Job_Scheduler__c Js;
     /* constructor */
     global AP_BatchDeleteCQRData(){ 
        System.debug('Delete Core Qutoa Rep Records--- Query' + Query); 
      }
      
     /*Parameter Constructor*/ 
     global AP_BatchDeleteCQRData(Job_Scheduler__c js,Decimal batchID){
        System.debug('-------------------------********* INSIDE CONSTRUCTOR PARAMETER *********-----------------------------');
         this.Js = js;
         System.debug('js-in constructor--->'+ Js);
        this.batchID = batchID;
        String CQRQuery = '';
        try{
        CQRQuery='SELECT Id FROM Core_Quota_Rep__c where Batch_ID__c != null and Batch_ID__c <'+ batchID ; 
       
        }
        catch(QueryException qe){
            System.debug('Exception for query Inside Constructor' + qe);
        }
        this.Query = CQRQuery;
        System.Debug('Query Inside Constructor Parameterized' + Query );
      }//END: AP_BatchDeleteCQRData
      
    // Method : To Start the batch job  
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('-------------------------********* INSIDE START METHOD *********-----------------------------');
        System.Debug('Query Inside Start Method------> ' + Query);
        return Database.getQueryLocator(Query);
    }
    
    //Mehotd : To execute Batch Job and Delete old Records from CQR
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        system.debug('-------------------------------###### Inside Execute Method #####------------------------------');
        Database.DeleteResult[] deleteResult = Database.Delete(scope) ;
        if(deleteResult != Null){
        catchErrorLogs(deleteResult) ;
        }
        system.debug('Delete Records');
     }//END : execute
  
    /*Method :Finish Batch Job - This method is used to calculate the remaining CQR , based on expected count, 
    batch Job2 will be called . If expected count is not met mail will be sent*/  
    global void finish(Database.BatchableContext BC){
    System.debug('-------------------------********* INSIDE FINAL METHOD *********-----------------------------');
    Integer batchSize = 20;
    Integer expectCQRCount;
  
          System.debug('------------------Run Batch Job2--------------------');
          //To Schedule batch Job 2 on same day
          DateTime n = datetime.now().addMinutes(2);
          String cron = '';
          cron += n.second();
          cron += ' ' + n.minute();
          cron += ' ' + n.hour();
          cron += ' ' + n.day();
          cron += ' ' + n.month();
          cron += ' ' + '?';
          cron += ' ' + n.year();
          
          String jobName = 'Batch Job To Assign CQR - ' + n.format('MM-dd-yyyy-hh:');
         // To schedule Batch Job 2
        // if(!Test.isRunningTest()){
             AP_AssignCQRScheduler batchSch = new AP_AssignCQRScheduler(js);
             String jobId = System.schedule(jobName,cron,batchSch);
           //  }
        
      
    }//END Method : Finish()
    
  

        
   //Method : To Catch any error log during deletion 
    Public void catchErrorLogs(Database.DeleteResult[] deleteResult) {
     List <EMCException> errors = new List <EMCException>();
     String deleteObjectName = 'Core_Quota_Rep__c';
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
                errors.add(new EMCException(dataErrs, 'ERROR_DELETION_'+deleteObjectName, new String [] {dr.getId()}));
            }
        }
      // log any errors that occurred
       if (errors.size() > 0) { 
            EMC_UTILITY.logErrors(errors);  
       }
  } //End Method catchErrorLog
      
}//End Class