/*
Created by: Vijo Joy
Created On: Feb 18th, 2013
Description: Test class to test the EBC_addEventAttendee class
Work Request/eRFC: WR226913

****Modification History****
    Modified By: 
    Modified On:
    Description:
    Work Request/eRFC:

*/
@isTest

private class EBC_addEventAttendee_TC {
    
    //initialising functions
        //Method: creating test account 
        private static Account createAccount(String accName){
        //setting the custom settings, for account
        CustomSetting_eBusiness_SFDC_Integration__c custSetting = new CustomSetting_eBusiness_SFDC_Integration__c();
        custSetting.Name = 'eBus_Partner_Enabled__c';
        custSetting.Id_Values__c = '';
        custSetting.String_Values__c = 'finder;punchout;finder & punchout';
        insert custSetting;
        //end of custom settings
        Account acc = new Account(Name = accName);
        insert acc;
        return acc;
        }
        //Method: creating test contact
        private static Contact createContact(String fstName, String lstName, Account accnt){
        Contact cont = new Contact(FirstName = fstName,
                                   LastName = lstName,
                                   Account = accnt);
        insert cont;
        return cont;
        }
        //Method: creating a briefing center
        private static EBC_Briefing_Center__c createBriefingCenter(String bcName){
        EBC_Briefing_Center__c bc = new EBC_Briefing_Center__c(Name = bcName);
        insert bc;
        return bc;
        }
        //Method: creating a briefing event
        private static EBC_Briefing_Event__c createBriefingEvent(String beName, Id accntId, String bcName){
        EBC_Briefing_Event__c be = new EBC_Briefing_Event__c(Name = beName,
                                                             Start_Date__c = Date.Today(),
                                                             End_Date__c = Date.Today().addDays(1),
                                                             Briefing_Center__c = [Select id from EBC_Briefing_Center__c where Name =: bcName LIMIT 1].id,
                                                             Customer_Name__c = accntId);
        insert be;
        return be;
        }
        //Method:creating an event.
        //Calendar taken is hopkinton, id = 02370000000nVuJ
        private static Event createEvent(String evSubject, Id evWhatId){
        GenUtilMethods gUtil = new GenUtilMethods();
        Event ev = new Event(Subject = evSubject,
                             OwnerId = '02370000000nVuJ',
                             WhatId = evWhatId,
                             StartDateTime = DateTime.now(),
                             EndDateTime = DateTime.now().addDays(1),
                             RecordTypeId = gUtil.getRecordTypesMap('Event').get('Briefing Event')
                             );
        insert ev;
        return ev;
        }
    
    //Test 1: To check attendee creation in event.
    static testMethod void test_createAttendee(){
    //initialising the class
    EBC_addEventAttendee testInstEventAttendee= new EBC_addEventAttendee();
    
    //creating a briefing event for event
        //creating a briefing center, with Hopkinton name since the calendar is used
        EBC_Briefing_Center__c testBC = createBriefingCenter('Hopkinton');
        //creating an account for briefing event
        Account testAcc = createAccount('Test account 1 for EBC');
        //creating a contact for the account, to use in event
        Contact testCont = createContact('test', 'Contact1', testAcc);
    EBC_Briefing_Event__c testBE = createBriefingEvent('test Briefing Event 1', testAcc.id, testBC.Name);
    //creating the event
    Event testEv = createEvent(testBE.Name, testBE.id);
    //creating invitees for the event
    testInstEventAttendee.createEventAttendee(testEv.id, testCont.id);
    }
    
    //Test 2: To check invitee creation in briefing event.
        //Sub Test A: To check when the requestor is a contact
        static testMethod void test_requestorInvitee_contact(){
            //creating a briefing event for event
                //creating a briefing center, with Hopkinton name since the calendar is used
                EBC_Briefing_Center__c testBC = createBriefingCenter('Hopkinton');
                //creating an account for briefing event
                Account testAcc = createAccount('Test account 2_A for EBC');
                //creating a contact for the account, to use in event
                Contact testCont = createContact('test', 'Contact2_A', testAcc);
            EBC_Briefing_Event__c testBE = createBriefingEvent('test Briefing Event 2_A', testAcc.id, testBC.Name);
            Test.startTest();
            EBC_addEventAttendee.toCreateRequestorinvitee(testCont.id, testBE.id);
            Test.stopTest();
        }
        //Sub Test B: To check when the requestor is a user
        static testMethod void test_requestorInvitee_user(){
            //creating a briefing event for event
                //creating a briefing center, with Hopkinton name since the calendar is used
                EBC_Briefing_Center__c testBC = createBriefingCenter('Hopkinton');
                //creating an account for briefing event
                Account testAcc = createAccount('Test account 2_B for EBC');
                //creating a user, with profile as 'AMER Commercial User'
                Profile p = [SELECT Id FROM Profile WHERE Name='AMER Commercial User']; 
                User testUser = new User(Alias = 'testU2_B', Email='testuser@emc.com', 
                                  EmailEncodingKey='UTF-8', LastName='Test User2_B', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', UserName='testuser@emc.com');
            EBC_Briefing_Event__c testBE = createBriefingEvent('test Briefing Event 2_B', testAcc.id, testBC.Name);
            Test.startTest();
            EBC_addEventAttendee.toCreateRequestorinvitee(testUser.id, testBE.id);
            Test.stopTest();
        }
    //Test 3: To catch the exception in toCreateRequestorinvitee method
    static testMethod void test_exception(){
    try
        {
        //passing illogical contact and briefing event ids, hence triggering the try-catch expression
         EBC_addEventAttendee.toCreateRequestorinvitee('00300000000ZZZZ','a0k000000000asd');
        }
    catch(Exception e)
        {
        }
    }   
}