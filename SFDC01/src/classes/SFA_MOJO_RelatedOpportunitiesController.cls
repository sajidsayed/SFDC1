/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  23 Oct 2012     Avinash K       MOJO        Initial Creation.Created this controller to fetch the linked Opportunity List
 												that would be shown on the Asset's detail page
+========================================================================================================================*/


public with sharing class SFA_MOJO_RelatedOpportunitiesController
{
    public List<Opportunity> lstRelatedOpportunities {get;set;} {lstRelatedOpportunities = new List<Opportunity>();}
    public List<Opportunity_Asset_Junction__c> lstOppAssetJunction = new List<Opportunity_Asset_Junction__c>();

    public Set<Id> setOppIds = new Set<Id>();

    public PageManager objPageManager {get;set;}
    
    public String strAssetId {get;set;}

    public SFA_MOJO_RelatedOpportunitiesController(ApexPages.StandardController controller) 
    {
        
        objPageManager = new PageManager(5);
        if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '')
    	{
    		strAssetId = ApexPages.currentPage().getParameters().get('id');

    		lstOppAssetJunction = [Select id, Related_Asset__c, Related_Opportunity__c 
    			From Opportunity_Asset_Junction__c
    			Where Related_Asset__c = :strAssetId
    			ORDER BY Isactive__c DESC
    			Limit 50000];

    		for (Opportunity_Asset_Junction__c oaj : lstOppAssetJunction) 
    		{
    			setOppIds.add(oaj.Related_Opportunity__c);
    		}

	        lstRelatedOpportunities= [Select id, name, Opportunity_Number__c, StageName, SO_Number__c, Account.Party_ID__c 
	        	From Opportunity
	        	Where Id in :setOppIds
	        	Limit 500];
	        
	        objPageManager.numberOfRows = lstRelatedOpportunities.size();
	    }
    }

    public List<Opportunity> getOppsDetails()
    {
        List<Opportunity> data = new List<Opportunity>();
        for(integer i=objPageManager.startIndex;i<objPageManager.endIndex&&i<lstRelatedOpportunities.size();i++)
        {
            data.add(lstRelatedOpportunities.get(i));
        }
        return data;
    }
}