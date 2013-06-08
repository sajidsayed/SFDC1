/*=======================================================================================================================================+
 
 |  DATE          DEVELOPER                WR          DESCRIPTION                               

 |  ====          =========                ==          =========== 

 |  3/22/2013    Sheriff/Vivek         234348/221255  SFA - BRS Bi-directional integration fix Dec accidentally terminated integration
                                                      SFA - BRS Bi-directional integration add 3 fields to mapping
    05/07/2013 	 Sravanthi 				252624		  To fix BRS Bi-directional integration currency conversion issue- Currency amount is being assigned
    													to the forecast amount irrespective of the currency code on 
    													opportunity record.
 +=======================================================================================================================================*/
public class EMCBRS_S2S_Utils {
  private static List<String> BRS_FIELDS_TO_COMPARE = new List<String>();
  private static List<String> EMC_FIELDS_TO_COMPARE = new List<String>();
  private static List<String> OPPTY_FIELDS_TO_COMPARE = new List<String>();
  static{
    BRS_FIELDS_TO_COMPARE.add('BRS_Opportunity_Nbr__c');
    BRS_FIELDS_TO_COMPARE.add('BRS_Close_Date__c');
    BRS_FIELDS_TO_COMPARE.add('BRS_Forecast_Status__c');
    BRS_FIELDS_TO_COMPARE.add('BRS_Forecast_Amount__c');
    BRS_FIELDS_TO_COMPARE.add('BRS_Quote_Amount__c');
    BRS_FIELDS_TO_COMPARE.add('BRS_Account_Name__c');
    BRS_FIELDS_TO_COMPARE.add('BRS_Account_Address__c');
    BRS_FIELDS_TO_COMPARE.add('BRS_Partner_Name__c');
    BRS_FIELDS_TO_COMPARE.add('BRS_Reseller_Company__c');

    OPPTY_FIELDS_TO_COMPARE.add('CloseDate');
    //OPPTY_FIELDS_TO_COMPARE.add('ForecastCategory');
    OPPTY_FIELDS_TO_COMPARE.add('Quote_Amount__c');
    OPPTY_FIELDS_TO_COMPARE.add('Partner__c');
    OPPTY_FIELDS_TO_COMPARE.add('Amount');
    OPPTY_FIELDS_TO_COMPARE.add('BRS_Opportunity_Nbr__c');
    //Added
    OPPTY_FIELDS_TO_COMPARE.add('StageName');
    OPPTY_FIELDS_TO_COMPARE.add('AddressInformation__c');
    OPPTY_FIELDS_TO_COMPARE.add('EMC_BRS_Products__c');
    OPPTY_FIELDS_TO_COMPARE.add('EMC_BRS_Forecast_Amount__c');
    //Added for update WR#221255
    OPPTY_FIELDS_TO_COMPARE.add('SO_Number__c');
    OPPTY_FIELDS_TO_COMPARE.add('Quote_Cart_Number__c');
    OPPTY_FIELDS_TO_COMPARE.add('Name');
    //252624
   // OPPTY_FIELDS_TO_COMPARE.add('CurrencyIsoCode');
    
  }
   // start -  Added for 252624
  Map<String,double> conversionrateMap = new Map<String,double>();
   // end -  Added for 252624
  /*
  Method that creates/deletes the EMC_BRS_Opportunity record when the BRS Opportunity
  number is updated/deleted on the EMC side by rep. 
  */
  public void upsertSharedOpportunities(Map<Id,Opportunity> opptyMapBfr,Map<Id,Opportunity> opptyMapAfr){
    List<EMC_BRS_Opportunity__c> emcBrsOppty2Updt = new List<EMC_BRS_Opportunity__c>();
    List<String> emcBrsOppty2Del = new List<String>();
    Opportunity opptyBfr,opptyAfr;
    Map<Id,Opportunity> masterOpptyMap = new Map<Id,Opportunity>([  select   Id,
                                        Account.Name,
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
                                        Quote_Cart_Number__c,
                                        CurrencyIsoCode
                                    from Opportunity 
                                    where Id in :opptyMapAfr.keySet()]);
    
    for(Id opptyId:opptyMapAfr.keySet()){
      opptyBfr = opptyMapBfr.get(opptyId);
      opptyAfr = opptyMapAfr.get(opptyId);
      system.debug('Amount Value----->'+opptyAfr.Amount); 
      system.debug('Quote_Amount__c Value----->'+opptyAfr.Quote_Amount__c);
      System.debug('SFDCDEV*******opptyBfr********'+opptyBfr);
      System.debug('SFDCDEV*******opptyAfr********'+opptyAfr);
      if(opptyBfr.BRS_Opportunity_Nbr__c != opptyAfr.BRS_Opportunity_Nbr__c){
        //The BRS Opportunity Number has changed
        if(opptyBfr.BRS_Opportunity_Nbr__c !=null && opptyAfr.BRS_Opportunity_Nbr__c ==null){
          //The Opportunity is being de-linked from an existing BRS Opportunity
          emcBrsOppty2Del.add(opptyBfr.BRS_Opportunity_Nbr__c);  
        }
        if(opptyBfr.BRS_Opportunity_Nbr__c ==null && opptyAfr.BRS_Opportunity_Nbr__c!=null){
          // The EMC Opportunity is now being linked to a BRS Opportunity
          if(isOpportunityUpdated(opptyBfr,opptyAfr)){
            emcBrsOppty2Updt.add(createNewEMCBRSOppty(masterOpptyMap.get(opptyId)));
          } 
        }
        if(opptyBfr.BRS_Opportunity_Nbr__c !=null && opptyAfr.BRS_Opportunity_Nbr__c !=null){
          //The Opportunity is being re-linked to another BRS Opportunity
          //Remove the existing link
          emcBrsOppty2Del.add(opptyBfr.BRS_Opportunity_Nbr__c);
          //Create the new link with the corresponding BRS Opportunity
          emcBrsOppty2Updt.add(createNewEMCBRSOppty(masterOpptyMap.get(opptyId)));
        }
      }else{
        if(opptyAfr.BRS_Opportunity_Nbr__c!=null && isOpportunityUpdated(opptyBfr,opptyAfr)){
          emcBrsOppty2Updt.add(createNewEMCBRSOppty(masterOpptyMap.get(opptyId)));
        }
      }
    }
    if(!emcBrsOppty2Del.isEmpty()){
      markInactive(emcBrsOppty2Del);      
    }
    if(!emcBrsOppty2Updt.isEmpty()){
      List<Database.UpsertResult> results = Database.upsert(emcBrsOppty2Updt,EMC_BRS_Opportunity__c.EMC_Opportunity_Nbr__c);
    }
  }
    // Start - Added for 252624 to fix the currency conversion issue.  
  public double getConvertedCurrencyAmt(Opportunity opp,EMC_BRS_Opportunity__c emcbrsopp){
  	double c1;
  	CurrencyConversionHelper cch = new CurrencyConversionHelper();
  	Double b1 = emcbrsopp.BRS_Forecast_Amount__c;
  	if(opp.CurrencyISOCode == emcbrsopp.BRS_Currency_Type__c){
  		system.debug('in 1st if '+opp.CurrencyISOCode+' code '+emcbrsopp.BRS_Currency_Type__c);
  		return emcbrsopp.BRS_Forecast_Amount__c;
  	}
  	if(opp.CurrencyISOCode !=null && emcbrsopp.BRS_Currency_Type__c == 'USD'){
  		system.debug('in 2nd if '+opp.CurrencyISOCode+' code11 '+emcbrsopp.BRS_Currency_Type__c);
  		c1 = cch.convertFromUSD(b1, opp.CurrencyISOCode);
  				
  		//emcbrsopp.BRS_Forecast_Amount__c*conversionrateMap.get(opp.CurrencyISOCode);
  		return c1;
  	}
  	if(emcbrsopp.BRS_Currency_Type__c !=null && opp.CurrencyISOCode == 'USD'){
  		system.debug('in 3rd if '+opp.CurrencyISOCode+' code22 '+emcbrsopp.BRS_Currency_Type__c+' rate '+conversionrateMap.get(opp.CurrencyISOCode));
  		c1 = cch.convertToUSD(b1, emcbrsopp.BRS_Currency_Type__c);
  		//(emcbrsopp.BRS_Forecast_Amount__c/conversionrateMap.get(emcbrsopp.BRS_Currency_Type__c));
  		system.debug('before returning 33 '+c1);
  		return c1;
  	}
  	if(emcbrsopp.BRS_Currency_Type__c !=null && emcbrsopp.BRS_Currency_Type__c != 'USD' && opp.CurrencyISOCode !=null && opp.CurrencyISOCode != 'USD'){
  		system.debug('in 4th if '+opp.CurrencyISOCode+' code33 '+emcbrsopp.BRS_Currency_Type__c+ ' amount ' +emcbrsopp.BRS_Forecast_Amount__c);
  		c1 = cch.convertFromOnecurrenytypetoanother(b1, emcbrsopp.BRS_Currency_Type__c,opp.CurrencyISOCode);
  		//(emcbrsopp.BRS_Forecast_Amount__c/conversionrateMap.get(emcbrsopp.BRS_Currency_Type__c))*conversionrateMap.get(opp.CurrencyISOCode);
  		
  	}
  	system.debug('before returning  '+c1);
  	return c1;
  }
    // end - Added for 252624 to fix the currency conversion issue.  
  /*
  Method that checks if there were updates that were received through S2S from BRS Org
  and updates the corresponding values into the EMC Opportunity Header
  */
  public void updateEMCOpportunityFromBRS(List<EMC_BRS_Opportunity__c> emcOpptyList){
   
    List<Opportunity> opptyToUpdate = new List<Opportunity>();
    List<String> emcOpptyNbrs = new List<String>();
    List<Id> idsToDelink = new List<Id>();
    for(EMC_BRS_Opportunity__c brsOppty: emcOpptyList){
      if(brsOppty.Active__c){
        emcOpptyNbrs.add(brsOppty.EMC_Opportunity_Nbr__c);
      }
    }

    Map<String,Opportunity> opptyMap = new Map<String,Opportunity>();
//Ketan Benegal - To prevent non-selective query exception, put check on the size of emcOpptyNbrs. 
    if(!emcOpptyNbrs.isEmpty() && emcOpptyNbrs.size() > 0){
        for(Opportunity oppty: [select Opportunity_Number__c,Id, CurrencyISOCode 
                    from Opportunity
                    where Opportunity_Number__c in :emcOpptyNbrs]){
          opptyMap.put(oppty.Opportunity_Number__c,oppty);
        }
    }
    Opportunity oppty2Updt = new Opportunity();
    if(!opptyMap.isEmpty()){
      for(EMC_BRS_Opportunity__c brsOppty : emcOpptyList){
        if(brsOppty.Active__c && brsOppty!=null){
          oppty2Updt = opptyMap.get(brsOppty.EMC_Opportunity_Nbr__c);
          if(oppty2Updt!=null){
              oppty2Updt.BRS_Opportunity_Nbr__c=brsOppty.BRS_Opportunity_Nbr__c;
              oppty2Updt.BRS_Close_Date__c=brsOppty.BRS_Close_Date__c;
              oppty2Updt.BRS_Forecast_Status__c=brsOppty.BRS_Forecast_Status__c;
              // added for 252624
              if(brsOppty.BRS_Forecast_Amount__c!=null && brsOppty.BRS_Forecast_Amount__c!=0 && String.valueof(brsOppty.BRS_Forecast_Amount__c)!='')
                  oppty2Updt.BRS_Forecast_Amount__c=getConvertedCurrencyAmt(oppty2Updt,brsOppty);
              else
                  oppty2Updt.BRS_Forecast_Amount__c=brsOppty.BRS_Forecast_Amount__c ;
                  // added for 252624
              oppty2Updt.BRS_Quote_Amount__c=brsOppty.BRS_Quote_Amount__c;
              oppty2Updt.BRS_Account_Name__c=brsOppty.BRS_Account_Name__c;
              oppty2Updt.BRS_Account_Address__c=brsOppty.BRS_Account_Address__c;
              oppty2Updt.BRS_Partner_Name__c=brsOppty.BRS_Partner_Name__c;
              oppty2Updt.BRS_Reseller_Company__c=brsOppty.BRS_Reseller_Company__c;
              oppty2Updt.BRS_Date_Last_Modified__c=brsOppty.BRS_Date_Last_Modified__c;
              oppty2Updt.BRS_Rep_Name__c=brsOppty.BRS_Rep_Name__c;
              oppty2Updt.BRS_Product_Details__c=brsOppty.BRS_Product_Details__c;
              oppty2Updt.BRS_Total_Forecast_Amount__c=brsOppty.BRS_Total_Forecast_Amount__c;
              
          }
        }
      }                    
      update opptyMap.values();
    }
    
    
    System.debug('SFDCDEV***********emcOpptyList*****'+emcOpptyList);
    for(EMC_BRS_Opportunity__c emcOppty : emcOpptyList){
      if(!emcOppty.Active__c){
        //If hte Oppty is in the list of Opportunites that were
        //updated earlier, then no need to blank out hte values 
        if(!opptyMap.containsKey(emcOppty.Opportunity__c)){
          idsToDelink.add(emcOppty.Id);
        }
      }
    }
     System.debug('SFDCDEV***********idsToDelink*****'+idsToDelink);
    if(!idsToDelink.isEmpty()){
      delinkOpportunitiesFromBRS(idsToDelink);
    }
   
  }
  
