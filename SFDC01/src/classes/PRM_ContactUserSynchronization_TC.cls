/*============================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 | 22-Sep-10   Anirudh       1061     Initial Creation.Test methods for 
                                      PRM_ContactUserSynchronization class.
 | 08-Oct-10   Karthik S     ---      System.assert is placed after stopTest()
 |                                    and added comments.
 | 26-Jun-11    Anil                  Renamed Partner User Profiles as per July Release
 | 14-12-2011	Anil				  Used Custom setting Data Helper
 | 25-05-2012	Anil				  Improved Code coverage for June Release
 | 17-08-2012  Ganesh                 Improved Code coverage for Sep Release
 +============================================================================*/
  
  @isTest
private class PRM_ContactUserSynchronization_TC {
    
    static TestMethod void test_updateContactActiveFlag(){
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Account account1 = createAccount('TestAccount1');
        Contact contact1 = createContact(account1.Id);
         User contactUser1;
         User u;       
        Profile p = [select id from profile where name='System Administrator'];
        System.runAs(insertUser)
        {
        u = new User(alias = 'utest', email='unit.test@emc.com',
              emailencodingkey='UTF-8', lastname='Unit Test', 
              languagelocalekey='en_US',
              localesidkey='en_GB', profileid = p.Id,
              timezonesidkey='Europe/London', 
              username='unit.test@emc.com');               
       
        contactUser1 = createUser(contact1.Id,'TestUser1');
        }
           
        
        
        //Changed here to remove the external entry point error.   
        Contact contacts = [select id,Partner_User2__c from contact where Id =:contact1.Id];
        //System.assertEquals(True,contacts.Partner_User2__c);
      }
  
  	 /*Test Data Start
	 /Method for Creation of Profiled Account*/
	    public static List<Account> createProfiledAccount(){
	        list<Account> lstPartnerAccount = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
	        lstPartnerAccount[0].name = 'Distributor Account for Partner SE';
	        lstPartnerAccount[2].name = 'Distributor Account for Inside Partner SE';
	        insert lstPartnerAccount;
	        lstPartnerAccount[0].PROFILED_ACCOUNT_FLAG__c = true;
	        lstPartnerAccount[0].Ispartner=true;
	        lstPartnerAccount[2].PROFILED_ACCOUNT_FLAG__c = true;
	        lstPartnerAccount[2].Ispartner=true;
	        update lstPartnerAccount;
	        return lstPartnerAccount;
	    }
	    /*Method for Creation of PartnerContact*/
	    public static List<Contact> createPartnercontact(List<Account> ProfiledAccount){
	        
	        List<Contact> lstContact = new List<Contact>();
	        Contact contact1 = new Contact();
	        contact1.FirstName='Test Disti Contact';
	        contact1.LastName='no Partner SE and no Inside';
	        contact1.AccountId = ProfiledAccount[0].Id;
	        contact1.Email = 'Contact1@abc.com';
	        contact1.Active__c = true;
	        lstContact.add(contact1);
	        
	        Contact contact2 = new Contact();
	        contact2.FirstName='Test Disti Contact';
	        contact2.LastName='no Partner SE and no Inside';
	        contact2.AccountId = ProfiledAccount[0].Id;
	        contact2.Email = 'Contact2@abc.com';
	        contact2.Active__c = true;
	        lstContact.add(contact2);
	        
	        Contact contact3 = new Contact();
	        contact3.FirstName='Test Disti Contact';
	        contact3.LastName='no Partner SE and no Inside';
	        contact3.AccountId = ProfiledAccount[2].Id;
	        contact3.Email = 'Contact3@abc.com';
	        contact3.Active__c = true;
	        lstContact.add(contact3);
	        
	        Contact contact4 = new Contact();
	        contact4.FirstName='Test Disti Contact';
	        contact4.LastName='no Partner SE and no Inside';
	        contact4.AccountId = ProfiledAccount[2].Id;
	        contact4.Email = 'Contact4@abc.com';
	        contact4.Active__c = true;
	        lstContact.add(contact4);
	        	        
	        insert lstContact;
	        lstContact[1].Partner_SE__c=true;
	        lstContact[3].Partner_SE__c=true;
	        update lstContact;       
	        return lstContact;
	    }
	    /*Method for Creation of PartnerUsers*/
	    public static List<User> createPortalUsers(){
	    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
	        System.runAs(insertUser)
	        {
	    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
	        }
	        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
        	String AmericasDistributorCAP = data.get('AmericasDistributorCAP').DataValue__c;
	    	List<User> lstPartnerUsers = new List<User>();
	    	User PartnerUsertoadd;
	    	List<Account> lstaccounts = createProfiledAccount();       
       		List<Contact> lstContact = createPartnercontact(lstaccounts);
       		for(Integer i=0;i<lstContact.size();i++)
       		{
       			lstContact[i].Email = 'Contact44'+i+'@abc.com';
       		}
       		update lstContact;       		
       		System.runAs(insertUser)
	        {       
		       String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
		       Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
		       for(integer i=0;i<lstContact.size();i++)
		       PartnerUsertoadd = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,lstContact[i].Id);
		       lstPartnerUsers.add(PartnerUsertoadd);		       
	        } 
	        insert lstPartnerUsers;
	        return lstPartnerUsers;
	    }
