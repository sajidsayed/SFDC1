/*
    This trigger will be used to share the case record
    originated in EMC only if the record type is VCE.
*/

trigger VCECaseShareTrigger on Case (after insert) {
    List<PartnerNetworkRecordConnection> partnerNetworkRecordList = new List<PartnerNetworkRecordConnection>();
    
    String vceRecType = VCEStatic__c.getInstance('VCECaseRecordType').Value__c;
    String connId = VCEStatic__c.getInstance('ConnectionId').Value__c;
    
    for(Case c : Trigger.new) {
        if(c.RecordTypeId == vceRecType)
        {   
            PartnerNetworkRecordConnection newrecord = new PartnerNetworkRecordConnection();
            newrecord.ConnectionId = connId;
            newrecord.LocalRecordId = c.Id; 
            // Added as per Josh's instruction : Start
            // shares all the related child records
            newrecord.SendClosedTasks = true;
            newrecord.SendOpenTasks = true;
            newrecord.RelatedRecords = 'VCECaseNote__c,Attachment,VCEAttachmentLink__c';
            // Added as per Josh's instruction : End
            partnerNetworkRecordList.add(newrecord);    
        }
    }
    insert partnerNetworkRecordList;
}