  public void updateEMCOpportunityInfo(List<EMC_BRS_Opportunity__c> emcOpptyList){
    List<String> emcOpptyNbrs = new List<String>();
    for(EMC_BRS_Opportunity__c emcOppty: emcOpptyList){
      //If an account name is present, then it's not a
      //record that was inserted via S2S but a record that was inserted as a result
      //of linking a EMC Oppty to an BRS Oppty
      if(emcOppty.EMC_Account_Name__c==null){
        emcOpptyNbrs.add(emcOppty.EMC_Opportunity_Nbr__c);
      }
    }
    system.debug('inside updateEMCOpportunityInfo');
    updateEMCOpptytoBRS(emcOpptyNbrs);
  }
  
  public void clearBRSOpptyData(Map<Id,Opportunity> opptyMapBfr,Map<Id,Opportunity> opptyMapAfr){
    Opportunity opptyBfr;
    for(Opportunity opptyAfr:opptyMapAfr.values()){
      opptyBfr = opptyMapBfr.get(opptyAfr.Id);
      if(opptyBfr.BRS_Opportunity_Nbr__c!=null && opptyAfr.BRS_Opportunity_Nbr__c==null){
        opptyAfr.BRS_Close_Date__c  =null;
        opptyAfr.BRS_Forecast_Status__c=null;
        opptyAfr.BRS_Forecast_Amount__c=null;
        opptyAfr.BRS_Quote_Amount__c=null;
        opptyAfr.BRS_Quote_Nbr__c=null;
        opptyAfr.BRS_Rep_Name__c=null;
        opptyAfr.BRS_Account_Name__c=null;
        opptyAfr.BRS_Account_Address__c=null;
        opptyAfr.BRS_Partner_Name__c=null;
        opptyAfr.BRS_Reseller_Company__c=null;
        opptyAfr.BRS_Date_Last_Modified__c=null;
        opptyAfr.BRS_Product_Details__c=null;
        opptyAfr.BRS_Total_Forecast_Amount__c=null;
      }      
    }
    system.debug('inside clearBRSOpptyData');
  }
  
