/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER           WR          DESCRIPTION                               
 |  ====            =========           ==          =========== 
 |  28.dec.2012     Krishna Pydavula   212171      To cover the codecoverage for "ValidateEMCinstallrectype" Trigger.
+========================================================================================================================*/
@isTest(seeAllData = true) 
private class ValidateEMCinstallrectype_TC 
{

    static testMethod void ValidateUnitTest() 
    {
    	User u = [Select id,name,email,phone from User where isActive=true and profile.Name='System Administrator' limit 1];
    	system.runAs(u)
  		{	  
    		RecordType rectype=[SELECT id,Name,SobjectType FROM RecordType where isactive = true and SobjectType = 'Asset__c' and name='EMC Install'];
    		 Account account =   new Account(Name='Test Account**',CurrencyIsoCode='USD',Account_Flag__c='Primary',Site_DUNS_Entity__c = '123456',
                                    Global_DUNS_Entity__c = '663399');  
                
                insert account;
                Asset__c oppAssetRecord1 = new Asset__c();
                oppAssetRecord1.Name = 'Asset Test 1';
                oppAssetRecord1.Configuration_Details__c='EMC';
                oppAssetRecord1.Swap_Value__c=789.00;
                oppAssetRecord1.Product_Family__c='Services Only';
                oppAssetRecord1.Total_Raw_Capacity_GB__c = '11';
                oppAssetRecord1.Customer_Name__c=account.id; 
                insert  oppAssetRecord1; 
                
                delete oppAssetRecord1;
    		
  		}  
    }
}