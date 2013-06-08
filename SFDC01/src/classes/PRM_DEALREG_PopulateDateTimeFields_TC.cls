@isTest
private class PRM_DEALREG_PopulateDateTimeFields_TC {
	static list<Account> lstAccount = new list<Account>();
	static list<Account> lstPartnerAccount = new list<Account>();
	static list<Lead> lstLead = new list<Lead>();
	static list<Lead> lstLeadpull = new list<Lead>();
	static list<Lead> lstLeadDeal = new list<Lead>();
	static list<User> lstpartner = new list<User>();
	static list<Opportunity> lstoppty = new list<Opportunity>();
    static testMethod void testPopulateDateTimeFieldsOnInsert() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        //creation of account
        lstAccount = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        lstPartnerAccount = AccountAndProfileTestClassDataHelper.CreatePartnerAccount(); 
        insert lstAccount;
        insert lstPartnerAccount;
        
        //updated as partner account
        for(Account account:lstPartnerAccount){
        	account.IsPartner = true;
        }
        update lstPartnerAccount;
        
        //creation of Deal Reg
        lstLead = LeadTestClassDataHelper.createDealReg(lstAccount[0],null,lstPartnerAccount[0],lstPartnerAccount[1]);
        lstpartner =[Select u.id,u.name, u.UserType From User u where u.IsActive=true and u.usertype like '%partner%' limit 1];
        lstoppty =[select id, name,Quote_Cart_Number__c,Quote_Cart_Linked_Date_Time__c,Linked_to_Deal_Registration__c,StageName from Opportunity limit 20];
        //for testing populateDateTimeFieldsOnInsert() method
        for(Lead lead:lstLead){
        	lead.Passed_to_Partner__c = true;
        	lead.phone='2344455';
        }	
        Test.startTest();
        insert lstLead;
       Map<String, Global_Lead_Deal_SLA__c> mapGlobal = Global_Lead_Deal_SLA__c.getAll();
       Map<String, Lead_Pull_SLA__c> mapLeadPull = Lead_Pull_SLA__c.getAll();
       Map<String, Register_Lead_SLA__c> mapDealPull = Register_Lead_SLA__c.getAll();
       Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();       
       // Global_Lead_Deal_SLA__c dealGet = Global_Lead_Deal_SLA__c.getValues('Global');
        //for 206404 and 207171
         List<Global_Lead_Deal_SLA__c> Globalcust = new List<Global_Lead_Deal_SLA__c>();
         List<Lead_Pull_SLA__c> LeadPullcust = new List<Lead_Pull_SLA__c>();
         List<Register_Lead_SLA__c> Dealcust = new List<Register_Lead_SLA__c>();
         
        if(mapGlobal.isEmpty() == true || mapLeadPull.isEmpty() == true || mapDealPull.isEmpty()== true ||DataValueMap.isEmpty() == true){
          Global_Lead_Deal_SLA__c DealSLA = new Global_Lead_Deal_SLA__c ();
          DealSLA.Name ='GlobalLead';
          DealSLA.Global_Lead_Deal_Pull_SLA__c =2;
          DealSLA.Final_Global_Lead_Deal_Pull_SLA__c=4;
          DealSLA.Global_Lead_Deal_Pull_Change_owner_SLA__c=5;
          Globalcust.add(DealSLA);
          Global_Lead_Deal_SLA__c DealSLA1 = new Global_Lead_Deal_SLA__c ();
          DealSLA1.Name = 'GlobalDeal';
          DealSLA1.Global_Lead_Deal_Pull_SLA__c =1;
          DealSLA1.Final_Global_Lead_Deal_Pull_SLA__c=2;
          DealSLA1.Global_Lead_Deal_Pull_Change_owner_SLA__c=3;
          Globalcust.add(DealSLA1);
          insert Globalcust;
          
          Lead_Pull_SLA__c PullSLA = new Lead_Pull_SLA__c();
          PullSLA.Name ='Americas';
          PullSLA.Lead_Pullback_SLA__c =1;
          PullSLA.Final_Lead_Pullback_SLA__c =2;
          PullSLA.Lead_Pullback_Change_Owner_SLA__c =3;
          LeadPullcust.add(PullSLA);
          Lead_Pull_SLA__c PullSLA1 = new Lead_Pull_SLA__c();
          PullSLA1.Name ='EMEA';
          PullSLA1.Lead_Pullback_SLA__c =1;
          PullSLA1.Final_Lead_Pullback_SLA__c =2;
          PullSLA1.Lead_Pullback_Change_Owner_SLA__c =3;
          LeadPullcust.add(PullSLA1);
          Lead_Pull_SLA__c PullSLA2 = new Lead_Pull_SLA__c();
          PullSLA2.Name ='APJ';
          PullSLA2.Lead_Pullback_SLA__c =1;
          PullSLA2.Final_Lead_Pullback_SLA__c =2;
          PullSLA2.Lead_Pullback_Change_Owner_SLA__c =3;
          LeadPullcust.add(PullSLA2);
          insert LeadPullcust;
          
          Register_Lead_SLA__c DealSLAs = new Register_Lead_SLA__c();
          DealSLAs.Name ='Americas';
          DealSLAs.Register_Lead_SLA__c=1;
          DealSLAs.Register_Lead_Change_Owner_SLA__c=3;
          DealSLAs.Final_Register_Lead_SLA__c =2;
          Dealcust.add(DealSLAs);
          Register_Lead_SLA__c DealSLAs1 = new Register_Lead_SLA__c();
          DealSLAs1.Name ='EMEA';
          DealSLAs1.Register_Lead_SLA__c=1;
          DealSLAs1.Register_Lead_Change_Owner_SLA__c=3;
          DealSLAs1.Final_Register_Lead_SLA__c =2;
          Dealcust.add(DealSLAs1);
          Register_Lead_SLA__c DealSLA2 = new Register_Lead_SLA__c();
          DealSLA2.Name ='APJ';
          DealSLA2.Register_Lead_SLA__c=1;
          DealSLA2.Register_Lead_Change_Owner_SLA__c=3;
          DealSLA2.Final_Register_Lead_SLA__c =2;
          Dealcust.add(DealSLA2);
          insert Dealcust;
          CustomSettingDataValueMap__c objfinalflag = new CustomSettingDataValueMap__c();
	       objfinalflag.Name ='FlagForCalculateBusinessdate';
	       objfinalflag.DataValue__c ='false';
	       insert objfinalflag;
        }
      
        
        
