@isTest
private class PRM_AccountVisibitlity_TC {
/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |             Rajeev                 Initial Creation.  Test methods for PRM_AccountVisibitlity class.
 |26-Jun-11   	Anil                  Renamed Partner User Profiles as per July Release
 |14/12/2011	Anil			      Removed Query for fetching Accounts and Contacts and used Custom setting Data Helper      
 |06/03/2013  Vivekananda             Increased code coverage             
 +===========================================================================*/

 static TestMethod void test_createAccountShare(){
 
   		User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        String distributorSuperUser = 'EMEA Distributor Super User';
   		Account account = new Account();
        account.name = 'Testing Account234';
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
        
        Account account1 = new Account();
        account1.name = 'Testing Account1234';
        insert account1;
       
        
        
        Profile p = [select id from profile where name='System Administrator'];
        User u;
        User user01;
        System.runAs(insertUser)
        {
        u = new User(alias = 'utest', email='unit.test@emc.com',
              emailencodingkey='UTF-8', lastname='Unit Test', 
              languagelocalekey='en_US',
              localesidkey='en_GB', profileid = p.Id,
              timezonesidkey='Europe/London', 
              username='unit.test@emc.com');    
        	
        	
        user01 = createUser(distributorSuperUser);        
           }
        
    //System.runAs(u)
        //{
           Set<Id> userIdSet = new Set<Id>();
           userIdSet.add(user01.Id);    
           Test.startTest();
           PRM_AccountVisibitlity.createAccountShare(userIdSet);
           Test.stopTest();
       // }
   
}

private static User createUser(String Profilename){          
 
   
        Map<String,CustomSettingDataValueMap__c>  dataValueMap =  CustomSettingDataValueMap__c.getall();
        string ProfileToFetch = dataValueMap.get(Profilename).DataValue__c;
        Profile amerUserProf = [select Id from Profile where Name=:Profilename];
        System.debug('Profile---->'+amerUserProf);
        Account account = new Account();
        account.name = 'Testing Account234';
        insert account;
        Contact contact = UserProfileTestClassDataHelper.createContact();
        contact.AccountId=account.Id;
        insert contact;
        /*Group grp = new Group();
        grp.name = 'TSG Channels test';
        insert grp; */
        //Start code for group
	        set<id> accountids = new set<id>();
	        accountids.add(account.id);
	        PRM_AccountVisibitlity.createAccountShareforGroup(accountids);
        //end
        
        
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