@isTest
private class AH_ChildObjectPresenceIndicators_TC {
/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |             L Jovanovic            Initial Creation.  Test methods for profile presence indicator.               
 |  01-JUN-09  S Douglas              Updated to add test methods for account plan presence indicator.
 |                                    (commented out as they do not go live until August)
 |  07-OCT-09    Shipra Misra         Adding test method  for delete and undelete profile presence, 
                                      Updating Profile exist checkbox against the created account.                 
 +===========================================================================*/


    /////////////////////////////////////////////////////////////////////////////////////
    //  Profile Presence Unit Test Methods
    /////////////////////////////////////////////////////////////////////////////////////

    // test Profile insert (singular) 
    static testMethod void runProfileInsert_Singular() {
        
        // delcare local vars
        Boolean presence = false;
        
        // create a sample account
        Account acct = createNewAccount('TEST ACCT1');
        
        // check to see that the presence indicator is now false
        presence = [select Id, Child_Record_Presence_Profile__c from account where id = :acct.Id].Child_Record_Presence_Profile__c;
        System.assertEquals(false, presence, 'Presence has not been initialized correctly');
        
        test.starttest();
        
        // create a sample profile
        ProfileCustom__c profile = createNewProfile(acct.Id);
        
        // check to see that the presence indicator is now true
        presence = [select Id, Child_Record_Presence_Profile__c from account where id = :acct.Id].Child_Record_Presence_Profile__c;
        System.assertEquals(true, presence, 'Presence has not been set correctly');
    }  //runProfileInsert_Singular
    
   
    // test Profile insert (bulk) 
    static testMethod void runProfileInsert_Bulk() {
        
        // declare local vars
        List <ProfileCustom__c> profilesToInsert = new List <ProfileCustom__c>();
        Boolean presence1 = false;
        Boolean presence2 = false;
        Boolean presence3 = false;
        
        // create 3 sample accounts
        Account acct1 = createNewAccount('runContactInsert_Bulk1');
        Account acct2 = createNewAccount('runContactInsert_Bulk2');
        Account acct3 = createNewAccount('runContactInsert_Bulk3');
        
        // check to see that the presence indicator is now false
        presence1 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct1.Id].Child_Record_Presence_Profile__c;
        presence2 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct2.Id].Child_Record_Presence_Profile__c;
        presence3 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct3.Id].Child_Record_Presence_Profile__c;
        System.assertEquals(false, presence1, 'Presence1 has not been initialized correctly');
        System.assertEquals(false, presence2, 'Presence2 has not been initialized correctly');
        System.assertEquals(false, presence3, 'Presence3 has not been initialized correctly');
        
        // loop and create 66 profiles on each
        for (Integer x = 0; x < 66; x++) {
            profilesToInsert.add(new ProfileCustom__c(Account_del__c = acct1.Id));
            profilesToInsert.add(new ProfileCustom__c(Account_del__c = acct2.Id));
            profilesToInsert.add(new ProfileCustom__c(Account_del__c = acct3.Id));
        }
        // add a 200th contact
        profilesToInsert.add(new ProfileCustom__c(Account_del__c = acct1.Id));
        profilesToInsert.add(new ProfileCustom__c(Account_del__c = acct2.Id));
        
        test.starttest();
        
        // create the contacts
        insert profilesToInsert;
        
        // check to see that the presence indicator is now false
        presence1 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct1.Id].Child_Record_Presence_Profile__c;
        presence2 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct2.Id].Child_Record_Presence_Profile__c;
        presence3 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct3.Id].Child_Record_Presence_Profile__c;
        System.assertEquals(true, presence1, 'Presence1 has not been set correctly');
        System.assertEquals(true, presence2, 'Presence2 has not been set correctly');
        System.assertEquals(true, presence3, 'Presence3 has not been set correctly');
    }  //runProfileInsert_Bulk
    
    
    // test Profile update (singular) 
    static testMethod void runProfileUpdate_Singular() {
        
        // declare local vars
        Boolean presence1 = false;
        Boolean presence2 = false;
        
        // create sample account2
        Account acct1 = createNewAccount('runContactInsert_Bulk1');
        Account acct2 = createNewAccount('runContactInsert_Bulk2');
        
        // check to see that the presence indicator is now false
        presence1 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct1.Id].Child_Record_Presence_Profile__c;
        presence2 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct2.Id].Child_Record_Presence_Profile__c;
        System.assertEquals(false, presence1, 'Presence1 has not been initialized correctly');
        System.assertEquals(false, presence2, 'Presence2 has not been initialized correctly');
        
        // create a profile and assign it to one of the accounts
        ProfileCustom__c profile1 = createNewProfile(acct1.Id);
        
        // check to see that the presence indicator is now true
        presence1 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct1.Id].Child_Record_Presence_Profile__c;
        System.assertEquals(true, presence1, 'Presence1 has not been set correctly');
        
        test.starttest();
        
        // update the profile from acct 1 to acct 2
        profile1.Account_del__c = acct2.Id;
        update profile1;
        
        // check to see that the presence indicator is correct
        presence1 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct1.Id].Child_Record_Presence_Profile__c;
        presence2 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct2.Id].Child_Record_Presence_Profile__c;
        System.assertEquals(false, presence1, 'Presence1 has not been set correctly');
        System.assertEquals(true, presence2, 'Presence2 has not been set correctly');
        
        // now we test the condition where we move a profile from an account that has many profiles
        ProfileCustom__c profile2 = createNewProfile(acct2.Id);
        
        // check to see that the presence indicator is correct
        presence2 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct2.Id].Child_Record_Presence_Profile__c;
        System.assertEquals(true, presence2, 'Presence2 has not been set correctly');
        
        // now we move one of the profiles from 2 to 1
        profile1.Account_del__c = acct1.Id;
        update profile1;
        
        // check to see that the presence indicator is correct
        presence1 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct1.Id].Child_Record_Presence_Profile__c;
        presence2 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct2.Id].Child_Record_Presence_Profile__c;
        System.assertEquals(true, presence1, 'Presence1 has not been set correctly');
        System.assertEquals(true, presence2, 'Presence2 has not been set correctly');
    }  //runProfileUpdate_Singular
    
    // test Profile update (bulk) 
    static testMethod void runProfileUpdate_Bulk() {
        
        // declare local vars
        List <ProfileCustom__c> profilesToInsert = new List <ProfileCustom__c>();
        List <ProfileCustom__c> profilesToUpdate = new List <ProfileCustom__c>();
        Boolean presence1 = false;
        Boolean presence2 = false;
        Boolean presence3 = false;
        
        // create 3 sample accounts
        Account acct1 = createNewAccount('runContactInsert_Bulk1');
        Account acct2 = createNewAccount('runContactInsert_Bulk2');
        Account acct3 = createNewAccount('runContactInsert_Bulk3');
        
        // check to see that the presence indicator is now false
        presence1 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct1.Id].Child_Record_Presence_Profile__c;
        presence2 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct2.Id].Child_Record_Presence_Profile__c;
        presence3 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct3.Id].Child_Record_Presence_Profile__c;
        System.assertEquals(false, presence1, 'Presence1 has not been initialized correctly');
        System.assertEquals(false, presence2, 'Presence2 has not been initialized correctly');
        System.assertEquals(false, presence3, 'Presence3 has not been initialized correctly');
        
        // loop and create 66 profiles on each
        for (Integer x = 0; x < 66; x++) {
            profilesToInsert.add(new ProfileCustom__c(Account_del__c = acct1.Id));
            profilesToInsert.add(new ProfileCustom__c(Account_del__c = acct2.Id));
            profilesToInsert.add(new ProfileCustom__c(Account_del__c = acct3.Id));
        }
        // add a 200th contact
        profilesToInsert.add(new ProfileCustom__c(Account_del__c = acct1.Id));
        profilesToInsert.add(new ProfileCustom__c(Account_del__c = acct2.Id));
        
        // create the contacts
        insert profilesToInsert;
        
        // check to see that the presence indicator is correct
        presence1 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct1.Id].Child_Record_Presence_Profile__c;
        presence2 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct2.Id].Child_Record_Presence_Profile__c;
        presence3 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct3.Id].Child_Record_Presence_Profile__c;
        System.assertEquals(true, presence1, 'Presence1 has not been set correctly');
        System.assertEquals(true, presence2, 'Presence2 has not been set correctly');
        System.assertEquals(true, presence3, 'Presence3 has not been set correctly');
        
        test.starttest();
        
        // change the profile account assignment
        for (Integer x = 0; x < 66; x++) {
            profilesToUpdate.add(new ProfileCustom__c(id = profilesToInsert[3 * x].Id, Account_del__c = acct3.Id));
            profilesToUpdate.add(new ProfileCustom__c(id = profilesToInsert[(3 * x) + 1].Id, Account_del__c = acct1.Id));
            profilesToUpdate.add(new ProfileCustom__c(id = profilesToInsert[(3 * x) + 2].Id, Account_del__c = acct2.Id));
        }
        profilesToUpdate.add(new ProfileCustom__c(id = profilesToInsert[198].Id, Account_del__c = acct3.Id));
        profilesToUpdate.add(new ProfileCustom__c(id = profilesToInsert[199].Id, Account_del__c = acct1.Id));
        
        // update the profiles
        update profilesToUpdate;
        
        // check to see that the presence indicator is correct
        presence1 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct1.Id].Child_Record_Presence_Profile__c;
        presence2 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct2.Id].Child_Record_Presence_Profile__c;
        presence3 = [select Id, Child_Record_Presence_Profile__c from account where id = :acct3.Id].Child_Record_Presence_Profile__c;
        System.assertEquals(true, presence1, 'Presence1 has not been set correctly');
        System.assertEquals(true, presence2, 'Presence2 has not been set correctly');
        System.assertEquals(true, presence3, 'Presence3 has not been set correctly');
    }  //runProfileUpdate_Bulk
    
    
    //Test Profile delete and Undelete
     static testMethod void runProfileDeleteRecord() {
        //Create a Account
        Account acct = createNewAccount('runProfileDelete');
        //Create Profile on account created.
        ProfileCustom__c profile = new ProfileCustom__c();
        //Defining the Account Id For Profile
        profile.Account_del__c = acct.Id;
        
        insert profile;
        //Start the test Method
        test.startTest();
        //For TC_AH_ChildObjectPresenceIndicators.runProfileDeleteRecord
        delete profile;
        //For TC_AH_ChildObjectPresenceIndicators.runProfileUndeleteRecord
        undelete profile; 
        
    }
    
