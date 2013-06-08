trigger opptyAssetsBeforeDelete on Opportunity_Asset_Junction__c (before Delete) {
  Set<Id> optyToUpdate = new Set<Id>();
  
if (Trigger.isBefore && Trigger.isDelete) 
  {
  
  SFA_MOJO_OppAssetJunctionTriggerCode junctionObj = new SFA_MOJO_OppAssetJunctionTriggerCode();
   for(Opportunity_Asset_Junction__c jnObj : Trigger.Old)
        {
            if(jnObj.Related_Opportunity__c!=null)
            {
                optyToUpdate.add(jnObj.Related_Opportunity__c);
            }
        }
        junctionObj.updateTradeInsAndSwaps(optyToUpdate);
    
  }

}