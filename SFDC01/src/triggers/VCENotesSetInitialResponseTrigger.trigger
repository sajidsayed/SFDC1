trigger VCENotesSetInitialResponseTrigger on VCECaseNote__c (after insert, after update) {
    List<Case> caseListEMC = new List<Case>();
    List<Task> taskListEMC = new List<Task>();
    List<Id> caseIdList = new List<Id>();
    
    Map<Id,DateTime> caseNoteMap = new Map<Id,DateTime>();
    
    for(VCECaseNote__c note : Trigger.New)
    {
        String noteType = note.Note_Type__c;
        if(noteType != null && 
            (noteType.equalsIgnoreCase('Initial Response')|| 
             noteType.equalsIgnoreCase('Dial Out Connect')))
        {
            caseIdList.add(note.Case__c);
            caseNoteMap.put(note.Case__c,note.Creation_Date__c);
        }   
    }
        
    caseListEMC = [select VCE_Case_Initial_Response__c from Case 
                       where id in :caseIdList and Origin = 'EMC'];

    for(Case c: caseListEMC)
    {
        c.VCE_Case_Initial_Response__c = caseNoteMap.get(c.Id);
    }

    taskListEMC = [select VCE_Task_Initial_Response__c,WhatId from Task 
                where WhatId in :caseIdList and VCE_Assigned_To__c = 'EMC'];

    for(Task t: taskListEMC)
    {
        t.VCE_Task_Initial_Response__c = caseNoteMap.get(t.WhatId);
    }

    if(caseListEMC.size()>0)
        update caseListEMC;
        
    if(taskListEMC.size()>0)
        update taskListEMC;
}