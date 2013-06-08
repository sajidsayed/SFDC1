/*=====================================================================================================+
|  HISTORY  |                       
|  DATE          DEVELOPER               WR         DESCRIPTION 
  ====          =========               ==         =========== 
|  06/07/2011    Ashwini Gowda                      This class is used to unit testing for 
                                                    PRM_DEALREG_ApprovalRouting Class
|  12/07/2011    Anirudh Singh                      Updated Test Data Creation as per the Validation Rules.   
   11/1/2011     Prasad                             Fix issue 101 SOQL limit     
   2 Dec 2011    Arif                               Updated createLead method to populate some mandatory fields for entering in approval process.
 | 11-JAN-2012    Anil                              Fixed Test Class for Jan'12 Release   
   11 April 2012  Arif                189527        Commented lines where 'DealReg_Extension_Justification__c' field is involved 
                                                    to change the data type of the field.    
   11 April 2012  Arif                189527        Uncommented back all the lines where 'DealReg_Extension_Justification__c' field
                                                    involved after changing data type.
   11 April 2012  Arif                189648        Changed the status of lead to 'Submitted' in createLead method
                                                    for bypassing a new validation rule. 
   02 May 2012    Arif                              Deleting EMEA DR Routing Mapping and EMEA Field Representative object.Commented lines  
   30 Nov 2012    Vivek                             Added custom setting.   
   07 Jan 2013    Krishna                           Test Class erros fix.                                       
 +=====================================================================================================*/
@isTest
private class PRM_DEALREG_ApprovalRouting_TC  
{  
    static Profile profile1 = [SELECT Id FROM profile WHERE name='System Administrator']; 
    static User usr1   = [SELECT Id from User where ProfileId=:profile1.id and IsActive=True limit 1] ;  
       
    /**/
    
    /* @Method <This method is used create Distributor accounts for the test class
                with same siteDuns Value>
    @param <Taking string as paramter which contains account name>  
    @return <void> - <Account record>
    @throws exception - <No Exception>
    */

    public static Account createAccount(String accountName){
        Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id accRecordTypeId = recordTypes.get('Customer Account Record Type').getRecordTypeId();
        
        //Creating the dummy account for test class.
        Account objAccount = new Account(
            name = accountName,
            Party_Number__c = '1234',
            //recordTypeId = accRecordTypeId,
            BillingCountry ='Colombia',
            Synergy_Account_Number__c = '10',
            Type = 'Partner' ,
            Lead_Oppty_Enabled__c = true, 
            Partner_Type__c ='Distributor'
            
        );
        insert objAccount;
        objAccount.Lead_Oppty_Enabled__c = true;
        objAccount.PROFILED_ACCOUNT_FLAG__c = true;        
        objAccount.Type = 'Partner';
        objAccount.Status__c='A';
        update objAccount;
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
        objAccount.PROFILED_ACCOUNT_FLAG__c = true;
        objAccount.Status__c='A';
        update objAccount;
        System.Debug('objAccount ----> ' + objAccount) ;       
        return objAccount;
    }
    
    // To cover calculateQuaterDate methods 
    static testmethod void createLeadShareForQueues()
    {
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        User user01;
        System.runAs(insertUser)
                {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
                }
        //PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        List<Lead> lstLead =createTestData(); 
        Map<Id,Lead> newLeadMap = new Map<Id,Lead>();
        Map<Id,Lead> oldLeadMap = new Map<Id,Lead>();
        if(lstLead.size()>0){
          for(Lead deal: lstLead){
            newLeadMap.put(deal.id,deal);            
          }             
        } 
        if(lstLead.size()>0){
          for(Lead deal: lstLead){
            deal.DealReg_Deal_Registration_Status__c='Approved';
            oldLeadMap.put(deal.id,deal);
          }
          //update lstLead; 
        }
                
        Test.startTest(); 
            PRM_DEALREG_ApprovalRouting objApprovalRouting = new PRM_DEALREG_ApprovalRouting();
            for(Lead objLeadStatus :lstLead){
                objLeadStatus.Status = 'Submitted';
                objLeadStatus.phone='2323556';
            }
            System.Debug('lstLead -----> ' + lstLead);  
             Deal_Reg_Approval_Date_Check__c objdatecheck = new Deal_Reg_Approval_Date_Check__c(Name ='Deal Reg Approval Date',Approval_Date__c =date.valueof('2013-01-01'));
            database.upsert(objdatecheck,false);
            objApprovalRouting.createLeadShareForQueues(lstLead);   
            objApprovalRouting.autoPopulateExpirationDate(newLeadMap,oldLeadMap);         
        Test.stopTest();
        
    } 
    
