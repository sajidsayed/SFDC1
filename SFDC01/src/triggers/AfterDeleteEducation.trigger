trigger AfterDeleteEducation on Education__c (after delete) {
   new PRM_VPP_DeltaIdentifer().deltaEducationMarking(Trigger.oldMap,Trigger.NewMap);
}