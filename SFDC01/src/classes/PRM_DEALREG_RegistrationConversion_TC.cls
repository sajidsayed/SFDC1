/*=====================================================================================================+
 |  HISTORY  |
 |  DATE          DEVELOPER               WR         DESCRIPTION 
 |  ====          =========               ==         =========== 
 |  28/06/2011    Anand Sharma                      This class is used to unit test  PRM_DEALREG_RegistrationConversion
 |  04/10/2011    Anand Sharma                      Updated test class to fix too many Query 
 |  20.10.2011    Shipra Misra          173695      Worked for Nov release.
                                                    Introduction new allaince partner & deleting existing ISV & Outsourcer field.Commenting existing code for ISV & Outsourcer.
 |  08/11/2011    Anand Sharma                      Fixed test class issue for Partner Field of opportinity record
 |  14/12/2011      Anil                            Removed Query for fetching Partner and used Custom setting Data Helper
    19/12/2012    Anand Sharma                      Exception Issue
 +=====================================================================================================*/
 
@isTest
private class PRM_DEALREG_RegistrationConversion_TC {

    static testMethod void myUnitTest() {
         
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1]; 
        User standardUser;           
        System.runAs(insertUser)
        {
            PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        List<Account> acc = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();       
        insert acc;
        Contact cont = UserProfileTestClassDataHelper.createContact();
        cont.AccountId=acc[0].Id;
        insert cont;
        System.runAs(insertUser){       
           Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
           String SystemAdmin = data.get('System Administrator').Name ;
           Profile SysAdminProf = [select Id from Profile where Name=: SystemAdmin];
           UserRole userRoles = [Select u.Id, u.Name from UserRole u where u.Name='Worldwide EMC Corporate'];
           standardUser = UserProfileTestClassDataHelper.createUser(SysAdminProf.Id, userRoles.Id);        
           insert standardUser;    
        }      
              
        
        System.RunAs(standardUser){
            Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
            Id accRecordTypeId = recordTypes.get('Customer Account Record Type').getRecordTypeId(); 
            
            /*Creating account record*/
            Account objAccount = new Account();
            objAccount.name = 'UNITTESTAcc';
            objAccount.Party_Number__c = '1234';
            objAccount.recordTypeId = accRecordTypeId;
            objAccount.BillingCountry ='India';
            objAccount.Synergy_Account_Number__c = '10';
            insert objAccount;
           
            Account objPartnerAccount = createAccount('UNITTESTAccPartner');
            Account objPartnerT2Account = createT2Account('UNITTESTAccT2Partner');
                  
            List<AccountTeamMember> lstATM = new List<AccountTeamMember>();
            AccountTeamMember objATM = new AccountTeamMember();
            objATM.AccountId =  objAccount.Id;
            objATM.TeamMemberRole ='Sales-Sales Rep';
            objATM.UserId = standardUser.Id;
            lstATM.add(objATM);
           
            AccountTeamMember objATM1 = new AccountTeamMember();
            objATM1.AccountId =  objAccount.Id;
            objATM1.TeamMemberRole ='Sales-Sales Rep';
            objATM1.UserId = standardUser.Id;
            lstATM.add(objATM1);
            
            insert lstATM; 
           
            Map<String,Schema.RecordTypeInfo> recordTypesDetails = Lead.sObjectType.getDescribe().getRecordTypeInfosByName();
            Id approvedDealregTypeId = recordTypesDetails.get('Deal Registration - Approved').getRecordTypeId();
            Lead objLead = new Lead();
            objLead.Company ='TestDealreg';
            objLead.DealReg_Deal_Description__c ='Deal Reg description';
            objLead.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
            objLead.CurrencyIsoCode ='USD';
            objLead.DealReg_Expected_Deal_Value__c =100;
            objLead.DealReg_Expected_Close_Date__c = System.today().addMonths(1);
            objLead.LastName ='DealregLastName';
            objLead.Email ='Dealreg1@dealreg.com';
            objLead.DealReg_Partner_Contact_First_Name__c ='testCFName';
            objLead.DealReg_Partner_Contact_Last_Name__c ='testLFname';
            objLead.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
            objLead.DealReg_Partner_Phone_Number__c = '98888888';
            objLead.Status = 'Approved';
            objLead.city = 'testcity' ;
            objLead.Country = 'Americas'; 
            objLead.Street = 'test Street';
            objLead.State = 'testState';
            objLead.PostalCode = 'test'; 
            objLead.Channel__c ='Direct';
            objLead.DealReg_PSC_Owner__c = standardUser.id;
            objLead.RecordTypeId = approvedDealregTypeId;
            objLead.DealReg_Deal_Registration__c = true;
            objLead.Related_Account__c =objAccount.Id;
            insert objLead;
           
            List<Lead> lstLead = new List<Lead>();
            lstLead.add(objLead);  
           
           
           
            Product2 objProduct = [Select Id, Name from Product2 where CurrencyIsoCode ='USD' limit 1];
           
            Partner_Product_Catalog__c objPPCatalog = new Partner_Product_Catalog__c();
            objPPCatalog.Name = objProduct.Name;
            objPPCatalog.Product__c = objProduct.Id;
            insert objPPCatalog;
           
            Registration_Product__c objRegProduct = new Registration_Product__c();
            objRegProduct.Deal_Registration__c = objLead.Id;
            objRegProduct.Partner_Product_Catalog__c = objPPCatalog.Id;
            insert objRegProduct;
           
            test.startTest();
           
            EMC_ConvertLead.convertLeads(lstLead);
           
            PRM_DEALREG_RegistrationConversion.updateSalesforceStatusOfLead(lstLead);
            
            PRM_DEALREG_RegistrationConversion.getOpportunityOwner(lstLead);
            
            Test.stopTest();
            /*
            System.Debug('objPartnerAccount---------->' + objPartnerAccount);
            // Creating OAR Rrecord for Named Partner with same Tier1 Partner.
            Opportunity Oppty = new Opportunity(Name = 'Test Opportunity ' 
                                ,AccountId= objAccount.Id
                                ,Sales_Force__c='EMC'
                                ,CurrencyIsoCode='USD'
                                ,Partner__c = objPartnerAccount.Id
                                ,Tier_2_Partner__c = objPartnerT2Account.Id
                                ,Tier_2_Partner_from_Deal_Reg__c =objAccount.Name
                                //Commenting ISV& Outsourcer field for Nov release.173965
                                //,Primary_ISV_Infrastructure__c= objAccount.Id
                               //,Primary_Outsourcer_System_Integrator__c = objAccount.Id
                               //*173965
                               , Opportunity_Owner__c=standardUser.Id, bypass_validation__c=true
                                 ,StageName ='Pipeline',CloseDate = System.today(),VCE_Related__c='VMWare Other',Amount = 500);
             
            //Insert the records that cause the trigger to execute.
            insert Oppty; 
            lstLead.get(0).Related_Opportunity__c = Oppty.Id;
            lstLead.get(0).Channel__c ='DIRECT';
            update lstLead; 
                   
            
            PRM_DEALREG_RegistrationConversion.validateRelatedOpportunity(lstLead);
            PRM_DEALREG_RegistrationConversion.syncDealRelatedOpportunity(lstLead);
            //PRM_DEALREG_RegistrationConversion.addProductOnOpportunity(convertedOpportunityMap);
            //PRM_DEALREG_RegistrationConversion.
           
            Map<String, Opportunity> convertedOpportunityMap = new Map<String, Opportunity>();
            convertedOpportunityMap.put(objLead.Id, Oppty);
            PRM_DEALREG_RegistrationConversion.addProductOnOpportunity(convertedOpportunityMap);
           
            List<Opportunity> lstOpprotunity = new List<Opportunity>();
            lstOpprotunity.add(Oppty);
            PRM_DEALREG_RegistrationConversion.updateDealStatusFromRelatedOpportunity(lstOpprotunity);
            lstLead.get(0).Sales_Force__c ='EMC';
            PRM_DEALREG_RegistrationConversion.getOpportunityOwner(lstLead);
            */
        }
    }
    
        
    public static testmethod void deployEMC_DealReg(){
      
    User  standardUser;   
    User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
           List<Account> acc = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();       
           insert acc;
           Contact cont = UserProfileTestClassDataHelper.createContact();
           cont.AccountId=acc[0].Id;
           insert cont;       
           System.runAs(insertUser)
           {       
           Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
           String SystemAdmin = data.get('System Administrator').Name ;
           Profile SysAdminProf = [select Id from Profile where Name=: SystemAdmin];
           UserRole userRoles = [Select u.Id, u.Name from UserRole u where u.Name='Worldwide EMC Corporate'];
           standardUser = UserProfileTestClassDataHelper.createUser(SysAdminProf.Id, userRoles.Id);        
           insert standardUser; 
           }                     
        
        
      Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
      Id accRecordTypeId = recordTypes.get('Customer Account Record Type').getRecordTypeId();
      /*Creating account record*/
       Account objAccount = new Account();
       objAccount.name = 'UNITTESTAcc';
       objAccount.Party_Number__c = '1234';
       objAccount.recordTypeId = accRecordTypeId;
       objAccount.BillingCountry ='India';
       objAccount.Synergy_Account_Number__c = '10';
       insert objAccount;
       
       List<AccountTeamMember> lstATM = new List<AccountTeamMember>();
       AccountTeamMember objATM = new AccountTeamMember();
       objATM.AccountId =  objAccount.Id;
       objATM.TeamMemberRole ='Sales-Sales Rep';
       objATM.UserId = standardUser.Id;
       lstATM.add(objATM);
       
       AccountTeamMember objATM1 = new AccountTeamMember();
       objATM1.AccountId =  objAccount.Id;
       objATM1.TeamMemberRole ='Sales-Sales Rep';
       objATM1.UserId = standardUser.Id;
       lstATM.add(objATM1);
       
       insert lstATM; 
       
       Map<String,Schema.RecordTypeInfo> recordTypesDetails = Lead.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id approvedDealregTypeId = recordTypesDetails.get('Deal Registration - Approved').getRecordTypeId();
     Lead objLead = new Lead();
     objLead.Company ='TestDealreg1';
     objLead.DealReg_Deal_Description__c ='Deal Reg description1';
     objLead.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification1';
     objLead.CurrencyIsoCode ='USD';
     objLead.DealReg_Expected_Deal_Value__c =100;
     objLead.DealReg_Expected_Close_Date__c = System.today().addMonths(1);
     objLead.LastName ='DealregLastName1';
     objLead.Email ='Dealreg11@dealreg.com';
     objLead.DealReg_Partner_Contact_First_Name__c ='testCFName1';
     objLead.DealReg_Partner_Contact_Last_Name__c ='testLFname1';
     objLead.DealReg_Partner_E_Mail_Address__c ='Dealreg11@dealreg.com';
     objLead.DealReg_Partner_Phone_Number__c = '988888882';
     objLead.Status = 'Submitted';
     objLead.DealReg_PSC_Owner__c = standardUser.id;
     objLead.RecordTypeId = approvedDealregTypeId;
     objLead.DealReg_Deal_Registration__c = true;
     objLead.Related_Account__c =objAccount.Id;
     objLead.DealReg_Deal_Registration__c = true;
     objLead.Channel__c ='Direct';
     objLead.city = 'testcity' ;
     objLead.Country = 'Americas'; 
     objLead.Street = 'test Street';
     objLead.State = 'testState';
     objLead.PostalCode = 'test';
       insert objLead;
       
       List<Lead> lstLead = new List<Lead>();
       lstLead.add(objLead);
       lstLead.get(0).Status ='Approved';
       EMC_ConvertLead.convertLeads(lstLead);
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
    
        Account objAccount = new Account(
            name = 'UNITTESTAcc',
            Party_Number__c = '1234',
            BillingCountry ='Colombia',
            Synergy_Account_Number__c = '10',
            Lead_Oppty_Enabled__c = true, 
            Partner_Type__c ='Distribution VAR',
            Type = 'Partner' ,
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
}