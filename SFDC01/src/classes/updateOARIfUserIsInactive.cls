/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       	DEVELOPER     DESCRIPTION                               
 |  ====       	=========     =========== 
 | 22.12.2011	Shipra Misra  Oppty OAR: Trigger when any user record is made inactive.It should Deactivate all the OAR's where these User's are present as Resource.
+===========================================================================*/

public class updateOARIfUserIsInactive 
{
	@future
	public static void deactivateOAR(Set<id> setUserId)
	{
		List<Opportunity_Assignment_Rule__c> lstOARUpdate= new List<Opportunity_Assignment_Rule__c>();
		List<Opportunity_Assignment_Rule__c> lstOARToBeDeactivated = new List<Opportunity_Assignment_Rule__c>([Select id, name,Resource_Name__c from Opportunity_Assignment_Rule__c where Resource_Name__c in :setUserId]);
		for(Opportunity_Assignment_Rule__c OARobj:lstOARToBeDeactivated)
		{
			OARobj.Active__c=false;
			lstOARUpdate.add(OARobj);
		}
		if(lstOARUpdate.size()>0 && lstOARUpdate!=null)
		{
			update lstOARUpdate;
		}
	 }
}