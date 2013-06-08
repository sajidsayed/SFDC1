/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    04-Apr-2011     Srinivas Nallapati      170056               
==============================================================================*/
@isTest
private class TASyncLogCreateController_TC {

    static testMethod void myUnitTest() {
    	Pagereference pgf = Page.TASyncLogCreate;
    	Test.setCurrentPage(pgf);
    	
    	User u = [select id from user where isactive=true limit 1];
    	
    	TASyncLogCreateController taCon = new TASyncLogCreateController(new Apexpages.Standardcontroller(new TA_Sync_Log__c()));
    	taCon.talog.Sales_Resource__c = u.id;
    	taCon.save();
   	
    	TASyncLogCreateController.SendTASyncLimitNotification();
    }
}