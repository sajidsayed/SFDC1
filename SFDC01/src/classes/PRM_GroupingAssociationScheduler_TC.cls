/*=====================================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 
| 05/07/2010     Suman B                               Test Clsss forPRM_GroupingAssociationScheduler.  
|
+=====================================================================================================*/

@isTest
private class PRM_GroupingAssociationScheduler_TC {
  static testMethod void GroupingAssociationScheduler_test() {
    Test.startTest();
        String strScheduleTime ='0 0 0 3 9 ? ';
        strScheduleTime = strScheduleTime + Datetime.now().addYears(2).year();
        String jobId = System.schedule('PRM_GroupingAssociationScheduler',strScheduleTime, 
                                        new PRM_GroupingAssociationScheduler());
        system.debug('JOB ID ---'+ JobId);
    Test.stopTest();
     
    }
}