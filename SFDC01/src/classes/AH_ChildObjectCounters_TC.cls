@isTest
private class AH_ChildObjectCounters_TC {
/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |             L Jovanovic            Initial Creation.  Test methods for contact counter.               
 |  27-MAY-09  S Douglas              Updated to add test methods for lead counter.
 |  20-AUG-09  S Douglas              Updated to test changing account relationship on contact
 |  9 April 2010  Arif     DEFECT 614  Change 'Campaign_Event_Name_New__c to Campaign_Event_Name__c'  
 |  03 Mar 2011   Anirudh              Updated class to increase code Coverage and cover
 |                                     LeadAfterDelete and ContactAfterDelete Trigger.
 |  Aug-2011     Saravanan C         		Test Class cleanup
 +===========================================================================*/
 
    /////////////////////////////////////////////////////////////////////////////////////
    //  Contact Unit Test Methods
    /////////////////////////////////////////////////////////////////////////////////////

    static testMethod void runLeadInsert_Bulk() {
        
        // declare local vars
        List <Lead> leadsToInsert = new List <Lead>();
        Integer currentLeadCt1 = 0;
        Integer currentLeadCt2 = 0;
        Integer currentLeadCt3 = 0;
        
        
        
        // create 3 sample accounts
        Account acct1 = testclassUtils.getAccount() ;  //createNewAccount('runContactInsert_Bulk1');
         insert acct1 ;
        Account acct2 = testclassUtils.getAccount() ;  //createNewAccount('runContactInsert_Bulk2');
         insert acct2 ;
        Account acct3 = testclassUtils.getAccount() ;  //createNewAccount('runContactInsert_Bulk3');
         insert acct3 ;
         
        Contact con = createNewContact(acct1.Id, 'last');
        
          
        // loop and create 66 leads on each
        for (Integer x = 0; x < 66; x++) {
            leadsToInsert.add(new Lead(Company = 'TestLeadA' + x, lastName = 'LastNameA' + x, Related_Account__c = acct1.Id, 
                                       status = 'New', Campaign_Event_Name__c = 'No Campaign/Event', leadSource = 'Manual', lead_originator__c = 'Field'));
            leadsToInsert.add(new Lead(Company = 'TestLeadB' + x, lastName = 'LastNameB' + x, Related_Account__c = acct2.Id, 
                                       status = 'New', Campaign_Event_Name__c = 'No Campaign/Event', leadSource = 'Manual', lead_originator__c = 'Field'));
            leadsToInsert.add(new Lead(Company = 'TestLeadC' + x, lastName = 'LastNameC' + x, Related_Account__c = acct3.Id, 
                                       status = 'New', Campaign_Event_Name__c = 'No Campaign/Event', leadSource = 'Manual', lead_originator__c = 'Field'));
        }
        // add a 200th lead
        leadsToInsert.add(new Lead(Company = 'TestLeadA67', lastName = 'LastNameA67', Related_Account__c = acct1.Id, 
                                   status = 'New', Campaign_Event_Name__c = 'No Campaign/Event', leadSource = 'Manual', lead_originator__c = 'Field'));
        
        test.starttest();
        
        // create the contacts
        insert LeadsToInsert;
        delete LeadsToInsert[0];
        
        delete con;
        
        // Account acc = [ Select id, Grouping__c from Account where Grouping__c != null limit 1];
        Account acc = testclassUtils.getAccount() ; 
         insert acc ;
         Contact cont = createNewContact(acc.Id, 'Test');
         cont.Partner_User2__c = False;
         update Cont ;
        
        test.stopTest();

        // get Account Contact counts
        currentLeadCt1 = 
            [select id, Child_Record_Count_Lead__c from Account where Id = :acct1.Id].Child_Record_Count_Lead__c.intValue();
        currentLeadCt2 = 
            [select id, Child_Record_Count_Lead__c from Account where Id = :acct2.Id].Child_Record_Count_Lead__c.intValue();
        currentLeadCt3 = 
            [select id, Child_Record_Count_Lead__c from Account where Id = :acct3.Id].Child_Record_Count_Lead__c.intValue();  
            
        // check count
        //System.assertEquals(67, currentLeadCt1, 'Lead count is incorrect for mass create case');
        //System.assertEquals(66, currentLeadCt2, 'Lead count is incorrect for mass create case');
        //System.assertEquals(66, currentLeadCt3, 'Lead count is incorrect for mass create case');
    }  //runLeadInsert_Bulk

    
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
    private static Contact createNewContact(String acctId, String cntLastName) {
        Contact contact = new Contact(lastname = cntLastName, accountId = acctId);
        insert contact;
        contact.Partner_User2__c = True;
        update contact;
        return contact;
    } //createNewContact 
    private static Lead createNewLead( String acctId, String ldCompany, String ldLastName) {
        Lead lead = new Lead(Company = ldCompany, lastName = ldLastName, Related_Account__c = acctId, 
                             status = 'New', Campaign_Event_Name__c = 'No Campaign/Event', leadSource = 'Manual', lead_originator__c = 'Field');
        insert lead;

        // reset flags
        AH_ChildObjectCounters.resetFlagsForUnitTest();

        return lead;
    } //createNewLead 

   
    
} //TC_AH_ChildObjectCounters class