/*=====================================================================================================+
 |  HISTORY  |
 |  DATE          DEVELOPER               WR                    DESCRIPTION 
 |  ====          =========               ==                    =========== 
 |  20/06/2011    Suman B                             This is a Testclass for Custom Account search  .
 |  14/12/2011      Anil                              Removed Query for Accounts and used Custom setting Data Helper
 |  28/03/2013    Karunakar M			WR#223941     Added startTest2 method for  Else block code coverage	
 +=====================================================================================================*/

@isTest
private class PRM_DEALREG_CustomSearch_TC {

/* @Method <This method is used for testing the controller methods>.   
    @param - <void>  
    @return <Lead> - <Lead record>   
    @throws exception - <No Exception>
*/    
    Private static testMethod void startTest(){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        ApexPages.currentpage().getParameters().put('LeadId','00Q'); 
        ApexPages.currentpage().getParameters().put('IsDealReg','true'); 
        ApexPages.currentpage().getParameters().put('RecordTypeId','01270000000Q7MD');
        PRM_DEALREG_CustomSearch dealRegController = new PRM_DEALREG_CustomSearch();
        list<Account> lstAccount = new list<Account>();
        lstAccount = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        insert lstAccount;
        String userprofileId = UserInfo.getProfileId();
        APJ_Partner_Profiles__c APJPP= new APJ_Partner_Profiles__c(name='ProfileId');
        APJPP.ProfileId__c=userprofileId;
        database.insert(APJPP,false);
        
        // CustomSearch
        dealRegController.clearresults();
        dealRegController.populateAccountInfo();

        dealRegController.search();
        dealRegController.selectedrecord = lstAccount[0].id ;
        dealRegController.paramValue = dealRegController.selectedrecord ;        
        List<Account> testAccount1=AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        List<Account> testAccount2=AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        List<Account> testAccount3=AccountAndProfileTestClassDataHelper.CreateT2PartnerAccount();
        insert testAccount1;
        insert testAccount2;
        insert testAccount3;
        for(Account account:testAccount2){
            account.IsPartner = true;
        }
        update testAccount2;
        List<Lead> dealReg = LeadTestClassDataHelper.createDealReg(testAccount1[0], null, testAccount2[0], testAccount3[0]);
        insert dealReg;
        //Lead dealReg = [select id,name from Lead limit 1];
        
        dealRegController.leadId =dealReg[0].Id ;
        dealRegController.populateValues1();    
        dealRegController.getSearchCriteriaList();
        dealRegController.getAccountDetails();
        // setting address input fields.
        dealRegController.inputAccountName = 'TestAcc';
        dealRegController.inputCity = 'Testcity';
        dealRegController.inputCountry = 'South Georgia and the South Sandwich Island';
        dealRegController.inputState ='Test' ;
        dealRegController.inputZipCode = 'Test' ;
        dealRegController.inputStreet = 'Test';
        dealRegController.setlocalAddress=true;
        dealRegController.search() ;
        dealRegController.sortListAccounts('name', TRUE);
        dealRegController.sortField1 = 'name';
        dealRegController.sortAscending1 = true;
        dealRegController.runSortAction1();        
        dealRegController.populateAccountInfo();
        dealRegController.cancel();
        dealRegController.searchAccount();
       // setting LeadId to 00Q 
        dealRegController.leadId = '00Q' ;
        dealRegController.setlocalAddress = false ;
        dealRegController.populateAccountInfo();
        dealRegController.populateValues1();
        dealRegController.cancel();         
    }    
     
    Private static testMethod void startTest2(){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }        
        ApexPages.currentpage().getParameters().put('LeadId','1115555'); 
        ApexPages.currentpage().getParameters().put('RecordTypeId','undefined');
        ApexPages.currentpage().getParameters().put('IsDealReg','false'); 
        String userprofileId = UserInfo.getProfileId();       
        
        PRM_DEALREG_CustomSearch dealRegController = new PRM_DEALREG_CustomSearch();       
        list<Account> lstAccount = new list<Account>();
        lstAccount = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        insert lstAccount;
        
        List<Account> testAccount1=AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        List<Account> testAccount2=AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        List<Account> testAccount3=AccountAndProfileTestClassDataHelper.CreateT2PartnerAccount();
        insert testAccount1;
        insert testAccount2;
        insert testAccount3;
        for(Account account:testAccount2){
            account.IsPartner = true;
        }
        update testAccount2;
       List<Lead> dealReg = LeadTestClassDataHelper.createDealReg(testAccount1[0], null, testAccount2[0], testAccount3[0]);
       insert dealReg;
        // CustomSearch
        dealRegController.clearresults();
        dealRegController.populateAccountInfo();
        dealRegController.search();
       
