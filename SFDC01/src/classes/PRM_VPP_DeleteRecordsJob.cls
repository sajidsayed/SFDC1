/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  09/02/2011    Prasad Kothawade                  To Delete records |
 |  13/09/2011    Suman B                 3735      Added logic to run batch job based on Theater specific records.
    21/11/2011    Prasad                            Added logic for sequence
    17/10/2012   Krishna Pydavula         197607    Added code snippet to send an email
    15/11/2012    vivek kodi             197607     To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.
 +=======================================================================================================*/

global class PRM_VPP_DeleteRecordsJob extends SequencialBatchJobScheduler  {
        
    // Data members
    global final String Query;       
    
    //Used to store the data mapping for the education master using the custom setting.
    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
    /* constructor */
       
    global PRM_VPP_DeleteRecordsJob(String Query){    
        System.Debug('INSIDE PARAM CONSTRUCTOR  -- PRM_VPP_DeleteRecordsJob ###' + Query);              
        System.Debug('ruleResultQuery ###' + Query);  
        this.Query = Query ;
        
            
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
        System.debug('scope' +scope);
         List <EMCException> errors = new List <EMCException>(); 
         String Batchid = BC.getJobid();   
        // delete reocrds
        //database.delete(scope);
       Database.DeleteResult[] results = database.delete(scope,false);       
       
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
		                errors.add(new EMCException(dataErrs, Batchid , new String [] {sr.getId()}));
		            }
		        }		        
		      // log any errors that occurred
		       if (errors.size() > 0) { 
		            EMC_UTILITY.logErrors(errors);  
		            emailerrors.addall(errors);
		            system.debug('emailerrorsemailerrors'+emailerrors);
		        }	
        
    }

   /* global void finish(Database.BatchableContext BC){  
        System.debug('PRM_VPP_DeleteRecordsJob --- finish()#####' );             
        //Schedule the next batch job to run for 1 minutes later:
        Datetime dt = System.now();
        dt = dt.addMinutes(1);
        String scheduleString='0';//0 seconds
        scheduleString+=' '+ dt.minute();
        scheduleString+=' '+ dt.hour();
        scheduleString+=' '+ dt.day();
        scheduleString+=' '+ dt.month();
        scheduleString+=' ?';
        scheduleString+=' '+ dt.year();     
        System.debug('currently scheduled time for VelocityRulecreate  ' + scheduleString); 
        
        CustomSettingDataValueMap__c jobPRMVPPALLJobExecution = DataValueMap.get('PRMVPPALLJobExecution');
        CustomSettingDataValueMap__c jobVelocityRuleCheckDetails = DataValueMap.get('PRMVPPDeleteJobExecutionVelocityRule');
        
        if(jobPRMVPPALLJobExecution.DataValue__c=='true'){
            if(jobVelocityRuleCheckDetails.DataValue__c=='true'){
                String ruleResultQuery = 'Select Id, Grouping__c,Batch_Job_Operation__c,Specialty_Rule_Type__c,Cluster__c '
                               + 'from Account e where profiled_Account_flag__c=true and Grouping__c!=null';                                    

                PRM_VPP_VelocityRuleResultJob1  objSchedule= new PRM_VPP_VelocityRuleResultJob1(ruleResultQuery);
                Id ScheduleBatchEducationId = System.schedule('Schedule Create Velocity Rule Batch',scheduleString , objSchedule);
                
                jobVelocityRuleCheckDetails.DataValue__c ='false';
                 
            }else{
                String ruleResultQuery = 'Select e.Batch_Job_Operation__c, e.Id,Education_Master__c '
                                   + 'from Education__c e ';                                                                           

                PRM_VPP_EducationEduationMasterGroupJob  objSchedule= new PRM_VPP_EducationEduationMasterGroupJob(ruleResultQuery);
                Id ScheduleBatchEducationEducMasterGroupId = System.schedule('Schedule Education Master Group Batch',scheduleString , objSchedule);
                
                jobVelocityRuleCheckDetails.DataValue__c ='true';           
            }
            
            update jobVelocityRuleCheckDetails;         
        }
        else{
            system.debug('Setting PRMVPPJobRunning to false -- END') ;
            CustomSettingDataValueMap__c PRMVPPJobRunning = DataValueMap.get('PRMVPPJobRunning');
            PRMVPPJobRunning.DataValue__c = 'false' ;
            update PRMVPPJobRunning ;
        }               
    } 
    */
    
     /* this method used to schedule class */
     //Execute batch class with default constructor from schedular
   /* global void execute(SchedulableContext sc) {
        system.debug('########## SchedulableContext --PRM_VPP_DeleteRecordsJob ') ;         
        Integer batchSize = 200; // this will be overwritten in try block
        try {
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null) {
                System.abortJob(ct.Id);
            }
        } catch (Exception e) {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
        } 
        
        CustomSettingDataValueMap__c jobVelocityRuleCheckDetails = DataValueMap.get('PRMVPPDeleteJobExecutionVelocityRule');
        system.debug('########## PRM_VPP_DeleteRecordsJob -- DeleteJobDetails'+ jobVelocityRuleCheckDetails) ;
        String DeleteResultsQuery = '';
        if(jobVelocityRuleCheckDetails.DataValue__c=='true'){
           /** Added for execute batch based on Theater 
           CustomSettingDataValueMap__c jobObjectTheater      = DataValueMap.get('RunAllJobs_Theater');
           CustomSettingDataValueMap__c jobObjectEval_Theater = DataValueMap.get('RunAllJobsEval_Theater');
            
          if(jobObjectEval_Theater.DataValue__c == 'true' && jobObjectTheater.DataValue__c != Null && jobObjectTheater.DataValue__c != ''){
            system.debug('Inside execute PRM_VPP_DeleteRecordsJob - Theater ####### '); 
            String theater = jobObjectTheater.DataValue__c ;
            system.debug('Theater ## '+ theater) ;
            DeleteResultsQuery ='select Id from Velocity_Rule_Results__c where createddate <'+ new PRM_CommonUtils().getQueryFormattedDate(System.now()) + 'AND'                    
                               + ' Account_Theater__c IN ( '+ theater +' )';         
          }
          else{
               DeleteResultsQuery ='select Id from Velocity_Rule_Results__c where createddate <'+ new PRM_CommonUtils().getQueryFormattedDate(System.now());            
          }
        }
        else{
           DeleteResultsQuery ='select Id from Education_EducationGroup_Mapping__c where createddate <'+ new PRM_CommonUtils().getQueryFormattedDate(System.now()) ;
        }
        
        id batchinstanceid = database.executeBatch(new PRM_VPP_DeleteRecordsJob(DeleteResultsQuery),batchSize); 
   }    */
}