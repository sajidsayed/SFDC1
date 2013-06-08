/*=======================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  24/03/2011    Suman B            				Unit Test for PRM_BatchDeleteStaging class
 |  28/03/2011	  Anand Sharma						Created custom setting value through test class  
 +=======================================================================================================*/

@isTest
private class PRM_BatchDeleteStaging_TC {

 static testMethod void PRM_BatchDeleteStaging_Test() {
        Staging_data__c objstaging = new Staging_data__c();
        objstaging.Object_Name__c ='Education';
        objstaging.Batch_Id__c = 1224;        
        insert objstaging;
        
        List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
    	CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
    	dataValueControlFlag.Name ='ESBI_Int_Control_Flag';
    	dataValueControlFlag.DataValue__c ='START';
    	lstDataValue.add(dataValueControlFlag);
    	try
        {
           Database.insert(lstDataValue, false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }
        
        integer batchid =1224;
   		system.debug('STAGING RECORD'+ objstaging);      
        Test.StartTest();      
	    // run batch 
	     String query = 'Select Id,Batch_Id__c,Object_Name__c from Staging_data__c Limit 5' ;
	
	    Id batchProcessId = Database.executeBatch(new PRM_BatchDeleteStaging(query));  
	    Test.StopTest();
    }
    
 static testMethod void PRM_BatchDeleteStaging_Scheduler_Test() {
        Staging_data__c objstaging = new Staging_data__c();
        objstaging.Object_Name__c ='Education';
        objstaging.Batch_Id__c =1224 ;        
        insert objstaging;
        
        List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
    	CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
    	dataValueControlFlag.Name ='ESBI_Int_Control_Flag';
    	dataValueControlFlag.DataValue__c ='START';
    	lstDataValue.add(dataValueControlFlag);
    	try
        {
           Database.insert(lstDataValue, false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }
        
        Test.StartTest();      
	    // run batch 
	    String strScheduleTime ='0 0 0 3 9 ? ';
	    strScheduleTime = strScheduleTime + Datetime.now().addYears(1).year();
	    String jobId = System.schedule('testBasicScheduledApex',strScheduleTime, new PRM_BatchDeleteStaging());
	      
	    Test.StopTest();
    }



}