/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  04/02/2011    Prasad Kothawade                  To create Mappings for Eduation and Eduation MAster Group 
 |  09/02/2011    Anand Sharma                      Added schedulable interfacse to schedule call
 |  21/03/2011    Prasad Kothawade                  Added fix for Run all Job
 |  04/08/2011    Suman B                           Added Custom settings for retreving the Batchsize.
 |  26/08/2011    Suman B                           Updating the CustomSetting value for 'PRMVPPDeleteJobExecutionVelocityRule' 
 |                                                  before Scheduling DeleteJob in finish() method.
 |  08/09/2011    Suman B                           Updated the execute() schedulabe method to include batch processing 
 |                                                  based on Theater.   
 |  /09/2011      Suman B                           Modified the execute() schedulabe method to run for multiple Theaters.  
   21/11/2011     Prasad K                          Sequentail Logic Added   
 |                                                                                      
 +=====================================================================================================================*/

global class PRM_VPP_EducationEduationMasterGroupJob extends SequencialBatchJobScheduler {
    
    // Data members
    global final String Query;    
   
    //Used to store the data mapping for the education master using the custom setting.
    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
    
    /* constructor */
    global PRM_VPP_EducationEduationMasterGroupJob(){ 
                             
        String ruleResultQuery = 'Select e.Batch_Job_Operation__c, e.Id,Education_Master__c '
                               + 'from Education__c e '
                               + 'where Batch_Job_Operation__c!=null' ;
        
        System.Debug('ruleResultQuery ###' + ruleResultQuery); 
        this.Query = ruleResultQuery ;
        
        
    }
    
    global PRM_VPP_EducationEduationMasterGroupJob(String Query){                  
        System.Debug('ruleResultQuery ###' + Query);  
        this.Query = Query ;    
    }
   
    /*create batch of records which is passed to execute method for processing */
    global override Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    } 
    
    /* List of passed Educations scope. */
    global override void execute(Database.BatchableContext BC, List<SObject> scope){
        System.debug('scope' +scope);
        List<Education__c> listEducations = (List<Education__c>) scope;
        
        List<ID> listEducationIDs = new List<ID>();
        
        // clear the bath job field 
        for( Education__c edu :listEducations){
            listEducationIDs.add(edu.Id);
            edu.Batch_Job_Operation__c='';
            
        }
        
        // call delete existing eduation mappings
        PRM_VPP_VelocityRuleResultsUtils.deleteEducationAndEducationGroupMapping(listEducationIDs);
        
        // create new education mappings
        PRM_VPP_VelocityRuleResultsUtils.createEducationAndEducationGroupMapping(listEducations);
        
        // update eduations
        database.update(listEducations);
         PRM_JobFactory.loglimits('PRM_VPP_EducationEduationMasterGroupJob');  
    }

   /* global void finish(Database.BatchableContext BC){       
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
        System.debug('PRM_VPP_EducationEduationMasterGroupJob --- finish()#####' ); 
        String DeleteVelocityRuleResultsQuery='select Id from Velocity_Rule_Results__c where createddate <'+ new PRM_CommonUtils().getQueryFormattedDate(System.now());
        
        CustomSettingDataValueMap__c jobObjectDetails = DataValueMap.get('PRMVPPALLJobExecution');
        CustomSettingDataValueMap__c jobVelocityRuleCheckDetails = DataValueMap.get('PRMVPPDeleteJobExecutionVelocityRule');
        if(jobObjectDetails.DataValue__c=='true'){
            jobVelocityRuleCheckDetails.DataValue__c ='true';
            update jobVelocityRuleCheckDetails;
            
            PRM_VPP_DeleteRecordsJob  objSchedule= new PRM_VPP_DeleteRecordsJob(DeleteVelocityRuleResultsQuery);
            Id ScheduleBatchEducationEducMasterGroupId = System.schedule('Schedule Delete Velocity rule result Batch',scheduleString , objSchedule);
        }else{
            jobVelocityRuleCheckDetails.DataValue__c ='false';
            update jobVelocityRuleCheckDetails;
            system.debug('Setting PRMVPPJobRunning to false') ;
            CustomSettingDataValueMap__c PRMVPPJobRunning = DataValueMap.get('PRMVPPJobRunning');
            PRMVPPJobRunning.DataValue__c = 'false' ;
            update PRMVPPJobRunning ;
            
        }
        system.debug('jobVelocityRuleCheckDetails ------' +jobVelocityRuleCheckDetails);
                 
    }  */
   
    /* this method used to schedule class */
     //Execute batch class with default constructor from schedular
   /*  global void execute(SchedulableContext sc) {
        Integer batchSize = 20; // this will be overwritten in try block
        try
         {            
            batchSize  = Integer.valueOf(DataValueMap.get('EducationMasterGroupBatchSize').DataValue__c);
         }
        catch(Exception e)
        {
            batchSize = 20;
        }                
        try {
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null) {
                System.abortJob(ct.Id);
            }
        } catch (Exception e) {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
        }
        
        // added by prasad fix for run all job
        CustomSettingDataValueMap__c jobObjectDetails = DataValueMap.get('PRMVPPALLJobExecution');
        if(jobObjectDetails.DataValue__c=='true'){
           /** Added Logic for running jobs based on Theater     
           String ruleResultQuery ;
           CustomSettingDataValueMap__c jobObjectTheater      = DataValueMap.get('RunAllJobs_Theater');
           CustomSettingDataValueMap__c jobObjectEval_Theater = DataValueMap.get('RunAllJobsEval_Theater');
            
          if(jobObjectEval_Theater.DataValue__c == 'true' && jobObjectTheater.DataValue__c != Null && jobObjectTheater.DataValue__c != ''){
            String theater = jobObjectTheater.DataValue__c ;
            system.debug('Theater ## '+ theater) ;
            ruleResultQuery = 'Select e.Batch_Job_Operation__c, e.Id,Education_Master__c '
                           + 'FROM Education__c e WHERE Theater__c IN ( '+ theater + ' )';                          
          } 
          else{    
            ruleResultQuery = 'Select e.Batch_Job_Operation__c, e.Id,Education_Master__c '
                           + 'FROM Education__c e ';
          }                                                                                                   
            PRM_VPP_EducationEduationMasterGroupJob  objEduMasterJob= new PRM_VPP_EducationEduationMasterGroupJob(ruleResultQuery);
            database.executebatch(objEduMasterJob, batchSize);
        }else{
             database.executebatch(new PRM_VPP_EducationEduationMasterGroupJob(), batchSize);
        }
        
   } */
    
}