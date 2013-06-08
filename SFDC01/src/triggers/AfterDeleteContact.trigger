trigger AfterDeleteContact on Contact (after delete) {
	new PRM_VPP_DeltaIdentifer().deltaContactMarking(Trigger.OldMap,Trigger.NewMap);
}