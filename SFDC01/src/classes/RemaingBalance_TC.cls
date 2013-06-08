/**

Created By		:	Avinash Kaltari
Created Date	:	22 May 2012
Purpose			:	To increase the coverage of RemaingBalance class

Modified By		:	Avinash K
Modified Date	:	31 May 2012
Purpose			:	To increase the coverage for "updateLOE" trigger.

*/
@isTest
private class RemaingBalance_TC 
{

    static testMethod void RemaingBalanceTest() 
    {
    											
		
    	
    	List<Release__c> lst = [select name from Release__c limit 50000];
    	if(lst != null && lst.size() > 0)
    		delete lst;
    	Release__c  r = new Release__c(Release__c = 2);
    	insert r;
    	Application_Requirement__c ar = new Application_Requirement__c(Release__c = r.id, Removed_Release__c = false);
    	insert ar;
    	Build_Inventory__c bi = new Build_Inventory__c(Requirement__c = ar.id, Estimated_Design_LOE__c = null, 
    													Estimated_Build_Unit_Test_LOE__c = null, Type__c = 'Apex', Complexity__c = 'Low',
    													Estimated_SIT_LOE__c = null, Work_Completed__c = null, Build_Work_Completed__c = null,
    													SIT_Work_Completed__c = null);
    	insert bi;
    	
    	Allocated_Release_Workhours__c arw = new Allocated_Release_Workhours__c (Allocated_Design_Workhours__c = null, Release__c = r.id,
    																Allocated_Build_Workhours__c = null, Allocated_SIT_Workhours__c = null);
    	
    	insert arw;
    	
    	RemaingBalance rb = new RemaingBalance();
    	
    	Double d = rb.getAvailableBalance();
    	d = rb.getRemainingBalance();
    	d = rb.getTotalLOE();
    	
    	Build_Inventory__c bi2 = new Build_Inventory__c(Requirement__c = ar.id, Override_Estimated_LOE__c = false,
    													 Type__c = 'Apex', Complexity__C = 'Low'
    													 );
    													
		insert bi2;
		
		List<Estimation_Factor__c> lstef = [select name from Estimation_Factor__c limit 50000];
		if(lstef != null && lstef.size() > 0)
			delete lstef;
		
		Build_Inventory__c bi3 = new Build_Inventory__c(Requirement__c = ar.id, Override_Estimated_LOE__c = false,
    													 Type__c = 'Visualforce', Complexity__C = 'High'
    													 );
    													
		insert bi3;

		
    }
}