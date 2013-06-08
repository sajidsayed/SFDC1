/*======================================================================================+

|  HISTORY  |                                                                           

|  DATE         DEVELOPER                WR            DESCRIPTION                               

|  ====         =========                ==            =============
  04/03/2011    Himanshu                 1829           This is unit test class
|                                                       to test the PRM_AssociationScheduler Class.
+======================================================================================*/
@isTest
private class PRM_AssociationScheduler_TC {

 /*@Method <This method is used to create test data.>*/  
    static testmethod void testdata() {        
        
        /*...... Creating one Account......*/
        Account Account1 = new Account(
                                    Name = 'TestAccount1',
                                    CurrencyIsoCode  = 'USD',
                                    PROFILED_ACCOUNT_FLAG__c  = false,
                                    Child_Partner_Users_Count__c  = 2);
                                    
        Insert Account1;
        
        /*......Creating the dummy grouping on the previously created Account......*/  
        Account_Groupings__c grouping = new Account_Groupings__c();
        grouping.Name = 'TestGrouping1';
        grouping.Active__c = True;
        grouping.Profiled_Account__c = Account1.id;
        grouping.No_Master_Required__c = False;
        Insert grouping;
        
        /*...... Creating one Profiled Account......*/
        Account Account2= new Account(
                                    Name = 'TestAccount2',
                                    CurrencyIsoCode  = 'USD',
                                    PROFILED_ACCOUNT_FLAG__c  = False,
                                    Child_Partner_Users_Count__c  = 2,
                                    Profiled_Account__c  = Account1.Id
                                    );
                                    
        Insert Account2;
        
        /*...... Creating one Account  for Delete Association......*/
        Account Account3= new Account(
                                    Name = 'TestAccount3',
                                    CurrencyIsoCode  = 'USD',
                                    PROFILED_ACCOUNT_FLAG__c  = False,
                                    Child_Partner_Users_Count__c  = 0);
        Insert Account3;
    }

/*@Method <This method is used to test the scheduler class.>*/ 
    static testmethod void test_scheduler()
    {
        testdata();    
        Test.startTest(); 
      
        Datetime dt = System.now();
        dt = dt.addMinutes(1);       
        String scheduleString='0';
        scheduleString+=' '+ dt.minute();   
        scheduleString+=' '+ dt.hour();     
        scheduleString+=' '+ dt.day();      
        scheduleString+=' '+ dt.month();       
        scheduleString+=' ?';
        scheduleString+=' '+ dt.year();
        String jobName = 'One Time - ' + dt.format('MM-dd-yyyy-hh:');  
        PRM_AssociationScheduler nextBatchJob = new PRM_AssociationScheduler();
        String jobId = System.schedule(jobName,scheduleString,nextBatchJob);
      
        Test.stopTest();
     
    }

}