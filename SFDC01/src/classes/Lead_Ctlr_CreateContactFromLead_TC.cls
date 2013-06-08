/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |  22-JUL-09  S Douglas              Initial Creation. Test class for CTCT_DuplicateInfo_WithSharing
 |  9 April 2010  Arif    DEFECT 614  Change 'Campaign_Event_Name_New__c to Campaign_Event_Name_New__c'     
 |  Aug-2011        Saravanan C             Test Class cleanup 
 |02/05/2013        Nimai Meher             Commented Title_Type__c & Type__c field as part of WR - 256428 (Contact simplification) for June Release.
 +===========================================================================*/
@isTest
private class Lead_Ctlr_CreateContactFromLead_TC {

    /////////////////////////////////////////////////////////////////////////////////////
    // test functions 
    /////////////////////////////////////////////////////////////////////////////////////
    
    static testMethod void runTest_GoodLead() {
        
        // create some test data
        Account acct1 = createNewAccount();
        Account acct2 = createNewAccount();

        //Create a contact under account 1
        Contact cont1 = createNewContact(acct1.id,'testcontact1@bogusco.com');
        
        //Create a lead under account 2
        //Lead lead = createNewLead(acct2.id,'testcontact2@bogusco.com');
        Lead lead = new Lead();
        lead.Related_Account__c = acct2.id;
        lead.email = 'testcontact2@bogusco.com';
        lead.Company = EMC_UTILITY.generateRandomString(5);
        lead.lastName = EMC_UTILITY.generateRandomString(5);
        lead.firstName = EMC_UTILITY.generateRandomString(5);
        lead.status = 'New';
        lead.Campaign_Event_Name__c = 'No Campaign/Event';
        lead.leadSource = 'Manual';
        lead.lead_originator__c = 'Field';
        lead.salutation = 'Dr';
        lead.department__c = 'Operations';
        lead.role__c = EMC_UTILITY.generateRandomString(5);
        lead.title = EMC_UTILITY.generateRandomString(5);
        //lead.title_type__c = 'Other';
        //lead.type__c = 'Front Office';
        lead.phone = '5555555';
        lead.mobilephone = '7777777';
        lead.DoNotCall = true;
        lead.HasOptedOutOfEmail = true;
        lead.Description = EMC_UTILITY.generateRandomString(5);
        lead.accept_lead__c = true;
        insert lead;
        
        // initialize the page reference
        PageReference pageRef = Page.Lead_CreateContactFromLead;
        ApexPages.currentPage().getParameters().put('id', lead.id);
        
        // set the context for the controller
        Lead_Ctlr_CreateContactFromLead ctlr = new Lead_Ctlr_CreateContactFromLead(new ApexPages.StandardController(lead));
        
        PageReference resPageRef = ctlr.autoRun();
        
        //Validate Results
        /*List<Contact> createdContact = [SELECT id, AccountId, Email, LastName, FirstName, Salutation,
                                        Department__c, Role__c, Title, Title_Type__c, Type__c, 
                                        Phone, MobilePhone, DoNotCall, HasOptedOutOfEmail, Description
                                        FROM Contact WHERE AccountId = :acct2.id and email = 'testcontact2@bogusco.com'];
        */                                
        List<Contact> createdContact = [SELECT id, AccountId, Email, LastName, FirstName, Salutation,
                                        Department__c, Role__c, Title, 
                                        Phone, MobilePhone, DoNotCall, HasOptedOutOfEmail, Description
                                        FROM Contact WHERE AccountId = :acct2.id and email = 'testcontact2@bogusco.com'];
        System.AssertEquals(1, createdContact.size(), 'Contact count incorrect for Good Lead');
        System.AssertEquals('/' + createdContact[0].id, resPageRef.getUrl(), 'Incorrect redirect pageReference after creating contact for good lead');
        System.AssertEquals(false, ApexPages.hasMessages(), 'Apex Page has error after creating contact for dup contact');
        System.AssertEquals(false, ctlr.getDuplicateContactsExist(), 'getDuplicateContactsExist set incorrectly after creating contact for good lead');
        //Mappings
        System.AssertEquals(lead.Related_Account__c, createdContact[0].AccountId, 'AccountId set incorrectly on created contact');
        System.AssertEquals(lead.Email, createdContact[0].Email, 'Email set incorrectly on created contact');
        System.AssertEquals(lead.LastName, createdContact[0].LastName, 'LastName set incorrectly on created contact');
        System.AssertEquals(lead.FirstName, createdContact[0].FirstName, 'FirstName set incorrectly on created contact');
        System.AssertEquals(lead.Salutation, createdContact[0].Salutation, 'Salutation set incorrectly on created contact');
        System.AssertEquals(lead.Department__c, createdContact[0].Department__c, 'Department__c set incorrectly on created contact');
        System.AssertEquals(lead.Role__c, createdContact[0].Role__c, 'Role__c set incorrectly on created contact');
        System.AssertEquals(lead.Title, createdContact[0].Title, 'Title set incorrectly on created contact');
        //System.AssertEquals(lead.Title_Type__c, createdContact[0].Title_Type__c, 'Title_Type__c set incorrectly on created contact');
        //System.AssertEquals(lead.Type__c, createdContact[0].Type__c, 'Type__c set incorrectly on created contact');
        System.AssertEquals(lead.Phone, createdContact[0].Phone, 'Phone set incorrectly on created contact');
        System.AssertEquals(lead.MobilePhone, createdContact[0].MobilePhone, 'MobilePhone set incorrectly on created contact');
        System.AssertEquals(lead.DoNotCall, createdContact[0].DoNotCall, 'DoNotCall set incorrectly on created contact');
        System.AssertEquals(lead.HasOptedOutOfEmail, createdContact[0].HasOptedOutOfEmail, 'HasOptedOutOfEmail set incorrectly on created contact');
        System.AssertEquals(lead.Description, createdContact[0].Description, 'Description set incorrectly on created contact');
        Lead updatedLead = [SELECT Related_Contact__c FROM Lead WHERE id = :lead.Id];
        System.AssertEquals(updatedLead.Related_Contact__c, createdContact[0].Id, 'Related_Contact__c set incorrectly on originating lead');
    }

