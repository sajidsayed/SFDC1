trigger PriorityRelatedRule on Lead_Routing_Rule_Priority__c (before update, before delete) {

    MAP_LeadRulePrioirity rulePriority = new MAP_LeadRulePrioirity();
    if (trigger.isUpdate) {
        rulePriority.CheckRulesonUpdate(trigger.old, trigger.new);
    } else if (trigger.isDelete) {
        rulePriority.CheckRulesonDelete(trigger.old);
    }
}