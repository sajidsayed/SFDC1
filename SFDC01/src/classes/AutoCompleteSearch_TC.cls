/**

Created By		:	Avinash Kaltari
Created Date	:	25 May 2012
Purpose			:	To increase the coverage of AutoCompleteSearch class

*/
@isTest
private class AutoCompleteSearch_TC 
{

    static testMethod void AutoCompleteSearchTest() 
    {
        AutoCompleteSearch acs = new AutoCompleteSearch('search a');
        try
        {
        	acs = new AutoCompleteSearch('s');
        }
        catch(Exception e)
        {
        	
        }
        
        List<string> lst = acs.execute();
    }
}