    static testMethod void runTest_MissingId() {
        
        // initialize the page reference
        PageReference pageRef = Page.Lead_CreateContactFromLead;
        //ApexPages.currentPage().getParameters().put('id', lead.id);
        
        // set the context for the controller
        Lead_Ctlr_CreateContactFromLead ctlr = new Lead_Ctlr_CreateContactFromLead(new ApexPages.StandardController(new Lead()));
        
        PageReference resPageRef = ctlr.autoRun();
        
        //Validate Results
        System.AssertEquals(true, ApexPages.hasMessages(), 'Apex Page has error after creating contact for dup contact');
    }

    static testMethod void runTest_NotAccepted() {
        
        // get user profile id for the user that shall be created
        String cmaUserProfileId = [select id from profile where name = 'CMA Standard User'].Id;
        String cmaRoleId = [select id from userRole where name = 'IIG AMER'].id;
        
        User cmaUser = returnUser(cmaUserProfileId, cmaRoleId);
       // User cmaUser = createNewUser(cmaUserProfileId, cmaRoleId);
        System.debug('Test cma user info( Id: ' + cmaUser.Id + '; username: ' + cmaUser.username + ')');
        
        // get a user 
        //Note:  creating the user doesn't appear to work, I get errors about the role
        //If this user is inactivated, will have to change the id...
//      User cmaUser = [SELECT Id FROM User WHERE id = '00570000001KiLU'];

        
        // create some test data
        Account acct1 = createNewAccount();
        Account acct2 = createNewAccount();

        //Create a contact under account 1
        Contact cont1 = createNewContact(acct1.id,'testcontact1@bogusco.com');  
        
        //Create a lead under account 2
        Lead lead = createNewLead(acct2.id, 'testcontact2@bogusco.com', true);
          

        // initialize the page reference
        PageReference pageRef = Page.Lead_CreateContactFromLead;
        ApexPages.currentPage().getParameters().put('id', lead.id);
        
        // set the context for the controller
        Lead_Ctlr_CreateContactFromLead ctlr = new Lead_Ctlr_CreateContactFromLead(new ApexPages.StandardController(lead));
        
        // run through the duplicate methods as a standard user
        PageReference resPageRef;
        System.RunAs(cmaUser) {
            resPageRef = ctlr.autoRun();
        }
        
        //Validate Results
        List<Contact> createdContact = [SELECT id FROM Contact WHERE email = 'testcontact2@bogusco.com'];
        System.AssertEquals(0, createdContact.size(), 'Contact count incorrect for unaccepted lead');
        System.AssertEquals(null, resPageRef, 'Incorrect redirect pageReference after attempting create contact for unaccepted lead');
        //System.AssertEquals(true, ApexPages.hasMessages(), 'Apex Page does not have error after creating contact for unaccepted lead');
        System.AssertEquals(false, ctlr.getDuplicateContactsExist(), 'getDuplicateContactsExist set incorrectly after creating contact for unaccepted lead');

    }

