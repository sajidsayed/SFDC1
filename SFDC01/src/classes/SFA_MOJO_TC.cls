/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  22.09.2012      Avinash K       MOJO        Initial Creation.Creating this test class to unit test 
                                                SFA_MOJO_MassDeleteAssetController class.
    22.09.2012      Avinash K       MOJO        Added RelatedOpportunitiesTest() test method to increase coverage for
                                                SFA_MOJO_RelatedOpportunitiesController class
    22.09.2012      Avinash K       MOJO        Updated the insertAndMassDeleteAssetAndOppJunctionTest() Test mrthod to increase
                                                coverage
+========================================================================================================================*/

@isTest(seeAllData = true) 
private class SFA_MOJO_TC 
{

    static testMethod void insertAndMassDeleteAssetAndOppJunctionTest()
    {
        List<Account> lstAccount = [Select id, Account_Flag__c 
            From Account
            Where Account_Flag__c = 'Primary'
            Limit 1];

        Account acc;
        
        Asset__c asset1 = new Asset__c();
        Asset__c asset2 = new Asset__c();
        Asset__c asset3 = new Asset__c();
        
        if (lstAccount != null && lstAccount.size() > 0) 
        {
            acc = lstAccount.get(0);
        }

        List<Opportunity> lstOpportunityClosedOther = [Select id, name, Closed_Reason__c, Close_Comments__c, CloseDate 
            From Opportunity
            Where StageName = 'Closed' AND Closed_Reason__c <> 'Competition'
            Limit 1];

        List<Opportunity> lstOpportunityClosedCompetition = [Select id, name, Closed_Reason__c, Close_Comments__c, CloseDate 
            From Opportunity
            Where StageName = 'Closed' AND Closed_Reason__c = 'Competition'
            Limit 1];

        List<Opportunity> lstOpportunityBooked = [Select id, name, Closed_Reason__c, Close_Comments__c, CloseDate 
            From Opportunity
            Where StageName = 'Booked'
            Limit 1];
            
        List<Opportunity> lstOpportunityUpside = [Select id, name, Closed_Reason__c, Close_Comments__c, CloseDate 
            From Opportunity
            Where StageName = 'Upside'
            Limit 1];    


        Opportunity oppClosedCompetition;
        Opportunity oppClosedOther;
        Opportunity oppBooked;
        Opportunity oppNormal;
        
        List<Opportunity_Asset_Junction__c> lstOppAssetJunction = new List<Opportunity_Asset_Junction__c>();

        if (lstOpportunityClosedCompetition != null && lstOpportunityClosedCompetition.size() > 0) 
        {
            oppClosedCompetition = lstOpportunityClosedCompetition.get(0);
        }

        List<Asset__c> lstAssets = new List<Asset__c>();
        List<Asset__c> lstAssets2 = new List<Asset__c>();
        
        if(acc != null && acc.id != null)
        {
            asset1 = new Asset__c(name = 'Test 1', Customer_Name__c = acc.id);
            asset2 = new Asset__c(name = 'Test 1', Customer_Name__c = acc.id, Disposition_Status__c = 'Installed');
            asset3 = new Asset__c(name = 'Test 1', Customer_Name__c = acc.id);

            lstAssets.add(asset1);
            lstAssets.add(asset2);

            lstAssets2.add(asset3);
            
            test.startTest();
            insert lstAssets;
            insert lstAssets2;
    
            
            ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(lstAssets);
            
            setCon.setSelected((List<SObject>)lstAssets);
                
            SFA_MOJO_MassDeleteAssetController deleteController = new SFA_MOJO_MassDeleteAssetController(setCon);
    
            deleteController.DeleteAssets();

            Opportunity_Asset_Junction__c oaj = new Opportunity_Asset_Junction__c(Related_Asset__c = asset3.id, Related_Opportunity__c = oppClosedCompetition.id);

            lstOppAssetJunction.add(oaj);

            if (lstOpportunityClosedOther != null && lstOpportunityClosedOther.size() > 0) 
            {
                oppClosedOther = lstOpportunityClosedOther.get(0);
            }

            Opportunity_Asset_Junction__c oaj0 = new Opportunity_Asset_Junction__c(Related_Asset__c = asset3.id, Related_Opportunity__c = oppClosedOther.id);

            lstOppAssetJunction.add(oaj0);


            if (lstOpportunityBooked != null && lstOpportunityBooked.size() > 0) 
            {
                oppBooked = lstOpportunityBooked.get(0);
            }

            Opportunity_Asset_Junction__c oaj1 = new Opportunity_Asset_Junction__c(Related_Asset__c = asset3.id, Related_Opportunity__c = oppBooked.id);

            lstOppAssetJunction.add(oaj1);

            if (lstOpportunityUpside != null && lstOpportunityUpside.size() > 0) 
            {
                oppNormal = lstOpportunityUpside.get(0);
            }

            Opportunity_Asset_Junction__c oaj2 = new Opportunity_Asset_Junction__c(Related_Asset__c = asset3.id, Related_Opportunity__c = oppNormal.id);

            lstOppAssetJunction.add(oaj2);

            insert lstOppAssetJunction;
            update lstOppAssetJunction;

            ApexPages.StandardSetController setCon1 = new ApexPages.StandardSetController(lstAssets2);
        
            setCon1.setSelected((List<SObject>)lstAssets2);
                
            SFA_MOJO_MassDeleteAssetController deleteController1 = new SFA_MOJO_MassDeleteAssetController(setCon1);
    
            deleteController1.DeleteAssets();

            Asset__c asset4 = new Asset__c(name = 'Test 1', Customer_Name__c = acc.id);
            insert asset4;

            if (lstOpportunityBooked != null && lstOpportunityBooked.size() > 0) 
            {
                oppBooked = lstOpportunityBooked.get(0);
            }

            oaj = new Opportunity_Asset_Junction__c(Related_Asset__c = asset4.id, Related_Opportunity__c = oppBooked.id);

            insert oaj;
            update oaj;
     
/////////
            
            oppNormal.CloseDate = System.TODAY();
            oppNormal.Related_Opportunity__c = oppBooked.id;

            oppNormal.StageName = 'Strong Upside';

            oppNormal.StageName = 'Booked';

            oppNormal.StageName = 'Closed';
            oppNormal.Closed_Reason__c = 'Competition';
            oppNormal.Close_Comments__c = 'test';
            oppNormal.SO_Number__c  = '12345';

            Trade_Ins_Competitive_Swap__c trade = new Trade_Ins_Competitive_Swap__c();
            trade.Related_Opportunity__c = oppNormal.id;
            trade.Swap_Value__c = 1;
            insert trade;

            update oppNormal;

            test.stopTest();

        }
    }

