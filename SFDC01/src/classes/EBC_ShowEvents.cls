/*
Author:     Sunil Arora
Created on: 29-Dec-2009
Description: This class acts as extension controller to the page which displays the standard event related to the Briefing Event
Modified by: Devi Prasad Bal
Modified on: 05-April-2010
Reason: Modified based on further inputs from the business
Where his controller is used: in visual force page "EBC_ShowEvents.page"
*/


public class EBC_ShowEvents
{  
    String briefingEvId;
    public String errMsg{get; set;}
    public Event[] showevent {get; set;} // to hold the events associated with the Briefing Event. 
    
    public EBC_ShowEvents(ApexPages.StandardController stdController)
    {
        briefingEvId = ApexPages.currentPage().getParameters().get('Id');
    }
  
    public List<Event> getEvents()
    {
        errMsg='';
        showevent = [Select Id,Subject,ActivityDate, ActivityDateTime,What.Name,Type,OwnerId,Location,WhatId from Event where WhatId=:briefingEvId ];
        List<Event> showEvent2=new List<Event>(); 
        
        //Loop to add events, where the owner of the event is a public calendar, to the list showEvent2 
        for(Integer i=0;i<showevent.size();i++)
        {
            String ownId = showevent[i].OwnerId;
            if(ownId.subString(0,3)=='023') // owner id of a public calendar
            {
                showEvent2.add(new Event(Subject=showevent[i].Subject,Id=showevent[i].Id, ActivityDate=showevent[i].ActivityDate, ActivityDateTime=showevent[i].ActivityDateTime,WhatId=showevent[i].WhatId,Type=showevent[i].Type,OwnerId=showevent[i].OwnerId,Location=showevent[i].Location));
            }
        }
        
        // Display error message if now records associated with the Briefing Event is found
        if(showevent.size()<=0)
        {
            errMsg='No records found.';
        }
        return showevent2;
    } 
}