        dealRegController.paramValue = dealRegController.selectedrecord ;
       
        //Lead dealReg = [select id,name from Lead limit 1];        
        dealRegController.leadId ='111' ;
        dealRegController.populateValues1();    
        dealRegController.getSearchCriteriaList();
        dealRegController.getAccountDetails();
        // setting address input fields.
        dealRegController.inputAccountName = 'TestAcc';
        dealRegController.inputCity = 'Testcity';
        dealRegController.inputCountry = 'Macedonia, The Former Yugoslav Republic Macedonia, The Former Yugoslav Republicrrrrrrrrrrrrrrrrrrrrrrrrrrrtttt';
        dealRegController.inputState ='Test' ;
        dealRegController.inputZipCode = 'Test' ;
        dealRegController.inputStreet = 'Test';
        dealRegController.inputPartyNumber='11';       
        dealRegController.search() ;
        dealRegController.sortListAccounts('name', FALSE);
        dealRegController.sortField1 = 'name';
        dealRegController.sortAscending1 = false;
        dealRegController.runSortAction1();        
        dealRegController.populateAccountInfo();
        dealRegController.cancel();        
        dealRegController.searchAccount();
       // setting LeadId to 00Q 
        dealRegController.leadId = '111555' ;      
        dealRegController.populateAccountInfo();
        dealRegController.populateValues1();
        dealRegController.cancel();          
    }
Private static testMethod void startTest3(){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }        
        ApexPages.currentpage().getParameters().put('LeadId','00Q'); 
         ApexPages.currentpage().getParameters().put('IsDealReg','false'); 
        ApexPages.currentpage().getParameters().put('RecordTypeId','012700000005Iaa');        
        PRM_DEALREG_CustomSearch dealRegController = new PRM_DEALREG_CustomSearch();       
        list<Account> lstAccount = new list<Account>();
        lstAccount = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        insert lstAccount;        
        String userprofileId = UserInfo.getProfileId();
        APJ_Partner_Profiles__c APJPP= new APJ_Partner_Profiles__c();
        APJPP.ProfileId__c=userprofileId;
        database.upsert(APJPP,false);   
        
        List<Account> testAccount1=AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
       // List<Account> testAccount2=AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
       // List<Account> testAccount3=AccountAndProfileTestClassDataHelper.CreateT2PartnerAccount();
        insert testAccount1;
       // insert testAccount2;
       // insert testAccount3;
        for(Account account:testAccount1){
            account.IsPartner = true;
        }
        update testAccount1;
       List<Lead> dealReg = LeadTestClassDataHelper.createDealReg(testAccount1[0], null, testAccount1[0], testAccount1[0]);
       insert dealReg;
        // CustomSearch
        dealRegController.clearresults();
        dealRegController.populateAccountInfo();
        dealRegController.search();       
        dealRegController.paramValue = dealRegController.selectedrecord ; 
        //Lead dealReg = [select id,name from Lead limit 1];       
        dealRegController.leadId ='111' ;
        dealRegController.populateValues1();    
        dealRegController.getSearchCriteriaList();
        dealRegController.getAccountDetails();
        // setting address input fields.
        dealRegController.inputAccountName = 'TestAcc';
        dealRegController.inputCity = 'Testcity';
        dealRegController.inputCountry = 'Macedonia, The Former Yugoslav Republic Macedonia, The Former Yugoslav Republicrrrrrrrrrrrrrrrrrrrrrrrrrrrtttt';
        dealRegController.inputState ='Test' ;
        dealRegController.inputZipCode = 'Test' ;
        dealRegController.inputStreet = 'Test';
        dealRegController.inputPartyNumber='11';       
        dealRegController.search() ;
        dealRegController.sortListAccounts('name', FALSE);
        dealRegController.sortField1 = 'name';
        dealRegController.sortAscending1 = false;
        dealRegController.runSortAction1();        
        dealRegController.populateAccountInfo();
        dealRegController.cancel();        
        dealRegController.searchAccount();
       // setting LeadId to 00Q 
        dealRegController.leadId = '00Q';     
        dealRegController.populateAccountInfo();
        dealRegController.populateValues1();
        dealRegController.cancel();
          
    }
    
 }