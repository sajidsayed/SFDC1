/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 17/9/2010      Karthik Shivprakash     1070       This is test class for the 
                                                     schedular PRM_AccountAssignmentScheduler
 |                                                   which is used to create the account
                                                     share between the associated accounts.
 | 
   21/10/2010      Suman B                 1117      Modified the test class as per change in 
 |                                                   Profile name -from 'Tier 1 Partner User' to 
                                                     'Direct Reseller Partner User' Line-127.
 |
 | 08/10/2010     Karthik Shivprakash       --       Updated createUser() method and
                                                     testAccountShare() method.
 |  26-Jun-11	      Anil				     		 Renamed Partner User Profiles as per July Release
 +===========================================================================*/

@istest

private class PRM_AccountAssignmentScheduler_TC{

/* @Method <This method testAccountShare is used test the schedular class>
   @param <Not taking any paramters>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    
    static testmethod void testAccountShare() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
      	PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        Map<String,CustomSettingCountryTheaterMapping__c> CountryTheaterMap = CustomSettingCountryTheaterMapping__c.getAll();
      	List<CustomSettingCountryTheaterMapping__c> customTheaterData = new List<CustomSettingCountryTheaterMapping__c>();
      	CustomSettingCountryTheaterMapping__c USA = CountryTheaterMap.get('USA');
		       if(USA==null)
		        {
		        	USA = new CustomSettingCountryTheaterMapping__c(Name = 'USA');
		      		USA.Cluster__c=null;
		            USA.Theater__c='Americas';
		            USA.CountryCode__c='US';
		            customTheaterData.add(USA);
		        }
         if(customTheaterData.size()>0){
           Database.insert(customTheaterData,false);
         } 
        }
        Account account1 = createAccount('TestAccount1');
        Account account2 = createAccount('TestAccount2');

        //Creating the dummy grouping on the previously created account for 
        //test class.
        Account_Groupings__c grouping = new Account_Groupings__c();
        grouping.Name = 'TestGrouping1';
        grouping.Active__c = true;
        grouping.Profiled_Account__c = account1.id;
        grouping.No_Master_Required__c = false;
        insert grouping;
               
        Contact contact1 = createContact(account1.Id,'User1');
        Contact contact2 = createContact(account2.Id,'User2');
       
        User contactUser1;
        User contactUser2;
        System.runAs(insertUser)
        {
        contactUser1 = createUser(contact1.Id,'TestUser1');
        contactUser2 = createUser(contact2.Id,'TestUser2');
        }
       
        //Test data finish

        Test.startTest();
        //Here scheduling the test class to run one minute after submitting
        //the test class.
        Datetime dt = System.now();
        dt = dt.addMinutes(1);       
        String scheduleString='0';//0 seconds
        scheduleString+=' '+ dt.minute();   
        scheduleString+=' '+ dt.hour();     
        scheduleString+=' '+ dt.day();      
        scheduleString+=' '+ dt.month();       
        scheduleString+=' ?';
        scheduleString+=' '+ dt.year();
        String jobName = 'Share Account Batch - ' + dt.format('MM-dd-yyyy-hh:');
        //Here creating the instance of the schedular class 
        //PRM_AccountAssignmentScheduler.
        PRM_AccountAssignmentScheduler nextBatchJob = new PRM_AccountAssignmentScheduler();
        //Here scheduling the class by passing the jobname, scheduleString
        //which is the time component and object of the schedule class.       
        String jobId = System.schedule(jobName,scheduleString,nextBatchJob);
        
        Test.stopTest();
        
    }
    
    //Test Data Start

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
            Site_DUNS_Entity__c='5693241',
            BillingCountry = 'USA'
        );
        insert account;
        return account;
    }

/* @Method <This method createContact is used create contact for the test class>
   @param <Taking Id as paramter which contains newly created accountId>
   @return <void> - <Contact record>
   @throws exception - <No Exception>
*/

    public static Contact createContact(Id accountId,String ContactName){
        //Creating the dummy contact on the previously created account for test class.
        Contact contact = new Contact(
            FirstName='Test',
            LastName=ContactName,
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

    public static User createUser(Id contactId, String UserNames){
        //Creating the dummy user on the previously created contact for the 
        //test class.
   // Req#1117.
       Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
       String directReseller = data.get('EMEA Direct Reseller Partner User').DataValue__c ;
       String distributionVAR = data.get('EMEA Distribution VAR Partner User').DataValue__c ;
    // Changes End.  
    //Changed here the profile Id.
        User tempUsr = new User(
            Username=UserNames+Math.random()+'@acme.com.test',
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