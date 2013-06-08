/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    21-JAN-2013     Shipra Misra            223457          test class for Schedule_Delete_Old_TA_LOG 
                                                            
==============================================================================*/
/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@IsTest(SeeAllData=true)
private class TC_Schedule_Delete_Old_TA_Log {

    static testMethod void TC_Schedule_Delete_Old_TA_Log_Test() 
    {
                             
       /* TA_Sync_Log__c e = new TA_Sync_Log__c(Sales_Resource__c =Userinfo.getUserId() );
        insert e ;
        e.Status__c='Error';
        update e ;
        */
        Profiles__c profile = Profiles__c.getOrgDefaults();
        Id apiOnlyProfileId = profile.System_Admin_API_Only__c;
        User sysAdmAPIUser=[Select id,name from User where profileId =: apiOnlyProfileId and Isactive= true and Last_TA_Synch_Date__c =:null limit 1];
        TA_Sync_Log__c ta2 = new TA_Sync_Log__c(Sales_Resource__c =sysAdmAPIUser.id );
        insert ta2;
        ta2.Status__c='Error';
        update ta2 ;
        Test.startTest();
        Util.isTestCoverage=true;
        DateTime delDate = system.now()- 30;
        String jobId = System.schedule('Test', '0 0 20 * * ?',new Schedule_Delete_Old_TA_Sync());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
        FROM CronTrigger WHERE id = :jobId];
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
       // String queryTASync  = 'Select Id FROM TA_Sync_Log__c where LastModifiedDate  > '+ new PRM_CommonUtils().getQueryFormattedDate(delDate);
       // database.executebatch( new Delete_Old_TA_Sync_Log(queryTASync) );  
        Test.stopTest();
    }
}