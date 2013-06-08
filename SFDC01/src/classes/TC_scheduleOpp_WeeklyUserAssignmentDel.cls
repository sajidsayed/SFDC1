/*
Description	: Test class for scheduleOpp_WeeklyUserAssignmentDelete
Author		: Pratibh Prakash
Created Date: 18-Aug-2010
Modified	:
05-Jan-2011     Srinivas Nallapati						Removed year (2010) from the cron expression paremeter of the System.Schedule method call	
*/
@isTest
private class TC_scheduleOpp_WeeklyUserAssignmentDel {

    private static testmethod void testScheduleOpp_WeeklyUserAssignmentDel() {
	    Test.startTest();
	    String jobId = System.schedule('Test',
	    //'0 0 3 0 9 ? 2022', new scheduleOpportunityVisibility ());
	    '0 0 20 * * ?',new scheduleOpp_WeeklyUserAssignmentDelete());
	    // Get the information from the CronTrigger API object
	    CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
	    FROM CronTrigger WHERE id = :jobId];
	    // Verify the job has not run
	    System.assertEquals(0, ct.TimesTriggered);
	    // Verify the next time the job will run
	    //System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
	    Test.stopTest();
	}
}