@isTest
private class SCH_SchedulerOperations_TC {
/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER       WR       DESCRIPTION                               
 |  ====       =========       ==       =========== 
 |  18-JUN-09  S Douglas                Created
 +===========================================================================*/

  public static testMethod void testScheduler()
  {
       Util.isTestCoverage=true;
        //Test calcNewRunDate method
        DateTime testDt;
        String nullString = null;
        System.Debug('Test calcNewRunDate******************************************************************************');
        testDt = SCH_SchedulerOperations.calcNewRunDate(DateTime.newInstance(2000,1,1,0,1,0), 'Daily');
        System.assert(testDt == DateTime.newInstance(2000,1,2,0,1,0), 'Incorrect new run date calculated for Weekly recurrence');
       
        //my code 
        
        testDt = SCH_SchedulerOperations.calcNewRunDate(DateTime.newInstance(2000,1,1,0,1,0), 'weekly');
        testDt = SCH_SchedulerOperations.calcNewRunDate(DateTime.newInstance(2000,1,1,0,1,0), 'Fortnightly');
        testDt = SCH_SchedulerOperations.calcNewRunDate(DateTime.newInstance(2000,1,1,0,1,0), 'Monthly');
        testDt = SCH_SchedulerOperations.calcNewRunDate(DateTime.newInstance(2000,1,1,0,1,0), 'Quarterly');
        testDt = SCH_SchedulerOperations.calcNewRunDate(DateTime.newInstance(2000,1,1,0,1,0), 'yearly');
        // my code

        Job_Scheduler__c sched = new Job_Scheduler__c();
        sched.Name = 'UnitTest_AccountTeamMemberBatchDelete';
        sched.Start_Date__c = Date.newInstance(2000,1,1);  //January 1, 2000
        sched.Operations__c = 'Batch Delete Account Team Members';  //'Test1';
        sched.Occurence__c = 'Daily';
        sched.End_Date__c = null;
        sched.Schedule_Hour__c = 0;
        sched.Minutes__c = 1;
        

        //Bulk cases
        List <Job_Scheduler__c> bulkScheds = new List <Job_Scheduler__c> ();
        bulkScheds.add(new Job_Scheduler__c(Name = 'UnitTest_EndDateBeforeToday', Start_Date__c = Date.newInstance(2000,1,1),
                                        Operations__c = 'Test', Occurence__c = 'Daily',
                                        End_Date__c = Date.newInstance(2000,1,5), Schedule_Hour__c = 0, Minutes__c = 1));

        Test.startTest();
        
        //Test insert which should populate Next Schedule and also set update flag to 0
        insert sched;  
        insert bulkScheds;
        
        Job_Scheduler__c insertedSched =  
            [select id, Next_Schedule__c, Update_Me__c from Job_Scheduler__c where Id = :sched.Id limit 1];
            
        
        System.Debug('UnitTest_AccountTeamMemberBatchDelete After Insert******************************************************************************');
        System.Debug('Inserted ID = ' + insertedSched.Id);
        System.Debug('Inserted nextSchedule = ' + insertedSched.Next_Schedule__c);
        System.Debug('Inserted Update_Me__c = ' + insertedSched.Update_Me__c);
        
        //System.assert(insertedSched.Next_Schedule__c == DateTime.newInstance(2000,1,1,0,1,0), 'Incorrect Update Next Schedule Value for Insert');
        System.assertEquals('0', insertedSched.Update_Me__c, 'Incorrect Update Flag Value for Insert');

        //Test the after update trigger which should create a new schedule record with Next Schedule incremented
        sched.Update_Me__c = '1';
        
        update sched;

       /* Job_Scheduler__c updatedSched =  
            [select id, Next_Schedule__c, Update_Me__c, IsDeleted from Job_Scheduler__c where name = 'UnitTest_AccountTeamMemberBatchDelete' and Id != :sched.Id];
            */
        System.Debug('UnitTest_AccountTeamMemberBatchDelete After Update******************************************************************************');
       // System.Debug('Updated ID = ' + updatedSched.Id);
       // System.Debug('Updated nextSchedule = ' + updatedSched.Next_Schedule__c);
       // System.Debug('Updated Update_Me__c = ' + updatedSched.Update_Me__c);
      //  System.Debug('Updated IsDeleted = ' + updatedSched.IsDeleted);
        
        //System.assert(updatedSched.Next_Schedule__c == DateTime.newInstance(2000,1,1,0,1,0).addDays(1), 'Incorrect Next Schedule Value for Insert');
        //System.assertEquals('0', updatedSched.Update_Me__c, 'Incorrect Flag Value for Insert');

        //Check bulk case with end date before today
        System.Debug('UnitTest_EndDateBeforeToday After Insert******************************************************************************');
        insertedSched =  
            [select id, Next_Schedule__c, Update_Me__c from Job_Scheduler__c where Id = :bulkScheds[0].Id];
        System.Debug('Inserted ID = ' + insertedSched.Id);
        System.Debug('Inserted nextSchedule = ' + insertedSched.Next_Schedule__c);
        System.Debug('Inserted Update_Me__c = ' + insertedSched.Update_Me__c);

        System.assert(insertedSched.Next_Schedule__c == DateTime.newInstance(2000,1,1,0,1,0), 'Incorrect Next Schedule Value for Bulk Insert EndDateBeforeToday');
        System.assertEquals('1', insertedSched.Update_Me__c, 'Incorrect Flag Value for Bulk Insert EndDateBeforeToday');

        SCH_SchedulerOperations.resetFlagsForUnitTest();

        Test.stopTest();
        
  } //testScheduler
  public static testMethod void testSchedulerTASync()
  {
    Job_Scheduler__c sched3 = new Job_Scheduler__c();
    sched3.Name = 'Inbound New Schedules';
    sched3.Operations__c = 'Update TA Sync Record';
    sched3.Start_Date__c = Date.newInstance(2013,1,1);
    sched3.Account_Locking__c=true;
    sched3.End_Date__c = null;
    sched3.status__c= 'Pending';
    sched3.Schedule_Hour__c =0;
    sched3.Minutes__c = 1;
    
    insert sched3;
    
  }
  public static testMethod void testSchedulerAP()
  {
    Job_Scheduler__c sched2 = new Job_Scheduler__c();
    sched2.Name = 'Core Quota Rep 1';
    sched2.Start_Date__c = Date.newInstance(2000,1,1);  //January 1, 2000
    sched2.Operations__c = 'Core Quota Rep';  //'Test1';
    sched2.Occurence__c = 'Daily';
    sched2.End_Date__c = null;
    sched2.Schedule_Hour__c = 0;
    sched2.Minutes__c = 1;
        
   /* User thisUser = [ Select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs( thisUser ){*/
         CustomSettingDataValueMap__c configEntry = CustomSettingDataValueMap__c.getValues('Max Batch Id');  
          configEntry.DataValue__c= '12121313';  
      //   update configEntry;
        
        //Test insert which should populate Next Schedule and also set update flag to 0
        insert sched2;
       // } 
        
    
  }

}