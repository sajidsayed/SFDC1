/**

Created By		:	Avinash Kaltari
Created Date	:	17 May 2012
Purpose			:	To increase the coverage of TASyncComponentController class

*/
@isTest
private class TASyncComponentController_TC 
{

    static testMethod void TASyncComponentControllerTest() 
    {
    	TASyncLimitCounter__c limitObj = new TASyncLimitCounter__c (Name = 'test', IsProcessedInNextCycle__c = 'Processed');
		insert limitObj;
		TASyncComponentController compObj = new TASyncComponentController();
    }
}