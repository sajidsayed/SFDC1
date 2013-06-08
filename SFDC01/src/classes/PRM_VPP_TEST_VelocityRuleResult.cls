// updated by prasad -- 21-Feb-2011 -- added all comliance status fields on account query


   
/*============================================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  18/03/2011    Anand Sharma                      Added Education_Data_Refresh_Date__c field into account query                          
 |  21-Feb-2011   Prasad                            Added all comliance status fields on account query
 |  23-Mar-2011   Saravanan C             2514      Defect 330 - updated the query for adding Field: Group_Rule_3__c,Group_Rule_4__c
 |                                                  Group_Rule_5__c in Object: Velocity_Rules__c     
 |  04-Aug-2011   Suman B                           Updated the queries for fetching with missing field Display_Name__c in 
                                                    runVelocityRuleJob() and runVelocityRuleResultJob() methods.
 |  06-Sep-2011   Suman B                 3735      Added options to runAlljobs based on Account Theater.
 |  08-Sep-2011   Suman B                 3735      Modified runJobForTheaters(). Scheduling Theater based batch job Classes -PRM_VPP_BatchJob_APJ. 
    21-Nov-2011   Prasad                            Sequential Logic update    
 |  28-Dec-2011   Anand Sharma                      Added  Theater Job to run getStagingTheaterJob     
 |  17-Jan-2012   Kaustav Debnath                   Modified the runPatnerLevJobs method to interchange the coditions for contact id and account id
 |  17-Jan-2012   Kaustav Debnath                   Added PROFILED_ACCOUNT_FLAG__c field in the query for account id in runPatnerLevJobs  method
 |  09-Mar-2012   Suman B                           Added Job for calcuation of Champion resources on Profiled Account 
 |  16-Mar-2012   Anand Sharma                      update runChampionResourceJob method to calculate only for active contact
 |  22 March 2012 Arif                              The Revenue jobs calling code has been updated.
 |  03 Apr 2012   Arif                              Update to display an error message if no staging data exist for an account
 |  22-Apr-2012   Anirudh Singh                     Updated Code to invoke runFunctionalAreaJob and runFunctionalAreaJobForAllAccounts
 |                                                  Method for Evaluation of Functional Area.
 |  23 July 2012  Arif                              Cloud Builder 
 |  05 Aug 2012   Prasad                            VPP improvement   
 |  07 Aug 2012   Arif                              Added a method 'deleteCreateEvaluateVRRForPAN' for deletion/creation/evaluation of velocity rule results
 |                                                  for a grouping at PAN Theater/Logical Block Level  
 |  16 Aug 2012   Arif                              Created methods for sequencing jobs of PAN and Logical Block    
 |  30 Aug 2012   Arif                              Added a logic of Local Requirement Set on grouping
    18 Sep 2012   Arif                              Added PAN GAF part  
    27 Sep 2012   Prasad                Added Immediate run    
    12 Oct 2012   Arif                  Added custom setting in runRevenueJobForAll   
    22Nov 2012    vivek kodi		                Added two parameters for inserting/email error records  
 |  21 Mar 2013   Karunaker M			235602      Added Isilon Incentive and Target Product fields in the query.
 |  22/05/2013    Suresh Dornadula      239600   	Added the Isilon_Track_Specialty__c to the queries and respective methods  
 +==============================================================================================================================*/

public class PRM_VPP_TEST_VelocityRuleResult { 
    

   
    public String accountId{get; set;}
    public String groupId{get; set;}
    public String velocityRuleId{get; set;}
    public String velocityRuleResultId{get; set;}
    public String SelectedJob{get; set;}
    public String SelectedTheaterJob { get; set; }  
    public Boolean isjobRunning { get; set; }
    public String[] SelectedTheatersForImmidateRun { get; set; }
    public String[] SelectedTheaters { get; set; }
    public String SelectedTheatersForScheduledJobs { get; set; }
    public string strGroupingId {get;set;}
    public String ProcessDeltaOnly{ get; set; }
    public string strGAFRevenueAndRebateId{get;set;}
    public string searchCriteriaForGAFPAN{get;set;}
    public string inputstr {get;set;}
    public string inputPLstr {get;set;}
    public string SelectedjobstoSchedule;
    public String[] SelectedJobs { get; set; }
    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll(); 
    
    public PageReference executeJobsNow() {
        
         Datetime dt = System.now();
            dt = dt.addMinutes(2);
            String scheduleString='0';//0 seconds
            scheduleString+=' '+ dt.minute();
            scheduleString+=' '+ dt.hour();
            scheduleString+=' '+ dt.day();
            scheduleString+=' '+ dt.month();
            scheduleString+=' ?';
            scheduleString+=' '+ dt.year();     
            
          
            Id SequentailJobId = System.schedule('VPP Jobs',scheduleString , new PRM_ESBI_VPP_Jobs_Scheduler());  
            
           Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();     
                   CustomSettingDataValueMap__c PRMVPPJobRunning = DataValueMap.get('PRMVPPJobRunning');  
                   PRMVPPJobRunning.DataValue__c = 'true' ;
                   update PRMVPPJobRunning ;   
        return null;
    }
    
    public PageReference setForNextScheduledRun() {
        CustomSettingDataValueMap__c ESBI_VPP_Scheduled_Theaters = DataValueMap.get('ESBI_VPP_Scheduled_Theaters'); 
        ESBI_VPP_Scheduled_Theaters.dataValue__c='';    
        for(String theater :SelectedTheaters){
            if(ESBI_VPP_Scheduled_Theaters.dataValue__c==''){
                ESBI_VPP_Scheduled_Theaters.dataValue__c= theater;

            }else{
                ESBI_VPP_Scheduled_Theaters.dataValue__c= ESBI_VPP_Scheduled_Theaters.dataValue__c +','+ theater;
            }
        }
        update ESBI_VPP_Scheduled_Theaters;
        
        return null;
    }
  public PageReference setJobsForNextScheduledRun() {
        CustomSettingDataValueMap__c ESBI_VPP_Scheduled_jobs = DataValueMap.get('ESBI_VPP_Scheduled_Jobs'); 
        ESBI_VPP_Scheduled_jobs.dataValue__c='';    
        for(String job:SelectedJobs){
            if(ESBI_VPP_Scheduled_jobs.dataValue__c==''){
                ESBI_VPP_Scheduled_jobs.dataValue__c= job;

            }else{
                ESBI_VPP_Scheduled_jobs.dataValue__c= ESBI_VPP_Scheduled_jobs.dataValue__c +','+ job;
            }
        }
        update ESBI_VPP_Scheduled_jobs;
        return null;
    }
    
    public PageReference setDeltaOption() {
        CustomSettingDataValueMap__c delta = DataValueMap.get('PRM_VPP_ProcessDeltaOnly');
        delta.dataValue__c=ProcessDeltaOnly;
        update delta;
        return null;
    }    

    public void runAllJob() {
        system.debug(' SelectedJob ' +SelectedJob);
        String DeleteEducationMappingQuery='select Id from Education_EducationGroup_Mapping__c where createddate <'+ new PRM_CommonUtils().getQueryFormattedDate(System.now());
        id batchinstanceid = database.executeBatch(new PRM_VPP_DeleteRecordsJob(DeleteEducationMappingQuery),200);
    }

    public PRM_VPP_TEST_VelocityRuleResult(){
        CustomSettingDataValueMap__c PRMVPPJobRunning = DataValueMap.get('PRMVPPJobRunning');     
        if(PRMVPPJobRunning.DataValue__c =='true'){
            isjobRunning = true ; 
        }else{
            isjobRunning = false ;
        }
    }

    
    
    string SearchCriteria;
    public string getSearchCriteria() {          
         return SearchCriteria;   
    } 

    public void setSearchCriteria(string SearchCriteria) {     
         this.SearchCriteria=SearchCriteria;    
    }
    
    public List<SelectOption> getSearchCriteriaList() 
      {     
         List<SelectOption> options2 = new List<SelectOption>();  
         options2.add(new SelectOption('Account Id','Account ID'));     
         options2.add(new SelectOption('Group Id','Grouping ID'));
         options2.add(new SelectOption('RollupforAccount','Rollup for Account'));                 
         return options2;  
      }
      
      string SearchCriteriaPL;
    public string getSearchCriteriaPL() {          
         return SearchCriteriaPl;   
    } 

    public void setSearchCriteriaPL(string SearchCriteriaPL) {     
         this.SearchCriteriaPl =SearchCriteriaPL;    
    }
    public List<SelectOption> getSearchCriteriaForPartnerLevList() 
    {     
        List<SelectOption> options2 = new List<SelectOption>();  
        options2.add(new SelectOption('Grouping ID','Grouping ID'));
        //options2.add(new SelectOption('Contact Id','Contact ID'));     
        //options2.add(new SelectOption('Account Id','Account ID'));                
        return options2;  
    }

    public List<SelectOption> getJobOperations(){
        List<SelectOption> options2 = new List<SelectOption>();
        
        options2.add(new SelectOption('RunAllJob','1. Run All Jobs'));
        options2.add(new SelectOption('Delete Education and Education Group Mappings','2. Delete Education and Education Group Mappings'));  
        options2.add(new SelectOption('Build Education and Education Group Mappings','3. Build Education and Education Group Mappings'));     
        options2.add(new SelectOption('Delete VelocityRuleResults','4. Delete Velocity Rule Results')); 
        options2.add(new SelectOption('BuildVelocityRuleResults','5. Build Velocity Rule Results'));     
        options2.add(new SelectOption('Evaluate Velocity Rules','6. Evaluate Velocity Rules Results'));
        options2.add(new SelectOption('Evaluate Rollup Rules','7. Evaluate Rollup Rules'));
        
        return options2;
    }

    public List<SelectOption> getTheaterJobOperations(){
        List<SelectOption> options2 = new List<SelectOption>();
        options2.add(new SelectOption('All','All'));        
        options2.add(new SelectOption('APJ','APJ'));
        options2.add(new SelectOption('EMEA','EMEA'));
        options2.add(new SelectOption('Americas','Americas'));       

        SelectedTheatersForScheduledJobs=DataValueMap.get('ESBI_VPP_Scheduled_Theaters').datavalue__c;
        ProcessDeltaOnly=DataValueMap.get('PRM_VPP_ProcessDeltaOnly').datavalue__c;
        return options2;
    }
     public List<SelectOption> getJobs(){
        List<SelectOption> options2 = new List<SelectOption>();
        
        options2.add(new SelectOption('VPP - Country Level','VPP - Country Level'));
        options2.add(new SelectOption('VPP - Logical Block Level','VPP - Logical Block Level'));
        options2.add(new SelectOption('VPP - PAN Theater Level','VPP - PAN Theater Level'));
        options2.add(new SelectOption('Funcational Area','Funcational Area'));
        options2.add(new SelectOption('Partner Leverage','Partner Leverage'));
               

       
        return options2;
    }
    public string getSelectedjobstoSchedule(){
         SelectedjobstoSchedule=DataValueMap.get('ESBI_VPP_Scheduled_Jobs').datavalue__c;
         return SelectedjobstoSchedule;
    } 
    
