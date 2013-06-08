/*===================================================================================================================================
|22/01/2011      Accenture                              Updated trigger to incorporate ByPass Logic
|                                                       NOTE: Please write all the code after BYPASS Logic 
 ===================================================================================================================================*/

trigger Update_Forecast_Amount_to_Quote_Amount on Opportunity (after update) {
    //Trigger BYPASS Logic
      if(CustomSettingBypassLogic__c.getInstance()!=null){
          if(CustomSettingBypassLogic__c.getInstance().By_Pass_Opportunity_Triggers__c){
                    return;
          }
       }
    
        List<Opportunity> OppRecs=new List<Opportunity>();
        new ForecastAmount2QuoteAmount().updateOpplineitems(Trigger.NewMap,Trigger.OldMap);
  }