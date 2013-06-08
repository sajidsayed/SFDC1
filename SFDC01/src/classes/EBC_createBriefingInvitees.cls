/*
*  Created By       :- Vijo Joy
*  Created Date     :- 21st March, 2013
*  WR/eRFC          :- WR240944
*  Description      :- This class will be used by trigger, 'EBC_CreateInvitees', to create/delete invitee records in briefing event, as 
                        and when session presenters are inserted or deleted on the Agenda page respectively.
*/

public class EBC_createBriefingInvitees {
    //Declaring environment variables
         GenUtilMethods gm = new GenUtilMethods();
         Id ContactRecTypeId = gm.getRecordTypesMap('Contact').get('EMC Internal Contact');
    //End of declaration
    
    //Method to insert invitees
    public void createInvitees(List<EBC_Session_Presenter__c> guestPresenters, List<EBC_Session_Presenter__c> topicPresenters){
        //declaring local variables
        List<EBC_Session_Presenter__c> lstAllPresentersToInsert = new List<EBC_Session_Presenter__c>();
        Set<Id> setBriefingSessionIds = new Set<Id>();
        Set<Id> setTopicPresenterIds = new Set<Id>();
        Set<Id> setPresenterIds = new Set<Id>();
        Set<Id> setBriefingEventIds = new Set<Id>();
        map<Id,EBC_Session__c> mapSessions = new map<Id,EBC_Session__c>();
        map<Id,EBC_Topic_Presenters__c> mapTopicPresenters = new map<Id,EBC_Topic_Presenters__c>();     
        List<EBC_Invitees__c> lstInviteesFromPresenters = new List<EBC_Invitees__c>();
        List<EBC_Invitees__c> inviteeInsertList = new List<EBC_Invitees__c>();
        Set<String>setEmailIdsOfPresenters = new Set<String>();
        Map<string, EBC_Session_Presenter__c> mapEmailToPresenters = new Map<string, EBC_Session_Presenter__c>();
        //End of declaration
        
        //combining the guest and topic presenters list to a common list
        if(guestPresenters.size()>0)
            {
            for(EBC_Session_Presenter__c gsp : guestPresenters)
            lstAllPresentersToInsert.add(gsp);
            }
        if(TopicPresenters.size()>0)
            {
            for(EBC_Session_Presenter__c tsp : TopicPresenters)
            lstAllPresentersToInsert.add(tsp);
            }
        
        //collecting sessions, topic presenter ids from above list
        for(EBC_Session_Presenter__c for_sp: lstAllPresentersToInsert)
        {
        setBriefingSessionIds.add(for_sp.Session__c);
        setTopicPresenterIds.add(for_sp.Topic_Presenters__c);
        }
        
        //Querying for topic presenters and sessions, and mapping them
        mapSessions = new map<Id,EBC_Session__c>([Select Id, Briefing_Event__c, Topic__c from EBC_Session__c where Id IN :setBriefingSessionIds]);
        mapTopicPresenters = new map<Id,EBC_Topic_Presenters__c>([Select Id, Active__c, Presenter__c, Presenter__r.FirstName, Presenter__r.LastName, Presenter__r.Email, Presenter__r.Account.Name, Presenter__r.RecordTypeId, EBC_Name__c, EBC_Title__c, Topic__c from EBC_Topic_Presenters__c where Id IN :setTopicPresenterIds]);
        
        //Collecing the briefing event ids from sessions above
        for(EBC_Session__c sess : mapSessions.values())
        setBriefingEventIds.add(sess.Briefing_Event__c);
        
        //Creating a map of  email ids vs presenters
        for(EBC_Session_Presenter__c sessptr: lstAllPresentersToInsert)
        {
            if(sessptr.Guest_Presenter_Email__c!=Null && sessptr.Guest_Presenter_Email__c!='')
            mapEmailToPresenters.put(sessptr.Guest_Presenter_Email__c, sessptr);
            else if(sessptr.Topic_Presenters__c!=Null)
            mapEmailToPresenters.put(mapTopicPresenters.get(sessptr.Topic_Presenters__c).Presenter__r.Email, sessptr);
        }
        
        //Querying existing invitees from the emails above
        setEmailIdsOfPresenters = mapEmailToPresenters.keyset();
        lstInviteesFromPresenters = [Select id,Attendee_Email__c,Contact__c from EBC_Invitees__c 
                                                    where Briefing_Event__c IN :setBriefingEventIds AND Attendee_Email__c IN :setEmailIdsOfPresenters AND
                                                    (Briefing_Team_Role__c='Presenter (Non EMC Employee)' OR Briefing_Team_Role__c= 'Presenter (EMC Employee)')];
        
        //If the above list has records, that implies that invitees already exist for those presenters, hence there is no need to create new ones
        // note that the email is the criteria, hence contacts having blank email ids will cause unforeseen behaviour

        if(lstInviteesFromPresenters.size()>0)
        {   
            // Removing the presenters from 'mapEmailToPresenters', those that does not need invitee records 
            for(EBC_Invitees__c inv : lstInviteesFromPresenters)
                mapEmailToPresenters.remove(inv.Attendee_Email__c);
        }
        // The map 'mapEmailToPresenters' would contain all the presenters for which the invitee records needs to be created
        for(EBC_Session_Presenter__c sp: mapEmailToPresenters.values())
            {
            Set<EBC_Session_Presenter__c> tempSessP = new Set<EBC_Session_Presenter__c>();
            boolean gFlag = false;
            boolean tFlag = false;
            for(EBC_Session_Presenter__c gsp: guestPresenters)
            { if(sp==gsp){gFlag = true;}}
            for(EBC_Session_Presenter__c tsp: topicPresenters)
            { if(sp==tsp){tFlag = true;}}
                EBC_Invitees__c bInvitee = createTheInvitee(sp, gFlag, tFlag, mapTopicPresenters.get(sp.Topic_Presenters__c), mapSessions.get(sp.Session__c).Briefing_Event__c);
            inviteeInsertList.add(bInvitee);
        }
        // inserting thru db command, so to enable other invitees to be created
        Database.saveResult[] result= Database.Insert(inviteeInsertList, false);
    }
    