    static testMethod void runTest_NotAccepted_Admin() {
        
        // create some test data
        Account acct1 = createNewAccount();
        Account acct2 = createNewAccount();

        //Create a contact under account 1
        Contact cont1 = createNewContact(acct1.id,'testcontact1@bogusco.com');  
        
        //Create a lead under account 2
        Lead lead = createNewLead(acct2.id, 'testcontact2@bogusco.com', true);
          

        // initialize the page reference
        PageReference pageRef = Page.Lead_CreateContactFromLead;
        ApexPages.currentPage().getParameters().put('id', lead.id);
        
        // set the context for the controller
        Lead_Ctlr_CreateContactFromLead ctlr = new Lead_Ctlr_CreateContactFromLead(new ApexPages.StandardController(lead));
        
        PageReference resPageRef = ctlr.autoRun();
        
        //Validate Results -- System administrators do not have to accept the lead
        List<Contact> createdContact = [SELECT id FROM Contact WHERE email = 'testcontact2@bogusco.com'];
       // System.AssertEquals(1, createdContact.size(), 'Contact count incorrect for unaccepted lead');

    }

    static testMethod void runTest_MissingAccount() {
        
        // create some test data
        Account acct1 = createNewAccount();
        Account acct2 = createNewAccount();

        //Create a contact under account 1
        Contact cont1 = createNewContact(acct1.id,'testcontact1@bogusco.com');  
        
        //Create a lead under account 2
        Lead lead = createNewLead(null, 'testcontact2@bogusco.com', true);
          

        // initialize the page reference
        PageReference pageRef = Page.Lead_CreateContactFromLead;
        ApexPages.currentPage().getParameters().put('id', lead.id);
        
        // set the context for the controller
        Lead_Ctlr_CreateContactFromLead ctlr = new Lead_Ctlr_CreateContactFromLead(new ApexPages.StandardController(lead));
        
        PageReference resPageRef = ctlr.autoRun();
        
        //Validate Results
        List<Contact> createdContact = [SELECT id FROM Contact WHERE email = 'testcontact2@bogusco.com'];
        System.AssertEquals(0, createdContact.size(), 'Contact count incorrect for missing account');
        System.AssertEquals(null, resPageRef, 'Incorrect redirect pageReference after attempting create contact for missing account');
        System.AssertEquals(true, ApexPages.hasMessages(), 'Apex Page does not have error after creating contact for dup contact');
        System.AssertEquals(false, ctlr.getDuplicateContactsExist(), 'getDuplicateContactsExist set incorrectly after creating contact for missing account');

    }
    
    static testMethod void runTest_MissingEmail() {
        
        // create some test data
        Account acct1 = createNewAccount();
        Account acct2 = createNewAccount();

        //Create a contact under account 1
        Contact cont1 = createNewContact(acct1.id,'testcontact1@bogusco.com');  
        
        //Create a lead under account 2
        Lead lead = createNewLead(acct2.id, null, true);
          

        // initialize the page reference
        PageReference pageRef = Page.Lead_CreateContactFromLead;
        ApexPages.currentPage().getParameters().put('id', lead.id);
        
        // set the context for the controller
        Lead_Ctlr_CreateContactFromLead ctlr = new Lead_Ctlr_CreateContactFromLead(new ApexPages.StandardController(lead));
        
        PageReference resPageRef = ctlr.autoRun();
        
        //Validate Results
        List<Contact> createdContact = [SELECT id FROM Contact WHERE AccountId = :acct2.id];
        System.AssertEquals(0, createdContact.size(), 'Contact count incorrect for missing email');
        System.AssertEquals(null, resPageRef, 'Incorrect redirect pageReference after attempting create contact for missing email');
        System.AssertEquals(true, ApexPages.hasMessages(), 'Apex Page does not have error after creating contact for dup contact');
        System.AssertEquals(false, ctlr.getDuplicateContactsExist(), 'getDuplicateContactsExist set incorrectly after creating contact for missing email');

    }

