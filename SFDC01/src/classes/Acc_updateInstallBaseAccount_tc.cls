/**
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  06.12.2010      Shipra Misra    151285      Initial Creation of Test Class.  Updating Install Base Account Field on Lead.  
 |  16/01/2011		Anand SHarma				Change : In place of inserting record, fetch account record: 
 														commented line 19-28, added line 32 - 34
 |  10/08/2011		Shipra Misra				Created account instead of fetching account record. 														
 																	
 +========================================================================================================================*/

 
@isTest
private class Acc_updateInstallBaseAccount_tc 
{
    static testMethod void trgInstallBaseAccountUpdateTest() 
    {
        //Create account record        
        Account accObj = new Account();
        accObj.Name ='TestAccount';
        accObj.Install_Base_Account__c = true;
        insert accObj;
       	
       	List<Account> accToBeAdded = new List<Account>();
       	accToBeAdded.add(accObj);
                
        //Hold list of Leads to be inserted.
        List<Lead> leadToBeInserted =new List<Lead>();
        for (Integer j=0;j<10;j++) 
        {            
            Lead leadNew =new Lead(Company ='Test Lead**'+j,LastName='Doe 2'+j,Related_Account__c=accObj.id,email='shipra.misra@salesforce.com');
            leadToBeInserted.add(leadNew);
        }
        //Insert Leads.
       
        insert leadToBeInserted;
        
        for(Account acc :accToBeAdded)
        {
            acc.Install_Base_Account__c=false;
        }
        //Update Accounts.
        test.startTest();
        update accToBeAdded;
        test.stopTest();
    }
}