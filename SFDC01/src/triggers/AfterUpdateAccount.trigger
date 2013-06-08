trigger AfterUpdateAccount on Account (after update) {
	new PRM_VPP_DeltaIdentifer().deltaAccountMarking(Trigger.oldMap,Trigger.NewMap);

	

}