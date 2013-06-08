/*=====================================================================================================+
|  HISTORY  |                       
|  DATE          DEVELOPER               WR         DESCRIPTION 
  ====          =========               ==         =========== 
|  05/07/2011    Ashwini Gowda                      This class is used to unit test 
                                                    IntegrationErrorReprocessing Class
 +=====================================================================================================*/
 @isTest
private class IntegrationErrorReprocessing_TC { 
    
    static testmethod void testdata() { 
         Test.startTest();
         Lead emeaDR = createLead();
         Account account = createAccount('TestingLog');
         Integration_error_log__c log1 = createIntegrationErrorLog(emeaDR.id,'Deal Registration Integration'); 
         Integration_error_log__c log2 = createIntegrationErrorLog(account.id,'Account Association Integration');
         Integration_error_log__c log3 = createIntegrationErrorLog(account.id,'Profiled Account Integration');
         List<String> integrationIDs = new List<String>();
         integrationIDs.add(log1.id);
         integrationIDs.add(log2.id);
         integrationIDs.add(log3.id);
         IntegrationErrorReprocessing.updateIntegration(integrationIDs);
         Test.stopTest();
    }
    
    static Lead createLead(){
        Lead newLead = new lead();
        newLead.lastname = 'Test Lead';
        newLead.company = 'EMC';
        newLead.DealReg_PSC_Owner__c = Userinfo.getUserId();
        newLead.DealReg_Deal_Registration_Status__c = 'New';
        newLead.DealReg_Of_Registration_Products__c = 3;
        newLead.DealReg_Deal_Description__c = 'test';
        newLead.DealReg_Deal_Registration_Justification__c = 'test';
        newLead.Partner__c = createAccount('Test').ID;
        newLead.DealReg_Theater__c = 'EMEA';
        newLead.Channel__c = 'Indirect';
        newLead.City ='India';
        newLead.Street ='Bangalore';
        newLead.DealReg_Deal_Registration__c = true;
        insert newLead;
        return newLead;
    }
    
    static Account createAccount(String accountName){
        Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id accRecordTypeId = recordTypes.get('T2_Partner Profile Record Type').getRecordTypeId();
    
        Account objAccount = new Account(
            name = 'UNITTESTAcc',
            Party_Number__c = '1234',
            BillingCountry ='Colombia',
            Synergy_Account_Number__c = '10',
            Lead_Oppty_Enabled__c = true, 
            Partner_Type__c ='Distributor',
            Type = 'Partner' ,
            PROFILED_ACCOUNT_FLAG__c = true,
            recordtypeid= accRecordTypeId           
        );
        insert objAccount;
        objAccount.Lead_Oppty_Enabled__c = true;
        objAccount.Type = 'Partner';
        objAccount.Status__c='A';
        update objAccount;
        System.Debug('objAccount ----> ' + objAccount) ;       
        return objAccount;
    }
    
    static Integration_error_log__c createIntegrationErrorLog(String IntegrationId,String IntegrationName){
        Integration_error_log__c errorLog = new Integration_error_log__c();
        errorLog.Integration_ID__c = IntegrationId;
        errorLog.Integration_Name__c = IntegrationName;
        insert errorLog;
        return errorLog;
    }
    
}