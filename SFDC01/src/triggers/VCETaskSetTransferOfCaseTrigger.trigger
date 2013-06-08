/*
    This trigger will be used to set the transfer field on parent
    case object if the task is assigned to EMC or the case origin is EMC.
*/
trigger VCETaskSetTransferOfCaseTrigger on Task (before insert) 
{
    List<Id> caseIdList = new List<Id>();
 
    String taskRecType = VCEStatic__c.getInstance('VCETaskRecordType').Value__c;
    String connUser = VCEStatic__c.getInstance('ConnectionUser').Value__c;
        
    for(Task vceTask: Trigger.New)
    {
        if(UserInfo.getUserId() == connUser)   
        {
            vceTask.RecordTypeId = taskRecType;
        }
        if(vceTask.RecordTypeId == taskRecType)
        {
            caseIdList.add(vceTask.WhatId);
        }   
    }
 
    if(caseIdList.size()>0)
    {
        Map<Id,Case> vceCaseMap = new Map<Id,Case>([select Id,RecordTypeId,
                VCE_Transfer__c,Origin from Case where id IN :caseIdList]);

    caseIdList.clear();     
 
        List<Case> updateCaseList = new List<Case>(); 
                        
        for(Task vceTask : Trigger.New)
        {
            Case vceCase = vceCaseMap.get(vceTask.WhatId); 
            if(vceCase!= null)
            {
                if(vceCase.VCE_Transfer__c == true ||
                   vceTask.VCE_Assigned_To__c == 'EMC')
                {
                    vceTask.Transfer__c = true;
                }
                if( vceCase.VCE_Transfer__c == false &&
                    (vceTask.VCE_Assigned_To__c == 'EMC'))
                {
                    vceCase.VCE_Transfer__c = true;
                    updateCaseList.add(vceCase);
                    caseIdList.add(vceCase.id);
                }
            }
        }
    
    List <Task> siblings = new List<Task>([select Id,Transfer__c,WhatId from Task where WhatId in :caseIdList and Transfer__c = false]);
        
        for(Task siblingTask : siblings)
        {
            siblingTask.Transfer__c = true;
        }
            
        if(updateCaseList.size()>0)
        {
            update updateCaseList;    
        }

        if(siblings.size()>0)
        {
            update siblings;
        }
    }
}