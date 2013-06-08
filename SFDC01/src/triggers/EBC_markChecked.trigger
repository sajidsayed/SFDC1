/*
*  Created By       :- Sunil Arora
*  Created Date     :- 26/02/2010
*  Last Modified By :- Sunil Arora
*  Description      :- This trigger is used to update GSE Account related values in Briefing Event.
*/
trigger EBC_markChecked on EBC_Briefing_Event__c (before Update)
{
   Set<Id> customerId=new set<Id>();
   Map<String,Id> accGlobalEntityMap=new Map<String,Id>();
   
   //This loop is used to get Account Id
   for(EBC_Briefing_Event__c bEvent:trigger.new){
       customerId.add(bEvent.Customer_Name__c);
    }
   Account[] accLst=[select Id, Global_DUNS_Entity__c from Account where Id IN: customerId];//This call is used to get Global_DUNS_Entity__c
   
   for(Integer i=0;i<accLst.size();i++)
    {
    	accGlobalEntityMap.put( accLst[i].Global_DUNS_Entity__c,accLst[i].Id);//Keeping Global_DUNS_Entity__c and Account Id as key value poir in map.
    }
    //This call is used here to fetch related Global_Strategic_Executive_Account__c records.
    EBC_Global_Strategic_Executive_Account__c[] gseAccount=[Select Id,Global_DUNS__c,Executive_Sponsor_Email_2__c, Executive_Sponsor_E_mail__c,
                                                                   District_Manager_Email__c,District_Manager_2_Email__c,CSM_Name__c,
                                                                   CSM_Name_2__c, CSM_Email__c ,CSM_Email2__c,
                                                                   GAM_email_address__c, GAM_email_address_2__c
                                                            from EBC_Global_Strategic_Executive_Account__c 
                                                            where Global_DUNS__c IN: accGlobalEntityMap.keySet()]; 
    for(EBC_Briefing_Event__c bEvent:trigger.new)
    {
        bEvent.SGE_Account__c=false;
    	bEvent.CSM_1_Email__c=null;
        bEvent.CSM_2_Email__c=null;
    	bEvent.Account_Designation__c=null;
    	bEvent.DM_1_Email__c=null;
    	bEvent.DM_2_Email__c=null;
    	bEvent.Executive_Sponsor_1_Email__c=null;
    	bEvent.Executive_Sponsor_2_Email__c=null;
    	bEvent.GAM_1_Email__c=null;
    	bEvent.GAM_2_Email__c=null;
       for(Integer i=0;i<gseAccount.size();i++)
    	{ 
    		if(accGlobalEntityMap.containsKey(gseAccount[i].Global_DUNS__c))
    		{	
    			 bEvent.SGE_Account__c=true;
    			 bEvent.CSM_1_Email__c=gseAccount[i].CSM_Email__c;
    			 bEvent.CSM_2_Email__c=gseAccount[i].CSM_Email2__c;
    			 bEvent.Account_Designation__c=gseAccount[i].Id;
    			 bEvent.DM_1_Email__c=gseAccount[i].District_Manager_Email__c;
    			 bEvent.DM_2_Email__c=gseAccount[i].District_Manager_2_Email__c;
    			 bEvent.Executive_Sponsor_1_Email__c=gseAccount[i].Executive_Sponsor_E_mail__c;
    			 bEvent.Executive_Sponsor_2_Email__c=gseAccount[i].Executive_Sponsor_Email_2__c;
    			 bEvent.GAM_1_Email__c=gseAccount[i].GAM_email_address__c;
    			 bEvent.GAM_2_Email__c=gseAccount[i].GAM_email_address_2__c; 
    		}
    	}
    }
}