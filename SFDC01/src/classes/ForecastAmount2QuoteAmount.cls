/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER           WR       DESCRIPTION                               
 |  ====       =========           ==       =========== 
 |  20.02.10   Abhishek Arya                To Override the Forecast Amount from Quote Amount of Opportunity if "Update Forecast Amount from Quote" Field's checkbox is true and Cart Number is not null.             
 |                                    
 |  15.03.2010 Prasad Kothawade             Condition Added(Quote Amount is not equal to null)                   
 +===========================================================================*/
public class ForecastAmount2QuoteAmount{
    Static Boolean ForecastAmount2QuoteAmountExecuted=false;
    public void updateOpplineitems(Map<Id,Opportunity> NewOppyRecMap,Map<Id,Opportunity> OldOppyRecMap){    
    if(ForecastAmount2QuoteAmountExecuted){
       // return;
    }
    ForecastAmount2QuoteAmountExecuted=true;
    List<String> Oppids=new List<String>();
    //Map<String,String> OpplineitemMap=new Map<String,String>();
    for(Id id:NewOppyRecMap.keyset()){
          Opportunity newoppcheck=NewOppyRecMap.get(id);
          Opportunity Oldoppcheck=OldOppyRecMap.get(id);
          if(Newoppcheck.Update_Forecast_Amount_from_Quote__c==true && newoppcheck.Quote_Amount__c!=null  && newoppcheck.Amount!=null  && newoppcheck.Quote_Amount__c.setScale(2) != newoppcheck.Amount.setScale(2) ){
 
              Oppids.add(id);
          }
      }    
      if(Oppids.size()==0){
          return;
      }
         System.debug('Oppids '+Oppids);
          
         List<OpportunityLineItem> Opplineitems = [select OpportunityId,UnitPrice,Quote_Amount__c from OpportunityLineItem
         where OpportunityId in :OppIds];
 
          for(OpportunityLineItem OppLine : Opplineitems){
              // OpplineitemMap.put(OppLine.Id,OppLine.OpportunityId);   
               //Changed By kothap(If Quote Amount is not equal to null,this condition is added).
               if(OppLine.Quote_Amount__c!=null){ 
                   System.debug('OppLine.UnitPrice'+OppLine.UnitPrice);  
                   OppLine.UnitPrice=OppLine.Quote_Amount__c;
                   OppLine.Bypass_Opportunity_Line_item_Validations__c=true;
                   System.debug('OppLine.UnitPrice'+OppLine.UnitPrice);
               }
          }
          Database.saveresult[] saveresult=Database.update(Opplineitems,false);
          Integer j=0;
          for(Database.saveresult sr:saveresult){
              if(sr.IsSuccess()){
                  j++;
              }
              else{
                  Database.Error err = sr.getErrors()[0];
                  Opportunity Opperr=NewOppyRecMap.get(Opplineitems.get(j).OpportunityId);
                  Opperr.adderror(err.getMessage());
              }
          }
  }
}