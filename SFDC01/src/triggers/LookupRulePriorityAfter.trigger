trigger LookupRulePriorityAfter on Lead_Routing_Rule__c (after insert, after update) {

    MAP_LeadRulePrioirity.LookupRulePriorityAfter(trigger.new);

}