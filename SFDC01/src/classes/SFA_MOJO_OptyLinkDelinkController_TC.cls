/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  28.10.2012      Shipra          MOJO        Initial Creation.Creating this test class to unit test 
                                                SFA_MOJO_OptyLinkDelinkController class.
    31.10.2012      Avinash K       MOJO        Updated the linkUnlinkUnitTest test method to increase coverage for
                                                SFA_MOJO_OptyLinkDelinkController
    
+========================================================================================================================*/

@isTest(seeAllData = true) 
private class SFA_MOJO_OptyLinkDelinkController_TC 
{

    static testMethod void linkUnlinkUnitTest() 
    {
        try
        {
            // Create List Of account 
            User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
            System.runAs(insertUser)
            {
                //Insert Account.
                Account account =   new Account(Name='Test Account**',CurrencyIsoCode='USD',Account_Flag__c='Primary',Site_DUNS_Entity__c = '123456',
                                    Global_DUNS_Entity__c = '663399');  
                
                insert account;
                //Creating Oppty
                Opportunity Oppty = new Opportunity(Name = 'Test Opportunity ',AccountId=account.id,Sales_Force__c='EMC',CurrencyIsoCode='USD',
                                    StageName ='Pipeline',CloseDate = System.today(),VCE_Related__c='VMWare Other',Amount = 500);    
                
                insert Oppty;

                Opportunity Oppty2 = new Opportunity(Name = 'Test Opportunity 1',AccountId=account.id,Sales_Force__c='EMC',CurrencyIsoCode='USD',
                                    StageName ='Closed',Closed_Reason__c = 'Competition',Close_Comments__c = 'test', CloseDate = System.today(),VCE_Related__c='VMWare Other',Amount = 500);    
                
                insert Oppty2;


                Set<Id> setOppId = new Set<Id>();
                setOppId.add(Oppty.id);
                
                List<Asset__c> lstAsset = new List<Asset__c>();
                
                Asset__c oppAssetRecord1 = new Asset__c();
                oppAssetRecord1.Name = 'Asset Test 1';
                oppAssetRecord1.Configuration_Details__c='EMC';
                oppAssetRecord1.Swap_Value__c=789.00;
                oppAssetRecord1.Product_Family__c='Services Only';
                oppAssetRecord1.Total_Raw_Capacity_GB__c = '11';
                oppAssetRecord1.Customer_Name__c=account.id;        
                lstAsset.add(oppAssetRecord1);
                
                Asset__c oppAssetRecord2 = new Asset__c();
                oppAssetRecord2.Name = 'Asset Test 2';
                oppAssetRecord2.Configuration_Details__c='EMC';
                oppAssetRecord2.Swap_Value__c=789.00;
                oppAssetRecord2.Product_Family__c='Services Only';
                oppAssetRecord2.Total_Raw_Capacity_GB__c = '22.0';
                oppAssetRecord2.Customer_Name__c=account.id;        
                lstAsset.add(oppAssetRecord2);
                
                Asset__c oppAssetRecord3 = new Asset__c();
                oppAssetRecord3.Name = 'Asset Test 3';
                oppAssetRecord3.Configuration_Details__c='EMC';
                oppAssetRecord3.Swap_Value__c=789.00;
                oppAssetRecord3.Product_Family__c='Services Only';
                oppAssetRecord3.Total_Raw_Capacity_GB__c = '33.0';
                oppAssetRecord3.Customer_Name__c=account.id;        
                lstAsset.add(oppAssetRecord3);
                
                Asset__c oppAssetRecord4 = new Asset__c();
                oppAssetRecord4.Name = 'Asset Test 4';
                oppAssetRecord4.Configuration_Details__c='EMC';
                oppAssetRecord4.Swap_Value__c=789.00;
                oppAssetRecord4.Product_Family__c='Services Only';
                oppAssetRecord4.Total_Raw_Capacity_GB__c = '44.0';
                oppAssetRecord4.Customer_Name__c=account.id;        
                lstAsset.add(oppAssetRecord4);
                
                Asset__c oppAssetRecord5 = new Asset__c();
                oppAssetRecord5.Name = 'Asset Test 5';
                oppAssetRecord5.Configuration_Details__c='EMC';
                oppAssetRecord5.Swap_Value__c=789.00;
                oppAssetRecord5.Product_Family__c='Services Only';
                oppAssetRecord5.Total_Raw_Capacity_GB__c = '55.0';
                oppAssetRecord5.Customer_Name__c=account.id;        
                lstAsset.add(oppAssetRecord5);
                
                Asset__c oppAssetRecord6 = new Asset__c();
                oppAssetRecord6.Name = 'Asset Test 6';
                oppAssetRecord6.Configuration_Details__c='EMC';
                oppAssetRecord6.Swap_Value__c=789.00;
                oppAssetRecord6.Product_Family__c='Services Only';
                oppAssetRecord6.Total_Raw_Capacity_GB__c = '66.0';
                oppAssetRecord6.Customer_Name__c=account.id;        
                lstAsset.add(oppAssetRecord6);
                
                
                insert lstAsset;

                List<Opportunity_Asset_Junction__c> lstOAJ = new List<Opportunity_Asset_Junction__c>();
                Opportunity_Asset_Junction__c oaj1 = new Opportunity_Asset_Junction__c(Related_Asset__c = oppAssetRecord1.id, Related_Opportunity__c = Oppty.id);

                Opportunity_Asset_Junction__c oaj2 = new Opportunity_Asset_Junction__c(Related_Asset__c = oppAssetRecord2.id, Related_Opportunity__c = Oppty.id, Related_Account__c = account.id);

                Opportunity_Asset_Junction__c oaj3 = new Opportunity_Asset_Junction__c(Related_Asset__c = oppAssetRecord3.id, Related_Opportunity__c = Oppty.id, Related_Account__c = account.id);

                Opportunity_Asset_Junction__c oaj4 = new Opportunity_Asset_Junction__c(Related_Asset__c = oppAssetRecord4.id, Related_Opportunity__c = Oppty.id, Related_Account__c = account.id);

                Opportunity_Asset_Junction__c oaj5 = new Opportunity_Asset_Junction__c(Related_Asset__c = oppAssetRecord5.id, Related_Opportunity__c = Oppty.id, Related_Account__c = account.id);

                Opportunity_Asset_Junction__c oaj6 = new Opportunity_Asset_Junction__c(Related_Asset__c = oppAssetRecord6.id, Related_Opportunity__c = Oppty.id, Related_Account__c = account.id);

                Opportunity_Asset_Junction__c oaj7 = new Opportunity_Asset_Junction__c(Related_Asset__c = oppAssetRecord6.id, Related_Opportunity__c = Oppty2.id, Related_Account__c = account.id);

                lstOAJ.add(oaj1);
                lstOAJ.add(oaj2);
                lstOAJ.add(oaj3);
                lstOAJ.add(oaj4);
                lstOAJ.add(oaj5);
                lstOAJ.add(oaj6);
                lstOAJ.add(oaj7);
                
                insert lstOAJ;
                
               	 FeedItem fItem = new FeedItem();
			  	 fItem.Type = 'LinkPost';
			  	 fItem.ParentId =Oppty.id;
			   	 fItem.Title='Sales Promotions'; 
			   	 fItem.LinkUrl='http://one.emc.com/clearspace/community/active/operation_mojo?view=overview';
			   	 fItem.Body = 'There are competitive assets linked to this opportunity - Check out the Sales Promotions that you may qualify for!';
			   	 insert fItem;

                Trade_Ins_Competitive_Swap__c trade1 = new Trade_Ins_Competitive_Swap__c(Related_Opportunity__c = Oppty.id, Registration_ID__c = 'test', Swap_Value__c = 1);
                Database.SaveResult result = Database.insert(trade1);

                Database.SaveResult result2 = Database.update(trade1);


                List<Database.SaveResult> results = new List<Database.SaveResult>();
                results.add(result);
                results.add(result2);

                ApexPages.currentpage().getParameters().put('Id',Oppty.Id);
                ApexPages.StandardController oppController=new ApexPages.StandardController(Oppty);
                SFA_MOJO_OptyLinkDelinkController sfaMojoLinkUnlink= new SFA_MOJO_OptyLinkDelinkController(oppController);
                
                SFA_MOJO_OptyLinkDelinkController.assetwrapper astwrp= new SFA_MOJO_OptyLinkDelinkController.assetwrapper(oppAssetRecord6,'xxx');
                
                astwrp.selected=true;
                

                sfaMojoLinkUnlink.updateTradeInsAndSwaps(setOppId);

                List<SFA_MOJO_OptyLinkDelinkController.assetwrapper> lst = sfaMojoLinkUnlink.getAssetstoBeLinkedDetails();
                lst.clear();
                lst.add(astwrp);
                sfaMojoLinkUnlink.delinkAsset();
                sfaMojoLinkUnlink.doSave();

                sfaMojoLinkUnlink.docancel();
                sfaMojoLinkUnlink.linkToOpportunity();

                sfaMojoLinkUnlink.updateTradeInsAndSwaps(setOppId);
                Boolean bln1 = sfaMojoLinkUnlink.getOpportunityClosed();
                Boolean bln2 = sfaMojoLinkUnlink.getCancel();
                lst = sfaMojoLinkUnlink.getAssetsDetails();
                lst = sfaMojoLinkUnlink.getAssetstoBeLinkedDetails();

                sfaMojoLinkUnlink.getData(results);
                

                ApexPages.currentpage().getParameters().put('Id',Oppty2.Id);
                ApexPages.StandardController oppController2 = new ApexPages.StandardController(Oppty2);
                SFA_MOJO_OptyLinkDelinkController sfaMojoLinkUnlink2 = new SFA_MOJO_OptyLinkDelinkController(oppController2);
                SFA_MOJO_OptyLinkDelinkController.Feedpost(Oppty.Id);

            }
        }
        catch(Exception e)
        {
            
        }
    }
}