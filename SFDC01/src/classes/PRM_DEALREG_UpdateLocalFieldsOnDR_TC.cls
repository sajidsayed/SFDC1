@isTest
/*=========================================================================================================================+
 |  14/12/2011      Anil                        Used Custom setting Data Helper
 +=========================================================================================================================*/
private class PRM_DEALREG_UpdateLocalFieldsOnDR_TC{

    private static testMethod void updateLocalFieldsOnDR(){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        list<account> lstAccount = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        list<account> lstPartnerAccount = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
                
        map<Id,Account> mapAccount = new map<Id,Account>();
        insert lstAccount;
        
        system.debug('lstAccount--->' +lstAccount);
        insert lstPartnerAccount;
        system.debug('lstPartnerAccount--->' +lstPartnerAccount);
        for(Account account:lstPartnerAccount){
            account.IsPartner = true;
        }
        update lstPartnerAccount;
        list<lead> lstLead = LeadTestClassDataHelper.createDealReg(lstAccount[0],null,lstPartnerAccount[0],lstPartnerAccount[0]);
        insert lstlead;
        system.debug('lstlead[0]--->' +lstlead[0]);
    
         
         Test.StartTest();
         lstAccount[0].State_Province_Local__c = 'testState1';
         system.debug('lstAccount[0]------>' +lstAccount[0]); 
         update lstAccount[0];
         mapAccount.put(lstAccount[0].Id,lstAccount[0]);
         //update lstAccount[0];
         
         PRM_DEALREG_UpdateLocalFieldsOnDR obj = new PRM_DEALREG_UpdateLocalFieldsOnDR();
         obj.updateAddressOnDR(mapAccount);
         Test.StopTest();
    }   
  
}