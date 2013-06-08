/*=====================================================================================================================================

History 
15th Oct 12  Hemavathi N M        Added the code for SFDC Transformation Opportunity Productfunctionality
                                  This class is used to update opportunitylineitem when an product is added to respective oppty
                                  or when product name is changed all the opptylineitem mapped with the product will be updated.
                                  
======================================================================================================================================*/
public class Transformation_OpptyProductOperations{
    
public static boolean isProductUpdated = false ;

//Method : This method is called before update of opptylineitem to insert a value to certain field upon adding product to oppty
 public void insertOpptyProduct(Map<Id,OpportunityLineItem> newOpptyMap){
 
  if(!isProductUpdated){
  if(newOpptyMap.size() >0){    
        Map<Id,Id> mapPriceEntryID = new Map<Id,Id>();
    List<PricebookEntry> lstPBE = new List<PricebookEntry>(); 
    
    Map<Id,Id>mapPriceEntryValidID = new Map<Id,Id>();
 
    for(OpportunityLineItem objOLI : newOpptyMap.values())
    {
        mapPriceEntryID.put(objOLI.Id,objOLI.PricebookEntryId);
        
    } 
 
 // To retrieve the value of custom settings  
    List<String> lstProductName= new List<String>();
    Map<String,Transformation_ProdcutList__c> mapCustomSettingProductList = Transformation_ProdcutList__c.getall();
    if(mapCustomSettingProductList.size()>0){
            lstProductName.addAll(mapCustomSettingProductList.KeySet());
       }
    
 // End of Custom Setting
    
    if(mapPriceEntryID.size()>0){
    lstPBE =[SELECT  Id, Pricebook2Id, ProductCode, Product2Id, Name FROM PricebookEntry where Id IN: mapPriceEntryID.Values() and Name IN: lstProductName and Product2.isActive = true];
    
    if(lstPBE.size()>0){
        for(PricebookEntry priceBookObj1 : lstPBE){
            mapPriceEntryValidID.put(priceBookObj1.Id,priceBookObj1.Id);
        }
     }
    }
  if(mapPriceEntryValidID.size()>0){
    for(OpportunityLineItem objOLI : newOpptyMap.values())
     {
        if(objOLI.PricebookEntryId == mapPriceEntryValidID.get(objOLI.PricebookEntryId))
        {
            objOLI.Secondary_Forecast_Summary_Type__c = System.Label.Transformation_Consulting; 
        }
        else{
            objOLI.Secondary_Forecast_Summary_Type__c = System.Label.Transformation_n_a;
           }
      }
     }
    
    } 
   // isProductUpdated = true;
  } //IF : End (isProductUpdated)
 }// Method : End

/* Not IN REQ
// Method : To Update OLE when Product Name is updated and this method is called after update of product
public void updateOpptyProduct(List<Product2> productObjLst){
    List <OpportunityLineItem> objOLI = new List <OpportunityLineItem>();
    objOLI = [SELECT  Id, OpportunityId, PricebookEntryId,PricebookEntry.Product2Id FROM OpportunityLineItem where PricebookEntry.Product2Id IN: productObjLst and PricebookEntry.Product2.isActive = true limit 5000];   
      if(objOLI!=null && objOLI.size()>0)
            {
             
                Set<Id> setOppIdstemp = new set<Id>();

                    for(Integer i=0; i<objOLI.size(); i++)
                    {
                        setOppIdstemp.add(objOLI.get(i).Id);
                        if(setOppIdstemp.size() ==10000){
                            updateOpportunityLineItem(setOppIdstemp); 
                            setOppIdstemp = new set<Id>(); 
                        }
                    }
                
                    if(setOppIdstemp.size() > 0){
                        
                       
                            updateOpportunityLineItem(setOppIdstemp);
                    }                      
                     
            }
  } // Method : End
  
 
// Method : Start 
  @future (callout=true)
    public static void updateOpportunityLineItem(Set<Id> opportunityLineItemIds ){
        isProductUpdated = true;

// To retrieve the value of custom settings  
    List<String> lstProductName= new List<String>();
    Map<Id,Id> mapPriceEntryID = new Map<Id,Id>();
    Map<string,string> mapProductName= new Map<string,string>();
    Map<String,Transformation_ProdcutList__c> mapCustomSettingProductList = Transformation_ProdcutList__c.getall();
    if(mapCustomSettingProductList.size()>0){
            lstProductName.addAll(mapCustomSettingProductList.KeySet());
            for(String pName : mapCustomSettingProductList.KeySet()){
            mapProductName.put(pName,pName);
            }
            System.debug('mapProductName==>' + mapProductName);
         }
    
// End of Custom Setting
         
        List<OpportunityLineItem> lstOpportunityLineItem = [SELECT  Id, OpportunityId, PricebookEntryId,PricebookEntry.Product2Id,PricebookEntry.Name FROM OpportunityLineItem where  id IN:opportunityLineItemIds ];  
      
        List<OpportunityLineItem> lstTempOpportunityLineItem = new List<OpportunityLineItem>();
        
        for(OpportunityLineItem oliObj: lstOpportunityLineItem){
            
            if(oliObj.PricebookEntry.Name == mapProductName.get(oliObj.PricebookEntry.Name)){
                oliObj.Secondary_Forecast_Summary_Type__c =System.Label.Transformation_Consulting;  
            }
            else{
                oliObj.Secondary_Forecast_Summary_Type__c =System.Label.Transformation_n_a;
            }
            lstTempOpportunityLineItem.add(oliObj);
        
        }
        if(lstTempOpportunityLineItem.size() == 1000){
            try{
                Database.SaveResult[] saveRes =   Database.update( lstTempOpportunityLineItem, false);
            
                lstTempOpportunityLineItem.clear();
             
                }catch(Exception ex){
                 throw ex;
                } 
         }
            
        if(lstTempOpportunityLineItem.size()>0)
        {
            try{
                Database.SaveResult[] saveRes =  Database.update(lstTempOpportunityLineItem, false);
            
          }catch(Exception ex){
              throw ex;
             } 
     }      
  }// Method : End  
 */
}