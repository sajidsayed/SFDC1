/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  27.10.2012      Smitha Thomas       MOJO        Initial Creation.Creating this test class to unit test 
                                                SFA_MOJO_CreateOpptyController class.
+========================================================================================================================*/ 
@isTest(seeAllData = true) 
private class SFA_MOJO_CreateOpptyController_TC 
{
	 static testMethod void createOpptyTest()
    {    	
    	
    	List<Account> lstAccount = [Select id, Account_Flag__c From Account Where Account_Flag__c = 'Primary'Limit 1];

        Account acc;
        
        List<Account> lstAccount1 = [Select id, Account_Flag__c From Account Where Account_Flag__c = 'Primary' and id not in:lstAccount Limit 1];
        Account acc1;
        
        Asset__c asset1 = new Asset__c();
        Asset__c asset2 = new Asset__c();
        Asset__c asset3 = new Asset__c();               
        Asset__c asset4 = new Asset__c();
        Asset__c asset5 = new Asset__c();
        if (lstAccount != null && lstAccount.size() > 0) 
        {
            acc = lstAccount.get(0);
        }
        
        if (lstAccount1 != null && lstAccount1.size() > 0) 
        {
            acc1 = lstAccount1.get(0);
        }
        
        List<Opportunity> lstOpportunityActive = [Select id, name, Closed_Reason__c, Close_Comments__c, CloseDate 
            From Opportunity
            Where StageName = 'Upside'
            Limit 1];    
            
        List<Opportunity> lstOpportunityClosed = [Select id, name, Closed_Reason__c, Close_Comments__c, CloseDate 
            From Opportunity
            Where StageName = 'Closed' Limit 1];
        
        Opportunity oppClosed;
        Opportunity oppActive;
        
        if (lstOpportunityClosed != null && lstOpportunityClosed.size() > 0) 
        {
            oppClosed = lstOpportunityClosed.get(0);
        }
        if (lstOpportunityActive != null && lstOpportunityActive.size() > 0) 
        {
            oppActive = lstOpportunityActive.get(0);
        }
        
        List<Asset__c> lstAssets = new List<Asset__c>();
        List<Asset__c> lstAssets1 = new List<Asset__c>();
        List<Asset__c> lstAssets2 = new List<Asset__c>(); 
        List<Asset__c> lstAssets3 = new List<Asset__c>();  
        List<Opportunity_Asset_Junction__c> lstOppAssetJunction = new List<Opportunity_Asset_Junction__c>();     
        if(acc != null && acc.id != null && acc1 != null && acc1.id != null)
        {
        	asset1 = new Asset__c(name = 'Test 1', Customer_Name__c = acc.id);
        	asset2 = new Asset__c(name = 'Test 2', Customer_Name__c = acc1.id);
        	
        	lstAssets.add(asset1);
            lstAssets.add(asset2);
         	
         	Test.startTest();
            insert lstAssets;
            
            ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(lstAssets);               
            setCon.setSelected((List<SObject>)lstAssets);                    
            SFA_MOJO_CreateOpptyController validateController = new SFA_MOJO_CreateOpptyController(setCon);        
            validateController.ValidateOpty();
            
            asset3 = new Asset__c(name = 'Test 1', Customer_Name__c = acc.id);
            asset4 = new Asset__c(name = 'Test 1', Customer_Name__c = acc.id); 
            lstAssets1.add(asset3);
            lstAssets1.add(asset4);
            insert lstAssets1;       	
        	Opportunity_Asset_Junction__c oaj = new Opportunity_Asset_Junction__c(Related_Asset__c = asset3.id, Related_Opportunity__c = oppClosed.id);
        	lstOppAssetJunction.add(oaj);
        	Opportunity_Asset_Junction__c oaj1 = new Opportunity_Asset_Junction__c(Related_Asset__c = asset4.id, Related_Opportunity__c = oppActive.id);
        	lstOppAssetJunction.add(oaj1);
        	insert lstOppAssetJunction;
        	
            ApexPages.StandardSetController setCon1 = new ApexPages.StandardSetController(lstAssets1);               
            setCon1.setSelected((List<SObject>)lstAssets1);                    
            SFA_MOJO_CreateOpptyController validateController1 = new SFA_MOJO_CreateOpptyController(setCon1);        
            validateController1.ValidateOpty();
            validateController1.CreateOpty();
            
            asset5 = new Asset__c(name = 'Test 1', Customer_Name__c = acc.id);
            lstAssets2.add(asset5);
            insert lstAssets2;
            ApexPages.StandardSetController setCon2 = new ApexPages.StandardSetController(lstAssets2);               
            setCon2.setSelected((List<SObject>)lstAssets2);                    
            SFA_MOJO_CreateOpptyController validateController2 = new SFA_MOJO_CreateOpptyController(setCon2);                    
            validateController2.CreateOpty();
            validateController2.ValidateOpty();
            
            ApexPages.StandardSetController setCon3 = new ApexPages.StandardSetController(lstAssets3);               
            setCon3.setSelected((List<SObject>)lstAssets3);                    
            SFA_MOJO_CreateOpptyController validateController3 = new SFA_MOJO_CreateOpptyController(setCon3);                    
            validateController3.CreateOpty();
            validateController3.ValidateOpty();
            
            test.stopTest();
            
        }
    }
}