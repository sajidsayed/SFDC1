trigger VCEStdAttachmentToSenderTrigger on Attachment (after insert) {

    List<Id> caseIdList = new List<Id>();
    
    for(Attachment vceAttachment : Trigger.New)    
    {
        caseIdList.add(vceAttachment.ParentId);    
    }    
        
    Map<Id,Case> vceCaseMap = new Map<Id,Case>([select Id,RecordTypeId 
                                      from Case where id IN :caseIdList and VCE_Transfer__c = true]);
    
    String vceRecType = VCEStatic__c.getInstance('VCECaseRecordType').Value__c;
        
    List<VCESenderObject__c> vceSenderList = new List<VCESenderObject__c>();
               
    for(Attachment a : Trigger.New)
    {
        Case vceCase = vceCaseMap.get(a.ParentId);
        if(vceCase != null && 
             vceCase.RecordTypeId == vceRecType)
        {
            VCESenderObject__c vceSenderObject = new VCESenderObject__c();
            vceSenderObject.IdToSend__c = a.Id;
            vceSenderList.add(vceSenderObject);
        }
    }
        
    upsert vceSenderList ;
    
}