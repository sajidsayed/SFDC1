/*===========================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR        DESCRIPTION                               

|  ====          =========                ==        =========== 

| 15-Dec-2010    Anirudh Singh           1477      This test class is used to
                                                   test the Create Location functionality
                                                   for Profiled accounts.
|  14/12/2011		Anil						   Used Custom setting Data Halper
+===========================================================================*/
@istest
private class PRM_PartnerFinderLocation_TC {
/* @Method <This method is used to test the Partner Location Functionality>
@param <None>
@return <void>
@throws exception - <No Exception>
*/
    static testmethod void testPartnerLocation() {
    	
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        PRM_PartnerFinderLocation PartnerLocation = New PRM_PartnerFinderLocation();
        Account account1 = createAccount('TestAccount1');
        Account account2 = createAccount('TestAccount2');
        

        //Test Data Finish
        Test.startTest();

        for(Account acc: [select Id,IsPartner,Lead_Oppty_Enabled__c 
                            from account 
                            where Id=:account1.Id]){
            acc.IsPartner=true;
            acc.Lead_Oppty_Enabled__c=true;
            acc.Site_DUNS_Entity__c = '448812';
            update acc;
        }
        List<Id> locationaccount= new list<Id>(); 
        //Creating the dummy grouping on the previously created account for 
        //test class.
        System.Debug('OldFlagValue----->' +account1.Profiled_Account_Flag__c);
        Account_Groupings__c TestGroup1 = createGrouping(account1.id);
        if(account1.PROFILED_ACCOUNT_FLAG__c==true){
        locationaccount.add(account1.id);
        }
        PartnerLocation.createPartnerLocation(locationaccount);
        System.Debug('GroupingProfiledAccount---'  +TestGroup1.Profiled_Account__c);
        System.Debug('NewFlagValue----->' +[Select Profiled_Account_Flag__c from Account where id=: account1.id]);                                                       

        Test.stopTest();

        }



/* @Method <This method is used create accounts for the test class>
@param <Taking string as paramter which contains account name>
@return <void> - <Account record>
@throws exception - <No Exception>
*/

        public static Account createAccount(String accountName){
        //Creating the dummy account for test class.
        Account account = new Account(
            name=accountName,
            Partner_Type__c='Distributor',
            Lead_oppty_enabled__c =True,
            APPR_MTV__Association_Account__c=True,
            CurrencyIsoCode='USD',
            BillingCity='Bangalore',
            Billingcountry='India',
            BillingPostalCode='56660066',
            BillingState='Karnatka',
            BillingStreet='Whitefiled',
            website='www.abc.com'
            
        );
        insert account;
        return account;
        }

        
/* @Method <This method is used to create grouping Data 
            for the test class >
@param <Taking Id as paramter which contains account Id>
@return <void> - <Grouping record>
@throws exception - <No Exception>
*/
        public static Account_Groupings__c createGrouping(Id accountId){
            Account_Groupings__c grouping = new Account_Groupings__c();
            grouping.Name = 'TestGrouping1';
            grouping.Active__c = true;
            grouping.Profiled_Account__c = accountId;
            grouping.No_Master_Required__c = False;

        insert grouping;
        return grouping;
    }

}