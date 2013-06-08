@isTest
/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  14/12/2011      Anil                        Removed Query for fetching Account and contacts and used Custom setting Data Helper
 +=========================================================================================================================*/
Private Class PRM_PartnerContactProfile_TC{
     
    Private static testMethod void startTest(){
        
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
        String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
        Account account = new Account();
        account.name = 'Testing Account2346';
        insert account;
        account.IsPartner = true;
        update account;
        System.debug('account---->'+account);
       
        Contact contact = new Contact();
        contact.AccountId = account.id;
        contact.Active__c = true;
        contact.LastName = 'test';
        contact.FirstName = 'test';
        contact.email = 'test12456@emc.com';
        insert contact;
        System.debug('contact----->'+contact);
       
        User user01;
        
        System.runAs(insertUser){
            user01 = createUser(distributorSuperUser);
        }
        
         System.runAs(user01){
         PRM_PartnerContactProfile cls = new PRM_PartnerContactProfile();
         cls.init();
         cls.contact.email ='asd@asd.com';
         cls.contact.Language_Preference__c ='English';       
         cls.saveAndReturnToHome();
         cls.getLanguage_PreferenceList();
         cls.getPrimary_Program_Contact_for_List();
         cls.getPreferred_Contact_MethodList();
         cls.getFunctional_AreaList();
      }
      
    }
    private static User createUser(String Profilename){          

        Profile distributorSuperUserProfile = [select Id from Profile where Name=:Profilename];
        System.debug('distributorSuperUserProfile---->'+distributorSuperUserProfile);
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
        con.AccountId=lstAccounts[0].Id;
        con.Email='test23@emc.com';
        update con;
        
        System.debug('contact----->'+con);
        User tempUsr = new User(
             Username='test12341'+Math.random()+'@acme.com.test',
             TimeZoneSidKey='America/New_York',
             ProfileId=distributorSuperUserProfile.Id,
             LocaleSidKey='en_US',
             FirstName='Direct',
             LastName='Rep',
             email='john@acme.com',
             Alias='test',
             EmailEncodingKey='ISO-8859-1',
             LanguageLocaleKey='en_US',
             Forecast_Group__c='Direct',
             BU__c='NA',
             Employee_Number__c='9323782000',
             IsActive=true,
             ContactId = con.id
        );
        insert tempUsr;
        System.debug('insert tempUsr--->'+tempUsr);
        return tempUsr;
    }

}