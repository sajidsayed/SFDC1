/*================================================================================================================================================+
 |  HISTORY  |
 |  DATE          DEVELOPER               WR                        DESCRIPTION 
 |  ====          =========               ==                        =========== 
 |  01 Dec 2012   Hemavathi N M         Account Presentation         This will used for running batch job on customer profiled account     
 +===========================================================================================================================================================*/
 
global class AP_Customer_Profile_Auditing implements Database.Batchable<sObject>,Schedulable  {

  public String Query;
  //Holds todays date.
  global Datetime currentDate=datetime.Now();
  public Boolean isRunTest=false;
    /* constructor */
    global AP_Customer_Profile_Auditing(){       
    /*    String accountQuery =  'Select ID, Name, Account_District__c, Customer_Profiled_Account__c, District_Lookup__c, '
                                  + 'Account_Profiling_Warning_Counts__c From Account '
                                  + 'WHERE type != \'Partner\' and isPartner = false '
                                  + 'and Account_District__c != null ';
        
        
        System.Debug('TASynch_AccountShareJobQuery ###' + accountQuery ); 
        this.Query = accountQuery  ;   */
        System.debug('Inside Constructor');      
    }
     global AP_Customer_Profile_Auditing(String query){    
     this.Query = query;
     }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope)
    {
        
        List<Account> AccountList =(Account[]) scope;
        system.debug('AccountList--->'+AccountList );
        // Exception Handling.
        List <EMCException> errors = new List <EMCException>();

        Set<String> masterListTracker = new Set<String>();
        List<Customer_Profile_Audit_Master__c> masterList = new List<Customer_Profile_Audit_Master__c>();
        List<Customer_Profile_Audit_Detail__c> detailList = new List<Customer_Profile_Audit_Detail__c>();
   try{
        for(Account acct : AccountList){
           // create Master Rec for use as Detail Rec parent reference
           Customer_Profile_Audit_Master__c masterRec = new Customer_Profile_Audit_Master__c();
              masterRec.Account_District__c = acct.Account_District__c;

           if (masterListTracker.isEmpty() || !masterListTracker.contains(acct.Account_District__c)) {
              // create additional Master rec for Upsert if we have not created one already
              Customer_Profile_Audit_Master__c masterUpsertRec = new Customer_Profile_Audit_Master__c();
              masterUpsertRec.Account_District__c = acct.Account_District__c;
              masterUpsertRec.District_Lookup__c = acct.District_Lookup__c;
              masterUpsertRec.name = acct.Account_District__c.abbreviate(80);
              masterList.add(masterUpsertRec);
              masterListTracker.add(acct.Account_District__c);
           }              
 
           Customer_Profile_Audit_Detail__c detailRec = new Customer_Profile_Audit_Detail__c();
              detailRec.Customer_Profile_Audit_Master__r = masterRec;
              detailRec.name               = acct.name.abbreviate(80);
              detailRec.Account_ID__c      = acct.id;
              detailRec.Account_Lookup__c  = acct.id;
              detailRec.Refresh_Date__c=currentDate;
              detailRec.Warning_Count__c   = acct.Account_Profiling_Warning_Counts__c;
              if (acct.Customer_Profiled_Account__c == true ) {
                  detailRec.Profile_Value__c = 1;
              } else {
                  detailRec.Profile_Value__c = 0;
              }
           detailList.add(detailRec);

        }
        
     
        if (masterList != null && masterList.size() > 0) {
            List<Database.upsertResult> masterResults = Database.upsert(masterList, Customer_Profile_Audit_Master__c.Account_District__c, false);
        }
        // if (detailList != null && detailList.size() > 0) {    
            List<Database.upsertResult> detailResults = Database.upsert(detailList, Customer_Profile_Audit_Detail__c.Account_ID__c, false);
        // }
        
        
        

        for (Database.Upsertresult sr : detailResults) {
            String dataErrs = '';
            if (!sr.isSuccess()) {
                // if the particular record did not get updated, we log the data error 
                for (Database.Error err : sr.getErrors()) {
                    dataErrs += err.getMessage();
                }
                errors.add(new EMCException(dataErrs, 'ACCOUNT AUDIT', new String [] {sr.getId()}));
            }
        }
        // log any errors that occurred
        if (errors.size() > 0) { 
            EMC_UTILITY.logErrors(errors);  
        }
        }
        Catch(Exception e){
         System.debug('Exception--->'+e.getMessage());
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
    	List<Customer_Profile_Audit_Detail__c> lstDeleteAuditDetail = new List<Customer_Profile_Audit_Detail__c>([Select Id, Refresh_Date__c, LastModifiedDate from Customer_Profile_Audit_Detail__c where LastModifiedDate<: currentDate limit 50000]);
    	if(lstDeleteAuditDetail.size()>0)
    	{
    		delete(lstDeleteAuditDetail);
    	}
        
    }
    
    global void execute(SchedulableContext sc) 
    {
       Map<String,CustomSettingDataValueMap__c> mapDataValueMap = CustomSettingDataValueMap__c.getAll();
 	   set<string> setHouseAccountExcluded= new set<String>();
 	   if(mapDataValueMap!= null &&
            mapDataValueMap.get('House Account For AP Exclusion') != null &&
            mapDataValueMap.get('House Account For AP Exclusion').DataValue__c != null)
	   {
	        system.debug('#### Entered batch calling area');
	        String strHouseAccuontsExcluded = mapDataValueMap.get('House Account For AP Exclusion').DataValue__c;
	        for(string s:strHouseAccuontsExcluded.split(','))
	        {
	        	setHouseAccountExcluded.add(s);
	        }
	   }  
       try {
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null)
                System.abortJob(ct.Id);
            } catch (Exception e) {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
       }     
       try {
       String accountQuery ;
       accountQuery ='Select ID, Name, Account_District__c,Account_District__r.name,District_Lookup__c, Customer_Profiled_Account__c, Account_Profiling_Warning_Counts__c From Account WHERE type != \'Partner\' and Customer_Profiled_Account__c = true and isPartner = false and Account_District__c != null and (Not Account_District__r.name  in:'+setHouseAccountExcluded+')';
       if(isRunTest){
       accountQuery ='Select ID, Name, Account_District__c,District_Lookup__c, Customer_Profiled_Account__c, Account_Profiling_Warning_Counts__c From Account WHERE type != \'Partner\' and Customer_Profiled_Account__c = true and isPartner = false and Account_District__c != null and (NOT Account_District__r.name  in:'+setHouseAccountExcluded+' ) limit 50';
       }
       system.debug('accountQuery===> '+accountQuery);
       database.executeBatch(new AP_Customer_Profile_Auditing(accountQuery));
       //database.executeBatch(new AP_Customer_Profile_Auditing());

        }
        catch (Exception e) {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
        } 
   } 
  
}