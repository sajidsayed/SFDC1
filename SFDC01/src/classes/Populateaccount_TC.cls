//    9 April 2010  Arif   DEFECT 614  Change 'Campaign_Event_Name__c to Campaign_Event_Name__c' 


@isTest
private class Populateaccount_TC {

    static testMethod void testDuplicateDUNSView() {
// create Account
        Account acct1 = createNewAccount('Account1');

// create Contact
        Contact cnt1 = createNewContact(acct1.Id,'TestContact1');
               
// create Lead
        Lead lead1 = createNewLead(acct1.Id,'TestLead1', 'LastName1');

//Create new task1
Task  task1=new task(whoid=cnt1.id,VCE_Assigned_To__c = 'EMC',
                VCE_Last_Modifying_Partner__c = 'EMC', Subject = 'Call',
                Type ='Email');
insert task1;

Map <String,String> activities= new Map<String,String>();
activities.put(task1.id,lead1.id);
List<String> contact_ids= new List<String>();
contact_ids.add(cnt1.id);
List<Task> tasks = [Select id,whatid,whoid from Task limit 1];
List<Event> events = [Select id,whatid,whoid from Event limit 1];
RelateAccountonActivities relateaccount = new RelateAccountonActivities();
RelateAccountonActivities.populateAccountOfLeadOnTask(activities);
RelateAccountonActivities.populateAccountOfLeadOnEvenet(activities);
relateaccount.populateAccountOfContactOnTask(tasks,contact_ids);
relateaccount.populateAccountOfContactOnEvent(events,contact_ids);
}
    private static Account createNewAccount(String acctName) {
    Account account = new Account();
    account.name = acctName;
    insert account;
    return account;
 }
    private static Contact createNewContact(String acctId, String cntLastName) {
        Contact contact = new Contact(lastname = cntLastName, accountId = acctId);
        insert contact;
        return contact;
    } //createNewContact 
     private static Lead createNewLead( String acctId, String ldCompany, String ldLastName) {
        Lead lead = new Lead(Company = ldCompany, lastName = ldLastName, Related_Account__c = acctId, 
                             status = 'New', Campaign_Event_Name__c = 'No Campaign/Event', leadSource = 'Manual', lead_originator__c = 'Field');
        insert lead;

        // reset flags
        AH_ChildObjectCounters.resetFlagsForUnitTest();

        return lead;
  } 
}