/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |                                              Initial Creation.
 |  Aug-2011        Saravanan C         		Test Class cleanup
 |  
 +===========================================================================*/
@isTest
Private Class OpptyProductTbl_TC{
    Private static testMethod void startTest(){
        OpptyProductTbl OppProd=new OpptyProductTbl();
        Opportunity Opp=[Select id from Opportunity limit 1];
        OppProd.getProductList(Opp.id);
        OppProd.getProductName();
        OppProd.getForecastAmount();
        OppProd.getQuoteAmount();
        OppProd.setProductName('Test Product');
        OppProd.setQuoteAmount(12);
        OppProd.setForecastAmount(15);
    }
}