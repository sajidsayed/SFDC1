/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  06.03.2011      Anand Sharma                This is used to store error log from integration
 +=========================================================================================================================*/
 
global class PRM_DealReg_IntegrationErrorLog {    
    
    webservice static String createdErrorLog(String integrationName, String integrationID, String errorMessage)
    {       
        Integration_error_log__c objErrorLog = new Integration_error_log__c();
        String strSuccessDetails = 'SUCCESS';
        
    	objErrorLog.Integration_Name__c = integrationName;
    	objErrorLog.Integration_ID__c = integrationID;
    	objErrorLog.Error_Message__c = errorMessage;     	
    	try{
    		insert   objErrorLog;
    	}
    	catch(Exception Ex){
    		strSuccessDetails = 'FAIL';
    		
    	}           
        return strSuccessDetails;
    }
    
    /*@Method <This method is used to insert the record in Outbound Message Log Object on insertion of Error record.>
	@param <This method takes list<Integration_error_log__c> as a parameter.>
	@return <void> - <Not Returning anything>
	@throws exception - <No Exception>
	*/
    public void insertOutboundMessageLogRecord(List<Integration_error_log__c> lstIntegrationErrorRecord){
        List<Outbound_Message_Log__c> lstOutboundMessageLogRecord = new List<Outbound_Message_Log__c>();
        Outbound_Message_Log__c OutboundMessageLogRecord = new Outbound_Message_Log__c();
        if(lstIntegrationErrorRecord != null && lstIntegrationErrorRecord.size() >0){
            for(Integration_error_log__c errorRecord: lstIntegrationErrorRecord){
                OutboundMessageLogRecord.RecordId__c = errorRecord.Integration_ID__c;
                OutboundMessageLogRecord.Integration_Operation__c = 'Insert';
                lstOutboundMessageLogRecord.add(OutboundMessageLogRecord);
            }
            if(lstOutboundMessageLogRecord != null && lstOutboundMessageLogRecord.size() > 0){
                insert lstOutboundMessageLogRecord;
            }
        } 
    }
}