  @future
  public static void updateEMCOpptytoBRS(List<String> emcOpptyNbrs){
    
    List<EMC_BRS_Opportunity__c> emcOppty2Updt = new List<EMC_BRS_Opportunity__c>();
    EMC_BRS_Opportunity__c emcOpptyShare;
    system.debug('inside updateEMCOpptytoBRS');
    for(Opportunity oppty:[  select   Id,
                    Account.Name,
                    Opportunity_Number__c,
                    CloseDate,
                    ForecastCategory,
                    StageName,
                    Amount,
                    Quote_Amount__c,
                    Account_Address__c,
                    Account.BillingStreet,
                    Account.BillingCity,
                    Account.BillingState,
                    Account.BillingPostalCode,
                    Account.BillingCountry,
                    Partner__r.Name,
                    Tier_2_Partner__r.Name,
                    LastModifiedDate,
                    AddressInformation__c,
                    EMC_BRS_Products__c,
                    EMC_BRS_Forecast_Amount__c,                  
                    Owner.Name
                from Opportunity 
                where Opportunity_Number__c in :emcOpptyNbrs])
    {
   
      emcOpptyShare = new EMC_BRS_Opportunity__c(EMC_Opportunity_Nbr__c=oppty.Opportunity_Number__c);
      emcOpptyShare.EMC_Opportunity_Nbr__c=oppty.Opportunity_Number__c;
      emcOpptyShare.EMC_Close_Date__c=oppty.CloseDate;
      emcOpptyShare.EMC_Forecast_Status__c=oppty.StageName;
      emcOpptyShare.EMC_Forecast_Amount__c=oppty.Amount;
      emcOpptyShare.EMC_Quote_Amount__c=oppty.Quote_Amount__c;
      emcOpptyShare.EMC_Account_Name__c=oppty.Account.Name;
      //emcOpptyShare.EMC_Account_Address__c=oppty.Account_Address__c;
      emcOpptyShare.EMC_Account_Address__c=oppty.AddressInformation__c;
      emcOpptyShare.EMC_Partner_Name__c=oppty.Partner__r.Name;
      emcOpptyShare.EMC_Tier_2_Partner__c=oppty.Tier_2_Partner__r.Name;
      emcOpptyShare.EMC_Date_Last_Modified__c=oppty.LastModifiedDate;
      emcOpptyShare.EMC_Rep_Name__c=oppty.Owner.Name;
      emcOpptyShare.EMC_Product_Details__c=oppty.EMC_BRS_Products__c;
      emcOpptyShare.CORE_Total_BRS_Forecast_Amount__c=oppty.EMC_BRS_Forecast_Amount__c;
      emcOpptyShare.currencyISOcode = oppty.CurrencyIsoCode;     
      emcOppty2Updt.add(emcOpptyShare);

    }
    upsert emcOppty2Updt EMC_BRS_Opportunity__c.EMC_Opportunity_Nbr__c;
  }
  
