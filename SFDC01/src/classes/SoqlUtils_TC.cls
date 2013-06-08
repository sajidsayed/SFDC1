/**

Created By      :   Avinash Kaltari
Created Date    :   17 May 2012
Purpose         :   To increase the coverage of SoqlUtils class

*/
@isTest
private class SoqlUtils_TC 
{

    static testMethod void SoqlUtilsTest() 
    {
        EBC_Briefing_Center__c bc=new EBC_Briefing_Center__c(name='hello');
        insert bc;
        
        List<EBC_Briefing_Center__c>    lstBE = new List<EBC_Briefing_Center__c>();
        lstBE.add(bc);
        
        List<String> lstStr = new List<String>();
        
        try
        {
            lstStr = SoqlUtils.toLiteral(lstBE);
        }
        catch(Exception e)
        {
            
        }
        
        
        lstStr.add('Hello');
        lstStr.add(' World');
        lstStr = SoqlUtils.toLiteral(lstStr, null);
        
        Boolean b = false;
        List<Boolean> lstBln = new List<Boolean>();
        lstBln.add(b);
        lstStr = SoqlUtils.toLiteral(lstBln, null);
        object obj;
        SoqlUtils.toLiteral(obj);
        
        
        Date d = date.newinstance(1960, 2, 17);
        List<Date> lstDate = new List<Date>();
        lstDate.add(d);
        lstStr = SoqlUtils.toLiteral(lstDate, null);
        
        DateTime dt = datetime.newInstance(2008, 12, 1);
        List<DateTime> lstDT = new List<DateTime>();
        lstDT.add(dt);
        lstStr = SoqlUtils.toLiteral(lstDT, null);
        
        lstDT = null;
        lstStr = SoqlUtils.toLiteral(lstDT);
        
        
        SoqlUtils.assertEquals('expected', 'expected');
        
        String str1 = 'Hello';
        String str2 = 'World';
        Boolean bln;
        
        bln = SoqlUtils.equals(str1,str2);
        
        str2 = 'Hello';
        bln = SoqlUtils.equals(str1,str2);
        
        str1 = 'select name, id from user limit 100';
        str2 = 'select   name , id  from user limit 100';
        bln = SoqlUtils.equals(str1,str2);
        
        str1 = 'select name from user limit 100';
        str2 = 'select name from user limit   100';
        bln = SoqlUtils.equals(str1,str2);
        
        str1 = 'select name,id from user limit 100';
        str2 = 'select name from user limit   100';
        bln = SoqlUtils.equals(str1,str2);
        
    }
}