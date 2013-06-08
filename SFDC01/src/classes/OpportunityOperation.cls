/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE              DEVELOPER        WR             DESCRIPTION                               
 |  ====              =========        ==             =========== 
 |  5 March 2010         Arif       Adhoc Req         'Replace Comments_Details__c field with Next_Steps__c'  
    28 April 2010        Arif          659            Added UnitPrice(Forecast Amount)in checkopportunityLineItemUpdates method in if condition.                                         
 | 17 Dec 2010		Shipra Misra	153590			 Updated Code to resolve Opportunity Inline editing tool not triggering Integration properly. Added Missing Fields.                    
 | 13 Jan 2011		Shipra Misra    153590			 Pulling Back the code updated on 17 dec.As per mail from Mike no extra fields are required to be added.                            
 +===========================================================================*/

global class OpportunityOperation
{
	webservice Static List<IntegrationResult> synchronizeOpportunity(List<OpportunityDetails> OppDetails,String event)
	{
		List<IntegrationResult> resultlist=new List<IntegrationResult>();
		if(event=='Create')
		{ 
		    resultlist= new OpportunityIntegrationOperation().createOpportunities(OppDetails);
		}
		else if(event=='Update')
		{
		    resultlist= new OpportunityIntegrationOperation().updateOpportunities(OppDetails);
		}
		else if(event=='Submit To Order')
		{   
		    resultlist= new OpportunityIntegrationOperation().updateOpportunities(OppDetails);
		}
		else if(event=='Udpate Create Opportunity Status')
		{   
		    resultlist.add(new OpportunityIntegrationOperation().udpateCreateOpportunityStatus(OppDetails[0]));
		}
		else if(event=='Udpate Create Quote Status')
		{   
		    resultlist.add(new OpportunityIntegrationOperation().udpateCreateQuoteStatus(OppDetails[0]));
		}
		else
		{
		    IntegrationResult result=new IntegrationResult();
		    result.ErrorMessage='Invalid Event';
		    result.IsSuccess=false;
		    result.SynergyOpportunityId='';
		    result.SFDCOpportunityId='';
		    resultlist.add(result);
		}
		return resultlist;
	}  

	webservice Static OpportunityDetails getSFDCOpportunity( String sfdcOppId)
	{
	    return new OpportunityDetails(sfdcOppId);
	}

    //Section included by Ashwini Gowda For Update Log Functionality
    // Included For Opportunity Update Log Functionality
    
    //This method receives a map of Old and new Opportunity Ids 
    //Method is used to check for any field update on Opportunity.
    //If there is any change in field values then insert a record for Opportunity_Integration_Log__c Object
    //with OpportunityId and Status set as Open 
    
    public void checkOpportunityUpdates(Map<Id,Opportunity> NewOpptyMap,Map<Id,Opportunity> OldOpptyMap)
    {
        //Added this to prevent Opportunity Update Logs getting created for System Adminstrator - API Only Profile users
        id UserProfileID = UserInfo.getProfileId();
        id SystemAdminAPIOnyProfileID = Profiles__c.getInstance().System_Admin_API_Only__c;
        if(UserProfileID == SystemAdminAPIOnyProfileID)
            return; //Not inserting Opportunity Update Logs when user profile is System Adminstrator - API Only
        //End of change
        
        List<Opportunity_Integration_Log__c> OpptyLog = new List<Opportunity_Integration_Log__c>();
        Set<Id> OpportunityIds = NewOpptyMap.keyset();
        System.debug('OpportunityIds--->'+OpportunityIds);
        for(Id opportunityId:OpportunityIds)
        {        
            Opportunity OldOpptyRecord=OldOpptyMap.get(opportunityId);
            Opportunity NewOpptyRecord=NewOpptyMap.get(opportunityId);
            if(NewOpptyRecord.Name!=OldOpptyRecord.Name||
            NewOpptyRecord.Sales_Force__c!= OldOpptyRecord.Sales_Force__c||
            NewOpptyRecord.Opportunity_Number__c!= OldOpptyRecord.Opportunity_Number__c||
            NewOpptyRecord.Owner!= OldOpptyRecord.Owner||
            NewOpptyRecord.Sales_Channel__c!= OldOpptyRecord.Sales_Channel__c||
            NewOpptyRecord.Vmware_Related__c!= OldOpptyRecord.Vmware_Related__c||
            NewOpptyRecord.Partner__c!= OldOpptyRecord.Partner__c||
            NewOpptyRecord.AccountId!= OldOpptyRecord.AccountId||
            NewOpptyRecord.CurrencyIsoCode!= OldOpptyRecord.CurrencyIsoCode||
            NewOpptyRecord.Originator__c!= OldOpptyRecord.Originator__c||
            NewOpptyRecord.LeadSource!= OldOpptyRecord.LeadSource||
            NewOpptyRecord.StageName!= OldOpptyRecord.StageName||
            NewOpptyRecord.CloseDate!= OldOpptyRecord.CloseDate||
            NewOpptyRecord.Closed_Reason__c!= OldOpptyRecord.Closed_Reason__c||
            NewOpptyRecord.Close_Comments__c!= OldOpptyRecord.Close_Comments__c||
            NewOpptyRecord.Disposition_Code__c!= OldOpptyRecord.Disposition_Code__c||
            NewOpptyRecord.Next_Steps__c!= OldOpptyRecord.Next_Steps__c||
            NewOpptyRecord.SO_Number__c!= OldOpptyRecord.SO_Number__c||
            NewOpptyRecord.Approval_Date__c!= OldOpptyRecord.Approval_Date__c||
            NewOpptyRecord.Expiration_Date__c!= OldOpptyRecord.Expiration_Date__c||
            NewOpptyRecord.Quote_Type__c!= OldOpptyRecord.Quote_Type__c||
            NewOpptyRecord.Quote_Cart_Number__c!= OldOpptyRecord.Quote_Cart_Number__c||
            NewOpptyRecord.Quote_Version__c!= OldOpptyRecord.Quote_Version__c||
            NewOpptyRecord.Quote_Operating_Unit__c!= OldOpptyRecord.Quote_Operating_Unit__c||
            NewOpptyRecord.Sell_Relationship__c!= OldOpptyRecord.Sell_Relationship__c
           	)
           	{
            	OpptyLog.add(createOpportunityLog(NewOpptyRecord.id));
            }
        }
        System.debug('Size is:--->'+OpptyLog.size());
        System.debug('OpptyLog--->'+OpptyLog);
        if(OpptyLog.size()>0)
        {
            insert OpptyLog;
        }
    }

    //This method receives a map of Old and new OpportunityLineItem Ids 
    //Method is used to check for any field update on OpportunityLineItem .
    //If there is any change in field values then insert a record for Opportunity_Integration_Log__c Object
    //with OpportunityId and Status set as Open 
    
    public void checkOpportunityLineItemUpdates(Map<Id,OpportunityLineItem> NewOpptyLineItemMap,Map<Id,OpportunityLineItem> OldOpptyLineItemMap)
    {
        //Added this to prevent Opportunity Update Logs getting created for System Adminstrator - API Only Profile users
        id UserProfileID = UserInfo.getProfileId();
        id SystemAdminAPIOnyProfileID = Profiles__c.getInstance().System_Admin_API_Only__c;
        if(UserProfileID == SystemAdminAPIOnyProfileID)
            return; //Not inserting Opportunity Update Logs when user profile is System Adminstrator - API Only
        //End of change
        
        List<Opportunity_Integration_Log__c> OpptyLog = new List<Opportunity_Integration_Log__c>();        
        Set<Id> OpportunityLineItemIds = NewOpptyLineItemMap.keyset();
        for(Id OpportunityLineItemId:OpportunityLineItemIds)
        {
            OpportunityLineItem OldOpptyLineItem = OldOpptyLineItemMap.get(OpportunityLineItemId);
            OpportunityLineItem NewOpptyLineItem = NewOpptyLineItemMap.get(OpportunityLineItemId);
            if(NewOpptyLineItem.PricebookEntry.Product2Id!= OldOpptyLineItem.PricebookEntry.Product2Id||
            NewOpptyLineItem.Quote_Amount__c!= OldOpptyLineItem.Quote_Amount__c || 
            NewOpptyLineItem.UnitPrice!= OldOpptyLineItem.UnitPrice)
            {
                OpptyLog.add(createOpportunityLog(newOpptyLineItem.OpportunityId));
            }    
        }
        if(OpptyLog.size()>0)
        {
            insert OpptyLog;
        }        
    }
    
    //Method is used to check for any field update on OpportunitySplit .
    //If there is any change in field values then insert a record for Opportunity_Integration_Log__c Object
    //with OpportunityId and Status set as Open 
    
   /** public void checkOpportunitySplitUpdates(OpportunitySplit NewOpptySalesTeamMap,OpportunitySplit OldOpptySalesTeamMap)
    {    
        List<Opportunity_Integration_Log__c> OpptyLog = new List<Opportunity_Integration_Log__c>();    
        OpportunitySplit NewOpptySalesTeam;
        if(
            NewOpptySalesTeamMap.SplitPercentage!= OldOpptySalesTeamMap.SplitPercentage||
            NewOpptySalesTeamMap.SplitOwnerId!= OldOpptySalesTeamMap.SplitOwnerId)
            {
               OpptyLog.add(createOpportunityLog(NewOpptySalesTeam.OpportunityId));
            }
            if(OpptyLog.size()>0){
                insert OpptyLog;
            }
    } */   
    
    //Method is used to insert a record for Opportunity_Integration_Log__c Object
    //with OpportunityId and Status set as Open
    
    public Opportunity_Integration_Log__c createOpportunityLog(String UpdatedOppId)
    {
        Opportunity_Integration_Log__c OpptyIntgLog = new Opportunity_Integration_Log__c();
        OpptyIntgLog.Status__c='Open';
        OpptyIntgLog.Opportunity_ID__c = UpdatedOppId;
        return OpptyIntgLog ;        
    }  
    
    //This method is used to directly insert a record on Opportunity_Integration_Log__c Object with OpportunityIds
    
    public void insertOpportunityIntgLog(List<String> OpportunityIds)
    {
        //Added this to prevent Opportunity Update Logs getting created for System Adminstrator - API Only Profile users
        id UserProfileID = UserInfo.getProfileId();
        id SystemAdminAPIOnyProfileID = Profiles__c.getInstance().System_Admin_API_Only__c;
        if(UserProfileID == SystemAdminAPIOnyProfileID)
            return; //Not inserting Opportunity Update Logs when user profile is System Adminstrator - API Only
        //End of change
        
        try
        {
	        List<Opportunity_Integration_Log__c> OpptyLog = new List<Opportunity_Integration_Log__c>();
	        for(String OpptyId:OpportunityIds)
	        {
	            OpptyLog.add(createOpportunityLog(OpptyId));    
	        }
	        system.debug(' OpptyLog  '+ OpptyLog);
	        if(OpptyLog.size()>0)
	        {
	            insert OpptyLog;
	        }
	        system.debug(' OpptyLog; '+ OpptyLog);
        }
        catch(Exception e)
        {
            System.debug('Exception while creating log '+e);
        }
    }
    
    //End of Section included For Update Log Functionality

}