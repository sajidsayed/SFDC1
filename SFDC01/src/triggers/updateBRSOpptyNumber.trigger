/*====================================================================================================================+
 |  HISTORY |                                                                 
 |                                                                           
 | DATE         DEVELOPER              WR               DESCRIPTION                               
 | ====           =========              ==               =========== 
 | Unknown      Unknown             Unknown           Unknown
 | 14-Nov-11    Kaustav Debnath     178714          Added code for PRM Partner Leverage functionality to flip 
                                                    opportunity recordtypes when opportunity stage is booked and one
                                                    of distributor/direct reseller or distribution VAR fields are 
                                                    rating eligible
 | 13-Dec-11    Kaustav Debnath     178714          Updated the condition to select booked Opportunity by adding 
 |                                                  Distributor_Reseller_VAR_Rating_Eligible__c field into the condition
 | 22/01/2011   Accenture                           Updated trigger to incorporate ByPass Logic
                                                    NOTE: Please write all the code after BYPASS Logic
   26/03/2012   Arif                                Including functionality of Comptetive Summary Mapping
   
   10/08/2012   Avinash Kaltari     201030          Updated Trigger to populate the Alliance Engagement Document URL field on Opportunity 
                                                    (through a method of AllianceEngagementMapping class)
   
 +====================================================================================================================*/

