/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  17/12/2010    Anand Sharma                      Unit Test for PRM_BatchDeleteEducation class
 |  26/09/2011    Suman B							Added Test method for running based on Theater. 
 |  06/12/2011	  Anand Sharma						Update test class according to new theater  
 +=======================================================================================================*/
@isTest
private class PRM_VPP_DeleteRecordsJob_TC {

    static testMethod void PRM_VPP_DeleteRecordsJob_Test() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
      		PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Education__c objEducation = new Education__c();
        objEducation.Education_ID__c ='1234567';
        objEducation.Training_ID__c ='ABC123456';        
        insert objEducation;
   
       Education_EducationGroup_Mapping__c em = new 
                               Education_EducationGroup_Mapping__c();
         em.Education__c = objEducation.id;
         insert em;
        Test.StartTest();           
        // run batch 
     String DeleteResultsQuery ='select Id from Education_EducationGroup_Mapping__c Limit 5 ';                      
        Id batchProcessId = Database.executeBatch(new PRM_VPP_DeleteRecordsJob(DeleteResultsQuery));  
        Test.StopTest();
    }
    
    static testMethod void PRM_VPP_DeleteRecordsJobScheduler_Test() {
    	 User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
	        System.runAs(insertUser)
	        {
	      		PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
	        }
        Education__c objEducation = new Education__c();
        objEducation.Education_ID__c ='1234567';
        objEducation.Training_ID__c ='ABC123456';        
        insert objEducation;

       Education_EducationGroup_Mapping__c em = new 
                               Education_EducationGroup_Mapping__c();
         em.Education__c = objEducation.id;
         insert em;
        
        Test.StartTest();           
        // run batch 
        String strScheduleTime ='0 0 0 3 9 ? ';
        strScheduleTime = strScheduleTime + Datetime.now().addYears(1).year();
        String DeleteResultsQuery ='select Id from Education_EducationGroup_Mapping__c Limit 5 ';                      
        //String jobId = System.schedule('testBasicScheduledApex',strScheduleTime, new PRM_VPP_DeleteRecordsJob(DeleteResultsQuery));
        
        List<SequencialBatchJob>LstSeqJobs = new List<SequencialBatchJob>(); 
        PRM_VPP_DeleteRecordsJob  job1= new PRM_VPP_DeleteRecordsJob(DeleteResultsQuery);       
        LstSeqJobs.add(new SequencialBatchJob('PRM_VPP_DeleteRecordsJob' ,job1,20));       
        SequencialBatchJobScheduler.executeSequence(LstSeqJobs); 
            
        Test.StopTest();
    }
    
     static testMethod void PRM_VPP_DeleteRecordsJobTheater_Test() {
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
        String DeleteResultsQuery ='select Id from Education_EducationGroup_Mapping__c Limit 5 ';                      
        //String jobId = System.schedule('testBasicScheduledApex',strScheduleTime, new PRM_VPP_DeleteRecordsJob(DeleteResultsQuery));
        
        List<SequencialBatchJob>LstSeqJobs = new List<SequencialBatchJob>(); 
        PRM_VPP_DeleteRecordsJob  job1= new PRM_VPP_DeleteRecordsJob(DeleteResultsQuery);       
        LstSeqJobs.add(new SequencialBatchJob('PRM_VPP_DeleteRecordsJob' ,job1,20));       
        SequencialBatchJobScheduler.executeSequence(LstSeqJobs);     
        
        Test.StopTest();
    }    
}