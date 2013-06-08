/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  10 Oct 2012     Avinash K       MOJO        Initial Creation.Creating this Trigger to call a class that posts a chatter feed
                                                on Opportunity when the Regitration Id field is updated.
+========================================================================================================================*/



trigger GFSTradeInSwapAfterUpdate on Trade_Ins_Competitive_Swap__c (after update) 
{
    if(Trigger.New != null)
    	SFA_MOJO_GFSTradeInSwapTriggerCode.postToChatter(Trigger.NewMap, Trigger.OldMap);
}