trigger LookupRulePriority on Lead_Routing_Rule__c (before insert, before update) {

    MAP_LeadRulePrioirity.LookupRulePriority(trigger.new);

}