/*======================================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 

| 05/07/2011      Suman B                          This is a testclass for PRM_WelcomeHomePageComponent.
| 14/12/2011		Anil						   Removed Query for fetching Partner and used Custom setting Data Helper
+=======================================================================================================*/
@isTest
private class PRM_WelcomeHomePageComponent_TC {

  static testMethod void welcomeHomePageComponent_Test() {
  	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
    List<Account> lstAccounts=AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
    insert lstAccounts;
    for(Account acc : lstAccounts)
    {
        acc.IsPartner=true;
        acc.PROFILED_ACCOUNT_FLAG__c =true;
        acc.Cluster__c='EMEA 1B';
    }
    update lstAccounts;
    Contact con = UserProfileTestClassDataHelper.createContact();    
    insert con;
    con.Email='test23@emc.com';
    update con;
    con.AccountId=lstAccounts[0].Id;
    update con;
    User partner;
    System.runAs(insertUser)
        {
     partner = new User(
             Username='test1234'+Math.random()+'@emc.com.test',
             TimeZoneSidKey='America/New_York',
             LocaleSidKey='en_US',
             FirstName='Direct',
             LastName='Rep',
             ProfileId = '00e70000001FhPm',
             UserRoleId = null,
             email='john@emc.com',
             Alias='test',
             EmailEncodingKey='ISO-8859-1',
             LanguageLocaleKey='en_US',
             Forecast_Group__c='Direct',
             BU__c='NA',
             Employee_Number__c='9323782818',
             IsActive=true,
             ContactId=con.Id
                         
        );
    insert partner;
    partner.IsPortalEnabled=true;
    partner.isActive=True;
    update partner;
    }                           
  
     system.runAs(partner){ 
        PRM_WelcomeHomePageComponent hpCmpt = new PRM_WelcomeHomePageComponent();
        hpCmpt.getReportId();
        hpCmpt.getAccountId();
        hpCmpt.getIsPartnerFinderAdmin();
        hpCmpt.getChannelMnagerName();
        hpCmpt.getEmailID();
        hpCmpt.setEmailId('test@test.com');
        if(partner != null){
          hpCmpt.setAccountId(partner.Contact.Account.id );
        } 
        
    }
  }
}