    //Method to delete invitees
    public void deleteInvitees(List<EBC_Session_Presenter__c> guestPresenters, List<EBC_Session_Presenter__c> TopicPresenters){
        //declaring local variables
        Set<Id> setBriefingEventIds = new Set<Id>();
        Set<Id> setBriefingSessionIds = new Set<Id>();
        Set<Id> setTopicPresenterIds = new Set<Id>();
        List<EBC_Session_Presenter__c> lstAllPresentersToDelete = new List<EBC_Session_Presenter__c>();
        map<Id,EBC_Session__c> mapSessions = new map<Id,EBC_Session__c>();
        map<Id,EBC_Topic_Presenters__c> mapTopicPresenters = new map<Id,EBC_Topic_Presenters__c>();
        Set<String>setEmailIdsOfPresenters = new Set<String>();
        Map<string, EBC_Session_Presenter__c> mapEmailToPresenters = new Map<string, EBC_Session_Presenter__c>();
        List<EBC_Invitees__c> lstInviteesFromPresenters = new List<EBC_Invitees__c>();
        //end of variable declaration
        
        //adding presenters for which invitees needs to be deleted in a common list
        if(guestPresenters.size()>0)
            {
            for(EBC_Session_Presenter__c gsp : guestPresenters)
            lstAllPresentersToDelete.add(gsp);
            }
        if(TopicPresenters.size()>0)
            {
            for(EBC_Session_Presenter__c tsp : TopicPresenters)
            lstAllPresentersToDelete.add(tsp);
            }
        
        //collecting sessions, topic presenter ids from above list
        for(EBC_Session_Presenter__c for_sp: lstAllPresentersToDelete)
        {
        setBriefingSessionIds.add(for_sp.Session__c);
        setTopicPresenterIds.add(for_sp.Topic_Presenters__c);
        }
        //Querying for topic presenters and sessions, and mapping them
        mapSessions = new map<Id,EBC_Session__c>([Select Id, Briefing_Event__c, Topic__c from EBC_Session__c where Id IN :setBriefingSessionIds]);
        mapTopicPresenters = new map<Id,EBC_Topic_Presenters__c>([Select Id, Active__c, Presenter__c, Presenter__r.FirstName, Presenter__r.LastName, Presenter__r.Email, Presenter__r.Account.Name, Presenter__r.RecordTypeId, EBC_Name__c, EBC_Title__c, Topic__c from EBC_Topic_Presenters__c where Id IN :setTopicPresenterIds]);
        
        //Collecing the briefing event ids from sessions above
        for(EBC_Session__c sess : mapSessions.values())
        setBriefingEventIds.add(sess.Briefing_Event__c);
        
        //Creating a map of  email ids vs presenters
        for(EBC_Session_Presenter__c sp: lstAllPresentersToDelete)
        {
            if(sp.Guest_Presenter_Email__c!=Null && sp.Guest_Presenter_Email__c!='')
            mapEmailToPresenters.put(sp.Guest_Presenter_Email__c, sp);
            else if(sp.Topic_Presenters__c!=Null)
            mapEmailToPresenters.put(mapTopicPresenters.get(sp.Topic_Presenters__c).Presenter__r.Email, sp);
        }
        
        //Querying existing invitees from the emails above, using the set of briefing event ids
        setEmailIdsOfPresenters = mapEmailToPresenters.keyset();
        lstInviteesFromPresenters = [Select id,Attendee_Email__c,Contact__c from EBC_Invitees__c 
                                                    where Briefing_Event__c IN :setBriefingEventIds AND Attendee_Email__c IN :setEmailIdsOfPresenters AND
                                                    (Briefing_Team_Role__c='Presenter (Non EMC Employee)' OR Briefing_Team_Role__c= 'Presenter (EMC Employee)')];
        //Deleting Invitees already present
        Delete lstInviteesFromPresenters;  
    }
    
