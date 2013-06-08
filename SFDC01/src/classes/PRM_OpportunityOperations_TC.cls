/*=====================================================================================================+
|  HISTORY  |                       
|  DATE          DEVELOPER               WR         DESCRIPTION 
  ====          =========               ==         =========== 
|  05/07/2011    Ashwini Gowda            			This class is used to unit test 
													PRM_OpportunityOperations Class
|  14/12/2011		Anil							used Custom setting Data Helper

	30/05/2012	Avinash K							To increase the coverage for "OpportunityAfterUpdate" trigger
 +=====================================================================================================*/
@isTest
private class PRM_OpportunityOperations_TC {
	
	static testmethod void testdata() {
		 User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
	        System.runAs(insertUser)
	        {
	    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
	        }
	        Test.startTest();
		 Account account = createAccount('Testing');
		 Opportunity opportunity = createOpportunity('Test Oppty',account.id);		 
         Map<Id,Opportunity> newOpportunityMap = new Map<Id,Opportunity>();
         Map<Id,Opportunity> oldOpportunityMap = new Map<Id,Opportunity>();
         newOpportunityMap.put(opportunity.id,opportunity);
         opportunity.Opportunity_Number__c = '123456789012334';
         update opportunity;
         oldOpportunityMap.put(opportunity.id,opportunity);
         PRM_OpportunityOperations opptyOperation = new PRM_OpportunityOperations();
         opptyOperation.updateDealRegs(newOpportunityMap,oldOpportunityMap);
		
		 
//Avinash' code begins...
		 opportunity.StageName = 'Booked';
		 update opportunity;
//Avinash's code ends.


		 Test.stopTest();
	}
	
	static Account createAccount(String accountName){
		Account account1 = new Account();
        account1.name = accountName;
        account1.Partner_Type__c='ISV';  
		insert account1;   
        return account1;
    }
    
    static Opportunity createOpportunity(String opportunityName,String AccountId){    	
        Date closeDate = date.newinstance(2012, 11, 17);
        Date approvalDate = date.newinstance(2011, 11, 1);
        Date expirationDate = date.newinstance(2013, 11, 18);
    	Opportunity Oppty = new Opportunity();
    	Oppty.Name = opportunityName;
        Oppty.AccountId = AccountId;
        Oppty.Sales_Channel__c = 'Direct';
        //Oppty.Opportunity_Number__c = '1234567';
        Oppty.Sales_Force__c = 'EMC';
        Oppty.StageName = 'Pipeline';
        Oppty.Closed_Reason__c = 'Loss';
        Oppty.Close_Comments__c = 'Lost';
        Oppty.CloseDate = closeDate;
        Oppty.Sell_Relationship__c = 'Direct';
        Oppty.Quote_Version__c='v13';
        Oppty.Quote_Type__c='New';
        Oppty.Approval_Date__c=approvalDate ;
        Oppty.Expiration_Date__c=expirationDate ;
        Oppty.Primary_Outsourcer_System_Integrator__c=AccountId;
	    Oppty.Primary_ISV_Infrastructure__c=AccountId;
	    Oppty.bypass_validation__c = true;
        insert Oppty;
        return Oppty;
    }
}