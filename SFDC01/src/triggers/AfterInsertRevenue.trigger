trigger AfterInsertRevenue on Revenue__c (after insert) {
	new PRM_VPP_DeltaIdentifer().deltaRevenueMarking(Trigger.oldMap,Trigger.NewMap);
}