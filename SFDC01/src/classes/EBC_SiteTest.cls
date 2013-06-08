/*
Author:     Devi Prasad Bal
Created on: 06-June-2010
Description: This class acts as an extension to the controller for the visualforce pages --Site_test.

Modified by: 
Modified on: 
Reason: 
*/ 


public class EBC_SiteTest
{
    public Id briefingEventId; // to hold the id of the briefing event
    public EBC_Briefing_Event__c objBEvent {get;set;} // to hold the briefing event object record
    
    public EBC_SiteTest(){
        
            briefingEventId= System.currentPageReference().getParameters().get('mid'); // id of the parent Briefing Event Object
            //String mID = 'a0kS00000005obK';
            objBEvent=[Select Id,Name  From EBC_Briefing_Event__c where Id=:briefingEventId];
            //objBEvent=[Select Id,Name  From EBC_Briefing_Event__c where Id=:mID];

    }
}