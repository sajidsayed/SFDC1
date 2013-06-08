/*=========================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER         WR        DESCRIPTION                               

 |  ====          =========         ==        =========== 

 |  2/12/2010    Suman B                     This is a Test Class for PRM_EmailNotificationScheduler.
 |  11/12/2010   Kothawade Prasad            Updated and added lead creation logic
                                              
 |  01/12/2011   Anil Sure           Created records manually and fixed MIXED_DML Exception
 +=========================================================================================*/
@isTest
Private Class PRM_EmailNotificationScheduler_TC  {


  /* @Method <testEmailScheduler(): Scheduler Testing>
       @param <void>
       @return <void> 
       @throws exception - <No Exception>
    */
 Public testmethod static void testEmailScheduler() {
     User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];
    System.runAs(insertUser)
    {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();
    }
        String inputqry =   'Partner' + '%' ;
        Group   groupQueue = [SELECT g.Id, g.name FROM Group g WHERE g.name like : inputqry limit 1];
       Lead ld = new Lead(LastName= 'Test Lead', Company='Test Company' ,ownerid =groupQueue.id,Channel__c = 'INDIRECT' );
       insert ld;
       List<Account> acc = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
       insert acc;
        acc[0].Queue_Name__c = ld.owner.name;
       update acc;
        Test.startTest();
        Datetime dt = System.now();
        dt = dt.addMinutes(1);      
        String scheduleString='0';//0 seconds       
        scheduleString+=' '+ dt.minute();       
        scheduleString+=' '+ dt.hour();       
        scheduleString+=' '+ dt.day();       
        scheduleString+=' '+ dt.month();       
        scheduleString+=' ?';       
        scheduleString+=' '+ dt.year();
        String jobName = 'Email Notifcation - ' + dt.format('MM-dd-yyyy-hh:');
      /**Here creating the instance of the schedular class **/
        PRM_EmailNotificationScheduler scheduleJob = new PRM_EmailNotificationScheduler();
        String jobId = System.schedule(jobName,scheduleString,scheduleJob);
        system.debug('JOB ID ---'+ JobId);
    Test.stopTest();
   }
}