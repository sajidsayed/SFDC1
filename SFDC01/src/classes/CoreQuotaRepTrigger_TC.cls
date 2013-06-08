/*=====================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  23.11.2012      Avinash K       212738      Initial Creation.  Test class for CoreQuotaRepTrigger Trigger.
 +=====================================================================================================================*/
@isTest(SeeAllData = true)
private class CoreQuotaRepTrigger_TC 
{
    static testMethod void CoreQuoteRepTriggerTest() 
    {
    	try
    	{
    		Account account = [Select id, name 
    			From Account
    			Limit 1];
    		User tempUsr = [Select id, name 
    			From User
    			Where isActive = true
    			Limit 1];
	        if(account != null && tempUsr != null)
	        {
	        	Core_Quota_Rep__c cqr = new Core_Quota_Rep__c(Account_ID__c = account.id, name = 'Test', Badge_ID__c = '123', 
				District_Name__c = 'CA', SFDC_User_ID__c = tempUsr.id);
				insert cqr;

				delete cqr;
			}
		}
		catch(Exception e)
		{
			system.debug('#### Exception occured in test class : CoreQuotaRepTrigger_TC');
		}

    }
}