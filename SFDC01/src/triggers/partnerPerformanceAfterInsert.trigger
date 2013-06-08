trigger partnerPerformanceAfterInsert on Partner_Performance_Rating_by_Field__c (after insert) {
    Set<Id> setOpportunityIds=new Set<Id>();
    for(Partner_Performance_Rating_by_Field__c partPerfObj:Trigger.new)
    {
        setOpportunityIds.add(partPerfObj.Opportunity__c);
    }
    if(setOpportunityIds.size()>0)
    {
        PRM_Partner_Leverage.updatePartnerPerformanceCompleted(setOpportunityIds,true);
        
    }
}