  @future
  public static void delinkOpportunitiesFromBRS(List<Id> emcBrsIdList){
    List<EMC_BRS_Opportunity__c> delinkOpptys = new List<EMC_BRS_Opportunity__c>();
    List<Id> localRecIds = new List<Id>();
    List<Opportunity> oppty2Updt = new List<Opportunity>();
    List<EMC_BRS_Opportunity__c> emcBrsToDelink= new List<EMC_BRS_Opportunity__c>(); 
    system.debug('inside delinkOpportunitiesFromBRS');
    for(EMC_BRS_Opportunity__c emcOppty : [select Id,Active__c,Opportunity__c from EMC_BRS_Opportunity__c where Id in :emcBrsIdList])
    {
    	System.debug('SFDCDEV*********emcOppty*******'+emcOppty);
    	System.debug('SFDCDEV*********emcOppty.Opportunity__c*******'+emcOppty.Opportunity__c);
      if(emcOppty.Opportunity__c!=null){
        localRecIds.add(emcOppty.Id);
        oppty2Updt.add(new Opportunity(  Id=emcOppty.Opportunity__c,
                        BRS_Account_Name__c=null,
                        BRS_Account_Address__c =null,
                        BRS_Close_Date__c=null,  
                        BRS_Forecast_Status__c=null,  
                        BRS_Forecast_Amount__c=null,  
                        BRS_Rep_Name__c=null,  
                        BRS_Opportunity_Nbr__c=null,  
                        BRS_Order_Nbr__c=null,  
                        BRS_Partner_Name__c=null,  
                        BRS_Quote_Amount__c=null,  
                        BRS_Quote_Nbr__c=null,
                        BRS_Date_Last_Modified__c=null,
                        BRS_Product_Details__c=null,
                        BRS_Total_Forecast_Amount__c=null,
                        BRS_Reseller_Company__c=null));
      }
    }
    if(!oppty2Updt.isEmpty()){
      update oppty2Updt;
    }
    List<PartnerNetworkRecordConnection> recsToDel = [  select Id 
                              from PartnerNetworkRecordConnection 
                              where LocalRecordId in :localRecIds
                              and Status='Connected'];
    delete recsToDel;
  }
  
