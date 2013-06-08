trigger AfterDeleteRule on Velocity_Rules__c (after delete) {
			new PRM_VPP_DeltaIdentifer().deltaRuleMarking(Trigger.oldMap,Trigger.newMap);
}