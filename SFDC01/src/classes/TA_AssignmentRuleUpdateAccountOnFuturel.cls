/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       	DEVELOPER     DESCRIPTION                               
 |  ====       	=========     =========== 
 | 16.12.2011	Shipra Misra  SFA: TA Assignment Rule Functionality enhancements
 |							  This functionality fires whenever a new TA AssignmentRule 
 |							  is inserted or updated.When there exist any matching account for Country, state and Classification.
 |							  Also the functionality would fire for only when one ‘TA_Assignment_Rule’ record 
 |							  is created or updated in single trigger execution. 
 |							  If more records are getting updated via DataLoader at same time, 
 |							  then it is advised to set batch size of data loader to 'one' record.This class is called from 'AfterInsertUpdateTA_AssignmentRule.trigger'.
 |							  This class contains Future method which will be used to increase governer limit using future method. 
+===========================================================================*/
//Making this a future call
public class TA_AssignmentRuleUpdateAccountOnFuturel 
{
	// This method is used to update Account record for TA Assignment Rule as 'Update'.
    // This is the future method, which will takes account ids.
    // This method will be used to increase governer limit using future method. 
    
    @future
	public static void UpdateAccountOnTARuleUpdateFuture(Set<Id>setAccId)
	{
		List<Account> lstAccUpdateForTARule= [Select id, name, TA_Assignment_Type__c from Account where id in:setAccId];
		List<Account> lstAccTobeUpdated=new List<Account>();
		for(Account accTATypeUpdate:lstAccUpdateForTARule)
		{
			accTATypeUpdate.TA_Assignment_Type__c='Update';
			lstAccTobeUpdated.add(accTATypeUpdate);
		}
		Util.UPDATED_FROM_TO_TA_ASSIGNMENT_JOB_FLAG=true;
		update lstAccTobeUpdated;
	}
}