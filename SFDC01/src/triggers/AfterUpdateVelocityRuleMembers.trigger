trigger AfterUpdateVelocityRuleMembers on Velocity_Rule_Member__c (after update) {
	new PRM_VPP_DeltaIdentifer().deltaRuleMarking(Trigger.newmap,Trigger.oldmap );
}