trigger OpportunityLineItem_UpdateLog on OpportunityLineItem (After Update,After Insert,After Delete) {
    OpportunityOperation OpptyOperation = new OpportunityOperation();
    //Profiles__c profile = Profiles__c.getInstance();
    List<OpportunityIntegration__c> houseAcct = OpportunityIntegration__c.getall().Values();
        System.debug('houseAcct[0].Integration_Admin__c'+houseAcct[1].Integration_Admin__c);
    System.debug('UserInfo.getProfileId()'+UserInfo.getProfileId());
    if(Trigger.isUpdate)//&& UserInfo.getUserId() != houseAcct[1].Integration_Admin__c)
    {
        OpptyOperation.checkOpportunityLineItemUpdates(trigger.newMap,trigger.oldMap);
        OP_SSF_CommonUtils utils = new OP_SSF_CommonUtils();
        //update quote amounts
        utils.updateProducts(trigger.newMap,trigger.oldMap);        
    }
    if(Trigger.isInsert && UserInfo.getUserId() != houseAcct[1].Integration_Admin__c)
    {
        List<String> OpptyIds = new List<String>();
        Set<String> setopptyIDs = new Set<String>();
        try
        { 
	        for(OpportunityLineItem product:Trigger.new )
	        {
	            OpptyIds.add(product.OpportunityId); 
	            setopptyIDs.add(product.OpportunityId); 
	        }
	        OpptyOperation.insertOpportunityIntgLog(OpptyIds);
	        OP_SSF_CommonUtilsInterface utils = OP_SSF_CommonUtils.getInstance();
	        //create the split information for these products
	        utils.addProducts(Trigger.new,false);
        }
        catch(DMLException ex)
        {
            if(setopptyIDs.size() == 1)
            {
            	for(OpportunityLineItem oli: Trigger.new)
            	{
            		oli.addError(ex.getDMLMessage(0));
            	}
            }
            else
            {
            	throw ex;
            }
        }
        catch(Exception ex)
        {
        	throw ex;
        }        
    }
    if(Trigger.isDelete && UserInfo.getUserId() != houseAcct[1].Integration_Admin__c)
    {
        List<String> OldOpptyIds = new List<String>();
        for(OpportunityLineItem OldProduct:Trigger.old )
        {
            OldOpptyIds.add(OldProduct.OpportunityId);              
        }
        OpptyOperation.insertOpportunityIntgLog(OldOpptyIds);
        OP_SSF_CommonUtilsInterface utils = OP_SSF_CommonUtils.getInstance();
        utils.removeProducts(Trigger.old,false);        
          
    }
}