    static testMethod void TradeInAndOppAfterUpdateTest()
    {
        test.startTest();

        List<Opportunity> lstOpportunityUpside = [Select id, name, Closed_Reason__c, Close_Comments__c, CloseDate 
            From Opportunity
            Where StageName = 'Upside'
            Limit 1];

        Opportunity oppNormal;

        if (lstOpportunityUpside != null && lstOpportunityUpside.size() > 0) 
        {
            oppNormal = lstOpportunityUpside.get(0);
        }

        Trade_Ins_Competitive_Swap__c trade = new Trade_Ins_Competitive_Swap__c();
        trade.Related_Opportunity__c = oppNormal.id;
        trade.Swap_Value__c = 1;
        insert trade;

        trade.Registration_ID__c = '122';
        update trade;

        List<Account> lstAccount = [Select id, Account_Flag__c 
            From Account
            Where Account_Flag__c = 'Primary'
            Limit 1];

        Account acc;

        if (lstAccount != null && lstAccount.size() > 0) 
        {
            acc = lstAccount.get(0);
        }

        Asset__c asset1 = new Asset__c(name = 'Test 1', Customer_Name__c = acc.id);
        insert asset1;

        Opportunity_Asset_Junction__c oaj = new Opportunity_Asset_Junction__c(Related_Asset__c = asset1.id, Related_Opportunity__c = oppNormal.id);

        insert oaj;

        oppNormal.SO_Number__c = '12345';
        oppNormal.CloseDate = System.TODAY();
        oppNormal.StageName = 'Booked';
        update oppNormal;


        test.stopTest();



    }

    static testMethod void RelatedOpportunitiesTest()
    {
        test.startTest();

        List<Account> lstAccount = [Select id, Account_Flag__c 
            From Account
            Where Account_Flag__c = 'Primary'
            Limit 1];

        Account acc;

        if (lstAccount != null && lstAccount.size() > 0) 
        {
            acc = lstAccount.get(0);
        }

        Asset__c asset1 = new Asset__c(name = 'Test 1', Customer_Name__c = acc.id);
        insert asset1; 

        List<Opportunity> lstOpportunityUpside = [Select id, name, Closed_Reason__c, Close_Comments__c, CloseDate 
            From Opportunity
            Where StageName = 'Upside'
            Limit 1];

        Opportunity oppNormal;

        if (lstOpportunityUpside != null && lstOpportunityUpside.size() > 0) 
        {
            oppNormal = lstOpportunityUpside.get(0);
        }

        Opportunity_Asset_Junction__c oaj = new Opportunity_Asset_Junction__c(Related_Asset__c = asset1.id, Related_Opportunity__c = oppNormal.id);

        insert oaj;

        ApexPages.currentpage().getParameters().put('Id',asset1.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(asset1);
        SFA_MOJO_RelatedOpportunitiesController relatedController = new SFA_MOJO_RelatedOpportunitiesController(con);
        List<Opportunity> lstOpps = relatedController.getOppsDetails();
        test.stopTest();
    }
}