     public List<SelectOption> getJobPLOperations(){
        List<SelectOption> options2 = new List<SelectOption>();
        options2.add(new SelectOption('RunAllJob','1. Run All Jobs'));
        //options2.add(new SelectOption('Delete Education and Education Group Mappings','2. Delete Education and Education Group Mappings'));  
        //options2.add(new SelectOption('Build Education and Education Group Mappings','3. Build Education and Education Group Mappings'));     
        //options2.add(new SelectOption('Evaluate Partner Lev factor','4. Evaluate Partner Lev factor'));
        

        return options2;
    }
   public void runPatnerLevJobs(){
                
        Id ContactAccountId ;
        Set<Id> groupingIds = new Set<Id>();
        Id profileAccountId;
        if(SearchCriteriaPL =='Grouping ID'){ 
            try{
                profileAccountId = inputPLstr;
            } catch(Exception ex){
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide valid grouping Id');
                ApexPages.addMessage(errorMessage);
                return;
            }       
                    
            groupingIds.add(profileAccountId);
            
            if(inputPLstr != null && inputPLstr !='' && inputPLstr.length() >14 && inputPLstr.startsWith('a0F')){
                 
                System.debug('#### am in here');            
                Map<Id,Account> mapAllAccountsFromGrouping=new Map<Id,Account>([select account.id,account.grouping__c,account.PROFILED_ACCOUNT_FLAG__c,velocity_Solution_Provider_Tier__c,
                                                                            account.name,account.rating_eligible__c,account.theater1__c from account where 
                                                                            account.grouping__c in :groupingIds order by account.grouping__c]);
                
                if(mapAllAccountsFromGrouping != null && mapAllAccountsFromGrouping.size() >0){
                    System.debug('### i am here');
                    for(Account accObj:mapAllAccountsFromGrouping.values())
                    {
                        System.debug('#### accObj.id=>'+accObj.id);
                        if(accObj.PROFILED_ACCOUNT_FLAG__c==true && accObj.Rating_Eligible__c==false)
                        {
                            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide valid grouping Id');
                            ApexPages.addMessage(errorMessage);
                            return;
                        }
                    }
                }                                                            
                List<Contact> lstContacts = [select id,name,partner_se__c,accountid, Account.Profiled_Account__c,
                                                Account.PROFILED_ACCOUNT_FLAG__c, Account.Profiled_Account__r.rating_eligible__c, 
                                                Account.Grouping__c, emc_pre_sales__c,account.rating_eligible__c,account_theater__c
                                                 from contact where partner_se__c=true and accountid in:mapAllAccountsFromGrouping.keyset() order by account_theater__c]; 
                
                PRM_Partner_Leverage.contactPartnerLevFactorCalculation(lstContacts);            
                
                String Batchid ='' ;
			    List <EMCException> errors = new List <EMCException>();
                PRM_Partner_Leverage.accountPartnerLevFactorCalculation(groupingIds,Batchid,errors);
            }else{
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide valid grouping Id');
                ApexPages.addMessage(errorMessage);
                return;
            }
        }/*else if(SearchCriteriaPL =='Contact ID'){
            Contact objContact =[Select id, Name,AccountId, Account.Profiled_Account__c, Account.Grouping__c from contact where id =: inputPLstr ];
            
            if(objContact != null && objContact.Accountid != null && objContact.Account.Grouping__c != null){
                groupingIds.add(objContact.Account.Grouping__c);
            }
                       
        }else if(SearchCriteriaPL =='Account ID'){
            Account objAccount =[Select id, Name, Profiled_Account__c,PROFILED_ACCOUNT_FLAG__c, Grouping__c,velocity_Solution_Provider_Tier__c from Account where id =: inputPLstr ];
            
            if(objAccount != null && objAccount.Grouping__c != null){
                groupingIds.add(objAccount.Grouping__c);
            }
        }*/       
            
        /*List<Education__c>  education = [Select e.Partner_Grouping__c, e.Partner_Grouping_ID__c, e.Name, 
                                     e.Id, e.Education_ID__c, e.Contact__c,e.Education_Master__c 
                                      From Education__c e 
                                     where e.Partner_Grouping__c IN :groupingIds ] ;
        if(education != null && education.size()> 0){
            system.debug('EDUCATION :: ' + education); 
            List<Id> educationIds = new List<Id>();
           for(Education__c edu : education){
              educationIds.add(edu.Id);
           }
           PRM_VPP_VelocityRuleResultsUtils.deleteEducationAndEducationGroupMapping(educationIds);
           PRM_VPP_VelocityRuleResultsUtils.createEducationAndEducationGroupMapping(education);
        }*/
        
        /*if(SearchCriteriaPL =='Contact ID'){            
            String query = 'select id,name,partner_se__c,accountid, Account.Profiled_Account__c,Account.PROFILED_ACCOUNT_FLAG__c, Account.Profiled_Account__r.rating_eligible__c, Account.Grouping__c, emc_pre_sales__c,account.rating_eligible__c,account_theater__c from contact where partner_se__c=true and id= \'' + ContactAccountId + '\' order by account_theater__c'; 
            System.debug('Query is---->'+Query);
            
            Contact objContact = Database.Query(query);
            List<Contact> lstContactUpdate = new List<Contact>();
            lstContactUpdate.add(objContact);
            if(objContact!= null && objContact.partner_se__c==true && objContact.AccountId != null && objContact.Account.PROFILED_ACCOUNT_FLAG__c==true && objContact.Account.rating_eligible__c ==true){
                 PRM_Partner_Leverage.contactPartnerLevFactorCalculation(lstContactUpdate);
            }else if(objContact!= null && objContact.partner_se__c==true && objContact.AccountId != null && objContact.Account.PROFILED_ACCOUNT_FLAG__c==false && objContact.Account.Profiled_Account__c != null && objContact.Account.Profiled_Account__r.rating_eligible__c ==true){
                PRM_Partner_Leverage.contactPartnerLevFactorCalculation(lstContactUpdate);
            }            
            
            PartnerSEContactSummaryFieldsUpdateBatch contactBatch = new PartnerSEContactSummaryFieldsUpdateBatch(Query);
            database.executebatch(contactBatch);
            
        }else if(SearchCriteriaPL =='Account ID'){
           
            String query='select id,grouping__c,PROFILED_ACCOUNT_FLAG__c,Partner_Leverage_Factor_Average__c,Partner_Leverage_Factor_Total__c,name,theater1__c,velocity_Solution_Provider_Tier__c,(select contact.id,contact.Partner_Leverage_Factor__c from account.contacts where contact.partner_se__c=true) from account where PROFILED_ACCOUNT_FLAG__c=true and id= \'' + ContactAccountId + '\' order by theater1__c';
            Account objAccount = database.query(query);
            if(objAccount!= null && objAccount.PROFILED_ACCOUNT_FLAG__c==true && objContact.Account.rating_eligible__c ==true){
                 PRM_Partner_Leverage.contactPartnerLevFactorCalculation(lstContactUpdate);
            }else if(objContact!= null && objContact.partner_se__c==true && objContact.AccountId != null && objContact.Account.PROFILED_ACCOUNT_FLAG__c==false && objContact.Account.Profiled_Account__c != null && objContact.Account.Profiled_Account__r.rating_eligible__c ==true){
                PRM_Partner_Leverage.contactPartnerLevFactorCalculation(lstContactUpdate);
            }
            
            PRM_Partner_Leverage.accountPartnerLevFactorCalculation(groupingIds);
            
            AccountPartnerSEFieldsUpdateBatch accountBatch= new AccountPartnerSEFieldsUpdateBatch(query);
            database.executebatch(accountBatch);
            
        }  */       
   }     
   
    public void runJobForALLPL(){
                
        List<SequencialBatchJob> SelectedTheaterPLJobs= new List<SequencialBatchJob> ();
        
        Integer batchSize = 200;
        //get batch size
        try{            
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_EducationEduMasterGroupJob').DataValue__c);
        }catch(Exception e){
            batchSize = 20;
        }
        SelectedTheatersForImmidateRun = new String[]{'All','APJ', 'EMEA','Americas'} ;
        for(String theater: SelectedTheatersForImmidateRun ){
            
            String ruleResultQuery = 'Select e.Batch_Job_Operation__c, e.Id,Education_Master__c '
                                       + 'from Education__c e  where Theater__c = \''+Theater+'\'';
            System.debug('ruleResultQuery '+ruleResultQuery);
            PRM_VPP_EducationEduationMasterGroupJob job2= new PRM_VPP_EducationEduationMasterGroupJob(ruleResultQuery);
            //SelectedTheaterPLJobs.add(new SequencialBatchJob('Build Education and Education Group Mappings '+Theater,job2,batchSize ));
                        
            if(theater=='APJ'){                 
                SelectedTheaterPLJobs.addAll(schedulePLTheaterwiseJobs('APJ'));               
            }
            if(theater=='EMEA' ){ 
                SelectedTheaterPLJobs.addAll(schedulePLTheaterwiseJobs('EMEA'));               
            } 
            if(theater=='Americas' ){ 
                SelectedTheaterPLJobs.addAll(schedulePLTheaterwiseJobs('Americas'));  
            } 
        }           
        SequencialBatchJobScheduler.executeSequence(SelectedTheaterPLJobs);
    }
    
    public List<SequencialBatchJob> schedulePLTheaterwiseJobs(String Theater) {
        
        List<SequencialBatchJob> SelectedPLJobs= new List<SequencialBatchJob> ();
        
        String query = 'select id,name,partner_se__c,accountid, Account.Profiled_Account__c,Account.PROFILED_ACCOUNT_FLAG__c, Account.Profiled_Account__r.rating_eligible__c, Account.Grouping__c, emc_pre_sales__c,account.rating_eligible__c,account_theater__c from contact where partner_se__c=true and account_theater__c = \'' + Theater + '\' order by account_theater__c';
        PartnerSEContactSummaryFieldsUpdateBatch contactBatch = new PartnerSEContactSummaryFieldsUpdateBatch(query);  
        SelectedPLJobs.add(new SequencialBatchJob('Partner Lev Contact Calculation: ' +Theater, contactBatch,200)); 
        
        String queryAccount ='select id,grouping__c,PROFILED_ACCOUNT_FLAG__c,Partner_Leverage_Factor_Average__c,Partner_Leverage_Factor_Total__c,name,theater1__c,velocity_Solution_Provider_Tier__c,(select contact.id,contact.Partner_Leverage_Factor__c from account.contacts where contact.partner_se__c=true) from account where PROFILED_ACCOUNT_FLAG__c=true and rating_eligible__c=true and theater1__c =\'' + Theater + '\' order by theater1__c';  
        AccountPartnerSEFieldsUpdateBatch accountBatch= new AccountPartnerSEFieldsUpdateBatch(queryAccount);
        SelectedPLJobs.add(new SequencialBatchJob('Partner Lev Account Rollup Calculation:' + Theater, accountBatch,200));
        
        return SelectedPLJobs;
    }
   
     public void runJobForAll(){
          
       CustomSettingDataValueMap__c PRMVPPJobRunning = DataValueMap.get('PRMVPPJobRunning');  
       PRMVPPJobRunning.DataValue__c = 'true' ;
       update PRMVPPJobRunning ;
      
       checkRunningJob();                 
      /*
       system.debug(' SelectedJob ' +SelectedJob);
       String DeleteEducationMappingQuery='select Id from Education_EducationGroup_Mapping__c where createddate <'+ new PRM_CommonUtils().getQueryFormattedDate(System.now());
           
           id batchinstanceid = database.executeBatch(new PRM_VPP_DeleteRecordsJob(DeleteEducationMappingQuery),200);
      */ 

        CustomSettingDataValueMap__c jobObjectDetails = DataValueMap.get('PRMVPPALLJobExecution');
        CustomSettingDataValueMap__c jobVelocityRuleCheckDetails = DataValueMap.get('PRMVPPDeleteJobExecutionVelocityRule');
        jobObjectDetails.DataValue__c ='false';
        if(SelectedJob=='Delete Education and Education Group Mappings'){
            jobObjectDetails.DataValue__c ='false';
            update jobObjectDetails;
            
            String DeleteEducationMappingQuery='select Id from Education_EducationGroup_Mapping__c where createddate <'+ new PRM_CommonUtils().getQueryFormattedDate(System.now()) ;
           
            id batchinstanceid = database.executeBatch(new PRM_VPP_DeleteRecordsJob(DeleteEducationMappingQuery),200);
            system.debug(' BATCH INSTANCE ---#### : ' +batchinstanceid);
        }
        if(SelectedJob=='Build Education and Education Group Mappings'){
            jobObjectDetails.DataValue__c ='false';
            update jobObjectDetails;
                
            String ruleResultQuery = 'Select e.Batch_Job_Operation__c, e.Id,Education_Master__c '
                               + 'from Education__c e ';
            id batchinstanceid1= database.executeBatch(new PRM_VPP_EducationEduationMasterGroupJob(ruleResultQuery),200);
            system.debug(' BATCH INSTANCE ---#### : ' +batchinstanceid1);

        }
        if(SelectedJob=='Delete VelocityRuleResults'){
            jobObjectDetails.DataValue__c ='false';
            update jobObjectDetails;
            
            String DeleteVelocityRuleResultsQuery='select Id,Grouping__c,Grouping__r.RecordType.DeveloperName from Velocity_Rule_Results__c where Grouping__r.RecordType.DeveloperName = \'Partner_Grouping\' and createddate <'+ new PRM_CommonUtils().getQueryFormattedDate(System.now()) ;
            System.debug(' DeleteVelocityRuleResultsQuery '+ DeleteVelocityRuleResultsQuery);
            id batchinstanceid = database.executeBatch(new PRM_VPP_DeleteRecordsJob(DeleteVelocityRuleResultsQuery),200);
            system.debug(' BATCH INSTANCE ---#### : ' +batchinstanceid);
        }       
        if(SelectedJob=='BuildVelocityRuleResults'){
            jobObjectDetails.DataValue__c ='false';
            update jobObjectDetails;
            
            String ruleResultQuery = 'Select Id, Grouping__c,Batch_Job_Operation__c,Specialty_Rule_Type__c,Cluster__c,Grouping__r.Local_Requirment_Set__c,'
                               +' Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c,'
                               +' Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c,Velocity_Compliance_Status__c,'
                               +' Education_Data_Refresh_Date__c,Deployed_Velocity_Services__c,velocity_Solution_Provider_Tier__c  '     
                               + 'from Account e where velocity_Solution_Provider_Tier__c!=\'\' and profiled_Account_flag__c=true and Grouping__c!=null';
            id batchinstanceid1 = database.executeBatch(new PRM_VPP_VelocityRuleResultJob1(ruleResultQuery),200);
            system.debug(' BATCH INSTANCE ---#### : ' +batchinstanceid1);
        }
        if(SelectedJob=='Evaluate Velocity Rules'){
            jobObjectDetails.DataValue__c ='false';
            update jobObjectDetails;
        
            String ruleResultQuery = 'Select Revenue_Amount__c, Required_value_Type__c,v.Speciality_RuleID__c, v.Rule_theater__c,Grouping__r.Local_Requirment_Set__c, '
                                    +'v.RequiredCount__c,Speciality_RuleID__r.RecordType.Name,v.Grouping__c,v.Grouping__r.RecordType.DeveloperName, '
                                    +'Speciality_RuleID__r.RecordType.DeveloperName, v.Name, v.Current__c,Speciality_RuleID__r.Local_Requirment_Set__c, '
                                    +'v.Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c, '
                                    +'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, '
                                    +'Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Group_Rule_3__c, '
                                    +'Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c, '
                                    +'Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.BR_Sub_category__c, '
                                    +'Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Required_Type__c, '
                                    +'Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,'
                                    +'Speciality_RuleID__r.Theater__c,Speciality_RuleID__r.Specilaity__c, '
                                    +'Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Any_Value_Acceptable__c,Speciality_RuleID__r.Value__c '
                                    +' VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c, '
                                    +'Speciality_RuleID__r.Name,v.AccountID__c From Velocity_Rule_Results__c v where Grouping__r.RecordType.DeveloperName = \'Partner_Grouping\' ORDER BY ' +'Grouping__c ';
            id batchinstanceid = database.executeBatch(new PRM_VPP_VelocityRuleEvaluatorJob(ruleResultQuery),200);
            System.debug(' BATCH INSTANCE ---#### : ' +batchinstanceid);
        }
        if(SelectedJob=='Evaluate Rollup Rules'){
            jobObjectDetails.DataValue__c ='false';
            update jobObjectDetails;
        
            String ruleResultQuery = 'Select a.PROFILED_ACCOUNT_FLAG__c, a.Name, Theater1__c, a.Id, a.Grouping__c, '
                                    +'Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c, '
                                    +'Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c, '
                                    +'Velocity_Compliance_Status__c , Education_Data_Refresh_Date__c,velocity_Solution_Provider_Tier__c From Account a '
                                    +'where profiled_Account_flag__c=true and Grouping__c!=null';
            id batchinstanceid = database.executeBatch(new PRM_VPP_RollupRuleEvaluatorJob(ruleResultQuery),200);
            System.debug(' BATCH INSTANCE ---#### : ' +batchinstanceid);
        }
        if(SelectedJob=='RunAllJob'){
            
            List<String> theaters= new List<String>(); 
            List<SequencialBatchJob> AllTheaterVPPJobs = new List<SequencialBatchJob>();
            PRM_JobFactory JobFactory = new PRM_JobFactory();
             
            AllTheaterVPPJobs.add(JobFactory.getStagingTheaterJob());
            
            AllTheaterVPPJobs.addAll(JobFactory.getVPPJobs('APJ','Country'));    
            AllTheaterVPPJobs.addAll( JobFactory.getVPPJobs('EMEA','Country'));
            AllTheaterVPPJobs.addAll(JobFactory.getVPPJobs('Americas','Country'));
            
            SequencialBatchJobScheduler.executeSequence(AllTheaterVPPJobs );
            
           /* jobObjectDetails.DataValue__c ='true';
            update jobObjectDetails;
            jobVelocityRuleCheckDetails.DataValue__c = 'false';
            update jobVelocityRuleCheckDetails;
            
            String DeleteResultsQuery ='select Id from Education_EducationGroup_Mapping__c where createddate <'+ new PRM_CommonUtils().getQueryFormattedDate(System.now());
            id batchinstanceid = database.executeBatch(new PRM_VPP_DeleteRecordsJob(DeleteResultsQuery),200);
          */  
        }
       system.debug('Setting PRMVPPJobRunning to --true ###');
   }
   
