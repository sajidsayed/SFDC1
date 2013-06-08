/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  25/03/2011    Suman B                      		Unit Test for PRM_VPP_VelocityRuleResultJob1 class
 |  28/03/2011	  Anand Sharma						Created account record data in test class  
 |  06/12/2011	  Anand Sharma						Update test class according to new theater
 |  06/12/2011	  Anil								Used Custom Setting Data Halper
 |  17/05/2012	  Kaustav							Increased the code coverage
 +=======================================================================================================*/
@isTest
private class PRM_VPP_VelocityRuleResultJob1_TC {

    static testMethod void PRM_VPP_VelocityRuleResultJob1_Test() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
      		PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        // Creation of Account Grouping record.
	    Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp');
	    insert grouping;
	    
	    // Creation of Account record.  
	    Account objAccount =  new Account (Name = 'UNITTESTAcc', Country_Local__c = 'Japan',cluster__C = 'APJ',Specialty_Rule_Type__c='APJ', Grouping__c = grouping.Id, Batch_Job_Operation__c = 'Clustor/Theather Updated', profiled_Account_flag__c=true);
	    insert objAccount;
	    
	    Account objAccount1 =  new Account (Name = 'UNITTESTAcc1', Country_Local__c = 'Japan',cluster__C = 'APJ',Specialty_Rule_Type__c='APJ', Grouping__c = grouping.Id, Batch_Job_Operation__c = 'New Profiled Account', profiled_Account_flag__c=true);
	    insert objAccount1;
	    
	    Account objAccount2 =  new Account (Name = 'UNITTESTAcc2', Country_Local__c = 'Japan',cluster__C = 'APJ',Specialty_Rule_Type__c='APJ', Grouping__c = grouping.Id, Batch_Job_Operation__c = 'Porifled Account Unchecked', profiled_Account_flag__c=true);
	    insert objAccount2;
	    /**/
	           
        Test.StartTest();           

        // run batch 
       String ruleResultQuery = 'Select Id, Grouping__c,Velocity_Solution_Provider_Tier__c,Batch_Job_Operation__c,Specialty_Rule_Type__c,Cluster__c '
                               + 'from Account e '
                               + 'where Batch_Job_Operation__c!=null Limit 5' ;
        Id batchProcessId = Database.executeBatch(new PRM_VPP_VelocityRuleResultJob1(ruleResultQuery));  
        Id batchProcessId1 = Database.executeBatch(new PRM_VPP_VelocityRuleResultJob1());
        
        Test.StopTest();
    }
    
   static testMethod void PRM_VPP_VelocityRuleResultJob1Scheduler_Test() {
   	 	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
      		PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        
        // Creation of Account Grouping record.
	    Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp');
	    insert grouping;
	      
	    // Creation of Account record.  
	    Account objAccount =  new Account (Name = 'UNITTESTAcc', Country_Local__c = 'Japan',cluster__C = 'APJ',Specialty_Rule_Type__c='APJ', Grouping__c = grouping.Id, Batch_Job_Operation__c = 'Clustor/Theather Updated', profiled_Account_flag__c=true);
	    insert objAccount;
	    
        Test.StartTest();           
        // run batch 
        String strScheduleTime ='0 0 0 3 9 ? ';
        strScheduleTime = strScheduleTime + Datetime.now().addYears(1).year();
        String ruleResultQuery = 'Select Id, Grouping__c,Velocity_Solution_Provider_Tier__c,Batch_Job_Operation__c,Specialty_Rule_Type__c,Cluster__c '
                               + 'from Account e '
                               + 'where Batch_Job_Operation__c!=null Limit 5' ;

        //String jobId = System.schedule('testBasicScheduledApex',strScheduleTime, new PRM_VPP_VelocityRuleResultJob1());
        List<SequencialBatchJob>LstSeqJobs = new List<SequencialBatchJob>(); 
        PRM_VPP_VelocityRuleResultJob1  job1= new PRM_VPP_VelocityRuleResultJob1();       
        LstSeqJobs.add(new SequencialBatchJob('PRM_VPP_VelocityRuleResultJob1' ,job1,20));   
        SequencialBatchJob seqBatchJob=new SequencialBatchJob('PRM_VPP_VelocityRuleResultJob1' ,job1);
        seqBatchJob.setStatus('testing method');
        SequencialBatchJobScheduler seqBatchJobSchedulerObj=new SequencialBatchJobScheduler();
        seqBatchJobSchedulerObj.addSequencialBatchjob(seqBatchJob);
        seqBatchJobSchedulerObj.addSequencialBatchjob(seqBatchJob);
        seqBatchJobSchedulerObj.getPreviousSequencialBatchjob();
        System.debug('#### seqBatchJobSchedulerObj.getPreviousSequencialBatchjob()'+seqBatchJobSchedulerObj.getPreviousSequencialBatchjob());
        System.debug('#### seqBatchJobSchedulerObj.getNextSequencialBatchjob()'+seqBatchJobSchedulerObj.getNextSequencialBatchjob());
        SequencialBatchJobScheduler.executeSequence(LstSeqJobs);
        Test.StopTest();
    }
}