/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  23/06/2011    Suman B                         Test Class for Controller for PRM_VPP_VelocityComponentController.
 |  13/03/2012    Anil Sure                       Removed DML Statements    
 +=======================================================================================================*/

@isTest
private class PRM_VPP_VelocityComponentController_TC {

    static testMethod void PRM_VPP_VelocityComponentController_Test() {
     PRM_VPP_VelocityComponentController vccObj = new PRM_VPP_VelocityComponentController();
         vccObj.emcSpecialityStatus = 'test';
         vccObj.specialityComplianceStatus = 'Test - compliancestatus' ;
         vccObj.Speciality = 'Test';
         vccObj.getSpecialityList();
         
         Account account1 = new Account(
            name='Test Account',
            CurrencyIsoCode='USD',
            Site_DUNS_Entity__c = '123456',
            Global_DUNS_Entity__c = '663399'
            );
        insert account1;
    
  
        
        Account_Groupings__c grouping = new Account_Groupings__c();
        grouping.Name = 'TestGrouping1';
        grouping.Active__c = true;
        grouping.Profiled_Account__c = account1.id;
        grouping.No_Master_Required__c = false;
        insert grouping;
         
        List<Account> listacc = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        insert listacc;

        for(Account acc : listacc)
        {
             acc.PROFILED_ACCOUNT_FLAG__c = true;
             acc.Grouping__c=grouping.Id;
        }
        update listacc;
        
         PRM_VPP_VelocityRuleResults vrrresultsObj = new PRM_VPP_VelocityRuleResults(listacc,false) ;
         List<Velocity_Rule_Results__c> listvrrresults = vrrresultsObj.createVelocityRuleResults();
         vccObj.setSpecialityList(listvrrresults);
    }
}