   public void runSelectedJob(){
    system.debug(' INSIDE SearchCriteria ' + SearchCriteria);
    if(SearchCriteria=='Account Id'){
           accountId = inputstr;
           runProfiledAccountsJob();
    }
    else if(SearchCriteria == 'RollupforAccount'){
       system.debug(' INSIDE RollupforAccount ');
       accountId = inputstr;
       runAccountRollupJob();    
   
    }
    else{
        groupId = inputstr;
        runProfiledGroupsJob();
    }
  }
 /** CHANGES END FOR DROP DOWN LIST**/   

    public void runAccountJob(){
        String ruleResultQuery = 'Select Speciality_RuleID__c, Rule_theater__c,Required_Value_Type__c,RequiredCount__c,Speciality_RuleID__r.Bucket__c,'
                                     + 'Name, Grouping__c, Current__c, Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.RecordType.Name,'                      
                                      +'Speciality_RuleID__r.RecordType.DeveloperName,Speciality_RuleID__r.Any_Value_Acceptable__c,Speciality_RuleID__r.Value__c,'
                                       + 'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c,Speciality_RuleID__r.Velocity_Rule_1__c,'
                                       + 'Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c, '
                                       + 'AccountID__c,VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c  From Velocity_Rule_Results__c v where AccountID__c =\'' + accountId + '\'' ;
        
        List<Velocity_Rule_Results__c > listVelocityRuleResults = Database.query(ruleResultQuery); 
        system.debug(' listVelocityRuleResults ---> : ' +listVelocityRuleResults.size());
        runBatchJob(listVelocityRuleResults);        
    }
    
    private void runBatchJob(List<Velocity_Rule_Results__c > listVelocityRuleResults){
        system.debug(' listVelocityRuleResults  Run BatcJob---> : ' +listVelocityRuleResults.size());
        PRM_VPP_RuleEvaluator objRuleEvaluator = new PRM_VPP_RuleEvaluator(listVelocityRuleResults);
        system.debug(' listVelocityRuleResults After Constructor---> : ' +listVelocityRuleResults.size());
        objRuleEvaluator.evaluateVelocityRule(listVelocityRuleResults);
        system.debug(' listVelocityRuleResults After evaluateVelocityRules---> : ' +listVelocityRuleResults.size());        
    }
    
    public void runVelocityRuleJob(){
        String ruleResultQuery = 'Select Speciality_RuleID__c,Required_Value_Type__c,Rule_theater__c, RequiredCount__c,Speciality_RuleID__r.RecordType.Name ,Speciality_RuleID__r.RecordType.DeveloperName,'
                               + 'Name, Grouping__c, Current__c, Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,'
                               + 'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Cluster__c,'
                               + 'Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c, '
                               + 'Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,'
                               + 'Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.Theater__c,'
                               + 'Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,'
                               + ' VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c, Speciality_RuleID__r.any_value_Acceptable__c,'
                               + 'AccountID__c From Velocity_Rule_Results__c v where Speciality_RuleID__c =\'' + velocityRuleId + '\'' ;
        
        List<Velocity_Rule_Results__c > listVelocityRuleResults = Database.query(ruleResultQuery); 
        runBatchJob(listVelocityRuleResults);                                              
    }
    
    public void runVelocityRuleResultJob(){
        String ruleResultQuery ='Select Speciality_RuleID__c,Required_Value_Type__c,Rule_theater__c, RequiredCount__c,Speciality_RuleID__r.RecordType.Name ,Speciality_RuleID__r.RecordType.DeveloperName,'
                               + 'Name, Grouping__c, Current__c, Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,'
                               + 'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Cluster__c,'
                               + 'Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c, '
                               + 'Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Any_Value_Acceptable__c,Speciality_RuleID__r.Value__c,'
                               + 'Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.Theater__c,'
                               + 'Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,'
                               + ' VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c, '
                               + 'AccountID__c From Velocity_Rule_Results__c v where Id =\'' + velocityRuleResultId + '\'' ;
        List<Velocity_Rule_Results__c > listVelocityRuleResults = Database.query(ruleResultQuery); 
        runBatchJob(listVelocityRuleResults);                                              
    }
    
    public void runGroupJob(){
       String ruleResultQuery = 'Select Speciality_RuleID__c,Required_Value_Type__c,Rule_theater__c, RequiredCount__c,Speciality_RuleID__r.RecordType.Name ,Speciality_RuleID__r.RecordType.DeveloperName,'
                               + 'Name, Grouping__c, Current__c, Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,'
                               + 'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Cluster__c,'
                               + 'Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c, '
                               + 'Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Value__c,'
                               + 'Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.Theater__c,'
                               + 'Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,'
                               + ' VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c,Speciality_RuleID__r.any_value_Acceptable__c, '
           + 'AccountID__c From Velocity_Rule_Results__c v where Grouping__c =\'' + groupId + '\'' ;
        List<Velocity_Rule_Results__c > listVelocityRuleResults = Database.query(ruleResultQuery); 
        runBatchJob(listVelocityRuleResults);                                              
    }


    // Added by Suman.   
   public void runProfiledAccountsJob(){
        Id accountIds = accountId;
        List<account> acc = [select id,name,cluster__C,Specialty_Rule_Type__c,Grouping__c, Advanced_Consolidate_Compliance_Status__c,Grouping__r.Local_Requirment_Set__c,
                                    Backup_and_Recovery_Compliance_Status__c,Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c,
                                    Deployed_Velocity_Services__c,Velocity_Compliance_Status__c, Education_Data_Refresh_Date__c,velocity_Solution_Provider_Tier__c from Account where id = :accountIds ];
        system.debug('ACCOUNT :: ' + acc );
        List<Id> grpIds = new List<Id>();
        for(Account accObj : acc){          
            if(accObj.Grouping__c != null){
                grpIds.add(accObj.Grouping__c);
            }          
        }
 
   List<Velocity_Rule_Results__c> listVRR1 = [SELECT id,name,AccountID__c,Grouping__c  from 
                                                    Velocity_Rule_Results__c where Grouping__c IN : grpIds];
        if( (listVRR1 != null) && (listVRR1.size()>0) ){
           delete listVRR1 ;
         }

     
        List<Education__c>  education = [Select e.Partner_Grouping__c, e.Partner_Grouping_ID__c, e.Name, 
                                     e.Id, e.Education_ID__c, e.Contact__c,e.Education_Master__c 
                                      From Education__c e 
                                     where e.Partner_Grouping__c IN :grpIds ] ;
        if(education != null && education.size()> 0){
            system.debug('EDUCATION :: ' + education); 
            List<Id> educationIds = new List<Id>();
           for(Education__c edu : education){
              educationIds.add(edu.Id);
           }
           PRM_VPP_VelocityRuleResultsUtils.deleteEducationAndEducationGroupMapping(educationIds);
           PRM_VPP_VelocityRuleResultsUtils.createEducationAndEducationGroupMapping(education);
        }
        
        if(acc != null && acc.size() >0){
        PRM_VPP_VelocityRuleResults vRR = new  PRM_VPP_VelocityRuleResults(acc,false ) ;
        List<Velocity_Rule_Results__c>  listVRR = vRR.createVelocityRuleResults();  
        system.debug('VRR :: ' + listVRR );
        List<ID> resultId =new List<Id>();
        for(Velocity_Rule_Results__c result : listVRR ) {
           resultId.add(result .id);
        }
      
       String ruleResultQuery = 'Select Speciality_RuleID__c,Required_Value_Type__c,Rule_theater__c, RequiredCount__c,Speciality_RuleID__r.RecordType.Name ,Speciality_RuleID__r.RecordType.DeveloperName,'
                               + 'Name, Grouping__c, Current__c, Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,'
                               + 'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Cluster__c,'
                               + 'Speciality_RuleID__r.Group_Rule_3__c,' +'Speciality_RuleID__r.Group_Rule_4__c,Speciality_RuleID__r.Group_Rule_5__c,Speciality_RuleID__r.Local_Requirment_Set__c,'
                               + 'Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Value__c,'
                               + 'Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.Theater__c,'
                               + 'Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,'
                               + '  VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c, Speciality_RuleID__r.any_value_Acceptable__c,' 
                               + 'AccountID__c From Velocity_Rule_Results__c v where Id IN : resultId ';
        
        List<Velocity_Rule_Results__c > listVelocityRuleResults = Database.query(ruleResultQuery);          
        //   List<Velocity_Rule_Results__c > listVelocityRuleResults = Database.query(ruleResultQuery); 
        system.debug('listVelocityRuleResults :: ' + listVelocityRuleResults );
            runBatchJob(listVelocityRuleResults);        
        }
    }

   /** ROLLUP JOB **/   
   Public Void runAccountRollupJob(){
      Id accountIds = accountId;
      List<account> acc = [select id,name,cluster__C,Specialty_Rule_Type__c,Grouping__c,Theater1__c,Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c,Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c,Velocity_Compliance_Status__c, Education_Data_Refresh_Date__c, velocity_Solution_Provider_Tier__c  from Account where id = :accountIds ];
      system.debug('ACCOUNT :: ' + acc );
      if(acc!= null){
        PRM_VPP_RuleEvaluator  prmRuleEval = new PRM_VPP_RuleEvaluator(acc);
        prmRuleEval.evaluateRollupRules(acc); 
      }
   }
    // Added by Suman.   
    public void runProfiledGroupsJob(){
        Id groupIds = groupId;
        List<account> acc = [select id,name,cluster__C,Specialty_Rule_Type__c,Grouping__c,Grouping__r.Local_Requirment_Set__c,
                             Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c,
                             Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c,
                             Velocity_Compliance_Status__c, Education_Data_Refresh_Date__c,
                             velocity_Solution_Provider_Tier__c from Account where Grouping__c = :groupIds
                             AND PROFILED_ACCOUNT_FLAG__c = true ];
        system.debug('ACCOUNT :: ' + acc );
       
        List<Id> grpIds = new List<Id>();
        for(Account accObj : acc){          
            if(accObj.Grouping__c != null){
                grpIds.add(accObj.Grouping__c);
            }          
        }
 
        List<Velocity_Rule_Results__c> listVRR1 = [SELECT id,name,AccountID__c  from 
                                                    Velocity_Rule_Results__c where Grouping__c  IN : grpIds];
        if( (listVRR1 != null) && (listVRR1.size()>0) ){
           delete listVRR1 ;
         }
      
       List<Education__c>  education = [Select e.Partner_Grouping__c, e.Partner_Grouping_ID__c, e.Name, 
                                     e.Id, e.Education_ID__c, e.Contact__c,e.Education_Master__c 
                                      From Education__c e 
                                     where e.Partner_Grouping__c IN :grpIds ] ;
        if(education != null && education.size()> 0){
            system.debug('EDUCATION :: ' + education);  
            List<Id> listeducation = new List<Id>();
           for(Education__c edu : education){
              listeducation.add(edu.Id);
           }
            PRM_VPP_VelocityRuleResultsUtils.deleteEducationAndEducationGroupMapping(listeducation);
            
            PRM_VPP_VelocityRuleResultsUtils.createEducationAndEducationGroupMapping(education);
        } 
        
        if(acc != null && acc.size() >0){
        PRM_VPP_VelocityRuleResults vRR = new  PRM_VPP_VelocityRuleResults(acc,false ) ;
        List<Velocity_Rule_Results__c>  listVRR = vRR.createVelocityRuleResults();  
        system.debug('VRR :: ' + listVRR );
        List<ID> resultId =new List<Id>();
        for(Velocity_Rule_Results__c result : listVRR ) {
           resultId.add(result .id);
      }
      
    String ruleResultQuery = 'Select Speciality_RuleID__c,Required_Value_Type__c,Rule_theater__c, RequiredCount__c,Speciality_RuleID__r.RecordType.Name ,Speciality_RuleID__r.RecordType.DeveloperName,'
                               + 'Name, Grouping__c, Current__c, Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,'
                               + 'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Cluster__c,'
                               + 'Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c,'
                               + 'Speciality_RuleID__r.Local_Requirment_Set__c,Speciality_RuleID__r.Value__c,'
                               + 'Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,'
                               + 'Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.Theater__c,'
                               + 'Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,'
                               + '  VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c, Speciality_RuleID__r.any_value_Acceptable__c,'
                               + 'AccountID__c From Velocity_Rule_Results__c v where Id IN : resultId ';
        
        List<Velocity_Rule_Results__c > listVelocityRuleResults = Database.query(ruleResultQuery);          
        //   List<Velocity_Rule_Results__c > listVelocityRuleResults = Database.query(ruleResultQuery); 
            runBatchJob(listVelocityRuleResults);        
        }
     }        

