/*================================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR        DESCRIPTION                               

|  ====          =========                ==        =========== 

| 12/09/2011     Anil Sure              #3656      This test class is used to
                                                   test the Search Criteria for Lead Deal Search.
|  14/12/2011		Anil						   Used Custom setting Data Helper
|  07/05/2012	 Anand Sharma						Fixed test class failure issue 
======================================================================================================*/
@isTest
private class PRM_DealLeadSearchController_TC {
    
    
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
        string partnerType;
        Lead l1=new Lead();
        Contact cont = new Contact();
        cont.LastName = 'testContact';
        cont.Active__c = true ;
        cont.Email = 'test12@xyx.com' ;

        insert cont;
        List<Account> account1 =  AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        List<Account> account2 =  AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        List<Account> AccountList = new List<Account>();
        List<Account> lstDistributorAccount = new List<Account>();
        for(account acc :account1)
        {
        AccountList.add(acc);
        }
        for(account acc: account2)
        { 
        AccountList.add(acc);
        }
        insert AccountList;
        for(account distiacc: AccountList){
            if(distiacc.Partner_Type__c=='Distributor'&& distiacc.Lead_Oppty_Enabled__c==true){
               distiacc.Ispartner=true;
            }
            lstDistributorAccount.add(distiacc);
        }
        Update lstDistributorAccount;
        System.Debug('AnirudhDebuglstDistributorAccount-->' +lstDistributorAccount);
        List<Lead> leadlist=LeadTestClassDataHelper.createDealReg(AccountList[4], null, lstDistributorAccount[0], AccountList[3]);
       
        insert leadlist;
        leadlist[0].DealReg_Deal_Submitter_Contact__c=cont.id;
        update leadlist;
        
        ApexPages.StandardController ctlr = new ApexPages.standardController(l1);
        PRM_DealLeadSearchController LeadCtrl = new PRM_DealLeadSearchController(ctlr);
        ApexPages.currentPage().getParameters().put('sbstr', '1778294');
        LeadCtrl.isSearch();
        LeadCtrl.SearchResults();
        LeadCtrl.getCountryList();
        LeadCtrl.getStatusList();
        LeadCtrl.getLeadList();
        LeadCtrl.OppNumber='1111';
        LeadCtrl.DealRegNumber='2222';
        LeadCtrl.sortListLeads('name', TRUE);
        LeadCtrl.sortField1 = 'name';
        LeadCtrl.sortAscending1 = true;
        LeadCtrl.runSortAction1();
        LeadCtrl.sortAscending1 = false;
        LeadCtrl.runSortAction1();
        LeadCtrl.sortListLeads('name', FALSE);
        LeadCtrl.ComponentSearch();
        LeadCtrl.openLink();
        LeadCtrl.BackPage();        
        
         }
         
        Private static testMethod void startTest1(){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Lead l1=new Lead();
        Contact cont = new Contact();
        cont.LastName = 'testContact';
        cont.Active__c = true ;
        cont.Email = 'test13@xyz.com' ;
        insert cont;
        List<Account> account1 =  AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        List<Account> account2 =  AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        List<Account> AccountList = new List<Account>();
        List<Account> lstDistributorAccount = new List<Account>();
        for(account acc :account1)
        {
        AccountList.add(acc);
        }
        for(account acc: account2)
        {
        AccountList.add(acc);
        }
        insert AccountList;
        
       for(account distiacc: AccountList){
            if(distiacc.Partner_Type__c=='Distributor'&& distiacc.Lead_Oppty_Enabled__c==true){
               distiacc.Ispartner=true;
            }
            lstDistributorAccount.add(distiacc);
        }
        Update lstDistributorAccount;
        List<Lead> leadlist=LeadTestClassDataHelper.createDealReg(AccountList[4], null, lstDistributorAccount[0], AccountList[3]);
       
        insert leadlist;
        leadlist[0].DealReg_Deal_Submitter_Contact__c=cont.id;
        update leadlist;
        ApexPages.StandardController ctlr = new ApexPages.standardController(l1);
        PRM_DealLeadSearchController LeadCtrl = new PRM_DealLeadSearchController(ctlr);       
        LeadCtrl.OppNumber='';
        LeadCtrl.DealRegNumber='';
        LeadCtrl.Country='--None--';
        LeadCtrl.Status='--None--';       
        leadlist[0].DealReg_Expiration_Date__c=null;
        leadlist[0].DealReg_Expected_Close_Date__c=null;
        leadlist[0].Contract_End_Date__c=null;
        leadlist[0].DealReg_Partner_Expected_Close_Date__c=null;
        leadlist[0].Tier_2_Partner__c=null;
        leadlist[0].DealReg_Related_Account_lookup__c=null;
        leadlist[0].DealReg_Deal_Submitter_Contact__c=null;
        leadlist[0].Partner__c=null;
        leadlist[0].phone='2324567';
        update leadlist[0];
        LeadCtrl.SearchResults();
        LeadCtrl.getCountryList();
        LeadCtrl.getStatusList();
        LeadCtrl.getLeadList();
        LeadCtrl.ComponentSearch();
        LeadCtrl.openLink();
        LeadCtrl.BackPage();
        LeadCtrl.getLeadDetails();
        LeadCtrl.setLeadList(leadlist);       
         
         }



}