trigger VCETaskShareTrigger on Task (after insert) {
    
    List<Id> caseIdList = new List<Id>();
      
    for(Task t: Trigger.New)
    {
        caseIdList.add(t.WhatId);
    }
    
    String recType = VCEStatic__c.getInstance('VCECaseRecordType').Value__c;
    String connId = VCEStatic__c.getInstance('ConnectionId').Value__c;
    
    Map<Id,Case> caseMap = VCESharingUtil.getCaseMap(caseIdList, recType);
    
    List<PartnerNetworkRecordConnection> partnerNetworkRecordList = new List<PartnerNetworkRecordConnection>();
            
    for(Task t : Trigger.New) {
        Case vceCase = caseMap.get(t.WhatId);
        if(vceCase != null)
            partnerNetworkRecordList.add(VCESharingUtil.newPNRC(connId, t.Id, t.WhatId));
    }
    
    insert partnerNetworkRecordList;
}