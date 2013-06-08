/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  25/03/2011    Suman B                      Unit Test for PRM_BatchDeleteEducation class 
 |  01/08/2001    Suman B					   Added assert and record creation through helper class.
 |  26/09/2011    Suman B                      Added Test method for running job based on Theater.	
 +=======================================================================================================*/
@isTest
private class PRM_VPP_Edu_EduationMasterGroupJob_TC {

    static testMethod void PRM_VPP_EducationEduationMasterGroupJob_Test() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
      		PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Education__c objEducation = UserProfileTestClassDataHelper.createEducation();
        insert objEducation;
        
        Test.StartTest();           
        // run batch 
        String educationQuery = 'Select e.Batch_Job_Operation__c, e.Id,Education_Master__c '
                               + 'from Education__c e '
                               + 'where Batch_Job_Operation__c!=null LIMIT 5' ;

        Id batchProcessId = Database.executeBatch(new PRM_VPP_EducationEduationMasterGroupJob(educationQuery));  
        system.assertNotEquals(batchProcessId, null);
        Test.StopTest();
    }
    
    static testMethod void PRM_VPP_Education_EM_Scheduler_Test() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
      		PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Education__c objEducation = UserProfileTestClassDataHelper.createEducation();
        insert objEducation;
        
        Test.StartTest();  
        PRM_VPP_EducationEduationMasterGroupJob  educationGrpJob = new PRM_VPP_EducationEduationMasterGroupJob();         
        // run batch 
        String strScheduleTime ='0 0 0 3 9 ? ';
        strScheduleTime = strScheduleTime + Datetime.now().addYears(1).year();
        String educationQuery = 'Select e.Batch_Job_Operation__c, e.Id,Education_Master__c '
                               + 'from Education__c e '
                               + 'where Batch_Job_Operation__c!=null LIMIT 5' ;

        /*String jobId = System.schedule('testBasicScheduledApex',strScheduleTime, 
                           new PRM_VPP_EducationEduationMasterGroupJob(educationQuery));*/
        
        List<SequencialBatchJob>LstSeqJobs = new List<SequencialBatchJob>(); 
        PRM_VPP_EducationEduationMasterGroupJob  job1= new PRM_VPP_EducationEduationMasterGroupJob(educationQuery);       
        LstSeqJobs.add(new SequencialBatchJob('PRM_VPP_EducationEduationMasterGroupJob' ,job1,20));       
        SequencialBatchJobScheduler.executeSequence(LstSeqJobs);
                           
        Test.StopTest();
    }

    static testMethod void PRM_VPP_Education_EM_Theater_Test() {
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
        String educationQuery = 'Select e.Batch_Job_Operation__c, e.Id,Education_Master__c '
                               + 'from Education__c e '
                               + 'where Batch_Job_Operation__c!=null LIMIT 5' ;
		/*
        String jobId = System.schedule('testBasicScheduledApex',strScheduleTime, 
                           new PRM_VPP_EducationEduationMasterGroupJob(educationQuery));
        */                   
		List<SequencialBatchJob>LstSeqJobs = new List<SequencialBatchJob>(); 
        PRM_VPP_EducationEduationMasterGroupJob  job1= new PRM_VPP_EducationEduationMasterGroupJob(educationQuery);       
        LstSeqJobs.add(new SequencialBatchJob('PRM_VPP_EducationEduationMasterGroupJob' ,job1,20));       
        SequencialBatchJobScheduler.executeSequence(LstSeqJobs);
                                   
        //system.assertNotEquals(jobId, null);            
        Test.StopTest();
    }
    
}