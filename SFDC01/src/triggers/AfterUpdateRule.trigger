trigger AfterUpdateRule on Velocity_Rules__c (after update) {
		new PRM_VPP_DeltaIdentifer().deltaRuleMarking(Trigger.oldMap,Trigger.newMap);
}