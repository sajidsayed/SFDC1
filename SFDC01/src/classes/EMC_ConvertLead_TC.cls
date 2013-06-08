/*=====================================================================================================+
|  HISTORY  | |  DATE          DEVELOPER     WR         DESCRIPTION  |  
====          =========                      ==         ===========  |
               28/06/2011    Anand Sharma    This class is used to unit test EMC_ConvertLead  
|              08/11/2011    Anand Sharma    Fixed test class issue for Presales validation rule faliure.
|              26/05/2012    Anil Sure       Fixed TOO many SOQL Error 
|          15/05/2013    Hemavathi       increasead code coverage   
+=====================================================================================================*/
@isTest
Private class EMC_ConvertLead_TC{   
 public static testmethod void deployEMC_ConvertLead(){  
          EMC_ConvertLead emcConvertLead = new EMC_ConvertLead();        
          List<Account> lstAccount = new List<Account>();

          Account acc1= new Account(name='Deploy');         
          lstAccount.add(acc1);         
          Account acc2= new Account(name='Deploy2');    
          lstAccount.add(acc2); 
          insert lstAccount;    
          User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];

  System.runAs(insertUser)     
          {      
          PRM_VPP_JobDataHelper.createVPPCustomSettingData();      
          }          
          List<Account> acc = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();     
          insert acc;
 for(Account account : acc)
 {      
          account.Type='Partner';
     account.IsPartner=true;  
          }

          update acc;  
          Contact cont = UserProfileTestClassDataHelper.createContact();         
          cont.AccountId=acc[0].Id; 
          insert cont;    
          User partner;  
          System.runAs(insertUser)       
          {  
          Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();    
          String distributorSuperUser = data.get('EMEA Distributor Partner User').DataValue__c ;
          Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];   
          partner = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont.Id);   
          insert partner;
 }   
          Profile userProfile = [select Id from Profile where Name='System Administrator'];  
          User standardUser = UserProfileTestClassDataHelper.createUser(userProfile.Id, null);
          standardUser.BU_Attribute__c='Core Channels';
          System.runAs(insertUser)       
          { 
          insert standardUser;  } 
          /*Profile userProfile = [select Id from Profile where Name='System Administrator'];   
          User standardUser  = [Select Id, BU_Attribute__c, Contact.Account.Owner.Email, Contact.Account.Name

          From user where isActive = true and (BU_Attribute__c like '%core%' )   AND ProfileId =:userProfile.Id limit 1];
  */

  
          List<AccountTeamMember> lstATM = new List<AccountTeamMember>();      
          AccountTeamMember objATM = new AccountTeamMember();    
          objATM.AccountId =  lstAccount.get(0).Id;

          objATM.TeamMemberRole ='Sales-Sales Rep';         
          objATM.UserId = standardUser.Id;        
          lstATM.add(objATM);
       
          AccountTeamMember objATM1 = new AccountTeamMember(); 
          objATM1.AccountId =  lstAccount.get(1).Id;         
          objATM1.TeamMemberRole ='Sales-Sales Rep';      
          objATM1.UserId = standardUser.Id;     
          lstATM.add(objATM1);
      
          insert lstATM;          
          Contact contact1 =new Contact(FirstName='John' , LastName='Doe',Email='doe_john@salesforce.com',accountid=acc2.id);
         insert contact1;      
          List<Lead> lstLead = new List<Lead>();
          Lead objLead = new Lead(Company='Deploy Lead',LastName='Doe',DealReg_Theater__c ='EMEA',email='doe_john1@salesforce.com', Competitors__c ='test;',ownerId=standardUser.Id);
  lstLead.add(objLead);

     
          Lead leadNext= new Lead(Company='Deploy Lead 2',DealReg_Theater__c ='EMEA',LastName='Doe 2',Related_Account__c=acc2.id,Related_Contact__c=contact1.id, Competitors__c ='test',ownerId=standardUser.Id);
 lstLead.add(leadNext);    
          insert lstLead;          
          //List<Lead> lead1=[select id,Channel__c,Campaign_Event_Name__c,S_Control_Converted__c,Description,DoNotCall,Email,FirstName,LastName,LeadSource,Lead_Originator__c,OwnerId,Phone,Related_Account__c,Related_Contact__c,Related_Opportunity__c,Sales_Force__c,Salutation,Status,Tier_2_Partner__c,Partner__c,Title,Title_Type__c from Lead where Status='New' and Related_Contact__c!=null and Related_Account__c!=null Limit 4 ];    
          Test.startTest();   
          EMC_ConvertLead.convertLead1(''+lstLead.get(0).id);       
          EMC_ConvertLead.convertLead(''+lstLead.get(1).id);

  EMC_ConvertLead.convertLeads(lstLead);
  Test.stopTest();       
          }/**/   
          public static testmethod void deployEMC_DealReg(){    
          List<Account> lstAccount = new List<Account>();     
          Account acc1= new Account(name='Deploy');        
          lstAccount.add(acc1);       
          Account acc2= new Account(name='Deploy2');
          lstAccount.add(acc2);
 
          insert lstAccount;

          User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];

  System.runAs(insertUser)    
          {
     
          PRM_VPP_JobDataHelper.createVPPCustomSettingData();

          }         
          List<Account> acc = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        insert acc;
 for(Account account : acc)  
          {
    
          account.Type='Partner';
          account.IsPartner=true;       
          }

          update acc;    
          Contact cont = UserProfileTestClassDataHelper.createContact();  
          cont.AccountId=acc[0].Id;         
          insert cont;

          User partner;

          System.runAs(insertUser)       
          {
          
          Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();    
          String distributorSuperUser = data.get('EMEA Distributor Partner User').DataValue__c ;  
          Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];    
          partner = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont.Id);  
          insert partner;
 }
     
          /*User partner = [Select  u.Id, u.Contact.Account.Owner.Email, u.Contact.Account.Name

       from    User u

       where   u.isActive=True and u.UserType='PowerPartner' and u.ContactId != null limit 1];*/       
          Profile userProfile = [select Id from Profile where Name='System Administrator'];    
          User standardUser = UserProfileTestClassDataHelper.createUser(userProfile.Id, null);
          standardUser.BU_Attribute__c='Core Channels';          
          //standardUser.Contact.Account.Name=acc1.Name;       
         System.runAs(insertUser)       
          { 
          insert standardUser;
          }
      
          /*User standardUser  = [Select Id, BU_Attribute__c, Contact.Account.Owner.Email, Contact.Account.Name


   From user where isActive = true and (BU_Attribute__c like '%core%' )  
          AND ProfileId =:userProfile.Id limit 1];*/      
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
         List<Lead> lstLead = new List<Lead>();
          for(Integer i=0;i<2;i++){      
          Lead objLead = new Lead();          
          objLead.Company ='TestDealreg1';
          objLead.ownerId=standardUser.Id;
objLead.DealReg_Theater__c ='EMEA';
          objLead.DealReg_Deal_Description__c ='Deal Reg description1';  
          objLead.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification1';
          objLead.CurrencyIsoCode ='USD';
        objLead.DealReg_Expected_Deal_Value__c =100;   
          objLead.DealReg_Expected_Close_Date__c = System.today().addMonths(1);
 objLead.LastName ='DealregLastName1';
// objLead.Email ='Dealreg11@dealreg.com';
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
 objLead.Competitors__c ='test;';
 
 if(i==1){
 objLead.Competitors__c ='test';}
  lstLead.add(objLead);
 }
 insert lstLead;

 // List<Lead> lstLead = new List<Lead>();
 //lstLead = lstLead1;
 lstLead.get(0).Status ='Approved';
 lstLead.get(1).Status ='Approved';
 Test.startTest();

  EMC_ConvertLead.convertLeads(lstLead);
 EMC_ConvertLead.convertLead(lstLead[1].Id);
 EMC_ConvertLead.convertLead(lstLead[0].Id);
 Test.stopTest();    }}