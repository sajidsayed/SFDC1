/*

30-05-2011      Srinivas Nallapati  Modified for June 11 SFA release WR-167363
 11.10.2011      Shipra Misra    173965             November Release.
 04.04.2013      Vivek           234348/221255      April Release(update SO_Number__c/QuoteCartnumber).
*/
@isTest(seealldata = true)
private class EMCBRS_S2S_Utils_TC { 
  public static testMethod void TestEMCBRS_S2S_Utils(){
   List<Opportunity> Opp_List=[Select Id,Account.Name,
                                        Opportunity_Number__c,
                                        BRS_Opportunity_Nbr__c,
                                        CloseDate,
                                        ForecastCategory,
                                        Amount,
                                        Quote_Amount__c,
                                        Account_Address__c,
                                        EMC_BRS_Products__c,
                                        SO_Number__c,
                                        Name,
                                        BRS_Product_Forecast__c,
                                        Quote_Cart_Number__c,
                                        Partner__r.Name,
                                        Owner.Name,(Select PricebookEntryId, PricebookEntry.Name,UnitPrice,TotalPrice,CurrencyIsoCode,Product_Family__c from OpportunityLineItems) from Opportunity where CloseDate>=Today and (  (BRS_Opportunity_Nbr__c=Null   )) and Opportunity_Number__c!=null 
                                         and service_provider__c=null limit 1];
   for(Opportunity opp:Opp_List){
   if(opp.BRS_Opportunity_Nbr__c==null){
       opp.BRS_Opportunity_Nbr__c='BRS-00009999';
       opp.Account.Name = 'Test';
       }
   }
   update Opp_List; 
   for(Opportunity oppty:Opp_List){
       oppty.BRS_Opportunity_Nbr__c=null;
   }
   update Opp_List; 
     
      EMC_BRS_Opportunity__c emc_brs_var=new EMC_BRS_Opportunity__c(CurrencyIsoCode='USD',Active__c=true,BRS_Opportunity_Nbr__c='BRS-00009998',EMC_Opportunity_Nbr__c='0000997');
      insert emc_brs_var; 
 }
 
