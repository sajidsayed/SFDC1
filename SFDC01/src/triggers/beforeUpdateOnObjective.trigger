/*================================================================================
Name            WR       Description
Ashwini Gowda    -       This trigger to populate Partner Approver on Objective 
                         associated to CAP.
===================================================================================*/
trigger beforeUpdateOnObjective on SFDC_Objective__c (before insert, before update) {
    PRM_CAPLockProcess capLockProcess = new PRM_CAPLockProcess();
    capLockProcess.populatePartnerApproverOnObjective(trigger.new);                                                             
}