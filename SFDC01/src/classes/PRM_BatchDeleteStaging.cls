/*===========================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  03/01/2011    Anand Sharma                      Delete staging data record 
 +===========================================================================*/
global class PRM_BatchDeleteStaging implements Database.Batchable<sObject>, Schedulable{

    //holds query string 
    global final String Query;
    
    //default constructor
    
    global PRM_BatchDeleteStaging (){
        this.Query = 'Select id from Staging_data__c' ;
    }
    
    global PRM_BatchDeleteStaging (String stagingQuery){
        this.Query = stagingQuery ;
    }
    
    //create batch of records which is passed to execute method for processing
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    //Update the list of passed account scope and break the context to handle governer limit
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        List<Staging_Data__c> lstEducation = (List<Staging_Data__c>) scope;
        
        // call static method "deleteFailBatch" of "PRM_ESBIIntegrationOperation" class      
        PRM_ESBIIntegrationOperation.deleteStagingData(lstEducation);   
    }
    // no need to do any operation in this method as per current business logic.
    global void finish(Database.BatchableContext BC){
        CustomSettingDataValueMap__c   controlFlag = CustomSettingDataValueMap__c.getValues ('ESBI_Int_Control_Flag');
        controlFlag.DataValue__c = 'START';
        update controlFlag;
    }
    
    //Execute batch class with default constructor from schedular
    global void execute(SchedulableContext sc) {
        //abort already schedule job
        PRM_ESBIIntegrationOperation.abortScheduleJob(sc.getTriggerId());
        
        //execute batch job 
        database.executebatch(new PRM_BatchDeleteStaging(Query));
   } 
}