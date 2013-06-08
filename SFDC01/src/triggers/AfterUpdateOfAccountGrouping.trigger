/*======================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 

| 24/11/2010     Arif                     1477          PRM_PartnerFinderLocation class is 
                                                        instantiated which insert 
                                                        an entry in PartnerFinder
|                                                       object if Profiled Account Flag
                                                        on Account is True.      
  17/11/2011     Kaustav Debnath         178714         Created a new method for partner leverage 
                                                        to update all grouping accounts on profiled
                                                        being rating eligible 
| 28/11/2011    Shipra Misra             180005         Checking if trigger is fired after TA Assignment status update then return.                                              
  13/12/2011    Kaustav Debnath          178741         Modified the existing code to remove trigger.old to trigger.new
|                                                       comparison condition
  22/12/2011    Accenture                183066         Updated code to set the values on non Profiled Account if Velocity Tier Values
|                                                       are updated on PF account and invoked  updateRelatedPartnerType method for the same. 
  09/01/2012    Accenture                183430         Updated Code to invoke createAccountShareforGroup() method of PRM_AccountVisibility
|                                                       if the Profiled Account is getting Rating Eligible or if a New Account Is Added in Grouping. 
 22/01/2011      Accenture                              Updated trigger to incorporate ByPass Logic
|                                                       NOTE: Please write all the code after BYPASS Logic 
 9/05/2012      Accenture               183066          Updated code to set the values on non Profiled Account if Velocity Tier Values
|                                                       are updated on PF account and invoked  updateRelatedPartnerType method for the same
                                                        against Formula fields as they are not working for Integration.
|18/05/2012    Anirudh                  192375          Added Logic to flip record type based on PartnerType=DistiVAR 
 27/06/2012    Ganesh  Soma             194567          Added logic to invoke setGAFOwner() of PRM_GAF_Operations class if
|                                                       the Account Owner of any PartnerAccount Is changed.
|30/07/2012    Kaustav                  198481          Added Logic to update location records upon change of eBus_Lead_Admin__c on account                                                                       
+======================================================================================*/

