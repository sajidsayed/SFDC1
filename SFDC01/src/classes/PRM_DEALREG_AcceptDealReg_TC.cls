/*=====================================================================================================+
|  HISTORY  |                       
|  DATE          DEVELOPER               WR         DESCRIPTION 
  ====          =========               ==         =========== 
|  06/07/2011    Ashwini Gowda                      This class is used to unit testing for 
                                                    PRM_DEALREG_AcceptDealReg Class
    27 Dec 2011  Arif                               Removed two queries
|  11-JAN-2012    Anil                              Fixed Test class for Jan'12 Release
 +=====================================================================================================*/
@isTest
private class PRM_DEALREG_AcceptDealReg_TC
{  
    static list<string> lstProfile = new list<string>{'System Administrator','EMEA PSC User'};
    static map<String,Id> mapProfileId = new map<String,Id>();
    static list<Profile> profile = [SELECT Id,name FROM profile WHERE name in:lstProfile]; 
    static User usr1,usr2;
    static Lead newLead,newLead1;      
    static Profiles__c customSetting = new Profiles__c();
    static void testdata() {
        
        for(Profile pro: profile){
            mapProfileId.put(pro.name,pro.Id);
        }
        usr1   = [SELECT Id from User where ProfileId=:mapProfileId.get('System Administrator') and IsActive=True limit 1] ; 
        
        usr2   = [SELECT Id from User where ProfileId=:mapProfileId.get('EMEA PSC User') and IsActive=True limit 1] ;
       
        
        /*Map<String,Schema.RecordTypeInfo> recordTypes1 = Lead.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id accRecordTypeId = recordTypes1.get('Deal Registration - Approved').getRecordTypeId();
        static RecordType  rec = [Select id,name from RecordType where name='Deal Registration - Approved' and SobjectType ='Lead' 
                                and isActive=True limit 1]; */
           
        newLead = new lead(); 
        newLead1 = new lead();  
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Account objAccount = createAccount('UNITTESTAcc');
        Account RelatedAccount = createRelatedAccount('RelatedAvvt');
        Account RelatedAccount1 = createRelatedAccount('RelatedAvvt1');
        Account objT2Account = createT2Account('UNITTESTAcc1');
        createAccountShare(RelatedAccount1.id,usr2.id);
        System.runAs(usr1) 
        {       
          newLead.lastname = 'Test Lead';
          newLead.company = 'EMC';
          newLead.DealReg_PSC_Owner__c = usr1.ID;
          newLead.Status = 'New';
          newLead.DealReg_Create_New_Opportunity__c = True;
          newLead.DealReg_Deal_Description__c = 'test';
          newLead.DealReg_Deal_Registration_Justification__c = 'test';
          newLead.DealReg_Theater__c = 'APJ';
          newLead.Partner__c = objAccount.Id;
          newLead.DealReg_Deal_Registration_Status__c ='New';
          newLead.Channel__c = 'INDIRECT';
          newLead.DealReg_Deal_Registration__c = true;          
          newLead.Related_Account__c = RelatedAccount.id;
          newLead.Tier_2_Partner__c = objT2Account.Id;
          newLead.DealReg_Create_New_Opportunity__c = True;
          newLead.DealReg_Of_Registration_Products__c = 3;
          newLead.City ='India';
          newLead.Country__c ='United States';
          newLead.DealReg_Theater__c='Americas';
          newLead.Street ='Bangalore';
          newLead.DealReg_Department_Project_Name__c = 'ABCL';
          newLead.DealReg_Expected_Deal_Value__c = 12345.5; 
          newLead.Email = 'abc@abc.com';
          newLead.DealReg_Partner_Contact_First_Name__c = 'Test';
          newLead.DealReg_Partner_Contact_Last_Name__c = 'Test';
          newLead.phone = '2323455';
          Insert newLead;
        }
        
        System.runAs(usr2) 
        {       
          newLead1.lastname = 'Test Lead1';
          newLead1.company = 'EMC';
          newLead1.DealReg_PSC_Owner__c = usr2.ID;
          newLead1.Status = 'New';
          newLead1.DealReg_Deal_Description__c = 'test';
          newLead1.DealReg_Deal_Registration_Justification__c = 'test';
          newLead1.Partner__c = objAccount.Id;
          newLead1.DealReg_Theater__c = 'Americas';
          newLead1.DealReg_Deal_Registration_Status__c ='New';
          newLead1.Channel__c = 'INDIRECT';
          newLead1.DealReg_Deal_Registration__c = true;
          newLead1.Related_Account__c = RelatedAccount1.id;
          newLead1.Tier_2_Partner__c = objT2Account.Id;
          newLead1.DealReg_Create_New_Opportunity__c = True;
          newLead1.DealReg_Of_Registration_Products__c = 3;
          newLead1.City ='India';
          newLead1.Country__c ='United States';
          newLead1.DealReg_Theater__c='Americas';
          newLead1.Street ='Bangalore';
          newLead1.DealReg_Department_Project_Name__c = 'ABCL';
          newLead1.DealReg_Expected_Deal_Value__c = 12345.5; 
          newLead1.Email = 'abc@abc.com';
          newLead1.DealReg_Partner_Contact_First_Name__c = 'Test';
          newLead1.DealReg_Partner_Contact_Last_Name__c = 'Test';
          newLead1.phone = '784759';
          Insert newLead1;
        }        
        
    } 
    
