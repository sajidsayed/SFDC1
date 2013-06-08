/*

Modified By		:	Avinash Kaltari
Modified Date	:	30 May 2012
Purpose			:	To increase the coverage for the 'AfterInsertUpdateTA_AssignmentRule' trigger.
*/

@isTest
Private class TO_AccountTARuleAssignment_TC {

    Private static testMethod void myUnitTest() { 
       List <Account> accns = new List<Account>();
       
       Group grp=[select Id from Group limit 1];
        Test.StartTest();
       for(integer i = 0; i<20; i++){
        if(i<5)
        {
            Account a = new Account(name='testAccount'+i, TA_Assignment_Type__c='Create',BillingCountry='US',BillingState='CA',EMC_Classification__c='EMC');
            accns.add(a);
        }
        else if(i<10)
        {
            Account a = new Account(name='testAccount'+i, TA_Assignment_Type__c='Create',BillingCountry='United States',BillingState='CA',EMC_Classification__c='EMC');
            accns.add(a);
        }
        else if(i<15)
        {
            Account a = new Account(name='testAccount'+i, TA_Assignment_Type__c='Update',BillingCountry='USA',BillingState='MA',EMC_Classification__c='EMC');
            accns.add(a);
         }
        else
        {
            Account a = new Account(name='testAccount'+i, TA_Assignment_Type__c='Create',BillingCountry='India',BillingState='HR',EMC_Classification__c='EMC');
            accns.add(a);
        }       
      }
          
       TA_Assignment_Rule__c tr = new TA_Assignment_Rule__c(name='rule', Country__c='United States',State_Or_Province__c='CA',Classification__c='EMC',Group_Id__c=grp.Id);
       insert tr;
       TA_Assignment_Rule__c tr2 = new TA_Assignment_Rule__c(name='rule1', Country__c='US',State_Or_Province__c='CA',Classification__c='EMC',Group_Id__c=grp.Id);
       insert tr2;
       TA_Assignment_Rule__c tr3 = new TA_Assignment_Rule__c(name='rule', Country__c='USA',State_Or_Province__c='MA',Classification__c='EMC',Group_Id__c=grp.Id);
       insert tr3;
       TA_Assignment_Rule__c tr4 = new TA_Assignment_Rule__c(name='rule1', Country__c='India',State_Or_Province__c='HR',Classification__c='EMC',Group_Id__c=grp.Id);
       insert tr4;      
       insert accns;
        List<AccountShare> accShare_Lst=new List<AccountShare>();//This List is used here to insert Account Share records.
       for(Integer i=0;i<accns.size();i++)
       {
        accShare_Lst.add(new AccountShare(UserOrGroupId=grp.Id,accountId=accns[i].Id,AccountAccessLevel='Read',
                                                          OpportunityAccessLevel='Read',CaseAccessLevel='Read'));
       } 
       insert accShare_Lst;
      
       TO_AccountTARuleAssignment reassign = new TO_AccountTARuleAssignment();
       
       reassign.query='Select id,BillingCountry,EMC_Classification__c,TA_Assignment_Rule__c, TA_Assignment_Type__c, BillingState,(Select id,UserOrGroupId from Shares where RowCause=\'Manual\')  from Account where Name LIKE \'testAccount%\'';
       Database.executeBatch(reassign, 40);

       reassign.COLLECTION_LIMIT = 3;
       
       List <Account> updateAcc = [Select id,Name, BillingCountry, EMC_Classification__c, TA_Assignment_Rule__c, TA_Assignment_Type__c, BillingState,(Select id,UserOrGroupId from Shares )  from Account where Name LIKE 'testAccount%'];
       integer i = 0;
       for(Account acc: updateAcc){
        acc.TA_Assignment_Type__c='Update';
        System.debug('ACC RULE ID = '+ acc.TA_Assignment_Rule__c+'--------------->test'+acc.Name);
      }   
      update updateAcc;
      ID batchprocessid1 = Database.executeBatch(reassign);
      
// Avinash's code begins...
		tr4.Country__c = 'USA';
		update tr4;
// Avinash's code ends.

        Test.stopTest(); 
    }
}