  private Boolean isUpdated(EMC_BRS_Opportunity__c recBfr,EMC_BRS_Opportunity__c recAfr){
    Boolean updated = false;
    system.debug('inside isUpdated for BRS_FIELDS_TO_COMPARE');
    for(String fldName: BRS_FIELDS_TO_COMPARE){
      if(recBfr.get(fldName) != recAfr.get(fldName)){
        updated = true;
        break;
      }
    }
    return updated;
  }
  /*
  Helper method that compares the opportunity before and after to
  determine if hte fields that are being shared with BRS have
  been updated.Returns true if atleast 1 field is updated.
  */
  private Boolean isOpportunityUpdated(Opportunity recBfr,Opportunity recAfr){
    Boolean updated = false;
    system.debug('inside isOpportunityUpdated for OPPTY_FIELDS_TO_COMPARE');
    if(recBfr==null || recAfr==null){
      return true;
    }
    for(String fldName: OPPTY_FIELDS_TO_COMPARE){
    system.debug('recBfr.get(fldName)'+recBfr.get(fldName));
     system.debug('recAfr.get(fldName)'+recAfr.get(fldName));
      if(recBfr.get(fldName) != recAfr.get(fldName)){
        updated = true;
        break;
      }
    }    
    return updated;
  }
  
  private EMC_BRS_Opportunity__c createNewEMCBRSOppty(Opportunity oppty){
    system.debug('inside createNewEMCBRSOppty');
   
    return new EMC_BRS_Opportunity__c(  Opportunity__c=oppty.Id,
                      EMC_Opportunity_Nbr__c=oppty.Opportunity_Number__c,
                      BRS_Opportunity_Nbr__c=oppty.BRS_Opportunity_Nbr__c,
                      EMC_Close_Date__c=oppty.CloseDate,                      EMC_Forecast_Status__c=oppty.StageName,
                      EMC_Forecast_Amount__c=oppty.Amount,
                      EMC_Quote_Amount__c=oppty.Quote_Amount__c,
                      EMC_Account_Name__c=oppty.Account.Name,
                      EMC_Account_Address__c=oppty.AddressInformation__c,
                      EMC_Partner_Name__c=oppty.Partner__r.Name,
                      EMC_Rep_Name__c=oppty.Owner.Name,
                      EMC_Tier_2_Partner__c=oppty.Tier_2_Partner__r.Name,
                      EMC_Date_Last_Modified__c=oppty.LastModifiedDate,
                      EMC_Product_Details__c=oppty.EMC_BRS_Products__c,
                      CORE_Total_BRS_Forecast_Amount__c =oppty.BRS_Product_Forecast__c,//EMC_BRS_Forecast_Amount__c(removed)
                      ///start  
                      EMC_Order_Nbr__c=oppty.SO_Number__c,
                      EMC_Quote_Nbr__c=oppty.Quote_Cart_Number__c,
                      EMC_Opportunity_Name__c=oppty.Name,                    
                      //end
                      //Added for 252624 to fix currency conversion issue
                      currencyISOcode = oppty.CurrencyIsoCode,
                      Active__c=true);
  }
  
