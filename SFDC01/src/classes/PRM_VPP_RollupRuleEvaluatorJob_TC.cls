/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  25/03/2011    Suman B                      		Unit Test for PRM_VPP_RollupRuleEvaluatorJob class 
 |  28/03/2011	  Anand Sharma						Created account record data in test class
 |  26/09/2011	  Suman B							Added Test method for running job based on Theater. 
 |  06/12/2011	  Anand Sharma						Update test class according to new theater
 |  06/12/2011	  Anil								Used Custom Setting Data Halper  
 +=======================================================================================================*/
@isTest
private class PRM_VPP_RollupRuleEvaluatorJob_TC {

    static testMethod void PRM_VPP_RollupRuleEvaluatorJob_Test() {
    	
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
      		PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
    	
    	// Creation of Account Grouping record.
	    Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp');
	    insert grouping;
	      
	    // Creation of Account record.  
	    Account objAccount =  new Account (Name = 'UNITTESTAcc',Advanced_Consolidate_Compliance_Status__c='Not Deployed',
	    									Backup_and_Recovery_Compliance_Status__c='Not Deployed', Consolidate_Compliance_Status__c ='Not Deployed',
	    									Governance_and_Archive_Compliance_Status__c ='Not Deployed',Velocity_Compliance_Status__c='Yes', 
	    									Country_Local__c = 'Japan',cluster__C = 'APJ', Specialty_Rule_Type__c='APJ', Grouping__c = grouping.Id, Batch_Job_Operation__c = 'Clustor/Theather Updated', profiled_Account_flag__c=true);
	    insert objAccount;
    	
     	String ruleResultQuery = 'Select a.PROFILED_ACCOUNT_FLAG__c, a.Name, Theater1__c, a.Id, a.Grouping__c,  '
                               +' Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c, '
                               +' Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c,Velocity_Compliance_Status__c '
                               + ' From Account a where profiled_Account_flag__c = true and Grouping__c != null Limit 5' ;
              
        Test.StartTest();           
        // run batch 

        Id batchProcessId = Database.executeBatch(new PRM_VPP_RollupRuleEvaluatorJob(ruleResultQuery));  
        Test.StopTest();
    }
    
    static testMethod void PRM_VPP_RollupRuleEvaluatorJobScheduler_Test() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
      		PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Test.StartTest();           
        // run batch 
        String strScheduleTime ='0 0 0 3 9 ? ';
        strScheduleTime = strScheduleTime + Datetime.now().addYears(1).year();
  		
        //String jobId = System.schedule('testBasicScheduledApex',strScheduleTime, new PRM_VPP_RollupRuleEvaluatorJob());
        
        List<SequencialBatchJob>LstSeqJobs = new List<SequencialBatchJob>(); 
        PRM_VPP_RollupRuleEvaluatorJob  job1= new PRM_VPP_RollupRuleEvaluatorJob();       
        LstSeqJobs.add(new SequencialBatchJob('PRM_VPP_RollupRuleEvaluatorJob' ,job1,20));       
        SequencialBatchJobScheduler.executeSequence(LstSeqJobs);
            
        Test.StopTest();
    }

    static testMethod void PRM_VPP_RollupRuleEvaluatorTheater_Test() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
      		PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        } 
	    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
	    List<CustomSettingDataValueMap__c> listCustomsettings = new List<CustomSettingDataValueMap__c> (); 
	    CustomSettingDataValueMap__c jobObjectTheater      = DataValueMap.get('RunAllJobs_Theater');
        CustomSettingDataValueMap__c jobObjectEval_Theater = DataValueMap.get('RunAllJobsEval_Theater');
        CustomSettingDataValueMap__c jobVelocityRuleCheckDetails = DataValueMap.get('PRMVPPDeleteJobExecutionVelocityRule');
 	    CustomSettingDataValueMap__c jobPRMVPPALLJobExecution = DataValueMap.get('PRMVPPALLJobExecution');
	    jobObjectTheater.DataValue__c = '\''+ 'APJ'+ '\'';
	    listCustomsettings.add(jobObjectTheater); 
	    jobObjectEval_Theater.DataValue__c = 'true';
	    listCustomsettings.add(jobObjectEval_Theater);
	    jobVelocityRuleCheckDetails.DataValue__c = 'true';
	    listCustomsettings.add(jobVelocityRuleCheckDetails);
	    jobPRMVPPALLJobExecution.DataValue__c = 'true';
		listCustomsettings.add(jobPRMVPPALLJobExecution);
	    update listCustomsettings ;
        
        Test.StartTest();            
        // run batch 
        String strScheduleTime ='0 0 0 3 9 ? ';
        strScheduleTime = strScheduleTime + Datetime.now().addYears(1).year();
  
        //String jobId = System.schedule('testBasicScheduledApex',strScheduleTime, new PRM_VPP_RollupRuleEvaluatorJob());
        List<SequencialBatchJob>LstSeqJobs = new List<SequencialBatchJob>(); 
        PRM_VPP_RollupRuleEvaluatorJob  job1= new PRM_VPP_RollupRuleEvaluatorJob();       
        LstSeqJobs.add(new SequencialBatchJob('PRM_VPP_RollupRuleEvaluatorJob' ,job1,20));       
        SequencialBatchJobScheduler.executeSequence(LstSeqJobs);
            
        Test.StopTest();
    }
    
}