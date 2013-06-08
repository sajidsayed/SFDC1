trigger AfterInsertEducationGroupMember on Education_Group_Member__c (after insert) {
	new PRM_VPP_DeltaIdentifer().deltaEducationMasterMarking(Trigger.newmap,Trigger.oldmap ); 
}