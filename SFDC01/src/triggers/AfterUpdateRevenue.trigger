trigger AfterUpdateRevenue on Revenue__c (after update) {
	new PRM_VPP_DeltaIdentifer().deltaRevenueMarking(Trigger.oldMap,Trigger.NewMap);
}