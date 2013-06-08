/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  29.10.2012      Smitha Thomas       MOJO    Initial Creation.Creating this test class to unit test 
                                                SFA_MOJO_RegisterWithGFSController class.
 |  30.10.2012      Avinash Kaltari     MOJO    Updated test class and added test methods to increase coverage
+========================================================================================================================*/ 

@isTest(SeeAllData = true) 
private class SFA_MOJO_RegisterWithGFSController_TC 
{
    static testMethod void registerWithGFSTest()
    {
        List<Account> lstAccount = [Select id, Account_Flag__c 
            From Account
            Where Account_Flag__c = 'Primary' AND BillingCountry = 'India'
            Limit 1];

        List<Account> lstAccount1 = [Select id, Account_Flag__c 
            From Account
            Where Account_Flag__c = 'Primary' AND BillingCountry = 'United Kingdom'
            Limit 1];

        List<Account> lstAccount2 = [Select id, Account_Flag__c 
            From Account
            Where Account_Flag__c = 'Primary' AND BillingCountry = 'United States'
            Limit 1];

        Account account;
        
        List<Asset__c> lstAssets = new List<Asset__c>();
        Asset__c asset1 = new Asset__c();
        Asset__c asset2 = new Asset__c();
        Asset__c asset3 = new Asset__c();
        Asset__c asset4 = new Asset__c();
        
        if (lstAccount != null && lstAccount.size() > 0) 
        {
            account = lstAccount.get(0);
        }

        List<Opportunity_Asset_Junction__c> lstOppAssetJunction = new List<Opportunity_Asset_Junction__c>();

        List<Contact> lstContact = [Select id From Contact Limit 1];
        Contact con;
        if (lstContact != null && lstContact.size() > 0) 
        {
            con = lstContact.get(0);
        }
        
        //Insert Account.
        /*Account account =  new Account(Name='Test Account**',CurrencyIsoCode='USD',Account_Flag__c='Primary',Site_DUNS_Entity__c = '123456',
                    Global_DUNS_Entity__c = '663399');  
        
        insert account;*/
        Account account1 = lstAccount.get(0);

        Opportunity validOpty = new Opportunity (Name = 'Test Opportunity ', AccountId = account.id, Sales_Force__c = 'EMC',CurrencyIsoCode = 'USD', StageName = 'Pipeline',District_Manager__c = con.id,Products__c = 'test',CloseDate = System.today(), VCE_Related__c='VMWare Other',Amount = 500, Opportunity_Number__c = '9999999 test');

        insert validOpty;

        
        Account account2 = lstAccount1.get(0);
        Opportunity validOpty2 = new Opportunity (Name = 'Test Opportunity 2', AccountId = account2.id, Sales_Force__c = 'EMC',CurrencyIsoCode = 'USD', StageName = 'Pipeline',District_Manager__c = con.id,Products__c = 'test',CloseDate = System.today(), VCE_Related__c='VMWare Other',Amount = 500, Opportunity_Number__c = '9999999 test2');
        insert validOpty2;

        Account account3 = lstAccount2.get(0);
        Opportunity validOpty3 = new Opportunity (Name = 'Test Opportunity 3', AccountId = account3.id, Sales_Force__c = 'EMC',CurrencyIsoCode = 'USD', StageName = 'Pipeline',District_Manager__c = con.id,Products__c = 'test',CloseDate = System.today(), VCE_Related__c='VMWare Other',Amount = 500, Opportunity_Number__c = '9999999 test3');
        insert validOpty3;

        Opportunity invalidOpty1 = new Opportunity (Name = 'Test Opportunity 4', AccountId = account3.id, Sales_Force__c = 'EMC',CurrencyIsoCode = 'USD', StageName = 'Pipeline',District_Manager__c = con.id,Products__c = 'test',CloseDate = System.today(), VCE_Related__c='VMWare Other',Amount = 500, Opportunity_Number__c = '9999999 test4');
        insert invalidOpty1;
        
        Opportunity invalidOpty2 = new Opportunity (Name = 'Test Opportunity 5', AccountId = account3.id, Sales_Force__c = 'EMC',CurrencyIsoCode = 'USD', StageName = 'Pipeline',CloseDate = System.today(), VCE_Related__c='VMWare Other',Amount = 500, Opportunity_Number__c = '9999999 test5');
        insert invalidOpty2;

        Opportunity invalidOpty3 = new Opportunity (Name = 'Test Opportunity 6', AccountId = account3.id, Sales_Force__c = 'EMC',CurrencyIsoCode = 'USD', StageName = 'Pipeline',District_Manager__c = con.id,Products__c = 'test',CloseDate = System.today(), VCE_Related__c='VMWare Other',Amount = 500, Opportunity_Number__c = '9999999 test6');
        insert invalidOpty3;

        asset1 = new Asset__c(name = 'Test 1', Customer_Name__c = account.id, Configuration_Details__c='test', Total_Raw_Capacity_GB__c = 'test');
        
        asset2 = new Asset__c(name = 'Test 2', Customer_Name__c = account2.id, Configuration_Details__c='test', Total_Raw_Capacity_GB__c = 'test');

        asset3 = new Asset__c(name = 'Test 3', Customer_Name__c = account3.id, Configuration_Details__c='test', Total_Raw_Capacity_GB__c = 'test');


        lstAssets.add(asset1);
        lstAssets.add(asset2);
        lstAssets.add(asset3);

        insert lstAssets;
        
        List<CustomSettingDataValueMap__c> lstdataValueControlFlag = new List<CustomSettingDataValueMap__c>();
        CustomSettingDataValueMap__c dataValueControlFlag1=new CustomSettingDataValueMap__c();
        dataValueControlFlag1.Name ='America Theater Email Notification';
        dataValueControlFlag1.DataValue__c ='GFSMOJOAMER@emc.com';
        lstdataValueControlFlag.add(dataValueControlFlag1);
         CustomSettingDataValueMap__c dataValueControlFlag2=new CustomSettingDataValueMap__c();
        dataValueControlFlag2.Name ='EMEA Theater Email Notification';
        dataValueControlFlag2.DataValue__c ='GFSMOJOEMEA@emc.com';
        lstdataValueControlFlag.add(dataValueControlFlag2);
         CustomSettingDataValueMap__c dataValueControlFlag3=new CustomSettingDataValueMap__c();
        dataValueControlFlag3.Name ='APJ Theater Email Notification';
        dataValueControlFlag3.DataValue__c ='GFSMOJOAPJ@emc.com';
        lstdataValueControlFlag.add(dataValueControlFlag3);
        
        try
        {
            database.insert (lstdataValueControlFlag,false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }


        Opportunity_Asset_Junction__c oaj1 = new Opportunity_Asset_Junction__c (Related_Asset__c = asset1.id, Related_Opportunity__c = validOpty.id);

        Opportunity_Asset_Junction__c oaj2 = new Opportunity_Asset_Junction__c (Related_Asset__c = asset2.id, Related_Opportunity__c = validOpty2.id);

        Opportunity_Asset_Junction__c oaj3 = new Opportunity_Asset_Junction__c (Related_Asset__c = asset3.id, Related_Opportunity__c = validOpty3.id);
        
        lstOppAssetJunction.add(oaj1);
        lstOppAssetJunction.add(oaj2);
        lstOppAssetJunction.add(oaj3);

        insert lstOppAssetJunction;

        ApexPages.currentpage().getParameters().put('Id',validOpty.Id);
        ApexPages.StandardController oppController1 = new ApexPages.StandardController(validOpty);
        SFA_MOJO_RegisterWithGFSController cont = new SFA_MOJO_RegisterWithGFSController(oppController1);

        cont.RegisterGFS();
        
        ApexPages.currentpage().getParameters().put('Id',validOpty2.Id);
        ApexPages.StandardController oppController2 = new ApexPages.StandardController(validOpty2);
        SFA_MOJO_RegisterWithGFSController cont2 = new SFA_MOJO_RegisterWithGFSController(oppController2);

        cont2.RegisterGFS();

      ApexPages.currentpage().getParameters().put('Id',validOpty3.Id);
        ApexPages.StandardController oppController3 = new ApexPages.StandardController(validOpty3);
        SFA_MOJO_RegisterWithGFSController cont3 = new SFA_MOJO_RegisterWithGFSController(oppController3);

        cont3.RegisterGFS();
        
        
        Trade_Ins_Competitive_Swap__c trade14=[select id,Registration_ID__c from Trade_Ins_Competitive_Swap__c where  Related_Opportunity__c =: validOpty.id];
        trade14.Registration_ID__c=null;
        update trade14;
        
             
        /*  ApexPages.currentpage().getParameters().put('Id',invalidOpty1.Id);
        ApexPages.StandardController oppController4 = new ApexPages.StandardController(invalidOpty1);
        SFA_MOJO_RegisterWithGFSController cont4 = new SFA_MOJO_RegisterWithGFSController(oppController4);

        cont4.RegisterGFS();*/
        
        
     /*   Opportunity_Asset_Junction__c oaj5 = new Opportunity_Asset_Junction__c (Related_Asset__c = asset3.id, Related_Opportunity__c = invalidOpty2.id);
        insert oaj5;

        ApexPages.currentpage().getParameters().put('Id',invalidOpty2.Id);
        ApexPages.StandardController oppController5 = new ApexPages.StandardController(invalidOpty2);
        SFA_MOJO_RegisterWithGFSController cont5 = new SFA_MOJO_RegisterWithGFSController(oppController5);

        cont5.RegisterGFS();
        
        asset3.Configuration_Details__c = '';
        update asset3;
        Opportunity_Asset_Junction__c oaj6 = new Opportunity_Asset_Junction__c (Related_Asset__c = asset3.id, Related_Opportunity__c = invalidOpty3.id);
        insert oaj6;

        ApexPages.currentpage().getParameters().put('Id',invalidOpty3.Id);
        ApexPages.StandardController oppController6 = new ApexPages.StandardController(invalidOpty3);
        SFA_MOJO_RegisterWithGFSController cont6 = new SFA_MOJO_RegisterWithGFSController(oppController6);

        cont6.RegisterGFS();*/
        
    }

    static testMethod void registerWithGFSUpdateTest()
    {
        List<Account> lstAccount = [Select id, Account_Flag__c 
            From Account
            Where Account_Flag__c = 'Primary' AND BillingCountry = 'India'
            Limit 1];

        List<Account> lstAccount2 = [Select id, Account_Flag__c 
            From Account
            Where Account_Flag__c = 'Primary' AND BillingCountry = 'United Kingdom'
            Limit 1];

        List<Account> lstAccount3 = [Select id, Account_Flag__c 
            From Account
            Where Account_Flag__c = 'Primary' AND BillingCountry = 'United States'
            Limit 1];

        Account account;
        Account account2;
        Account account3;
        
        List<Contact> lstContact = [Select id From Contact Limit 1];
        Contact con;
        if (lstContact != null && lstContact.size() > 0) 
        {
            con = lstContact.get(0);
        }

        List<Asset__c> lstAssets = new List<Asset__c>();
        Asset__c asset1 = new Asset__c();
        Asset__c asset2 = new Asset__c();
        Asset__c asset3 = new Asset__c();

        if (lstAccount != null && lstAccount.size() > 0) 
        {
            account = lstAccount.get(0);
        }

        if (lstAccount2 != null && lstAccount2.size() > 0) 
        {
            account2 = lstAccount2.get(0);
        }

        if (lstAccount3 != null && lstAccount3.size() > 0) 
        {
            account3 = lstAccount3.get(0);
        }

        List<Opportunity_Asset_Junction__c> lstOppAssetJunction = new List<Opportunity_Asset_Junction__c>();

        Opportunity validOpty = new Opportunity (Name = 'Test Opportunity', AccountId = account.id, Sales_Force__c = 'EMC',CurrencyIsoCode = 'USD', StageName = 'Pipeline',District_Manager__c = con.id,Products__c = 'test',CloseDate = System.today(), VCE_Related__c='VMWare Other',Amount = 500, Opportunity_Number__c = '9999999 testing');

        insert validOpty;

        Opportunity validOpty2 = new Opportunity (Name = 'Test Opportunity2', AccountId = account2.id, Sales_Force__c = 'EMC',CurrencyIsoCode = 'USD', StageName = 'Pipeline',District_Manager__c = con.id,Products__c = 'test',CloseDate = System.today(), VCE_Related__c='VMWare Other',Amount = 500, Opportunity_Number__c = '9999999 testing2');

        insert validOpty2;

        Opportunity validOpty3 = new Opportunity (Name = 'Test Opportunity3', AccountId = account3.id, Sales_Force__c = 'EMC',CurrencyIsoCode = 'USD', StageName = 'Pipeline',District_Manager__c = con.id,Products__c = 'test',CloseDate = System.today(), VCE_Related__c='VMWare Other',Amount = 500, Opportunity_Number__c = '9999999 testing3');

        insert validOpty3;


        asset1 = new Asset__c(name = 'Test 1', Customer_Name__c = account.id, Configuration_Details__c='test', Total_Raw_Capacity_GB__c = 'test');
        asset2 = new Asset__c(name = 'Test 1', Customer_Name__c = account2.id, Configuration_Details__c='test', Total_Raw_Capacity_GB__c = 'test');
        asset3 = new Asset__c(name = 'Test 1', Customer_Name__c = account3.id, Configuration_Details__c='test', Total_Raw_Capacity_GB__c = 'test');

        lstAssets.add(asset1);
        lstAssets.add(asset2);
        lstAssets.add(asset3);

        insert lstAssets;
        List<CustomSettingDataValueMap__c> lstdataValueControlFlag = new List<CustomSettingDataValueMap__c>();
        CustomSettingDataValueMap__c dataValueControlFlag1=new CustomSettingDataValueMap__c();
        dataValueControlFlag1.Name ='America Theater Email Notification';
        dataValueControlFlag1.DataValue__c ='GFSMOJOAMER@emc.com';
        lstdataValueControlFlag.add(dataValueControlFlag1);
         CustomSettingDataValueMap__c dataValueControlFlag2=new CustomSettingDataValueMap__c();
        dataValueControlFlag2.Name ='EMEA Theater Email Notification';
        dataValueControlFlag2.DataValue__c ='GFSMOJOEMEA@emc.com';
        lstdataValueControlFlag.add(dataValueControlFlag2);
         CustomSettingDataValueMap__c dataValueControlFlag3=new CustomSettingDataValueMap__c();
        dataValueControlFlag3.Name ='APJ Theater Email Notification';
        dataValueControlFlag3.DataValue__c ='GFSMOJOAPJ@emc.com';
        lstdataValueControlFlag.add(dataValueControlFlag3);
        
        try
        {
            database.insert (lstdataValueControlFlag,false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }

        Opportunity_Asset_Junction__c oaj1 = new Opportunity_Asset_Junction__c (Related_Asset__c = asset1.id, Related_Opportunity__c = validOpty.id);
        Opportunity_Asset_Junction__c oaj2 = new Opportunity_Asset_Junction__c (Related_Asset__c = asset2.id, Related_Opportunity__c = validOpty2.id);
        Opportunity_Asset_Junction__c oaj3 = new Opportunity_Asset_Junction__c (Related_Asset__c = asset3.id, Related_Opportunity__c = validOpty3.id);

        lstOppAssetJunction.add(oaj1);
        lstOppAssetJunction.add(oaj2);
        lstOppAssetJunction.add(oaj3);

        insert lstOppAssetJunction;

        Trade_Ins_Competitive_Swap__c trade = new Trade_Ins_Competitive_Swap__c(Related_Opportunity__c = validOpty.id, Registration_ID__c = 'test', Swap_Value__c = 1);
        insert trade;

        Trade_Ins_Competitive_Swap__c trade2 = new Trade_Ins_Competitive_Swap__c(Related_Opportunity__c = validOpty2.id, Registration_ID__c = 'test', Swap_Value__c = 1);
        insert trade2;
        
        //trade2.Registration_ID__c='Test';
        //update trade2;


        Trade_Ins_Competitive_Swap__c trade3 = new Trade_Ins_Competitive_Swap__c(Related_Opportunity__c = validOpty3.id, Registration_ID__c = 'test', Swap_Value__c = 1);
        insert trade3;

        //trade3.Registration_ID__c='';
        //update trade3;
        
        ApexPages.currentpage().getParameters().put('Id',validOpty.Id);
        ApexPages.StandardController oppController1 = new ApexPages.StandardController(validOpty);
        SFA_MOJO_RegisterWithGFSController cont = new SFA_MOJO_RegisterWithGFSController(oppController1);

        cont.RegisterGFS();
        Pagereference p = cont.Cancel();

        ApexPages.currentpage().getParameters().put('Id',validOpty2.Id);
        ApexPages.StandardController oppController2 = new ApexPages.StandardController(validOpty2);
        SFA_MOJO_RegisterWithGFSController cont2 = new SFA_MOJO_RegisterWithGFSController(oppController2);

        cont2.RegisterGFS();

        ApexPages.currentpage().getParameters().put('Id',validOpty3.Id);
        ApexPages.StandardController oppController3 = new ApexPages.StandardController(validOpty3);
        SFA_MOJO_RegisterWithGFSController cont3 = new SFA_MOJO_RegisterWithGFSController(oppController3);

        cont3.RegisterGFS();
        
        Trade_Ins_Competitive_Swap__c trade4=[select id,Registration_ID__c from Trade_Ins_Competitive_Swap__c where id=:trade3.Id and Related_Opportunity__c =: validOpty3.id];
        trade4.Registration_ID__c=null;
        update trade4;
        
        Trade_Ins_Competitive_Swap__c trade5=[select id,Registration_ID__c from Trade_Ins_Competitive_Swap__c where id=:trade2.Id and Related_Opportunity__c =: validOpty2.id];
        trade5.Registration_ID__c='test5';
        update trade5;
        
        Trade_Ins_Competitive_Swap__c trade6=[select id,Registration_ID__c from Trade_Ins_Competitive_Swap__c where id=:trade.Id and Related_Opportunity__c =: validOpty.id];
        trade6.Registration_ID__c='test6';
        update trade6;
    }

}