/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  14/02/2011    Anand Sharma                      To create batch and schedulable interfacse to schedule call
 |  14/04/2011    Anand Sharma                      Req# 02761: Added batch size into custom setting.
 |  06/09/2011    Suman B                 3735      Added condition check in the execute() schedulabe and finish() methods
                                                     for running jobs based on Account Theaters.                               
 |  13/09/2011    Suman B                 3735      Updated the execute() schedulable method to run for multiple Theaters.
    21/11/2011    Prasad                            Sequential Batch Logic 
    10/17/2012    Krishna Pydavula       197607     Added code snippet to send an email
    15/11/2012    vivek kodi             197607     To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.  
 +=======================================================================================================*/

global class PRM_VPP_RollupRuleEvaluatorJob extends SequencialBatchJobScheduler {
    
    // Data members
    global final String Query; 

    /* constructor */
    global PRM_VPP_RollupRuleEvaluatorJob(){ 
                             
        String ruleResultQuery = 'Select a.PROFILED_ACCOUNT_FLAG__c, a.Name, Theater1__c, a.Id, a.Grouping__c,  '
                               +' Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c, '
                               +' Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c,Velocity_Compliance_Status__c '
                               + ' From Account a where profiled_Account_flag__c = true and Grouping__c != null' ;
        
        System.Debug('RollupRuleEvaluatorQuery ###' + ruleResultQuery); 
        this.Query = ruleResultQuery ;
        
        
    }
    
    global PRM_VPP_RollupRuleEvaluatorJob(String Query){                  
        System.Debug('RollupRuleEvaluatorQuery ###' + Query);  
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
    global override  void execute(Database.BatchableContext BC, List<SObject> scope){
        List<Account > listAccountResults = (List<Account>) scope;
         String Batchid = BC.getjobid();
        PRM_VPP_RuleEvaluator objRuleEvaluator = new PRM_VPP_RuleEvaluator(listAccountResults);
        //objRuleEvaluator.evaluateRollupRules(listAccountResults);
         objRuleEvaluator.evaluateRollupRuleswitherrors(listAccountResults,Batchid,emailerrors);
        PRM_JobFactory.loglimits('PRM_VPP_RollupRuleEvaluatorJob'); 
    }
    
   /* global void finish(Database.BatchableContext BC){ 
      /** Resetting the CustomSetting values for RunAllJobs Theater  
      Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
      List<CustomSettingDataValueMap__c> customSettingsData = new List<CustomSettingDataValueMap__c>();
      CustomSettingDataValueMap__c jobObjectTheater = DataValueMap.get('RunAllJobs_Theater');
       jobObjectTheater.DataValue__c = null ;
       customSettingsData.add(jobObjectTheater);
      
      CustomSettingDataValueMap__c jobObjectEval_Theater = DataValueMap.get('RunAllJobsEval_Theater');
       jobObjectEval_Theater.DataValue__c = 'false' ;
       customSettingsData.add(jobObjectEval_Theater);

      CustomSettingDataValueMap__c PRMVPPJobRunning = DataValueMap.get('PRMVPPJobRunning');
       PRMVPPJobRunning.DataValue__c = 'false' ;
       customSettingsData.add(PRMVPPJobRunning);
      
      update customSettingsData ; 
    }
    */
     //Execute batch class with default constructor from schedular
  /*  global void execute(SchedulableContext sc) {
                
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
        
        //Used to store the data mapping for the education master using the custom setting.
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        
        try
        {            
            batchSize  = Integer.valueOf(DataValueMap.get('RollupEvaluationBatchSize').DataValue__c);
        }
        catch(Exception e)
        {
            batchSize = 200;
        } 
        /** Added for execute batch based on Theater 
        CustomSettingDataValueMap__c jobObjectTheater      = DataValueMap.get('RunAllJobs_Theater');
        CustomSettingDataValueMap__c jobObjectEval_Theater = DataValueMap.get('RunAllJobsEval_Theater');
 
        if(jobObjectEval_Theater.DataValue__c == 'true' && jobObjectTheater.DataValue__c != Null && jobObjectTheater.DataValue__c != ''){
          system.debug('Inside execute PRM_VPP_RollupRuleEvaluatorJob - Theater ####### '); 
          String theater = jobObjectTheater.DataValue__c ;
          system.debug('Theater ## '+ theater) ;
          String ruleEvaluatorQuery = 'Select a.PROFILED_ACCOUNT_FLAG__c, a.Name, Theater1__c, a.Id, a.Grouping__c,  '
                                       +' Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c, '
                                       +' Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c,Velocity_Compliance_Status__c '
                                       +' From Account a where profiled_Account_flag__c = true and Grouping__c != null and ' 
                                       +' Theater1__c IN ( '+ theater + ' )' ;
            
         database.executebatch(new PRM_VPP_RollupRuleEvaluatorJob(ruleEvaluatorQuery), batchSize);                              
        }
        else {          
        database.executebatch(new PRM_VPP_RollupRuleEvaluatorJob(), batchSize);
        }
   } */
}