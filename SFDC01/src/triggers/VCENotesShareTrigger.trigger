trigger VCENotesShareTrigger on VCECaseNote__c (after insert) {
    
    List<Id> caseIdList = new List<Id>();
      
    for(VCECaseNote__c n: Trigger.New)
    {
        caseIdList.add(n.Case__c);
    }
    
    String recType = VCEStatic__c.getInstance('VCECaseRecordType').Value__c;
    String connId = VCEStatic__c.getInstance('ConnectionId').Value__c;
    
    Map<Id,Case> caseMap = VCESharingUtil.getCaseMap(caseIdList, recType);
                                
    List<PartnerNetworkRecordConnection> partnerNetworkRecordList = new List<PartnerNetworkRecordConnection>();
        
    for(VCECaseNote__c n : Trigger.New) {
        Case vceCase = caseMap.get(n.Case__c) ;
        if(vceCase != null)
            partnerNetworkRecordList.add(VCESharingUtil.newPNRC(connId, n.Id, n.Case__c));
    }
    
    insert partnerNetworkRecordList;
}