/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       		DEVELOPER     WR      	DESCRIPTION                               
 |  ====       		=========     ==       	=========== 
 |  13 Dec 2011		Shipra	   	182949		Test Class.SFA - Update TA Assignment Rule Staus to 'update' on insert/update.
  +===========================================================================*/
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
private class TC_TA_Assignment_Status_Update {

    static List<Account> lstAcc= new List<Account>();
	static List<TA_Assignment_Rule__c> lstTARule = new List<TA_Assignment_Rule__c>();
	static testMethod void tc_TAAssignRuleInsertAndUpdate()
	{
		Account acc2 = new Account();
		acc2.Name = 'Account 2';
		acc2.BillingCountry = 'United States';
		acc2.BillingState ='MA';
		acc2.EMC_Classification__c='Classification 2';
		lstAcc.add(acc2);
		insert lstAcc;
		
		TA_Assignment_Rule__c objTARule1= new TA_Assignment_Rule__c();
		objTARule1.Name='TA Assignment Rule Test 1';
		objTARule1.Country__c ='United States';
		objTARule1.State_Or_Province__c ='MA';
		objTARule1.Classification__c='Classification 2';
		objTARule1.Rule_Type__c='Geo Commercial';
		lstTARule.add(objTARule1);
		insert lstTARule;
	}
	static testMethod void tc_TAAssignmentRuleInsertWithCountry1()
	{
		Account acc1= new Account();
		acc1.Name = 'Account 1';
		acc1.BillingCountry='Country 1';
		acc1.BillingState='State 1';
		acc1.EMC_Classification__c='ENTERPRISE';
		lstAcc.add(acc1);
		insert lstAcc;
		
		TA_Assignment_Rule__c objTARule2= new TA_Assignment_Rule__c();
		objTARule2.Name='TA Assignment Rule Test 1';
		objTARule2.Country__c ='Country 1';
		objTARule2.State_Or_Province__c ='State 1';
		objTARule2.Classification__c='ENTERPRISE';
		objTARule2.Rule_Type__c='Geo Commercial';
		lstTARule.add(objTARule2);
		insert lstTARule;
	}
}