trigger AfterUpdateOfAccountGrouping on Account (after update) {
   //Trigger BYPASS Logic
    if(CustomSettingBypassLogic__c.getInstance()!=null){
       System.Debug('1111--->');
       if(CustomSettingBypassLogic__c.getInstance().By_Pass_Account_Triggers__c){
                return;
       }
    } 
    if(Util.UPDATED_FROM_TO_TA_ASSIGNMENT_JOB_FLAG)return;
    System.Debug('NewFieldValue-----' +Trigger.New[0].PROFILED_ACCOUNT_FLAG__c);
    System.Debug('OldFieldValue-----' +Trigger.Old[0].PROFILED_ACCOUNT_FLAG__c);
    PRM_GroupingOfAssignment Obj = new PRM_GroupingOfAssignment();
    //WR 1477 Partner Finder Location class is instantiated here.
    PRM_PartnerFinderLocation instance = new PRM_PartnerFinderLocation();
    instance.createListOfAccountId(Trigger.NewMap,Trigger.OldMap);
    PRM_Partner_Leverage partner_leverage = new PRM_Partner_Leverage();
    map<Id,Id> mapPartnerAccountWithOwner = new Map<Id,Id>();
    //WR 1477
    //Code written for Partner leverage functionality
    List<Account> lstProfiledAccounts=new List<Account>();    
    List<Account> lstProfiledAccountsRatingFalse=new List<Account>();
    /*Code added for eBiz SFDC integration WR 198481*/
    Map<Id,Account> mapProfiledAccountsEbizLeadAdminChanged_OLD = new Map<Id,Account>();
    Map<Id,Account> mapProfiledAccountsEbizLeadAdminChanged_NEW = new Map<Id,Account>();
    Map<Id,Account> mapProfiledAccountsNonEBizFieldsUpdated_OLD = new Map<Id,Account>();
    Map<Id,Account> mapProfiledAccountsNonEBizFieldsUpdated_NEW = new Map<Id,Account>();
    Map<String,CustomSetting_eBusiness_SFDC_Integration__c> mapCustomSettingEBiz = CustomSetting_eBusiness_SFDC_Integration__c.getall();
    Boolean isOnlyAccountUpdate=false; 
        CustomSetting_eBusiness_SFDC_Integration__c account_Ebus_enabled = (mapCustomSettingEBiz.get('eBus_Partner_Enabled__c'));           
        String str_eBiz_picklist_values = account_Ebus_enabled.String_Values__c;
        Set<String> split1 = new Set<String>();
    	for(String s: str_eBiz_picklist_values.Split(';')){
        	split1.add(s.toLowerCase());
    	}
     /*End of Code added for eBiz SFDC integration WR 198481*/   
    for(Integer i=0;i<Trigger.New.size();i++)
    {
        if(Trigger.New[i].Rating_Eligible__c!=Trigger.Old[i].Rating_Eligible__c && Trigger.New[i].Rating_Eligible__c==true && Trigger.New[i].PROFILED_ACCOUNT_FLAG__c==true)
        {
            lstProfiledAccounts.add(Trigger.New[i]);            
        }
        else if(Trigger.New[i].Rating_Eligible__c!=Trigger.Old[i].Rating_Eligible__c && Trigger.New[i].Rating_Eligible__c==false && Trigger.New[i].PROFILED_ACCOUNT_FLAG__c==true)
        {
            lstProfiledAccountsRatingFalse.add(Trigger.New[i]);
        }
        else if(Trigger.New[i].OwnerId != Trigger.Old[i].OwnerId && Trigger.New[i].IsPartner==true){
                mapPartnerAccountWithOwner.put(Trigger.New[i].Id,Trigger.New[i].OwnerId);
        }   
        /*Code added for eBiz SFDC integration WR 198481*/     
        if( Trigger.Old[i].PROFILED_ACCOUNT_FLAG__c == Trigger.New[i].PROFILED_ACCOUNT_FLAG__c
		    && Trigger.New[i].PROFILED_ACCOUNT_FLAG__c == TRUE
			&&((Trigger.New[i].eBus_Lead_Admin__c!=null && Trigger.New[i].eBus_Lead_Admin__c!=Trigger.Old[i].eBus_Lead_Admin__c)	|| 
			(Trigger.New[i].eBus_Partner_Enabled__c!=null && Trigger.New[i].eBus_Partner_Enabled__c != Trigger.Old[i].eBus_Partner_Enabled__c 
			&&  split1.contains(Trigger.New[i].eBus_Partner_Enabled__c.toLowerCase()))))
        {
			mapProfiledAccountsEbizLeadAdminChanged_OLD.put(Trigger.Old[i].id,Trigger.Old[i]);
        	mapProfiledAccountsEbizLeadAdminChanged_NEW.put(Trigger.New[i].id,Trigger.New[i]);
        }
        
         
         if( Trigger.Old[i].PROFILED_ACCOUNT_FLAG__c == Trigger.New[i].PROFILED_ACCOUNT_FLAG__c
		    && Trigger.New[i].PROFILED_ACCOUNT_FLAG__c == TRUE
		    && (split1!=null && Trigger.New[i].eBus_Partner_Enabled__c!=null && split1.contains(Trigger.New[i].eBus_Partner_Enabled__c.toLowerCase()))
			&& (Trigger.New[i].eBus_Lead_Admin__c!=null || Trigger.New[i].eBus_Lead_Admin__c==null) 
			&& Trigger.New[i].eBus_Lead_Admin__c!=Trigger.Old[i].eBus_Lead_Admin__c	 
			)/*This if condition checks that the Profiled account is eBiz enabled and the eBiz lead admin gets updated*/
         {
         	System.debug('in if for lead owner change');
         	mapProfiledAccountsEbizLeadAdminChanged_OLD.put(Trigger.Old[i].id,Trigger.Old[i]);
        	mapProfiledAccountsEbizLeadAdminChanged_NEW.put(Trigger.New[i].id,Trigger.New[i]);
         }
         
         else if(Trigger.Old[i].PROFILED_ACCOUNT_FLAG__c == Trigger.New[i].PROFILED_ACCOUNT_FLAG__c
		    && Trigger.New[i].PROFILED_ACCOUNT_FLAG__c == TRUE
		    && (Trigger.New[i].eBus_Partner_Enabled__c!=null && Trigger.New[i].eBus_Partner_Enabled__c != Trigger.Old[i].eBus_Partner_Enabled__c 
			&&  split1!=null && split1.contains(Trigger.New[i].eBus_Partner_Enabled__c.toLowerCase()))
			)/*This if condition checks that the eBiz Enabled field changes for the Profiled account */
         {
         	System.debug('in else if for partner enabled');
         	mapProfiledAccountsNonEBizFieldsUpdated_OLD.put(Trigger.Old[i].id,Trigger.Old[i]);
        	mapProfiledAccountsNonEBizFieldsUpdated_NEW.put(Trigger.New[i].id,Trigger.New[i]);
         }
         else if(Trigger.Old[i].PROFILED_ACCOUNT_FLAG__c == Trigger.New[i].PROFILED_ACCOUNT_FLAG__c
		    && Trigger.New[i].PROFILED_ACCOUNT_FLAG__c == TRUE
		    && (Trigger.New[i].eBus_Partner_Enabled__c==null && Trigger.New[i].eBus_Partner_Enabled__c != Trigger.Old[i].eBus_Partner_Enabled__c)
			)/*This if condition checks that the eBiz Enabled field gets updated to blank for the Profiled account */
         {
         	System.debug('in else if for partner enabled changed to null');
         	mapProfiledAccountsNonEBizFieldsUpdated_OLD.put(Trigger.Old[i].id,Trigger.Old[i]);
        	mapProfiledAccountsNonEBizFieldsUpdated_NEW.put(Trigger.New[i].id,Trigger.New[i]);
         }
         
         else if(Trigger.New[i].eBus_Partner_Enabled__c!=null
	         	&& Trigger.Old[i].PROFILED_ACCOUNT_FLAG__c == Trigger.New[i].PROFILED_ACCOUNT_FLAG__c
			    && Trigger.New[i].PROFILED_ACCOUNT_FLAG__c == TRUE		    
			    && split1.contains(Trigger.New[i].eBus_Partner_Enabled__c.toLowerCase())
			    && ((Trigger.Old[i].name!=Trigger.Old[i].name) ||
			        (Trigger.New[i].Partnership_Overview__c!=Trigger.Old[i].Partnership_Overview__c)||
			        (Trigger.New[i].Partner_Self_Description_Long__c!=Trigger.Old[i].Partner_Self_Description_Long__c)||
			        (Trigger.New[i].logo__c!=Trigger.Old[i].logo__c)||
			        (Trigger.New[i].Business_Focus__c!=Trigger.Old[i].Business_Focus__c)||
			        (Trigger.New[i].Industry_Verticals__c!=Trigger.Old[i].Industry_Verticals__c)||
			        (Trigger.New[i].Product_Focus__c!=Trigger.Old[i].Product_Focus__c)
			    )
			)/*This if condition checks that the non eBiz fields gets updated to blank for the Profiled account */
         {
         	System.debug('in else if for non ebiz fields being updated');
         	mapProfiledAccountsNonEBizFieldsUpdated_OLD.put(Trigger.Old[i].id,Trigger.Old[i]);
        	mapProfiledAccountsNonEBizFieldsUpdated_NEW.put(Trigger.New[i].id,Trigger.New[i]);
         }
         
        /*End of Code added for eBiz SFDC integration WR 198481*/
    }
    
    
    if(lstProfiledAccounts!=null && lstProfiledAccounts.size()>0)
    {
        //System.debug('#### in here');
        partner_leverage.groupingAccountsRatingEligible(lstProfiledAccounts,true);        
    }
    if(lstProfiledAccountsRatingFalse!=null && lstProfiledAccountsRatingFalse.size()>0)
    {
        //System.debug('#### in here');
        partner_leverage.groupingAccountsRatingEligible(lstProfiledAccountsRatingFalse,false);
    }
    /*end of code for partner leverage functionality*/
    /*Code added for eBiz SFDC integration WR 198481*/
    if(mapProfiledAccountsEbizLeadAdminChanged_OLD!=null && mapProfiledAccountsEbizLeadAdminChanged_NEW!=null 
       && mapProfiledAccountsEbizLeadAdminChanged_OLD.size()>0 && mapProfiledAccountsEbizLeadAdminChanged_NEW.size()>0)
    {
    	Boolean isPartnerLocationUpdated=new PartnerInfoIntegrationOperation().updateLocationEBizLeadAdminFields(mapProfiledAccountsEbizLeadAdminChanged_OLD,mapProfiledAccountsEbizLeadAdminChanged_NEW);
    	if(!isPartnerLocationUpdated)//This loop executes if no locations are updated for the account update to make an entry into the log table
    	{
    		new PartnerInfoIntegrationOperation().insertAccountIntegrationLog(mapProfiledAccountsEbizLeadAdminChanged_OLD,mapProfiledAccountsEbizLeadAdminChanged_NEW);
    	}
    }
    if(mapProfiledAccountsNonEBizFieldsUpdated_OLD!=null && mapProfiledAccountsNonEBizFieldsUpdated_NEW!=null 
       && mapProfiledAccountsNonEBizFieldsUpdated_OLD.size()>0 && mapProfiledAccountsNonEBizFieldsUpdated_NEW.size()>0)
    {
    	new PartnerInfoIntegrationOperation().insertAccountIntegrationLog(mapProfiledAccountsNonEBizFieldsUpdated_OLD,mapProfiledAccountsNonEBizFieldsUpdated_NEW);
    	
    }
    /*End of Code added for eBiz SFDC integration WR 198481*/
    if(PRM_GroupingOfAssignment.PartnerGroupingCreation || PRM_GroupingOfAssignment.isRelatedSiteDunsExceedingLimit){
        return;
    }
    else{
        System.debug('I am in account trigger after update');
        Map<String,String> accountsAfterUpdate = new Map<String,String>(); //Map  which contains SITE_DUNS/ENTITY_ID along with Grouping Name
        Map<Id,Account> accountIdWithPartnerType = new Map<Id,Account>();
        List<Account> accountList = new List<Account>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> newAccountId = Trigger.newMap.keySet();
        for(Id newAccId: newAccountId){
            Account newAccountValue = Trigger.newMap.get(newAccId);
            System.debug('New value of Account'+newAccountValue);
            Account oldAccountValue = Trigger.oldMap.get(newAccId);
            System.debug('Old value of Account'+oldAccountValue);
            if(newAccountValue.Grouping__c!=null && newAccountValue.Grouping__c!=oldAccountValue.Grouping__c && newAccountValue.PROFILED_ACCOUNT_FLAG__c==false && newAccountValue.Site_DUNS_Entity__c!=null){ //comparing old value with new value of grouping
                String groupNames = newAccountValue.Grouping__c+'='+newAccountValue.Master_Grouping__c+'@'+newAccountValue.PROFILED_ACCOUNT__c; //assigning the new grouping value
                if(newAccountValue.PROFILED_ACCOUNT__c!=null){
                    accountsAfterUpdate.put(newAccountValue.Site_DUNS_Entity__c,groupNames); //Adding the SITE_DUNS/ENTITY_ID and new grouping name
                    System.debug('After putting in map'+accountsAfterUpdate);
                }
            }
            //Here checking if Partner Type of the profiled account is changed, then updating its related accounts.
            if((newAccountValue.Partner_Type__c!=oldAccountValue.Partner_Type__c || newAccountValue.VSI_Approved_Delivery_Products__c!=oldAccountValue.VSI_Approved_Delivery_Products__c ||
                newAccountValue.Velocity_Specialties_Achieved__c!=oldAccountValue.Velocity_Specialties_Achieved__c || newAccountValue.Affiliate_Services__c!=oldAccountValue.Affiliate_Services__c ||
                newAccountValue.Velocity_Services_Implement__c !=oldAccountValue.Velocity_Services_Implement__c || newAccountValue.Velocity_Solution_Provider_Tier__c != oldAccountValue.Velocity_Solution_Provider_Tier__c ||
                newAccountValue.Master_Site_ID__c !=oldAccountValue.Master_Site_ID__c || newAccountValue.Master_Agreement__c != oldAccountValue.Master_Agreement__c)
                && newAccountValue.PROFILED_Account_flag__c==true){
                    System.debug('Profiled Account in Trigger'+newAccountValue.Id);
                    accountIdWithPartnerType.put(newAccountValue.Id,newAccountValue);
            }
        }    
        if(accountsAfterUpdate.size()>0){
            //Obj.updateGroupingsFromTrigger(accountsAfterUpdate);
            Obj.updateRelatedGrouping(accountsAfterUpdate); //Calling update method to update the all the account based on SITE_DUNS/ENTITY_ID
        }
        if(accountIdWithPartnerType.size()>0){
            Obj.updateRelatedPartnerType(accountIdWithPartnerType);//Calling update method to update Partner type field on related accounts.
        }
        
    }
    
    set<Id> seAccountId = new set<Id>();
    PRM_ContactUserSynchronization refObj= new PRM_ContactUserSynchronization();
    for(Account acc: Trigger.new)
    {       
        Account oldAccount = Trigger.oldMap.get(acc.Id);
        if(acc.Partner_Type__c!=null && acc.IsPartner && (acc.Partner_Type__c!=oldAccount.Partner_Type__c) && acc.Partner_Type__c.contains('Distribution VAR') )
        {
            seAccountId.add(acc.Id);            
        }
        if(acc.Partner_Type__c!=null && acc.IsPartner && (acc.Partner_Type__c!=oldAccount.Partner_Type__c) && !acc.Partner_Type__c.contains('Distribution VAR'))
        {
            seAccountId.add(acc.Id);            
        }    
    }
    if(seAccountId.size()>0)
    {
        PRM_ContactUserSynchronization.flipContactRecordTypetoDistiVarOnUpdateofAccount(seAccountId);
    }
    if(mapPartnerAccountWithOwner.size()>0){
        new PRM_GAF_Operations().setGAFOwner(mapPartnerAccountWithOwner,trigger.newMap);
    }
      
  }