/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    15-Feb-2011     Srinivas Nallapati      139074          Batch class to delete out of sync 
                                                            AccountTeams and obsolete TA Sync Log records.Modified to update the records with Sync Complete status
                                                            
    25-Jun-2011     Srinivas Nallapati      170056          Added   'TASyncLogCreateController.SendTASyncLimitNotification();'    
    
    23 Dec 2011     Arif                    Issue           Changed the logic and hence query to run the deletion job based on 'TA_Synch_Admin__c' and not on Profile   
                                                            Removed Hard Coding   
 |  21/06/2012      Anand Sharma                            Update logic to delete record  
 |  17/07/2012      Anand Sharma                            Update logic to delete record, changed mapUserTAsync.get(syncLog.UserId).CreatedDate > syncLog.LastModifiedDate                                                                                                                                                                
 |  06/12/2012      Shipra Misra                            Update logic to delete record.
==============================================================================*/
global class Delete_TA_Sync_Log_Batch implements database.Batchable<Sobject> , Database.Stateful { 

    public String Query;
    global Map<Id,Integer> mapNetDeletions = new Map<Id,Integer>();
    global List<TA_Sync_Log__c> lstTASync = new List<TA_Sync_Log__c>();
    public Job_Scheduler__c js;
    global Delete_TA_Sync_Log_Batch(String query,Job_Scheduler__c js){
       this.Query = query;
       this.js = js;
       System.debug('Query is---->'+query);
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        List<ID> taSyncIDs = new List<Id>();
        TASyncLogCreateController.SendTASyncLimitNotification();
        
        Profiles__c profile = Profiles__c.getOrgDefaults();
        Id apiOnlyProfileId = profile.System_Admin_API_Only__c;
        
        lstTASync = [Select Id, Account_Team_Deletes__c,Sales_Resource__c from TA_Sync_Log__c
                            where Status__c =: 'Rowcount Validated' order by LastModifiedDate ];
        for(TA_Sync_Log__c objTASync :lstTASync){
            taSyncIDs.add(objTASync.Id);
        }
        
        return Database.getQueryLocator([Select Id , Text1__c , Text2__c 
                                        from Staging_Data__c 
                                        where Object_Name__c = 'TASyncDelete'
                                        and Text1__c in :taSyncIDs ]);
    }
    
    global void execute(Database.BatchableContext BC, SObject[] scope)
    {    
        List<Staging_Data__c> stageList = (Staging_Data__c[]) scope;  
        List<AccountTeamMember> todelete = new List<AccountTeamMember>();
        
        for(Staging_Data__c stageRec : stageList){
            ID delID = stageRec.Text2__c;
            set<ID> IdAtm= new Set<Id>();
            AccountTeamMember delRec = new AccountTeamMember(ID = delID);
            if(!IdAtm.contains(delRec.id))
            {
            	todelete.add(delRec);
            	IdAtm.add(delRec.id);
            }
            // Track count of deletion records by ta_sync_log__c.id
            if( mapNetDeletions.containsKey(stageRec.Text1__c) ) {
                mapNetDeletions.put(stageRec.Text1__c, mapNetDeletions.get(stageRec.Text1__c) + 1); 
              } else {
                mapNetDeletions.put(stageRec.Text1__c, 1);
            }
        }

        delete todelete;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        System.debug('Entered Finish');
        for(TA_Sync_Log__c taSyncRec : lstTASync) {
            taSyncRec.Status__c = 'Sync Complete';
            //taSyncRec.Resource_Id__c=taSyncRec.Sales_Resource__c+taSyncRec.status__c;
            System.debug('mapNetDeletions Value===>***'+mapNetDeletions);
            if ( mapNetDeletions.containsKey(taSyncRec.id) ) {
                taSyncRec.Account_Team_Deletes__c = mapNetDeletions.get(taSyncRec.id);
            } else {
                taSyncRec.Account_Team_Deletes__c = 0;
            }
            system.debug('taSyncRec===>'+taSyncRec);
           // if(taSyncRec.Sales_Resource__c!=null)taSyncRec.Resource_Id__c=taSyncRec.Sales_Resource__c+taSyncRec.status__c;
        }
        Util.TA_Sync_Job_Scheduler_Inserted=true;
        update lstTASync;
        mapNetDeletions.clear();
        System.debug('***js'+js);
        if(js!=null)
        {
        js.Status__c='Complete';
        //js.Update_Me__c='1';
        system.debug('js===>'+js);
     	update js;
        }
        
    }
}