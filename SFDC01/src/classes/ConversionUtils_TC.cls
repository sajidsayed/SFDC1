/**

Created By		:	Avinash Kaltari
Created Date	:	16 May 2012
Purpose			:	To increase the coverage of ConversionUtils class

*/
@isTest
private class ConversionUtils_TC 
{

    static testMethod void ConversionUtilsTest() 
    {
        
        Double conversion = ConversionUtils.convert(20, UnitOfLength.KILOMETERS, UnitOfLength.MILES);
        conversion = ConversionUtils.convert(20, UnitOfLength.MILES, UnitOfLength.KILOMETERS);
        conversion = ConversionUtils.convert(null, UnitOfLength.MILES, UnitOfLength.KILOMETERS);
        
    }
}