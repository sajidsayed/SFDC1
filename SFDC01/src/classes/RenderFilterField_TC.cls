/**

Created By		:	Avinash Kaltari
Created Date	:	25 May 2012
Purpose			:	To increase the coverage of RenderFilterField class

*/
@isTest
private class RenderFilterField_TC 
{

    static testMethod void RenderFilterFieldTest() 
    {
        RenderField field1 = new RenderField('Account', Account.Profile_Published_to_Partner_Finder__c.getDescribe());
        RenderField field2= new RenderField('Account', Account.Profile_Published_to_Partner_Finder__c.getDescribe());
        RenderField field3 = new RenderField('Account', Account.Profile_Published_to_Partner_Finder__c.getDescribe());
        RenderField field4 = new RenderField('Account', Account.Profile_Published_to_Partner_Finder__c.getDescribe());
        RenderField field5 = new RenderField('Account', Account.Profile_Published_to_Partner_Finder__c.getDescribe());
        
        List<RenderField> lstrf = new List<RenderField>();
        lstrf.add(field1);
        lstrf.add(field2);
        lstrf.add(field3);
        lstrf.add(field4);
        
        
        List<RenderFilterField> lstrff = RenderFilterField.putFilterFieldList(lstrf);
        
        lstrf.add(field5);
        lstrff = RenderFilterField.putFilterFieldList(lstrf);
        
        lstrf.add(field5);
        lstrf.add(field5);
        lstrf.add(field5);
        lstrf.add(field5);
        lstrff = RenderFilterField.putFilterFieldList(lstrf);
        
    }
}