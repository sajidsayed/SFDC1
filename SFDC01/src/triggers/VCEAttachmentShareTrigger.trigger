trigger VCEAttachmentShareTrigger on VCEAttachmentLink__c (after insert) {
    
    List<Id> caseIdList = new List<Id>();
      
    for(VCEAttachmentLink__c a: Trigger.New)
    {
        caseIdList.add(a.Case__c);
    }

    String recType = VCEStatic__c.getInstance('VCECaseRecordType').Value__c;
    String connId = VCEStatic__c.getInstance('ConnectionId').Value__c;
    
    Map<Id,Case> caseMap = VCESharingUtil.getCaseMap(caseIdList, recType);
        
    List<PartnerNetworkRecordConnection> partnerNetworkRecordList = new List<PartnerNetworkRecordConnection>();
      
    for(VCEAttachmentLink__c a : Trigger.New) {
        Case vceCase = caseMap.get(a.Case__c);
        if(vceCase != null)
            partnerNetworkRecordList.add(VCESharingUtil.newPNRC(connId, a.Id, a.Case__c));    
    }
         
    insert partnerNetworkRecordList;
}