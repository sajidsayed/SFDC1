/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER       WR        DESCRIPTION                               

 |  ====          =========       ==        =========== 

 | 22/9/2010      Ashwini Gowda  Req#991   Test Class for PRM_GroupingScheduler
 | 
 | 19/10/2010     Ashwini Gowda  Req#1179  Updated Test Class to reflect changes
                                           when Partner Type field is updated.  
 | 02/02/2012	  Anil Sure				   Added Inactivation Reason
 +===========================================================================*/

@istest

private class PRM_GroupingScheduler_TC{

/* @Method <This method is used test the schedular class>.
   @param <Not taking any paramters>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    
    
    static testmethod void testGrouping() {
        PRM_GroupingSchedulerOperation scheduleOperations = new PRM_GroupingSchedulerOperation();
        
        PRM_GroupingSchedulerOperation.PRM_GroupingScheduler_TestClass_Execution=true;
                
        Account account1 = createAccount('TestAccount1','89675');
        Account account2 = createAccount('TestAccount2','9987690');
        Account account3 = createAccount('TestAccount3','346789');
        Account account4 = createAccount('TestAccount4','897689');
        Account account5 = createAccount('TestAccount5','89968512');
        Account account6 = createAccount('TestAccount6','89968500');
        
        account1.Grouping_Batch_Operation__c='UpdateRelatedSiteDuns';
        update account1;
        
       account2.Grouping_Batch_Operation__c='InactivateGrouping';
        update account2;
        
        account3.Grouping_Batch_Operation__c='Grouping Nullified';
        update account3;
        
        account4.Grouping_Batch_Operation__c='updateGroupingOnAccount';
        update account4;
        
        account5.Grouping_Batch_Operation__c='updateRelatedPartnerTypes';
        update account5;
        
        account6.Grouping_Batch_Operation__c='MasterGroupingUpdated';
        update account6;
        
        //Creating the dummy grouping on the previously created account for 
        //test class.
        Account_Groupings__c grouping = new Account_Groupings__c();
        grouping.Name = 'TestGrouping1';
        grouping.Active__c = true;
        grouping.Profiled_Account__c = account1.id;
        grouping.No_Master_Required__c = false;
        insert grouping;        
        
        grouping.Grouping_Update__c = 'updateMasterGrouping';        
        update grouping;
        
        Account_Groupings__c grouping2 = new Account_Groupings__c();
        grouping2.Name = 'TestGrouping2';
        grouping2.Active__c = true;
        grouping2.Profiled_Account__c = account2.id;
        grouping2.No_Master_Required__c = false;
        insert grouping2;
        
        grouping2.Active__c = false;
        grouping2.Inactivation_Reason__c='No longer a partner';        
        update grouping2;
        
        Account_Groupings__c grouping3 = new Account_Groupings__c();
        grouping3.Name = 'TestGrouping21';
        grouping3.Active__c = true;
        grouping3.Profiled_Account__c = account4.id;
        grouping3.No_Master_Required__c = false;
        insert grouping3;
        
        grouping3.Active__c = false;
        grouping3.Inactivation_Reason__c='No longer a partner'; 
        grouping3.Grouping_Update__c = 'Grouping Inactivated';        
        update grouping3;
        
        Account_Groupings__c grouping5 = new Account_Groupings__c();
        grouping3.Name = 'TestGrouping89';
        grouping3.Active__c = true;
        grouping3.Profiled_Account__c = account5.id;
        grouping3.No_Master_Required__c = false;
        insert grouping5;
        
        Test.startTest();
        //Here scheduling the test class to run one minute after submitting
        //the test class.        
        Datetime dt = System.now();
        dt = dt.addMinutes(1);       
        String scheduleString='0';//0 seconds       
        scheduleString+=' '+ dt.minute();       
        scheduleString+=' '+ dt.hour();       
        scheduleString+=' '+ dt.day();       
        scheduleString+=' '+ dt.month();       
        scheduleString+=' ?';       
        scheduleString+=' '+ dt.year();
        String jobName = 'GroupingScheduler - ' + dt.format('MM-dd-yyyy-hh:');
        //Here creating the instance of the schedular class 
        //PRM_GroupingScheduler.
        PRM_GroupingScheduler nextBatchJob = new PRM_GroupingScheduler();
        //Here scheduling the class by passing the jobname, scheduleString
        //which is the time component and object of the schedule class.       
        String jobId = System.schedule(jobName,scheduleString,nextBatchJob);
        
        Test.stopTest();
        
     
    }
    

/* @Method <This method is used create account for the test class>.
   @param <Taking string as paramter which contains account name and SiteDUNS>
   @return <void> - <Account record>
   @throws exception - <No Exception>
*/
    
    public static Account createAccount(String accountName,String SiteDUNS){
        //Creating the dummy account for test class.
        Account account = new Account(
            name=accountName,
            CurrencyIsoCode='USD',
            Site_DUNS_Entity__c=SiteDUNS
        );
        insert account;
        return account;
    }


}