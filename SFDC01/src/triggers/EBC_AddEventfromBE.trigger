/*
*  Created By       :- Vijo Joy
*  Created Date     :- 12/12/2012
*  Description      :- This trigger is used to add a calender event in the public calendar
                        upon briefing advisor changing the status of Briefing event from requested to pending

******Modification history***********
    Modified By: Vijo Joy
    Modified On: 19th Feb, 2013
    Description: Added the ability to add invitees, and other code improvements
    WR/eRFC: WR 226913


*/

trigger EBC_AddEventfromBE on EBC_Briefing_Event__c (before Update) {

    // Initialising the utility method to get record type id maps for objects
    GenUtilMethods gUM = new GenUtilMethods();
    
    // declaring environment variables
    Event Evnt = new Event();
    List<EBC_Briefing_Event__c> BE = new list<EBC_Briefing_Event__c>();// to capture all the qualified briefing events (events with 'requested' briefing status)
    List<Event> EventsForCalendar = new list<Event>();// to hold all the events to be inserted
    Map<String,String> mapCalendars = new Map<String,String>(); //map between calendar name and calendar id
    Map<String, String> mapBlocations = new Map<String,String>(); //map between location name and location id.
    Map<String, String> mapCalvsLocation = new Map<String,String>(); //map to create a relation between a calendar and location

    //get the record type id for 'Requested Briefing Event' for the EBC_Briefing_Event object
    Id briefingRecordTypeId = gUM.getRecordTypesMap('EBC_Briefing_Event__c').get('Requested Briefing Event');
    // get the record type id for 'Briefing Event' for Event object
    Id eventRecordTypeId = gUM.getRecordTypesMap('Event').get('Briefing Event');

    //Creating a map between calendar Id and briefing center Id
    List<Calendars__c> AllCalendars= Calendars__c.getAll().Values();
    List<EBC_Briefing_Center__c> AllBriefingLoc = new List<EBC_Briefing_Center__c>([Select id, Name from EBC_Briefing_Center__c]); 
    
        for(Calendars__c Cals: AllCalendars)
        mapCalendars.put(Cals.Name, Cals.Calendar_ID__c);
    
        for(EBC_Briefing_Center__c BC: AllBriefingLoc)
        mapBlocations.put(BC.Name, BC.id);

        for(String Cal_Name : mapCalendars.keySet())
        mapCalvsLocation.put(mapBlocations.get(Cal_Name),mapCalendars.get(Cal_Name));//the cal VS center map 
     
        for(EBC_Briefing_Event__c BEvent : trigger.new)
        {
        if(trigger.isBefore && trigger.newMap.get(BEvent.id).Briefing_Status__c=='pending' && trigger.oldMap.get(BEvent.id).Briefing_Status__c=='Requested' && BEvent.RecordTypeId==briefingRecordTypeId && BEvent.Standard_Event_Id__c==NULL)
        BE.add(BEvent);//collecting only those events that has the relevant status change
        }
    
    //iterating and creating a list of events to be inserted
    if(BE.size()>0)
    {
    for(EBC_Briefing_Event__c BEvent :BE)
        {
        Evnt = new Event();
        Evnt.RecordTypeId = eventRecordTypeId;
        Evnt.WhatId = BEvent.id;
        Evnt.Subject = BEvent.Name;
        Evnt.StartDateTime = DateTime.newInstance(BEvent.Start_Date__c.year(),BEvent.Start_Date__c.month(),BEvent.Start_Date__c.day(),(Datetime.now().hour()+1),0,0);
        Evnt.EndDateTime = DateTime.newInstance(BEvent.End_Date__c.year(),BEvent.End_Date__c.month(),BEvent.End_Date__c.day(),(Datetime.now().hour()+2),0,0);
        Evnt.OwnerId = mapCalvsLocation.get(BEvent.Briefing_Center__c);
        Evnt.Projected_Number_of_Attendees__c = BEvent.Projected_of_Attendees__c;
        Evnt.Briefing_Event__c = true;
        Evnt.IsFromSalesRep__c = true;
        Evnt.IsReminderSet = true;
        EventsForCalendar.add(Evnt);
        }
     }
     else 
     {Return;}// if no records are found that satisfies the change of status condition, then this trigger is skipped
     
     //Inserting the events to the database
     Database.SaveResult[] insSaveResult = Database.insert(EventsForCalendar,false);// inserting the events into DB  
     
     //posting errors to records for which the record was not inserted
     for(Integer i = 0; i<insSaveResult.size();i++)
         {
         if(!insSaveResult[i].isSuccess())
         Trigger.newMap.get(EventsForCalendar[i].WhatId).addError('An event on the calendar is not created for this briefing event. Please contact your system administrator.');
         else
             {
             try
                 {
                 //The event has been inserted successfully, hence associating the standard event to the briefing event
                     trigger.newMap.get(EventsForCalendar[i].WhatId).Standard_Event_Id__c = EventsForCalendar[i].id;
                 //setting the requestor name field. 
                     EBC_addEventAttendee eAttend = new EBC_addEventAttendee();
                     //Here the getTheRequestor method called would return a string among the following: Error 1, Error 2 or the contact id. Error/requestor assigning is done as per the returned string
                     String errorOrId = eAttend.getTheRequestor(trigger.oldMap.get(EventsForCalendar[i].WhatId).CreatedById);
                     if(errorOrId == 'Error 1')
                     Trigger.newMap.get(EventsForCalendar[i].WhatId).addError('The sales User does not have an Internal EMC contact record. Please contact your system administrator.');
                     else if(errorOrId == 'Error 2')
                     Trigger.newMap.get(EventsForCalendar[i].WhatId).addError('The sales user contact is not a valid EMC Internal contact. Please contact your system administrator.');
                     else
                     trigger.newMap.get(EventsForCalendar[i].WhatId).Requestor_Name__c = eAttend.getTheRequestor(trigger.oldMap.get(EventsForCalendar[i].WhatId).CreatedById);
                  // adding attendees to the Event.
                     //adding the requestor as an invitee and attendee
                         if(trigger.newMap.get(EventsForCalendar[i].WhatId).Requestor_Name__c!= Null)
                         {
                         eAttend.createEventAttendee(EventsForCalendar[i].id, trigger.newMap.get(EventsForCalendar[i].WhatId).Requestor_Name__c);
                         EBC_addEventAttendee.toCreateRequestorinvitee(trigger.newMap.get(EventsForCalendar[i].WhatId).Requestor_Name__c,EventsForCalendar[i].WhatId);
                         }
                     //adding the scheduler invitee. Here the whatId would be the briefing Event Id
                     EBC_addCustomInvitees cusInvitees = new EBC_addCustomInvitees();
                     cusInvitees.createSchedulerInvitee(EventsForCalendar[i].WhatId, UserInfo.getUserId());
                  
                  }
               catch(Exception e)
                  {
                  trigger.newMap.get(EventsForCalendar[i].WhatId).addError('Briefing event cannot be saved. The following error occured: '+e);
                  }
             }
         }
}