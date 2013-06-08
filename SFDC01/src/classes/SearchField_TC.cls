/**

Created By		:	Avinash Kaltari
Created Date	:	18 May 2012
Purpose			:	To increase the coverage of SetOfThreeSearchFields class

*/
@isTest
private class SearchField_TC 
{

    static testMethod void myUnitTest() 
    {
    	FieldConfiguration fc1 = new FieldConfiguration('Account','Name','Name');
    	FieldConfiguration fc2 = new FieldConfiguration('Account','CurrencyIsoCode','');
    	FieldConfiguration fc3 = new FieldConfiguration('Account','Date_Manager_Prioritized__c','Date_Manager_Prioritized__c');
    	
    	List<FieldConfiguration> lstFc = new List<FieldConfiguration>();
    	lstFc.add(fc1);
    	lstFc.add(fc2);
    	lstFc.add(fc3);
    	
    	List<SearchField> lstsf = SearchField.build(lstFc);
    	
    	
    	lstsf = SearchField.filterOutUnsupportedTypes(lstsf);
    }
}