  private Opportunity createOpptyFromBRSData(Opportunity oppty,EMC_BRS_Opportunity__c brsOppty){
    system.debug('inside createOpptyFromBRSData');
    return oppty;    
  }
  /*
  Method to mark a EMC_BRS_Opportunity Record as "inactive". It also sets all the fields to "null"
  so that the data when sent over to the other Org is also blanked out.
  */
  private void markInactive(List<String> brsOpptyNbrs){
        system.debug('inside markInactive');
    List<EMC_BRS_Opportunity__c> recsToUpdt = new List<EMC_BRS_Opportunity__c>();
    for(EMC_BRS_Opportunity__c emcBrsOppty:[select   Id,
                            Active__c,
                            EMC_Opportunity_Nbr__c,  
                            BRS_Opportunity_Nbr__c,  
                            EMC_Close_Date__c,    
                            EMC_Forecast_Status__c,  
                            EMC_Forecast_Amount__c,  
                            EMC_Quote_Amount__c,  
                            EMC_Account_Name__c,  
                            EMC_Account_Address__c,  
                            EMC_Partner_Name__c,
                            EMC_Rep_Name__c,
                            EMC_Order_Nbr__c,
                            EMC_Quote_Nbr__c, 
                            CurrencyISOCode,   
                            BRS_Close_Date__c,    
                            BRS_Forecast_Status__c,  
                            BRS_Forecast_Amount__c,  
                            BRS_Quote_Amount__c,  
                            BRS_Account_Name__c,  
                            BRS_Account_Address__c,  
                            BRS_Partner_Name__c,
                            BRS_Rep_Name__c,
                            BRS_Order_Nbr__c,
                            BRS_Quote_Nbr__c,
                            BRS_Currency_Type__c,
                            BRS_Reseller_Company__c,
                            EMC_Tier_2_Partner__c,
                            BRS_Date_Last_Modified__c,
                            EMC_Date_Last_Modified__c,
                            EMC_Product_Details__c,
                            BRS_Product_Details__c,
                            CORE_Total_BRS_Forecast_Amount__c,  
                            BRS_Total_Forecast_Amount__c                           
                        from   EMC_BRS_Opportunity__c 
                        where   BRS_Opportunity_Nbr__c in :brsOpptyNbrs])
    {
      //Set Active Flag to "false"
      emcBrsOppty.Active__c=false;
      //Set all other fields to "null"
      emcBrsOppty.EMC_Opportunity_Nbr__c=null;  
      emcBrsOppty.BRS_Opportunity_Nbr__c=null;  
      emcBrsOppty.EMC_Close_Date__c=null;    
      emcBrsOppty.EMC_Forecast_Status__c=null;  
      emcBrsOppty.EMC_Forecast_Amount__c=null;  
      emcBrsOppty.EMC_Quote_Amount__c=null;  
      emcBrsOppty.EMC_Account_Name__c=null;  
      emcBrsOppty.EMC_Account_Address__c=null;  
      emcBrsOppty.EMC_Partner_Name__c=null;
      emcBrsOppty.Opportunity__c=null;
      emcBrsOppty.BRS_Close_Date__c=null;
      emcBrsOppty.BRS_Forecast_Status__c=null;
      emcBrsOppty.BRS_Forecast_Amount__c=null;
      emcBrsOppty.BRS_Quote_Amount__c=null;
      emcBrsOppty.BRS_Account_Name__c=null;
      emcBrsOppty.BRS_Account_Address__c=null;
      emcBrsOppty.BRS_Partner_Name__c=null;
      emcBrsOppty.BRS_Rep_Name__c=null;
      emcBrsOppty.BRS_Order_Nbr__c=null;
      emcBrsOppty.BRS_Quote_Nbr__c=null;
      emcBrsOppty.EMC_Tier_2_Partner__c=null;
      emcBrsOppty.BRS_Reseller_Company__c=null;
      emcBrsOppty.EMC_Date_Last_Modified__c=null;
      emcBrsOppty.BRS_Date_Last_Modified__c=null;
      emcBrsOppty.EMC_Product_Details__c=null;
      emcBrsOppty.BRS_Product_Details__c=null;
      emcBrsOppty.CORE_Total_BRS_Forecast_Amount__c=null; 
      emcBrsOppty.BRS_Total_Forecast_Amount__c=null;
      emcBrsOppty.currencyISOCode = null;
      emcBrsOppty.BRS_Currency_Type__c= null;
      recsToUpdt.add(emcBrsOppty);
    }                          

    List<Database.SaveResult> updateResults= Database.update(recsToUpdt);    
  }
  
  
    public void deleteExistingEMC_BRS_OpportunityRecords(List<EMC_BRS_Opportunity__c> lstEMCBRSOpportunity){
      if(lstEMCBRSOpportunity != null && lstEMCBRSOpportunity.size() >0){
        Set<String> setEMCOpportunityNbr = new Set<String>();
        Set<String> setBRSOpportunityNbr = new Set<String>();
        for(EMC_BRS_Opportunity__c objEMCBRSOpp :lstEMCBRSOpportunity){
          if(objEMCBRSOpp.EMC_Opportunity_Nbr__c != null){
            setEMCOpportunityNbr.add(objEMCBRSOpp.EMC_Opportunity_Nbr__c);
          }
          if(objEMCBRSOpp.BRS_Opportunity_Nbr__c != null){
            setBRSOpportunityNbr.add(objEMCBRSOpp.BRS_Opportunity_Nbr__c);
          }
        }
        
        if(setEMCOpportunityNbr.size() > 0 || setBRSOpportunityNbr.size() >0){
          List<EMC_BRS_Opportunity__c> lstDeleteEMCBRSOpp = [Select Id from EMC_BRS_Opportunity__c 
                        where EMC_Opportunity_Nbr__c in:setEMCOpportunityNbr
                           or BRS_Opportunity_Nbr__c in:setBRSOpportunityNbr];  
          if(lstDeleteEMCBRSOpp != null && lstDeleteEMCBRSOpp.size() >0){
            delete lstDeleteEMCBRSOpp;
          }
        }
      }     
    }
}