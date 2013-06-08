trigger ProfileCustomAfterUpdate on ProfileCustom__c (after update) {
	// process the profile updates, setting presence indicators where necessary
	AH_ChildObjectPresenceIndicators.ProcessProfileCustomUpdates(trigger.new, trigger.old);
}