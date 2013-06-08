/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  20.07.2010      Anand Sharma    136601      Initial Creation.  Test class Assign sales rep to the opportunity For EMC Type.               
 |   01.11.2010     Shipra Misra    145924      Enhancements in channel visibility.Updated the test class as per the simplified logic 
 |                                              no change in records is required as the same records can be assigned(Geo constarints) after the enhancement to the code. 
 |  27.01.2011      Shipra Misra    151892      Updated test class as two new required fields which have been introduced to the system. "Primary  & Infrastructure" & "Primary Outsourcer & Integrator".
 |  01.02.2011      Shipra Misra    151892      Updated Test class as it was failing in deployment validation.
 |  25.02.2011      Shipra Misra    156767      Worked on code for March release.    
 |  05.04.2011      Shipra Misra    162718      Worked on code for April release. 
 |	12.04.2011		Shipra Misra	160455		WR-160455 Included Master grouping for Partner's.Having the ability to select a Master Partner Grouping 
 |												hence simplify OAR maintenance and reduce the number of OARs that need to be created.                                        
 |	12.05.2011		Shipra Misra	162881		Worked for Jun release.Changes for including service provider field.
 |	21.08.2011		Shipra Misra	168750		Worked for Sep release.Create validation rules on OAR.
 |	14.10.2011		Shipra Misra	173695		Worked for Nov release.Introduction new allaince partner & deleting existing  & Outsourcer field.
 |	14.11.2012		Vivek Kodi   	WR199084	Commented The custom setting code for OAR permissions.
 +===========================================================================*/

@isTest
private class Opp_assignChannelRep_TC 
{

