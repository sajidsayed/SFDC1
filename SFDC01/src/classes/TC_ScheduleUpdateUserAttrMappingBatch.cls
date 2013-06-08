/*=============================================================================
	HISTORY                                                                  
                                                               
	DATE          	DEVELOPER                WR       		DESCRIPTION                               
	====          	=========                ==       		=========== 
	06-Sep-2010		Pratibh Prakash			136350			Test class for Scheduler class ScheduleUpdateUserAttrMappingBatch.
	05-Jan-2011     Srinivas Nallapati						Removed year (2010) from the cron expression paremeter of the System.Schedule method call
==============================================================================*/
@isTest
private class TC_ScheduleUpdateUserAttrMappingBatch {

    static testMethod void testScheduleUpdateUserAttrMappingBatch() {
        Test.startTest();
	    String jobId = System.schedule('Test','0 0 20 * * ?',new ScheduleUpdateUserAttrMappingBatch());
	    // Get the information from the CronTrigger API object
	    CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
	    FROM CronTrigger WHERE id = :jobId];
	    // Verify the job has not run
	    System.assertEquals(0, ct.TimesTriggered);
	    Test.stopTest();
    }
}