/*=================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  27/06/2011    Suman B                      Test class for Delete staging data  
 +================================================================================*/

@isTest
private class PRM_ScheduleBatchDeleteStaging_Manual_TC {
  static testMethod void myUnitTest() {
      Test.StartTest();      
	    // run batch 
	    String strScheduleTime ='0 0 0 3 9 ? ';
	    strScheduleTime = strScheduleTime + Datetime.now().addYears(2).year();
	    String jobId = System.schedule('testBasicScheduledApex',strScheduleTime, 
	    								new PRM_ScheduleBatchDeleteStaging_Manually());
	      
	    Test.StopTest();
    }
}