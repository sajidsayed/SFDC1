/*
Created by: Vijo Joy
Created On: March 29th, 2013
Description: Test class to test the EBC_createBriefingInvitees class
Work Request/eRFC: WR240944

****Modification History****
    Modified By: 
    Modified On:
    Description:
    Work Request/eRFC:

*/
@isTest

private class EBC_createBriefingInvitees_TC{
   
    static testMethod void testInsertUpdateAndDeleteTopicPresenters(){
    	//creating an admin user for this test method
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminUser = createUser('Admin', p.id);
        //creating a briefing event
        Account acc = createAccount('testAcc', adminUser);
        EBC_Briefing_Center__c bc= createBriefingCenter('testBriefingCenter', adminUser);
        EBC_Briefing_Event__c bEvent = createBriefingEvent('testBEvent',acc.id,bc.id, adminUser);
        //creating a topic, topic presenter
        Contact c = createContact('fstname','lstname',acc, adminUser);
        EBC_Topics__c tpc = createTopic('Test Topic', adminUser);
        EBC_Topic_Presenters__c tp= createTopicPresenter('Test TPresenter',c.id, tpc.id, adminUser);
        //create a session first
        EBC_Session__c ses = createSession(bEvent.id, tpc.id, adminUser);
        //Creating a session presenter
        EBC_Session_Presenter__c tPresenter = New EBC_Session_Presenter__c(Name = 'TestsessP',
                                                                          Session__c = ses.id,
                                                                          Topic_Presenters__c = tp.id);
        
        System.RunAs(adminUser){
        //inserting the session presenter. An invitee should be created for this presenter
        insert tPresenter;
        }
        List<EBC_Invitees__c> lstInv = new List<EBC_Invitees__c>([Select Id, Attendee_Email__c from  EBC_Invitees__c where Briefing_Event__c =:bEvent.id ]);
        //asserting that the invitee has the email id as that of the contact created, thus proving true
        system.assertEquals('fstname.lstname@emc.com',lstInv[0].Attendee_Email__c);
        
        //testing for updating the topic presenters
         	//creating another topic presenter, and then update the above session presenter with this
        	//creating a topic, topic presenter
        Contact c1 = createContact('fstname1','lstname1',acc, adminUser);
        EBC_Topics__c tpc1 = createTopic('Test Topic1', adminUser);
        EBC_Topic_Presenters__c tp1= createTopicPresenter('Test TPresenter1',c1.id, tpc1.id, adminUser);
        //assigning values to the presenter
        tPresenter.Topic_Presenters__c = tp1.id;
        
        //updating the session presenter
        System.RunAs(adminUser){
        Update tPresenter;
        }
        //asserting the following
        lstInv.clear();
        lstInv = new List<EBC_Invitees__c>([Select Id, Attendee_Email__c from  EBC_Invitees__c where Briefing_Event__c =:bEvent.id ]);
        	//first that only one invitee is present for the briefing event
        	system.assertequals(lstInv.size(),1);
        	//second that the only invitee has the email id of second topic presenter
        	system.assertEquals('fstname1.lstname1@emc.com',lstInv[0].Attendee_Email__c);
        
        //deleting the topic presenter
        System.RunAs(adminUser){
        Delete tPresenter;
        }
        //asserting that the number of invitees is zero, thus confirming that the above invitee is deleted when presenter is deleted
        lstInv.clear();
        lstInv = new List<EBC_Invitees__c>([Select Id, Attendee_Email__c from  EBC_Invitees__c where Briefing_Event__c =:bEvent.id ]);
        system.assertequals(lstInv.size(),0);
    }
    
