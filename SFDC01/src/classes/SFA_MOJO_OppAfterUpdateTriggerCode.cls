/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  13 Oct 2012     Avinash K       MOJO        Initial Creation.The methods from this class are called from OpportunityAfterUpdate
                                                on after update event. One method updates the Disposition status on Asset when Forecast status
                                                is updated and another posts a chatter feed on Opportunity when SO# is updated

    13 Oct 2012     Avinash K       MOJO 		Updated the code to remove the AFM part which is to be implemented in MOJO Phase 2.
+========================================================================================================================*/



public class SFA_MOJO_OppAfterUpdateTriggerCode 
{
    public static Boolean blnUpdatedDispositionStatus = false;
    public static Boolean blnNotifiedOnSOUpdate = false;

    

    public static void updateDispositionStatus(List<Opportunity> lstNew, Map<Id,Opportunity> mapOld)
    {
        Set<Id> setOppIds = new Set<Id>();
        // Set<Id> setClosedOppIds = new Set<Id>();

        if (blnUpdatedDispositionStatus == false) 
        {
//Code for Disposition Status begins... -Avinash K
            blnUpdatedDispositionStatus = true;

            for (Opportunity opp : lstNew) 
            {
                if (opp.StageName != mapOld.get(opp.id).StageName) 
                {
                    setOppIds.add(opp.id);
                }
            }

            try
            {
               	List<Opportunity_Asset_Junction__c> lstJunction;
                if(setOppIds.size()>0){
                	// List<Opportunity_Asset_Junction__c> lstUpdateJunction = List<Opportunity_Asset_Junction__c>();
	                lstJunction = [Select id, Asset_Disposition_Status__c, Related_Asset__c, Related_Opportunity__c 
	                    From Opportunity_Asset_Junction__c
	                    Where Related_Opportunity__c in :setOppIds AND Isactive__c = true
	                    Limit 50000];	                
                }
                if (lstJunction != null && lstJunction.size() > 0) 
                {
                    update lstJunction;
                }
            }
            catch(Exception e)
            {
                ////system.debug('#### Exception Thrown : '+e);
            }
        }
    }
    

// Code for Disposition Status ends. - Avinash K


// Code for "Email/Chatter when SO# on Opportunity is updated" begins...  -Avinash K

