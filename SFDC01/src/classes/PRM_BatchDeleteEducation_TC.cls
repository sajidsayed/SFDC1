/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  17/12/2010    Anand Sharma                      Unit Test for PRM_BatchDeleteEducation class 
 |  28/03/2011	  Anand Sharma						Created custom setting value through test class 
 |  06/12/2011	  Anand Sharma						Update test class according to new theater 
 +=======================================================================================================*/
@isTest
private class PRM_BatchDeleteEducation_TC {

    static testMethod void PRM_BatchDeleteEducation_Test() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
      	PRM_VPP_JobDataHelper.createVPPCustomSettingData();        
    	List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
    	CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
    	dataValueControlFlag.Name ='ESBI_Int_Control_Flag_Sequence';
    	dataValueControlFlag.DataValue__c ='2';
    	lstDataValue.add(dataValueControlFlag);
    	try
        {
           Database.insert(lstDataValue, false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }
        }    	
    	
        Education__c objEducation = new Education__c();
        objEducation.Education_ID__c ='1234567';
        objEducation.Training_ID__c ='ABC123456'; 
        objEducation.Education_Batch_Number__c = 1;       
        insert objEducation;
        
        Test.StartTest();           
        // run batch 
        String educationQuery = 'Select Id, Name from Education__c order by createddate DESC limit 10 ' ;  
        Id batchProcessId = Database.executeBatch(new PRM_BatchDeleteEducation(educationQuery));  
        Test.StopTest();
    }
    
    static testMethod void PRM_BatchDeleteEducationSchedular_Test() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();  
        List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
    	CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
    	dataValueControlFlag.Name ='ESBI_Int_Control_Flag_Sequence';
    	dataValueControlFlag.DataValue__c ='2';
    	lstDataValue.add(dataValueControlFlag);
    	try
        {
           Database.insert(lstDataValue, false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }
        }
    	
        Education__c objEducation = new Education__c();
        objEducation.Education_ID__c ='1234567';
        objEducation.Training_ID__c ='ABC123456'; 
        objEducation.Education_Batch_Number__c = 1;       
        insert objEducation;
        
        Test.StartTest();           
        // run batch 
        String strScheduleTime ='0 0 0 3 9 ? ';
        strScheduleTime = strScheduleTime + Datetime.now().addYears(1).year();
      	//  String educationQuery = 'Select Id, Name from Education__c order by createddate DESC limit 10 ' ;
      	       
        
        List<SequencialBatchJob>LstSeqJobs = new List<SequencialBatchJob>(); 
        String ScheduleNowTime = String.valueOfGmt(DateTime.Now());
        ScheduleNowTime  = ScheduleNowTime.replace(' ', 'T');
        ScheduleNowTime = ScheduleNowTime +'.000Z';

		Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c jobDeleteEducationTime = DataValueMap.get('EducationDeleteScheduleTime');
        String strSchedule =jobDeleteEducationTime.DataValue__c;
        String theater ='APJ';
        String educationQuery = 'Select Id, Name from Education__c where Theater__c  =\''+ theater +'\' AND  lastModifieddate < ' + ScheduleNowTime ;                                    
        PRM_BatchDeleteEducation  job3= new PRM_BatchDeleteEducation(educationQuery);
        PRM_BatchDeleteEducation  job2= new PRM_BatchDeleteEducation();
        LstSeqJobs.add(new SequencialBatchJob('PRM_BatchDeleteEducation  for '+theater ,job3,20));
        LstSeqJobs.add(new SequencialBatchJob('PRM_BatchDeleteEducation  for '+theater ,job2,20));
        SequencialBatchJobScheduler.executeSequence(LstSeqJobs);        
            
        Test.StopTest();
    }
}