/*====================================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  14/03/2012    Anand Sharma                      Created job to pupulate Champions on profile accounts                           
 |  16/03/2012    Anand Sharma                      update to calculate only for active contact
 +==============================================================================================================================*/
global class PRM_CalculateChampionsBatch extends SequencialBatchJobScheduler{
  
  public string batchQuery = '';
  public PRM_CalculateChampionsBatch(){
      batchQuery = 'select Id,PROFILED_ACCOUNT_FLAG__c,Profiled_Account__c, '
      			   +' Advanced_Consolidate_Champion_Resources__c,Consolidate_Champion_Resources__c,'
                   +' Backup_Champion_Resources__c,Governance_Archive_Champion_Resources__c  '		
      			   +' FROM account where PROFILED_ACCOUNT_FLAG__c = true ' ; 
  }
  
/*@Method <This method gets executed acutomatically when the batch job is started.>
    @param <Database.BatchableContext BC - Batchable context>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
*/
    global override Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(batchQuery);
    }
     
/*@Method <This method gets executed acutomatically when the batch job is execution mode.>
    @param <Database.BatchableContext BC - Batchable context>
    @param <List<Sobject> scope - scope>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
*/
	global override void execute(Database.BatchableContext BC, list<SObject> scope){
      	list<account> lstAccount = (list<account>)scope;
      	//Set<Id> setAccountIds = new Set<Id>();
      	calculateChampions(lstAccount);
    } 
    
    public void calculateChampions(list<Account> listProfiledAccount){
    	List<Account> accountList;
  		Map<Id,Account> mapIdAccounts = new Map<Id,Account>() ;

    	if(listProfiledAccount != Null && listProfiledAccount.size() >0){
	  		for(Account objAccount : listProfiledAccount){
	  			objAccount.Advanced_Consolidate_Champion_Resources__c = 0;
	  			objAccount.Consolidate_Champion_Resources__c = 0;
	  			objAccount.Backup_Champion_Resources__c = 0;
				objAccount.Governance_Archive_Champion_Resources__c = 0;
      			mapIdAccounts.put(objAccount.Id,objAccount);
   	  		}
         	accountList = [SELECT id,name,Profiled_Account__c, Grouping__c,
                               Advanced_Consolidate_Champion_Resources__c,Consolidate_Champion_Resources__c,Backup_Champion_Resources__c,
                               Governance_Archive_Champion_Resources__c,
                               (SELECT Id,Advanced_Consolidate_Champion__c,Consolidate_Champion__c,Backup_Champion__c,
                                       Governance_Archive_Champion__c FROM Contacts where Active__c = true)       
                             FROM Account WHERE  Profiled_Account__c= : mapIdAccounts.keyset()  
                             	          OR Id in: mapIdAccounts.keyset() order by Profiled_Account__c ASC ];                  

     	if(accountList.size()>0){
     		system.debug('ACCOUNT LIST ##### ' +accountList.SIZE());    		
      		for(Account acc : accountList){
      			Integer AdvancedConsolidateCount = 0;
  				Integer ConsolidateCount = 0; 
  				Integer BackupCount = 0;
  				Integer GovernanceArchiveCount = 0;
  				
          		if(acc.contacts != null && acc.contacts.size()>0 ){
          			Account profiledAccount ;
             		for(Contact con : acc.contacts){
		                if(con.Advanced_Consolidate_Champion__c){
		                    AdvancedConsolidateCount  = AdvancedConsolidateCount +1 ;   
		                }
		                if(con.Consolidate_Champion__c){
		                    ConsolidateCount  = ConsolidateCount +1 ;
		                }
		                if(con.Backup_Champion__c){
		                    BackupCount  = BackupCount +1 ;
		                }
		                if(con.Governance_Archive_Champion__c){
		                    GovernanceArchiveCount  = GovernanceArchiveCount +1 ;
		                }
             		} //End of Contact for loop.

		            if(mapIdAccounts.containskey(acc.Profiled_Account__c)){
		                profiledAccount = mapIdAccounts.get(acc.Profiled_Account__c);
		            }
		            else{
		                profiledAccount = mapIdAccounts.get(acc.id);
		            }
		            if(profiledAccount != Null){
     					  system.debug('SETTING VALUES FOR PROFILED ACCOUNT ##### ' +accountList.SIZE());		            	
					      profiledAccount.Advanced_Consolidate_Champion_Resources__c = profiledAccount.Advanced_Consolidate_Champion_Resources__c +AdvancedConsolidateCount;
					      profiledAccount.Consolidate_Champion_Resources__c = profiledAccount.Consolidate_Champion_Resources__c + ConsolidateCount;
					      profiledAccount.Backup_Champion_Resources__c = profiledAccount.Backup_Champion_Resources__c+ BackupCount;
					      profiledAccount.Governance_Archive_Champion_Resources__c = profiledAccount.Governance_Archive_Champion_Resources__c +GovernanceArchiveCount;
		            	  mapIdAccounts.put(profiledAccount.id ,profiledAccount);
		            }
      		  } // End of contact size -if condition. 
      		} // End of Account for loop.
     	 }	//End of Account size -if condition.

  			update mapIdAccounts.values() ;
      }
    } // End of method- calculateChampions().
     
}