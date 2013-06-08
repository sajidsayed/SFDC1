@isTest

private class EBC_ShowProfiles_TC {
       
    static testMethod void test_getprofiles(){
    //declaring local variables
    ProfileCustom__c PC;
    Account acc = createNewAccount('Test acc');
    EBC_Briefing_Event__c BE = createNewBriefingEvent('Test_Briefing Event for profiles',acc);
    PC = new ProfileCustom__c(Account_del__c = acc.id,
                              Profile_Description__c = 'Testing profiles');
    
    //setting the page environment
    PageReference profileForBEPage = Page.EBC_ShowProfiles;
    profileForBEPage.getparameters().put('Id',BE.id);
    Test.setCurrentPage(profileForBEPage);
    
    //initialising the controller
    ApexPages.StandardController sc = new ApexPages.standardController(BE);
    EBC_ShowProfiles sP = new EBC_ShowProfiles(sc);
    List<ProfileCustom__c> lstOfProfiles = sP.getProfiles();
  
    }
            
        private static Account createNewAccount(String acctName) {
        Account account = new Account();
        account.name = acctName;
        account.Site_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account.Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account.Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        insert account;
        return account;
        }
        
        private static EBC_Briefing_Event__c createNewBriefingEvent(String BEname, Account acc) {
        EBC_Briefing_Event__c BE = new EBC_Briefing_Event__c();
        BE.Name = BEname;
        BE.Start_date__c = date.newInstance(2012, 12, 12);
        BE.End_date__c = date.newInstance(2012,12,13);
        BE.Projected_of_attendees__c = 10;
        BE.Customer_Name__c = acc.Id;
        BE.Objective_of_the_visit__c = 'Testing';
        BE.Briefing_Status__c = 'Requested';
        BE.Briefing_Center__c = 'a0j70000000Tbk1';//took hopkinton center as location
        insert BE;
        return BE;     
        }
}