trigger updateBRSOpptyNumber on Opportunity (before insert, before update) {
    //Trigger BYPASS Logic
   
   if(CustomSettingBypassLogic__c.getInstance().By_Pass_Opportunity_Triggers__c){
            return;
   } 
   List<Opportunity> lstCompOpportunity = new List<Opportunity>();

   
//Following List of opportunities would contain the ones whose Alliance Engagement Document URL field is to be updated 
   List<Opportunity> lstAllianceOpportunity = new List<Opportunity>();
     List<Opportunity> lstServiceOpportunity = new List<Opportunity>();
    /*Added the following 2 lines for Partner Leverage booked recordtype flip*/
    if(!PRM_Partner_Leverage.PRM_Partner_Leverage_flag)
    {
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        
        for(Opportunity oppObj:Trigger.New)
        for(Integer i=0;i<Trigger.New.size();i++)
        {
            if(Trigger.IsUpdate && Trigger.New[i].stageName!=Trigger.Old[i].stageName && Trigger.New[i].stageName=='Booked' && Trigger.New[i].Distributor_Reseller_VAR_Rating_Eligible__c=='YES')
            {
                lstOpportunity.add(Trigger.New[i]);
            }
            else if(Trigger.IsInsert && Trigger.New[i].stageName=='Booked' && Trigger.New[i].Distributor_Reseller_VAR_Rating_Eligible__c=='YES')
            {
                lstOpportunity.add(Trigger.New[i]);
            }
        }
        if(lstOpportunity!=null && lstOpportunity.size()>0)
        {
            PRM_Partner_Leverage objClass=new PRM_Partner_Leverage();
            objClass.bookedOppRecordtypeFlip(lstOpportunity);
        }
        
    /*end of partner leverage functionality code*/
    for (Opportunity oppty : Trigger.new) {
        String AccountAddress='';
        if(oppty.BRS_Opportunity_Nbr__c!=null){
            oppty.BRS_Opportunity_Nbr__c = oppty.BRS_Opportunity_Nbr__c.toUpperCase();
        }   
        
        
    }
    
    
    //Added
    String EMCProducts = ' ';
    Double TotalForecastAmt = 0.00;
    Double TotalForecastAmtOfBRSProducts = 0.00;
    //List<OpportunityLineItem> products = new List<OpportunityLineItem>();
        if(trigger.isUpdate)
        {
            List<Opportunity> opptys = [Select o.AccountId, o.Account.BillingCity, o.Account.BillingCountry, o.Account.BillingPostalCode, o.Account.BillingState, o.Account.BillingStreet, o.AddressInformation__c, o.Id,o.EMC_BRS_Forecast_Amount__c, o.EMC_BRS_Products__c,(Select  PricebookEntryId, PricebookEntry.Name,UnitPrice,TotalPrice,CurrencyIsoCode,Product_Family__c from OpportunityLineItems) from Opportunity o  where o.Id in :Trigger.NewMap.keyset() and o.closeDate>Today and o.Opportunity_Number__c!=null];
            for(Opportunity oppty01:opptys){
             if(oppty01.AddressInformation__c==null){
             String AccountAddress='';
             
             if(oppty01.Account.BillingStreet!=null){
                    AccountAddress=AccountAddress+' '+oppty01.Account.BillingStreet;
                }
                if(oppty01.Account.BillingCity!=null){
                    AccountAddress=AccountAddress+' '+oppty01.Account.BillingCity;
                }
                if(oppty01.Account.BillingState!=null){
                    AccountAddress=AccountAddress+' '+oppty01.Account.BillingState;
                }
                if(oppty01.Account.BillingPostalCode!=null){
                    AccountAddress=AccountAddress+' '+oppty01.Account.BillingPostalCode;
                }
                if(oppty01.Account.BillingCountry!=null){
                    AccountAddress=AccountAddress+' '+oppty01.Account.BillingCountry;
                }
                                 
                Opportunity opp=Trigger.newMap.get(oppty01.id);
                opp.AddressInformation__c = AccountAddress;
                System.debug('Opp----->'+oppty01.AddressInformation__c);
                System.debug('AccountAddresss'+AccountAddress);
                }
                /////
                if(oppty01.OpportunityLineItems.size()>0)
                {
                    for(OpportunityLineItem opptyProd: oppty01.OpportunityLineItems )
                    {
                        if(opptyProd!=null){
                            //EMCProducts = EMCProducts+opptyProd.PricebookEntry.Name+' USD '+opptyProd.UnitPrice+', ';
                            EMCProducts = EMCProducts+opptyProd.PricebookEntry.Name+'  '+opptyProd.CurrencyIsoCode+'  '+opptyProd.UnitPrice+', ';
                            //TotalForecastAmt = TotalForecastAmt+opptyProd.UnitPrice;
                            if(opptyProd.Product_Family__c=='DATADOMAIN'||opptyProd.Product_Family__c=='ANDL'){
                                TotalForecastAmtOfBRSProducts = TotalForecastAmtOfBRSProducts+opptyProd.UnitPrice;
                            }
                           }
                    }
                    if(EMCProducts!=null)
                    {
                        EMCProducts = EMCProducts.substring(0,EMCProducts.length()-2);
                        System.debug('List of Products final--->'+EMCProducts );
                        Opportunity opp01=Trigger.newMap.get(oppty01.id);
                        opp01.EMC_BRS_Products__c = EMCProducts;
                        System.debug('EMCProducts--->'+opp01.EMC_BRS_Products__c);
                        //opp01.Total_BRS_Forecast_Amount__c = TotalForecastAmtOfBRSProducts;
                        //opp01.TotalForecastAmount__c = TotalForecastAmtOfBRSProducts;
                        opp01.EMC_BRS_Forecast_Amount__c = TotalForecastAmtOfBRSProducts;
                        System.debug('TotalForecastAmtOfBRSProducts--->'+opp01.EMC_BRS_Forecast_Amount__c );
                    }
                }  
                
         } 
         //Added
        }
    }
    
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {   
        for (Opportunity opp : Trigger.New) 
        {
            if(Trigger.isInsert)
            {
                lstCompOpportunity.add(opp);
                
//Following line added to populate List of Opportunities for which Alliance Engagement Document URL field has to be updated (by Avinash)
                lstAllianceOpportunity.add(opp);
                lstServiceOpportunity.add(opp);
 
            }
            else if(Trigger.isUpdate)
            {
                if((opp.Competitor__c != null && opp.Product_Model__c != null) 
                    && ((Trigger.oldMap.get(opp.id).Competitor__c != opp.Competitor__c) ||  
                    Trigger.oldMap.get(opp.id).Product_Model__c != opp.Product_Model__c ))
                {
                        lstCompOpportunity.add(opp);
                }
                
//Following lines added to populate List of Opportunities for which Alliance Engagement Document URL field has to be updated (by Avinash)
                if(opp.Primary_Alliance_Partner__c != null)
                {
                    lstAllianceOpportunity.add(opp);
                }
                
                if(opp.Primary_Alliance_Partner__c == null)
                {
                    opp.Alliance_Engagement_Document__c = null;
                }
                
                
                 if(opp.Service_Provider__c != null)
                {
                    lstServiceOpportunity.add(opp);
                }
                 if(opp.Service_Provider__c == null)
                {
                    opp.Service_Provider_Engagement_Document__c = null;
                }
                 
            }
        }       
    }
    
    if(lstCompOpportunity.size() >0)
    {
         CompetitiveSummaryOperation obj = new CompetitiveSummaryOperation();
         obj.populateCompetitiveMappingOnOppty(lstCompOpportunity);
    }
    
    if(lstAllianceOpportunity.size() > 0)
    {
        AllianceEngagementMapping obj = new AllianceEngagementMapping();
        obj.populateAllianceEngagementDocumentURL(lstAllianceOpportunity);
          
    }
    if(lstServiceOpportunity.size() > 0)
    {
        
        AllianceEngagementMapping obj = new AllianceEngagementMapping();
    obj.populateServiceEngagementDocumentURL(lstServiceOpportunity);
    }
        
  }