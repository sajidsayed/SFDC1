trigger AfterUpdateEducationGroupMember on Education_Group_Member__c (after update) {
	new PRM_VPP_DeltaIdentifer().deltaEducationMasterMarking(Trigger.newmap,Trigger.oldmap ); 
}