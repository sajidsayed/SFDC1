/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER             WR               DESCRIPTION                               
 |  ====       =========             ==               =========== 
 |  07-July-11 Srinivas Nallapati    178926            Prevention of Duplicate Products on Opportunity  
 |
 |                          
 +===========================================================================*/
trigger OpportunityLineItem_PreventDuplicates on OpportunityLineItem (before insert) {
    
    List<OpportunityLineItem> lstOli = trigger.new;
    map<id,list<OpportunityLineItem>> mapOppIdtoLines = new map<id,list<OpportunityLineItem>>();
    for(OpportunityLineItem Oline : lstOli)
    {
    	if(mapOppIdtoLines.containsKey(Oline.OpportunityId))
    	   mapOppIdtoLines.get(Oline.OpportunityId).add(Oline);
    	else{
    		mapOppIdtoLines.put(Oline.OpportunityId, new OpportunityLineItem[] {Oline});
    	}
    }
    //Duplicate check in the Batch
    for(id Opptyid : mapOppIdtoLines.keySet())
    {
    	set<id> setProductids = new set<id>();
    	for(OpportunityLineItem Oline : mapOppIdtoLines.get(Opptyid))
    	{
    		if(setProductids.contains(Oline.PricebookEntryId))
    		  Oline.addError(System.label.DuplicateProductInBatchError);
    		else
    		    setProductids.add(Oline.PricebookEntryId);
    	}
    }
    
    //
    list<OpportunityLineItem> lstExistingProducts = new list<OpportunityLineItem>();
    lstExistingProducts = [Select PricebookEntryID, PricebookEntry.Product2Id, PricebookEntry.IsActive, UnitPrice, TotalPrice, SystemModstamp, SortOrder, ServiceDate, Quote_Amount__c, Quantity, Product_Type__c, Product_Type_Sales__c, Product_Type_Rollup__c, Product_Family__c, Product_Dependency__c, OpportunityId, ListPrice, LastModifiedDate, LastModifiedById, IsDeleted, Id, Forecast_Updated__c, Forecast_Summary_Type__c, Forecast_Summary_Type_For_Rollup__c, Description, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId, ConnectionReceivedId, Bypass_Opportunity_Line_item_Validations__c, Business_Unit__c From OpportunityLineItem where OpportunityId in :mapOppIdtoLines.keySet()]; 
    map<id,set<id>> mapOppIdtoExistingProducts = new map<id,set<id>>();
    
    for(OpportunityLineItem Oline : lstExistingProducts)
    {
    	if(mapOppIdtoExistingProducts.containsKey(Oline.OpportunityId))
           mapOppIdtoExistingProducts.get(Oline.OpportunityId).add(Oline.PricebookEntryID);
        else{
            set<id> idset = new set<id>();
            idset.add(Oline.PricebookEntryID);
            mapOppIdtoExistingProducts.put(Oline.OpportunityId, idset);
        }
    }
    
    
    for(id Opptyid : mapOppIdtoLines.keySet())
    {
        
        for(OpportunityLineItem Oline : mapOppIdtoLines.get(Opptyid))
        {
            if(mapOppIdtoExistingProducts.get(Opptyid) != null)
	            if(mapOppIdtoExistingProducts.get(Opptyid).contains(Oline.PricebookEntryId))
	              Oline.addError(System.label.DuplicateProductError);
        }
    }
    
}//End of trigger