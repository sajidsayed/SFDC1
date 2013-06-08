trigger AfterDeleteGrouping on Account_Groupings__c (after delete) {
	PRM_PAN_VPP_Operations PANVPPOBJ = new PRM_PAN_VPP_Operations();
	if(trigger.isDelete){
		PANVPPOBJ.RollupSpecialitiesPanlevel(Trigger.old);
	}  
}