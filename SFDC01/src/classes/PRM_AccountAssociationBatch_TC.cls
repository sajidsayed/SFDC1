/*====================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR         DESCRIPTION                               

 |  ====          =========      ==         =========== 

 |  21/06/2011    Ramu M            Test class for PRM_AccountAssociationBatch.
 |  15/12/2011      Anil            Used Custom setting Data Halper
    19/10/2012    Arif              Added custom string generation function 
                                 
 |=============================================================================================================== */

@isTest
Private Class PRM_AccountAssociationBatch_TC{
    static TestMethod void PRM_AccountAssociationBatch_TC(){
    /* @Method <This method is used to test account share creation between the associated accounts>.   
        @param - <void>  
        @return <void> - <Not Returning anything   
        @throws exception - <No Exception>
    */ 
    User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
    User testUser;
    User inactiveUser;
    String partnerContId;
    List<Account> lstAccount = new List<Account>();
    RecordType recordTypePartner = [select Id from RecordType where name = 'Partner Account Record Type'];
    
    /*Creating account record*/
    Account account = new Account();
    account.name = 'UNITTESTAcc';
    account.RecordTypeId = recordTypePartner.Id;
    account.Child_Partner_Users_Count__c = 1;
    insert account;
    account.IsPartner = true;
    update account;
    lstAccount.add(account);
    
    /*Creating Contact record*/
    Contact cont = new Contact();
    cont.LastName = 'Test-Con';
    cont.AccountId = account.Id;
    cont.Email = 'acc@acc.com';
    cont.Partner_User2__c = true;
      
    Insert cont;
    
    User adminUser = [Select id from User where isActive = true and profile.Name='System Administrator' limit 1];
    
    system.runAs(adminUser){
        testUser = testData(cont.Id);
    }
    List<User> lstUser = new List<User>();
    lstUser.add(testUser);
    
        
    /*Creating Contact record*/
    Contact partnerUser = new Contact();
    partnerUser.LastName = 'Test-Partner Con';
    partnerUser.AccountId = account.Id;
    partnerUser.Email = 'acc1@acc.com';
    partnerUser.Partner_User2__c = true;
    
    Insert partnerUser;
    
    Test.startTest();
    system.runAs(testUser){
        Database.executebatch(new PRM_AccountAssociationBatch());
        PRM_AccountAssociationBatch obj = new PRM_AccountAssociationBatch();
        obj.getPartnerAccountExecutiveRoles(lstAccount);
        obj.createAccountShare();
        obj.getAccountsFromUser(lstUser);
    }
    /*system.runAs(inactiveUser){
    PRM_ContactUserSynchronization contactClass = new PRM_ContactUserSynchronization();
    contactClass.disablingPartnerContactsBatch();
    }*/
    Test.stopTest();
    
    }
    
    static User testData(Id contId){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1]; 
        string randomName = string.valueof(Datetime.now()).replace('-','').replace(':','').replace(' ','');           
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
        String directReseller = data.get('EMEA Direct Reseller Partner User').DataValue__c ;
        Profile p = [select id from profile where name =: directReseller];
        
        User testUser = new User(alias = 'u1421', email='u145612@testorg.com',
                                emailencodingkey='UTF-8', lastname='Testing'+randomName, languagelocalekey='en_US',
                                localesidkey='en_US', profileid = p.Id, country='United States',
                                timezonesidkey='America/Los_Angeles', username='u1@testorg.com.'+randomName,
                                contactId = contId);
 
        insert testUser;
        return testUser;
    }
    
    
}