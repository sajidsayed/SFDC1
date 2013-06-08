/*=======================================================================================================+
|  HISTORY  |                                                                           
|  DATE          DEVELOPER        WR                    DESCRIPTION                               
|  ====          =========        ==                    =========== 
| 12-Jul-2011    Anirudh Singh    Helper Class          This test class is used to Create Account Data for Test
|                                                       Classes
+=====================================================================================================*/

public class AccountAndProfileTestClassDataHelper {

    public static list<Account> CreateCustomerAccount(){
        
        Map<String,Schema.RecordTypeInfo> recordTypes;
        Id accRecordTypeId;
        
        if(Account.sObjectType != null && Account.sObjectType.getDescribe() != null && 
            Account.sObjectType.getDescribe().getRecordTypeInfosByName() != null)
            recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        if(recordTypes!= null && recordTypes.get('Customer Account Record Type') != null &&
            recordTypes.get('Customer Account Record Type').getRecordTypeId() != null)
            accRecordTypeId = recordTypes.get('Customer Account Record Type').getRecordTypeId(); 
        
        List<Account> lstAccount = New List<Account>();
        
        //Creation of Customer Accounts
        Account objAccount = new Account();
        objAccount.name = 'UNITTESTAcc';
        objAccount.Party_Number__c = '1234';        
        objAccount.BillingCountry ='Colombia';
        objAccount.Synergy_Account_Number__c = '10';
        objAccount.Status__c='A';
        objAccount.State_Province_Local__c = 'testState1';
        objAccount.Street_Local__c='test1';
        objAccount.Zip_Postal_Code_Local__c='23454';
        //objAccount.DealReg_Address_Local__c='test2';
        lstAccount.add(objAccount);
        
        Account objAccount1 = new Account();
        objAccount1.name = 'UNITTESTAcc1';
        objAccount1.Party_Number__c = '12345';        
        objAccount1.BillingCountry ='Colombia';
        objAccount1.Synergy_Account_Number__c = '10';
        objAccount1.Status__c='A';
        objAccount1.State_Province_Local__c = 'testState2';
        objAccount1.Street_Local__c='test1';
        objAccount1.Zip_Postal_Code_Local__c='23454';
        //objAccount1.DealReg_Address_Local__c='test2';
        lstAccount.add(objAccount1);
        
        Account objAccount2 = new Account();
        objAccount2.name = 'UNITTESTAcc1';
        objAccount2.Party_Number__c = '12345';        
        objAccount2.BillingCountry ='Colombia';
        objAccount2.Synergy_Account_Number__c = '10';
        objAccount2.Status__c='A';
        objAccount2.State_Province_Local__c = 'testState3';
        objAccount2.Street_Local__c='test1';
        objAccount2.Zip_Postal_Code_Local__c='23454';
        //objAccount2.DealReg_Address_Local__c='test2';
        lstAccount.add(objAccount2);
        
        Account objAccount3 = new Account();
        objAccount3.name = 'UNITTESTAcc1';
        objAccount3.Party_Number__c = '12345';        
        objAccount3.BillingCountry ='Colombia';
        objAccount3.Synergy_Account_Number__c = '10';
        objAccount3.Status__c='A';
        objAccount3.State_Province_Local__c = 'testState3';
        objAccount3.Street_Local__c='test1';
        objAccount3.Zip_Postal_Code_Local__c='23454';
        //objAccount3.DealReg_Address_Local__c='test2';
        lstAccount.add(objAccount3);
        
        return lstAccount;    
    }
    
