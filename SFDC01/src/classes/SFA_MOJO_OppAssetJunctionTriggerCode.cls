/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  13 Oct 2012     Avinash K       MOJO        Initial Creation.Created this class to include the OpportunityAssetJunction 
                                                Trigger logic.
+========================================================================================================================*/

public with sharing class SFA_MOJO_OppAssetJunctionTriggerCode
{

    public static Boolean blnInsertUpdate = false;

    public static void updateAssetRecords(Map<ID,Opportunity_Asset_Junction__c> mapNew, Boolean isUpdate)
    {
        try
        {
            Set<Id> setAssetId = new Set<Id>();
            Map<Id,Set<Id>> mapJunctionIdAndSetAssetId = new Map<Id,Set<Id>>();

            if(mapNew != null && mapNew.values() != null && !blnInsertUpdate)
            {
                blnInsertUpdate = true;

                for (Opportunity_Asset_Junction__c j: mapNew.values()) 
                {
                    if(j.Isactive__c)
                    {
                        setAssetId.add(j.Related_Asset__c);


                        if (mapJunctionIdAndSetAssetId.get(j.id) == null) 
                        {
                            Set<Id> setAssetTemp = new Set<Id>();
                            setAssetTemp.add(j.Related_Asset__c);
                            mapJunctionIdAndSetAssetId.put(j.id,setAssetTemp);
                        }
                    }
                }

                Map<Id,Asset__c> mapAssetIdAndAsset;

                if(setAssetId != null && setAssetId.size() > 0)
                {
                    Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall();
                    CustomSettingDataValueMap__c CompRecord;
                    String strCompetitiveInstallId;

                    if(mapCustomSettingDataValueMap != null && mapCustomSettingDataValueMap.get('Asset Competitive Record Type Id') != null)
                        CompRecord = mapCustomSettingDataValueMap.get('Asset Competitive Record Type Id');
                    
                    if(CompRecord != null && CompRecord.Datavalue__c != null)
                        strCompetitiveInstallId = CompRecord.Datavalue__c;

                    mapAssetIdAndAsset = new Map<Id,Asset__c>([Select id, Disposition_Status__c 
                        From Asset__c
                        Where Id in :setAssetId AND RecordTypeId = :strCompetitiveInstallId
                        Limit 50000]);

                    for (Id jid: mapJunctionIdAndSetAssetId.keyset()) 
                    {
                        for (Id aid: mapJunctionIdAndSetAssetId.get(jid)) 
                        {
                            if (mapNew.get(jid).Opportunity_Forecast_Status__c != 'Closed' && mapNew.get(jid).Opportunity_Forecast_Status__c != 'Booked')
                            {
                                mapAssetIdAndAsset.get(aid).Disposition_Status__c = mapNew.get(jid).Opportunity_Forecast_Status__c;
                            }

                            else if(mapNew.get(jid).Opportunity_Forecast_Status__c == 'Booked')
                                mapAssetIdAndAsset.get(aid).Disposition_Status__c = 'Displaced by EMC';

                            else if (mapNew.get(jid).Opportunity_Forecast_Status__c == 'Closed') 
                            {
                                if (mapNew.get(jid).Opportunity_Closed_Reason__c.containsIgnoreCase('Competition')) 
                                {
                                    mapAssetIdAndAsset.get(aid).Disposition_Status__c = 'Displaced by competitor';
                                }
                                else
                                    mapAssetIdAndAsset.get(aid).Disposition_Status__c = 'Installed';
                                
                                if(isUpdate)
                                    mapNew.get(jid).Isactive__c = false;
                            }
                        }
                    }

                    update mapAssetIdAndAsset.values();
                }
            }
        }
        catch(Exception e)
        {
            if(e != null && e.getTypeName() != null && e.getTypeName().containsIgnoreCase('DML'))
            {
                for (Opportunity_Asset_Junction__c oaj : mapNew.values()) 
                {
                    for (Integer i = 0; i < e.getNumDml(); i++) 
                    {
    //System.debug(e.getDmlMessage(i));
                        oaj.addError(e.getDmlMessage(i));
                    }
                }
            }
        }
    }
    //Method to Update Trade Ins/Swaps if any asset is linked/uninked.
    public void updateTradeInsAndSwaps(set<Id> setOpportunityId)
    {
        Trade_Ins_Competitive_Swap__c[] lstTradeInAndSwap;
        if(setOpportunityId!=null && setOpportunityId.size()>0)
        {
            lstTradeInAndSwap=[Select Swap_Value__c, Related_Opportunity__c,Registration_ID__c, Name, Id From Trade_Ins_Competitive_Swap__c where Related_Opportunity__c in: setOpportunityId];
            if(lstTradeInAndSwap.size()!=0)
            {
                lstTradeInAndSwap[0].Swap_Value__c=null;
                lstTradeInAndSwap[0].Registration_ID__c='';
            }
            if(lstTradeInAndSwap.size()!=0)
            {
                Database.SaveResult[] unlinkTradeInSwaps = Database.update(lstTradeInAndSwap,false);
            }
        }
    }
}