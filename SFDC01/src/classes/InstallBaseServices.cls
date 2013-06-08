/*
 * Class        : InstallBaseServices
 * Developer/Org: Ramón Muñoz/Bluewolf
 * Created      : Sep 08, 2010
 * Objective    : Services class for Install_Base__c object  
 *				  Contains business logic that applies to any Install Base record or set of records
*/
public class InstallBaseServices
{
	//This method is called from InstallBaseTrigger and updates the Install_Base_Products__c and Install_Base_Families__c
	//multi-select picklists on parent account records
	public static void updateAccountInstallBaseProductsAndFamilies(Install_Base__c[] ibs)
	{
		if(ibs != null && ibs.size() > 0)
		{
			//Get account IDs
			Set<Id> accountIds = new Set<Id>();
			for(Install_Base__c ib : ibs)
			{
				if(ib.Account__c != null) accountIds.add(ib.Account__c);
			}
			//Query Install Base records and update picklists
			Account[] accountsToUpdate = new Account[]{};
			for(Account a : [select Id,
					(select Family__c, Product_Line__c from Install_Base__r order by Product_Line__c, Family__c)
					from Account
					where Id in :accountIds])
			{
				a.Install_Base_Products__c = '';
				a.Install_Base_Families__c = '';
				//Use sets to only include distinct values
				Set<String> products = new Set<String>(), families = new Set<String>();
				for(Install_Base__c ib : a.Install_Base__r)
				{
					if(ib.Product_Line__c != null && !products.contains(ib.Product_Line__c) && products.size() <= 100)
					{
						products.add(ib.Product_Line__c);
						a.Install_Base_Products__c += ib.Product_Line__c + ';';
					}
					if(ib.Family__c != null && !families.contains(ib.Family__c) && families.size() <= 100)
					{
						families.add(ib.Family__c);
						a.Install_Base_Families__c += ib.Family__c + ';';
					}
				}
				//Only add account to update list if either picklist was modified
				if(a.Install_Base_Products__c.length() > 0 || a.Install_Base_Families__c.length() > 0)
					accountsToUpdate.add(a);
			}
			update accountsToUpdate;
		}
	}
}