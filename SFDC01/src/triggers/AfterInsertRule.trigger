trigger AfterInsertRule on Velocity_Rules__c (after insert) {
			new PRM_VPP_DeltaIdentifer().deltaRuleMarking(Trigger.oldMap,Trigger.newMap);
}