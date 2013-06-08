/**

Created By		:	Avinash Kaltari
Created Date	:	18 May 2012
Purpose			:	To increase the coverage of SetOfThreeSearchFields class

*/
@isTest
private class SetOfThreeSearchFields_TC 
{

    static testMethod void SetOfThreeSearchFieldsTest() 
    {
    	//SetOfThreeSearchFields objSet = new SetOfThreeSearchFields();
    	
		FieldConfiguration fc1 = new FieldConfiguration('Account','Name','Name');
	
    	SearchField sf1 = new SearchField(fc1);
    	SearchField sf2 = new SearchField(fc1);
    	SearchField sf3 = new SearchField(fc1);
    	
    	List<SearchField> lstsf = new List<SearchField>();
    	lstsf.add(sf1);
    	lstsf.add(sf2);
    	lstsf.add(sf3);
    	lstsf.add(sf1);
    	lstsf.add(sf2);
    	
    	List<SetOfThreeSearchFields> lst = SetOfThreeSearchFields.createFromList(lstsf);
    	
    	lstsf.clear();
    	lst = SetOfThreeSearchFields.createFromList(lstsf);
    	
    	lstsf.add(sf1);
    	lst = SetOfThreeSearchFields.createFromList(lstsf);
    	
    	
    	
    }
}