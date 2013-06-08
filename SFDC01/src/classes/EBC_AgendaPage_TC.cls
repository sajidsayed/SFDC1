@isTest
private class EBC_AgendaPage_TC {
    static EBC_AgendaPage Ctlr;
    static EBC_Briefing_Event__c BEvent;
    static EBC_Topics__c topic;
    static PageReference EBCPage;
        
    private static void init(){
      BEvent = new EBC_Briefing_Event__c(Name='test',Start_Date__c=date.today(),End_Date__c=date.today(),Briefing_Status__c='Pending');
      insert BEvent;
      topic = new EBC_Topics__c(Name='topic');
      insert topic;
      EBCPage = Page.EBC_AgendaPage;
      EBCPage.getParameters().put('Id',BEvent.Id);
      Test.setCurrentPage(EBCPage);
    }
    
    static testMethod void saveSession(){
      User_Locales__c ul = new User_Locales__c(Name = 'en_US', LocaleKey__c = 'en_US');
      insert ul;
    
      init();
      ApexPages.StandardController sc = new ApexPages.standardController(BEvent);
      EBC_AgendaPage eap = new EBC_AgendaPage(sc);

      EBC_Session__c sess=new EBC_Session__c(Name='sessions',Topic__c=topic.Id,Briefing_Event__c=BEvent.Id,Session_Start_Time__c=datetime.now(),Session_End_Time__c=datetime.now(),Session_Start_Date__c=date.today(),Session_End_Date__c=date.today(),Status__c='No longer active.');
      insert sess;
      
      List <object> temp = eap.getSessionlisttodisplay();
      eap.getMinuteOptions();
      eap.getHourOptions();
      eap.getconfirmoptions();
      eap.savepage();
    }
    
    /*Sessions with Guest Presenters*/
    static testMethod void saveSessionAndPresenters1(){
      User_Locales__c ul = new User_Locales__c(Name = 'en_US', LocaleKey__c = 'en_US');
      insert ul;
    
      init();
      ApexPages.StandardController sc = new ApexPages.standardController(BEvent);
      EBC_AgendaPage eap = new EBC_AgendaPage(sc);
    
      EBC_Session__c sess=new EBC_Session__c(Name='sessions',Topic__c=topic.Id,Briefing_Event__c=BEvent.Id,Session_Start_Time__c=datetime.now(),Session_End_Time__c=datetime.now(),Session_Start_Date__c=date.today(),Session_End_Date__c=date.today(),Status__c='No longer active.');
      insert sess;
      
      List<EBC_Session_Presenter__c> presenters = new List<EBC_Session_Presenter__c>();
      EBC_Session_Presenter__c pres1 = new EBC_Session_Presenter__c(Session__c = sess.Id,
      Guest_Presenter__c = true, Guest_Presenter_First_Name__c = 'Guest Presenter 1');
      presenters.add(pres1);
      EBC_Session_Presenter__c pres2 = new EBC_Session_Presenter__c(Session__c = sess.Id,
      Guest_Presenter__c = true, Guest_Presenter_First_Name__c = 'Guest Presenter 2');
      presenters.add(pres2);
      EBC_Session_Presenter__c pres3 = new EBC_Session_Presenter__c(Session__c = sess.Id,
      Guest_Presenter__c = true, Guest_Presenter_First_Name__c = 'Guest Presenter 3');
      presenters.add(pres3);
      EBC_Session_Presenter__c pres4 = new EBC_Session_Presenter__c(Session__c = sess.Id,
      Guest_Presenter__c = true, Guest_Presenter_First_Name__c = 'Guest Presenter 4');
      presenters.add(pres4);
      EBC_Session_Presenter__c pres5 = new EBC_Session_Presenter__c(Session__c = sess.Id,
      Guest_Presenter__c = true, Guest_Presenter_First_Name__c = 'Guest Presenter 5');
      presenters.add(pres5);
      insert presenters;
    
      List <object> temp = eap.getSessionlisttodisplay();
      eap.getMinuteOptions();
      eap.getHourOptions();
      eap.getconfirmoptions();
      eap.savepage();
    }
   
