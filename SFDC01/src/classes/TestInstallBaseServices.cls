/*
 * Class        : TestInstallBaseServices
 * Developer/Org: Ramón Muñoz/Bluewolf
 * Created      : Nov 2, 2010
 * Objective    : Test class to iron out the service functionalities   
 *				  for InstallBaseServices
*/
@isTest
private class TestInstallBaseServices
{
	static Account a;
	static void setupData()
	{
    	//Set up test data
    	a = new Account();
    	a.Name = 'somedummyname';
    	a.BillingState = 'somedummystate';
    	a.BillingCountry = 'somedummycountry';
    	a.Industry__c = 'somedummyindustry';
    	a.EMC_Classification__c = 'somedummyclass';
    	insert a;
	}
	static testMethod void updateAccountInstallBaseProductsAndFamilies_NullParam_returnsNothing()
	{
    	Integer rowsUpdatedBefore = Limits.getDmlRows();
    	InstallBaseServices.updateAccountInstallBaseProductsAndFamilies(null);
    	Integer rowsUpdatedAfter = Limits.getDmlRows();
        System.assertEquals(rowsUpdatedAfter, rowsUpdatedBefore, 'DML rows detected when none should have been');
	}
	static testMethod void updateAccountInstallBaseProductsAndFamilies_EmptyParam_returnsNothing()
	{
    	Integer rowsUpdatedBefore = Limits.getDmlRows();
    	InstallBaseServices.updateAccountInstallBaseProductsAndFamilies(new Install_Base__c[]{});
    	Integer rowsUpdatedAfter = Limits.getDmlRows();
        System.assertEquals(rowsUpdatedAfter, rowsUpdatedBefore, 'DML rows detected when none should have been');
	}
	static testMethod void updateAccountInstallBaseProductsAndFamilies_ValidParam_singleRecord_returnsNothing()
	{
		setupData();
		Install_Base__c ib = new Install_Base__c();
		ib.Account__c = a.Id;
		ib.Family__c = 'Family';
		ib.Product_Line__c = 'Prod Line';
		insert ib;
		
    	Integer rowsUpdatedBefore = Limits.getDmlRows();
    	InstallBaseServices.updateAccountInstallBaseProductsAndFamilies(new Install_Base__c[]{ib});
    	Integer rowsUpdatedAfter = Limits.getDmlRows();
        System.assertEquals(rowsUpdatedAfter, rowsUpdatedBefore + 1, 'DML rows detected when none should have been');
        //Requery for updated account fields
        Account testAccount = [select Id, Install_Base_Families__c, Install_Base_Products__c from Account where Id = :a.Id];
        System.assertEquals('Family', testAccount.Install_Base_Families__c);
        System.assertEquals('Prod Line', testAccount.Install_Base_Products__c);
	}
	static testMethod void updateAccountInstallBaseProductsAndFamilies_ValidParam_multiRecord_returnsNothing()
	{
		setupData();
		Install_Base__c[] ibs = new Install_Base__c[]{};
		for(Integer i=0; i<10; i++)
		{
			Install_Base__c ib = new Install_Base__c();
			ib.Account__c = a.Id;
			ib.Family__c = 'Family' + i;
			ib.Product_Line__c = 'Prod Line' + i;
			ibs.add(ib);
		}
		insert ibs;
		
    	Integer rowsUpdatedBefore = Limits.getDmlRows();
    	InstallBaseServices.updateAccountInstallBaseProductsAndFamilies(ibs);
    	Integer rowsUpdatedAfter = Limits.getDmlRows();
        System.assertEquals(rowsUpdatedAfter, rowsUpdatedBefore + 1, 'DML rows detected when none should have been');
        //Requery for updated account fields
        Account testAccount = [select Id, Install_Base_Families__c, Install_Base_Products__c from Account where Id = :a.Id];
        System.assertEquals('Family0;Family1;Family2;Family3;Family4;Family5;Family6;Family7;Family8;Family9', testAccount.Install_Base_Families__c);
        System.assertEquals('Prod Line0;Prod Line1;Prod Line2;Prod Line3;Prod Line4;Prod Line5;Prod Line6;Prod Line7;Prod Line8;Prod Line9', testAccount.Install_Base_Products__c);
	}
}