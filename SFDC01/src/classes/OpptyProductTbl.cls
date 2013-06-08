global class OpptyProductTbl {

    webservice string ProductName;
    webservice Double QuoteAmount;
    webservice Double ForecastAmount;
    
    global string getProductName(){
        return this.ProductName;
    } 
    global Double getQuoteAmount(){
        return this.QuoteAmount;
    } 
    global Double getForecastAmount(){
        return this.ForecastAmount;
    } 
    global void setProductName(String prod){
        this.ProductName=prod;
    }
    global void setQuoteAmount(Double Quoteamt){
        this.QuoteAmount=Quoteamt;
    }
    global void setForecastAmount(Double forecastamt){
        this.ForecastAmount=forecastamt;
    }
 public List<OpptyProductTbl> getProductList(String sfdcOppyId){
     List <OpptyProductTbl> ProductList= new  List <OpptyProductTbl>();
    for ( OpportunityLineItem p : [SELECT UnitPrice,Quote_Amount__c,PricebookEntry.Product2.Name 
                                            FROM OpportunityLineItem WHERE OpportunityId =: sfdcOppyId]){
       
        OpptyProductTbl  product= new OpptyProductTbl ();
            product.ProductName = p.PricebookEntry.Product2.Name;
            product.QuoteAmount= p.Quote_Amount__c;
            product.ForecastAmount= p.UnitPrice;
        ProductList.add(product);
       }
      return ProductList;
    }
}