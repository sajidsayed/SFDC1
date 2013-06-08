/*
    This trigger will update the record type of the case
    created via S2S sharing.This will be done by comparing 
    created by user to connection user. 
*/
trigger VCECaseSetRecTypeTrigger on Case (before insert) {
    
    String connUser = VCEStatic__c.getInstance('ConnectionUser').Value__c;
    String recType = VCEStatic__c.getInstance('VCECaseRecordType').Value__c;
    
    for(Case c: Trigger.New)
    {
       if(UserInfo.getUserId() == connUser)
       {
            c.RecordTypeId = recType;
       }   
    }
}