    static testmethod void createExtensionShareForQueues()
    {
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        User user01;
        System.runAs(insertUser)
                {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
                }
        Set<Id> setLeadids = new Set<Id>();
        List<Lead> lstLead =createTestData();
        
        List<Extension_Request__c> lstEtnReq = createExtensionRequest();  
        Map<Id,Extension_Request__c> mapEtnReqOld = new map<Id,Extension_Request__c>();
        Map<Id,Extension_Request__c> mapEtnReqNew = new map<Id,Extension_Request__c>();
        for(Extension_Request__c objExtn: lstEtnReq){
            mapEtnReqNew.put(objExtn.Id, objExtn);
            lstLead.get(0).DealReg_Deal_Registration_Status__c ='Submitted';
            objExtn.Extension_Request_Status__c ='Submitted';
            objExtn.Deal_Registration__c = lstLead.get(0).Id;
            mapEtnReqOld.put(objExtn.Id, objExtn);
        }            
        Test.startTest();                    
            
            PRM_DEALREG_ApprovalRouting objApprovalRouting = new PRM_DEALREG_ApprovalRouting();
            for(Lead objLeadStatus :lstLead){
                setLeadids.add(objLeadStatus.Id);
                objLeadStatus.DealReg_Deal_Registration_Status__c = 'Submitted';
            }
            System.Debug('lstLead -----> ' + lstLead);  
            objApprovalRouting.createExtensionShareForQueues(mapEtnReqNew, mapEtnReqOld); 
            lstEtnReq.get(0).Extension_Request_Status__c ='Approved';
           // PRM_DEALREG_ApprovalRouting.calculateQuaterDate(5);
            date expiration = date.valueOf('2013-02-02');
            PRM_DEALREG_ApprovalRouting.calculateQuaterDate(5,expiration);
            PRM_DEALREG_ApprovalRouting.updateSLAFieldRepExpirationDateForDR();
            PRM_DEALREG_ApprovalRouting.updateSLAFieldRepExpirationDateForER();
            PRM_DEALREG_ApprovalRouting.calculateNOOfExtensions(lstEtnReq) ;   
            PRM_DEALREG_ApprovalRouting.extendExpirationDate (lstEtnReq);
            PRM_DEALREG_ApprovalRouting.getRelatedAccountMembersForUsers(lstLead);
            PRM_DEALREG_ApprovalRouting.getRelatedAccountMembersForExtensionForUsers(lstEtnReq);
            //PRM_DEALREG_ApprovalRouting.autoApproveFirstStepDRForEMEA(setLeadids); 
            
            
                   
        Test.stopTest();
        
    }
    
        
    static List<Extension_Request__c> createExtensionRequest(){
        Extension_Request__c objExtn = new Extension_Request__c();
        objExtn.Extension_Request_Status__c='Submitted';
        objExtn.Expected_Close_Date__c = System.today().addMonths(1);
        objExtn.DealReg_Extension_Justification__c ='test';
        
        
        insert objExtn; 
        
        List<Extension_Request__c> lstER = new List<Extension_Request__c>();
        lstER.add(objExtn);
        
        return lstER;
    }
    static List<Lead> createTestData(){
        User standardUser  = [Select Id, BU_Attribute__c, Contact.Account.Owner.Email, Contact.Account.Name
                                From user where isActive = true and (BU_Attribute__c like '%core%' )   AND ProfileId ='00e70000000wBza' limit 1];                       
        
        Profile profile2 = [SELECT Id FROM profile WHERE name='EMEA PSC User']; 
      User usr2   = [SELECT Id from User where ProfileId=:profile2.id and IsActive=True limit 1] ; 
      
      Profile profile3 = [SELECT Id FROM profile WHERE name='AMER PSC User'];
      User usr3   = [SELECT Id from User where ProfileId=:profile3.id and IsActive=True limit 1] ;
      
      Profile profile4 = [SELECT Id FROM profile WHERE name='APJ PSC User'];
      User usr4   = [SELECT Id from User where ProfileId=:profile4.id and IsActive=True limit 1] ;
        
        Account objPartnerAccount = createAccount('UNITTESTAcc');
        Account objT2Account = createT2Account('UNITTESTAcc1');
        
        //System.RunAs(standardUser){
        Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id accRecordTypeId = recordTypes.get('Customer Account Record Type').getRecordTypeId(); 
        
        /*Creating account record*/
        Account objAccount = new Account();
        objAccount.name = 'UNITTESTAcc';
        objAccount.Party_Number__c = '1234';
        objAccount.recordTypeId = accRecordTypeId;
        objAccount.BillingCountry ='Colombia';
        objAccount.Synergy_Account_Number__c = '10';
        insert objAccount;
        
        List<Lead> lstLead = new List<Lead>();
        
        Map<String,Schema.RecordTypeInfo> recordTypesDetails = Lead.sObjectType.getDescribe().getRecordTypeInfosByName();
        //Id approvedDealregTypeId = recordTypesDetails.get('Deal Registration - Approved').getRecordTypeId();
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
        objLead.Status = 'Submitted';
        objLead.DealReg_PSC_Owner__c = usr3.id;
        //objLead.RecordTypeId = approvedDealregTypeId;
        objLead.DealReg_Deal_Registration__c = true;
        objLead.Related_Account__c =objAccount.Id;
        objLead.DealReg_Theater__c ='Americas';
        objLead.DealReg_Deal_Registration_Status__c ='Submitted';
        objLead.DealReg_Of_Registration_Products__c = 5;
        objLead.DealReg_Deal_Registration__c = true;
        objLead.DealReg_Create_New_Opportunity__c =true;
        objLead.Partner__c = objPartnerAccount.Id;
        objLead.Channel__c = 'INDIRECT';   
        objLead.City = 'Bangalore';
        objLead.Country__c = 'India';
        objLead.Street = 'Bangalore';
        objLead.Sales_Force__c = 'EMC';
        objLead.phone = '2334566';
        lstLead.add(objLead);
        
        
        
        Lead objLead1 = new Lead();
        objLead1.Company ='TestDealreg';
        objLead1.DealReg_Deal_Description__c ='Deal Reg description';
        objLead1.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
        objLead1.CurrencyIsoCode ='USD';
        objLead1.DealReg_Expected_Deal_Value__c =100;
        objLead1.DealReg_Expected_Close_Date__c = System.today().addMonths(1);
        objLead1.LastName ='DealregLastName';
        objLead1.Email ='Dealreg1@dealreg.com';
        objLead1.DealReg_Partner_Contact_First_Name__c ='testCFName';
        objLead1.DealReg_Partner_Contact_Last_Name__c ='testLFname';
        objLead1.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
        objLead1.DealReg_Partner_Phone_Number__c = '98888888';
        objLead1.Status = 'Submitted';
        objLead1.DealReg_Theater__c ='EMEA';
        objLead1.DealReg_PSC_Owner__c = usr2.id;
        //objLead1.RecordTypeId = approvedDealregTypeId;
        objLead1.DealReg_Deal_Registration__c = true;
        objLead1.Related_Account__c =objAccount.Id;
        objLead1.DealReg_Deal_Registration_Status__c ='Submitted';
        objLead1.DealReg_Of_Registration_Products__c = 5;
        objLead1.DealReg_Deal_Registration__c = true;
        objLead1.DealReg_Create_New_Opportunity__c =true;
        objLead1.Tier_2_Partner__c = objT2Account.Id;
        objLead1.Partner__c = objPartnerAccount.Id;
        objLead1.Channel__c = 'INDIRECT'; 
        objLead1.City = 'Bangalore';
        objLead1.Country__c = 'India';
        objLead1.Street = 'Bangalore';
        objLead1.Sales_Force__c = 'EMC';
        objLead1.phone = '6788993';
        lstLead.add(objLead1);
        
        Lead objLead2 = new Lead();
        objLead2.Company ='TestDealreg';
        objLead2.DealReg_Deal_Description__c ='Deal Reg description';
        objLead2.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
        objLead2.CurrencyIsoCode ='USD';
        objLead2.DealReg_Expected_Deal_Value__c =100;
        objLead2.DealReg_Expected_Close_Date__c = System.today().addMonths(1);
        objLead2.LastName ='DealregLastName';
        objLead2.Email ='Dealreg1@dealreg.com';
        objLead2.DealReg_Partner_Contact_First_Name__c ='testCFName';
        objLead2.DealReg_Partner_Contact_Last_Name__c ='testLFname';
        objLead2.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
        objLead2.DealReg_Partner_Phone_Number__c = '98888888';
        objLead2.Status = 'Submitted';
        objLead2.DealReg_Theater__c ='APJ';
        objLead2.DealReg_PSC_Owner__c = usr4.id;
        //objLead2.RecordTypeId = approvedDealregTypeId;
        objLead2.DealReg_Deal_Registration__c = true;
        objLead2.Related_Account__c =objAccount.Id;
        objLead2.DealReg_Deal_Registration_Status__c ='Submitted';
        objLead2.DealReg_Of_Registration_Products__c = 5;
        objLead2.DealReg_Deal_Registration__c = true;
        objLead2.DealReg_Create_New_Opportunity__c =true;
        objLead2.Partner__c = objPartnerAccount.Id;
        objLead2.Channel__c = 'INDIRECT';
        objLead2.City = 'Bangalore';
        objLead2.Country__c = 'India';
        objLead2.Street = 'Bangalore'; 
        objLead2.Sales_Force__c = 'EMC';
        objLead2.phone = '7897934';
        lstLead.add(objLead2);
        
        Lead objLead3 = new Lead();
        objLead3.Company ='TestDealreg';
        objLead3.DealReg_Deal_Description__c ='Deal Reg description';
        objLead3.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
        objLead3.CurrencyIsoCode ='USD';
        objLead3.DealReg_Expected_Deal_Value__c =100;
        objLead3.DealReg_Expected_Close_Date__c = System.today().addMonths(1);
        objLead3.LastName ='DealregLastName';
        objLead3.Email ='Dealreg1@dealreg.com';
        objLead3.DealReg_Partner_Contact_First_Name__c ='testCFName';
        objLead3.DealReg_Partner_Contact_Last_Name__c ='testLFname';
        objLead3.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
        objLead3.DealReg_Partner_Phone_Number__c = '98888888';
        objLead3.Status = 'Submitted';
        objLead3.DealReg_Deal_Registration_Status__c ='Submitted';
        objLead3.DealReg_Theater__c ='APJ';
        objLead3.DealReg_PSC_Owner__c = usr4.id;
        //objLead3.RecordTypeId = approvedDealregTypeId;
        objLead3.DealReg_Deal_Registration__c = true;
        objLead3.Related_Account__c =objAccount.Id;
        objLead3.DealReg_Of_Registration_Products__c = 5;
        objLead3.DealReg_Deal_Registration__c = true;
        objLead3.DealReg_Create_New_Opportunity__c =true;
        objLead3.Partner__c = objPartnerAccount.Id;
        objLead3.Channel__c = 'INDIRECT'; 
        objLead3.City = 'Bangalore';
        objLead3.Country__c = 'India';
        objLead3.Street = 'Bangalore';
        objLead3.Sales_Force__c = 'EMC'; 
        objLead3.phone = '7883984';
        lstLead.add(objLead3);
        
        Lead objLeadAmericas = new Lead();
        objLeadAmericas.Company ='TestDealreg';
        objLeadAmericas.DealReg_Deal_Description__c ='Deal Reg description';
        objLeadAmericas.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
        objLeadAmericas.CurrencyIsoCode ='USD';
        objLeadAmericas.DealReg_Expected_Deal_Value__c =100;
        objLeadAmericas.DealReg_Expected_Close_Date__c = System.today().addMonths(1);
        objLeadAmericas.LastName ='DealregLastName';
        objLeadAmericas.Email ='Dealreg1@dealreg.com';
        objLeadAmericas.DealReg_Partner_Contact_First_Name__c ='testCFName';
        objLeadAmericas.DealReg_Partner_Contact_Last_Name__c ='testLFname';
        objLeadAmericas.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
        objLeadAmericas.DealReg_Partner_Phone_Number__c = '98888888';
        objLeadAmericas.Status = 'Submitted';
        objLeadAmericas.DealReg_PSC_Owner__c = usr3.id;
        //objLeadAmericas.RecordTypeId = approvedDealregTypeId;
        objLeadAmericas.DealReg_Deal_Registration__c = true;
        objLeadAmericas.Related_Account__c =objAccount.Id;
        objLeadAmericas.DealReg_Theater__c ='Americas';
        objLeadAmericas.DealReg_Deal_Registration_Status__c ='Submitted';
        objLeadAmericas.DealReg_Of_Registration_Products__c = 5;
        objLeadAmericas.DealReg_Deal_Registration__c = true;
        objLeadAmericas.DealReg_Create_New_Opportunity__c =true;
        objLeadAmericas.Partner__c = objPartnerAccount.Id;
        objLeadAmericas.Channel__c = 'INDIRECT'; 
        objLeadAmericas.City = 'Bangalore';
        objLeadAmericas.Country__c = 'India';
        objLeadAmericas.Street = 'Bangalore'; 
        objLeadAmericas.Sales_Force__c = 'EMC';
        objLeadAmericas.phone = '23455667';
        lstLead.add(objLeadAmericas);
        insert lstLead;
        return lstLead;
    }
    
