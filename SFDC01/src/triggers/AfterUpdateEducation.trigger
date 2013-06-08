trigger AfterUpdateEducation on Education__c (before update) { 
    
    new PRM_VPP_DeltaIdentifer().deltaEducationMarking(Trigger.oldMap,Trigger.NewMap);
    
}