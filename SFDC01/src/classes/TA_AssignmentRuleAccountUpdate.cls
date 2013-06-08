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
+===========================================================================*/
public class TA_AssignmentRuleAccountUpdate 
{
	//method to update the associated account for inserted or updated TA Assignment Rule.
	public void UpdateAccountOnTARuleUpdate(TA_Assignment_Rule__c taRule)
	{
		List<Account> lstAcc= new List<Account> ();
		Set<id> accId= new Set<Id>();
		String strCountry=taRule.Country__c;
		String strState=taRule.State_Or_Province__c;
		String strClassification = taRule.Classification__c;
		if(strCountry=='United States' || strCountry=='Canada')
		{
			lstAcc = [Select id, TA_Assignment_Type__c From Account where TA_Assignment_Rule__c=:taRule.id OR( BillingCountry =:strCountry  AND BillingState =:strState AND EMC_Classification__c =: strClassification) limit 10000];	
		}
		else
		{
			lstAcc = [Select id, TA_Assignment_Type__c  From Account where TA_Assignment_Rule__c=:taRule.id OR(BillingCountry =:strCountry  AND EMC_Classification__c =: strClassification) limit 10000];
		}
		system.debug('ACCOUNT LIST ====>  '+lstAcc);
		if(lstAcc!=null && lstAcc.size()>0)
		{
			for(Account objAcc:lstAcc)
			{
				accId.add(objAcc.id);
			}
			// Calling this method to increase governer limit using future method. 
			TA_AssignmentRuleUpdateAccountOnFuturel.UpdateAccountOnTARuleUpdateFuture(accId);
		}
	}
}