    /*Sessions with Topic Presenters*/
    static testMethod void saveSessionAndPresenters2(){
      User_Locales__c ul = new User_Locales__c(Name = 'en_US', LocaleKey__c = 'en_US');
      insert ul;
    
      init();
      ApexPages.StandardController sc = new ApexPages.standardController(BEvent);
      EBC_AgendaPage eap = new EBC_AgendaPage(sc);
    
      EBC_Topics__c topicA = new EBC_Topics__c();
      topicA.Name = 'Topic A';
      topicA.Active__c = true;
      insert topicA;
    
      List<EBC_Topic_Presenters__c> topicPresenters = new List<EBC_Topic_Presenters__c>();
      EBC_Topic_Presenters__c tpres1 = new EBC_Topic_Presenters__c();
      tpres1.Name = 'Presenter 1, Topic A';
      tpres1.Topic__c = topicA.Id;
      tpres1.Active__c = true;
      topicPresenters.add(tpres1);
      insert topicPresenters;
    
      EBC_Session__c sess=new EBC_Session__c(Name='sessions',Topic__c=topic.Id,Briefing_Event__c=BEvent.Id,Session_Start_Time__c=datetime.now(),Session_End_Time__c=datetime.now(),Session_Start_Date__c=date.today(),Session_End_Date__c=date.today(),Status__c='No longer active.');
      insert sess;
      
      List<EBC_Session_Presenter__c> presenters = new List<EBC_Session_Presenter__c>();
      EBC_Session_Presenter__c pres1 = new EBC_Session_Presenter__c(Session__c = sess.Id,
      Topic_Presenters__c = tpres1.Id, Is_Certified__c = true);
      presenters.add(pres1);
      insert presenters;
    
      List <object> temp = eap.getSessionlisttodisplay();
      eap.getMinuteOptions();
      eap.getHourOptions();
      eap.getconfirmoptions();
      eap.savepage();
    }
   
    static testMethod void deleteSession(){
      init();
      ApexPages.StandardController sc = new ApexPages.standardController(BEvent);
      EBC_AgendaPage eap = new EBC_AgendaPage(sc);
      eap.TwntyFourHour = false;
    
      EBC_Session__c sess=new EBC_Session__c(Name='sessions',Topic__c=topic.Id,Briefing_Event__c=BEvent.Id,Session_Start_Time__c=datetime.now(),Session_End_Time__c=datetime.now(),Session_Start_Date__c=date.today(),Session_End_Date__c=date.today(),Status__c='No longer active.');
      insert sess;
      
      List<EBC_Session_Presenter__c> presenters = new List<EBC_Session_Presenter__c>();
      EBC_Session_Presenter__c pres1 = new EBC_Session_Presenter__c(Session__c = sess.Id);
      presenters.add(pres1);
      EBC_Session_Presenter__c pres2 = new EBC_Session_Presenter__c(Session__c = sess.Id);
      presenters.add(pres2);
      insert presenters;
    
      Id[] fiexdSearchResults = new Id[]{BEvent.Id, topic.Id, sess.Id, pres1.Id, pres2.Id};
      Test.setFixedSearchResults(fiexdSearchResults);
    
      EBCPage.getParameters().put('00A00000000AAAA',sess.Id);
      eap.doDelete();
      EBCPage.getParameters().put('deletedId',sess.Id);
      eap.doDelete();
    }
    
    static testMethod void addSession(){
      init();
      ApexPages.StandardController sc = new ApexPages.standardController(BEvent);
      EBC_AgendaPage eap = new EBC_AgendaPage(sc);
      eap.TwntyFourHour = false;
      
      eap.addasession();
      eap.SessionDetails[0].ESession.Session_Start_Date__c = date.newInstance(2013, 6, 3);
      eap.SessionDetails[0].ESession.Session_End_Date__c = date.newInstance(2013, 6, 5);
      eap.SessionDetails[0].ESession.Session_Start_Time__c = datetime.newInstance(2013, 6, 3, 9, 30, 5);
      eap.SessionDetails[0].ESession.Session_End_Time__c = datetime.newInstance(2013, 6, 5, 12, 30, 5);
      eap.SessionDetails[0].Presenter1.Guest_Presenter_Last_Name__c = 'GPresenter 1';
      eap.dothefinalsave();
    }
}