trigger ServiceProviderEngagementMapping on Service_Provider_Engagement_Mapping__c (before insert, before update) 
{
    if(Trigger.isInsert)
    {
        AllianceEngagementMapping obj = new AllianceEngagementMapping();
        obj.restrictDuplicateRecordSE(Trigger.New);
      //  obj.insertUpdateAllianceMapping(Trigger.New);
    }
    else
    {
        map<Id,Service_Provider_Engagement_Mapping__c> mapIdServiceEngagement = new map<Id,Service_Provider_Engagement_Mapping__c>(); 
        for(Service_Provider_Engagement_Mapping__c se: Trigger.New)
        {
            Service_Provider_Engagement_Mapping__c oldRecord = Trigger.OldMap.get(se.Id);
            
            if(se.Service_Provider_Engagment_Mapping_Name__c != oldRecord.Service_Provider_Engagment_Mapping_Name__c 
                && se.Service_Provider_Engagment_Mapping_Name__c != null && se.Service_Provider_Engagment_Mapping_Name__c != '')
            {
                mapIdServiceEngagement.put(se.Id,se);
            }
        }
      
   }                    
            
}