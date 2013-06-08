/*====================================================================================================================+

 |  HISTORY  |                                                                           
    DATE          DEVELOPER     WR   DESCRIPTION                               

 |  ====          =========     ==   =========== 
 |  8/10/2010     Ashwini Gowda      Commented utils.fromGroup(usrIds);
 |  20/10/2010    Ashwini Gowda 1318 UnCommented utils.fromGroup(usrIds) as the issue is fixed.
 |  26-Jun-11     Anil               Renamed Partner User Profiles as per July Release
 |  30-Nov-11     Anil               Removed Queries and MIXED DML Exceptions and Query Statements                                     
 |=============================================================================================================== */


@isTest
Private Class PRM_CommonUtils_TC{
    
     
     
     static PRM_CommonUtils utils = new PRM_CommonUtils();
     static list<String> usrIds = new list<String>();
     
    Private static testMethod void startTest(){
        
             User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
             User user01;
                
                System.runAs(insertUser)
                {
                PRM_VPP_JobDataHelper.createVPPCustomSettingData();
                Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
                String emeadistributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
                user01 = createUser(emeadistributorSuperUser);
                }           
 
      usrIds.add(user01.id);

      utils.isPartnerUser(user01.id);

      
      utils.userType(usrIds);
      
      utils.fromUser(usrIds);
      
      Group grp = [select id from group limit 1];
    
      usrIds.add(grp.id);
      
      utils.fromGroup(usrIds);
     
      utils.userDetails(usrIds);

      
    }
    
    private static User createUser(String Profilename){          
    
            Profile amerUserProf = [select Id from Profile where Name=:Profilename];
            System.debug('Profile---->'+amerUserProf);
            List<Account> account = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
            insert account;
            account[0].IsPartner = true;
            update account[0];
            Contact contact = UserProfileTestClassDataHelper.createContact();
            contact.AccountId= account[0].Id;
            contact.Email='test2345@emc.com';           
            insert contact;
            System.debug('contact----->'+contact);
            User tempUsr = new User(
                 Username='test1234'+Math.random()+'@acme.com.test',
                 TimeZoneSidKey='America/New_York',
                 ProfileId=amerUserProf.Id,
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
                 ContactId = contact.id
            );
            insert tempUsr;
            System.debug('insert tempUsr--->'+tempUsr);
            return tempUsr;
        }

}