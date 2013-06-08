/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |  06 Mar     Avinash K              Initial Creation. To Cover the DetailLineigger               
 |  
 +===========================================================================*/
 
@isTest
private class DetailLine_TC 
{

    static testMethod void myUnitTest() 
    {
        Detail_Line__c objDetailLine = new Detail_Line__c(name='Test', Opportunity_Access_Level__c='Edit', CurrencyIsoCode = 'USD', Split__c=200.00);
        insert objDetailLine;
        objDetailLine.Split__c = 201.00;
        update objDetailLine;
    }
}