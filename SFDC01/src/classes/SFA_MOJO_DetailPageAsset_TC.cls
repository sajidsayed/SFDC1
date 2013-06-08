/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class SFA_MOJO_DetailPageAsset_TC {

      static testMethod void RelatedAssetTest()
    {
        try
        {
            test.startTest();

            //Insert Account.
       
        
         Account acc = new Account(Name = 'Test Account Asset' 
                                ,CurrencyIsoCode='USD'
                                ,Status__c = 'A'
                                ,Account_Flag__c='Primary'
                                ,BillingPostalCode='1000'
                                ,BillingCountry='United States'
                                ,Reporting_Segmentation_Group__c='Global Alliances'
                                ,PROFILED_ACCOUNT_FLAG__c=true
                                ,Customer_Segment__c='Enterprise Tier 1'
                               );
        insert acc;
        /* Account acc =   new Account(Name='Test Account**',CurrencyIsoCode='USD',Account_Flag__c='Primary',Site_DUNS_Entity__c = '123456',
                            Global_DUNS_Entity__c = '663399');  
            List<Account> lstAccount = [Select id, Account_Flag__c 
                From Account
                Where Account_Flag__c ='Primary'
                Limit 1];

            Account acc;

            if (lstAccount != null && lstAccount.size() > 0) 
            {
                acc = lstAccount.get(0);
            }
*/
            
            List<Opportunity> lstOpportunityUpside = [Select id, name, Closed_Reason__c, Close_Comments__c, CloseDate 
                From Opportunity
                Where StageName = 'Upside'
                Limit 1];

            Opportunity oppNormal;
            Asset__c asset1 = new Asset__c(name = 'Test 1', Customer_Name__c = acc.id);
            insert asset1; 

            if (lstOpportunityUpside != null && lstOpportunityUpside.size() > 0) 
            {
                oppNormal = lstOpportunityUpside.get(0);
            }

            Opportunity_Asset_Junction__c oaj = new Opportunity_Asset_Junction__c(Related_Asset__c = asset1.id, Related_Opportunity__c = oppNormal.id);

            insert oaj;

            ApexPages.currentpage().getParameters().put('Id',oppNormal.id);
            ApexPages.StandardController con = new ApexPages.StandardController(oppNormal);
            DetailPageAsset relatedController = new DetailPageAsset(con);
            List<Asset__c> lstAsts = relatedController.getOppz();
            test.stopTest();
        }
        catch(Exception e)
        {
            
        }
    }
}