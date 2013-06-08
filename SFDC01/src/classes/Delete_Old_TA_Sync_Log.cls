/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
|  21/01/2013       Shipra Misra            223457             Logic to delete record.
==============================================================================*/
global class Delete_Old_TA_Sync_Log implements database.Batchable<Sobject> { 

    public String Query;
    global Delete_Old_TA_Sync_Log(String query){
       this.Query = query;
       System.debug('Query is---->'+query);
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        if(Util.isTestCoverage){
            return Database.getQueryLocator([Select Sales_Resource__c, Status__c, LastModifiedDate, OwnerId, Name, Id, Error__c, Count__c From TA_Sync_Log__c where Status__c=:'Sync Complete' or Status__c=:'Error'  limit 2]);
        }
        else{
           return Database.getQueryLocator([Select Sales_Resource__c, Status__c, LastModifiedDate, OwnerId, Name, Id, Error__c, Count__c From TA_Sync_Log__c where Status__c= : 'Sync Complete' or Status__c= :'Error' ]);
        }
    }
    
    global void execute(Database.BatchableContext BC, SObject[] scope)
    {    
        integer day = datetime.now().dateGMT().day();
		integer month = datetime.now().dateGMT().month();
		integer year = datetime.now().dateGMT().year();
		System.debug('***scope***'+scope);
		List<TA_Sync_Log__c> completed_SyncLogsList = new List<TA_Sync_Log__c>();
        Map<String,CustomSettingDataValueMap__c> mapDataValueMap = CustomSettingDataValueMap__c.getAll();
		if(mapDataValueMap!= null &&
                    mapDataValueMap.get('TA_Sync_Log_Day_Limit') != null &&
                    mapDataValueMap.get('TA_Sync_Log_Day_Limit').DataValue__c != null &&
                    Integer.valueOf(mapDataValueMap.get('TA_Sync_Log_Day_Limit').DataValue__c) != null )
		{
			for(SObject sobjects:scope)
	        {
	            TA_Sync_Log__c syncLog = (TA_Sync_Log__c)sobjects;
				if(syncLog.LastModifiedDate< Datetime.newInstanceGmt(year,month,day).addDays(-(Integer.valueOf(mapDataValueMap.get('TA_Sync_Log_Day_Limit').DataValue__c))))
	            {
	                completed_SyncLogsList.add(syncLog);
	            }
	        }
		}
		if(completed_SyncLogsList.size()>0)
        {
            delete completed_SyncLogsList;
        }        
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        System.debug('Entered Finish');
    }
}