/** 
 5-5-2011   Srinivas Nallapati        Field Inventory 
 
 */
@isTest
private class TC_populateFIOwner {

    static testMethod void myUnitTest() {
        List<Account> lstaccount = new List<Account>();
        Account account1 = new Account();
        account1.name = 'Test';
        account1.Partner_Type__c='ISV';
        lstaccount.add(account1);
        insert lstaccount;
        
        User usr = [select id from user where profile.name='System Administrator' and isActive=true limit 1]; 
        
        Field_Inventory__c fi1 = new Field_Inventory__c(Account__c = account1.id,RMA_Number__c='TestRMA Number 11',FI_Owner__c=usr.id);
        insert fi1;
        fi1 = [select id, ownerid, FI_Owner__c from Field_Inventory__c where id=:fi1.id];
        system.assertEquals(fi1.ownerid,fi1.FI_Owner__c);
        update fi1;
        system.assertEquals(fi1.ownerid,fi1.FI_Owner__c);
    }
}