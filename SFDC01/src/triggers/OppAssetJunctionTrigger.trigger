trigger OppAssetJunctionTrigger on Opportunity_Asset_Junction__c (after insert, before update) 
{
	if (Trigger.isInsert && Trigger.isAfter && Trigger.New != null) 
	{
		//system.debug('#### Entered Trigger code');
		SFA_MOJO_OppAssetJunctionTriggerCode.updateAssetRecords(Trigger.NewMap, Trigger.isUpdate);
	}

	if (Trigger.isUpdate && Trigger.isBefore && Trigger.New != null) 
	{
		SFA_MOJO_OppAssetJunctionTriggerCode.updateAssetRecords(Trigger.NewMap, Trigger.isUpdate);
	}
}