   static testmethod void test1()
    {
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Test.startTest();         
        testdata();
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting');
        req1.setObjectId(newLead.id);
        Approval.ProcessResult result = Approval.process(req1);
        System.runAs(usr2) {    
            PRM_DEALREG_AcceptDealReg.AcceptDealReg(newLead.ID);
        }    
        newLead.DealReg_Deal_Registration_Status__c  = 'PSC Declined';
        newLead.DealReg_Comments__c = 'Rejected';
        newLead.DealReg_Rejection_Reason__c = 'Reject';
        newLead.External_Comments__c = 'Reject';
        newLead.DealReg_Create_New_Opportunity__c=true;
        newLead.Country__c ='United States';
        newLead.DealReg_Theater__c='Americas';        
        newLead.phone='7899033';
        update newLead;
        System.runAs(usr2) {
            PRM_DEALREG_AcceptDealReg.ApproveDealReg(newLead.ID); 
            PRM_DEALREG_AcceptDealReg.ApproveDealRegbutton(newLead.ID);
            PRM_DEALREG_AcceptDealReg.approve(String.valueof(newLead.ID)); 
        }
        Test.stopTest();
    } 
    
    static testmethod void test2()
    {
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        testdata();
          System.runAs(usr1) {
        
            Test.startTest(); 
                PRM_DEALREG_AcceptDealReg.ApproveDealReg(newLead1.ID); 
                PRM_DEALREG_AcceptDealReg.AcceptDealReg(newLead1.ID);
                                
                newLead1.DealReg_Theater__c = 'APJ';
                Update newLead1;
                PRM_DEALREG_AcceptDealReg.AcceptDealReg(newLead1.ID);
                
                newLead1.DealReg_Theater__c = NULL;
                //Update newLead1;
                PRM_DEALREG_AcceptDealReg.AcceptDealReg(newLead1.ID);
                newLead1.DealReg_Deal_Registration_Status__c = 'Approved';
                newLead1.Sales_Force__c = 'EMC';
                newLead1.DealReg_Create_New_Opportunity__c=true;
                newLead1.phone='5638899';
                //update newLead1;
                PRM_DEALREG_AcceptDealReg.ApproveDealReg(newLead1.ID); 
                                
            Test.stopTest();
          
          }
        
    } 
    
    
    
/* @Method <This method is used create Distributor accounts for the test class
            with same siteDuns Value>
@param <Taking string as paramter which contains account name>
@return <void> - <Account record>
@throws exception - <No Exception>
*/

  static Account createAccount(String accountName){
    Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id accRecordTypeId = recordTypes.get('T2_Partner Profile Record Type').getRecordTypeId();
        PRM_VPP_JobDataHelper.createVPPCustomSettingData(); 
    
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
    
    static Account createT2Account(String accountName){
    Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id accRecordTypeId = recordTypes.get('T2_Partner Profile Record Type').getRecordTypeId();
        PRM_VPP_JobDataHelper.createVPPCustomSettingData(); 
    
        Account objAccount = new Account(
            name = 'UNITTESTAcc',
            Party_Number__c = '1234',
            BillingCountry ='Colombia',
            Synergy_Account_Number__c = '10',
            Lead_Oppty_Enabled__c = true, 
            Partner_Type__c ='Distribution VAR',
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
    
     static Account createRelatedAccount(String accountName){
        //Creating the dummy account for test class.
        PRM_VPP_JobDataHelper.createVPPCustomSettingData(); 
        Account account = new Account(
            name=accountName,
            CurrencyIsoCode='USD',
            Site_DUNS_Entity__c = '123456',
            Global_DUNS_Entity__c = '663399'
        );
        //usr2
        System.runAs(usr1) {
            insert account;
        }
        return account;
    }
    
    static void createAccountShare(String accountId,String UserId){
        PRM_VPP_JobDataHelper.createVPPCustomSettingData(); 
        AccountShare acctshare = new AccountShare();
        acctshare.AccountAccessLevel = 'Edit';
        acctshare.AccountId = accountId;
        acctshare.UserOrGroupId  = UserId;
        acctshare.OpportunityAccessLevel = 'Edit';
        insert acctshare;
    }
}