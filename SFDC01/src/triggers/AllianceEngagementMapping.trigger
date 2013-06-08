/*====================================================================================================================+

Created By      :   Avinash K, EMC Application Developer
Created Date    :   6 July 2012
Descripion      :   Trigger excutes before insert and update of an Alliance Engagement Mapping record
                    and populates the Alliance_Engagement_URL__c field with the Document URL from the unique document name provided
                    in the Alliance_Engagement_Document_Name__c field

Modified By   : Hemavathi N M
Modified Date : 12 Nov 2012
Description   : Dec Release - Removed the functionality of auto populating Alliance_Engagement_URL__c field with the Document URL from the unique document name provided
                in the Alliance_Engagement_Document_Name__c field
 +====================================================================================================================*/

trigger AllianceEngagementMapping on Alliance_Engagement_Mapping__c (before insert, before update) 
{
    if(Trigger.isInsert)
    {
        AllianceEngagementMapping obj = new AllianceEngagementMapping();
        obj.restrictDuplicateRecord(Trigger.New);
       //Dec Release
      //  obj.insertUpdateAllianceMapping(Trigger.New);
    }
    else
    {
        map<Id,Alliance_Engagement_Mapping__c> mapIdAllianceEngagement = new map<Id,Alliance_Engagement_Mapping__c>(); 
        for(Alliance_Engagement_Mapping__c ae: Trigger.New)
        {
            Alliance_Engagement_Mapping__c oldRecord = Trigger.OldMap.get(ae.Id);
            
            if(ae.Alliance_Engagement_Document_Name__c != oldRecord.Alliance_Engagement_Document_Name__c 
                && ae.Alliance_Engagement_Document_Name__c != null && ae.Alliance_Engagement_Document_Name__c != '')
            {
                mapIdAllianceEngagement.put(ae.Id,ae);
            }
        }
        /*
        #### Start Dec Release
        if(!mapIdAllianceEngagement.isempty())
        {
            AllianceEngagementMapping obj = new AllianceEngagementMapping();
            obj.insertUpdateAllianceMapping(mapIdAllianceEngagement.values());  
        }
        #### End Dec Release
        */
   }                    
            
}