trigger AfterDeleteVelocityRuleMembers on Velocity_Rule_Member__c (after delete) {
	new PRM_VPP_DeltaIdentifer().deltaRuleMarking(Trigger.newmap,Trigger.oldmap ); 
}