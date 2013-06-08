trigger AfterDeleteRevenue on Revenue__c (after delete) {
	new PRM_VPP_DeltaIdentifer().deltaRevenueMarking(Trigger.oldMap,Trigger.NewMap);
}