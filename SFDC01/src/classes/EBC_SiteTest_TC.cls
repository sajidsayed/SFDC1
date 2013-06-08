/**

Created By		:	Avinash Kaltari
Created Date	:	16 May 2012
Purpose			:	To increase the coverage of EBC_SiteTest class

*/

@isTest
private class EBC_SiteTest_TC 
{

    static testMethod void EBC_SiteTestTest() 
    {
		
		
		EBC_Briefing_Center__c bc=new EBC_Briefing_Center__c(name='hello');
        insert bc;
        EBC_Briefing_Venue__c bv=new EBC_Briefing_Venue__c(Briefing_Center__c=bc.Id);
        insert bv;
		EBC_Briefing_Event__c beRecord = new EBC_Briefing_Event__c(Name= 'testName', Briefing_Status__c= 'Open',Briefing_Center__c=bc.Id,Briefing_Venue__c=bv.Id);
		insert beRecord;
    	
    	System.currentPageReference().getParameters().put('mid',beRecord.id);
    	
    	EBC_SiteTest obj = new EBC_SiteTest();
    	
    }
}