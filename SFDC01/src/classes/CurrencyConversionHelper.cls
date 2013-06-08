/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    03-Nov-2010     Pratibh Prakash                         Helper class which contains method to convert a given
                                                            Amount in a particular Currency to USD.
    12-May-2013 	Sravanthi           252624				Added methods- convertFromUSD and convertFromOnecurrenytypetoanother                                       
==============================================================================*/
public class CurrencyConversionHelper 
{
    
    private static Map<String, Double> conversionRateMap = new Map<String, Double>();//Map to store Currency IsoCode and corresponding conversion rate.
    
    private void initiateConversionMap()
    {
//        for(DatedConversionRate conRate: [Select IsoCode, ConversionRate From DatedConversionRate]){
        for(CurrencyType conRate: [Select IsoCode, ConversionRate From CurrencyType]){
            conversionRateMap.put(conRate.IsoCode, conRate.ConversionRate);
        }
    } 
    
    public Double convertToUSD(Double amount, String currencyCode)
    {
        if(amount == null)
              amount = 0;
        if(conversionRateMap.size()==0){
            initiateConversionMap();
        }
        System.debug('MY CONVERTER CODE = '+currencyCode);
        System.debug('MY CONVERTER RATE = '+conversionRateMap.get(currencyCode));
        if(conversionRateMap.get(currencyCode)!=null){
            return (amount/conversionRateMap.get(currencyCode));
        }
        else{
            throw new EMCException('Currency Code not found in Currency Rate records.','0',new List<String>());
        }
    }
    public Double convertFromUSD(Double amount, String currencyCode)
    {
        if(amount == null)
              amount = 0;
        if(conversionRateMap.size()==0){
            initiateConversionMap();
        }
        System.debug('MY CONVERTER CODE1 = '+currencyCode);
        System.debug('MY CONVERTER RATE1 = '+conversionRateMap.get(currencyCode));
        if(conversionRateMap.get(currencyCode)!=null){
            return (amount*conversionRateMap.get(currencyCode));
        }
        else{
            throw new EMCException('Currency Code not found in Currency Rate records.','0',new List<String>());
        }
    }
     public Double convertFromOnecurrenytypetoanother(Double amount, String currencyCode1,String currencyCode2)
    {
        if(amount == null)
              amount = 0;
        if(conversionRateMap.size()==0){
            initiateConversionMap();
        }
        System.debug('MY CONVERTER CODE2 = '+currencyCode1);
        System.debug('MY CONVERTER RATE 2= '+conversionRateMap.get(currencyCode1));
        if(conversionRateMap.get(currencyCode1)!=null && conversionRateMap.get(currencyCode2)!=null){
            return ((amount/conversionRateMap.get(currencyCode1))*conversionRateMap.get(currencyCode2));
        }
        else{
            throw new EMCException('Currency Code not found in Currency Rate records.','0',new List<String>());
        }
    }
    
    
}