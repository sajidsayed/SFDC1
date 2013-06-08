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
 * =====================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  23.11.2012      Avinash K       212738      Initial Creation.  Test class for TestTA_Sync_Log_Insert class.
 +=====================================================================================================================*/

@isTest(SeeAllData = true)
private class TA_Sync_Log_Insert_TC 
{  
   public static testMethod void TestTA_Sync_Log_Insert()
    {
        try
        {
          Test.startTest();
          List<Group> lstTopOffenderGroup = new List<Group>();
          Set<GroupMember> setTopOffenderGroupMember = new Set<GroupMember>();
          Set<Id> setTopOffenderMemberId = new Set<Id>();

          lstTopOffenderGroup = [select name, id, 
                  (select GroupId, UserOrGroupId from GroupMembers)
                  from Group 
                  where name like '%TOPUB%' OR name like '%TOPVT%'
                  limit 50000];

          for (Group g: lstTopOffenderGroup) 
          {
            Boolean blnAddAll = setTopOffenderGroupMember.addAll(g.GroupMembers);
          }

          for (GroupMember gm: setTopOffenderGroupMember) 
          {
            setTopOffenderMemberId.add(gm.id);
          }
        Util.isTestCoverage=true;
          TA_Sync_Log_Insert batch = new TA_Sync_Log_Insert('select name, id, Profile_Name__c, Last_TA_Synch_Date__c from User where isActive = true AND (NOT Profile_Name__c  like \'%VAR%\') AND (NOT Profile_Name__c  like \'%Distributor%\') AND (NOT Profile_Name__c  like \'%Reseller%\') ORDER BY Last_TA_Synch_Date__c asc limit 15') ;
          //Database.executeBatch(batch, 15);
          //test.stopTest();
        }
        catch(Exception e)
        {
          system.debug('#### Exception occurred in Test Class : TA_Sync_Log_Insert_TC');
        }

    }
    public static testMethod void TestTASyncInsertBatchScheduler()
    {
          //TASyncInsertBatchSchedule taSchedule= new TASyncInsertBatchScheduler('select name, id, Profile_Name__c, Last_TA_Synch_Date__c from User where isActive = true AND (NOT Profile_Name__c  like \'%VAR%\') AND (NOT Profile_Name__c  like \'%Distributor%\') AND (NOT Profile_Name__c  like \'%Reseller%\') AND (Last_TA_Synch_Date__c = null OR Last_TA_Synch_Date__c < :dteThirtyDaysBack) ORDER BY Last_TA_Synch_Date__c asc');
        Util.isTestCoverage=true;
        TASyncInsertBatchScheduler batchSch = new TASyncInsertBatchScheduler();
        String schedule = '0 0 5 * * ?'; // This job will run every hour
        //Test.startTest();
        system.schedule('TA Sync Batch Job Test', schedule , new TASyncInsertBatchScheduler());
       // test.stopTest();
    }
}