    static testMethod void runTest_DupContact() {
        
        // create some test data
        Account acct1 = createNewAccount();
        Account acct2 = createNewAccount();

        //Create a contact under account 1
        Contact cont1 = createNewContact(acct1.id,'testcontact1@bogusco.com');  
        
        //Create a lead under account 2
        Lead lead = createNewLead(acct2.id,'testcontact1@bogusco.com', true);
          

        // initialize the page reference
        PageReference pageRef = Page.Lead_CreateContactFromLead;
        ApexPages.currentPage().getParameters().put('id', lead.id);
        
        // set the context for the controller
        Lead_Ctlr_CreateContactFromLead ctlr = new Lead_Ctlr_CreateContactFromLead(new ApexPages.StandardController(lead));
        
        PageReference resPageRef = ctlr.autoRun();
        
        //Validate Results
        List<Contact> createdContact = [SELECT id FROM Contact WHERE AccountId = :acct2.id and email = 'testcontact12@bogusco.com'];
        System.AssertEquals(0, createdContact.size(), 'Contact count incorrect for dup contact');
        System.AssertEquals(null, resPageRef, 'Incorrect redirect pageReference after attempting create contact for dup contact');
        System.AssertEquals(true, ApexPages.hasMessages(), 'Apex Page does not have error after creating contact for dup contact');
        System.AssertEquals(true, ctlr.getDuplicateContactsExist(), 'getDuplicateContactsExist set incorrectly after creating contact for dup contact');
        List <Contact> dupContacts = ctlr.getDuplicateContacts();
        for (Integer x=0; x < dupContacts.size(); x++) {
            System.AssertEquals('testcontact1@bogusco.com', dupContacts[x].email, 'getDuplicateContacts returned incorrect duplicate after creating contact for dup contact');
        }

    }

    /////////////////////////////////////////////////////////////////////////////////////
    // helper functions 
    /////////////////////////////////////////////////////////////////////////////////////
    private static Account createNewAccount() {
        Account account = new Account();
        account.name = EMC_UTILITY.generateRandomString(20);
        account.Site_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account.Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account.Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        
        Database.Saveresult[] sr = Database.insert(new Account[] {account});
        System.debug('Account save result: ' + sr[0].isSuccess());
        if (!sr[0].isSuccess()) {
            System.debug(sr[0].getErrors());
        } else {
            System.debug(sr[0].Id);
        }
        return account;
    } //createNewAccount
    private static Contact createNewContact(String acctId, String email) {
        Contact contact = new Contact();
        contact.accountId = acctId;
        contact.email = email;
        contact.lastname = EMC_UTILITY.generateRandomString(5);
        contact.active__c = true;
        insert contact;
        return contact;
    } //createNewContact 
    private static Lead createNewLead( String acctId, String ldEmail, Boolean acceptLead) {
        Lead lead = new Lead();
        lead.Related_Account__c = acctId;
        lead.email = ldEmail;
        lead.Company = 'Dummy Co';  //EMC_UTILITY.generateRandomString(5);
        lead.lastName = 'DummyName';  //EMC_UTILITY.generateRandomString(5);
        lead.status = 'New';
        lead.Campaign_Event_Name__c = 'No Campaign/Event';
        lead.leadSource = 'Manual';
        lead.lead_originator__c = 'Field';
        lead.accept_lead__c = acceptLead;
        insert lead;
        return lead;
    } //createNewLead
    
   
    private static User returnUser(String profilesId,String rolesId) {
        User testUser = [Select Alias,email,lastname,username,ProfileId,BU__c, Employee_Number__c from User where ProfileId=:profilesId and IsActive =true and UserRoleId=:rolesId limit 1];       
        return testUser;    
    }    
}