/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
|   06/12/2012      Shipra Misra                            Logic to delete ATM/ASO record.
==============================================================================*/
global class Update_TA_Sync_Records_SFDC_Count implements database.Batchable<Sobject> , Database.Stateful 
{
    private final static String EXC_PROCID = 'BatchUpdateTASyncRecords';
    final static String DEFAULT_QUERY = 'Select Sales_Resource__c, Status__c,Count__c,Row_Count__c, LastModifiedDate,CreatedDate, OwnerId, Name, Id, Error__c from TA_Sync_Log__c where Status__c =\'EIS Insertions Complete\'  order by LastModifiedDate asc';
    final static String TestClass_Query='Select Sales_Resource__c, Row_Count__c,Count__c,Status__c, LastModifiedDate,CreatedDate, OwnerId, Name, Id, Error__c from TA_Sync_Log__c where Status__c = :System.label.TA_Sync_EIS_Insertion_complete  order by LastModifiedDate limit 50';
    public String query;
    public Job_Scheduler__c js;

    global List<TA_Sync_Log__c> eisInsList = new List<TA_Sync_Log__c>();
    global Map<ID, TA_Sync_Log__c> mapUseridSyncLog  = new Map<ID, TA_Sync_Log__c>();
    global Map<Id, Integer> mapUseridCounts  = new Map<Id, Integer>();
    global Map<Id, Integer> mapUseridNetNew  = new Map<Id, Integer>();

    global Update_TA_Sync_Records_SFDC_Count(Job_Scheduler__c js,String query){
       this.js = js;
       if(Util.isTestCoverage){
        	this.query=TestClass_Query;
        }
        else
       	 {
       this.query=query;
        }
       System.debug('query is ===>'+query);
       System.debug('js is---->'+js);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        Profiles__c profile = Profiles__c.getOrgDefaults();
        Id apiOnlyProfileId = profile.System_Admin_API_Only__c;
        Set<ID> userIds = new Set<ID>();
        eisInsList = [Select Sales_Resource__c, Status__c,Count__c,Row_Count__c, LastModifiedDate,
                         CreatedDate, OwnerId, Name, Id, Error__c from TA_Sync_Log__c
                         where Status__c = 'EIS Insertions Complete'  order by LastModifiedDate asc];

        for (TA_Sync_Log__c eisInsRec : eisInsList) {
             // create a set to use in query locator and global Map to reference from execute 
             userIds.add(eisInsRec.Sales_Resource__c);
             mapUseridSyncLog.put(eisInsRec.Sales_Resource__c, eisInsRec);
        }

        
        query = 'select ID, UserID, createdDate, lastModifiedDate '
                           + 'from AccountTeamMember '
                           + 'where UserId in :userIds '
                           + 'and LastModifiedBy.profileId = :apiOnlyProfileId ';

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, SObject[] scope)
    {   
        List<AccountTeamMember> ATMList =(AccountTeamMember[]) scope;        
        List<Staging_Data__c> del_stage = new List<Staging_Data__c>();
        Integer userCount =0;

        for(AccountTeamMember ATMrec : ATMList) {   

            if (ATMrec.lastmodifieddate < mapUseridSyncLog.get(ATMrec.userID).createddate) {
                  /* ATM record has not been updated so we save the TA_Sync_log ID and the ATM ID to staging table
                     so we can later delete the ATM records for TA_Sync_logs that pass the count validation */
                  Staging_Data__c delStgRec = new Staging_Data__c();
                      delStgRec.Object_Name__c = 'TASyncDelete';
                      delStgRec.Text1__c = mapUseridSyncLog.get(ATMrec.userID).ID;
                      delStgRec.Text2__c = ATMrec.ID;
                  del_stage.add(delStgRec);
            } else {
                  // ATM record has been updated so we keep track of the total counts for validation
                if(mapUseridCounts.containsKey(ATMrec.UserId)){
                    userCount = mapUseridCounts.get(ATMrec.UserId) + 1; 
                    mapUseridCounts.put(ATMrec.UserId, userCount);
                }else{
                    userCount = 1; 
                        mapUseridCounts.put(ATMrec.UserId, userCount );
                }
                // Also keep track of the net new adds for troubleshooting
                if (ATMrec.lastModifiedDate == ATMrec.createdDate) {
                    if(mapUseridNetNew.containsKey(ATMrec.UserId)){
                        userCount = mapUseridNetNew.get(ATMrec.UserId) + 1; 
                        mapUseridNetNew.put(ATMrec.UserId, userCount);
                    }else{
                        userCount = 1; 
                            mapUseridNetNew.put(ATMrec.UserId, userCount );
                    }
                }
            }
        }
        insert del_stage; 
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
        for ( TA_Sync_Log__c eisInsRec : eisInsList ) {
            // get the counts that were tracked in execute method
            Integer ATMcount = 0;
            Integer ATMnetnew = 0;
            if ( mapUseridCounts.containsKey(eisInsRec.Sales_Resource__c) ) {
                ATMcount = mapUseridCounts.get(eisInsRec.Sales_Resource__c);
            }
            if ( mapUseridNetNew.containsKey(eisInsRec.Sales_Resource__c) ) {
                ATMnetnew = mapUseridNetNew.get(eisInsRec.Sales_Resource__c);
            }
            // perform Oracle rowcount validation
            if (eisInsRec.Row_Count__c == null) {
                eisInsRec.status__c = 'Error';
               // eisInsRec.Resource_Id__c=eisInsRec.Sales_Resource__c+eisInsRec.status__c;
                eisInsRec.Error__c = 'Oracle Rowcount not found';
                eisInsRec.Count__c = ATMcount ;
            } else if ( ATMcount < eisInsRec.Row_Count__c ) {
                eisInsRec.status__c = 'Error';
                eisInsRec.Error__c = 'Rowcount Validation failed';
               // eisInsRec.Resource_Id__c=eisInsRec.Sales_Resource__c+eisInsRec.status__c;
                eisInsRec.Count__c = ATMcount;
            } else if ( ATMcount >= eisInsRec.Row_Count__c ) {
                eisInsRec.status__c = 'Rowcount Validated';
              //  eisInsRec.Resource_Id__c=eisInsRec.Sales_Resource__c+eisInsRec.status__c;
                eisInsRec.Count__c = ATMcount;
                eisInsRec.Net_New_Adds__c = ATMnetnew;
            }
        }
        update eisInsList ;

        System.debug(LoggingLevel.WARN,'Batch Process 1 Finished');
        //Build the system time of now + 20 seconds to schedule the batch apex.
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(20);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        system.debug(chron_exp);
        //updated by shipra..
        Schedule_Delete_TA_SYNC_LOG atmDeleteBatch2Sched = new Schedule_Delete_TA_SYNC_LOG(js,'');
        //Schedule the next job, and give it the system time so name is unique
        System.schedule('atmDeleteBatch2Sched' + sysTime.getTime(),chron_exp,atmDeleteBatch2Sched);
        //js.Status__c='Complete';
        
    }
}