global class AP_CQRcount implements Database.Batchable<sObject>, Database.Stateful {
    
    global Integer CQRcount = 0;    
    global String Query;

    
    global AP_CQRcount(){
        this.Query = 'select id from core_quota_rep__c' ;
        system.debug('QUERY ### :' + query );
    }
        
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        for(SObject sobj : scope)
        {
            CQRcount++ ;
        }                           
    }
    
    global void finish(Database.BatchableContext BC){
         system.debug('**** CQR Count = ' + cqrCount);

    }

}