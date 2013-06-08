/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  06.05.2012      Anand Sharma                This will used for unit testing of PRM_ESBI_VPP_Jobs_Scheduler Class.
 ========================================================================================================================*/
@isTest
private class PRM_ESBI_VPP_Jobs_Scheduler_TC {

    static testMethod void myUnitTest() {
         User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];    
         System.runAs(insertUser){
           PRM_VPP_JobDataHelper.createVPPCustomSettingData();
         }
        // TO DO: implement unit test
        Test.StartTest();      
        // run batch 
        String strScheduleTime ='0 0 0 3 9 ? ';
        strScheduleTime = strScheduleTime + Datetime.now().addYears(1).year();
        String jobId = System.schedule('testBasicScheduledApex',strScheduleTime, new PRM_ESBI_VPP_Jobs_Scheduler());
          
        Test.StopTest();
    }
}