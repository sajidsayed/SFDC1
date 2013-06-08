/*
*  Created By       :- Sunil Arora
*  Created Date     :- 13/04/2010
*  Last Modified By :- Sunil Arora
*  Description      :- This class will be called from EC_Impact_Page and used to show/save Impact record.

Modified by	: 	Avinash Kaltari
Modified on	: 	12-Jun-2012
Reason		: 	To eliminate hardcoding of IDs for System Administrator and EBC Power User profiles


*/
public class EBC_Impact
{
	public Id briefingEventId; // to hold the id of the briefing event
	public EBC_Briefing_Event__c objBEvent {get;set;} // to hold the briefing event object record
    public Boolean NotFromSite {get;set;}
    public Boolean ImpactSubmitted {get;set;}
	public EBC_Impact(ApexPages.StandardController stdController)
	{        
        try
        {
            briefingEventId= System.currentPageReference().getParameters().get('id'); // id of the parent Briefing Event Object
            objBEvent = [Select id, Name, Start_Date__c, End_Date__c from EBC_Briefing_Event__c where id =:briefingEventId];
        }
        catch(StringException strEx)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , system.label.Valid_BE_id ));
            return;
        }
        
        if(briefingEventId != null) 
        {
            // retrieve the Feedback fields from the Briefing Event and store it in objBEvent
            objBEvent=[Select  Id,Name,Start_Date__c,End_Date__c,Did_the_opportunity_Close__c,Was_EMC_Jet_Used_to_Transport_Customer__c,Actual__c,
                               Comments_status_of_opportunity_if_no__c,Comments_briefing_impact_the_sale_acco__c,Status_of_Opportunity__c,
                               How_did_the_briefing_impact_the_sale_acc__c,Impact_Status_Picklist__c       
                        From EBC_Briefing_Event__c where Id=:briefingEventId];
 
            ImpactSubmitted = false;
            NotFromSite = true;
            Profile p = [Select Id, Name from Profile where Id =: UserInfo.getProfileId()];
            
            if(p.Name == 'EBC Application Site Profile')
            {
                NotFromSite=false;  
            }
            //EBC Power User Profile Id=00e70000001FbAv and System Administrator Profile Id=00e70000000wBza
            
//Avinash's code begins...
            
            Id SystemAdministratorId, EBCPowerUserId ;
			List<Profile> lstid = [SELECT Name, Id FROM Profile where name in (:System.Label.System_Administrator_Profile_Name ,:System.Label.EBC_Power_User_Profile_Name)  limit 2];
			for(Profile prof : lstid)
			{
				if(prof.name == 'System Administrator')
					SystemAdministratorId = prof.id;
				if(prof.name == 'EBC Power User')
					EBCPowerUserId = prof.id;
			}
            
//Avinash's code ends.
            
            
            if(objBEvent.Impact_Status_Picklist__c == 'Submitted' && !(p.Id == EBCPowerUserId || p.Id == SystemAdministratorId))
            {
                ImpactSubmitted = true;   
            }
                      
        }
    }

        // this method updates the briefing event record, sessions related to the briefing event and the session presenters related to the briefing event  
    public PageReference saveRecord()
    {   
        try
        {
        	objBEvent.Impact_Status_Picklist__c = 'Submitted';
        	update objBEvent;
	        //update sessionPresentersList; // updates the session presenters related to the briefing event with the Rating and Notes fields
	        if(NotFromSite == true)
	        {
	            return backToBriefingEvent();
	        }
	        else
	        {
	            ImpactSubmitted = true;  
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO , 'Impact submitted successfully'));
	            return null;     
	        }
        }
        catch(Exception e)
        {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , system.label.EBC_Impact_Exception+' Error: '+e.getMessage()));
        	return null;
        }
        
        
         
    }
    
        // method to go back to the briefing event detail page
    public PageReference backToBriefingEvent()
    { 
        PageReference pageRef = new PageReference('/' + briefingEventId);
        pageRef.setRedirect(true);
        return pageRef;
    }  
}