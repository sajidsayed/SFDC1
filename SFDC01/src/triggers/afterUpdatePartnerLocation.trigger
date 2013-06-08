/*================================================================================
Name      WR       Description
Prasad             This trigger is used for Partner Location  Latitude and Longitude
                   Defect Fix.     
Kaustav  198481    Added code for eBusiness SFDC Integration  
Arif               Updated the code for eBusiness req change                 
======================================================================================*/

trigger afterUpdatePartnerLocation on Partner_Location__c (after update) {
   
    Set<Id> PartnerLocIds = new Set<Id>();
    List<Partner_Location__c> lstLocation=new List<Partner_Location__c>();
    for(Partner_Location__c newloc :Trigger.new){
        Partner_Location__c oldLoc= Trigger.oldMap.get(newloc.Id);
        if(oldLoc.City__c!=newLoc.City__c || 
            oldLoc.Street__c!=newLoc.Street__c ||
            oldLoc.Postal_Code__c!=newLoc.Postal_Code__c ||
            oldLoc.Country__c!=newLoc.Country__c ||
            oldLoc.State_Province__c!=newLoc.State_Province__c
          ){
              PartnerLocIds.add(newloc.Id);
          }
          
         if((newloc.eBus_Location_Enabled__c!=oldLoc.eBus_Location_Enabled__c) ||
            ((newloc.eBus_Location_Enabled__c)&& (newloc.eBus_Lead_Admin__c!=oldLoc.eBus_Lead_Admin__c || oldLoc.City__c!=newLoc.City__c || oldLoc.Street__c!=newLoc.Street__c || oldLoc.Postal_Code__c!=newLoc.Postal_Code__c || 
            oldLoc.Country__c!=newLoc.Country__c || oldLoc.State_Province__c!=newLoc.State_Province__c || 
            newloc.Name!=oldLoc.Name || newloc.eBus_Lead_Admin_Name__c!=oldLoc.eBus_Lead_Admin_Name__c || 
            newloc.eBus_Lead_Admin_Email__c!=oldLoc.eBus_Lead_Admin_Email__c || newloc.eBus_Lead_Admin_Phone__c!=oldLoc.eBus_Lead_Admin_Phone__c )))
         {
            lstLocation.add(newloc);            
         }
            
    }
    if(PartnerLocIds.size()>0){
        PRM_MapLocation.getLatitudenLongitude(PartnerLocIds);
    }
    if(lstLocation.size()>0)
    {
        new PartnerInfoIntegrationOperation().insertAccountForLocationUpdateIntoIntegrationLog(lstLocation);
    }

}