   public void runJobForTheaters(){
    PRM_JobFactory jobFactory = new PRM_JobFactory();
     if(SelectedTheatersForImmidateRun != null && SelectedTheatersForImmidateRun.size()>0){
      
        CustomSettingDataValueMap__c PRMVPPJobRunning = DataValueMap.get('PRMVPPJobRunning');  
        PRMVPPJobRunning.DataValue__c = 'true' ;
        update PRMVPPJobRunning ;
       
        List<SequencialBatchJob> SelectedTheaterVPPJobs= new List<SequencialBatchJob> ();
    
        SelectedTheaterVPPJobs.add( jobFactory.getStagingTheaterJob());
        
        SelectedTheaterVPPJobs.add( jobFactory.getEducationMasterJob());
        
        //get batch size
        Integer revenuebatchSize = 10;
        try{            
            revenuebatchSize  = Integer.valueOf(DataValueMap.get('PRM_PopulateRevenueBatch').DataValue__c);
        }catch(Exception e){
            revenuebatchSize = 10;
        } 
        if(DataValueMap.containsKey('IS_Revenue_Run') && DataValueMap.get('IS_Revenue_Run').DataValue__c =='true'){
            PRM_PopulateRevenueBatch objRevenueStagingBatch =  new PRM_PopulateRevenueBatch();
            SelectedTheaterVPPJobs.add(new SequencialBatchJob('StagingtoRevenueCalculation', objRevenueStagingBatch,revenuebatchSize));
        }
        
        for(String theater: SelectedTheatersForImmidateRun ){       
            
           if(theater=='All'){ 
               SelectedTheaterVPPJobs.addAll(jobFactory.getEducationMatchingJobs('All'));
               System.debug('After ESBI for APJ '+SelectedTheaterVPPJobs);
               SelectedTheaterVPPJobs.addAll(jobFactory.getVPPJobs('All','Country'));
               System.debug('After VPP for APJ '+SelectedTheaterVPPJobs);
               SelectedTheaterVPPJobs.addAll(jobFactory.getPartnerLevrageJobs('All'));
               System.debug('After PL for APJ '+SelectedTheaterVPPJobs);
           }
           if(theater=='APJ'){ 
               SelectedTheaterVPPJobs.addAll(jobFactory.getEducationMatchingJobs('APJ'));
               System.debug('After ESBI for APJ '+SelectedTheaterVPPJobs);
               SelectedTheaterVPPJobs.addAll(jobFactory.getVPPJobs('APJ','Country'));
               System.debug('After VPP for APJ '+SelectedTheaterVPPJobs);
               SelectedTheaterVPPJobs.addAll(jobFactory.getPartnerLevrageJobs('APJ'));
               System.debug('After PL for APJ '+SelectedTheaterVPPJobs);
           }
           if(theater=='EMEA' ){ 
               SelectedTheaterVPPJobs.addAll(jobFactory.getEducationMatchingJobs('EMEA'));
               System.debug('After ESBI for APJ '+SelectedTheaterVPPJobs);
               SelectedTheaterVPPJobs.addAll( jobFactory.getVPPJobs('EMEA','Country'));
               System.debug('After VPP for EMEA '+SelectedTheaterVPPJobs);
               SelectedTheaterVPPJobs.addAll(jobFactory.getPartnerLevrageJobs('EMEA'));
               System.debug('After PL for EMEA '+SelectedTheaterVPPJobs);
           } 
           if(theater=='Americas' ){ 
               SelectedTheaterVPPJobs.addAll(jobFactory.getEducationMatchingJobs('Americas'));
               System.debug('After ESBI for APJ '+SelectedTheaterVPPJobs);
               SelectedTheaterVPPJobs.addAll(jobFactory.getVPPJobs('Americas','Country'));
               System.debug('After VPP for EMEA '+SelectedTheaterVPPJobs);
               SelectedTheaterVPPJobs.addAll(jobFactory.getPartnerLevrageJobs('Americas'));
               System.debug('After PL for Americas '+SelectedTheaterVPPJobs);
           } 
        }
        
        Integer GAFandVelocityBatchSize = 10;
        try{            
            GAFandVelocityBatchSize  = Integer.valueOf(DataValueMap.get('PRM_CalculateGAFandVelocityFieldsBatch').DataValue__c);
        }catch(Exception e){
            GAFandVelocityBatchSize = 10;
        }
        
        if(DataValueMap.containsKey('IS_GAF_Run') && DataValueMap.get('IS_GAF_Run').DataValue__c=='true'){
            PRM_CalculateGAFandVelocityFieldsBatch objCalGafVelocity = new PRM_CalculateGAFandVelocityFieldsBatch();
            SelectedTheaterVPPJobs.add(new SequencialBatchJob('RevenueCalculation', objCalGafVelocity,GAFandVelocityBatchSize)); 
        }
        
        Integer ChampBatchSize = 10;
        try{            
            ChampBatchSize  = Integer.valueOf(DataValueMap.get('PRM_CalculateChampionsBatch').DataValue__c);
        }catch(Exception e){
            ChampBatchSize = 10;
        }
        if(DataValueMap.containsKey('IS_Campions_Run') && DataValueMap.get('IS_Campions_Run').DataValue__c =='true'){
            PRM_CalculateChampionsBatch objChampBatch =  new PRM_CalculateChampionsBatch();
            SelectedTheaterVPPJobs.add(new SequencialBatchJob('CalculateCampions', objChampBatch,ChampBatchSize));
        }
        
        integer index=0;
        for(SequencialBatchJob job :SelectedTheaterVPPJobs){
            index++;
            System.debug(index +' Jobs '+ job.getJobName() );
        }
        system.debug('Testing  1111');
        SequencialBatchJobScheduler.executeSequence(SelectedTheaterVPPJobs);
        system.debug('Testing  11111122222');
     }  
   } // End of runJobForTheaters- method.

   /** Method will check Job status **/
   public boolean checkRunningJob() {
      CustomSettingDataValueMap__c PRMVPPJobRunning = DataValueMap.get('PRMVPPJobRunning');  
      if(PRMVPPJobRunning.DataValue__c =='true'){
        isjobRunning = true ; 
      }else{
        isjobRunning = false ;
      }
      return isjobRunning ;
   } // End of checkRunningJob- method.
   
     public void runPANLogicalJobForTheaters(){
        if(SelectedTheatersForImmidateRun != null && SelectedTheatersForImmidateRun.size()>0){
            CustomSettingDataValueMap__c PRMJobRunning = DataValueMap.get('PRMVPPJobRunning');  
            PRMJobRunning.DataValue__c = 'true' ;
            update PRMJobRunning;
            List<SequencialBatchJob> SelectedTheaterPANLogicalJobs= new List<SequencialBatchJob> ();
            
            Integer batchSize = 200;
            //get batch size
            try{            
                batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_EducationEduMasterGroupJob').DataValue__c);
            }catch(Exception e){
                batchSize = 20;
            }                    
            for(String theater: SelectedTheatersForImmidateRun ){                        
                if(theater=='APJ'){                 
                    SelectedTheaterPANLogicalJobs.addAll(schedulePANandLogicalBlockJobs('APJ'));               
                }
                if(theater=='EMEA' ){ 
                    SelectedTheaterPANLogicalJobs.addAll(schedulePANandLogicalBlockJobs('EMEA'));               
                } 
                if(theater=='Americas' ){ 
                    SelectedTheaterPANLogicalJobs.addAll(schedulePANandLogicalBlockJobs('Americas'));  
                } 
            }           
            SequencialBatchJobScheduler.executeSequence(SelectedTheaterPANLogicalJobs);
        }
    }
   
   public List<SequencialBatchJob> scheduleVPPJobs(String Theater) {
    List<SequencialBatchJob>Jobs = new List<SequencialBatchJob>(); 
    integer batchSize; 
      
       /* 
        String DeleteResultsQuery ='select Id from Education_EducationGroup_Mapping__c where  Theater__c = \''+Theater+'\' and createddate <'+ new PRM_CommonUtils().getQueryFormattedDate(System.now());
        //database.Query(DeleteResultsQuery);
        System.debug('DeleteResultsQuery '+DeleteResultsQuery);

        PRM_VPP_DeleteRecordsJob Job1= new PRM_VPP_DeleteRecordsJob(DeleteResultsQuery);
        Jobs.add(new SequencialBatchJob('Delete Education and Education Group Mappings for'+Theater,Job1,200)); 
       */
        
        String ruleResultQuery = 'Select e.Batch_Job_Operation__c, e.Id,Education_Master__c '
                                       + 'from Education__c e  where Theater__c = \''+Theater+'\'';
        System.debug('ruleResultQuery '+ruleResultQuery);
        PRM_VPP_EducationEduationMasterGroupJob job2= new PRM_VPP_EducationEduationMasterGroupJob(ruleResultQuery);
        //get batch size
        try{            
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_EducationEduMasterGroupJob').DataValue__c);
        }catch(Exception e){
            batchSize = 20;
        } 
        Jobs.add(new SequencialBatchJob('Build Education and Education Group Mappings '+Theater,Job2,200));                                        
        
        
        String DeleteVelocityRuleResultsQuery='select Id,Grouping__c,Grouping__r.RecordType.DeveloperName from Velocity_Rule_Results__c' 
                                            +'where Grouping__r.RecordType.DeveloperName = \'Partner_Grouping\' and Account_Theater__c =\''+Theater+'\' and createddate <'
                                            + new PRM_CommonUtils().getQueryFormattedDate(System.now()) ; 
        System.debug('DeleteVelocityRuleResultsQuery '+DeleteVelocityRuleResultsQuery);
        
        PRM_VPP_DeleteRecordsJob job3= new PRM_VPP_DeleteRecordsJob(DeleteVelocityRuleResultsQuery);
        Jobs.add(new SequencialBatchJob('Delete VelocityRuleResults '+Theater,Job3,200));  
        
        
        String ruleResultQuery1 = 'Select Id, Grouping__c,Batch_Job_Operation__c,Specialty_Rule_Type__c,Cluster__c,Velocity_Solution_Provider_Tier__c, '
                                       +' Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c,Consolidate_Compliance_Status__c, '
                                       + 'Grouping__r.Local_Requirment_Set__c, '
                                       +' Governance_and_Archive_Compliance_Status__c,Velocity_Compliance_Status__c, Education_Data_Refresh_Date__c,Deployed_Velocity_Services__c ' 
                                       + ' from Account e where velocity_Solution_Provider_Tier__c!=\'\' and profiled_Account_flag__c=true and Grouping__c!=null and Theater1__c =\''+Theater+'\'';
        System.debug('ruleResultQuery1 '+ruleResultQuery1);
        PRM_VPP_VelocityRuleResultJob1 job4 = new PRM_VPP_VelocityRuleResultJob1(ruleResultQuery1);
        //get batch size
        try{            
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleResultJob1').DataValue__c);
        }catch(Exception e){
            batchSize = 20;
        } 
        Jobs.add(new SequencialBatchJob('BuildVelocityRuleResults '+Theater,Job4,batchSize)); 

        String ruleResultQuery2 = 'Select Revenue_Amount__c, Required_value_Type__c,v.Speciality_RuleID__c, v.Rule_theater__c,Grouping__r.Local_Requirment_Set__c, '
                                            +'v.RequiredCount__c,Speciality_RuleID__r.RecordType.Name,Speciality_RuleID__r.Local_Requirment_Set__c, '
                                            +'Speciality_RuleID__r.RecordType.DeveloperName, v.Name, v.Grouping__c,Grouping__r.RecordType.DeveloperName,v.Current__c, '
                                            +'v.Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c, '
                                            +'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, '
                                            +'Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Group_Rule_3__c, '
                                            +'Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c, '
                                            +'Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.BR_Sub_category__c, '
                                            +'Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Required_Type__c, '
                                            +'Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,'
                                            +'Speciality_RuleID__r.Theater__c,Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Value__c, '
                                            +'Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c, '
                                            + 'VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c, Speciality_RuleID__r.any_value_Acceptable__c,'
                                            +'Speciality_RuleID__r.Name,v.AccountID__c From Velocity_Rule_Results__c v  where '
                                            +'v.Grouping__r.RecordType.DeveloperName = \'Partner_Grouping\' AND Account_Theater__c= \''+Theater+'\' ORDER BY Grouping__c ';
        System.debug('ruleResultQuery2 '+ruleResultQuery2);                                 
        PRM_VPP_VelocityRuleEvaluatorJob job5 = new PRM_VPP_VelocityRuleEvaluatorJob(ruleResultQuery2);
        //get batch size
        try{            
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleEvaluatorJob').DataValue__c);
        }catch(Exception e){
            batchSize = 20;
        } 
        
        Jobs.add(new SequencialBatchJob('Evaluate Velocity Rules '+Theater,Job5,batchSize));   
                                            
        String ruleResultQuery3 = 'Select a.PROFILED_ACCOUNT_FLAG__c, a.Name, Theater1__c, a.Id, a.Grouping__c,velocity_Solution_Provider_Tier__c, '
                                            +'Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c, '
                                            +'Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c, Deployed_Velocity_Services__c, '
                                            +'Velocity_Compliance_Status__c , Education_Data_Refresh_Date__c From Account a '
                                            +'where profiled_Account_flag__c=true and Grouping__c!=null and Theater1__c=\''+Theater+'\'';
        System.debug('ruleResultQuery3 '+ruleResultQuery3);                                 
        PRM_VPP_RollupRuleEvaluatorJob job6 = new PRM_VPP_RollupRuleEvaluatorJob(ruleResultQuery3);        
        //get batch size
        try{            
            batchSize  = Integer.valueOf(DataValueMap.get('RollupEvaluationBatchSize').DataValue__c);
        }catch(Exception e){
            batchSize = 20;
        } 
        Jobs.add(new SequencialBatchJob('Evaluate Rollup Rules '+Theater,Job6,batchSize )); 
        
    
    return Jobs;
   }
   
  
   
    
   
   // Revenue Logic
    public String SearchCriteriaRevenue{get; set;}
    public string inputRevenuestr {get;set;}
    
    public List<SelectOption> getSearchCriteriaForRevenueList() 
    {     
        List<SelectOption> options2 = new List<SelectOption>();  
        //options2.add(new SelectOption('Grouping ID','Grouping ID'));
        //options2.add(new SelectOption('Contact Id','Contact ID'));     
        options2.add(new SelectOption('Account Id','Account ID'));                
        return options2;  
    } 
    
