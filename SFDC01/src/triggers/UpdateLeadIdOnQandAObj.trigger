/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER         WR       DESCRIPTION                               

 |  ====          =========         ==       =========== 

 |  6/04/2012     Shipraa     		176284    SFA - Add Questions & Answers from Aprimo to SFDC.To track lead Id against Aprimo Id
 +===========================================================================*/
trigger UpdateLeadIdOnQandAObj on Marketing_Q_A__c (before insert) 

{
	//Holds set of Aprimo Id.
	Set<string> setAprimoId= New Set<String>();
	//Holds Map of Aprimo Id to Lead Id
	Map<String,Id> mapLeadIdToAprimoId= new Map<String,Id>();
	//make set of all Aprimo Id.
	for(Marketing_Q_A__c ldQAObj:trigger.new)
	{
		//Add to Aprimo Id set.
		setAprimoId.add(ldQAObj.Aprimo_Lead_ID__c);
	}
	//If set size is > 0 the update the Lead Q and A record.
	if(setAprimoId!=null && setAprimoId.size()>0)
	{
		//Query Lead object for Lead Id.
		List<Lead> lstQandA= new List<Lead>([Select Id,Name,Aprimo_Lead_ID__c from lead where Aprimo_Lead_ID__c in :setAprimoId]);
		if(lstQandA!=null && lstQandA.size()>0)
		{
			//For each lead record.
			for(Lead leadObj:lstQandA)
			{
				//Put Aprimo Id against lead Id.
				mapLeadIdToAprimoId.put(leadObj.Aprimo_Lead_ID__c,leadObj.id);
			}
		}
		for (integer i = 0 ; i < trigger.New.size(); i++)
		{
			//Assign Lead Look-up on Lead Q and A appropriate value.
			trigger.new[i].Lead_look_up__c=mapLeadIdToAprimoId.get(trigger.new[i].Aprimo_Lead_ID__c);
		}
	}

}