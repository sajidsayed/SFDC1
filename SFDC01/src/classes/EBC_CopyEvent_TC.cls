@isTest
private class EBC_CopyEvent_TC{

public static testMethod void Test_EBC_CopyEvent(){
	date testDate = date.today();

    //Create Topics for adding to Sessions on Briefing Event
    List<EBC_Topics__c> topics = new List<EBC_Topics__c>();
    EBC_Topics__c topicA = new EBC_Topics__c();
        topicA.Name = 'Topic A';
        topicA.Active__c = true;
        topics.add(topicA);
    EBC_Topics__c topicB = new EBC_Topics__c();
        topicB.Name = 'Topic B';
        topicB.Active__c = true;
        topics.add(topicB);
    EBC_Topics__c topicC = new EBC_Topics__c();
        topicC.Name = 'Topic C';
        topicC.Active__c = true;
        topics.add(topicC);
    EBC_Topics__c topicD = new EBC_Topics__c();
        topicD.Name = 'Topic D';
        topicD.Active__c = true;
        topics.add(topicD);
    insert topics;
    
    //Then establish relationships of Topic/Presenter
    List<EBC_Topic_Presenters__c> topicPresenters = new List<EBC_Topic_Presenters__c>();
    EBC_Topic_Presenters__c presenter1_tA = new EBC_Topic_Presenters__c();
        presenter1_tA.Name = 'Presenter 1, Topic A';
        presenter1_tA.Topic__c = topicA.Id;
        presenter1_tA.Active__c = true;
        topicPresenters.add(presenter1_tA);
    EBC_Topic_Presenters__c presenter2_tA = new EBC_Topic_Presenters__c();
        presenter2_tA.Name = 'Presenter 2, Topic A';
        presenter2_tA.Topic__c = topicA.Id;
        presenter2_tA.Active__c = false;
        topicPresenters.add(presenter2_tA);
    EBC_Topic_Presenters__c presenter1_tB = new EBC_Topic_Presenters__c();
        presenter1_tB.Name = 'Presenter 1, Topic B';
        presenter1_tB.Topic__c = topicA.Id;
        presenter1_tB.Active__c = true;
        topicPresenters.add(presenter1_tB);
    insert topicPresenters;
    
    //Create a 2 day event with sessions that will be the copy source
    //with its corresponding Session/Session Presenters
    List<EBC_Briefing_Event__c> sources = new List<EBC_Briefing_Event__c>();
    EBC_Briefing_Event__c sourceevent1 = new EBC_Briefing_Event__c();
        sourceevent1.name = 'test source 1';
        sourceevent1.Start_Date__c = date.newInstance(2010, 1, 2);
        sourceevent1.End_Date__c = date.newInstance(2010, 1, 3);
        sourceevent1.Briefing_Status__c = 'Open';
        sourceevent1.Objective_of_the_Visit__c = 'test objective';
        sources.add(sourceevent1);
    EBC_Briefing_Event__c sourceevent2 = new EBC_Briefing_Event__c();
        sourceevent2.name = 'test source 2';
        sourceevent2.Start_Date__c = date.newInstance(2010, 1, 2);
        sourceevent2.Briefing_Status__c = 'Open';
        sourceevent2.Objective_of_the_Visit__c = 'test objective';
        sources.add(sourceevent2);
    EBC_Briefing_Event__c sourceevent3 = new EBC_Briefing_Event__c();
        sourceevent3.name = 'test source 3';
        sourceevent3.Start_Date__c = date.newInstance(2012, 10, 25);
        sourceevent3.End_Date__c = date.newInstance(2012, 10, 30);
        sourceevent3.Briefing_Status__c = 'Open';
        sourceevent3.Objective_of_the_Visit__c = 'test objective';
        sources.add(sourceevent3);
    insert sources;
    
    List<EBC_Session__c> sessions = new List<EBC_Session__c>();    
    EBC_Session__c source_session1 = new EBC_Session__c();
        source_session1.Briefing_Event__c = sourceevent1.Id;
        source_session1.Topic__c = topicA.Id;
        source_session1.Topic_Override__c = 'session_one';
        source_session1.Session_Start_Time__c = datetime.newInstance(2010, 1, 2, 9, 0, 0);
        source_session1.Session_End_Time__c = datetime.newInstance(2010, 1, 2, 17, 0, 0);
        sessions.add(source_session1);
    EBC_Session__c source_session2 = new EBC_Session__c();
        source_session2.Briefing_Event__c = sourceevent1.Id;
        source_session2.Topic__c = topicB.Id;
        source_session2.Topic_Override__c = 'session_two';
        source_session2.Session_Start_Time__c = datetime.newInstance(2010, 1, 3, 9, 0, 0);
        source_session2.Session_End_Time__c = datetime.newInstance(2010, 1, 3, 11, 0, 0);
        sessions.add(source_session2);
   EBC_Session__c source_session3 = new EBC_Session__c();
        source_session3.Briefing_Event__c = sourceevent1.Id;
        source_session3.Topic__c = topicC.Id;
        source_session3.Topic_Override__c = 'session_three';
        source_session3.Session_Start_Time__c = datetime.newInstance(2010, 1, 3, 9, 0, 0);
        source_session3.Session_End_Time__c = datetime.newInstance(2010, 1, 3, 11, 0, 0);
        sessions.add(source_session3);
   EBC_Session__c source_session4 = new EBC_Session__c();
        source_session4.Briefing_Event__c = sourceevent1.Id;
        source_session4.Topic__c = topicD.Id;
        source_session4.Topic_Override__c = 'session_four';
        source_session4.Session_Start_Time__c = datetime.newInstance(2010, 1, 3, 9, 0, 0);
        source_session4.Session_End_Time__c = datetime.newInstance(2010, 1, 3, 11, 0, 0);
        sessions.add(source_session4);
   insert sessions;
   
   //Internal Presenters
   List<EBC_Session_Presenter__c> sessionPresenters = new List<EBC_Session_Presenter__c>();
   EBC_Session_Presenter__c presenter1_session1 = new EBC_Session_Presenter__c();
        presenter1_session1.Session__c = source_session1.Id;
        presenter1_session1.Is_Certified__c = true;
        presenter1_session1.Topic_Presenters__c = presenter1_tA.Id;
        sessionPresenters.add(presenter1_session1);
    EBC_Session_Presenter__c presenter2_session1 = new EBC_Session_Presenter__c();
        presenter2_session1.Session__c = source_session1.Id;
        presenter2_session1.Is_Certified__c = true;
        presenter2_session1.Topic_Presenters__c = presenter2_tA.Id;
        sessionPresenters.add(presenter2_session1);
    EBC_Session_Presenter__c presenter1_session2 = new EBC_Session_Presenter__c();
        presenter1_session2.Session__c = source_session2.Id;
        presenter1_session2.Is_Certified__c = true;
        presenter1_session2.Topic_Presenters__c = presenter1_tB.Id;
        sessionPresenters.add(presenter1_session2);
    insert sessionPresenters;
        
    //Guest Presenters
    List<EBC_Session_Presenter__c> guests = new List<EBC_Session_Presenter__c>();
    EBC_Session_Presenter__c guest1_session1 = new EBC_Session_Presenter__c();
        guest1_session1.Session__c = source_session1.Id;
        guest1_session1.Guest_Presenter__c = true;
        guest1_session1.Guest_Presenter_First_Name__c = 'Guest';
        guest1_session1.Guest_Presenter_Last_Name__c = 'Number One';
        guest1_session1.Guest_Presenter_Email__c = 'guest1@emc.com.sfdc01';
        guest1_session1.Guest_Presenter_EBC_Title__c = 'Guest';
        guest1_session1.Guest_Company__c = 'External';
        guests.add(guest1_session1);
    EBC_Session_Presenter__c guest2_session2 = new EBC_Session_Presenter__c();
        guest2_session2.Session__c = source_session2.Id;
        guest2_session2.Guest_Presenter__c = true;
        guest2_session2.Guest_Presenter_First_Name__c = 'Guest';
        guest2_session2.Guest_Presenter_Last_Name__c = 'Number Two';
        guest2_session2.Guest_Presenter_Email__c = 'guest2@emc.com.sfdc01';
        guest2_session2.Guest_Presenter_EBC_Title__c = 'Guest';
        guest2_session2.Guest_Company__c = 'External';
        guests.add(guest2_session2);
    insert guests;

    // Create an event that will be the copy target
    List<EBC_Briefing_Event__c> targets = new List<EBC_Briefing_Event__c>();
    //Scenario 0: Target without Start/End Dates
    EBC_Briefing_Event__c event0 = new EBC_Briefing_Event__c();
        event0.name = 'another target';
        event0.Briefing_Status__c = 'Open';
        targets.add(event0);
    //Scenario 1: Target with both Start/End Dates
    EBC_Briefing_Event__c event1 = new EBC_Briefing_Event__c();
        event1.name = 'test target';
        event1.Briefing_Status__c = 'Open';
        event1.Start_Date__c = date.newInstance(2013, 4, 26);
        event1.End_Date__c = date.newInstance(2013, 4, 27);
        targets.add(event1);
    insert targets;
    
    //Set the doSearch results set to return the two test events
    Id[] fixedSearchResults= new Id[]{event0.Id, event1.Id, sourceevent1.Id, sourceevent2.Id, sourceevent3.Id,
    	source_session1.Id, source_session2.Id, topicA.Id, topicB.Id, topicC.Id, topicB.Id, guest1_session1.Id,
    	guest2_session2.Id};
    Test.setFixedSearchResults(fixedSearchResults);
    
    PageReference pageRef = Page.EBC_CopyEvent;
    Test.setCurrentPage(pageRef);
    
    //Basic Test, Scenario 0
    pageRef.getParameters().put('id', event0.Id);
    ApexPages.Standardcontroller e0 = new Apexpages.Standardcontroller(event0);
    EBC_CopyEvent controller0 = new EBC_CopyEvent(e0);
    
    controller0.copyHeader = true;
    controller0.copySession = true;
    controller0.copyDateTime = true;
    controller0.copyPresenter = true;

    controller0.setSearchText('another');
    controller0.doSearch();
    
    controller0.setSelectedEvent(sourceevent1.Id);
    controller0.updateEvent();
    
    //First Test, Scenario 1
    pageRef.getParameters().put('id', event1.Id);
    ApexPages.Standardcontroller e1 = new Apexpages.Standardcontroller(event1);
    EBC_CopyEvent controller1 = new EBC_CopyEvent(e1);
    
    controller1.copyHeader = true;
    controller1.copySession = true;
    controller1.copyDateTime = true;
    controller1.copyPresenter = true;

    controller1.setSearchText('test');
    controller1.doSearch();
    
    String searchTerm = controller1.getSearchText();
    System.assertEquals('test', searchTerm);
    
    List<EBC_Briefing_Event__c> searchResult = controller1.getResults();
    
    controller1.updateEvent();
    
    controller1.setSelectedEvent(sourceevent1.Id);
    controller1.updateEvent();
    
    controller1.setSearchText('abcxyz123*');
    controller1.doSearch();
    controller1.doCancel();
    
    //Second Test, Scenario 1
    controller1.setSelectedEvent(sourceevent2.Id);
    controller1.updateEvent();
    
    //Third Test, Scenario 1
    controller1.setSelectedEvent(sourceevent3.Id);
    controller1.updateEvent();
    }
}