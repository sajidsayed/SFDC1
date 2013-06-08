trigger LookupQueueId on Lead_Routing_Rule__c (before insert, before update) {

    MAP_LeadRulePrioirity.LookupQueueId(trigger.new);

}