        Lead objLeadpullback = new Lead();         
        objLeadpullback.Company ='TestDealreg1';
        objLeadpullback.DealReg_Deal_Description__c ='Deal Reg description';
        objLeadpullback.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
        objLeadpullback.CurrencyIsoCode ='USD'; 
        objLeadpullback.OwnerId = lstpartner[0].Id;
        objLeadpullback.DealReg_Expected_Deal_Value__c =100;
        objLeadpullback.DealReg_Expected_Close_Date__c = System.today().addMonths(1);       
        objLeadpullback.LastName ='DealregLastName2';
        objLeadpullback.Email ='Dealreg1@dealreg.com';
        objLeadpullback.DealReg_Partner_Contact_First_Name__c ='testCFName';
        objLeadpullback.DealReg_Partner_Contact_Last_Name__c ='testLFname';
        objLeadpullback.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
        objLeadpullback.DealReg_Partner_Phone_Number__c = '98888888';
        objLeadpullback.Status = 'Submitted';
        objLeadpullback.Accept_Lead__c = false;
        objLeadpullback.Passed_to_Partner_Date_Time__c=System.today();
        objLeadpullback.Related_Account__c =lstAccount[0].Id;
        objLeadpullback.Partner__c = lstPartnerAccount[0].Id;
        objLeadpullback.Sales_Force__c = 'EMC';
        objLeadpullback.DealReg_Theater__c = 'APJ';
        lstLeadpull.add(objLeadpullback); 
        
        Lead objLeadDealReg = new Lead();         
        objLeadDealReg.Company ='TestDealreg1';
        objLeadDealReg.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
        objLeadDealReg.CurrencyIsoCode ='USD'; 
        objLeadDealReg.Passed_to_Partner__c = true;
        objLeadDealReg.OwnerId = lstpartner[0].Id;
        objLeadDealReg.DealReg_Expected_Deal_Value__c =100;
        objLeadDealReg.DealReg_Expected_Close_Date__c = System.today().addMonths(1);       
        objLeadDealReg.LastName ='DealregLastName2';
        objLeadDealReg.Email ='Dealreg1@dealreg.com';
        objLeadDealReg.DealReg_Partner_Contact_First_Name__c ='testCFName';
        objLeadDealReg.DealReg_Partner_Contact_Last_Name__c ='testLFname';
        objLeadDealReg.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
        objLeadDealReg.DealReg_Partner_Phone_Number__c = '98888888';
        objLeadDealReg.Status = 'Submitted';
        objLeadDealReg.Accept_Lead__c = true;
        objLeadDealReg.Passed_to_Partner_Date_Time__c=System.today();
        objLeadDealReg.DealReg_Deal_Registration__c = false;
        objLeadDealReg.Related_Account__c =lstAccount[0].Id;
        objLeadDealReg.DealReg_Deal_Registration_Status__c ='Approved';
        objLeadDealReg.DealReg_Of_Registration_Products__c = 5;
        objLeadDealReg.DealReg_Create_New_Opportunity__c =true;
        objLeadDealReg.Partner__c = lstPartnerAccount[0].Id;
        objLeadDealReg.Sales_Force__c = 'EMC';
        objLeadDealReg.EvaluateFlag__c = true;
        objLeadDealReg.Last_EMC_Owner__c = lstLead[0].Id;
        objLeadDealReg.DealReg_Theater__c = 'APJ';
        objLeadDealReg.phone = '3455939';  
        objLeadDealReg.City = 'SOUTH BRISBANE';
        lstLeadDeal.add(objLeadDealReg);
         