 public static testmethod void TestEMCBRS_S2S_TestData(){
 
 EMCBRS_S2S_Utils emc_brs_vartest =new EMCBRS_S2S_Utils();
     
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        Opportunity Oppty = new Opportunity();
        Oppty.AccountId = testAccount.Id;
        Date closeDate = date.today()+15;
        Date approvalDate = date.newinstance(2014, 11, 1);
        Date expirationDate = date.newinstance(2015, 11, 18);
        Oppty.Name = 'Test Oppty';
        Oppty.Sales_Channel__c = 'Direct';
        oppty.Opportunity_Number__c ='852963742';
        Oppty.Sales_Force__c = 'EMC';
        Oppty.StageName = 'Pipeline';
        Oppty.Closed_Reason__c = 'Loss';
        Oppty.Close_Comments__c = 'Lost';
        Oppty.CloseDate = closeDate;
        Oppty.Sell_Relationship__c = 'Direct';
        Oppty.Quote_Version__c='v13';
        Oppty.BRS_Opportunity_Nbr__c='BRS-000019972';
        Oppty.Quote_Type__c='New';
        Oppty.Approval_Date__c=approvalDate ;
        Oppty.Expiration_Date__c=expirationDate ;
        insert Oppty;
        
        
        Opportunity Oppty2 = new Opportunity();
        Oppty2.AccountId = testAccount.Id;
        Date closeDate1 = date.today()+15;
        Date approvalDate1 = date.newinstance(2014, 11, 1);
        Date expirationDate1 = date.newinstance(2015, 11, 18);
        Oppty2.Name = 'Test Oppty';
        oppty.Opportunity_Number__c ='852963741';
        Oppty2.Sales_Channel__c = 'Direct';
        Oppty2.Sales_Force__c = 'EMC';
        Oppty2.StageName = 'Pipeline';
        Oppty2.Closed_Reason__c = 'Loss';
        Oppty2.Close_Comments__c = 'Lost';
        Oppty2.CloseDate = closeDate1;
        Oppty2.BRS_Opportunity_Nbr__c='BRS-000019973';
        Oppty2.Sell_Relationship__c = 'Direct';        
        Oppty2.Quote_Version__c='v13';
        Oppty2.Quote_Type__c='New';
        Oppty2.Approval_Date__c=approvalDate1 ;
        Oppty2.Expiration_Date__c=expirationDate1 ;
        insert Oppty2;
        
          Map<Id,Opportunity> opptyMapBfr = new  Map<Id,Opportunity>();
        Opportunity opptyMapset1 =[select  Account.Name,
                                        Opportunity_Number__c,
                                        BRS_Opportunity_Nbr__c,
                                        CloseDate,
                                        ForecastCategory,
                                        StageName,
                                        Amount,
                                        Quote_Amount__c,
                                        Account_Address__c,
                                        Partner__r.Name,
                                        Owner.Name,
                                        Tier_2_Partner__r.Name,
                                        Account.BillingStreet,
                                        Account.BillingCity,
                                        Account.BillingState,
                                        Account.BillingPostalCode,
                                        Account.BillingCountry,
                                        AddressInformation__c,
                                        LastModifiedDate,
                                        EMC_BRS_Products__c,
                                        EMC_BRS_Forecast_Amount__c,                                        
                                        SO_Number__c,
                                        BRS_Product_Forecast__c,
                                        Name,
                                        Quote_Cart_Number__c  from Opportunity where id =:Oppty.id];
		system.debug('opptyMapset1 == '+opptyMapset1);
        opptyMapBfr.put(opptyMapset1.id,opptyMapset1);
        Map<Id,Opportunity> opptyMapAfr = new Map<Id,Opportunity>();
        Opportunity opptyMapset2 =[select  Account.Name,
                                        Opportunity_Number__c,   
                                        BRS_Opportunity_Nbr__c,                                    
                                        CloseDate,
                                        ForecastCategory,
                                        StageName,
                                        Amount,
                                        Quote_Amount__c,
                                        Account_Address__c,
                                        Partner__r.Name,
                                        Owner.Name,
                                        Tier_2_Partner__r.Name,
                                        Account.BillingStreet,
                                        Account.BillingCity,
                                        Account.BillingState,
                                        Account.BillingPostalCode,
                                        Account.BillingCountry,
                                        AddressInformation__c,
                                        LastModifiedDate,
                                        EMC_BRS_Products__c,
                                        EMC_BRS_Forecast_Amount__c,                                        
                                        SO_Number__c,
                                        BRS_Product_Forecast__c,
                                        Name,
                                        Quote_Cart_Number__c  from Opportunity where id =:Oppty2.id];  
		   system.debug('opptyMapset2 == '+opptyMapset2);
           opptyMapAfr.put(opptyMapset2.id,opptyMapset2);
           
           Opportunity obj1 = opptyMapset2.clone(); 
           obj1.BRS_Opportunity_Nbr__c = null;
           insert obj1;
           Opportunity obj2 = opptyMapset2.clone(); 
           obj2.BRS_Opportunity_Nbr__c = 'BRS-111111';
           insert obj2;
              
           opptyMapBfr.put(opptyMapset2.id,opptyMapset2);
           opptyMapBfr.put(obj1.id,obj1);
           opptyMapBfr.put(obj2.id,obj2);
        
        emc_brs_vartest.upsertSharedOpportunities(opptyMapBfr,opptyMapAfr);
                          
        List<EMC_BRS_Opportunity__c> listBRSOppty = new List<EMC_BRS_Opportunity__c>();
        EMC_BRS_Opportunity__c emcBrsOppty= new EMC_BRS_Opportunity__c();
        emcBrsOppty.EMC_Account_Name__c ='ATOS IT SOLUTIONS AND SERVICES GMBH';
        emcBrsOppty.EMC_Opportunity_Nbr__c='2005935';
        emcBrsOppty.EMC_Opportunity_Name__c='Atos_CCH_VMAX_1475_Upgrade_Q112_Tarit';
        emcBrsOppty.EMC_Order_Nbr__c='64616667';
        emcBrsOppty.EMC_Quote_Nbr__c='1004137657';
        emcBrsOppty.EMC_Forecast_Status__c='Pipeline';
        emcBrsOppty.BRS_Account_Name__c='Test America';
        emcBrsOppty.BRS_Opportunity_Nbr__c='BRS-000219972';
        emcBrsOppty.BRS_Rep_Name__c='TESTTEST';
        emcBrsOppty.BRS_Account_Address__c='4955 Yarrow St Arvada CO 80002-4517 USA (US)';
        emcBrsOppty.BRS_Forecast_Status__c='Omitted';
        database.upsert(emcBrsOppty,false);
        listBRSOppty.add(emcBrsOppty);
        list<string> opptynumber = new list<string>();
        opptynumber.add(obj1.Opportunity_Number__c);
        
        //EMCBRS_S2S_Utils.updateEMCOpptytoBRS(opptynumber);        
        emc_brs_vartest.updateEMCOpportunityFromBRS(listBRSOppty);
 
 }
}