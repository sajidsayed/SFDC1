/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE      DEVELOPER             WR      DESCRIPTION                               

 |  ====      =========             ==      =========== 

 | 30/9/2010  Karthik Shivprakash   1074    This class is used to test
                                            My Company Profile fields 
 |                                          saved on account.
   08/10/2010 Karthik Shivprakash   --      Update testAccountSave method
 |                                          and called save method.
 | 14/10/2012  Krishna Pydavula     204075  Added two fields 3rd PartyVirtualization and 3rd PartyNetworking 
 +===========================================================================*/

@istest

private class PRM_EditMyPublicProfile_TC {

/* @Method <This method testAccountSave is used test the My Company Profile 
            fields saved on the account>
   @param <Not taking any paramters>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

    static testmethod void testAccountSave() {
    
        Account account1 = createAccount('TestAccount');        
        System.currentPageReference().getParameters().put('id',account1.id);
        
              
        PRM_EditMyPublicProfile obj = new PRM_EditMyPublicProfile();
        obj.accounts = account1;

        obj.Partnership_Overview = 'Test Partnership';
        obj.Partner_Self_Description_Long = 'Service Company';
        Obj.Business_Focus = new List<String>();
        obj.Business_Focus.add('Content Managment');
        Obj.Product_Focus = new List<String>();
        obj.Product_Focus.add('Auto Start');
        Obj.Application_Environments = new List<String>();
        obj.Application_Environments.add('MS SQL');
        Obj.Industry_Verticals = new List<String>();
        obj.Industry_Verticals.add('Retail');
        Obj.Party_Virtualization = new List<String>();
        obj.Party_Virtualization.add('VM Ware');
        Obj.Party_Networking = new List<String>();
        obj.Party_Networking.add('Cisco');
        
        Test.startTest();
        Obj.getBusinessFocus();
        Obj.getProductFocus();
        Obj.getApplicationEnvironments();
        Obj.getIndustryVerticals();
        Obj.saveAccount();
        Obj.getPartyVirtualization();
        Obj.getPartyNetworking();
        Obj.cancel();
        
        Test.stopTest();
        
       Account account = [select id,name,Partnership_Overview__c,Partner_Self_Description_Long__c,
                            Business_Focus__c,Product_Focus__c,Application_Environments__c,Industry_Verticals__c,Cloud_Builder_Virtualization__c,Cloud_Builder_Networking__c
                            from account
                            where Id=:account1.Id];

        System.debug('Account Details'+account);
        System.assertEquals('Test Partnership',account.Partnership_Overview__c);
        System.assertEquals('Service Company',account.Partner_Self_Description_Long__c);
        System.assertEquals('Content Managment',account.Business_Focus__c);
        System.assertEquals('Auto Start',account.Product_Focus__c);
        System.assertEquals('MS SQL',account.Application_Environments__c);
        System.assertEquals('Retail',account.Industry_Verticals__c);
        System.assertEquals('VM Ware',account.Cloud_Builder_Virtualization__c);
        System.assertEquals('Cisco',account.Cloud_Builder_Networking__c);

    }
    
/* @Method <This method createAccount is used create account for the test class>
   @param <Taking string as paramter which contains account name>
   @return <void> - <Account record>
   @throws exception - <No Exception>
*/
    
    public static Account createAccount(String accountName){
        //Creating the dummy account for test class.
        Account account = new Account(
            name=accountName,
            CurrencyIsoCode='USD',
            Site_DUNS_Entity__c='5693241',
            Partnership_Overview__c='Partnership_Overview__c',
            Partner_Self_Description_Long__c='Partner_Self_Description_Long__c',
            Business_Focus__c='Business_Focus__c',
            Product_Focus__c='Product_Focus__c',
            Application_Environments__c='Application_Environments__c',
            Industry_Verticals__c='Industry_Verticals__c',
            Cloud_Builder_Virtualization__c='Cloud_Builder_Virtualization__c',
            Cloud_Builder_Networking__c='Cloud_Builder_Networking__c'
        );
        insert account;
        return account;
    }
    
}