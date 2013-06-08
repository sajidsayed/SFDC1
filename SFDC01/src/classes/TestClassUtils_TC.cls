/**

Created By      :   Avinash Kaltari
Created Date    :   24 May 2012
Purpose         :   To increase the coverage of TestClassUtils class

*/
@IsTest
private class TestClassUtils_TC 
{
    
    
    static testMethod void TestClassUtilsTest() 
    {
        CustomSettingDataValueMap__c cs = testclassUtils.getCustomSetRec('Name', 'Value');
        
        
        testclassUtils.InsertCustomSetRec('Name', 'Value');
        
        //testclassUtils.getCustomSettingrec_Profiles('Name Prasad111');
        
        DealRegistration_CustomSetting__c drcs = testclassUtils.getCustomSettingrec_dealreg('name', 'pscQueueId');
        
        OpportunityIntegration__c opics = testclassUtils.getCustomSettingrec_opptyIntg('name','name');
        
        OpportunityIntegration__c opics1 = testclassUtils.getCustomSettingrec_opptyIntg_IntAdmin('name1','name1');
        
        Lead l = testclassUtils.getLeadrec();
        
        testclassUtils.getRecord(l);
        
        Opportunity opp = testclassUtils.getOppty();
        
        Account acc = testclassUtils.getAccount();
        
        Contact con = testclassUtils.getContact();
        
        Id i = testclassUtils.getRecordTypeId('Contact', 'EMC Internal Contact');
        
        String strProfile = [select name from Profile limit 1].name;
        String strRole = [select name from UserRole limit 1].name;
        User u;
        
        try
        {
            u = testclassUtils.queryUser(strProfile, strRole);
        }
        catch(Exception e)
        {
            
        }
        
        u = testclassUtils.getUser(strProfile, strRole);
    }
}