    //Method to put values to an invitee and return
    EBC_Invitees__c createTheInvitee(EBC_Session_Presenter__c eSP, boolean isGuestP, boolean isTopicP, EBC_Topic_Presenters__c tP, Id briefingId){
        if(eSP.Guest_Presenter_Email__c !=null && eSP.Guest_Presenter_Last_Name__c != null && isGuestP==true)
        {
         EBC_Invitees__c invitee = new EBC_Invitees__c (
                                                       Briefing_Team_Role__c = 'Presenter (Non EMC Employee)',
                                                       Last_Name__c = eSP.Guest_Presenter_Last_Name__c,
                                                       First_Name__c = eSP.Guest_Presenter_First_Name__c,
                                                       Attendee_Email__c = eSP.Guest_Presenter_Email__c,
                                                       EBC_Title__c = eSP.Guest_Presenter_EBC_Title__c,
                                                       EBC_Name__c = eSP.Presenter_Name__c,
                                                       Company__c = eSP.Guest_Company__c,
                                                       From_Object__c = 'Session Presenter',
                                                       Briefing_Event__c = briefingId);
         return invitee;
         }
         else if(eSP.Topic_Presenters__c!=null && isTopicP==true)
         {
         EBC_Invitees__c invitee = new EBC_Invitees__c (
                                                        Last_Name__c=tP.presenter__r.LastName,
                                                        First_Name__c=tP.presenter__r.FirstName,
                                                        Attendee_Email__c=tP.presenter__r.Email,
                                                        Contact__c=tP.presenter__c,
                                                        EBC_Title__c=tP.EBC_Title__c,
                                                        EBC_Name__c=tP.EBC_Name__c,
                                                        From_Object__c='Session Presenter',
                                                        Briefing_Event__c=briefingId);
         
         if(tP.presenter__r.RecordTypeId == ContactRecTypeId)
         {
               invitee.Briefing_Team_Role__c='Presenter (EMC Employee)';
               invitee.Send_FBP__c=true;
               invitee.Feedback_Output__c=true;
               invitee.Company__c='EMC Corporation';
         }
         else
         {                                         
              invitee.Briefing_Team_Role__c='Presenter (Non EMC Employee)';
              invitee.Feedback_Output__c=false;
              invitee.Company__c=tP.presenter__r.Account.Name;       
         }
         return invitee;
        }
        else return null;
        }
}