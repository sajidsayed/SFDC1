/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class EBC_markChecked_TC {

    static testMethod void EBC_markChecked() {
        Account acc=new Account(name='testAccount',Global_DUNS_Entity__c='12');
        insert acc;
        EBC_Global_Strategic_Executive_Account__c gseAccount =new EBC_Global_Strategic_Executive_Account__c(Global_DUNS__c='12');
        insert gseAccount;
        EBC_Briefing_Event__c bEvent=new EBC_Briefing_Event__c(Customer_Name__c=acc.Id,Name='xyz',Start_Date__c=date.today(),End_Date__c=date.today(),Briefing_Status__c='Pending');
		insert bEvent;
    }
}