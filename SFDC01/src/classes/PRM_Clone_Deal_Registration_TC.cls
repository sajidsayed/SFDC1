/*=====================================================================================================+
 |  HISTORY  |
 |  DATE          DEVELOPER               WR         DESCRIPTION 
 |  ====          =========               ==         =========== 
 |  24/05/2012    Anirudh Singh           189663  	 This class is used to unit test  PRM_Clone_Deal_Registration
 +=====================================================================================================*/
@isTest
public class PRM_Clone_Deal_Registration_TC {	
/*  @Method <This method is used create DealRegistration for the test class>.   
    @param - <void>  
    @return <Lead> - <Lead record>   
    @throws exception - <No Exception>
*/    
    Static Lead createDealReg(){
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
        newLead.DealReg_Pre_Sales_Engineer_Name__c = 'Test1';
        newLead.DealReg_Pre_Sales_Engineer_Phone__c = '75964';
        newLead.DealReg_Pre_Sales_Engineer_Email__c = 'test@t.com';
        newLead.DealReg_EMCTA_Certified_Email__c = 'test@tt.com';
        insert newLead;
        return newLead;
    }
/*  @Method <This method is used create Test Account for the test class>.   
    @param - <void>  
    @return <Account> - <Account Record>   
    @throws exception - <No Exception>
*/ 
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
	            recordtypeid= accRecordTypeId           
	        );
	        insert objAccount;
	        User systemAdminUser = [Select Id,Name from User where Profile.Name ='System Administrator' and IsActive = true limit 1];
	        System.RunAs(systemAdminUser){
		        objAccount.Lead_Oppty_Enabled__c = true;
		        objAccount.Type = 'Partner';
		        objAccount.Status__c='A';
		        objAccount.PROFILED_ACCOUNT_FLAG__c=true;
		        update objAccount;
	        }            
	        return objAccount;
	}
/*  @Method <This method is used to unit test Clone Deal Registration>.   
    @param - <void>  
    @return <Lead> - <Lead record>   
    @throws exception - <No Exception>
*/	
	private static testMethod void cloneDealRegistration(){    
	   lead TesLead = createDealReg();
	   Product2 objProduct = [Select Id, Name from Product2 where CurrencyIsoCode ='USD' limit 1];       
      
       Partner_Product_Catalog__c objPPCatalog = new Partner_Product_Catalog__c();
       objPPCatalog.Name = objProduct.Name;
       objPPCatalog.Product__c = objProduct.Id;
       insert objPPCatalog;
       
       Registration_Product__c objRegProduct = new Registration_Product__c();
       objRegProduct.Deal_Registration__c = TesLead.Id;
       objRegProduct.Partner_Product_Catalog__c = objPPCatalog.Id;
       
       insert objRegProduct;
       PRM_Clone_Deal_Registration.cloneDealRegistration(TesLead.Id);
	}
}