         Lead objLeadDealReg1 = new Lead();         
        objLeadDealReg1.Company ='TestDealreg1';
        objLeadDealReg1.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
        objLeadDealReg1.CurrencyIsoCode ='USD'; 
        objLeadDealReg1.Passed_to_Partner__c = true;
        objLeadDealReg1.OwnerId = lstpartner[0].Id;
        objLeadDealReg1.DealReg_Expected_Deal_Value__c =100;
        objLeadDealReg1.DealReg_Expected_Close_Date__c = System.today().addMonths(1);       
        objLeadDealReg1.LastName ='DealregLastName2';
        objLeadDealReg1.Email ='Dealreg1@dealreg.com';
        objLeadDealReg1.DealReg_Partner_Contact_First_Name__c ='testCFName';
        objLeadDealReg1.DealReg_Partner_Contact_Last_Name__c ='testLFname';
        objLeadDealReg1.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
        objLeadDealReg1.DealReg_Partner_Phone_Number__c = '98888888';
        objLeadDealReg1.Status = 'Submitted';
        objLeadDealReg1.Accept_Lead__c = true;
        objLeadDealReg1.Passed_to_Partner_Date_Time__c=System.today();
        objLeadDealReg1.DealReg_Deal_Registration__c = false;
        objLeadDealReg1.Related_Account__c =lstAccount[0].Id;
        objLeadDealReg1.DealReg_Deal_Registration_Status__c ='Submitted';
        objLeadDealReg1.DealReg_Of_Registration_Products__c = 5;
        objLeadDealReg1.DealReg_Create_New_Opportunity__c =true;
        objLeadDealReg1.Partner__c = lstPartnerAccount[0].Id;
        objLeadDealReg1.Sales_Force__c = 'EMC';
        objLeadDealReg1.EvaluateFlag__c = true;
        objLeadDealReg1.Last_EMC_Owner__c = lstLead[0].Id;
        objLeadDealReg1.DealReg_Theater__c = 'APJ';
        objLeadDealReg1.phone = '3455939';  
        objLeadDealReg1.City = 'SOUTH BRISBANE';
        lstLeadDeal.add(objLeadDealReg1);
      Set<id> checkids = new Set<id>();
      for(Lead setownerid:lstLeadpull){
        checkids.add(setownerid.OwnerId);
      }
       Map <id,User> objPartneruser = new Map<id,User>([Select u.id,u.name, u.UserType From User u where u.IsActive=true and u.id in:checkids and u.usertype like '%partner%']);
        
        PRM_DEALREG_PopulateDateTimeFields obj = new PRM_DEALREG_PopulateDateTimeFields();    
        obj.clearDealRegDateTimeFields(lstLead);
        obj.populateDateTimeFieldsOnInsert(lstLead);
        obj.UpdateLeadStatus(lstLead);
        //obj.populateSLAforPassToPartner(lstLead,objPartneruser);
        //obj.populateSLAforAcceptedLead(lstLead,objPartneruser);
        obj.populateSLAforPassToPartner(lstLeadpull,objPartneruser);
        obj.populateSLAforAcceptedLead(lstLeadDeal,objPartneruser);
        PRM_DEALREG_PopulateDateTimeFields.CalculateBusinessdate(System.Now(), 5);
        obj.populateDateTimeFieldsOnUpdateOfOpportunity(lstoppty);
        obj.stampTime(lstoppty, 'Quote_Cart_Linked_Date_Time__c');
        Test.stopTest();
    }   
    
   static testMethod void testPopulateDateTimeFieldsOnUpdate() {
   	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        //for testing populateDateTimeFieldsOnUpdate() method
        List<Lead> lstLeads = new List<Lead>();
        for(Lead lead:lstLead){
        	lead.Passed_to_Partner__c = false;
        	lead.OwnerId = UserInfo.getUserId();
        	lead.DealReg_Deal_Registration_Status__c = 'Approved';
        	//lead.Related_Account__c = null;
        	lead.Accept_Lead__c = true;
        	lead.phone='7778893';
        	lstLeads.add(lead);
        }
        update lstLeads;
        for(Lead lead:lstLead){
        	lead.DealReg_Deal_Registration_Status__c = 'Approved';
        	lstLeads.add(lead);
        }
        for(Lead lead:lstLead){
        	lead.Passed_to_Partner__c = true;
        	lead.DealReg_Deal_Registration_Status__c = 'Expired';
        	lead.Related_Account__c = lstAccount[0].Id;
        	lstLeads.add(lead);
        }     
       Test.startTest();
       update lstLeads;
       Test.stopTest();
    }
    
   static testMethod void testUpdateClosedlostDR(){
   	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	  PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
      //for testing updateClosedlostDR() method
        for(Lead lead:lstLead){
        	lead.DealReg_Partner_Probability__c = 'Deal Lost';
        	lead.phone='88765634';
        }
       Test.startTest();
       update lstLead;
       PRM_DEALREG_PopulateDateTimeFields obj = new PRM_DEALREG_PopulateDateTimeFields();
       obj.updateClosedlostDR(lstLead);
       Test.stopTest();        
    }
    
}