/*Method to unit test PRM_ContactUserSynchronization.cls*/
 			static testMethod void testPRMContactUserSync() {   	
		   	List<Account> lstProfiledAccounts=createProfiledAccount();
		   	List<Contact> lstContact=createPartnercontact(lstProfiledAccounts);
		   
		   	Set<Id> AccountIds  = new set<Id>();
		   	PRM_ContactUserSynchronization Obj= new PRM_ContactUserSynchronization();
		   	
		   	/** Flip Record Types on Contacts based on Partner Type **/
		    Obj.flipContactRecordTypetoDistiVar(lstContact);		    
		    /**Update Account Partner Type to flip record Types on Contacts**/		    
		    lstProfiledAccounts[0].Partner_Type__c='Distribution VAR';
			lstProfiledAccounts[2].Partner_Type__c='Distributor';
		    update lstProfiledAccounts;
		    AccountIds.add(lstProfiledAccounts[0].Id);
		    AccountIds.add(lstProfiledAccounts[2].Id);
		    PRM_ContactUserSynchronization.flipContactRecordTypetoDistiVarOnUpdateofAccount(AccountIds);		    
		    /**Test for Populating the Contact name who inactivated the Contact**/		    		    
		    Obj.populateInactivatedByValueOnContact(lstContact,true);
		    Obj.populateInactivatedByValueOnContact(lstContact,false);		   
		   }
		   
/*Method to unit test PRM_ContactUserSynchronization.cls*/ 
			static testMethod void testPRMContactUserSync1() {
			List<User> lstPartnerUsers = new list<User>();
			Map<Id,User> newUserMap = new Map<Id,User>();
			Map<Id,User> oldUserMap = new Map<Id,User>();
		   	PRM_ContactUserSynchronization Obj= new PRM_ContactUserSynchronization(); 
		   	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
	        System.runAs(insertUser)
	        {
	    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();        
		   	lstPartnerUsers = createPortalUsers();
	        }
	        	        
		   	Obj.populatePartnerContactOnUser(lstPartnerUsers);
		   	for(User u:lstPartnerUsers)
	        {
	        	oldUserMap.put(u.Id,u);
	        	u.IsActive=false;
	        }
		   	update lstPartnerUsers;
		   	for(User u: lstPartnerUsers)
		   	{
		   		newUserMap.put(u.Id,u);
		   	}
		   	Obj.updateContact(oldUserMap,newUserMap);
		   }
		   
		      	static testMethod void testPRMContactUserSync2() { 
		   	  List<Account> lstAcc = new List<Account>();
		   	  List<Contact> lstCon = new List<Contact>();
		   	  map<Id,Id> mapPartnerAccountWithContact = new Map<Id,Id>();  
		   	  map<Id,Contact> mapContactDetails = new Map<Id,Contact>();
		   	  Account acc1 = new Account(name='TestAccount1');
		   	  Account acc2 = new Account(name='TestAccount2',Partner_Type__c='Distribution VAR');
		   	  lstAcc.add(acc1);
		   	  lstAcc.add(acc2);
		   	  insert lstAcc;
		   	  Contact con1  = new Contact(FirstName='TestFirstName',LastName='TestLastName',AccountId = acc1.Id,Email = 'sample1t@test.com',Active__c = true,Partner_SE__c=false);
		   	  Contact con2  = new Contact(FirstName='TestFirstName',LastName='TestLastName',AccountId = acc1.Id,Email = 'sample2@test.com',Active__c = true,Partner_SE__c=false);
		   	  lstCon.add(con1);
		   	  lstCon.add(con2);
		   	  insert lstCon;
		   	  lstCon[0].AccountId=acc2.Id;
		   	  lstCon[1].AccountId=acc2.Id;
		   	  update lstCon;
		   	  mapPartnerAccountWithContact.put(con1.Id,con1.AccountId);
		   	  mapPartnerAccountWithContact.put(con2.Id,con2.AccountId);
		   	  mapContactDetails.put(con1.Id,con1);
		   	  mapContactDetails.put(con2.Id,con2);
		   	  PRM_ContactUserSynchronization Obj= new PRM_ContactUserSynchronization(); 
		   	  Obj.flipContactRecordTypeToPartner(mapPartnerAccountWithContact,mapContactDetails);		   	  
		   	}  
		   
/* @Method <This method createAccount is used create account for the test class>
   @param <Taking string as paramter which contains account name>
   @return <void> - <Account record>
   @throws exception - <No Exception>
*/
    
    public static Account createAccount(String accountName){
        //Creating the dummy account for test class.
        Account account = new Account(
            name=accountName,
            CurrencyIsoCode='USD',
            Site_DUNS_Entity__c='5693241'
        );
        insert account;
        return account;
    }

/* @Method <This method createContact is used create contact for the test class>
   @param <Taking Id as paramter which contains newly created accountId>
   @return <void> - <Contact record>
   @throws exception - <No Exception>
*/

    public static Contact createContact(Id accountId){
        //Creating the dummy contact on the previously created account for test class.
        Contact contact = new Contact(
            FirstName='Test',
            LastName='User1121',
            AccountId=accountId
        );
        insert contact;
        return contact;
    }

/* @Method <This method createUser is used create user for the test class>
   @param <Taking Id and String as paramters which contains newly created 
            contactId and userName>
   @return <void> - <User record>
   @throws exception - <No Exception>
*/
    
    public static User createUser(Id contactId, String userName){
        //Creating the dummy user on the previously created contact for the 
        //test class.
        // Req#1117.
       Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
       String directReseller = data.get('EMEA Direct Reseller Partner User').DataValue__c ;
       String distributionVAR = data.get('EMEA Distribution VAR Partner User').DataValue__c ;
        // Changes End.  
    
        User tempUsr = new User(
            Username='test1234'+Math.random()+'@acme.com.test',
            TimeZoneSidKey='America/New_York',
            ProfileId= '00e70000001Fbqw',
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
            ContactId = contactId
        );
        insert tempUsr;
        return tempUsr;
    }
    //Test Data ends.
}