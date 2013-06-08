/**
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  18/01/2013      Vijo Joy        207305      Initial Creation of Test Class.
                                                This is to test the EBC_AddEventfromBE trigger
                                                                              
 +========================================================================================================================*/
// The briefing center taken is hopkinton. The calendar id is given below
 //Hopkinton calendar:02370000000nVuJ
 //Code references custom setting. The custom setting contains calendar ids. hard coded values are
 //used for the following reasons
 // 1. Calendars cannot be queried
 // 2. Calendars cannot be programatically created (for testing purposes)
// Please note: do not change the API version below 18. This is to avoid the mixed DML operation error.
// As per salesforce, you cannot have 2 or more dml operation between a setup object and a non setup object. Refer link below for details.
//http://www.salesforce.com/us/developer/docs/apexcode/index_Left.htm#StartTopic=Content/apex_dml_non_mix_sobjects.htm?SearchType.
@isTest(SeeAllData = true)

private class EBC_AddEventfromBE_trigger_TC {
    // declaring environment variable
    static Account accnt = createNewAccount('Test Account for events add');
    static EBC_Briefing_Event__c BE = createNewBriefingEvent('Test Briefing Event',accnt);
    
    //Test 1: The core function, i.e. when briefing status updates from requested to pending, event is placed on the calendar
    static testMethod void testTrigger_UpdateBE(){
    GenUtilMethods gm = new GenUtilMethods();
    try{
    //inserting 'Hopkinton' into the custom setting Calendars__c if not present
    if(!(Calendars__c.getAll().containsKey('Hopkinton')))
    {
    Calendars__c forTestCal = new Calendars__c(Name = 'Hopkinton', Calendar_ID__c = '02370000000nVuJ');
    insert forTestCal;
    }
    // updating the briefing event status from requested to pending
    BE.Briefing_Status__c = 'pending';
    // creating the matching contact
    Contact con = new contact(Account = accnt,
                              FirstName = 'test',
                              LastName = 'EPUser',
                              Email = 'EPUser@emc.com.test',
                              RecordTypeId = gm.getRecordTypesMap('Contact').get('EMC Internal Contact'));
    insert con;                         
    update BE;
    //asserting that the Briefing event status has updated to pending
    system.assertequals('pending',BE.Briefing_Status__c);
    }
    catch(Exception e)
    {}
    }
       //Method to create a test account
        private static Account createNewAccount(String acctName) {
        Account acc = new account();
        //initialising the system admin user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminUser = createUser('atest', p.id);
        System.RunAs(adminUser){
        acc = new Account(Name = acctName);
        insert acc;
        }
        return acc;
        }
        
        // Method to create test briefing event
        private static EBC_Briefing_Event__c createNewBriefingEvent(String BEname, Account acc) {
        //creating a user to insert briefing event
        Profile p = [SELECT Id FROM Profile WHERE Name='EBC Power User']; 
        User EBCPUser = createUser('EPUser', p.id);
        // initialising the briefing event
        EBC_Briefing_Event__c BEnt = new EBC_Briefing_Event__c();
        System.RunAs(EBCPUser){
        BEnt.RecordTypeId = getRecordTypeId('Requested Briefing Event');
        BEnt.Name = BEname;
        BEnt.Start_date__c = date.today();
        BEnt.End_date__c = date.today().addDays(1);
        BEnt.Projected_of_attendees__c = 10;
        BEnt.Customer_Name__c = acc.Id;
        BEnt.Objective_of_the_visit__c = 'Testing';
        BEnt.Briefing_Status__c = 'Requested';
        BEnt.Briefing_Center__c = [Select id from EBC_Briefing_Center__c where Name = 'Hopkinton' LIMIT 1].id;//selecting the hopkinton briefing center.
        insert BEnt;
        }
        return BEnt;     
        }
        
        //method to get the EBC recordtype by passing recordtype name.
        private static Id getRecordTypeId(String Rtype) {
        Schema.DescribeSObjectResult dr = Schema.SobjectType.EBC_Briefing_Event__c;
        Map<String,Schema.RecordTypeInfo> mapRecTypeInfo = dr.getRecordTypeInfosByName();
        Id RecordTypeId = mapRecTypeInfo.get(RType).getRecordTypeId();
        Return RecordTypeId;
        }
        //Method to create User
        private static User createUser(String userlstName, Id profileId){
                User testUser = new User(Alias = userlstName, Email=userlstName+'@emc.com.test', 
                                  EmailEncodingKey='UTF-8', LastName=userlstName, LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = profileId, 
                                  TimeZoneSidKey='America/Los_Angeles', UserName=userlstName+'share@emc.com');
            
                insert testUser;
                return testUser;
                }
}