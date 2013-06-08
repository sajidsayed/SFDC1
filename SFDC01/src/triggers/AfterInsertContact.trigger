trigger AfterInsertContact on Contact (after insert) { 
	new PRM_VPP_DeltaIdentifer().deltaContactMarking(Trigger.OldMap,Trigger.NewMap);

}