/*
    /////////////////////////////////////////////////////////////////////////////////////
    //  Account Plan Presence Unit Test Methods
    /////////////////////////////////////////////////////////////////////////////////////

    // test Account Plan insert (singular) 
    static testMethod void runAcctPlanInsert_Singular() {
        
        // delcare local vars
        Boolean presence = false;
        
        // create a sample account
        Account acct = createNewAccount('TEST ACCT1');
        
        // check to see that the presence indicator is now false
        presence = [select Id, Child_Record_Presence_Profile__c from account where id = :acct.Id].Child_Record_Presence_Profile__c;
        System.assertEquals(false, presence, 'Acct Plan Presence has not been initialized correctly');
        
        test.starttest();
        
        // create a sample plan
        SFDC_Acct_Plan__c plan = createNewAcctPlan(acct.Id);
        
        // check to see that the presence indicator is now true
        presence = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct.Id].Child_Record_Presence_AccountPlan__c;
        System.assertEquals(true, presence, 'Acct Plan Presence has not been set correctly');
    }  //runAcctPlanInsert_Singular
    
    // test Account Plan insert (bulk) 
    static testMethod void runAcctPlanInsert_Bulk() {
        
        // declare local vars
        List <SFDC_Acct_Plan__c> plansToInsert = new List <SFDC_Acct_Plan__c>();
        Boolean presence1 = false;
        Boolean presence2 = false;
        Boolean presence3 = false;
        
        // create 3 sample accounts
        Account acct1 = createNewAccount('runAcctPlanInsert_Bulk1');
        Account acct2 = createNewAccount('runAcctPlanInsert_Bulk2');
        Account acct3 = createNewAccount('runAcctPlanInsert_Bulk3');
        
        // check to see that the presence indicator is now false
        presence1 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct1.Id].Child_Record_Presence_AccountPlan__c;
        presence2 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct2.Id].Child_Record_Presence_AccountPlan__c;
        presence3 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct3.Id].Child_Record_Presence_AccountPlan__c;
        System.assertEquals(false, presence1, 'Acct Plan Presence1 has not been initialized correctly');
        System.assertEquals(false, presence2, 'Acct Plan Presence2 has not been initialized correctly');
        System.assertEquals(false, presence3, 'Acct Plan Presence3 has not been initialized correctly');
        
        // loop and create 66 plans on each
        for (Integer x = 0; x < 66; x++) {
            plansToInsert.add(new SFDC_Acct_Plan__c(Account__c = acct1.Id, Name = 'TestPlanA'+x, Account_Type__c = 'Existing customer', Planning_Year__c = 'FY2010', Plan_Status__c = 'Not Started'));
            plansToInsert.add(new SFDC_Acct_Plan__c(Account__c = acct2.Id, Name = 'TestPlanB'+x, Account_Type__c = 'Existing customer', Planning_Year__c = 'FY2010', Plan_Status__c = 'Not Started'));
            plansToInsert.add(new SFDC_Acct_Plan__c(Account__c = acct3.Id, Name = 'TestPlanC'+x, Account_Type__c = 'Existing customer', Planning_Year__c = 'FY2010', Plan_Status__c = 'Not Started'));
        }
        // add a 200th plan
        plansToInsert.add(new SFDC_Acct_Plan__c(Account__c = acct1.Id, Name = 'TestPlanA'+67, Account_Type__c = 'Existing customer', Planning_Year__c = 'FY2010', Plan_Status__c = 'Not Started'));
        plansToInsert.add(new SFDC_Acct_Plan__c(Account__c = acct2.Id, Name = 'TestPlanB'+67, Account_Type__c = 'Existing customer', Planning_Year__c = 'FY2010', Plan_Status__c = 'Not Started'));
        
        test.starttest();
        
        // create the plans
        insert plansToInsert;
        
        // check to see that the presence indicator is now true
        presence1 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct1.Id].Child_Record_Presence_AccountPlan__c;
        presence2 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct2.Id].Child_Record_Presence_AccountPlan__c;
        presence3 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct3.Id].Child_Record_Presence_AccountPlan__c;
        System.assertEquals(true, presence1, 'Acct Plan Presence1 has not been set correctly');
        System.assertEquals(true, presence2, 'Acct Plan Presence2 has not been set correctly');
        System.assertEquals(true, presence3, 'Acct Plan Presence3 has not been set correctly');
    }  //runAcctPlanInsert_Bulk
    
    // test Account Plan update (singular) 
    static testMethod void runAcctPlanUpdate_Singular() {
        
        // declare local vars
        Boolean presence1 = false;
        Boolean presence2 = false;
        
        // create sample account2
        Account acct1 = createNewAccount('TEST ACC1');
        Account acct2 = createNewAccount('TEST ACC2');
        
        // check to see that the presence indicator is now false
        presence1 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct1.Id].Child_Record_Presence_AccountPlan__c;
        presence2 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct2.Id].Child_Record_Presence_AccountPlan__c;
        System.assertEquals(false, presence1, 'Acct Plan Presence1 has not been initialized correctly');
        System.assertEquals(false, presence2, 'Acct Plan Presence2 has not been initialized correctly');
        
        // create a account plan and assign it to one of the accounts
        SFDC_Acct_Plan__c plan1 = createNewAcctPlan(acct1.Id);
        
        // check to see that the presence indicator is now true
        presence1 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct1.Id].Child_Record_Presence_AccountPlan__c;
        System.assertEquals(true, presence1, 'Acct Plan Presence1 has not been set correctly');
        
        test.starttest();
        
        // update the plan from acct 1 to acct 2
        plan1.Account__c = acct2.Id;
        update plan1;
        
        // check to see that the presence indicator is correct
        presence1 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct1.Id].Child_Record_Presence_AccountPlan__c;
        presence2 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct2.Id].Child_Record_Presence_AccountPlan__c;
        System.assertEquals(false, presence1, 'Acct Plan Presence1 has not been set correctly');
        System.assertEquals(true, presence2, 'Acct Plan Presence2 has not been set correctly');
        
        // now we test the condition where we move a plan from an account that has many profiles
        SFDC_Acct_Plan__c plan2 = createNewAcctPlan(acct2.Id);
        
        // check to see that the presence indicator is correct
        presence2 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct2.Id].Child_Record_Presence_AccountPlan__c;
        System.assertEquals(true, presence2, 'Presence2 has not been set correctly');
        
        // now we move one of the profiles from 2 to 1
        plan1.Account__c = acct1.Id;
        update plan1;
        
        // check to see that the presence indicator is correct
        presence1 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct1.Id].Child_Record_Presence_AccountPlan__c;
        presence2 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct2.Id].Child_Record_Presence_AccountPlan__c;
        System.assertEquals(true, presence1, 'Presence1 has not been set correctly');
        System.assertEquals(true, presence2, 'Presence2 has not been set correctly');
    }  //runAcctPlanUpdate_Singular
    
    // test Account Plan update (bulk) 
    static testMethod void runAcctPlanUpdate_Bulk() {
        
        // declare local vars
        List <SFDC_Acct_Plan__c> plansToInsert = new List <SFDC_Acct_Plan__c>();
        List <SFDC_Acct_Plan__c> plansToUpdate = new List <SFDC_Acct_Plan__c>();
        Boolean presence1 = false;
        Boolean presence2 = false;
        Boolean presence3 = false;
        
        // create 3 sample accounts
        Account acct1 = createNewAccount('runAcctPlanInsert_Bulk1');
        Account acct2 = createNewAccount('runAcctPlanInsert_Bulk2');
        Account acct3 = createNewAccount('runAcctPlanInsert_Bulk3');
        
        // check to see that the presence indicator is now false
        presence1 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct1.Id].Child_Record_Presence_AccountPlan__c;
        presence2 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct2.Id].Child_Record_Presence_AccountPlan__c;
        presence3 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct3.Id].Child_Record_Presence_AccountPlan__c;
        System.assertEquals(false, presence1, 'Acct Plan Presence1 has not been initialized correctly');
        System.assertEquals(false, presence2, 'Acct Plan Presence2 has not been initialized correctly');
        System.assertEquals(false, presence3, 'Acct Plan Presence3 has not been initialized correctly');
        
        // loop and create 66 profiles on each
        for (Integer x = 0; x < 66; x++) {
            plansToInsert.add(new SFDC_Acct_Plan__c(Account__c = acct1.Id, Name = 'TestPlanA'+x, Account_Type__c = 'Existing customer', Planning_Year__c = 'FY2010', Plan_Status__c = 'Not Started'));
            plansToInsert.add(new SFDC_Acct_Plan__c(Account__c = acct2.Id, Name = 'TestPlanB'+x, Account_Type__c = 'Existing customer', Planning_Year__c = 'FY2010', Plan_Status__c = 'Not Started'));
            plansToInsert.add(new SFDC_Acct_Plan__c(Account__c = acct3.Id, Name = 'TestPlanB'+x, Account_Type__c = 'Existing customer', Planning_Year__c = 'FY2010', Plan_Status__c = 'Not Started'));
        }
        // add a 200th contact
        plansToInsert.add(new SFDC_Acct_Plan__c(Account__c = acct1.Id, Name = 'TestPlanA'+67, Account_Type__c = 'Existing customer', Planning_Year__c = 'FY2010', Plan_Status__c = 'Not Started'));
        plansToInsert.add(new SFDC_Acct_Plan__c(Account__c = acct2.Id, Name = 'TestPlanB'+67, Account_Type__c = 'Existing customer', Planning_Year__c = 'FY2010', Plan_Status__c = 'Not Started'));
        
        // create the contacts
        insert plansToInsert;
        
        // check to see that the presence indicator is correct
        presence1 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct1.Id].Child_Record_Presence_AccountPlan__c;
        presence2 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct2.Id].Child_Record_Presence_AccountPlan__c;
        presence3 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct3.Id].Child_Record_Presence_AccountPlan__c;
        System.assertEquals(true, presence1, 'Acct Plan Presence1 has not been set correctly');
        System.assertEquals(true, presence2, 'Acct Plan Presence2 has not been set correctly');
        System.assertEquals(true, presence3, 'Acct Plan Presence3 has not been set correctly');
        
        test.starttest();
        
        // change the profile account assignment
        for (Integer x = 0; x < 66; x++) {
            plansToUpdate.add(new SFDC_Acct_Plan__c(id = plansToInsert[3 * x].Id, Account__c = acct3.Id));
            plansToUpdate.add(new SFDC_Acct_Plan__c(id = plansToInsert[(3 * x) + 1].Id, Account__c = acct1.Id));
            plansToUpdate.add(new SFDC_Acct_Plan__c(id = plansToInsert[(3 * x) + 2].Id, Account__c = acct2.Id));
        }
        plansToUpdate.add(new SFDC_Acct_Plan__c(id = plansToInsert[198].Id, Account__c = acct3.Id));
        plansToUpdate.add(new SFDC_Acct_Plan__c(id = plansToInsert[199].Id, Account__c = acct1.Id));
        
        // update the profiles
        update plansToUpdate;
        
        // check to see that the presence indicator is correct
        presence1 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct1.Id].Child_Record_Presence_AccountPlan__c;
        presence2 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct2.Id].Child_Record_Presence_AccountPlan__c;
        presence3 = [select Id, Child_Record_Presence_AccountPlan__c from account where id = :acct3.Id].Child_Record_Presence_AccountPlan__c;
        System.assertEquals(true, presence1, 'Acct Plan Presence1 has not been set correctly');
        System.assertEquals(true, presence2, 'Acct Plan Presence2 has not been set correctly');
        System.assertEquals(true, presence3, 'Acct Plan Presence3 has not been set correctly');
    }  //runAcctPlanUpdate_Bulk
*/  
    


    /////////////////////////////////////////////////////////////////////////////////////
    // helper functions 
    /////////////////////////////////////////////////////////////////////////////////////
    private static Account createNewAccount(String acctName) {
        Account account = new Account();
        account.name = acctName;
        account.Site_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account.Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account.Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        insert account;
        return account;
    }  //createNewAccount
    
   
    private static ProfileCustom__c createNewProfile(String acctId) {
        ProfileCustom__c profile = new ProfileCustom__c();
        profile.Account_del__c = acctId;
        insert profile;
        return profile;
        
    }  //createNewProfile

/*
    private static SFDC_Acct_Plan__c createNewAcctPlan(String acctId) {
        SFDC_Acct_Plan__c plan = new SFDC_Acct_Plan__c();
        plan.Account__c = acctId;
        plan.name = 'TestPlan';
        plan.Account_Type__c = 'Existing Customer';
        plan.Planning_Year__c = 'FY2010';
        plan.Plan_Status__c = 'Not Started';
        insert plan;
        return plan;    
    }  //createNewAcctPlan
*/

}