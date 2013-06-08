/**

Created By		:	Avinash Kaltari
Created Date	:	22 May 2012
Purpose			:	To increase the coverage of Field class

*/
@isTest
private class Field_TC 
{

    static testMethod void FieldTest() 
    {
    	
    	Field x = new Field('Test');
    	x = x.toLabelx();
    	String str = x.toSoql();
    }
    
}