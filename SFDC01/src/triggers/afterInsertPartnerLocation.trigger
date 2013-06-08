/*================================================================================
Name      WR       Description
Prasad             This trigger is used for Partner Location  Latitude and Longitude
                   Defect Fix.     
===================================================================================*/
trigger afterInsertPartnerLocation on Partner_Location__c (after insert) {
    PRM_MapLocation.getLatitudenLongitude(Trigger.newMap.keySet());
}