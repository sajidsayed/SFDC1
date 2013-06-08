/**

Created By      :   Avinash Kaltari
Created Date    :   24 May 2012
Purpose         :   To increase the coverage of Field EmailMaskingTool

*/

@isTest
public class EmailMaskingTool_TC 
{
     public static testMethod void EmailMaskingTool () 
    {
       EmailMaskingTool emailToolNew=new EmailMaskingTool();
       emailToolNew.batchSize ='200';
       emailToolNew.AppendText='Test';
       emailToolNew.selectedFields= new List<String>();
       emailToolNew.selectedFields.add('Email');
       emailToolNew.getEmail();
       emailToolNew.startMasking();
       
       emailToolNew.inputHiddenValue = 'hello:world';
       emailToolNew.getEmail();
   }
}