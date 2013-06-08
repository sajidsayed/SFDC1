/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  22/06/2011    Suman B                           To test the class PRM_VPP_TEST_VelocityRuleResult for 
 |                                                   batch Jobs.
 |  15/09/2011    Suman B                           Added for runJobForTheaters() method.  
 |  11/1/2011     PRasad                            Many jobs schdeuled more than 5 taken out the other as rest is working fine
 |  15/12/2011    Anil                              Used Custom setting Data Helper  
 |  26/12/2011    Suman B                           Added code for creating Grouping data.  
 |  17/05/2012	  Anand Sharma					    Grouping issue exception  
  +=======================================================================================================*/

@isTest
private class PRM_VPP_TEST_VelocityRuleResult1_TC {

   static testMethod void myUnitTest() {
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        PRM_VPP_TEST_VelocityRuleResult prmvpp = new PRM_VPP_TEST_VelocityRuleResult();
        Test.startTest() ;
        
        //Create Account Record
        
         List<Account> lstAccount= AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
         insert lstAccount; 
        
       /*Creation of Grouping record */ 
       Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp');
       insert grouping;
        
         RecordType recordTypeSpecialty = [Select r.Id From RecordType r 
                                          where SobjectType = 'Velocity_Rules__c' 
                                          and Name = 'Specialty Rule']; 
        
       
         //Create Velocity Rule Record
         Velocity_Rules__c velocityrule = new Velocity_Rules__c(Display_Name__c = 'UNITTEST1',
                                                                                      RecordTypeId = recordTypeSpecialty.Id,
                                                                                      Cluster__c = 'APJ', 
                                                                                      Specialty_Rule_Type__c = 'LA1');
         
         
         insert velocityrule;
         //List<Velocity_Rule_Results__c>  listRuleResult = [Select v.Speciality_RuleID__c, v.Id, v.Grouping__c,v.AccountID__c 
         //                                                From Velocity_Rule_Results__c v  limit 5] ;
         //Create Velocity Speciality Record
         Velocity_Rule_Results__c listRuleResult = new Velocity_Rule_Results__c();
         listRuleResult.Speciality_RuleID__c = velocityrule.id ;
         listRuleResult.Grouping__c = grouping.Id;
         listRuleResult.AccountID__c = lstAccount[0].id ;
         insert listRuleResult;
        
         prmvpp.velocityRuleResultId = listRuleResult.Id ;
         //prmvpp.groupId  = listRuleResult.Grouping__c ;
         prmvpp.groupId  = grouping.id ;
         prmvpp.runGroupJob();
         prmvpp.runVelocityRuleResultJob();
     
         prmvpp.SelectedTheaterJob = '[EMEA]' ;  
         prmvpp.runJobForTheaters();
       Test.stopTest() ;
    }
}