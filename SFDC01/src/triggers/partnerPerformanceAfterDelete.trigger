trigger partnerPerformanceAfterDelete on Partner_Performance_Rating_by_Field__c (after delete) {
    Set<Id> setOpportunityIds=new Set<Id>();
    for(Partner_Performance_Rating_by_Field__c partPerfObj:Trigger.old)
    {
        setOpportunityIds.add(partPerfObj.Opportunity__c);
    }
    if(setOpportunityIds.size()>0)
    {
        PRM_Partner_Leverage.updatePartnerPerformanceCompleted(setOpportunityIds,false);
        
    }
}