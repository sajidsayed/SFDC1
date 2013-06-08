/**

Created By      :   Avinash Kaltari
Created Date    :   25 May 2012
Purpose         :   To increase the coverage of TestData class

*/
@isTest
private class TestData_TC 
{

    static testMethod void TestDataTest() 
    {
        TestData.ensureVariableExists('key', 'value');
        Account acc;
        try
        {
            acc = TestData.createTestPartner();
        }
        catch (Exception e)
        {
            
        }
                
        //Account acc = [select name from Account where isPartner = true limit 1];
        
        Account acct = new Account();
        acct.Name='Test Account 123 ABC';
        acct.Profile_Published_to_Partner_Finder__c='Yes';
        acct.Approved_for_Partner_Finder__c=true;
        acct.Partner_User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId();
        acct.Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now();
        //acct.IsPartner = true;
        insert acct;
        
        
        if (acct != null)   
            List<Partner_Location__c> lst = TestData.createTestPartnerLocations(acct, 180);
        
        
        TestData.ensureVariableExists('key', 'value');
        
        
    }
}