    public static void notifyOnSOUpdate(Map<Id,Opportunity> mapNew, Map<Id,Opportunity> mapOld)
    {
//system.debug('#### entered notify method');
        Set<Id> setOppIds = new Set<Id>();
        Map<Id,String> mapOppIdAndRegistrationId = new Map<Id,String>();
        Map<Id,Id> mapOppIdAndAFMId = new Map<Id,Id>();

        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall();
        CustomSettingDataValueMap__c CompRecord;
        String strCompetitiveInstallId;

        if(mapCustomSettingDataValueMap != null && mapCustomSettingDataValueMap.get('Asset Competitive Record Type Id') != null)
            CompRecord = mapCustomSettingDataValueMap.get('Asset Competitive Record Type Id');
        
        if(CompRecord != null && CompRecord.Datavalue__c != null)
            strCompetitiveInstallId = CompRecord.Datavalue__c;


        if(blnNotifiedOnSOUpdate == false)
        {
            blnNotifiedOnSOUpdate = true;

//system.debug('#### entered notify on update part 2');

            for (Opportunity opp : mapNew.values()) 
            {
                if (opp.SO_Number__c != '' && opp.SO_Number__c != mapOld.get(opp.id).SO_Number__c) 
                {
                    setOppIds.add(opp.id);
                }
            }

//system.debug('#### setOppIds : '+setOppIds);

////system.debug('#### Limits.getHeapSize() BEFORE nested Query :: '+Limits.getHeapSize());
////system.debug('#### Limits.getLimitHeapSize() BEFORE nested Query :: '+Limits.getLimitHeapSize());

           List<Opportunity> lstOpp;
            if(setOppIds.size()>0){
            	lstOpp = [Select id, name, SO_Number__c, Account_TheaterText__c, 
                                        (select Registration_ID__c, AFM__c, AFM__r.email from Trade_Ins_Competitive_Swaps__r limit 50000),
                                        (select Asset_Record_Type_ID__c from Opportunity_Asset_Junction__r limit 50000)
                From Opportunity
                Where id in :setOppIds
                Limit 50000];            	
            } 

////system.debug('#### Limits.getHeapSize() AFTER nested Query :: '+Limits.getHeapSize());
////system.debug('#### Limits.getLimitHeapSize() AFTER nested Query :: '+Limits.getLimitHeapSize());
    
//system.debug('#### lstOpp : '+lstOpp);
		if(lstOpp != null){	
			
            for (Opportunity opp : lstOpp) 
            {
                Boolean blnCompetitiveAssetExists = false;
                for (Opportunity_Asset_Junction__c oaj: opp.Opportunity_Asset_Junction__r) 
                {
                    if (oaj.Asset_Record_Type_ID__c == strCompetitiveInstallId) 
                    {
                        blnCompetitiveAssetExists = true;
                        break;
                    }
                }
                
//system.debug('#### blnCompetitiveAssetExists : '+blnCompetitiveAssetExists);
                if(blnCompetitiveAssetExists)
                {
//system.debug('#### Entered AFM section Trade_Ins_Competitive_Swaps__r :: '+opp.Trade_Ins_Competitive_Swaps__r);
                    for (Trade_Ins_Competitive_Swap__c trade : opp.Trade_Ins_Competitive_Swaps__r) 
                    {
                        if (trade.Registration_ID__c != '' && trade.Registration_ID__c != null) 
                        {
                            mapOppIdAndRegistrationId.put(opp.Id,trade.Registration_ID__c);
//system.debug('#### Inside Registration ID present section');
                        }
                        
//system.debug('#### AFM : '+trade.AFM__c);
                        
                        /*if (trade.AFM__c != '' && trade.AFM__c != null) 
                        {
                            mapOppIdAndAFMId.put(opp.Id,trade.AFM__c);
                        }*/
                    }
                }
            }
		}
//system.debug('#### mapOppIdAndRegistrationId ::' +mapOppIdAndRegistrationId.values());

            List<OAR_Member_Added__c> lstOAR = new List<OAR_Member_Added__c>();
            List<FeedItem> lstFeedItem = new List<FeedItem>();

            for (Id oppid : mapOppIdAndRegistrationId.keyset())
            {
                if((mapNew.get(oppid).Account_TheaterText__c != null) && (mapNew.get(oppid).SO_Number__c != null))
                {
                    OAR_Member_Added__c oar = new OAR_Member_Added__c();
                    Opportunity opp = mapNew.get(oppid);
                    
                    oar.Name = mapNew.get(oppid).name;
                    oar.Condition__c = System.Label.OAR_Condition_for_MOJO;
                    oar.Text_1__c = opp.Account_TheaterText__c;
                    oar.Text_2__c = opp.SO_Number__c;
                    oar.Text_3__c = mapOppIdAndRegistrationId.get(oppid);
                    oar.Text_4__c = 'https://'+URL.getSalesforceBaseUrl().getHost()+'/'+oppid;
                    if (mapOppIdAndAFMId.get(oppid) != null) 
                    {
                        oar.User_1__c = mapOppIdAndAFMId.get(oppid);
                    }
                    
                    lstOAR.add(oar);

                    FeedItem fi = new FeedItem();
                    fi.Title = 'Link to Opportunity';
                    fi.Body = 'Oppty with GFS Registration Number "'+ mapOppIdAndRegistrationId.get(oppid) +'" has just been notified of an SO# "'+ mapNew.get(oppid).SO_Number__c +'" on '+System.today().format();
                    fi.linkURL = 'https://'+URL.getSalesforceBaseUrl().getHost()+'/'+oppid;
                    fi.ParentId = oppid;

                    lstFeedItem.add(fi);
                }
            }

            if (lstOAR.size() > 0 && lstFeedItem.size() > 0 && lstOAR.size() == lstFeedItem.size()) 
            {
                try
                {
                    insert lstOAR;
                    insert lstFeedItem;
                }
                catch(Exception e)
                {
                    ////system.debug('#### Exception Thrown while inserting OAR/Chatter Post');
                }
            }

        }
    }

// Code for "Email/Chatter when SO# on Opportunity is updated" ends.  -Avinash K

    
}