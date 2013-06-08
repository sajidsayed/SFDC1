/*================================================================================
Name            WR       Description
Ashwini Gowda   1457     This trigger is used to create Sharing on Objectives to
                1489     Designated Users and Groups. 
Ashwini Gowda            Commented the call to methods for sharing as the relationship 
                         changed from Look up to Master-Detail              
===================================================================================*/
trigger afterUpdateOnObjective on SFDC_Objective__c (after Update) {
    //PRM_CAPVisibility objectiveVisibility = new PRM_CAPVisibility();
    //objectiveVisibility.createObjectiveShareforApproversAndGroups(trigger.new);      
}