    static testMethod void channelVisibiltyUnitTest() 
    {
        // TO DO: implement unit test
        //Query Profile object to find the Id of System Administrator Profile which will be used for selecting user which is standard type and
        //has Profile as System Administrator.
        Profile objProfile = [Select id,Name from Profile where name=:'System Administrator'];
        
        //Query Standard user which is active and has System Administrator Profile.
        User objUser = [Select Id, Name, username, alias, email,lastname,languagelocalekey,profileid,localesidkey,timezonesidkey, UserType, 
        emailencodingkey, BU__c, Employee_Number__c, Theater__c,Division__c, District__c, Country__c, IsActive, State, Forecast_Group__c from User where  UserType='Standard' and Country__c='United States' and CurrencyIsoCode='USD' and IsActive=True and ProfileId=:objProfile.id limit 1];

        //Query another user to get assigned on sales team. on Partner change.
        User objUserTier2 = [Select Id, Name, username, alias, email,lastname,languagelocalekey,profileid,localesidkey,timezonesidkey, UserType, 
                            emailencodingkey, BU__c, Employee_Number__c, Theater__c,Division__c, District__c, Country__c, IsActive, State, Forecast_Group__c from User where  UserType='Standard'and Country__c='United States'and CurrencyIsoCode='USD'and id!=:objUser.id and IsActive=True limit 1];
        
        //Provide CAP_Approver & Co_Op_Access to the user.
        objUser.CAP_Approver__c=true;
        objUser.Co_Op_Access__c=true;
                
        System.runAs(objUser)
        {
            //Create Partner Account to be added on  Partners.
            List<account> acctToBeAddedAliance = new List<account>();
            for(Integer i = 0; i < 10; i++)
            {
              Account accAlliance = new Account(Name = 'Test Account Alliance' + i
                                ,RecordTypeId='012700000005IlnAAE'
                                ,Type='Partner'
                                ,CurrencyIsoCode='USD'
                                ,Status__c = 'A'
                                ,OwnerId = objUser.Id
                                ,BillingPostalCode='1000'
                                ,BillingCountry='United States'
                                ,Non_Distributor_Direct_Reseller_Partner__c=true
                                ,Partner_Type__c='Service Provider,Direct Reseller,Distribution VAR'
                                ,Reporting_Segmentation_Group__c='Global Alliances'
                                ,PROFILED_ACCOUNT_FLAG__c=true
                                ,Coverage_Model__c='A-Hunting'
                                ,Customer_Segment__c='Enterprise Tier 1'
                                ,Grouping__c='a0F70000004CnKu'
                                ,Master_Grouping__c='a0F70000004CoyI'
                                ,Lead_Oppty_Enabled__c = true,Child_Partner_Users_Count__c=2);
                acctToBeAddedAliance.add(accAlliance);
                System.debug('the value of i is '+i);
            }
            insert acctToBeAddedAliance;
            
            //Create Partner account to be added on Tier1 /Tier2 partner.
            List<account> acctToBeAdded = new List<account>();
            for(Integer i = 0; i < 10; i++)
            {
              Account accPartner = new Account(Name = 'Test Account partner ' + i
                                ,RecordTypeId='012700000005IlnAAE'
                                ,Type='Partner'
                                ,CurrencyIsoCode='USD'
                                ,BillingPostalCode='1000'
                                ,BillingCountry='United States'
                                ,Non_Distributor_Direct_Reseller_Partner__c=true
                                ,Partner_Type__c='Service Provider,Direct Reseller,Distribution VAR'
                                ,Reporting_Segmentation_Group__c='Global Alliances'
                                ,Coverage_Model__c='A-Hunting'
                                ,Customer_Segment__c='Enterprise Tier 1'
                                ,Status__c = 'A'
                                ,OwnerId = objUser.Id
                                ,Lead_Oppty_Enabled__c = true,Child_Partner_Users_Count__c=2,PROFILED_ACCOUNT_FLAG__c=true);
                acctToBeAdded.add(accPartner);
            }
            insert acctToBeAdded;
            acctToBeAdded.addAll(acctToBeAddedAliance);
            
            //Update the Lead_Oppty_Enabled__c on account as True once the accounts are inserted. 
            Set<id> accntId =new set<id>();
            for(integer i=0;i<acctToBeAdded.size();i++)
            {
                accntId.add(acctToBeAdded[i].id);
            }
            
            List<Account> accStatus =new List<Account>([Select name,RecordTypeId,Account_Status__c,Type,CurrencyIsoCode,BillingCountry,Status__c,OwnerId,Lead_Oppty_Enabled__c from Account where id in: accntId]);
            for(Integer i=0;i<accStatus.size();i++)
            {
                accStatus[i].Lead_Oppty_Enabled__c=true;
                accStatus[i].Partner_Type__c='Service Provider,Direct Reseller,Distribution VAR';
                accStatus[i].Non_Distributor_Direct_Reseller_Partner__c=true;
            }
            update accStatus; 
            System.debug('accStatus'+accStatus);
            System.debug('Partner type'+accStatus[1].CreatedDate);
            System.debug('Partner type'+accStatus[1].Partner_Type__c);
            //Custom Setting to add user to the custom setting.
           /* AccessOnUserAssignmentRule__c objAccess= new AccessOnUserAssignmentRule__c();
            objAccess.UserID__c = Userinfo.getUserId();
            objAccess.EditAccess__c = true;
            objAccess.Name = 'TestUser';
            try
            {
               insert objAccess;
            }catch(Exception e){
               System.debug('Check Obj Access'+e); 
            }*/
                
           PricebookEntry pricebook=[Select Id from PricebookEntry where IsActive=true and CurrencyIsoCode='USD'limit 1];
        
            // Creating Records for OAR. 
            List<Opportunity_Assignment_Rule__c> lstOppAssigRuleRecord = new List<Opportunity_Assignment_Rule__c>();
            
            Opportunity_Assignment_Rule__c oppAssigRuleRecord1 = new Opportunity_Assignment_Rule__c();
            oppAssigRuleRecord1.Resource_Name__c = objUserTier2.Id;
            oppAssigRuleRecord1.Resource_Sales_Force__c='EMC';
            oppAssigRuleRecord1.Active__c=true;
            oppAssigRuleRecord1.Partner_Type__c='Named Partners';
            oppAssigRuleRecord1.Partner_Grouping__c = acctToBeAddedAliance.get(0).Grouping__c;
            //oppAssigRuleRecord1.Tier1Tier2_Partner_Name__c =acctToBeAdded.get(0).Id;
            oppAssigRuleRecord1.Resource_Opportunity_Sales_Team_Role__c='Channel Ã¢â‚¬â€œ Execution Sales Rep';        
            lstOppAssigRuleRecord.add(oppAssigRuleRecord1);
            
            Opportunity_Assignment_Rule__c oppAssigRuleRecord2 = new Opportunity_Assignment_Rule__c();
            oppAssigRuleRecord2.Resource_Name__c = objUser.Id;
            oppAssigRuleRecord2.Resource_Sales_Force__c='EMC';
            oppAssigRuleRecord2.Active__c=true;
            oppAssigRuleRecord2.Partner_Type__c='Named Partners';
            oppAssigRuleRecord2.Coverage_Model__c='A-Hunting';
            oppAssigRuleRecord2.Customer_Segment__c='Enterprise Tier 1';
            oppAssigRuleRecord2.Tier1Tier2_Partner_Name__c =acctToBeAddedAliance.get(0).Id;
            oppAssigRuleRecord2.Resource_Opportunity_Sales_Team_Role__c='Channel Ã¢â‚¬â€œ Execution Sales Rep';        
            lstOppAssigRuleRecord.add(oppAssigRuleRecord2);
              
            Opportunity_Assignment_Rule__c oppAssigRuleRecord3 = new Opportunity_Assignment_Rule__c();
            oppAssigRuleRecord3.Resource_Name__c = objUser.Id;
            oppAssigRuleRecord3.Resource_Sales_Force__c='EMC';
            oppAssigRuleRecord3.Active__c=true;
            oppAssigRuleRecord3.Partner_Type__c='Named Partners';
            oppAssigRuleRecord3.Zip_Postal_Code_High_Range__c='1500';
            oppAssigRuleRecord3.Zip_Postal_Code_Low_Range__c='1000';
            oppAssigRuleRecord3.ResourceCountry__c ='United States';
            oppAssigRuleRecord3.Coverage_Model__c='A-Hunting';
            oppAssigRuleRecord3.Customer_Segment__c='Enterprise Tier 1';
            oppAssigRuleRecord3.Tier1Tier2_Partner_Name__c =acctToBeAddedAliance.get(1).id;
            oppAssigRuleRecord3.Resource_Opportunity_Sales_Team_Role__c='Channel Ã¢â‚¬â€œ Execution Sales Rep';        
            lstOppAssigRuleRecord.add(oppAssigRuleRecord3);
              
            Opportunity_Assignment_Rule__c oppAssigRuleRecord4 = new Opportunity_Assignment_Rule__c();
            oppAssigRuleRecord4.Resource_Name__c = objUser.Id;
            oppAssigRuleRecord4.Resource_Sales_Force__c='EMC';
            oppAssigRuleRecord4.Active__c=true;
            oppAssigRuleRecord4.Partner_Type__c='All Partners';
            oppAssigRuleRecord4.ResourceCountry__c ='United States';
            oppAssigRuleRecord4.Resource_Opportunity_Sales_Team_Role__c='Channel Ã¢â‚¬â€œ Execution Sales Rep';        
            lstOppAssigRuleRecord.add(oppAssigRuleRecord4);
            
            Opportunity_Assignment_Rule__c oppAssigRuleRecord6 = new Opportunity_Assignment_Rule__c();
            oppAssigRuleRecord6.Resource_Name__c = objUser.Id;
            oppAssigRuleRecord6.Resource_Sales_Force__c='EMC';
            oppAssigRuleRecord6.Active__c=true;
            oppAssigRuleRecord6.Partner_Type__c='Alliances';
            oppAssigRuleRecord6.Zip_Postal_Code_List__c='1000';
            oppAssigRuleRecord6.ResourceCountry__c ='United States';
            oppAssigRuleRecord6.ResourceTheatre__c='Global';
            oppAssigRuleRecord6.Alliance_Partner__c =acctToBeAddedAliance.get(2).id;
            oppAssigRuleRecord6.Resource_Opportunity_Sales_Team_Role__c='ChannelÃ¢â‚¬â€œ Execution Sales Rep';        
            lstOppAssigRuleRecord.add(oppAssigRuleRecord6);
            
            Opportunity_Assignment_Rule__c oppAssigRuleRecord7 = new Opportunity_Assignment_Rule__c();
            oppAssigRuleRecord7.Resource_Name__c = objUserTier2.Id;
            oppAssigRuleRecord7.Resource_Sales_Force__c='EMC';
            oppAssigRuleRecord7.Copy_Resource_Attributes__c=true;
            oppAssigRuleRecord7.Active__c=true;
            oppAssigRuleRecord7.Partner_Type__c='Alliances';
            oppAssigRuleRecord7.Zip_Postal_Code_High_Range__c='1500';
            oppAssigRuleRecord7.Zip_Postal_Code_Low_Range__c='1000';
            oppAssigRuleRecord7.ResourceCountry__c ='United States';
            oppAssigRuleRecord7.Customer_Segment__c='Enterprise Tier 1';
            oppAssigRuleRecord7.Coverage_Model__c='A-Hunting';
            oppAssigRuleRecord7.Alliance_Partner__c =acctToBeAddedAliance.get(0).id;
            oppAssigRuleRecord7.Resource_Opportunity_Sales_Team_Role__c='Channel Ã¢â‚¬â€œ Execution Sales Rep';        
            lstOppAssigRuleRecord.add(oppAssigRuleRecord7);
            
            Opportunity_Assignment_Rule__c oppAssigRuleRecord8 = new Opportunity_Assignment_Rule__c();
            oppAssigRuleRecord8.Resource_Name__c = objUserTier2.Id;
            oppAssigRuleRecord8.Resource_Sales_Force__c='EMC';
            oppAssigRuleRecord8.Copy_Resource_Attributes__c=true;
            oppAssigRuleRecord8.Active__c=true;
            oppAssigRuleRecord8.Partner_Type__c='Named Partners';
            oppAssigRuleRecord8.Partner_Grouping__c = acctToBeAddedAliance.get(1).Grouping__c;
            //oppAssigRuleRecord8.Tier1Tier2_Partner_Name__c =acctToBeAdded.get(1).Id;
            oppAssigRuleRecord8.Resource_Opportunity_Sales_Team_Role__c='Channel Ã¢â‚¬â€œ Execution Sales Rep';        
            lstOppAssigRuleRecord.add(oppAssigRuleRecord8);
            
            Opportunity_Assignment_Rule__c oppAssigRuleRecord9 = new Opportunity_Assignment_Rule__c();
            oppAssigRuleRecord9.Resource_Name__c = objUserTier2.Id;
            oppAssigRuleRecord9.Resource_Sales_Force__c='EMC';
            oppAssigRuleRecord9.Copy_Resource_Attributes__c=true;
            oppAssigRuleRecord9.Active__c=true;
            oppAssigRuleRecord9.Partner_Type__c='Service Provider';
            oppAssigRuleRecord9.Partner_Grouping__c = acctToBeAddedAliance.get(1).Grouping__c;
            oppAssigRuleRecord9.Resource_Opportunity_Sales_Team_Role__c='Channel Ã¢â‚¬â€œ Execution Sales Rep';        
            lstOppAssigRuleRecord.add(oppAssigRuleRecord9);
            
            Opportunity_Assignment_Rule__c oppAssigRuleRecord10 = new Opportunity_Assignment_Rule__c();
            oppAssigRuleRecord10.Resource_Name__c = objUser.Id;
            oppAssigRuleRecord10.Resource_Sales_Force__c='EMC';
            oppAssigRuleRecord10.Active__c=true;
            oppAssigRuleRecord10.Partner_Type__c='Service Provider';
            oppAssigRuleRecord10.Zip_Postal_Code_List__c='1000';
            oppAssigRuleRecord10.ResourceCountry__c ='United States';
            oppAssigRuleRecord10.ResourceTheatre__c='Global';
            oppAssigRuleRecord10.Service_Provider__c =acctToBeAddedAliance.get(1).id;
            oppAssigRuleRecord10.Resource_Opportunity_Sales_Team_Role__c='Channel Ã¢â‚¬â€œ Execution Sales Rep';        
            lstOppAssigRuleRecord.add(oppAssigRuleRecord10);
            // insert opportunity assignment records
    		try
    		{
    			insert lstOppAssigRuleRecord;	
    		}
            catch(Exception e)
            {
            	System.debug('e--->'+e);
            }
            
            List<OAR_Exclusion_Condition__c> oarExclusionRecord = new List<OAR_Exclusion_Condition__c>();
            OAR_Exclusion_Condition__c oarExclusionRecord1 = new OAR_Exclusion_Condition__c();
            oarExclusionRecord1.OAR_Field_API_Name__c ='BillingCountry';
            oarExclusionRecord1.Exclusion_Value__c='Uganda';
            oarExclusionRecord1.Partner_Grouping_Excluded__c=acctToBeAddedAliance[0].Grouping__c;
            oarExclusionRecord1.Account_Look_Up__c=acctToBeAddedAliance.get(6).id;
            oarExclusionRecord1.Opportunity_Assignment_Rule_del__c=oppAssigRuleRecord1.id;
            oarExclusionRecord.add(oarExclusionRecord1);
            
            OAR_Exclusion_Condition__c oarExclusionRecord2 = new OAR_Exclusion_Condition__c();
            oarExclusionRecord2.OAR_Field_API_Name__c ='region__c';
            oarExclusionRecord2.Exclusion_Value__c='East1';
            oarExclusionRecord2.Partner_Grouping_Excluded__c='a0F70000004Coba';
            oarExclusionRecord2.Account_Look_Up__c=acctToBeAddedAliance.get(2).id;
            oarExclusionRecord2.Opportunity_Assignment_Rule_del__c=oppAssigRuleRecord8.id;
            oarExclusionRecord.add(oarExclusionRecord2);
            
            
            database.insert(oarExclusionRecord,false);
            System.debug('oarExclusionRecord=---->'+oarExclusionRecord);
            System.debug('lstOppAssigRuleRecord--->'+lstOppAssigRuleRecord[0].Resource_Active__c);
            System.debug('lstOppAssigRuleRecord--->'+lstOppAssigRuleRecord);
            //Creating Oppty with Partner's. 
            List<Opportunity> lstOppty=new List<Opportunity>();  
        	//updated on 05.04.2011 for April release changed i<10 to i<2.   
            for(Integer i = 0; i < 4; i++)
            {
              // Creating OAR Rrecord for Named Partner with same Tier1 Partner.
              Opportunity Oppty = new Opportunity(Name = 'Test Opportunity ' + i
                                ,AccountId=acctToBeAdded.get(0).Id
                                ,Sales_Force__c='EMC'
                                ,CurrencyIsoCode='USD'
                                ,Partner__c = acctToBeAddedAliance.get(i).Id
                                ,Tier_2_Partner__c = acctToBeAdded.get(i).Id
                                ,Primary_Alliance_Partner__c=acctToBeAddedAliance.get(i).Id
                                ,Secondary_Alliance_Partner__c=acctToBeAddedAliance.get(i).Id
                                ,Service_Provider__c=acctToBeAddedAliance.get(i).Id
                                ,Opportunity_Owner__c=objUser.id
                                ,StageName ='Pipeline',CloseDate = System.today(),VCE_Related__c='VMWare Other',Amount = 500);
                lstOppty.add(Oppty);
                System.debug('the value of i is '+i);
            }
            //Insert the records that cause the trigger to execute.
            System.debug('lstOppty --->'+lstOppty);
            System.debug('The value of AccountId  is--->'+acctToBeAdded.get(0));
            System.Test.startTest();
            insert lstOppty; 
            
            List<OpportunityLineItem> lstOpptyLineItem= new List<OpportunityLineItem>();
            for(Integer k=0;lstOppty.size()>k;k++)
            {
            	OpportunityLineItem opptyLineItem = new OpportunityLineItem();
            	opptyLineItem.OpportunityId=lstOppty.get(k).id;
        		opptyLineItem.PricebookEntryId=pricebook.ID;
        		//.Product2Id='01t70000002UZxl';
            	opptyLineItem.Quote_Amount__c=36.00;
            	lstOpptyLineItem.add(opptyLineItem);
            }
            insert lstOpptyLineItem;
            
            Util.isChannelVisibilityExecuted = false;
            lstOppty.get(0).Opportunity_Owner__c=objUserTier2.id;
            lstOppty.get(0).Partner__c = acctToBeAddedAliance.get(5).id;
            lstOppty.get(0).Tier_2_Partner__c = acctToBeAdded.get(5).id;
            lstOppty.get(0).Primary_Alliance_Partner__c=acctToBeAddedAliance.get(5).id;
            lstOppty.get(0).Secondary_Alliance_Partner__c=acctToBeAddedAliance.get(8).id;
            lstOppty.get(0).Service_Provider__c=acctToBeAddedAliance.get(5).Id;
            update lstOppty.get(0);
            System.Test.stopTest();
        }
    }
}