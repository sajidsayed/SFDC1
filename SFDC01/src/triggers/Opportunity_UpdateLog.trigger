/*===================================================================================================================================
|22/01/2011      Accenture                              Updated trigger to incorporate ByPass Logic
|                                                       NOTE: Please write all the code after BYPASS Logic 
|14/02/2012		Shipraa M								SFA - EMEA email alert changes (FD Required)
 ===================================================================================================================================*/

trigger Opportunity_UpdateLog on Opportunity (after insert,After Update) {
  //Trigger BYPASS Logic
   if(CustomSettingBypassLogic__c.getInstance()!=null){
      if(CustomSettingBypassLogic__c.getInstance().By_Pass_Opportunity_Triggers__c){
                return;
      }
   }
    //Inside EMEA Alerts.
    Map<Id,Opportunity> mapNewOpp= new Map<Id,Opportunity>();
    Map<Id,Opportunity> mapOldOpp= new Map<Id,Opportunity>();
    Map<Id,Opportunity> mapBookedOpp= new Map<Id,Opportunity>();
    
    if(trigger.isUpdate)
    {
    	for(Id newoppId:trigger.newMap.keySet())
    	{
    		Opportunity newOpportunity=trigger.newMap.get(newoppId);
    		Opportunity oldOpportunity=trigger.oldMap.get(newoppId);
    		if(newOpportunity.StageName!=oldOpportunity.StageName || newOpportunity.CloseDate!=oldOpportunity.CloseDate)
	    	{
	    		mapNewOpp.put(newoppId,newOpportunity);
	    		mapOldOpp.put(newoppId,oldOpportunity);
	    		system.debug('MapNewOpp '+mapNewOpp);
	    		if(newOpportunity.StageName=='Booked' && newOpportunity.Under_Pen_Account_Type__c!=null &&newOpportunity.Opportunity_Owner__c!=null)
	    		{
	    			System.debug('newOpportunity.Under_Pen_Account_Type_Legacy__c==>'+newOpportunity.Under_Pen_Account_Type__c);
	    			mapBookedOpp.put(newoppId,newOpportunity);
	    		}
	    	}
	    	
    	}
    	if(mapNewOpp!=null && mapNewOpp.size()>0)
    	{
    		Opp_EMEAInsideSalesAlerts oppEmeaAlerts = new Opp_EMEAInsideSalesAlerts();
    		oppEmeaAlerts.updateEmailNotificationRecords(mapNewOpp,mapOldOpp);
    	}
    	if(mapBookedOpp!=null && mapBookedOpp.size()>0)
    	{
    		//For Under pen email alerts.
    		if(!Util.Underpen_EMAIL_Alert_fired)
    		{
    			Enterprise_Under_Pen_Email_Notification.updateEmailFieldsForEnterpriseNotification(mapBookedOpp);
    		}
    	}
    	
    }
    //End of Inside EMEA Alerts.
    if(!EMC_BRS_S2S_AutoForward.Opportunity_UpdateLogFlag){
        EMC_BRS_S2S_AutoForward.Opportunity_UpdateLogFlag = true;
        Map<Id,Id> opptyOwnerMap = new Map<Id,Id>();
        Profiles__c profile = Profiles__c.getInstance();
        System.debug('UserInfo.getProfileId()  '+ UserInfo.getProfileId());
        System.debug('profile.System_Admin_API_Only__c '+profile.System_Admin_API_Only__c );
        System.debug('util.CheckOpportunityAccess '+util.CheckOpportunityAccess ); 
        if(util.CheckOpportunityAccess){
          if(trigger.isInsert|| trigger.isUpdate){
            for(Opportunity oppty:trigger.new){
                
                    if( UserInfo.getProfileId() == profile.System_Admin_API_Only__c && trigger.isUpdate && trigger.oldMap.get(oppty.Id).OwnerId!=trigger.newMap.get(oppty.Id).OwnerId){
                       System.debug('Yes');
                        opptyOwnerMap.put(oppty.Id,oppty.OwnerId);
                    }
                    if(trigger.isInsert || trigger.oldMap.get(oppty.Id).OwnerId!=trigger.newMap.get(oppty.Id).OwnerId || Util.mapOldOpportunityOwner.get(oppty.Id)!=Util.mapNewOpportunityOwner.get(oppty.Id)){
                        System.debug('No');
                        opptyOwnerMap.put(oppty.Id,oppty.OwnerId);
                    }
                
            }
        }
        if(!opptyOwnerMap.isEmpty() &&  Opp_MassUserReassignment.ExecuteOwnerChangeTrigger){
            System.debug('Yes1'); 
            OP_SSF_CommonUtilsInterface utils = OP_SSF_CommonUtils.getInstance();
            utils.changeOwner(opptyOwnerMap,false);
        } 
        if(Trigger.isAfter && Trigger.isUpdate && UserInfo.getProfileId() != profile.System_Admin_API_Only__c){
            System.debug('No1');
            OpportunityOperation OpptyOperation = new OpportunityOperation();
            OpptyOperation.checkOpportunityUpdates(trigger.newMap,trigger.oldMap);
        }   
        }
        //Included this code for S2S functionality
        if(trigger.isUpdate){
            //System.debug('*******welcome');
            EMCBRS_S2S_Utils s2sUtils = new EMCBRS_S2S_Utils();
            s2sUtils.upsertSharedOpportunities(Trigger.oldMap,Trigger.newMap);
        }
    }
  }