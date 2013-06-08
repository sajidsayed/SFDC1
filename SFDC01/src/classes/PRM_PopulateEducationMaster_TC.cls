/*=======================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  21/12/2010    Karthik                           Unit Test for Eduation Master Batch and Schedular class 
 |  28/11/2012    Krishna pydavula       197607     Added batch id for populateEducationMaster method   
 +=======================================================================================================*/
@isTest
private class PRM_PopulateEducationMaster_TC {

     static testMethod void PRM_BatchTest() {
        // TO DO: implement unit test
        
        //Create Staging Data Records
        List<Staging_Data__c> stagingDataList = new List<Staging_Data__c>();
        Staging_Data__c objStagedata = new Staging_Data__c();
        objStagedata.Text1__c = 'A100003Test';
        objStagedata.Text2__c ='ATest1111111';
        objStagedata.Text3__c ='anand.sharma5@emc.com';
        objStagedata.Text4__c ='a0F70000004CljX';
        objStagedata.Text5__c ='1234567';
        objStagedata.Date1__c = System.today();
        objStagedata.Date2__c = System.today();
        objStagedata.is_Header__c = false;
        stagingDataList.add(objStagedata);
        
        Staging_Data__c objStagedata1 = new Staging_Data__c();
        objStagedata1.Text1__c = 'A100004Test';
        objStagedata1.Text2__c ='ATest1111112';
        objStagedata1.Text3__c ='anand.sharma8@emc.com';
        objStagedata1.Text4__c ='a0F70000004CljX';
        objStagedata1.Text5__c ='123456';
        objStagedata1.Date1__c = System.today();
        objStagedata1.Date2__c = System.today();
        objStagedata1.is_Header__c = false;
        stagingDataList.add(objStagedata1);
        insert stagingDataList;
        System.debug('stagingDataList ----> ' + stagingDataList);
        
         string finalquery = 'Select s.Date1__c, s.Date2__c, s.Id, s.Number1__c, s.Object_Name__c, s.Text1__c,'
       +' s.Text2__c, s.Text3__c, s.Text4__c, s.Text5__c , s.Text6__c from Staging_Data__c s'
       + ' where s.Object_Name__c=\'Education Master\'';
        PRM_PopulateEducationMasterBatch objEduMaster = new PRM_PopulateEducationMasterBatch(finalquery);
        Test.StartTest();           
        // run batch 
        Id batchProcessId = Database.executeBatch(objEduMaster);  
        objEduMaster.populateEducationMaster(stagingDataList,batchProcessId);
        Test.StopTest();
    }
    
     static testMethod void PRM_Schedular_Test() {
        //Create Staging Data Records
        List<Staging_Data__c> stagingDataList = new List<Staging_Data__c>();
        Staging_Data__c objStagedata = new Staging_Data__c();
        objStagedata.Text1__c = 'A100003';
        objStagedata.Text2__c ='ABtest1111111';
        objStagedata.Text3__c ='anand.sharma5@emc.com';
        objStagedata.Text4__c ='a0F70000004CljX';
        objStagedata.Text5__c ='123456';
        objStagedata.Date1__c = System.today();
        objStagedata.Date2__c = System.today();
        objStagedata.is_Header__c = false;
        stagingDataList.add(objStagedata);
        
        Staging_Data__c objStagedata1 = new Staging_Data__c();
        objStagedata1.Text1__c = 'A100004';
        objStagedata1.Text2__c ='ABtest1111112';
        objStagedata1.Text3__c ='anand.sharma8@emc.com';
        objStagedata1.Text4__c ='a0F70000004CljX';
        objStagedata1.Text5__c ='123456';
        objStagedata1.Date1__c = System.today();
        objStagedata1.Date2__c = System.today();
        objStagedata1.is_Header__c = false;
        stagingDataList.add(objStagedata1);
        insert stagingDataList;
        
        Test.StartTest();           
        // run batch 
        String strScheduleTime ='0 0 0 3 9 ? ';
        strScheduleTime = strScheduleTime + Datetime.now().addYears(1).year();
        String jobId = System.schedule('testBasicScheduledApex',strScheduleTime, new PRM_PopulateEducationMasterScheduler());
        Test.StopTest();
     }
}