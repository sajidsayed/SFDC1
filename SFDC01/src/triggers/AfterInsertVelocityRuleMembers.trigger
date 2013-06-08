trigger AfterInsertVelocityRuleMembers on Velocity_Rule_Member__c (after insert) {
	new PRM_VPP_DeltaIdentifer().deltaRuleMarking(Trigger.newmap,Trigger.oldmap );
}