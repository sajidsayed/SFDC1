/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  23.06.2011      Suman B                This is testClass for integrationerrorlog.
 +=========================================================================================================================*/

@isTest
private class PRM_DealReg_IntegrationErrorLog_TC {

  static testMethod void IntegrationErrorLog_TEST() {
     PRM_DealReg_IntegrationErrorLog errlog = new PRM_DealReg_IntegrationErrorLog(); 
     PRM_DealReg_IntegrationErrorLog.createdErrorLog('integrationName', 'integrationID', 'errorMessage') ;
        Integration_error_log__c objErrorLog = new Integration_error_log__c();
        objErrorLog.Integration_Name__c = 'integrationNametest';
    	objErrorLog.Integration_ID__c = '123455';
    	objErrorLog.Error_Message__c = 'errorMessagetest';     	
    	try{
    		insert   objErrorLog;
    	     List<Integration_error_log__c> listErrLog = new List<Integration_error_log__c>();
    	     listErrLog.add(objErrorLog);
    	     errlog.insertOutboundMessageLogRecord(listErrLog) ;
             system.assertNotEquals(objErrorLog.id,null) ;	
    	}
    	catch(Exception Ex){
    		system.debug('Error in testclass PRM_DealReg_IntegrationErrorLog_TC');
    		
    	}
    }
}