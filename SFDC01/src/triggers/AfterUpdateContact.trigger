trigger AfterUpdateContact on Contact (after update) {
	new PRM_VPP_DeltaIdentifer().deltaContactMarking(Trigger.OldMap,Trigger.NewMap);
}