    static testMethod void testInsertUpdateAndDeleteGuestPresenters(){
    	//creating an admin user for this test method
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminUser = createUser('Admin', p.id);
        //creating a briefing event
        Account acc = createAccount('testAcc', adminUser);
        EBC_Briefing_Center__c bc= createBriefingCenter('testBriefingCenter', adminUser);
        EBC_Briefing_Event__c bEvent = createBriefingEvent('testBEvent',acc.id,bc.id, adminUser);
        //creating a topic
        EBC_Topics__c tpc = createTopic('Test Topic', adminUser);
        //create a session
        EBC_Session__c ses = createSession(bEvent.id, tpc.id, adminUser);
        //Creating a session presenter
        EBC_Session_Presenter__c gPresenter = New EBC_Session_Presenter__c(Name = 'TestsessP',
                                                                          Session__c = ses.id,
                                                                          Guest_Presenter__c = true,
                                                                          Guest_Presenter_First_Name__c = 'gfstname',
                                                                          Guest_Presenter_Last_Name__c = 'glstname',
                                                                          Guest_Presenter_EBC_Title__c = 'gtitle',
                                                                          Guest_Presenter_Email__c = 'gfstname.glstname@rsa.com',
                                                                          Guest_Company__c = 'RSA');
        
        System.RunAs(adminUser){
        //inserting the session presenter. An invitee should be created for this presenter
        insert gPresenter;
        }
        List<EBC_Invitees__c> lstInv = new List<EBC_Invitees__c>([Select Id, Attendee_Email__c from  EBC_Invitees__c where Briefing_Event__c =:bEvent.id ]);
        //asserting that the invitee has the email id as that of the contact created, thus proving true
        system.assertEquals('gfstname.glstname@rsa.com',lstInv[0].Attendee_Email__c);
        
        //testing for updating the guest presenters
        //assigning values to the presenter
        gPresenter.Guest_Presenter_First_Name__c = 'gfstname1';
        gPresenter.Guest_Presenter_Last_Name__c = 'glstname1';
        gPresenter.Guest_Presenter_EBC_Title__c = 'gtitle1';
        gPresenter.Guest_Presenter_Email__c = 'gfstname1.glstname1@rsa.com';
        gPresenter.Guest_Company__c = 'RSA';
        
        //updating the session presenter
        System.RunAs(adminUser){
        Update gPresenter;
        }
        //asserting the following
        lstInv.clear();
        lstInv = new List<EBC_Invitees__c>([Select Id, Attendee_Email__c from  EBC_Invitees__c where Briefing_Event__c =:bEvent.id ]);
        	//first that only one invitee is present for the briefing event
        	system.assertequals(lstInv.size(),1);
        	//second that the only invitee has the email id of second topic presenter
        	system.assertEquals('gfstname1.glstname1@rsa.com',lstInv[0].Attendee_Email__c);
        
        //deleting the topic presenter
        System.RunAs(adminUser){
        Delete gPresenter;
        }
        //asserting that the number of invitees is zero, thus confirming that the above invitee is deleted when presenter is deleted
        lstInv.clear();
        lstInv = new List<EBC_Invitees__c>([Select Id, Attendee_Email__c from  EBC_Invitees__c where Briefing_Event__c =:bEvent.id ]);
        system.assertequals(lstInv.size(),0);
    }
     
    	//Method: creating test account 
        private static Account createAccount(String accName, User adminUser){
        //initialising the account variable
        Account acc;
        System.RunAs(adminUser){
        acc = new Account(Name = accName);
        insert acc;
        }
        return acc;
        }
        
        //Method: creating test contact
        private static Contact createContact(String fstName, String lstName, Account accnt, User adminUser){
        GenUtilMethods gm = new GenUtilMethods();
            //initialising the contact
        Contact cont;
        System.RunAs(adminUser){
                cont = new Contact(FirstName = fstName,
                                   LastName = lstName,
                                   Email = fstName+'.'+lstName+'@emc.com',
                                   Account = accnt,
                                  RecordTypeId = gm.getRecordTypesMap('Contact').get('EMC Internal Contact'));
        insert cont;
        }
        return cont;
        }
    
        //Method: creating a briefing center
        private static EBC_Briefing_Center__c createBriefingCenter(String bcName, User adminUser){
        //initialising the briefing center variable
        EBC_Briefing_Center__c bc = new EBC_Briefing_Center__c();
        System.RunAs(adminUser){
        bc = new EBC_Briefing_Center__c(Name = bcName);
        insert bc;
        }
        return bc;
        }
    
        //Method: creating a briefing event
        private static EBC_Briefing_Event__c createBriefingEvent(String beName, Id accntId, Id bcId, User adminUser){
        //initialising the briefing event
        EBC_Briefing_Event__c be = new EBC_Briefing_Event__c();
        System.RunAs(adminUser){
                              be = new EBC_Briefing_Event__c(Name = beName,
                                                             Start_Date__c = Date.Today(),
                                                             End_Date__c = Date.Today().addDays(1),
                                                             Briefing_Center__c = bcId,
                                                             Briefing_Status__c = 'Pending',
                                                             Customer_Name__c = accntId);
        insert be;
        }
        return be;
        }
    
    	//method to create a topic
    	private static EBC_Topics__c createTopic(String topicName, User adminUser)
    	{
        //initialising the topic record
        EBC_Topics__c topic = new EBC_Topics__c();
        System.RunAs(adminUser){
        topic = new EBC_Topics__c(Name = topicName);
        insert topic;
        }
        return topic;   
    	}
    
    	//method to create a topic presenter
    	private static EBC_Topic_Presenters__c createTopicPresenter(String TPresenterName, id contactId, id TopicId, User adminUser)
    	{
        //initialising the topic presenter record
        EBC_Topic_Presenters__c topicPresenter = new EBC_Topic_Presenters__c();
        System.RunAs(adminUser){
        topicPresenter = new EBC_Topic_Presenters__c(Name = TPresenterName,
                                                    Topic__c = TopicId,
                                                    Presenter__c = contactId);
        insert topicPresenter;
        }
        return topicPresenter;    
    	}
    
    	//method to create a session
    	private static EBC_Session__c createSession(id briefingEventId, id TopicId, User adminUser)
    	{
        //initialising the session
        EBC_Session__c BSession = new EBC_Session__c();
        System.RunAs(adminUser){
        BSession = new EBC_Session__c(Topic__c = TopicId,
                                      Briefing_Event__c = briefingEventId);
        insert BSession;
        }
        return BSession;  
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