    /* static testmethod void createLeadExtensionTest()
    {
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        User user01;
        System.runAs(insertUser)
                {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
                }
        //PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        Map<String,Schema.RecordTypeInfo> recordTypesDetails = Lead.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id approvedDealregTypeId = recordTypesDetails.get('Deal Registration - Approved').getRecordTypeId();
        
        User standardUser  = [Select Id, BU_Attribute__c, Contact.Account.Owner.Email, Contact.Account.Name
                                From user where isActive = true and (BU_Attribute__c like '%core%' )   
                                AND ProfileId =:profile1.Id limit 1];
        Profile profile2 = [SELECT Id FROM profile WHERE name='EMEA PSC User']; 
      User usr2   = [SELECT Id from User where ProfileId=:profile2.id and IsActive=True limit 1] ;
      
        //System.RunAs(standardUser){
        Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id accRecordTypeId = recordTypes.get('Customer Account Record Type').getRecordTypeId(); 
        
        Account objPartnerAccount = createAccount('UNITTESTAcc');
        Account objT2Account = createT2Account('UNITTESTAcc1');
        
        //Creating account record
        Account objAccount = new Account();
        objAccount.name = 'UNITTESTAcc';
        objAccount.Party_Number__c = '1234';
        objAccount.recordTypeId = accRecordTypeId;
        objAccount.BillingCountry = 'United States';
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
        
         Opportunity Oppty = new Opportunity(Name = 'Test Opportunity ' 
                            ,AccountId= objAccount.Id
                            ,Sales_Force__c='EMC'
                            ,CurrencyIsoCode='USD'
                            ,Partner__c = objPartnerAccount.Id
                            ,Tier_2_Partner__c = objT2Account.Id
                            ,Tier_2_Partner_from_Deal_Reg__c =objAccount.Name
                            , Opportunity_Owner__c=standardUser.Id, bypass_validation__c=true
                             ,StageName ='Pipeline',CloseDate = System.today(),VCE_Related__c='VMWare Other',Amount = 500);
         
        insert Oppty;
                                       
        Lead objLeadAmericas = new Lead();
        objLeadAmericas.Company ='TestDealreg';
        objLeadAmericas.DealReg_Deal_Description__c ='Deal Reg description';
        objLeadAmericas.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
        objLeadAmericas.CurrencyIsoCode ='USD';
        objLeadAmericas.DealReg_Expected_Deal_Value__c =100;
        objLeadAmericas.DealReg_Expected_Close_Date__c = System.today().addMonths(1);
        objLeadAmericas.LastName ='DealregLastName';
        objLeadAmericas.Email ='Dealreg1@dealreg.com';
        objLeadAmericas.DealReg_Partner_Contact_First_Name__c ='testCFName';
        objLeadAmericas.DealReg_Partner_Contact_Last_Name__c ='testLFname';
        objLeadAmericas.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
        objLeadAmericas.DealReg_Partner_Phone_Number__c = '98888888';
        objLeadAmericas.Status = 'Submitted';
        objLeadAmericas.DealReg_PSC_Owner__c = usr2.id;
        //objLeadAmericas.RecordTypeId = approvedDealregTypeId;
        objLeadAmericas.DealReg_Deal_Registration__c = true;
        objLeadAmericas.Related_Account__c =objAccount.Id;
        objLeadAmericas.DealReg_Theater__c ='EMEA';
        objLeadAmericas.DealReg_Deal_Registration_Status__c ='Submitted';
        objLeadAmericas.DealReg_Of_Registration_Products__c = 5;
        objLeadAmericas.DealReg_Deal_Registration__c = true;
        objLeadAmericas.DealReg_Create_New_Opportunity__c =true;
        objLeadAmericas.DealReg_of_Extension_Requests__c =2;
        objLeadAmericas.DealReg_Field_SLA_Expire_on__c =  DateTime.Now().addMinutes(2);
        objLeadAmericas.Partner__c = objPartnerAccount.Id;
        objLeadAmericas.Tier_2_Partner__c = objT2Account.Id;
        objLeadAmericas.Country__c = 'United States';
        objLeadAmericas.Channel__c = 'INDIRECT'; 
        objLeadAmericas.City = 'New York';        
        objLeadAmericas.Street = 'South Hampton'; 
        objLeadAmericas.Sales_Force__c = 'EMC';
        objLeadAmericas.Related_Opportunity__c=Oppty.Id;
        objLeadAmericas.Channel__c='DIRECT';
        insert objLeadAmericas;
        
        Account profiledAccount = [SELECT id,name,PROFILED_ACCOUNT_FLAG__c,Grouping__c,Site_DUNS_Entity__c,Type,Status__c 
                      FROM Account 
                      where PROFILED_ACCOUNT_FLAG__c=false and Grouping__c=null and Status__c='A' and Type='Partner' limit 1];
        
        Account_Groupings__c objGrouping = new Account_Groupings__c();
        Map<String,Schema.RecordTypeInfo> recordTypesId = Account_Groupings__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id partnerGroupingId = recordTypesId.get('Partner Grouping').getRecordTypeId();        
        objGrouping.Name = 'TestClass323';
        objGrouping.Active__c = true;
        objGrouping.Profiled_Account__c = profiledAccount.id;
        objGrouping.No_Master_Required__c = true;
        objGrouping.RecordTypeId = partnerGroupingId;
        
        insert objGrouping;
        
       /* EMEA_DR_Routing_Mapping__c objRM = new EMEA_DR_Routing_Mapping__c();
        objRM.Master_Grouping__c = objGrouping.Id;
        objRM.Prospect_Country__c = 'United States';
        insert objRM;
        
        Field_Representative__c objFR = new Field_Representative__c();
        objFR.EMEA_DR_Routing_Mapping__c = objRM.Id;
        objFR.Field_Rep__c = Userinfo.getUserId();
        insert objFR;
        
        List<DealRegistration_CustomSetting__c> lstDataValue = new List<DealRegistration_CustomSetting__c>();
        DealRegistration_CustomSetting__c dataValueControlFlag2 = new DealRegistration_CustomSetting__c();
        dataValueControlFlag2.Name ='DistributionVARSuperUsers';
        dataValueControlFlag2.ParnterProfileID__c = Userinfo.getProfileId();
        lstDataValue.add(dataValueControlFlag2);        
        try
        {
           Database.upsert(lstDataValue, false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }
        System.Debug('lstDataValue  ----> '+ lstDataValue);
        PRM_DEALREG_ApprovalRouting.updateSLAFieldRepExpirationDateForDR();
        
        Extension_Request__c objExtn = new Extension_Request__c();
        objExtn.Extension_Request_Status__c='New';
        objExtn.Expected_Close_Date__c = System.today().addMonths(1);
        objExtn.DealReg_Extension_Justification__c ='test' ;//+ i;
        objExtn.DealReg_Field_SLA_Expire_on__c = DateTime.Now().addMinutes(2);        
        objExtn.Approval_Status__c = 'Submitted By Field Rep';
        objExtn.Deal_Registration__c =objLeadAmericas.Id;
        objExtn.Extension_Request_Status__c='Submitted';
        insert objExtn;
        
        //objExtn.Extension_Request_Status__c='Submitted';
       // update objExtn;
        
        Map<Id, Extension_Request__c> mapER =new  Map<Id,Extension_Request__c>();
        mapER.put(objExtn.Id, objExtn);
        Map<Id,Map<Id,Extension_Request__c>> extensionwithGroupingMap = new Map<Id,Map<Id,Extension_Request__c>>();
        //extensionwithGroupingMap.put(objRM.Id,mapER);
        Set<String> setCountry = new Set<String>();
        setCountry.add('test');
      //  PRM_DEALREG_ApprovalRouting.getEmeaRoutingMappingForExtensionRequestForUsers(extensionwithGroupingMap, setCountry);
 
        
        PRM_DEALREG_ApprovalRouting.updateSLAFieldRepExpirationDateForER();              
        
    } */
    
