//Updated By Shipra For 2011 March Release Code Validation.
/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  10.08.2010      Shipra Misra    171026      Modify Appointment Set field on Lead to capture User.
 |  14/12/2011      Anil                        Removed Query for fetching Accounts and Contacts and used Custom setting Data Helper  
 +===========================================================================*/

@isTest
Private class PRM_ConvertLeadController_TC{
    
    private static testMethod void ConvertLeadController(){
        
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        CustomSettingCreation();   
        }
        List<Account> lstAccounts=AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        List<Account> lstPartnerAccounts=AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        List<Account> lstT2PartnerAccounts=AccountAndProfileTestClassDataHelper.CreateT2PartnerAccount();
        insert lstAccounts;
        insert lstPartnerAccounts;
        insert lstT2PartnerAccounts;
        for(Account account:lstPartnerAccounts){
            account.IsPartner = true;
        }
        update lstPartnerAccounts;
        List<Lead> lstlead = LeadTestClassDataHelper.createDealReg(lstAccounts[0], null, lstPartnerAccounts[0], lstT2PartnerAccounts[0]);
        insert lstlead;
        ApexPages.currentpage().getParameters().put('Id',lstlead[0].id);        
        ApexPages.StandardController controller = new ApexPages.StandardController(new Lead());  
        PRM_ConvertLeadController convertLead = new PRM_ConvertLeadController(controller);
        Test.startTest();
        convertLead.validate();
        convertLead.getLead();        
        convertLead.getshowOkButton();
        convertLead.getshowErrorMessage();
        convertLead.getshowCancelButton();
        convertLead.getshowClosedReason();
        Test.stopTest();
    }
        
    private static testMethod void ConvertLeadController1(){
        
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();       
        CustomSettingCreation();
        }
        List<Account> lstAccounts=AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        List<Account> lstPartnerAccounts=AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        List<Account> lstT2PartnerAccounts=AccountAndProfileTestClassDataHelper.CreateT2PartnerAccount();
        insert lstAccounts;
        insert lstPartnerAccounts;
        insert lstT2PartnerAccounts;
        for(Account account:lstPartnerAccounts){
            account.IsPartner = true;
        }
        update lstPartnerAccounts;  
        List<Lead> lstlead = LeadTestClassDataHelper.createDealReg(lstAccounts[0], null, lstPartnerAccounts[0], lstT2PartnerAccounts[0]);
        insert lstlead;
        ApexPages.currentpage().getParameters().put('Id',lstlead[0].id);  
        ApexPages.StandardController controller = new ApexPages.StandardController(new Lead());  
   
        PRM_ConvertLeadController convertLead = new PRM_ConvertLeadController(controller);
        Test.startTest();
        convertLead.validate();
        convertLead.getLead();
        convertLead.dealRegistration();
        Test.stopTest();
    }
    
    private static testMethod void ConvertLeadController2(){
        
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();        
        CustomSettingCreation();
        }
        List<Account> lstAccounts=AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        List<Account> lstPartnerAccounts=AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        List<Account> lstT2PartnerAccounts=AccountAndProfileTestClassDataHelper.CreateT2PartnerAccount();
        insert lstAccounts;
        insert lstPartnerAccounts;
        insert lstT2PartnerAccounts;
        for(Account account:lstPartnerAccounts){
            account.IsPartner = true;
        }
        update lstPartnerAccounts;      
        List<Lead> lstlead = LeadTestClassDataHelper.createDealReg(lstAccounts[0], null, lstPartnerAccounts[0], lstT2PartnerAccounts[0]);
        insert lstlead;
        lstlead[0].District_Manager__c = null;
        lstlead[0].Area_Manager__c = null;
        lstlead[0].Channel_Manager__c = null; 
        lstlead[0].Appointment_Set__c  = false;    
        update lstlead[0];
        ApexPages.currentpage().getParameters().put('Id',lstlead[0].id);         
        ApexPages.StandardController controller = new ApexPages.StandardController(new Lead());  
     
        PRM_ConvertLeadController convertLead = new PRM_ConvertLeadController(controller);
        Test.startTest();
        convertLead.validate();
        convertLead.getLead();
        convertLead.nonDealRegistration();
        convertLead.ok();
        convertLead.closeLead();     
        convertLead.getClosedList();  
        convertLead.updateDealReg();
        Test.stopTest(); 
    }  
    
    private static testMethod void ConvertLeadController3(){
        
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();        
        CustomSettingCreation();
        }
        List<Account> lstAccounts=AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        List<Account> lstPartnerAccounts=AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        List<Account> lstT2PartnerAccounts=AccountAndProfileTestClassDataHelper.CreateT2PartnerAccount();
        insert lstAccounts;
        insert lstPartnerAccounts;
        insert lstT2PartnerAccounts;
        for(Account account:lstPartnerAccounts){
            account.IsPartner = true;
        }
        update lstPartnerAccounts;      
        List<Lead> lstlead = LeadTestClassDataHelper.createDealReg(lstAccounts[0], null, lstPartnerAccounts[0], lstT2PartnerAccounts[0]);
        insert lstlead;
        lstlead[0].District_Manager__c = null;
        lstlead[0].Area_Manager__c = null;
        lstlead[0].Channel_Manager__c = null; 
        lstlead[0].Appointment_Set__c  = false;    
        update lstlead[0];
        
        ApexPages.currentpage().getParameters().put('Id',lstlead[0].id);
        ApexPages.currentpage().getParameters().put('DealReg','true');        
        ApexPages.StandardController controller = new ApexPages.StandardController(new Lead());  
     
        PRM_ConvertLeadController convertLead = new PRM_ConvertLeadController(controller);
        Test.startTest();
        convertLead.ok();
        convertLead.updateDealReg();
        convertLead.validate();
        convertLead.getLead();
        convertLead.nonDealRegistration();
        convertLead.ok();
        convertLead.closeLead();     
        convertLead.getClosedList();  
        convertLead.updateDealReg();        
        convertLead.dealRegistration();
        convertLead.nonDealRegistration();
        convertLead.ok();
        convertLead.updateDealReg();
        convertLead.getshowNonDealRegButton();
        Test.stopTest();
    }
    public static void CustomSettingCreation()
    {
        Map<String,OpportunityIntegration__c> OppIntegration = OpportunityIntegration__c.getAll(); 
        List<OpportunityIntegration__c> OppIntegrationlist = new List<OpportunityIntegration__c>();     
        OpportunityIntegration__c AdminConversion = OppIntegration.get('Admin Conversion');
        if(AdminConversion==null)
        {
            AdminConversion = new OpportunityIntegration__c(Name = 'Admin Conversion');
            AdminConversion.House_Account_User__c='00570000001dlVA';
            AdminConversion.Integration_Admin__c='00570000001L8sfAAC';
            AdminConversion.Admin_Conversion__c='00570000001L8zrAAC';
            OppIntegrationlist.add(AdminConversion);            
        }
        if(OppIntegrationlist.size()>0)
        {
            insert OppIntegrationlist;
        }
    }    
    
}