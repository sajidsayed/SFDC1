/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |  18 Nov 2010   Srinivas  150894  Test Class for covering all the methods of
 |                                   'CurrencyConversionHelper' class
 | 
  +===========================================================================*/
@isTest
private class CurrencyConversionHelper_TC {
   
   /* @Method <This method is used to test the function with different conditions>
   @param <This method does not take any parameter>
   @return <void> - <This method does not return anything>
   @throws exception - <No Exception>
    */  
    static testMethod void testCurrencyConversionHelper() {
        CurrencyConversionHelper CCH = new CurrencyConversionHelper();
        Double amt;
        CCH.convertToUSD(amt, 'EUR');
        CCH.convertToUSD(50000, 'EUR');
        try{
            CCH.convertToUSD(50000, 'XXX');
        }catch(EMCException e){
            system.assertEquals('Currency Code not found in Currency Rate records.', e.getmessage());
        }
    }
}