    static testmethod void testApprovalProcess(){
     User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        User user01;
        System.runAs(insertUser)
                {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
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
       
       Account objPartnerAccount = createAccount('UNITTESTAccPartner');
       Account objPartnerT2Account = createT2Account('UNITTESTAccT2Partner');
       
       
                
       Opportunity Oppty = new Opportunity(Name = 'Test Opportunity ' 
                            ,AccountId= objAccount.Id
                            ,Sales_Force__c='EMC'
                            ,CurrencyIsoCode='USD'
                            ,Partner__c = objPartnerAccount.Id
                            ,Tier_2_Partner__c = objPartnerT2Account.Id
                            ,Tier_2_Partner_from_Deal_Reg__c =objAccount.Name
                            ,StageName ='Pipeline',CloseDate = System.today(),VCE_Related__c='VMWare Other',Amount = 500);
         
        //Insert the records that cause the trigger to execute.
        insert Oppty; 
         
      Profile profile2 = [SELECT Id FROM profile WHERE name='EMEA PSC User']; 
      User usr2   = [SELECT Id from User where ProfileId=:profile2.id and IsActive=True limit 1] ; 
      
      PRM_DEALREG_ApprovalRouting approvalRouting = new PRM_DEALREG_ApprovalRouting();
      //approvalRouting.getLead();
      
      //Account RelatedAccount = createRelatedAccount('RelatedAcct');
      Lead emeaDR = createLead('EMEA',usr2.id);
      emeaDR.Related_Opportunity__c = Oppty.Id;
      emeaDR.Channel__c ='DIRECT';
      update emeaDR;
     
      List<Extension_Request__c> extensionsList = new List<Extension_Request__c>();
      List<Lead> emeaDRList = new List<Lead>();
      
      //Extension_Request__c extensionReq = createExtension(emeaDR.id);
      
      /*Approval.ProcessSubmitRequest erRequest = new Approval.ProcessSubmitRequest();
        erRequest.setComments('Submitting request for approval.');
        erRequest.setObjectId(extensionReq.id);
        
        Approval.ProcessResult extResult = Approval.process(erRequest);*/
        
        Test.startTest();
       Approval.ProcessSubmitRequest drRequest = new Approval.ProcessSubmitRequest();
        drRequest.setComments('Submitting request for approval.');
        drRequest.setObjectId(emeaDR.id);
        Approval.ProcessResult drResult = Approval.process(drRequest);
        
        /*ApexPages.currentpage().getParameters().put('rejectDR','DealReg');
        
        ApexPages.StandardController controller = new ApexPages.StandardController(emeaDR);  
        PRM_DEALREG_ApprovalRouting approvalProcess = new PRM_DEALREG_ApprovalRouting(controller);
        
        System.runAs(usr2){
          approvalRouting.SaveRejection();
        }*/
        Test.stopTest();
    } 
    
    
    static testmethod void testApprovalProcess2(){
    
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        User user01;
        System.runAs(insertUser)
                {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
                }   
      //PRM_VPP_JobDataHelper.createVPPCustomSettingData();      
      Profile profile2 = [SELECT Id FROM profile WHERE name='APJ PSC User']; 
      User usr2   = [SELECT Id from User where ProfileId=:profile2.id and IsActive=True limit 1];
      
     // Profile profile3 = [SELECT Id FROM profile WHERE name='EMEA PSC User']; 
      //User usr3   = [SELECT Id from User where ProfileId=:profile2.id and IsActive=True limit 1];  
      
      //Account objPartnerAccount = createAccount('UNITTESTAcct2');
      //Account RelatedAccount = createRelatedAccount('RelatedAcct2');
      Lead apjDR = createLead('APJ',usr2.id);
      
      //Lead emeaDR = createLead('APJ',usr2.id);
      Set<Id> setExtnId = new Set<Id>();
      Set<Id> setDRId = new Set<Id>();       
      Extension_Request__c extensionReq = createExtension(apjDR.id);
      //Extension_Request__c extensionReq2 = createExtension(emeaDR.id);
      setExtnId.add(extensionReq.id);
      
      Approval.ProcessSubmitRequest erRequest = new Approval.ProcessSubmitRequest();
        erRequest.setComments('Submitting request for approval.');
        erRequest.setObjectId(extensionReq.id);
        Approval.ProcessResult extResult = Approval.process(erRequest);      
      
      /*Approval.ProcessSubmitRequest drRequest = new Approval.ProcessSubmitRequest();
        drRequest.setComments('Submitting request for approval.');
        drRequest.setObjectId(emeaDR.id);
        Approval.ProcessResult drResult = Approval.process(drRequest);*/
      //setDRId.add(emeaDR.id);
      
      /*Approval.ProcessSubmitRequest erEMEARequest = new Approval.ProcessSubmitRequest();
        erEMEARequest.setComments('Submitting request for approval.');
        erEMEARequest.setObjectId(extensionReq2.id);
        Approval.ProcessResult extEMEAResult = Approval.process(erEMEARequest);*/
      
      Test.startTest();
      PRM_DEALREG_ApprovalRouting.autoApproveExtensionForAPjEMEA(setExtnId);
      //PRM_DEALREG_ApprovalRouting.autoApproveFirstStepDRForEMEA(setDRId);
      Test.stopTest();
      
    }
    
    static Lead createLead(String Theater,String UserId){
        Map<String,Schema.RecordTypeInfo> recordTypes = Lead.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id drRecordTypeId = recordTypes.get('Deal Registration').getRecordTypeId();
        Account objAccount = createAccount('UNITTESTAcc');
        Account objT2Account = createT2Account('UNITTESTAcct');
        Account RelatedAccount = createRelatedAccount('RelatedAcct');
        Lead newLead = new lead();
        newLead.lastname = 'Test Lead';
        newLead.company = 'EMC';
        newLead.DealReg_PSC_Owner__c = UserId;
        newLead.DealReg_Deal_Registration_Status__c = 'Submitted';
        newLead.DealReg_Of_Registration_Products__c = 3;
        newLead.DealReg_Deal_Description__c = 'test';
        newLead.DealReg_Deal_Registration__c = true;
        newLead.DealReg_Deal_Registration_Justification__c = 'test';
        newLead.DealReg_Department_Project_Name__c = 'ABCL';
        newLead.DealReg_Expected_Deal_Value__c = 12345.5;
        newLead.Email = 'abc@abc.com';
        newLead.DealReg_Partner_Contact_First_Name__c = 'Test';
        newLead.DealReg_Partner_Contact_Last_Name__c = 'Test'; 
        newLead.Partner__c = objAccount.Id;
        //newLead.DealReg_Theater__c = 'EMEA';
        newLead.DealReg_Theater__c = Theater;
        newLead.recordtypeid = drRecordTypeId;
        newLead.Tier_2_Partner__c = objT2Account.Id;
        newLead.DealReg_Create_New_Opportunity__c = True;
        newLead.City ='India';
        newLead.Street ='Bangalore';
        newLead.Channel__c = 'INDIRECT';
        newLead.Related_Account__c = RelatedAccount.id;
        newLead.DealReg_Deal_Registration__c = true;
        newLead.DealReg_of_Extension_Requests__c = 0;
        newLead.phone = '3455677'; 
        newLead.DealReg_PSC_Approval_Rejection_Date_Time__c =System.today().addMonths(1); //DateTime.valueOf('2007-01-01 2:35:21')
        insert newLead;
        system.debug('new lead--->'+newlead);
        return newLead;
    }
    
    static Account createRelatedAccount(String accountName){
        Account account = new Account(
            name=accountName,
            CurrencyIsoCode='USD',
            Site_DUNS_Entity__c = '123456',
            Global_DUNS_Entity__c = '663399'
        );        
        insert account;
        return account;
    }
    
    static Extension_Request__c createExtension(String leadId){
      Extension_Request__c objExtn = new Extension_Request__c();
        objExtn.Extension_Request_Status__c='Submitted';
        objExtn.Expected_Close_Date__c = System.today().addMonths(1);
        objExtn.DealReg_Extension_Justification__c ='test' ;
        objExtn.Deal_Registration__c = leadId;
        objExtn.DealReg_Field_SLA_Expire_on__c = DateTime.Now().addMinutes(2);        
        objExtn.Approval_Status__c = 'Submitted By Field Rep';
        insert objExtn;
        return objExtn;
    }
    
    
}