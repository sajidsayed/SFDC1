/*======================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 10/01/2011    Suman B                           This is used to create Velocity Rule Result by fetching
 |                                                  the Profiled Account and Partner Grouping details based on the Velocity Rules.
 | 06/03/2012    Suman B                            Added logic for Velocity Servicecard in createVelocityRuleResults() and 
                                                     query in getVelocityRules(List<Account> listAccounts)  . 
   29 March 2012  Prasad                           bypassed VSI evaluation if tier is not populated on account 
   19 July 2012   Arif                             Changes to include 'Cloud Builder' part on Velocity Specility Table     
   25 July 2012   Arif                             Added a check to resolve creation of dublicate VRR for cloud builder    
   15/11/2012    vivek kodi              197607    To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.                                         
 +=====================================================================================================*/

Public with sharing Class PRM_VPP_VelocityRuleResults {

   List<Velocity_Rules__c> listVelocityRules = new List<Velocity_Rules__c> ();
   set<String> setClusters = new set<String>();
   set<String> setSpecialtyRuleTypes = new set<String>();
   List<Account> listGrouping = new List<Account>();
   List<Velocity_Rule_Results__c> listVelocityRuleResults = new List<Velocity_Rule_Results__c>();
   String velocityRuleQuery;
   List<String> Recordtypes = new String[]{'Specialty_Rule','Tier_Rule','Field_Based_Rule_Type'} ;
   List<String> NonPanRecordtypes = new String[]{ 'Services_Rule' };
   Integer rowLimit = Limits.getLimitQueryRows();

/* @Constructor <PRM_VPP_VelocityRuleResults(): This constructor would be used for 
                                                fetching all the VelocityRules and 
                                                ProfiledAccounts.>
       @param - <void>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
*/
 Public PRM_VPP_VelocityRuleResults(){
   rowLimit = Limits.getLimitQueryRows();
   velocityRuleQuery = 'SELECT id, name,Required__c,Specialty_Rule_Type__c,Cluster__c,' 
                        +' RecordType.DeveloperName,RecordTypeId FROM Velocity_Rules__c WHERE' 
                        +' RecordType.DeveloperName IN :Recordtypes AND (Evaluation_At__c=\'Country Grouping Level\'  )'
                        +' LIMIT :rowLimit';
   
   listVelocityRules = Database.query(velocityRuleQuery);
   system.debug('1--->');
   getProfiledAccounts(listVelocityRules);
   system.debug('1--->');
 }
 
/* @Constructor <PRM_VPP_VelocityRuleResults(): This constructor would be used for fetching  
                                                ProfiledAccounts based on the VelocityRule.>
       @param - <List velocityRules>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
*/
 
 Public PRM_VPP_VelocityRuleResults(List<Velocity_Rules__c> velocityRules){
     system.debug('2--->');
      getProfiledAccounts(VelocityRules);
      
 }

/* @Constructor <PRM_VPP_VelocityRuleResults(): This constructor would be used for fetching  
                                                VelocityRules  based on the ProfiledAccounts.>
       @param - <List ProfiledAccounts>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
*/
 Public PRM_VPP_VelocityRuleResults(List<Account> listAccount,boolean fetchNonPanRules ){
     system.debug('3--->');
       listGrouping = listAccount;
       if (fetchNonPanRules ){
         listVelocityRules= getNonPanRules() ;
       }else{
           getVelocityRules(listAccount);
       }
   } 
 
 public void createVelocityRuleResults(List<Account> listAccount,boolean fetchNonPanRules){
     system.debug('4--->');
     if (fetchNonPanRules ){
          listVelocityRules= getNonPanRules() ;
      }else{
           getVelocityRules(listAccount);
      }
     createVelocityRuleResults();
 }
 
  public void createVelocityRuleResults(List<Velocity_Rules__c> velocityRules){
     system.debug('5--->');
     getProfiledAccounts(velocityRules);
     createVelocityRuleResults();
 }
  
 
 /*@Method <createVelocityRuleResults: This method would be used to create VelocityRuleResults
                                       based on ProfiledAccounts/VelocityRules.>
       @param - <void>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
 */
 Public List<Velocity_Rule_Results__c> createVelocityRuleResults(){
   List<Velocity_Rules__c> velocityRules = listVelocityRules;
   system.debug('velocityRules------->' +velocityRules);
   if( (velocityRules!= null) && (velocityRules.size() >0) && 
           (listGrouping!=null) && (listGrouping.size()>0) ) {
     for(Velocity_Rules__c VRObj : velocityRules){
       if(VRObj.RecordType.DeveloperName == 'Specialty_Rule') {
          for(Account partnerGrp : listGrouping  ){
            if( VRObj.Specialty_Rule_Type__c == partnerGrp.Specialty_Rule_Type__c ) {
                Velocity_Rule_Results__c velocityRuleResult= new  Velocity_Rule_Results__c();
                   velocityRuleResult.Speciality_RuleID__c = VRObj.id ;
                   velocityRuleResult.Grouping__c = partnerGrp.Grouping__c;
                   velocityRuleResult.AccountID__c = partnerGrp.id ;
                                        
               listVelocityRuleResults.add(velocityRuleResult);
               system.debug('velocityRuleResult SR-------->' +velocityRuleResult);
              } 
            } 
         } // End of IF       
       else if(VRObj.RecordType.DeveloperName == 'Field_Based_Rule_Type') {
          for(Account partnerGrp : listGrouping  ){
              if(VRObj.Specialty_Rule_Type__c == partnerGrp.Specialty_Rule_Type__c ) {
                  Velocity_Rule_Results__c velocityRuleResult= new  Velocity_Rule_Results__c();
                  velocityRuleResult.Speciality_RuleID__c = VRObj.id ;
                  velocityRuleResult.Grouping__c = partnerGrp.Grouping__c;
                  velocityRuleResult.AccountID__c = partnerGrp.id ;                                      
                  listVelocityRuleResults.add(velocityRuleResult); 
                  system.debug('velocityRuleResult FSRT-------->' +velocityRuleResult);  
              }
          } 
       }
       else if(VRObj.RecordType.DeveloperName == 'Services_Rule'){
          for(Account partnerGrp : listGrouping  ){
               if(partnerGrp.Velocity_Solution_Provider_Tier__c!=''){   // added by prasad for bypassing evaluation of all profiled accounts
                   Velocity_Rule_Results__c velocityRuleResult= new  Velocity_Rule_Results__c();
                   velocityRuleResult.Speciality_RuleID__c = VRObj.id ;
                   velocityRuleResult.Grouping__c = partnerGrp.Grouping__c;
                   velocityRuleResult.AccountID__c = partnerGrp.id ;
                   listVelocityRuleResults.add(velocityRuleResult);
               }
           } 
       } //End of else if
                 
       else {
         system.debug('Inside createVelocityRuleResults() -else' );
         for(Account partnerGrp : listGrouping  ){
          if( VRObj.Cluster__c == partnerGrp.Cluster__c ) {
                Velocity_Rule_Results__c velocityRuleResult= new  Velocity_Rule_Results__c();
                   velocityRuleResult.Speciality_RuleID__c = VRObj.id ;
                   velocityRuleResult.Grouping__c = partnerGrp.Grouping__c;
                   velocityRuleResult.AccountID__c = partnerGrp.id ;
                                        
               listVelocityRuleResults.add(velocityRuleResult);
              } 
            } 
         } // End of ELSE   
      } // End of Velocity_Rules__c - loop.
    } 
      if(listVelocityRuleResults.size()>0) {
         //TODO - for handling failed records.
       // Database.Saveresult[] resultVelocityRuleResult = Database.insert(listVelocityRuleResults);
       // PRM_VPP_VelocityRuleResultsUtils.logFailedRecords(resultVelocityRuleResult);
       system.debug('listVelocityRuleResults Before Insert---------->' +listVelocityRuleResults);
         upsert listVelocityRuleResults;
      }
      system.debug('listVelocityRuleResults After Insert---------->' +listVelocityRuleResults);
     return listVelocityRuleResults; 
    } // END of Method.
 
  //save error records
   public List<Velocity_Rule_Results__c> createVelocityRuleResultswitherrors(string Batchid, List<EMCException> emailerrors){
	   List<Velocity_Rules__c> velocityRules = listVelocityRules;
	   system.debug('velocityRules------->' +velocityRules);
	   List <EMCException> errors = new List <EMCException>();
	   if( (velocityRules!= null) && (velocityRules.size() >0) && 
	           (listGrouping!=null) && (listGrouping.size()>0) ) {
	     for(Velocity_Rules__c VRObj : velocityRules){
	       if(VRObj.RecordType.DeveloperName == 'Specialty_Rule') {
	          for(Account partnerGrp : listGrouping  ){
	            if( VRObj.Specialty_Rule_Type__c == partnerGrp.Specialty_Rule_Type__c ) {
	                Velocity_Rule_Results__c velocityRuleResult= new  Velocity_Rule_Results__c();
	                   velocityRuleResult.Speciality_RuleID__c = VRObj.id ;
	                   velocityRuleResult.Grouping__c = partnerGrp.Grouping__c;
	                   velocityRuleResult.AccountID__c = partnerGrp.id ;
	                                        
	               listVelocityRuleResults.add(velocityRuleResult);
	               system.debug('velocityRuleResult SR-------->' +velocityRuleResult);
	              } 
	            } 
	         } // End of IF       
	       else if(VRObj.RecordType.DeveloperName == 'Field_Based_Rule_Type') {
	          for(Account partnerGrp : listGrouping  ){
	              if(VRObj.Specialty_Rule_Type__c == partnerGrp.Specialty_Rule_Type__c ) {
	                  Velocity_Rule_Results__c velocityRuleResult= new  Velocity_Rule_Results__c();
	                  velocityRuleResult.Speciality_RuleID__c = VRObj.id ;
	                  velocityRuleResult.Grouping__c = partnerGrp.Grouping__c;
	                  velocityRuleResult.AccountID__c = partnerGrp.id ;                                      
	                  listVelocityRuleResults.add(velocityRuleResult); 
	                  system.debug('velocityRuleResult FSRT-------->' +velocityRuleResult);  
	              }
	          } 
	       }
	       else if(VRObj.RecordType.DeveloperName == 'Services_Rule'){
	       for(Account partnerGrp : listGrouping  ){
	               if(partnerGrp.Velocity_Solution_Provider_Tier__c!=''){   // added by prasad for bypassing evaluation of all profiled accounts
	                   Velocity_Rule_Results__c velocityRuleResult= new  Velocity_Rule_Results__c();
	                   velocityRuleResult.Speciality_RuleID__c = VRObj.id ;
	                   velocityRuleResult.Grouping__c = partnerGrp.Grouping__c;
	                   velocityRuleResult.AccountID__c = partnerGrp.id ;
	                   listVelocityRuleResults.add(velocityRuleResult);
	               }
	           } 
	         } //End of else if
	                 
	       else {
	         system.debug('Inside createVelocityRuleResults() -else' );
	         for(Account partnerGrp : listGrouping  ){
	          if( VRObj.Cluster__c == partnerGrp.Cluster__c ) {
	                Velocity_Rule_Results__c velocityRuleResult= new  Velocity_Rule_Results__c();
	                   velocityRuleResult.Speciality_RuleID__c = VRObj.id ;
	                   velocityRuleResult.Grouping__c = partnerGrp.Grouping__c;
	                   velocityRuleResult.AccountID__c = partnerGrp.id ;
	                                        
	               listVelocityRuleResults.add(velocityRuleResult);
              } 
            } 
         } // End of ELSE   
      } // End of Velocity_Rules__c - loop.
    } 
      if(listVelocityRuleResults.size()>0) {
         //TODO - for handling failed records.
       // Database.Saveresult[] resultVelocityRuleResult = Database.insert(listVelocityRuleResults);
       // PRM_VPP_VelocityRuleResultsUtils.logFailedRecords(resultVelocityRuleResult);
       system.debug('listVelocityRuleResults Before Insert---------->' +listVelocityRuleResults);
           Database.upsertresult[] results = database.upsert(listVelocityRuleResults,false);
            /* HANDLING EXCEPTION LOG*/
		        for (Database.upsertresult sr : results) {
		            String dataErrs = '';
		            if (!sr.isSuccess()) {
		                // if the particular record did not get updated, we log the data error 
		                for (Database.Error err : sr.getErrors()) {
		                    dataErrs += err.getMessage();
		                }
		                System.debug('An exception occurred while attempting an update on ' + sr.getId());
		                System.debug('ERROR: ' + dataErrs);		                
		                errors.add(new EMCException(dataErrs, Batchid, new String [] {sr.getId()}));
		                
		            }
		        }    
		      // log any errors that occurred
		      system.debug('BatchidBatchidvv'+Batchid);
		       if (errors.size() > 0) { 
		            EMC_UTILITY.logErrors(errors);
		            emailerrors.addall(errors);
		            system.debug('emailerrorsemailerrors'+emailerrors);
		        }		
      }
      system.debug('listVelocityRuleResults After Insert---------->' +listVelocityRuleResults);
     return listVelocityRuleResults; 
    } // END of Method.
 
 
 // HELPER METHODS
 /*@Method <getProfiledAccounts(): This method will be called from Constructor to get the
                                    profiledAccount details based on VelocityRules.>
       @param - List<Velocity_Rules__c>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
 */
  private void getProfiledAccounts(List<Velocity_Rules__c> velocityRules){
  if(velocityRules!=Null && velocityRules.size()>0){ 
    for(Velocity_Rules__c velocityRule : velocityRules){
     if(velocityRule.Cluster__c != null ){
       setClusters.add(velocityRule.Cluster__c);
     }
     if(velocityRule.Specialty_Rule_Type__c != null){  
     setSpecialtyRuleTypes.add(velocityRule.Specialty_Rule_Type__c);    
     }
    } //End of for.
    rowLimit = Limits.getLimitQueryRows();
   velocityRuleQuery = 'SELECT id,name,Specialty_Rule_Type__c,Cluster__c,Theater1__c,'
                          +'PROFILED_ACCOUNT_FLAG__c,Grouping__c,Velocity_Solution_Provider_Tier__c FROM Account '
                          +'WHERE ( (PROFILED_ACCOUNT_FLAG__c = TRUE) AND (Grouping__c != NULL) )'
                          + 'AND '
                          + '( (Cluster__c IN : setClusters) OR '
                          +'(Specialty_Rule_Type__c IN : setSpecialtyRuleTypes) ) LIMIT :rowLimit ';
    system.debug('velocityRuleQuery -- '+ velocityRuleQuery);                           
    listGrouping = Database.query(velocityRuleQuery);
    listVelocityRules = velocityRules; 
   }
  } // End of method - getProfiledAccounts.
 
 /*@Method <getProfiledAccounts(): This method will be called from Constructor to get the
                                    profiledAccount details based on VelocityRules.>
       @param - List<Account>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
 */  
 private void getVelocityRules(List<Account> listAccounts){
  System.debug('listAccounts  '+listAccounts);
  if( (listAccounts != Null) && (listAccounts.size()>0) ){  
    for(Account acc : listAccounts){
     if((acc.Cluster__c !=null) && (acc.Cluster__c !='')){
       setClusters.add(acc.Cluster__c);
     }
     if( (acc.Specialty_Rule_Type__c !=null) && (acc.Specialty_Rule_Type__c!= '')){  
       setSpecialtyRuleTypes.add(acc.Specialty_Rule_Type__c);    
     }
    }
    system.debug('setClusters :' + setClusters); 
    system.debug('setSpecialtyRuleTypes :' + setSpecialtyRuleTypes);
         
    rowLimit = Limits.getLimitQueryRows();
    system.debug('ROW LIMIT ::'+ rowLimit);
     velocityRuleQuery ='SELECT id, name,Cluster__c,Required__c,Specialty_Rule_Type__c,Recordtype.DeveloperName, RecordtypeId'
                         +' FROM Velocity_Rules__c WHERE RecordType.DeveloperName IN :Recordtypes' 
                         +' AND (( Cluster__c IN : setClusters) OR (Specialty_Rule_Type__c IN : setSpecialtyRuleTypes) )'
                         +' AND (Evaluation_At__c=\'Country Grouping Level\' ) LIMIT :rowLimit';
    
     listVelocityRules = Database.query(velocityRuleQuery);
     system.debug('listVelocityRules Size ####' + listVelocityRules.size());
     listGrouping = listAccounts;
    }
  }//End of method- getVelocityRules.
  
  /*@Method <getNonPanRules(): This method will velocity rules which are not part PAN Model. Such as Service Rules.>
       @param - <void>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
 */  
 private  List<Velocity_Rules__c> getNonPanRules(){
 
    rowLimit = Limits.getLimitQueryRows();
    system.debug('ROW LIMIT ::'+ rowLimit);
    velocityRuleQuery ='SELECT id, name,Cluster__c,Required__c,Specialty_Rule_Type__c,Recordtype.DeveloperName, RecordtypeId '
                         +' FROM Velocity_Rules__c WHERE RecordType.DeveloperName IN :NonPanRecordtypes ' 
                         +' and (VS_Section__c != null) AND (Evaluation_At__c=\'Country Grouping Level\'  )'
                         +' LIMIT :rowLimit';
    
     List <Velocity_Rules__c>listVelocityRules = Database.query(velocityRuleQuery);
     system.debug('listVelocityRules Size ####' + listVelocityRules.size());
     return  listVelocityRules ;
  }//End of method- getNonPanRules.
}