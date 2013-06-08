/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       		DEVELOPER     WR      	DESCRIPTION                               
 |  ====       		=========     ==       	=========== 
 |  13 Dec 2011		Shipra	   	177094		Test Class.SFA - Remove inactive users from Account Team.
 |  03 Nov 2012     Vivekananda 204934      Test Clsss.SFA - Test Class for To_DeleteInactiveAccountTeamMemb.
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
private class TC_DeactivateUser 
{
	static testMethod void tc_Schedule_ToDeleteInactiveAccountTeamMemb() 
    {
    	 RunInactiveATbatch__c RIA = new RunInactiveATbatch__c();
         RIA.Name ='FlagStatus';            
         RIA.StatusFlag__c = true;
        Database.insert(RIA,false);
        ATMLimit__c atlmt = new ATMLimit__c(LimitNumber__c ='100');
        Database.insert(atlmt,false);
        To_DeleteInactiveAccountTeamMemb objTest = new To_DeleteInactiveAccountTeamMemb();
        objTest.query ='Select a.AccountAccessLevel, a.AccountId, a.Id, a.LastModifiedDate, a.TeamMemberRole, a.UserId, a.User.IsActive, a.User.LastModifiedDate, a.User.Name from AccountTeamMember a where a.User.IsActive = false LIMIT 100';       
        System.Test.startTest(); 
        id  batchid = Database.executeBatch(objTest);        
        System.Test.stopTest();
        RIA.StatusFlag__c = false;
        Database.update(RIA,false);
    }
	
}