/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    04-Apr-2011     Srinivas Nallapati      139074          test class for Schedule_Delete_TA_SYNC_LOG 
                                                            
==============================================================================*/
@isTest
private class TC_Schedule_Delete_TA_SYNC_LOG {

    static testMethod void myUnitTest() 
    {
        Datetime sysTime = System.now();
	    Job_Scheduler__c js = new Job_Scheduler__c();
	                    js.Name = 'Inbound New Schedules';
	                    js.Operations__c = 'Update TA Sync Record';
	                    js.Start_Date__c = date.today();
	                    js.Account_Locking__c=true;
            			js.status__c= 'Pending';
	                    js.Schedule_Hour__c = sysTime.hour();
	                    js.Minutes__c = sysTime.minute();
	                    System.debug('Job Scheduler Name = ' + js.Name);
	                    insert js;
	                         
        String query = 'Select Sales_Resource__c, Status__c, LastModifiedDate, OwnerId, Name, Id, Error__c, Count__c From TA_Sync_Log__c limit 200';
	    
        Test.startTest();
        Util.isTestCoverage=true;
	    String jobId = System.schedule('Test', '0 0 20 * * ?',new Schedule_Delete_TA_SYNC_LOG(js,query));
	    
	    // Get the information from the CronTrigger API object
	    CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
	    FROM CronTrigger WHERE id = :jobId];
	    // Verify the job has not run
	    System.assertEquals(0, ct.TimesTriggered);
	    Test.stopTest();
    }
}