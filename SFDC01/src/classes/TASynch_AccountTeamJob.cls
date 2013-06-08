/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  21/01/2011    Anand Sharma                     To populate account team member and share record from staging object
 |  23/04/2012    Anand Sharma                     Update logic to populate count on TA Log Records
 |  26/06/2012    Anirudh Singh                    Updated finish() method to include scheduling of DeleteInactiveAccountTeamMember_Job
 |  17/07/2012    Anand Sharma                     Update logic to populate failed count on TA Log Records and Updated finish() method to include 
 													scheduling of Schedule_Delete_TA_SYNC_LOG job
 +======================================================================================================================================*/

global class TASynch_AccountTeamJob implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
  Map<String,CustomSettingDataValueMap__c> getTimeInterval = CustomSettingDataValueMap__c.getall();  
  global final String Query; 
  global Set<Id> userids  = new Set<Id>(); 
  global Map<Id, Integer> mapUseridCounts  = new Map<Id, Integer>();
  global Map<String, Integer> mapUseridCountsFails  = new Map<String, Integer>();
  
  /* constructor */
    global TASynch_AccountTeamJob(){ 
                             
        String accountShareQuery =  'Select Text5__c, Text4__c, Text3__c, Text2__c, Text1__c, Object_Name__c, Batch_Id__c From Staging_Data__c '
                                  + 'WHERE Object_Name__c = \'TASync\' order by Text1__c' ;
        
        
        System.Debug('TASynch_AccountShareJobQuery ###' + accountShareQuery ); 
        this.Query = accountShareQuery  ; 
        //userids = new Set<Id>();              
    }
    
    global TASynch_AccountTeamJob(String Query){                  
        System.Debug('TASynch_AccountShareJobQuery ###' + Query);  
        this.Query = Query ;
        //userids = new Set<Id>();
    }
    
    /*create batch of records which is passed to execute method for processing */
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    /* List of passed Educations scope. */
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        List<Staging_Data__c> DataStagingList =(Staging_Data__c[]) scope;  
        List<AccountTeamMember>  lstAccteamMem = new List<AccountTeamMember>();
        List<AccountShare>  lstAccShare = new List<AccountShare>();
        AccountTeamMember objATM= new AccountTeamMember();
        AccountShare objAS= new AccountShare();
        Map<Id, User> mapUserDetails = new Map<Id, User>();
        
        // Exception Handling.
        List <EMCException> errors = new List <EMCException>();
        
        Id AccountId;
        Id UserGroupId;
        Database.Saveresult[] resultTeamMember ;
        Database.Saveresult[] resultShare ;
        Integer intCount=0;
        for(Staging_Data__c objStaging : DataStagingList){
            try{
                UserGroupId = objStaging.Text3__c;
                userids.add(UserGroupId);
            }catch(Exception ex){
            
                errors.add(new EMCException(ex.getMessage(), 'ERROR_TASYNC_TEAMMEMBER_POPULATION', new String [] {objStaging.Id}));
            }
            
        }
        if(userids.size() > 0){
            mapUserDetails = new Map<Id, User>([Select Id,UserRole.Name, UserRoleId From User where id in:userids ]);
        }
        for(Staging_Data__c objStaging : DataStagingList){        
            try{
                AccountId = objStaging.Text1__c;
                UserGroupId = objStaging.Text3__c;
                objATM = new AccountTeamMember();
                objATM.AccountId = AccountId ;
                if(objStaging.Text2__c== null || objStaging.Text2__c ==''){
                    if(mapUserDetails.containsKey(objStaging.Text2__c)){
                        objATM.TeamMemberRole = mapUserDetails.get(objStaging.Text2__c).UserRole.Name;
                    }                    
                }else{
                    objATM.TeamMemberRole = objStaging.Text2__c;
                }
                
                objATM.UserId = UserGroupId ;            
                lstAccteamMem.add(objATM);
            
                objAS = new AccountShare();
                objAS.AccountId = AccountId ;
                objAS.UserOrGroupId = UserGroupId ;
                objAS.AccountAccessLevel = objStaging.Text4__c ;
                objAS.OpportunityAccessLevel = objStaging.Text5__c ;
                lstAccShare.add(objAS);
                
            }catch(Exception ex){
                errors.add(new EMCException(ex.getMessage(), 'ERROR_TASYNC_TEAMMEMBER_POPULATION', new String [] {objStaging.Id}));
                Integer userCount =0;
                if(mapUseridCountsFails.containsKey(objStaging.Text3__c)){
                    userCount = mapUseridCountsFails.get(objStaging.Text3__c) + 1; 
                    mapUseridCountsFails.put(objStaging.Text3__c, userCount);
                }else{
                    mapUseridCountsFails.put(objStaging.Text3__c, 0 );
                    userCount = mapUseridCountsFails.get(objStaging.Text3__c)+ 1; 
                    mapUseridCountsFails.put(objStaging.Text3__c, userCount);
                }
            }
        } 
        if(lstAccteamMem.size() >0){
            resultTeamMember= Database.insert(  lstAccteamMem, false);
        }
        if(lstAccShare.size() >0){
            resultShare = Database.insert(  lstAccShare, false);
        } 
        if(resultTeamMember != null && resultTeamMember.size() >0) {
			for (Database.Saveresult sr : resultTeamMember) {
				String dataErrs = '';
				Integer userCount =0;
				if (!sr.isSuccess()) {
					// if the particular record did not get updated, we log the data error 
					for (Database.Error err : sr.getErrors()) {
						dataErrs += err.getMessage();
					}
					System.debug('An exception occurred while attempting an update on ' + sr.getId());
					System.debug('ERROR: ' + dataErrs);
					errors.add(new EMCException(dataErrs, 'ERROR_TASYNC_TEAMMEMBER_POPULATION', new String [] {sr.getId()}));
					/**/
					if(mapUseridCountsFails.containsKey(lstAccteamMem.get(intCount).UserId)){
						userCount = mapUseridCountsFails.get(lstAccteamMem.get(intCount).UserId) + 1; 
						mapUseridCountsFails.put(lstAccteamMem.get(intCount).UserId, userCount);
					}else{
						mapUseridCountsFails.put(lstAccteamMem.get(intCount).UserId, 0 );
						userCount = mapUseridCountsFails.get(lstAccteamMem.get(intCount).UserId)+ 1; 
						mapUseridCountsFails.put(lstAccteamMem.get(intCount).UserId, userCount);
					}
				}else{
					if(mapUseridCounts.containsKey(lstAccteamMem.get(intCount).UserId)){
						userCount = mapUseridCounts.get(lstAccteamMem.get(intCount).UserId) + 1; 
						mapUseridCounts.put(lstAccteamMem.get(intCount).UserId, userCount);
					}else{
						mapUseridCounts.put(lstAccteamMem.get(intCount).UserId, 0 );
						userCount = mapUseridCounts.get(lstAccteamMem.get(intCount).UserId)+ 1; 
						mapUseridCounts.put(lstAccteamMem.get(intCount).UserId, userCount);
					}
				}
				intCount ++;
			}
		}
		if(resultShare != null && resultShare.size() >0) {
			for (Database.Saveresult sr : resultShare) {
				String dataErrs = '';
				if (!sr.isSuccess()) {
					// if the particular record did not get updated, we log the data error 
					for (Database.Error err : sr.getErrors()) {
						dataErrs += err.getMessage();
					}
					System.debug('An exception occurred while attempting an update on ' + sr.getId());
					System.debug('ERROR: ' + dataErrs);
					errors.add(new EMCException(dataErrs, 'ERROR_TASYNC_TEAMMEMBER_POPULATION', new String [] {sr.getId()}));
				}
			}
		}
        // log any errors that occurred
        if (errors.size() > 0) { 
            EMC_UTILITY.logErrors(errors);  
        }          
        System.debug('Now in finish userids Finish. ' + userids);  
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('Now in finish userids. ' + userids);
        List<TA_Sync_Log__c> lstTA_Sync_Log = [Select Id,  Status__c,Count__c, Sales_Resource__c from TA_Sync_Log__c where Status__c ='Open' and Sales_Resource__c in:userids];
        for(TA_Sync_Log__c objTA : lstTA_Sync_Log){
             objTA.Status__c ='In Process';
             if(mapUseridCounts.containsKey(objTA.Sales_Resource__c)){
                objTA.Count__c = mapUseridCounts.get(objTA.Sales_Resource__c);
             }
             if(mapUseridCountsFails.containsKey(objTA.Sales_Resource__c)){
                objTA.Fail_Counts__c = mapUseridCountsFails.get(objTA.Sales_Resource__c);
             }
        }
        System.debug('Now in finish . ' + lstTA_Sync_Log);
        Database.update (lstTA_Sync_Log, false);
        
       	Datetime dt = System.now(); 
       	Integer timeInMin = Integer.valueof(getTimeInterval.get('DeleteAccountTeamMemberTimeInterval').DataValue__c);      
       	dt = dt.addMinutes(timeInMin);
       	String scheduleString='0';//0 seconds
       	scheduleString+=' '+ dt.minute();
       	scheduleString+=' '+ dt.hour();
       	scheduleString+=' '+ dt.day();
       	scheduleString+=' '+ dt.month();
       	scheduleString+=' ?';
       	scheduleString+=' '+ dt.year();
       	String jobName = 'Delete Inactive Account Team Member - ' + dt.format('MM-dd-yyyy-hh:');
  
       	//Schedule_Delete_TA_SYNC_LOG nextBatchJob = new Schedule_Delete_TA_SYNC_LOG();
       //	System.schedule(jobName,scheduleString,nextBatchJob);
    }
    
     //Execute batch class with default constructor from schedular
    global void execute(SchedulableContext sc) {
        Integer batchSize = 200; // this will be overwritten in try block
        try {
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null) {
                System.abortJob(ct.Id);
            }
        } catch (Exception e) {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
        }     
        
        //Used to store the data mapping for the education master using the custom setting.
        
        List<CustomSettingDataValueMap__c> lstDataValueMap = new List<CustomSettingDataValueMap__c>();        
        CustomSettingDataValueMap__c   seqeunceDV = CustomSettingDataValueMap__c.getValues('TASync_Int_Control_Flag_Sequence');
        Integer sequenceId =  Integer.valueOf(seqeunceDV.DataValue__c);
                 
        //execute batch job 
        String accountTAQuery =  'Select Id, Text5__c, Text4__c, Text3__c, Text2__c, Text1__c, Object_Name__c, Batch_Id__c From Staging_Data__c '
                                  + 'WHERE Object_Name__c = \'TASync\' AND Batch_Id__c ='+ sequenceId + ' order by Text1__c ' ;
                               
        database.executeBatch(new TASynch_AccountTeamJob(accountTAQuery) , 200);
   }     
}