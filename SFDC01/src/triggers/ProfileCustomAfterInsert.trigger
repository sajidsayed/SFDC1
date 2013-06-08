trigger ProfileCustomAfterInsert on ProfileCustom__c (after insert) {
	
	// process new profiles and set presence indicators where necessary
	AH_ChildObjectPresenceIndicators.ProcessProfileCustomInserts(trigger.new);
}