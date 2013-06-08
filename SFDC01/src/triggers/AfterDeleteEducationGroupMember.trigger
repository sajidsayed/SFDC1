trigger AfterDeleteEducationGroupMember on Education_Group_Member__c (after delete) {
	new PRM_VPP_DeltaIdentifer().deltaEducationMasterMarking(Trigger.newmap,Trigger.oldmap ); 
}