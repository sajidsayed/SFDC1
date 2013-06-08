/*======================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |   
 |  06 MAR 2013   Singla sheriff         234348   Trigger to handle duplicate records received from BRS S2S if the connection is deactived. 
 +=======================================================================================*/
trigger beforeInsertEMCBRSOppty on EMC_BRS_Opportunity__c (before insert) {
    EMCBRS_S2S_Utils s2sUtils = new EMCBRS_S2S_Utils();
    s2sUtils.deleteExistingEMC_BRS_OpportunityRecords( trigger.new);
}