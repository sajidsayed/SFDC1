/**

Created By		:	Avinash Kaltari
Created Date	:	25 May 2012
Purpose			:	To increase the coverage of OrderBy class

*/
@isTest
private class OrderBy_TC 
{

    static testMethod void OrderByTest() 
    {
        OrderBy o;
        try
        {	
        	o = new OrderBy('');
        }
        catch(Exception e)
        {
        	
        }
        
        o = new OrderBy('hello');
        o = o.descending();
        o = o.nullsFirst();
        o = o.nullsLast();
        
       String str = o.toSoql();
        
    }
}