/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  04/02/2011    Prasad Kothawade                  To create Velocity rule results
 |  09/02/2011    Anand Sharma                      Added schedulable interfacse to schedule call
                                                    And Schedule "PRM_VPP_VelocityRuleEvaluatorJob" batch
                                                    in finished method.
 |  06/09/2011    Suman B                 3735      Added condition check in the execute() schedulable method
                                                    for  execution based on Theaters.  
 |  13/09/2011    Suman B                 3735      Updated the execute() schedulable method to run for multiple Theaters.   
    21/11/2011    Prasad                            Sequential logic added                
    17/10/2012   Krishna Pydavula         197607    Added code snippet to send an email  
    15/11/2012    vivek kodi              197607    To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.                                                                                         
 +===========================================================================================================================*/



global class PRM_VPP_VelocityRuleResultJob1 extends SequencialBatchJobScheduler {
    
    // Data members
    global final String Query;    
    boolean EvaluateForAll = false;
    public boolean EvaluateForServiceRule = false;
    /* constructor */
    global PRM_VPP_VelocityRuleResultJob1(){ 
                             
        String ruleResultQuery = 'Select Id, Grouping__c,Batch_Job_Operation__c,Specialty_Rule_Type__c,Cluster__c,Velocity_Solution_Provider_Tier__c '
                               + 'from Account e '
                               + 'where Batch_Job_Operation__c!=null ' ;
        
        System.Debug('ruleResultQuery ###' + ruleResultQuery); 
        this.Query = ruleResultQuery ;
        
        
    }
    
    global PRM_VPP_VelocityRuleResultJob1(String Query){                  
        System.Debug('ruleResultQuery ###' + Query);  
        this.Query = Query ;  
        EvaluateForAll =true;  
    }
   
    /*create batch of records which is passed to execute method for processing */
    global override Database.QueryLocator start(Database.BatchableContext BC){
    	 //code added for WR 197607
    	if(BC != null && BC.getJobId() !=null){
	        	batchprocessid=BC.getJobId();
	        	List<EMCException> emailerrors = new List<EMCException>();
                SendEmailNotificationToAllBatchjobs.EmailProcessor(batchprocessid,emailerrors);
                }  
         //End of code for  WR 197607
        return Database.getQueryLocator(query);
    } 
    
    /* List of passed Educations scope. */
    global override void execute(Database.BatchableContext BC, List<SObject> scope){
        List<Account> listAccounts = (List<Account>) scope;
        
        List<ID> listEducationIDs = new List<ID>();
        List <EMCException> errors = new List <EMCException>();
        List<Account> listAccounts_deleteVRR = new List<Account>() ;
        List<Account> listAccounts_createVRR = new List<Account>() ;
        
        
        for( Account acc :listAccounts){
            if(EvaluateForAll){
                listAccounts_createVRR.add(acc);
                continue;
            }
            if(acc.Batch_Job_Operation__c=='New Profiled Account'){
                listAccounts_createVRR.add(acc);
            }else if(acc.Batch_Job_Operation__c=='Clustor/Theather Updated'){
                listAccounts_createVRR.add(acc);
                listAccounts_deleteVRR.add(acc);
                
            }else if(acc.Batch_Job_Operation__c=='Porifled Account Unchecked'){
                listAccounts_deleteVRR.add(acc);
            }
            
            acc.Batch_Job_Operation__c='';
        }
        
       /* Taking out update accounts as not going with acc.Batch_Job_Operation__c  
     // update accounts
        Database.Saveresult[] resultAccounts = Database.update(listAccounts, false);
         if(resultAccounts!= null){
           PRM_VPP_VelocityRuleResultsUtils.logFailedRecords(resultAccounts);
          }          
    
     */         
    
        
         // delete velocity rule results
         System.debug('listAccounts_deleteVRR  '+listAccounts_deleteVRR);
         String Batchid = BC.getjobid();
        if(listAccounts_deleteVRR.size()>0){
            //PRM_VPP_VelocityRuleResultsUtils.deleteVelocityRuleResults(listAccounts_deleteVRR);
           set<Id> setaccountIds = new set<Id>();
		   
		     for(Account acc : listAccounts_deleteVRR) {
		       setaccountIds.add(acc.Id);
		     }
		   List<Velocity_Rule_Results__c> listVRR = [SELECT v.AccountID__c, v.Id 
		                                               FROM Velocity_Rule_Results__c v  
		                                               WHERE AccountID__c IN : setaccountIds];
		    if(listVRR.size() >0){
		        Database.DeleteResult[] results = Database.delete(listVRR);
		        
		         /* HANDLING EXCEPTION LOG*/
		        for (Database.DeleteResult sr : results) {
		            String dataErrs = '';
		            if (!sr.isSuccess()) {
		                // if the particular record did not get updated, we log the data error 
		                for (Database.Error err : sr.getErrors()) {
		                    dataErrs += err.getMessage();
		                }
		                System.debug('An exception occurred while attempting an update on ' + sr.getId());
		                System.debug('ERROR: ' + dataErrs);
		                errors.add(new EMCException(dataErrs, Batchid, new String [] {sr.getId()}));
		            }
		        }		        
		      // log any errors that occurred
		      system.debug('BatchidBatchidvv'+Batchid);
		       if (errors.size() > 0) { 
		            EMC_UTILITY.logErrors(errors);
		            emailerrors.addall(errors);
		            system.debug('emailerrorsemailerrors'+emailerrors);
		        }		  
		        
		        
		     }  
   
        }
        
        // create velocity rule results
        System.debug('listAccounts_createVRR  '+listAccounts_createVRR);        
         //new PRM_VPP_VelocityRuleResults(listAccounts_createVRR,EvaluateForServiceRule ).createVelocityRuleResults();
           new PRM_VPP_VelocityRuleResults(listAccounts_createVRR,EvaluateForServiceRule ).createVelocityRuleResultswitherrors(Batchid,emailerrors);
        
       PRM_JobFactory.loglimits('PRM_VPP_VelocityRuleResultJob1');  
    }

  /*  global void finish(Database.BatchableContext BC){       
        //Schedule the next batch job to run for 2 minutes later:
        Datetime dt = System.now();
        dt = dt.addMinutes(2);
        String scheduleString='0';//0 seconds
        scheduleString+=' '+ dt.minute();
        scheduleString+=' '+ dt.hour();
        scheduleString+=' '+ dt.day();
        scheduleString+=' '+ dt.month();
        scheduleString+=' ?';
        scheduleString+=' '+ dt.year();     
        System.debug('currently scheduled. time for VelocityRuleEvaluator  ' + scheduleString); 
                                    
        PRM_VPP_VelocityRuleEvaluatorJob  objSchedule= new PRM_VPP_VelocityRuleEvaluatorJob();
        Id ScheduleBatchEducationEducMasterGroupId = System.schedule('Schedule VelocityRuleEvaluator Batch',scheduleString , objSchedule);
    }*/  
   
    /* this method used to schedule class */
     //Execute batch class with default constructor from schedular
  /*  global void execute(SchedulableContext sc) {
                
        //Used to store the data mapping for the education master using the custom setting.
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        
        Integer batchSize = 10; // this will be overwritten in try block
        try {
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null) {
                System.abortJob(ct.Id);
            }
        } catch (Exception e) {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
        }
        
        try
        {            
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleResultJob1').DataValue__c);
        }
        catch(Exception e)
        {
            batchSize = 10;
        }

      /** CustomSetting values for RunAllJobs Theater  
      List<CustomSettingDataValueMap__c> customSettingsData = new List<CustomSettingDataValueMap__c>();
        /** Added for execute batch based on Theater 
        CustomSettingDataValueMap__c jobObjectTheater      = DataValueMap.get('RunAllJobs_Theater');
        CustomSettingDataValueMap__c jobObjectEval_Theater = DataValueMap.get('RunAllJobsEval_Theater');
        String ruleResultQuery ;
        if(jobObjectEval_Theater.DataValue__c == 'true' && jobObjectTheater.DataValue__c != Null && jobObjectTheater.DataValue__c != ''){
          system.debug('Inside execute PRM_VPP_VelocityRuleResultJob1 - Theater ####### '); 
          String theater = jobObjectTheater.DataValue__c ;
          system.debug('Theater ## '+ theater) ;
          ruleResultQuery = 'Select Id, Grouping__c,Batch_Job_Operation__c,Specialty_Rule_Type__c,Cluster__c '
                          + 'from Account e where profiled_Account_flag__c=true and Grouping__c!=null and Theater1__c IN ( '+ theater + ' )'; 
        }
        else{        
           ruleResultQuery = 'Select Id, Grouping__c,Batch_Job_Operation__c,Specialty_Rule_Type__c,Cluster__c '
                           + 'from Account e where profiled_Account_flag__c=true and Grouping__c!=null';
        }                             
       id batchinstanceid1 = database.executeBatch(new PRM_VPP_VelocityRuleResultJob1(ruleResultQuery),batchSize); 
   } // End of execute() method.
   
   */
    
}