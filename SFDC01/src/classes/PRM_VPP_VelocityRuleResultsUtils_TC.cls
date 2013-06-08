/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE            DEVELOPER                WR       DESCRIPTION                               
 |  ====            =========                ==       =========== 
 |  22/06/2011      Suman B                         Created custom setting value through test class
 |  2 March 2012    Arif                            Changed the order of calling 'deleteEducationAndEducationGroupMapping'
 |                                                  and 'createEducationAndEducationGroupMapping'  method
 |  13/03/2012      Anil Sure                       Removed DML Statements  
 |  17/05/2012      Anand Sharma                    Grouping issue exception                                                
 +=======================================================================================================*/

@isTest
private class PRM_VPP_VelocityRuleResultsUtils_TC {
    Static set<Id> setAccountIds = new set<Id>();
    Static List<Account> listacc = new list<Account>();
    static testMethod void PRM_VPP_VelocityRuleResultsUtils_Test() {
       Recordtype velocityrulerecType  = [Select SobjectType, Name, Id, DeveloperName 
                            From RecordType  where DeveloperName = 'Specialty_Rule' AND 
                            SobjectType = 'Velocity_Rules__c' limit 1] ; 
       List<Velocity_Rules__c> listVelRules = new list<Velocity_Rules__c>();                    
       Velocity_Rules__c testRule = new Velocity_Rules__c(
                                Cluster__c='Test',
                                Specialty_Rule_Type__c ='test');
       listVelRules.add(testRule);                    
       Velocity_Rules__c testRule2 = new Velocity_Rules__c(
                                Cluster__c='Test',
                                Specialty_Rule_Type__c ='test',
                                recordtypeid = velocityrulerecType .id );
               
        listVelRules.add(testRule2);
        insert listVelRules;
        
        
        Account account1 = createAccount('TestAccount1');
        listacc = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        insert listacc;
        
        Account_Groupings__c grouping = new Account_Groupings__c();
        grouping.Name = 'TestGrouping1';
        grouping.Active__c = true;
        grouping.Profiled_Account__c = listacc[0].id;
        grouping.No_Master_Required__c = false;
        insert grouping; 
        
        for(Account acc : listacc)
        {   
             acc.Type = 'Partner';
             acc.Cluster__c = 'LA1';
             acc.IsPartner = true;
             acc.PROFILED_ACCOUNT_FLAG__c = true;
             acc.Grouping__c=grouping.Id;
             setAccountIds.add(acc.ID);
        }
        update listacc;
        List<id> listRuleIds = new List<Id>();
        list<Velocity_Rule_Results__c> listVelocityRuleResults = new list<Velocity_Rule_Results__c>();
        for(Velocity_Rules__c ruleObj :listVelRules){
             Velocity_Rule_Results__c velocityRuleResult= new  Velocity_Rule_Results__c();
              velocityRuleResult.Speciality_RuleID__c = ruleObj.id ;
              velocityRuleResult.Grouping__c = grouping.Id;
              velocityRuleResult.AccountID__c = listacc[0].id ;
              listRuleIds.add(ruleObj.Id);                                        
              listVelocityRuleResults.add(velocityRuleResult);
        }
        insert listVelocityRuleResults;
        PRM_VPP_VelocityRuleResults vrrresultsObj = new PRM_VPP_VelocityRuleResults(listacc,false) ;
        List<Velocity_Rule_Results__c> listvrrresults = vrrresultsObj.createVelocityRuleResults();
                                              
            
        
        Integer listcheck =0 ;
        for(Velocity_Rule_Results__c vrr : listvrrresults){
           //listRuleIds.add(vrr.Speciality_RuleID__c);
           setAccountIds.add(vrr.AccountID__c);  
           listcheck++;
           if(listcheck>1){
              break ;
           }
         }
        System.Debug('listRuleIds--->' +listRuleIds.size());
       List<Velocity_Rules__c> listRules1 = [Select v.Theater__c, v.Specialty_Rule_Type__c,v.Name, 
                                             v.Id, v.Cluster__c From Velocity_Rules__c v 
                                             where id =:listRuleIds[0] ];
    
    
       List<Velocity_Rules__c> listRules2 = [Select v.Theater__c, v.Specialty_Rule_Type__c,v.Name, 
                                             v.Id, v.Cluster__c From Velocity_Rules__c v 
                                             where id =:listRuleIds[1] ];                                         
    
       PRM_VPP_VelocityRuleResultsUtils.checkVelocityRuleUpdate( listRules1 ,listRules2 );    
      
       PRM_VPP_VelocityRuleResultsUtils.deleteVelocityRuleResults(listRuleIds);
       PRM_VPP_VelocityRuleResultsUtils.deleteVelocityRuleResults(listacc);
     
   
    
    }
    /* @Method <This method is used create account for the test class
            with siteDuns same as the existing account which has
            grouping on the account>
   @param <Taking string as paramter which contains account name>
   @return <void> - <Account record>
   @throws exception - <No Exception>
*/
    
    public static Account createAccount(String accountName){
        //Creating the dummy account for test class.
        Account account = new Account(
            name=accountName,
            CurrencyIsoCode='USD',
            Site_DUNS_Entity__c = '123456',
            Global_DUNS_Entity__c = '663399'
        );
        insert account;
        return account;
    }
    
    /*static testMethod void PRM_VPP_VelocityRuleResultsUtils_Test1() { 
        //List<Account> listAccount = [Select id,name from Account where Id IN :setAccountIds ] ;
        PRM_VPP_VelocityRuleResultsUtils.deleteVelocityRuleResults(listacc);
    }*/
    
    static testMethod void PRM_VPP_VelocityRuleResultsUtils_Test2() { 
         List<Education__c> listEducation = [Select e.Training_ID__c, e.Staging_ID__c, e.Name, e.Id, 
                                       e.Education_Type__c, e.Education_Master__c, e.Education_ID__c, 
                                       e.EMC_Mentoring_Location__c, e.Batch_Job_Operation__c 
                                       From Education__c e limit 20];   
        List<id> educationIds = new List<id>();
        for(Education__c edu :listEducation){
           educationIds.add(edu.id);
        }
        test.startTest();
        PRM_VPP_VelocityRuleResultsUtils.deleteEducationAndEducationGroupMapping(educationIds);
        
        PRM_VPP_VelocityRuleResultsUtils.createEducationAndEducationGroupMapping(listEducation);   
        test.stopTest();                           
    
    }
}