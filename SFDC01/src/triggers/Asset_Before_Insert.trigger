/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  26.09.2012      Avinash K       MOJO        Initial Creation.Creating this Trigger to update the value of the Disposition
                                                status field of Asset before insert
+========================================================================================================================*/

trigger Asset_Before_Insert on Asset__c (before insert) 
{
    
    if(Trigger.isInsert && Trigger.isBefore)
    {
        SFA_Mojo_AssetTrigger.setDispositionStatusBeforeInsert(Trigger.New);
    }
}