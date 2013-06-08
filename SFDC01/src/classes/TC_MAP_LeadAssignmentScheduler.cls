@istest

Private class TC_MAP_LeadAssignmentScheduler {
    static testmethod void test1() {
        
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
        String jobName = 'Lead Routing Batch13 - ' + dt.format('MM-dd-yyyy-hh:');
        MAP_LeadAssignmentScheduler nextBatchJob = new MAP_LeadAssignmentScheduler();       
        String jobId = System.schedule(jobName,scheduleString,nextBatchJob);
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(scheduleString, ct.CronExpression);
        Test.stopTest();

    }
    static testmethod void test2() {
        
        Test.startTest();
        Datetime dt = System.now();
        dt = dt.addMinutes(5);       
        String scheduleString='0';//0 seconds       
        scheduleString+=' '+ dt.minute();       
        scheduleString+=' '+ dt.hour();       
        scheduleString+=' '+ dt.day();       
        scheduleString+=' '+ dt.month();       
        scheduleString+=' ?';       
        scheduleString+=' '+ dt.year();       
        String jobName = 'Lead Routing Batch12 - ' + dt.format('MM-dd-yyyy-hh:');
        List<MAP_Profile_Options__c> optionList = [SELECT Profile_Option_Name__c, Profile_Option_Value__c FROM MAP_Profile_Options__c where Profile_Option_Name__c = :'Lead_Batch_Size' limit 1];
       delete optionList;
       
        MAP_LeadAssignmentScheduler nextBatchJob = new MAP_LeadAssignmentScheduler();       
        String jobId = System.schedule(jobName,scheduleString,nextBatchJob);
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(scheduleString, ct.CronExpression);
        Test.stopTest();

    }


}