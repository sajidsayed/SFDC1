/*======================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 23/06/2011    Suman B                           This is used for testing PRM_VPP_VelocityRuleResults.
 
   2 April 2012  Arif                              Added 'Velocity_Service_Provider_Tier__c' while creation of account
 +=====================================================================================================*/

@isTest
private class PRM_VPP_VelocityRuleResults_TC {

   static testMethod void myUnitTest() {
     User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];    
     System.runAs(insertUser){
       PRM_VPP_JobDataHelper.createVPPCustomSettingData();
     }

     List<Velocity_Rules__c > listVelRules = new List<Velocity_Rules__c >();
     List<Account> listaccount = new List<Account>();
     Recordtype rt  = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName 
                            From RecordType r where DeveloperName = 'Specialty_Rule' AND 
                            r.SobjectType = 'Velocity_Rules__c' limit 1] ; 

        Velocity_Rules__c vr = new Velocity_Rules__c(
                                Cluster__c='Test',
                                Specialty_Rule_Type__c ='test');
                insert vr ;             
       Velocity_Rules__c vr1 = new Velocity_Rules__c(
                                Cluster__c='Test',
                                Specialty_Rule_Type__c ='test',
                                recordtypeid = rt.id );
                insert vr1 ;
        listVelRules.add(vr);
        listVelRules.add(vr1);
               
        Account_Groupings__c grouping = new Account_Groupings__c();
        grouping.Name = 'TestGrouping1';
        grouping.Active__c = true;
        grouping.No_Master_Required__c = false;
        insert grouping;

       Account account = new Account(
        name='accountName',
        Velocity_Service_Provider_Tier__c = 'Platinum',
        CurrencyIsoCode='USD',
        Global_DUNS_Entity__c = '663399',
        PROFILED_ACCOUNT_FLAG__c = TRUE, 
        Grouping__c=grouping.Id ,
        Specialty_Rule_Type__c = 'test',
        Cluster__c = 'Test');
        insert account ;
          
        listaccount.add(account) ;
        
        grouping.Profiled_Account__c = account.id;                                                                                          
        update grouping ;
        
      Test.startTest();
          PRM_VPP_VelocityRuleResults vrrObj1  = new PRM_VPP_VelocityRuleResults(listVelRules) ;
          PRM_VPP_VelocityRuleResults vrrObj2  = new PRM_VPP_VelocityRuleResults(listaccount,false) ;
          PRM_VPP_VelocityRuleResults vrrObj4  = new PRM_VPP_VelocityRuleResults(listaccount,true) ;
          PRM_VPP_VelocityRuleResults vrrObj3  = new PRM_VPP_VelocityRuleResults() ;          
          vrrObj1.createVelocityRuleResults(listVelRules);
          vrrObj1.createVelocityRuleResults(listAccount,false); 
          // vrrObj3.getNonPanRules();
      Test.stopTest();
   }
}