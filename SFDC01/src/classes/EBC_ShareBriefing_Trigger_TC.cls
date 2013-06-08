@isTest(SeeAllData = true)
/*
Created by: Vijo Joy
Created On: 1st March, 2013
Description: This test class is to cover the EBC_shareBriefing Trigger
Wr/eRFC: 

*/

 private class EBC_ShareBriefing_Trigger_TC{
     //initialisations
     
     
        static testmethod void testShareBE(){
        Account acnt = createAccount('Test Acc Sharing');
        EBC_Briefing_Center__c bc= createBriefingCenter('testBriefingCenter');
        EBC_Briefing_Event__c bEvent = createBriefingEvent('testBEvent',acnt.id,'testBriefingCenter');
        Contact con = createContact('test','user1',acnt);
        //creating a user to match the contact email
        Profile p = [SELECT Id FROM Profile WHERE Name='AMER Commercial User']; 
        User testUser = new User(Alias = 'test', Email='test@emc.com.test', 
                                  EmailEncodingKey='UTF-8', LastName='test', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', UserName='testusershare@emc.com');
        insert testUser;
            //initial creation of invitees
            EBC_invitees__c testInvitee = new EBC_invitees__c();
            //initialising the system admin user
            Profile pa = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User adminUser = createUser('atest4', pa.id);
            System.RunAs(adminUser){
            testInvitee= new EBC_invitees__c(Briefing_Team_Role__c='Logistic Advisor',
                                                  Last_Name__c= con.Lastname,
                                                  First_Name__c= con.FirstName,
                                                  Attendee_Email__c= 'test@emc.com.test',
                                                  From_Object__c='Event',
                                                  EBC_Name__c=con.FirstName+' '+con.Lastname,
                                                  EBC_Title__c= 'Test',
                                                  Attending__c=true,
                                                  Briefing_Event__c= bEvent.Id,
                                                  Contact__c= con.id);
             insert testInvitee;
             //updating the invitee to trigger
             testInvitee.Briefing_Team_Role__c = 'Account team member';
             Update testInvitee;
             }
             

            } 
                                                  
        
        
        
    //Method: creating test account 
        private static Account createAccount(String accName){
        //initialising the account variable
        Account acc;
        //initialising the system admin user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminUser = createUser('atest', p.id);
        System.RunAs(adminUser){
        //setting the custom settings, for account
        //CustomSetting_eBusiness_SFDC_Integration__c custSetting = new CustomSetting_eBusiness_SFDC_Integration__c();
        //custSetting.Name = 'eBus_Partner_Enabled__c';
        //custSetting.Id_Values__c = '';
        //custSetting.String_Values__c = 'finder;punchout;finder & punchout';
        //insert custSetting;
        //end of custom settings
        acc = new Account(Name = accName);
        insert acc;
        }
        return acc;
        }
        //Method: creating test contact
        private static Contact createContact(String fstName, String lstName, Account accnt){
        //initialising the contact
        Contact cont;
        //initialising the system admin user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminUser = createUser('atest3', p.id);
        System.RunAs(adminUser){
                cont = new Contact(FirstName = fstName,
                                   LastName = lstName,
                                   Account = accnt);
        insert cont;
        }
        return cont;
        }
        //Method: creating a briefing center
        private static EBC_Briefing_Center__c createBriefingCenter(String bcName){
        //initialising the briefing center variable
        EBC_Briefing_Center__c bc = new EBC_Briefing_Center__c();
        //initialising the system admin user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminUser = createUser('atest1', p.id);
        System.RunAs(adminUser){
        bc = new EBC_Briefing_Center__c(Name = bcName);
        insert bc;
        }
        return bc;
        }
        //Method: creating a briefing event
        private static EBC_Briefing_Event__c createBriefingEvent(String beName, Id accntId, String bcName){
        //initialising the briefing event
        EBC_Briefing_Event__c be = new EBC_Briefing_Event__c();
        //initialising the system admin user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminUser = createUser('atest2', p.id);
        System.RunAs(adminUser){
                              be = new EBC_Briefing_Event__c(Name = beName,
                                                             Start_Date__c = Date.Today(),
                                                             End_Date__c = Date.Today().addDays(1),
                                                             Briefing_Center__c = [Select id from EBC_Briefing_Center__c where Name =: bcName LIMIT 1].id,
                                                             Briefing_Status__c = 'Pending',
                                                             Customer_Name__c = accntId);
        insert be;
        }
        return be;
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