trigger AfterInsertEducation on Education__c (after insert) {
   new PRM_VPP_DeltaIdentifer().deltaEducationMarking(Trigger.oldMap,Trigger.NewMap);
}