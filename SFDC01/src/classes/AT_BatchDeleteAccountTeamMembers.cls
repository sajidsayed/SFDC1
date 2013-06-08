/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER       WR       DESCRIPTION                               
 |  ====       =========       ==       =========== 
 |             N Padmanabhan            Initial Creation.               
 |  16-JUN-09  S Douglas                Updated to add error handling, commenting, etc.
 |  06-OCT-09  Anand Narasimha          Updated to conform to the new interface 
 |  10-Mar-10  Shipra Misra             Updated Batch to handle 15 digit SFDC ID(UserId__C). 
 |  28-May-12  Anand Sharma				Update code to reduce extra code  
 |  19 Oct 2012 Vivek         204934    SFA - Bug Fix for Batch Job that Removes Inactive Account Team Members.             
 +===========================================================================*/
global class AT_BatchDeleteAccountTeamMembers implements Database.Batchable<SObject> {
    private final static String EXC_PROCID = 'AT_BatchDeleteAccountTeamMembers';
    final static String DEFAULT_QUERY = 'Select Id, AccountId__c, UserId__c, LastModifiedDate From AccountTeamDelete__c Where ProcessedFlag__c = false order by AccountId__c';
    public String query;
    final static String TestClass_Query='Select Id, AccountId__c, UserId__c, LastModifiedDate From AccountTeamDelete__c Where ProcessedFlag__c = false order by AccountId__c limit 5';

    public List<String> unitTestAccounts;

    global database.querylocator start(Database.BatchableContext BC) 
    {
        //If the caller has not set the value of query, use the default query
        if (query == null || query.length() == 0)
            {
            if(Util.isTestCoverage){
                query= TestClass_Query;
            }
            else{
                query = DEFAULT_QUERY;
            }
        }
        return Database.getQueryLocator(query);
    }
  
    global void execute(Database.BatchableContext BC,Sobject[] scope)
    {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        List<AccountTeamMember> resourcesToBeDeleted = new List<AccountTeamMember>();
        AccountTeamDelete__c[] deleteInstances = (AccountTeamDelete__c[])scope;
        Map<String, Integer> concatenatedDeletes = new Map<String, Integer>();
        Set<String> concatenatedDelete = new Set<String>();
        Id AccountId ;
        Id UserId;
        //Populate the (distinct) set of all accountIDs and the (distinct) set of all userIDs  
        for(integer i = 0; i < deleteInstances.size(); i++)
        {
        	try{	        	
        		AccountId =deleteInstances[i].AccountId__c;
        		accountIds.add(AccountId);
        	
            	UserId = deleteInstances[i].UserId__c; 
            	userIds.add(UserId);
	            
	            concatenatedDeletes.put(AccountId + ':' + UserId, i);
	           	
        	}catch(Exception ex){
        		errors.add(new EMCException(ex.getMessage(), EXC_PROCID + ':Invalid Account or User Ids', new String [] {deleteInstances[i].Id}));
        	}
        	
        	deleteInstances[i].ProcessedFlag__c = true;
        }
        
        //First get the superset of records we want to delete
        //These are the records that have both AccountID and UserID in our list of distinct IDs
        //Iterate through the records in the superset
        //If we find the record in the list of records for the batch, add it to the list of resources to be deleted
        //System.debug('ID | AccountId | UserId');
        
       	for(AccountTeamMember mem: [Select Id, AccountId, UserId , LastModifiedDate
                                                From   AccountTeamMember 
                                                Where  AccountId In :accountIds
                                                AND    UserId    In :userIds])
    	{                
            if(concatenatedDeletes.containsKey(mem.AccountId + ':' + mem.UserId) && 
            	(deleteInstances[concatenatedDeletes.get(mem.AccountId + ':' + mem.UserId)].LastModifiedDate > mem.LastModifiedDate))
        	{
                resourcesToBeDeleted.add(mem);
                //deleteInstances[concatenatedDeletes.get(mem.AccountId +':'+ mem.UserId)].ProcessedFlag__c = true;
            }               
        } 
            
     	// for (iterating through superset)        
        //NOTE:  If there are any failures when deleting, we do not want the whole batch to fail
        //       We will log the IDs of the failed deletes
        //       We should mark the failures as processed in the AccountTeamDelete__c table so that
        //       they are not re-tried with each batch  
    
        List <EMCException> errors = new List <EMCException>();
        Database.DeleteResult[] delResults = null;
        Database.SaveResult[] saveResults = null;
    
        // now we delete the list of resources
        System.debug('resourcesToBeDeleted 2'+resourcesToBeDeleted);
        
        delResults = database.delete(resourcesToBeDeleted, false);
        System.debug('resourcesToBeDeleted 2'+resourcesToBeDeleted);
        // look for any errors
        //Note that DeleteResult.getId() will only return a value if the delete was successful
        //So we have to use an index to iterate through the results in order to get the ID from the
        //resourcesToBeDeleted list
        for (integer i = 0; i < delResults.size(); i++) {
            Database.DeleteResult dr = delResults[i];
            if (!dr.isSuccess()) {
                // if the particular record did not get deleted, we log the data error 
                String dataErrs = '';
                for (Database.Error err : dr.getErrors()) {
                    dataErrs += err.getMessage();
                }
                errors.add(new EMCException(dataErrs, EXC_PROCID + ':DeleteAccountTeamMember', new String [] {resourcesToBeDeleted[i].Id}));
            }
        }
        
        // now we update the accounts with the new values
        saveResults = database.update(deleteInstances, false);  //Updates the AccountTeamDelete processed flag
        // look for any errors
        //Note that SaveResult.getId() will only return a value if the update was successful
        //So we have to use an index to iterate through the results in order to get the ID from the
        //deleteInstances list
        for (integer i = 0; i < saveResults.size(); i++) {
            Database.SaveResult sr = saveResults[i];
            if (!sr.isSuccess()) {
                // if the particular record did not get deleted, we log the data error 
                String dataErrs = '';
                for (Database.Error err : sr.getErrors()) {
                    dataErrs += err.getMessage();
                }
                errors.add(new EMCException(dataErrs, EXC_PROCID + ':UpdateProcessedFlag', new String [] {deleteInstances[i].Id}));
            }
        }
    
        // log any errors that occurred
        if (errors.size() > 0) { 
            EMC_UTILITY.logErrors(errors);  
        }

    }  //executeBatch
  
    global void finish(Database.BatchableContext BC)
    {
        // After complete the job StatusFlag set to true for WR:204934   
           RunInactiveATbatch__c RIA = RunInactiveATbatch__c.getValues('FlagStatus');
           RIA.StatusFlag__c = true;
           update RIA;
    }
}