    public void runRevenueJobs(){
                
        Id ContactAccountId ;
        Set<Id> groupingIds = new Set<Id>();
        Id profileAccountId;
        decimal BatchId;
    
        if(SearchCriteriaRevenue =='Account ID'){ 
            try{
                profileAccountId = inputRevenuestr;
            } catch(Exception ex){
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide valid account Id');
                ApexPages.addMessage(errorMessage);
                return;
            }       
            
            map<string,CustomSettingDataValueMap__c> mapCustomSetting = CustomSettingDataValueMap__c.getall();
            BatchId = mapCustomSetting.get('Batch Id').DateValue__c;
            
            if(inputRevenuestr != null && inputRevenuestr !='' && inputRevenuestr.length() >14 && inputRevenuestr.startsWith('001')){
                list<Account_Groupings__c> lstAccountgrouping = [Select Profiled_Account__c,Id__c from Account_Groupings__c where Profiled_Account__c =:profileAccountId];
                if(lstAccountgrouping  != null && lstAccountgrouping.size()>0){  
                    List<Staging_Data__c> lstStaging = [select Batch_Id__c,Text1__c,Text2__c,Text3__c,Text4__c,Text5__c,Text6__c,Text7__c,Text8__c,Text9__c,Text10__c,Object_Name__c
                                                        from Staging_Data__c where Object_Name__c = 'Revenue' and Batch_Id__c =:BatchId and Text1__c =: lstAccountgrouping[0].Id__c];
                    
                    if(lstStaging != null && lstStaging.size()>0){            
                        PRM_RevenueGAFVROperations objRevenueStaging =  new PRM_RevenueGAFVROperations();
                        objRevenueStaging.insertUpdateRevenue(lstStaging);
                    }else{
                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error,Label.Revenue_Error_Message);
                        ApexPages.addMessage(errorMessage);
                        return;
                    }                     
                }                
                   
            } 
            
            
            if(inputRevenuestr != null && inputRevenuestr !='' && inputRevenuestr.length() >14 && inputRevenuestr.startsWith('001')){
                 
                System.debug('#### am in here');            
                List<Account> lstAccount = [select Id,PROFILED_ACCOUNT_FLAG__c,velocity_Solution_Provider_Tier__c from account where PROFILED_ACCOUNT_FLAG__c = true and Id =: profileAccountId];
                PRM_RevenueGAFVROperations objCalGafVelocity = new PRM_RevenueGAFVROperations();
                objCalGafVelocity.calculateRevenueForAccount(lstAccount);                
                
            }else{
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide valid account Id');
                ApexPages.addMessage(errorMessage);
                return;
            }
        }   
    }
    
    public void runJobForALLRevenue(){
        List<SequencialBatchJob> SelectedRevenueJobs= new List<SequencialBatchJob> ();
        PRM_PopulateRevenueBatch objRevenueStagingBatch =  new PRM_PopulateRevenueBatch();
        Integer revenuebatchSize = 10;
        try{            
            revenuebatchSize  = Integer.valueOf(DataValueMap.get('PRM_PopulateRevenueBatch').DataValue__c);
        }catch(Exception e){
            revenuebatchSize = 10;
        } 
        Integer GAFandVelocityBatchSize = 10;
        try{            
            GAFandVelocityBatchSize  = Integer.valueOf(DataValueMap.get('PRM_CalculateGAFandVelocityFieldsBatch').DataValue__c);
        }catch(Exception e){
            GAFandVelocityBatchSize = 10;
        }
        SelectedRevenueJobs.add(new SequencialBatchJob('StagingtoRevenueCalculation', objRevenueStagingBatch,revenuebatchSize));
        
        PRM_CalculateGAFandVelocityFieldsBatch objCalGafVelocity = new PRM_CalculateGAFandVelocityFieldsBatch();
        SelectedRevenueJobs.add(new SequencialBatchJob('RevenueCalculation', objCalGafVelocity,GAFandVelocityBatchSize)); 
        
        SequencialBatchJobScheduler.executeSequence(SelectedRevenueJobs);
    }

 // Champion Resource Logic
    public String SearchCriteriaCR{get; set;}
    public string inputProfiledAccountstr {get;set;}
    
    public List<SelectOption> getSearchCriteriaForCRList() 
    {     
        List<SelectOption> options5 = new List<SelectOption>();  
        //options2.add(new SelectOption('Grouping ID','Grouping ID'));
        //options2.add(new SelectOption('Contact Id','Contact ID'));     
        options5.add(new SelectOption('Account Id','Account ID'));                
        return options5;  
    } 
    
    public List<SelectOption> getJobChampOperations(){
        List<SelectOption> options2 = new List<SelectOption>();
        options2.add(new SelectOption('RunAllJob','Evaluate Champion Resources for All Accounts'));
        //options2.add(new SelectOption('Delete Education and Education Group Mappings','2. Delete Education and Education Group Mappings'));  
        //options2.add(new SelectOption('Build Education and Education Group Mappings','3. Build Education and Education Group Mappings'));     
        //options2.add(new SelectOption('Evaluate Partner Lev factor','4. Evaluate Partner Lev factor'));
        

        return options2;
    }
    
    public void runChampionResourceJob(){
      List<Account> accountList = new List<Account>();
      List<Contact> contactList ;
      Account profiledAccount ; 
      Id profileAccountId; 
      try{
            profileAccountId = inputProfiledAccountstr;
            accountList = [SELECT id,name,velocity_Solution_Provider_Tier__c FROM Account where  Profiled_Account__c= : profileAccountId ];
            if(accountList != null && accountList.size() <1) {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide valid profile account Id');
                ApexPages.addMessage(errorMessage);
                return;
            } 
        } catch(Exception ex){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide valid profile account Id');
            ApexPages.addMessage(errorMessage);
            return;
        }       
      if(inputProfiledAccountstr != Null){
         accountList = [SELECT id,name,Account_Grouping__r.Profiled_Account__c, Grouping__c,
                               Advanced_Consolidate_Champion_Resources__c,Consolidate_Champion_Resources__c,Backup_Champion_Resources__c,
                               Governance_Archive_Champion_Resources__c, velocity_Solution_Provider_Tier__c,
                               (SELECT Id,Advanced_Consolidate_Champion__c,Consolidate_Champion__c,Backup_Champion__c,
                                       Governance_Archive_Champion__c FROM Contacts where Active__c = true)       
                                     FROM Account where  Profiled_Account__c= : inputProfiledAccountstr
                                     OR Id =: inputProfiledAccountstr order by Profiled_Account__c ASC ];                  
      }
     if(accountList.size()>0)
     {
      profiledAccount = accountList[0] ;
      system.debug('ProfiledAccount -- '+ profiledAccount.Id);       
      Integer AdvancedConsolidateCount = 0;
      Integer ConsolidateCount = 0;
      Integer BackupCount = 0;
      Integer GovernanceArchiveCount = 0;             
      for(Account acc : accountList){
          if(acc.contacts != null && acc.contacts.size()>0 ){
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
             }
          }
      } // End of for loop.
      profiledAccount.Advanced_Consolidate_Champion_Resources__c = AdvancedConsolidateCount;
      profiledAccount.Consolidate_Champion_Resources__c = ConsolidateCount;
      profiledAccount.Backup_Champion_Resources__c = BackupCount;
      profiledAccount.Governance_Archive_Champion_Resources__c =GovernanceArchiveCount;

      update profiledAccount ;
     } // End of if condition.
    
    } // End of method - runChampionResourceJob.
    
    public void runChampJobForALLAccount(){
        List<SequencialBatchJob> SelectedRevenueJobs= new List<SequencialBatchJob> ();
        PRM_CalculateChampionsBatch objChampBatch =  new PRM_CalculateChampionsBatch();
        SelectedRevenueJobs.add(new SequencialBatchJob('CalculateCampions', objChampBatch,10));
        SequencialBatchJobScheduler.executeSequence(SelectedRevenueJobs);
    }
     // Functional Area logic
    public String SearchCriteriaFA{get; set;}
    public string inputProfiledAccountFAstr {get;set;}
    
    public List<SelectOption> getSearchCriteriaFAList() 
    {     
        List<SelectOption> options7 = new List<SelectOption>(); 
        options7.add(new SelectOption('Account Id','Account ID'));      
        return options7;                   
         
    } 
    
    public List<SelectOption> getFunctionalAreaOperationsList(){
        List<SelectOption> options8 = new List<SelectOption>();
        options8.add(new SelectOption('RunAllJob','Evaluate Functional Area For All Partner Contacts'));
        return options8;
    }
    
    public void runFunctionalAreaJob(){
      List<Account> accountList = new List<Account>();
      List<Contact> contactList = new list<contact>() ;
      List<Contact> contactListToUpdate = new list<contact>() ;
      Account profiledAccount ; 
      Id profileAccountId; 
      try{
            profileAccountId = inputProfiledAccountFAstr;
            accountList = [SELECT id,name FROM Account where  Profiled_Account__c= : profileAccountId ];
            if(accountList != null && accountList.size() <1) {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide valid profile account Id');
                ApexPages.addMessage(errorMessage);
                return;
            } 
        } catch(Exception ex){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide valid profile account Id');
            ApexPages.addMessage(errorMessage);
            return;
        }         
         String query = 'select id,name,Account_Theater__c,functional_Area__c,functional_Area1__c,partner_se__c,accountid '
                         + 'from contact where Active__c = true and account.IsPartner=true and Accountid=\''+inputProfiledAccountFAstr+'\'';
         PRM_Contact_Functional_Area_UpdateBatch contactBatch = new PRM_Contact_Functional_Area_UpdateBatch(query);        
         database.executebatch(contactBatch,10);
              
    } 
    
    public void runFunctionalAreaJobForAllAccounts(){       
        String query = 'select id,name,Account_Theater__c,functional_Area__c,functional_Area1__c,partner_se__c,accountid, Account.Profiled_Account__c,Account.PROFILED_ACCOUNT_FLAG__c from contact where Active__c = true and account.IsPartner=true order by account_theater__c';
        PRM_Contact_Functional_Area_UpdateBatch contactBatch = new PRM_Contact_Functional_Area_UpdateBatch(query);      
        database.executebatch(contactBatch,10);
           
    }
    /*public void deleteCreateEvaluateVRRForPAN(){
        if(strGroupingId != NULL && strGroupingId != '' && strGroupingId.startsWith('a0F')){
        //----------------------DELETE Velocity Rule Results related to all grouping under PAN/Logical Block as well as 
        //                      DELETE Velocity Rule Results wrt PAN/Logical Block----------------------------
            Account_Groupings__c AccountGrouping = new Account_Groupings__c();
            try{
                AccountGrouping = [Select Id,RecordTypeId,RecordType.DeveloperName,Active__c,Target_Tier__c,Cluster__c,Local_Requirment_Set__c,Speciality_Type__c
                                   from Account_Groupings__c where Id =: strGroupingId and Active__c = true]; 
            }catch(exception e){
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, 'There is no active grouping with this Id.Please provide valid grouping Id');
                ApexPages.addMessage(errorMessage);
                return;
            }       
            PRM_PAN_VPP_VelocityRuleResultsUtils PANVelocityRuleResultsUtils = new PRM_PAN_VPP_VelocityRuleResultsUtils();
            Map<Id,List<Account_Groupings__c>> mapPANLBLevelGrouping = new Map<Id,List<Account_Groupings__c>>();
            Map<Id,List<Account_Groupings__c>> mapPANAndLogicalBlock = new Map<Id,List<Account_Groupings__c>>();
            list<Account> lstAccount = new list<Account>();
            list<Id> lstPABOrLBGroupingId = new list<Id>();
            lstPABOrLBGroupingId.add(AccountGrouping.Id);
            list<Id> lstAccountGroupingId = new list<Id>();
            list<Id> lstGroupingToCreateVRR = new list<Id>();
            list<Account_Groupings__c> lstLogicalBlockForPAN = new list<Account_Groupings__c>();
            integer sizeOfGrouping;
            list<Account_Groupings__c> lstAccountGrouping = new list<Account_Groupings__c>();
            if(AccountGrouping.RecordType.DeveloperName == 'Partner_Grouping_PAN_Theater'){
                //mapPANLBLevelGrouping = PANVelocityRuleResultsUtils.getGroupingsUnderPANLevel(lstPABOrLBGroupingId);
                mapPANAndLogicalBlock = PANVelocityRuleResultsUtils.getLogicalBlockUnderPAN(lstPABOrLBGroupingId);
            }
            if(AccountGrouping.RecordType.DeveloperName == 'Partner_Grouping_Logical_Block'){
                //mapPANLBLevelGrouping = PANVelocityRuleResultsUtils.getGroupingsUnderLogicalBlock(lstPABOrLBGroupingId);
            }
            system.debug('mapPANAndLogicalBlock --------->' +mapPANAndLogicalBlock );
            //if(!mapPANLBLevelGrouping.isEmpty()){
                //for(Id PANOrLBId: mapPANLBLevelGrouping.keyset()){ 
                    //lstAccountGrouping = mapPANLBLevelGrouping.get(PANOrLBId);
                    //sizeOfGrouping = mapPANLBLevelGrouping.get(PANOrLBId).size();
                    if(AccountGrouping.RecordType.DeveloperName == 'Partner_Grouping_PAN_Theater'){
                        if(!mapPANAndLogicalBlock.isEmpty()){
                            for(Id PANId: mapPANAndLogicalBlock.keyset()){
                                if(mapPANAndLogicalBlock.get(PANId) != null && mapPANAndLogicalBlock.get(PANId).size()>0){
                                    lstLogicalBlockForPAN.addAll(mapPANAndLogicalBlock.get(PANId));
                                    lstAccountGrouping.addAll(mapPANAndLogicalBlock.get(PANId));
                                }
                            }
                        }
                    }
                    lstAccountGrouping.add(AccountGrouping);
                    //break;
                //}
            //}
            if(lstAccountGrouping.size()>0){
                for(integer index = 0;index<lstAccountGrouping.size();index++){
                    if(index < sizeOfGrouping){
                        lstGroupingToCreateVRR.add(lstAccountGrouping[index].Id);
                    }
                    lstAccountGroupingId.add(lstAccountGrouping[index].Id);
                }
            }
            if(lstAccountGroupingId.size()>0){
                List<Velocity_Rule_Results__c> listVRRToDelete = new List<Velocity_Rule_Results__c>();
                listVRRToDelete  = [SELECT id,name,AccountID__c from Velocity_Rule_Results__c where Grouping__c  IN : lstAccountGroupingId];
                if( (listVRRToDelete != null) && (listVRRToDelete.size()>0) ){
                   delete listVRRToDelete ;
                }
            }
            /*if(lstGroupingToCreateVRR.size()>0){
                
                //----------------------CREATE Velocity Rule Results related to all grouping under PAN/Logical Block----------------------------
                lstAccount = [Select id,name,cluster__C,Specialty_Rule_Type__c,Grouping__c,Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c,
                              Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c,Velocity_Compliance_Status__c, Education_Data_Refresh_Date__c,
                              velocity_Solution_Provider_Tier__c from Account where Grouping__c = :lstGroupingToCreateVRR AND PROFILED_ACCOUNT_FLAG__c = true ]; 
                if(lstAccount.size()>0){
                    PRM_VPP_VelocityRuleResults VPPVelocityRuleResults = new PRM_VPP_VelocityRuleResults(lstAccount) ;
                    List<Velocity_Rule_Results__c> listVRRToCreate = VPPVelocityRuleResults.createVelocityRuleResults();
                    
                //----------------------EVALUATE Velocity Rule Results related to all grouping under PAN/Logical Block----------------------------
                    if(listVRRToCreate.size()>0){
                        List<ID> lstInsertedVelocityRuleResult =new List<Id>();
                        for(Velocity_Rule_Results__c velocityRuleResult : listVRRToCreate) {
                           lstInsertedVelocityRuleResult.add(velocityRuleResult.id);
                        }
                      
                        String ruleResultQuery = 'Select Speciality_RuleID__c,Required_Value_Type__c,Rule_theater__c, RequiredCount__c,Speciality_RuleID__r.RecordType.Name ,Speciality_RuleID__r.RecordType.DeveloperName,'
                                               + 'Name, Grouping__c, Current__c, Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,'
                                               + 'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Cluster__c,'
                                               + 'Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c, '
                                               + 'Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Any_Value_Acceptable__c,Speciality_RuleID__r.Value__c,'
                                               + 'Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.Theater__c,'
                                               + 'Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,'
                                               + '  VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c, '
                                               + 'AccountID__c From Velocity_Rule_Results__c v where Id IN : lstInsertedVelocityRuleResult ';
                        
                        List<Velocity_Rule_Results__c > listVelocityRuleResults = new list<Velocity_Rule_Results__c>();
                        listVelocityRuleResults = [Select Speciality_RuleID__c,Required_Value_Type__c,Rule_theater__c, RequiredCount__c,Speciality_RuleID__r.RecordType.Name ,Speciality_RuleID__r.RecordType.DeveloperName,
                                                    Name, Grouping__c, Current__c, Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,
                                                    Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Cluster__c,
                                                    Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c,
                                                    Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Any_Value_Acceptable__c,Speciality_RuleID__r.Value__c,
                                                    Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.Theater__c,
                                                    Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,
                                                    VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c,
                                                    AccountID__c From Velocity_Rule_Results__c v where Id IN : lstInsertedVelocityRuleResult];
                        System.Debug('listVelocityRuleResults --->' +listVelocityRuleResults );
                        PRM_VPP_RuleEvaluator objRuleEvaluator = new PRM_VPP_RuleEvaluator(listVelocityRuleResults);
                        objRuleEvaluator.evaluateVelocityRule(listVelocityRuleResults);       
                    }
                }
            }
            
            //-------------------------CREATE/EVALUATE Velocity Rule Results records related to PAN/Logical Block grouping--------------------------------------
            PRM_PAN_VPP_RuleEvaluator PANRuleEvaluator = new PRM_PAN_VPP_RuleEvaluator();
            PRM_PAN_VPP_VelocityRuleResults PANVelocityRuleResults = new PRM_PAN_VPP_VelocityRuleResults();
            list<Account_Groupings__c> lstGrouping = new list<Account_Groupings__c>();
            lstGrouping.add(AccountGrouping); 
            if(AccountGrouping.RecordType.DeveloperName == 'Partner_Grouping_Logical_Block'){               
                List<Velocity_Rule_Results__c> lstLogicalBlockRuleResults = PANVelocityRuleResults.createLogicalBlockVelocityRuleResults(lstGrouping);
                System.Debug('lstLogicalBlockRuleResults--------->'+lstLogicalBlockRuleResults);
                if(lstLogicalBlockRuleResults != null && lstLogicalBlockRuleResults.size()>0){
                        PANRuleEvaluator.evaluateLogicalBlockVelocityRules(lstLogicalBlockRuleResults);
                }
            }
            if(AccountGrouping.RecordType.DeveloperName == 'Partner_Grouping_PAN_Theater'){
                if(lstLogicalBlockForPAN.size()>0){                    
                   List<Velocity_Rule_Results__c> lstLogicalBlockRuleResults = PANVelocityRuleResults.createLogicalBlockVelocityRuleResults(lstLogicalBlockForPAN);
                   System.Debug('lstLogicalBlockRuleResults------>'+lstLogicalBlockRuleResults);
                   if(lstLogicalBlockRuleResults != null && lstLogicalBlockRuleResults.size()>0){
                        PANRuleEvaluator.evaluateLogicalBlockVelocityRules(lstLogicalBlockRuleResults);
                   }
                }               
                List<Velocity_Rule_Results__c> lstPANTheaterRuleResults = PANVelocityRuleResults.createPANLevelVelocityRuleResults(lstGrouping);
                System.Debug('lstPANTheaterRuleResults---->'+lstPANTheaterRuleResults);
                if(lstPANTheaterRuleResults != null && lstPANTheaterRuleResults.size()>0){
                    PANRuleEvaluator.evaluatePANTheaterVelocityRules(lstPANTheaterRuleResults);
                }
            }
        }else{
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide valid grouping Id');
            ApexPages.addMessage(errorMessage);
            return;
        }
    }*/
    
     public void deleteCreateEvaluateVRRForPAN(){
        PRM_PAN_VPP_RuleEvaluator PANRuleEvaluator = new PRM_PAN_VPP_RuleEvaluator();
        PRM_PAN_VPP_VelocityRuleResults PANVelocityRuleResults = new PRM_PAN_VPP_VelocityRuleResults();
        PRM_PAN_VPP_VelocityRuleResultsUtils PANVelocityRuleResultsUtils = new PRM_PAN_VPP_VelocityRuleResultsUtils();
        if(strGroupingId != NULL && strGroupingId != '' && strGroupingId.startsWith('a0F')){        
            Account_Groupings__c AccountGrouping = new Account_Groupings__c();
            try{
                AccountGrouping = [Select Id,RecordTypeId,Theater2__c,RecordType.DeveloperName,Active__c,Target_Tier__c,Cluster__c,Local_Requirment_Set__c,Speciality_Type__c
                                   from Account_Groupings__c where Id =: strGroupingId and Active__c = true]; 
            }catch(exception e){
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, 'There is no active grouping with this Id.Please provide valid grouping Id');
                ApexPages.addMessage(errorMessage);
                return;
            }           
            list<Account_Groupings__c> lstPABOrLBGroupingId = new list<Account_Groupings__c>();
            List<Velocity_Rule_Results__c> lstGroupingVRR = new List<Velocity_Rule_Results__c>();
            List<Velocity_Rule_Results__c> lstPANorLBVRR = new List<Velocity_Rule_Results__c>();
            List<Velocity_Rule_Results__c> lstLogicalBlockRuleResults = new List<Velocity_Rule_Results__c>();
            Set<Id> setCountryGroupingIds = new Set<Id>();
            Set<Id> setProfileAccountIds = new Set<Id>();
            
            lstPABOrLBGroupingId.add(AccountGrouping);
            Map<Id,List<Velocity_Rules__c>> mapPANLBLevelRules = new Map<Id,List<Velocity_Rules__c>>();
            List<Velocity_Rules__c> lstVelocityRules = new List<Velocity_Rules__c>();
            if(AccountGrouping.RecordType.DeveloperName == 'Partner_Grouping_PAN_Theater'){
                mapPANLBLevelRules = PANVelocityRuleResultsUtils.getPANLevelRules(lstPABOrLBGroupingId);
                if(mapPANLBLevelRules.containsKey(AccountGrouping.Id)){
                    lstVelocityRules =  mapPANLBLevelRules.get(AccountGrouping.Id);
                } 
                
            }
            if(AccountGrouping.RecordType.DeveloperName == 'Partner_Grouping_Logical_Block'){
                mapPANLBLevelRules = PANVelocityRuleResultsUtils.getLogicalBlockLevelRules(lstPABOrLBGroupingId);
                if(mapPANLBLevelRules.containsKey(AccountGrouping.Id)){
                    lstVelocityRules =  mapPANLBLevelRules.get(AccountGrouping.Id);
                } 
                
            }
            if(lstVelocityRules.size()>0){
                List<Velocity_Rule_Results__c> listVRRToDelete = new List<Velocity_Rule_Results__c>();
                listVRRToDelete  = [SELECT id,name,AccountID__c from Velocity_Rule_Results__c where Speciality_RuleID__c  IN : lstVelocityRules and (Grouping__c in :lstPABOrLBGroupingId 
                                    or Grouping__r.Logical_Block_Level_Grouping__c in:lstPABOrLBGroupingId or Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c in :lstPABOrLBGroupingId)];
                if( (listVRRToDelete != null) && (listVRRToDelete.size()>0) ){
                   delete listVRRToDelete ;
                }
            } 
            
            //-------------------------CREATE/EVALUATE Velocity Rule Results records related to PAN/Logical Block grouping--------------------------------------           
            if(AccountGrouping.RecordType.DeveloperName == 'Partner_Grouping_Logical_Block'){               
                List<Velocity_Rule_Results__c> lstRuleResults = PANVelocityRuleResults.createLogicalBlockVelocityRuleResults(lstPABOrLBGroupingId);
                for(Velocity_Rule_Results__c VRRObj :lstRuleResults){
                    if(VRRObj.Grouping__r.RecordType.DeveloperName=='Partner_Grouping'){
                       lstGroupingVRR.add(VRRObj);
                       setCountryGroupingIds.add(VRRObj.Grouping__c);
                       setProfileAccountIds.add(VRRObj.AccountID__c);
                    }else{
                       lstPANorLBVRR.add(VRRObj);
                    }
                }
                
                //--------------------Create Education group mapping record ---------------------------------------------------//
                List<Education__c>  lstEducation = [Select e.Partner_Grouping__c, e.Partner_Grouping_ID__c, e.Name, 
                                         e.Id, e.Education_ID__c, e.Contact__c,e.Education_Master__c 
                                          From Education__c e 
                                         where e.Partner_Grouping__c IN :setCountryGroupingIds ] ;
                if(lstEducation != null && lstEducation.size()> 0){
                    system.debug('EDUCATION :: ' + lstEducation); 
                    List<Id> educationIds = new List<Id>();
                    for(Education__c edu : lstEducation){
                        educationIds.add(edu.Id);
                    }
                    PRM_VPP_VelocityRuleResultsUtils.deleteEducationAndEducationGroupMapping(educationIds);
                    PRM_VPP_VelocityRuleResultsUtils.createEducationAndEducationGroupMapping(lstEducation);
                }
                //-------------------------------------------------------------------------------------------------------------//
            
                //--------------------Calculate Grouping Rules ----------------------------------------------------------------//
                if(lstGroupingVRR != null && lstGroupingVRR.size()>0){
                    PRM_VPP_RuleEvaluator objRuleEvaluator = new PRM_VPP_RuleEvaluator(lstGroupingVRR);        
                    objRuleEvaluator.evaluateVelocityRule(lstGroupingVRR);                        
                }
                //-------------------------------------------------------------------------------------------------------------//
                
                //--------------------Calculate Rollup Rules -------------------------------------------------------------------//
                List<account> lstAccount = [select id,name,cluster__C,Specialty_Rule_Type__c,Grouping__c,Theater1__c,Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c,Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c,Velocity_Compliance_Status__c, Education_Data_Refresh_Date__c, velocity_Solution_Provider_Tier__c  from Account where id = :setProfileAccountIds ];
                system.debug('ACCOUNT :: ' + lstAccount );
                if(lstAccount != null){
                    PRM_VPP_RuleEvaluator  prmRuleEval = new PRM_VPP_RuleEvaluator(lstAccount);
                    prmRuleEval.evaluateRollupRules(lstAccount); 
                }
                //--------------------------------------------------------------------------------------------------------------//
                
                //--------------------Calculate Logical Block Rules -----------------------------------------------------------//
                if(lstPANorLBVRR != null && lstPANorLBVRR.size()>0){
                    PANRuleEvaluator.evaluateLogicalBlockVelocityRulesUsingRule(lstPANorLBVRR);
                  }
                //-------------------------------------------------------------------------------------------------------------//
            }
            if(AccountGrouping.RecordType.DeveloperName == 'Partner_Grouping_PAN_Theater'){                              
                List<Velocity_Rule_Results__c> lstRuleResults = PANVelocityRuleResults.createPANLevelVelocityRuleResults(lstPABOrLBGroupingId);
                for(Velocity_Rule_Results__c VRRObj :lstRuleResults){
                    if(VRRObj.Grouping__r.RecordType.DeveloperName=='Partner_Grouping'){
                       lstGroupingVRR.add(VRRObj);
                       setCountryGroupingIds.add(VRRObj.Grouping__c);
                       setProfileAccountIds.add(VRRObj.AccountID__c);
                    }else{
                       lstPANorLBVRR.add(VRRObj);
                    }
                }
                
                //--------------------Create Education group mapping record ---------------------------------------------------//
                List<Education__c>  lstEducation = [Select e.Partner_Grouping__c, e.Partner_Grouping_ID__c, e.Name, 
                                         e.Id, e.Education_ID__c, e.Contact__c,e.Education_Master__c 
                                          From Education__c e 
                                         where e.Partner_Grouping__c IN :setCountryGroupingIds ] ;
                if(lstEducation != null && lstEducation.size()> 0){
                    system.debug('EDUCATION :: ' + lstEducation); 
                    List<Id> educationIds = new List<Id>();
                    for(Education__c edu : lstEducation){
                        educationIds.add(edu.Id);
                    }
                    PRM_VPP_VelocityRuleResultsUtils.deleteEducationAndEducationGroupMapping(educationIds);
                    PRM_VPP_VelocityRuleResultsUtils.createEducationAndEducationGroupMapping(lstEducation);
                }
                //-------------------------------------------------------------------------------------------------------------//
                
                //--------------------Calculate Grouping Rules ----------------------------------------------------------------//
                if(lstGroupingVRR != null && lstGroupingVRR.size()>0){
                    PRM_VPP_RuleEvaluator objRuleEvaluator = new PRM_VPP_RuleEvaluator(lstGroupingVRR);        
                    objRuleEvaluator.evaluateVelocityRule(lstGroupingVRR);                        
                }
                //--------------------------------------------------------------------------------------------------------------//
                
                //--------------------Calculate Rollup Rules -------------------------------------------------------------------//
                List<account> lstAccount = [select id,name,cluster__C,Specialty_Rule_Type__c,Grouping__c,Theater1__c,Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c,Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c,Velocity_Compliance_Status__c, Education_Data_Refresh_Date__c, velocity_Solution_Provider_Tier__c  from Account where id = :setProfileAccountIds ];
                system.debug('ACCOUNT :: ' + lstAccount );
                if(lstAccount != null){
                    PRM_VPP_RuleEvaluator  prmRuleEval = new PRM_VPP_RuleEvaluator(lstAccount);
                    prmRuleEval.evaluateRollupRules(lstAccount); 
                }
                //--------------------------------------------------------------------------------------------------------------//
                
                
                //--------------------Calculate Pan Rule Rules -------------------------------------------------------------------//
                if(lstPANorLBVRR != null && lstPANorLBVRR.size()>0){
                    PANRuleEvaluator.evaluatePanVelocityRulesUsingRule(lstPANorLBVRR);
                }   
                //--------------------------------------------------------------------------------------------------------------//             
            }
        }else{
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide valid grouping Id');
            ApexPages.addMessage(errorMessage);
            return;
        }   
    } 
    
    public List<SequencialBatchJob> schedulePANJobs(String Theater) {
    List<SequencialBatchJob>Jobs = new List<SequencialBatchJob>(); 
    integer batchSize;                                 
  
        String DeleteVelocityRuleResultsQuery='select Id,Grouping__c,Grouping__r.RecordType.DeveloperName from Velocity_Rule_Results__c where Grouping__r.RecordType.DeveloperName = \'Partner_Grouping_PAN_Theater\' and Account_Theater__c =\''+Theater+'\' and createddate <'+ new PRM_CommonUtils().getQueryFormattedDate(System.now()) ;
        System.debug('DeleteVelocityRuleResultsQuery '+DeleteVelocityRuleResultsQuery);
        
        PRM_VPP_DeleteRecordsJob jobDelVRR= new PRM_VPP_DeleteRecordsJob(DeleteVelocityRuleResultsQuery);
        Jobs.add(new SequencialBatchJob('Delete PANVelocityRuleResults '+Theater,jobDelVRR,200));  
        
        
        String ruleResultQuery1 = 'SELECT Account__c, Advanced_Consolidate_Specialty__c, Backup_and_Recovery_Specialty__c, Cluster__c, '+
                                  ' Compliance_Period_Requirments_Met__c, Consolidate_Specialty__c, Deployed_To__c, Name,Active__c ' +
                                  ' Governance_and_Archive_Specialty__c, Isilon_Track_Specialty__c, Local_Requirment_Set__c, Logical_Block_Level_Grouping__c, '+ 
                                  ' Pan_Theater_Level_Grouping__c, Speciality_Type__c,RecordType.DeveloperName,Theater2__c, Target_Tier__c,Velocity_Specaility_Achieved__c, RecordTypeId '+
                                  ' FROM Account_Groupings__c where RecordType.DeveloperName=\'Partner_Grouping_PAN_Theater\''+
                                  ' AND Active__c = true AND Theater2__c =\''+Theater+'\'';
        System.debug('ruleResultQuery1 '+ruleResultQuery1);
        PRM_PAN_VPP_VelocityRuleResultJob1 jobCreateVRR = new PRM_PAN_VPP_VelocityRuleResultJob1(ruleResultQuery1);
        //get batch size
        try{            
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleResultJob1').DataValue__c);
        }catch(Exception e){
            batchSize = 20;
        } 
        Jobs.add(new SequencialBatchJob('BuildPANVelocityRuleResults '+Theater,jobCreateVRR,batchSize)); 

        String ruleResultQuery2 = 'Select Revenue_Amount__c,Required_value_Type__c,v.Speciality_RuleID__c, v.Rule_theater__c, '
                                            +'v.RequiredCount__c,Speciality_RuleID__r.RecordType.Name, '
                                            +'Speciality_RuleID__r.RecordType.DeveloperName, v.Name, v.Grouping__c,v.Grouping__r.RecordType.DeveloperName,v.Current__c, '
                                            +'v.Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c, '
                                            +'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, '
                                            +'Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Group_Rule_3__c, '
                                            +'Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c, '
                                            +'Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.BR_Sub_category__c, '
                                            +'Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Required_Type__c, '
                                            +'Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,'
                                            +'Speciality_RuleID__r.Theater__c,Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Any_Value_Acceptable__c,Speciality_RuleID__r.Value__c, '
                                            +'Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c, '
                                            + ' VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c, '
                                            +'Speciality_RuleID__r.Name,v.AccountID__c From Velocity_Rule_Results__c v where v.Grouping__r.RecordType.DeveloperName = \'Partner_Grouping_PAN_Theater\' AND Account_Theater__c= \''+Theater+'\' ORDER BY Grouping__c ';
        System.debug('ruleResultQuery2 '+ruleResultQuery2);                                 
        PRM_PAN_VPP_VelocityRuleEvaluatorJob jobEvaluateVRR = new PRM_PAN_VPP_VelocityRuleEvaluatorJob(ruleResultQuery2);
        //get batch size
        try{            
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleEvaluatorJob').DataValue__c);
        }catch(Exception e){
            batchSize = 20;
        } 
        Jobs.add(new SequencialBatchJob('EvaluatePANVelocityRuleResults '+Theater,jobEvaluateVRR,batchSize)); 
    return Jobs;
   }

   public List<SequencialBatchJob> scheduleLogicalBlockJobs(String Theater) {
    List<SequencialBatchJob>Jobs = new List<SequencialBatchJob>(); 
    integer batchSize;                                 
  
        String DeleteVelocityRuleResultsQuery='select Id,Grouping__c,Grouping__r.RecordType.DeveloperName from Velocity_Rule_Results__c where Grouping__r.RecordType.DeveloperName = \'Partner_Grouping_Logical_Block\' and Account_Theater__c =\''+Theater+'\' and createddate <'+ new PRM_CommonUtils().getQueryFormattedDate(System.now()) ;
        System.debug('DeleteVelocityRuleResultsQuery '+DeleteVelocityRuleResultsQuery);
        
        PRM_VPP_DeleteRecordsJob jobDelVRR= new PRM_VPP_DeleteRecordsJob(DeleteVelocityRuleResultsQuery);
        Jobs.add(new SequencialBatchJob('Delete LBVelocityRuleResults '+Theater,jobDelVRR,200));  
        
        
        String ruleResultQuery1 = 'SELECT Account__c, Advanced_Consolidate_Specialty__c, Backup_and_Recovery_Specialty__c, Cluster__c, '+
                                  ' Compliance_Period_Requirments_Met__c, Consolidate_Specialty__c, Deployed_To__c, Name,Active__c ' +
                                  ' Governance_and_Archive_Specialty__c, Isilon_Track_Specialty__c, Local_Requirment_Set__c, Logical_Block_Level_Grouping__c, '+ 
                                  ' Pan_Theater_Level_Grouping__c, Speciality_Type__c,RecordType.DeveloperName,Theater2__c, Target_Tier__c,Velocity_Specaility_Achieved__c, RecordTypeId '+
                                  ' FROM Account_Groupings__c where RecordType.DeveloperName=\'Partner Grouping- Logical Block Level\''+
                                  ' AND Active__c = true AND Theater2__c =\''+Theater+'\'';
        System.debug('ruleResultQuery1 '+ruleResultQuery1);
        PRM_PAN_VPP_VelocityRuleResultJob1 jobCreateVRR = new PRM_PAN_VPP_VelocityRuleResultJob1(ruleResultQuery1);
        //get batch size
        try{            
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleResultJob1').DataValue__c);
        }catch(Exception e){
            batchSize = 20;
        } 
        Jobs.add(new SequencialBatchJob('BuildLBVelocityRuleResults '+Theater,jobCreateVRR,batchSize)); 

        String ruleResultQuery2 = 'Select Revenue_Amount__c,Required_value_Type__c,v.Speciality_RuleID__c, v.Rule_theater__c, '
                                            +'v.RequiredCount__c,Speciality_RuleID__r.RecordType.Name, '
                                            +'Speciality_RuleID__r.RecordType.DeveloperName, v.Name, v.Grouping__c,v.Grouping__r.RecordType.DeveloperName,v.Current__c, '
                                            +'v.Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c, '
                                            +'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, '
                                            +'Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Group_Rule_3__c, '
                                            +'Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c, '
                                            +'Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.BR_Sub_category__c, '
                                            +'Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Required_Type__c, '
                                            +'Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,'
                                            +'Speciality_RuleID__r.Theater__c,Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Any_Value_Acceptable__c,Speciality_RuleID__r.Value__c, '
                                            +'Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c, '
                                            + ' VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c, '
                                            +'Speciality_RuleID__r.Name,v.AccountID__c From Velocity_Rule_Results__c v where v.Grouping__r.RecordType.DeveloperName = \'Partner_Grouping_Logical_Block\' AND Account_Theater__c= \''+Theater+'\' ORDER BY Grouping__c ';
        System.debug('ruleResultQuery2 '+ruleResultQuery2);                                 
        PRM_PAN_VPP_VelocityRuleEvaluatorJob jobEvaluateVRR = new PRM_PAN_VPP_VelocityRuleEvaluatorJob(ruleResultQuery2);
        //get batch size
        try{            
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleEvaluatorJob').DataValue__c);
        }catch(Exception e){
            batchSize = 20;
        } 
        Jobs.add(new SequencialBatchJob('EvaluateLBVelocityRuleResults '+Theater,jobEvaluateVRR,batchSize)); 
    return Jobs;
   }
   public void runJobForALLPANTheater(){                
        List<SequencialBatchJob> SelectedTheaterPANJobs= new List<SequencialBatchJob> ();        
        Integer batchSize = 200;
        //get batch size
        try{            
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_EducationEduMasterGroupJob').DataValue__c);
        }catch(Exception e){
            batchSize = 20;
        }
        SelectedTheatersForImmidateRun = new String[]{'All','APJ', 'EMEA','Americas'} ;
        for(String theater: SelectedTheatersForImmidateRun ){
            
            
                        
            if(theater=='APJ'){                 
                SelectedTheaterPANJobs.addAll(schedulePANandLogicalBlockJobs('APJ'));               
            }
            if(theater=='EMEA' ){ 
                SelectedTheaterPANJobs.addAll(schedulePANandLogicalBlockJobs('EMEA'));               
            } 
            if(theater=='Americas' ){ 
                SelectedTheaterPANJobs.addAll(schedulePANandLogicalBlockJobs('Americas'));  
            } 
        }           
        SequencialBatchJobScheduler.executeSequence(SelectedTheaterPANJobs);
    }
   public List<SequencialBatchJob> schedulePANandLogicalBlockJobs(String Theater) {
    List<SequencialBatchJob> Jobs = new List<SequencialBatchJob>(); 
    integer batchSize;                                 
  
        String DeleteVelocityRuleResultsQuery='select Id,Grouping__c,Grouping__r.RecordType.DeveloperName from Velocity_Rule_Results__c where '
                                              +'(Speciality_RuleID__r.Evaluation_at__c = \'PAN Theater Grouping Level\' or '
                                              +'Speciality_RuleID__r.Evaluation_at__c = \'Logical Block Grouping Level\') '                                             
                                              +'and Account_Theater__c =\''+Theater+'\''+ 'and createddate <'+ new PRM_CommonUtils().getQueryFormattedDate(System.now()) ;
        System.debug('DeleteVelocityRuleResultsQuery '+DeleteVelocityRuleResultsQuery);
        
        PRM_VPP_DeleteRecordsJob jobDelVRR= new PRM_VPP_DeleteRecordsJob(DeleteVelocityRuleResultsQuery);
        Jobs.add(new SequencialBatchJob('Delete PANAndLogicalBlockVelocityRuleResults '+Theater,jobDelVRR,200));  
        
        
        String ruleResultQuery1 = 'SELECT Account__c, Advanced_Consolidate_Specialty__c, Backup_and_Recovery_Specialty__c, Cluster__c, '+
                                  ' Compliance_Period_Requirments_Met__c, Consolidate_Specialty__c, Deployed_To__c, Name,Active__c, ' +
                                  ' Governance_and_Archive_Specialty__c, Isilon_Track_Specialty__c, Local_Requirment_Set__c, Logical_Block_Level_Grouping__c, '+ 
                                  ' Pan_Theater_Level_Grouping__c, Speciality_Type__c,RecordType.DeveloperName,Theater2__c, Target_Tier__c,Velocity_Specaility_Achieved__c, RecordTypeId '+
                                  ' FROM Account_Groupings__c where (RecordType.DeveloperName=\'Partner_Grouping_PAN_Theater\' '+
                                  'or RecordType.DeveloperName=\'Partner_Grouping_Logical_Block\') '+
                                  ' AND Active__c = true AND Theater2__c =\''+Theater+'\'';
        System.debug('ruleResultQuery1 '+ruleResultQuery1);
        PRM_PAN_VPP_VelocityRuleResultJob1 jobCreateVRR = new PRM_PAN_VPP_VelocityRuleResultJob1(ruleResultQuery1);
        //get batch size
        try{            
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleResultJob1').DataValue__c);
        }catch(Exception e){
            batchSize = 20;
        } 
        Jobs.add(new SequencialBatchJob('BuildPANAndLogicalBlockVelocityRuleResults '+Theater,jobCreateVRR,batchSize)); 
        
        String ruleResultQuery2 = 'Select Revenue_Amount__c, Required_value_Type__c,v.Speciality_RuleID__c, v.Rule_theater__c,Grouping__r.Local_Requirment_Set__c, '
                                            +'v.RequiredCount__c,Speciality_RuleID__r.RecordType.Name,Speciality_RuleID__r.Local_Requirment_Set__c, '
                                            +'Speciality_RuleID__r.RecordType.DeveloperName, v.Name, v.Grouping__c,v.Grouping__r.RecordType.DeveloperName,v.Current__c, '
                                            +'v.Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c, '
                                            +'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, '
                                            +'Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Group_Rule_3__c, Grouping__r.Target_Tier__c, '
                                            +'Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c, '
                                            +'Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.BR_Sub_category__c, '
                                            +'Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Required_Type__c, '
                                            +'Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,'
                                            +'Speciality_RuleID__r.Theater__c,Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Any_Value_Acceptable__c,Speciality_RuleID__r.Value__c, '
                                            +'Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c, '
                                            + ' VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c, '
                                            +'Speciality_RuleID__r.Name,v.AccountID__c From Velocity_Rule_Results__c v where v.Grouping__r.RecordType.DeveloperName = \'Partner_Grouping\' and (Speciality_RuleID__r.Evaluation_at__c = \'PAN Theater Grouping Level\' or '
                                            +'Speciality_RuleID__r.Evaluation_at__c = \'Logical Block Grouping Level\') ' 
                                            +'AND Account_Theater__c= \''+Theater+'\'' +' ORDER BY Grouping__c ';
        System.debug('ruleResultQuery2 '+ruleResultQuery2);                                 
        PRM_VPP_VelocityRuleEvaluatorJob EvaluateGroupingVRR = new PRM_VPP_VelocityRuleEvaluatorJob(ruleResultQuery2);
        //get batch size
        try{            
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleEvaluatorJob').DataValue__c);
        }catch(Exception e){
            batchSize = 20;
        } 
        
        Jobs.add(new SequencialBatchJob('Evaluate Grouping Velocity Rules '+Theater,EvaluateGroupingVRR,batchSize)); 
        
        String rollupruleResultQuery = 'Select a.PROFILED_ACCOUNT_FLAG__c, a.Name, Theater1__c, a.Id, a.Grouping__c,velocity_Solution_Provider_Tier__c, '
                                            +'Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c, '
                                            +'Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c, Deployed_Velocity_Services__c, '
                                            +'Velocity_Compliance_Status__c , Education_Data_Refresh_Date__c From Account a '
                                            +'where profiled_Account_flag__c=true and Grouping__c!=null and Theater1__c=\''+Theater+'\'';
        System.debug('rollupruleResultQuery '+rollupruleResultQuery);                                 
        PRM_VPP_RollupRuleEvaluatorJob rollUpJob = new PRM_VPP_RollupRuleEvaluatorJob(rollupruleResultQuery);        
        //get batch size
        try{            
            batchSize  = Integer.valueOf(DataValueMap.get('RollupEvaluationBatchSize').DataValue__c);
        }catch(Exception e){
            batchSize = 20;
        } 
        Jobs.add(new SequencialBatchJob('Evaluate Rollup Rules '+Theater,rollUpJob,batchSize ));    
        
        String ruleResultQuery3 = 'Select Revenue_Amount__c,Required_value_Type__c,v.Speciality_RuleID__c, v.Rule_theater__c, '
                                            +'v.RequiredCount__c,Speciality_RuleID__r.RecordType.Name, '
                                            +'Speciality_RuleID__r.RecordType.DeveloperName, v.Name, v.Grouping__c,v.Grouping__r.RecordType.DeveloperName,v.Current__c, '
                                            +'v.Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,Grouping__r.Target_Tier__c, '
                                            +'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, '
                                            +'Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Group_Rule_3__c, '
                                            +'Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c, '
                                            +'Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.BR_Sub_category__c, '
                                            +'Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Required_Type__c, '
                                            +'Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,'
                                            +'Speciality_RuleID__r.Theater__c,Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Any_Value_Acceptable__c,Speciality_RuleID__r.Value__c, '
                                            +'Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c, '
                                            + ' VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c, '
                                            +'Speciality_RuleID__r.Name,v.AccountID__c From Velocity_Rule_Results__c v where (v.Grouping__r.RecordType.DeveloperName = \'Partner_Grouping_PAN_Theater\' or v.Grouping__r.RecordType.DeveloperName =\'Partner_Grouping_Logical_Block\') '
                                            +'AND Account_Theater__c= \''+Theater+'\'' +' ORDER BY Grouping__c ';
        System.debug('PanEvaluationruleResultQuery2 '+ruleResultQuery3);                                 
        PRM_PAN_VPP_VelocityRuleEvaluatorJob jobEvaluateVRR = new PRM_PAN_VPP_VelocityRuleEvaluatorJob(ruleResultQuery3);
        //get batch size
        try{            
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleEvaluatorJob').DataValue__c);
        }catch(Exception e){
            batchSize = 20;
        } 
        Jobs.add(new SequencialBatchJob('EvaluatePANandLogicalBlockVelocityRuleResults '+Theater,jobEvaluateVRR,batchSize)); 
    return Jobs;
   }      
    public List<SelectOption> getSearchCriteriaForPANGAFList() 
    {     
        List<SelectOption> options2 = new List<SelectOption>();  
        options2.add(new SelectOption('GAF Revenue & Rebate Id','GAF Revenue & Rebate Id'));                
        return options2;  
    }
    
    public void runPANGAFJobForGAFRevenueAndRebate(){       
        list<GAF_Revenue_Rebate__c> lstGAFRevenueAndRebate = new list<GAF_Revenue_Rebate__c>();
        try{    
            if(strGAFRevenueAndRebateId != null && strGAFRevenueAndRebateId != ''){
                lstGAFRevenueAndRebate = [Select Id,GAF_Revenue_Rebate_Type__c,Profiled_Account__c,Profiled_Account__r.Grouping__c,Logical_Block__c,Pan_Theater__c,Country__c,GAF_Year__c,Partner_Type__c,Theater__c,Advcd_Cnsld_Actual_Q1__c,Advcd_Cnsld_Actual_Q2__c,Advcd_Cnsld_Actual_Q3__c,Advcd_Cnsld_Actual_Q4__c,Advcd_Cnsld_Rebt_Q1__c,Advcd_Cnsld_Rebt_Q2__c,Advcd_Cnsld_Rebt_Q3__c,Advcd_Cnsld_Rebt_Q4__c,
                                                Adv_Cnsld_Al_Ptr_Rev_Actl_Q1__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q2__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q3__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q4__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q1__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q2__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q3__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q4__c,Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q1__c,Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q2__c,
                                                Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q3__c,Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q4__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q1__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q2__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q3__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q4__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q1__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q2__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q3__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q4__c,
                                                BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q1__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q2__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q3__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q4__c,BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q1__c,BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q2__c,BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q3__c,
                                                BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q4__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q1__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q2__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q3__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q4__c,BRS_Cnsld_All_Ptr_Unit_Rebt_Q1__c,BRS_Cnsld_All_Ptr_Unit_Rebt_Q2__c,BRS_Cnsld_All_Ptr_Unit_Rebt_Q3__c,
                                                BRS_Cnsld_All_Ptr_Unit_Rebt_Q4__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q1__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q2__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q3__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q4__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q1__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q2__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q3__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q4__c,
                                                BRS_Cnsld_All_Ptr_Rev_Actl_Q1__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q2__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q3__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q4__c,BRS_Cnsld_Grwt_Rev_Rebt_Q1__c,BRS_Cnsld_Grwt_Rev_Rebt_Q2__c,BRS_Cnsld_Grwt_Rev_Rebt_Q3__c,BRS_Cnsld_Grwt_Rev_Rebt_Q4__c,
                                                BRS_Cnsld_Grwt_Unit_Rebt_Q1__c,BRS_Cnsld_Grwt_Unit_Rebt_Q2__c,BRS_Cnsld_Grwt_Unit_Rebt_Q3__c,BRS_Cnsld_Grwt_Unit_Rebt_Q4__c,BRS_Actl_Q1__c,BRS_Actl_Q2__c,BRS_Actl_Q3__c,BRS_Actl_Q4__c,BRS_Al_Ptr_Rebt_Q1__c,BRS_Al_Ptr_Rebt_Q2__c,BRS_Al_Ptr_Rebt_Q3__c,BRS_Al_Ptr_Rebt_Q4__c,
                                                BRS_Al_Ptr_Rev_Actl_Q1__c,BRS_Al_Ptr_Rev_Actl_Q2__c,BRS_Al_Ptr_Rev_Actl_Q3__c,BRS_Al_Ptr_Rev_Actl_Q4__c,BRS_Al_Ptr_Rev_Rebt_Q1__c,BRS_Al_Ptr_Rev_Rebt_Q2__c,BRS_Al_Ptr_Rev_Rebt_Q3__c,BRS_Al_Ptr_Rev_Rebt_Q4__c,BRS_Al_Ptr_Unit_Actl_Q1__c,BRS_Al_Ptr_Unit_Actl_Q2__c,BRS_Al_Ptr_Unit_Actl_Q3__c,
                                                BRS_Al_Ptr_Unit_Actl_Q4__c,BRS_Al_Ptr_Unit_Rebt_Q1__c,BRS_Al_Ptr_Unit_Rebt_Q2__c,BRS_Al_Ptr_Unit_Rebt_Q3__c,BRS_Al_Ptr_Unit_Rebt_Q4__c,BRS_Grwt_Ptr_Rebt_Q1__c,BRS_Grwt_Ptr_Rebt_Q2__c,BRS_Grwt_Ptr_Rebt_Q3__c,BRS_Grwt_Ptr_Rebt_Q4__c,BRS_Grwt_Ptr_Rev_Actl_Q1__c,
                                                BRS_Grwt_Ptr_Rev_Actl_Q2__c,BRS_Grwt_Ptr_Rev_Actl_Q3__c,BRS_Grwt_Ptr_Rev_Actl_Q4__c,BRS_Grwt_Ptr_Unit_Actl_Q1__c,BRS_Grwt_Ptr_Unit_Actl_Q2__c,BRS_Grwt_Ptr_Unit_Actl_Q3__c,BRS_Grwt_Ptr_Unit_Actl_Q4__c,BRS_Rebt_Q1__c,BRS_Rebt_Q2__c,BRS_Rebt_Q3__c,BRS_Rebt_Q4__c,
                                                Cnsld_Actl_Q1__c,Cnsld_Actl_Q2__c,Cnsld_Actl_Q3__c,Cnsld_Actl_Q4__c,Cnsld_Al_Ptr_Rebt_Q1__c,Cnsld_Al_Ptr_Rebt_Q2__c,Cnsld_Al_Ptr_Rebt_Q3__c,Cnsld_Al_Ptr_Rebt_Q4__c,Cnsld_Al_Ptr_Rev_Actl_Q1__c,Cnsld_Al_Ptr_Rev_Actl_Q2__c,Cnsld_Al_Ptr_Rev_Actl_Q3__c,Cnsld_Al_Ptr_Rev_Actl_Q4__c,Cnsld_Al_Ptr_Unit_Actl_Q1__c,
                                                Cnsld_Al_Ptr_Unit_Actl_Q2__c,Cnsld_Al_Ptr_Unit_Actl_Q3__c,Cnsld_Al_Ptr_Unit_Actl_Q4__c,Cnsld_Al_Ptr_Unit_Rebt_Q1__c,Cnsld_Al_Ptr_Unit_Rebt_Q2__c,Cnsld_Al_Ptr_Unit_Rebt_Q3__c,Cnsld_Al_Ptr_Unit_Rebt_Q4__c,Cnsld_Al_Ptr_Rev_Rebt_Q1__c,Cnsld_All_Ptr_Rev_Rebt_Q2__c,Cnsld_All_Ptr_Rev_Rebt_Q3__c,
                                                Cnsld_All_Ptr_Rev_Rebt_Q4__c,Cnsld_Grwt_Ptr_Rebt_Q1__c,Cnsld_Grwt_Ptr_Rebt_Q2__c,Cnsld_Grwt_Ptr_Rebt_Q3__c,Cnsld_Grwt_Ptr_Rebt_Q4__c,Cnsld_Grwt_Ptr_Rev_Actl_Q1__c,Cnsld_Grwt_Ptr_Rev_Actl_Q2__c,Cnsld_Grwt_Ptr_Rev_Actl_Q3__c,Cnsld_Grwt_Ptr_Rev_Actl_Q4__c,
                                                Cnsld_Grwt_Ptr_Unt_Actl_Q1__c,Cnsld_Grwt_Ptr_Unt_Actl_Q2__c,Cnsld_Grwt_Ptr_Unt_Actl_Q3__c,Cnsld_Grwt_Ptr_Unt_Actl_Q4__c,Cnsld_Rebt_Q1__c,Cnsld_Rebt_Q2__c,Cnsld_Rebt_Q3__c,Cnsld_Rebt_Q4__c,Gvr_Arv_Actl_Q1__c,Gvr_Arv_Acl_Q2__c,Gvr_Arv_Acl_Q3__c,Gvr_Arv_Acl_Q4__c,
                                                Gvr_Arv_Al_Ptr_Rbt_Q1__c,Gvr_Arv_Al_Ptr_Rbt_Q2__c,Gvr_Arv_Al_Ptr_Rbt_Q3__c,Gvr_Arv_Al_Ptr_Rbt_Q4__c,Gvrn_Archv_Rebt_Q1__c,Gvrn_Archv_Rebt_Q2__c,Gvrn_Archv_Rebt_Q3__c,Gvrn_Archv_Rebt_Q4__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Q1__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Q2__c,
                                                Gvrn_Archv_Al_Ptr_Rev_Actl_Q3__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Q4__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q1__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q2__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q3__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q4__c,Gvrn_Archv_Grwt_Ptr_Rebt_Q1__c,Gvrn_Archv_Grwt_Ptr_Rebt_Q2__c,Gvrn_Archv_Grwt_Ptr_Rebt_Q3__c,
                                                Gvrn_Archv_Grwt_Ptr_Rebt_Q4__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q1__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q2__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q3__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q4__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Q1__c,
                                                Gvrn_Archv_Al_Ptr_Unt_Actl_Q2__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Q3__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Q4__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q1__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q2__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q3__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q4__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q1__c,
                                                Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q2__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q3__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q4__c,
                                                Isilon_Actl_Q1__c,Isilon_Acl_Q2__c,Isilon_Acl_Q3__c,Isilon_Acl_Q4__c,
												Isilon_Al_Ptr_Rbt_Q1__c,Isilon_Al_Ptr_Rbt_Q2__c,Isilon_Al_Ptr_Rbt_Q3__c,Isilon_Al_Ptr_Rbt_Q4__c,
												Isilon_Rebt_Q1__c,Isilon_Rebt_Q2__c,Isilon_Rebt_Q3__c,Isilon_Rebt_Q4__c,
												Isilon_Al_Ptr_Rev_Actl_Q1__c,Isilon_Al_Ptr_Rev_Actl_Q2__c,Isilon_Al_Ptr_Rev_Actl_Q3__c,Isilon_Al_Ptr_Rev_Actl_Q4__c,
												Isilon_Grwt_Ptr_Rebt_Q1__c,Isilon_Grwt_Ptr_Rebt_Q2__c,Isilon_Grwt_Ptr_Rebt_Q3__c,Isilon_Grwt_Ptr_Rebt_Q4__c,
												Isilon_All_Ptr_Unt_Rebt_Q1__c,Isilon_All_Ptr_Unt_Rebt_Q2__c,Isilon_All_Ptr_Unt_Rebt_Q3__c,Isilon_All_Ptr_Unt_Rebt_Q4__c,
												Isilon_Al_Ptr_Unt_Actl_Q1__c,Isilon_Al_Ptr_Unt_Actl_Q2__c,Isilon_Al_Ptr_Unt_Actl_Q3__c,Isilon_Al_Ptr_Unt_Actl_Q4__c,
												Isilon_Grwt_Ptr_Rev_Actl_Q1__c,Isilon_Grwt_Ptr_Rev_Actl_Q2__c,Isilon_Grwt_Ptr_Rev_Actl_Q3__c,Isilon_Grwt_Ptr_Rev_Actl_Q4__c,
												Isilon_Incentive_Actual_Q1__c,Isilon_Incentive_Actual_Q2__c,Isilon_Incentive_Actual_Q3__c,Isilon_Incentive_Actual_Q4__c,Isilon_Incentive_Actual_Total__c,
                    							Isilon_Incentive_Rebate_Q1__c,Isilon_Incentive_Rebate_Q2__c,Isilon_Incentive_Rebate_Q3__c,Isilon_Incentive_Rebate_Q4__c,Isilon_Incentive_Rebate_Total__c,
                   								Target_Products_Actual_Q1__c,Target_Products_Actual_Q2__c,Target_Products_Actual_Q3__c,Target_Products_Actual_Q4__c,Target_Products_Actual_Total__c,
                    							Target_Products_Rebate_Q1__c,Target_Products_Rebate_Q2__c,Target_Products_Rebate_Q3__c,Target_Products_Rebate_Q4__c,Target_Products_Rebate_Total__c from GAF_Revenue_Rebate__c 
                                                where Id =: strGAFRevenueAndRebateId];
                
                PRM_RevenueGAFVROperations RevenueGAFVROperations = new PRM_RevenueGAFVROperations();
                RevenueGAFVROperations.populateGAFForPANLBCustom(lstGAFRevenueAndRebate);
            }
        }catch(exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide valid GAF Revenue & Rebate Id');
            ApexPages.addMessage(errorMessage);
            return;
        }
    }
    
    public void runPANGAFJobForALLGAFRevenueAndRebate(){       
        PRM_PopulateFieldsOnGAFRevRebateBatch PANGAFBatch = new PRM_PopulateFieldsOnGAFRevRebateBatch(); 
        Integer GafRevbatchSize = 10;
        try{            
            GafRevbatchSize = Integer.valueOf(DataValueMap.get('PRM_PopulateFieldsOnGAFRevRebateBatch').DataValue__c);
        }catch(Exception e){
            GafRevbatchSize = 10;
        }    
        database.executebatch(PANGAFBatch,GafRevbatchSize);
    }
 }