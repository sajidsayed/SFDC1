/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  02/01/2012    Shalabh Sharma           Trigger to map chatter post comments on Opportunity to Opportunity Reporting                                             
 +==================================================================================================================**/

trigger Presales_afterInsertBeforeDeleteOfFeedComment on FeedComment (after insert, before delete) {
    Presales_OpportunityReporting objAttmt= new Presales_OpportunityReporting();
    if(trigger.isInsert){
        objAttmt.mapChatterPostComments(trigger.newMap,false);
    }
}