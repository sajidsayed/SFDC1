/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  08 Oct 2012 	Avinash K       MOJO        Initial Creation.Created this class to include the Asset Trigger logic.
+========================================================================================================================*/

public class SFA_MOJO_AssetTrigger 
{

// setOppIds: Set to hold Opportunity Ids of the Assets being Inserted/Updated
    public static Set<Id> setOppIds = New Set<Id>();

// blnAssetTrigger: Static Boolean variable to ensure the trigger is executed only once in a given context
	public static Boolean blnAssetTrigger = true;


/* setDispositionStatusBeforeInsertUpdate: Method called by the Asset trigger on before insert & before update events to set the 
	value of the Disposition Status field */
	public static void setDispositionStatusBeforeInsert(List<Asset__c> lstTriggerNew)
	{
		if (blnAssetTrigger) 
		{
			blnAssetTrigger = false;
	        if(lstTriggerNew != null)
	        {
	            
	            for (Asset__c a : lstTriggerNew)
	            {
	                a.Disposition_Status__c = 'Installed';
	            }
	        }
	    }
	}
}