    public static list<Account> CreatePartnerAccount(){
        List<Account> lstPartnerAccount = New List<Account>();
        
         //Creation of Partner Accounts
         Account objAccount = new Account();
         objAccount.name = 'TestPartnerAcc';
         objAccount.Party_Number__c = '1234';            
         objAccount.BillingCountry ='Colombia';
         objAccount.Synergy_Account_Number__c = '10';
         objAccount.Type = 'Partner';
         objAccount.Lead_Oppty_Enabled__c = true;
         objAccount.Partner_Type__c ='Distributor';
         objAccount.Site_DUNS_Entity__c='001017771';
         objAccount.PROFILED_ACCOUNT_FLAG__c = true;
         lstPartnerAccount.add(objAccount);
         
         Account objAccount1 = new Account();
         objAccount1.name = 'TestPartnerAcc1';
         objAccount1.Party_Number__c = '1234';            
         objAccount1.BillingCountry ='Colombia';
         objAccount1.Synergy_Account_Number__c = '10';
         objAccount1.Type = 'Partner';
         objAccount1.Lead_Oppty_Enabled__c = true;
         objAccount1.Partner_Type__c ='Distributor';
         objAccount1.Site_DUNS_Entity__c='001017771';
         objAccount1.PROFILED_ACCOUNT_FLAG__c = true;
         lstPartnerAccount.add(objAccount1);
         
       
         
         Account objAccount2 = new Account();
         objAccount2.name = 'TestPartnerAcc2';
         objAccount2.Party_Number__c = '1234';            
         objAccount2.BillingCountry ='Colombia';
         objAccount2.Synergy_Account_Number__c = '10';
         objAccount2.Type = 'Partner';
         objAccount2.Lead_Oppty_Enabled__c = true;
         objAccount2.Partner_Type__c ='Distribution VAR';
         objAccount2.Site_DUNS_Entity__c='002017771';
         objAccount2.PROFILED_ACCOUNT_FLAG__c = true;
         lstPartnerAccount.add(objAccount2);
         
         Account objAccount3 = new Account();
         objAccount3.name = 'TestPartnerAcc3';
         objAccount3.Party_Number__c = '1234';            
         objAccount3.BillingCountry ='Colombia';
         objAccount3.Synergy_Account_Number__c = '10';
         objAccount3.Type = 'Partner';
         objAccount3.Lead_Oppty_Enabled__c = false;
         objAccount3.Partner_Type__c ='Distribution VAR';
         objAccount3.Site_DUNS_Entity__c='002017771';
         objAccount3.PROFILED_ACCOUNT_FLAG__c = true;
         lstPartnerAccount.add(objAccount3);
         
         return lstPartnerAccount;
    }
    
     public static list<Account> CreateT2PartnerAccount(){
         List<Account> lstT2PartnerAccount= New List<Account>();
         
         Account objAccount2 = new Account();
         objAccount2.name = 'TestPartnerAcc2';
         objAccount2.Party_Number__c = '1234';            
         //objAccount2.BillingCountry ='Colombia';
         objAccount2.Synergy_Account_Number__c = '10';
         objAccount2.Type = 'Partner';
         objAccount2.Lead_Oppty_Enabled__c = true;
         objAccount2.Partner_Type__c ='Distribution VAR';
         objAccount2.PROFILED_ACCOUNT_FLAG__c = true;
         lstT2PartnerAccount.add(objAccount2);
         
         Account objAccount3 = new Account();
         objAccount3.name = 'TestPartnerAcc3';
         objAccount3.Party_Number__c = '1234';            
         objAccount3.BillingCountry ='Colombia';
         objAccount3.Synergy_Account_Number__c = '10';
         //objAccount3.Type = 'Partner';
         objAccount3.Lead_Oppty_Enabled__c = false;
         objAccount3.Partner_Type__c ='Distribution VAR';
         objAccount3.PROFILED_ACCOUNT_FLAG__c = true;
         lstT2PartnerAccount.add(objAccount3);
         
         return lstT2PartnerAccount;
     }
     
    public static Account_Groupings__c createAccountGrouping(Id accountid){
      Account_Groupings__c accGrp = new Account_Groupings__c();
            accGrp.Account__c = accountid ;
            accGrp.Name = 'Test-AccountGrp' ;
         return accGrp ;      
    }  

}