trigger EMCBRSOpptyAfter on EMC_BRS_Opportunity__c (after insert,after update) {
  EMCBRS_S2S_Utils s2sUtils = new EMCBRS_S2S_Utils();
  s2sUtils.updateEMCOpportunityFromBRS(trigger.new);
  if(Trigger.isInsert){
    s2sUtils.updateEMCOpportunityInfo(trigger.new);
  }
  EMC_BRS_S2S_AutoForward autoForward = new EMC_BRS_S2S_AutoForward();
  autoForward.autoForwardToEMCBRS(trigger.new);
}