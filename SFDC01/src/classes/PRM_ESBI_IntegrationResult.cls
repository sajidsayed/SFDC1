/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  25.02.2011      Anand Sharma                This is used to store result for EBSI Integration Process
 +=========================================================================================================================*/
global class PRM_ESBI_IntegrationResult {
    
    // hold current status of Operation
    webservice String statusMessage;
    
    // hold current batch id number 
    webservice Integer batchId;
    
    //default constructor
    public PRM_ESBI_IntegrationResult(String statusMessage,Integer BatchId ){
        this.statusMessage = statusMessage;     
        this.BatchId = BatchId;
    }
    
    
    global String getStatusMessage(){
        return this.statusMessage;
    }

    global Integer getBatchId(){
        return this.batchId;
    }
    
    global void setErrorMessage(String strStatus){
        this.statusMessage = strStatus;
    }

    global void setBatchId(Integer strBatchId){
        this.batchId = strBatchId;
    }
}