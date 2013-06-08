/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  02/09/2011    Shalabh Sharma                    To test the class PRM_VPP_TEST_VelocityRuleResult
 |  28/03/2011    Anand Sharma                      Created custom setting value through test class
 |  24/08/2011    Anirudh Singh                     Commented Line#92&#93 for batch limit issue.
 |  21/10/2011    Suman B                           Calling createVPPCustomSettingData() in test methods to
 |                                                  set up data.  
 |  18/05/2012    Kaustav Debnath                   Increased the test coverage
 |  01/03/2013    Karunakar            209736	    Increased the test coverage
 +=======================================================================================================*/
@isTest

   private class PRM_VPP_TEST_VelocityRuleResult_TC {   

       public List<Account> createTestData()
       {
            /*Creation of Grouping record */ 
       Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp');
       Insert grouping;
       
        Account_Groupings__c grouping1 = new Account_Groupings__c (Name = 'UNITTESTGrp1');
       Insert grouping1;
      
       /*Creation of Account record */ 
       List<Account> lstAccountToInsert=new List<Account>();
       Account account =  new Account (Name = 'UNITTESTVPP', cluster__C = 'APJ', Grouping__c = grouping.Id,PROFILED_ACCOUNT_FLAG__c = true,rating_eligible__c=true);
       lstAccountToInsert.add(account);
       //Insert account;
       Account account1 =  new Account (Name = 'UNITTESTPL', cluster__C = 'APJ', Grouping__c = grouping1.Id,PROFILED_ACCOUNT_FLAG__c = true,rating_eligible__c=false);
       lstAccountToInsert.add(account1);
       List<Account_Groupings__c> lstGroupingUpdate=new List<Account_Groupings__c>();
       grouping.Profiled_Account__c=lstAccountToInsert[0].id;
       grouping1.Profiled_Account__c=lstAccountToInsert[1].id;
       
       lstGroupingUpdate.add(grouping);
       lstGroupingUpdate.add(grouping1);
       update lstGroupingUpdate;
       System.debug('##### grouping.Profiled_Account__c=>'+grouping);
       System.debug('##### grouping1.Profiled_Account__c=>'+grouping1);
       //Insert account1;
       //Account account2 =  new Account (Name = 'UNITTESTPL1', cluster__C = 'APJ', Grouping__c = grouping.Id,PROFILED_ACCOUNT_FLAG__c = true,rating_eligible__c=true);
       //lstAccountToInsert.add(account2);
       //Insert account2;
       insert lstAccountToInsert;
       
       /*Creation of contact record*/
       List<Contact> lstContactToInsert=new List<Contact>();
       Contact contObj = new Contact(LastName = 'Tester',Phone = '999999999',Email = 'xxxx@acc.com',accountId=lstAccountToInsert[0].Id,Partner_SE__c = true,emc_pre_sales__c='70%',Advanced_Consolidate_Champion__c=true,Consolidate_Champion__c=true,Backup_Champion__c=true,Governance_Archive_Champion__c=true);
       lstContactToInsert.add(contObj);
       //insert contObj;
       Contact contObj1 = new Contact(LastName = 'Tester1',Phone = '999999998',Email = 'xxxx1@acc.com',accountId=lstAccountToInsert[1].Id,Partner_SE__c = true,emc_pre_sales__c='70%');
       lstContactToInsert.add(contObj1);
        //insert contObj;        
        insert lstContactToInsert;  
       /* creation of 5 Velocity Rule Record */
        List<Velocity_Rules__c> velocityRulesRecords = new List<Velocity_Rules__c>();
        RecordType recordTypeSpecialty = [Select r.Id From RecordType r 
                                          where SobjectType = 'Velocity_Rules__c' 
                                          and Name = 'Specialty Rule'];  
        RecordType recordTypeGroup = [Select r.Id From RecordType r 
                                      where SobjectType = 'Velocity_Rules__c' 
                                      and Name = 'Group Rule']; 
        RecordType recordTypeRollUp = [Select r.Id From RecordType r 
                                       where SobjectType = 'Velocity_Rules__c' 
                                       and Name = 'Roll Up Rule']; 
        RecordType recordTypeTier = [Select r.Id From RecordType r 
                                     where SobjectType = 'Velocity_Rules__c' 
                                     and Name = 'Tier Rule']; 
                                     
        for(integer i = 0; i<5; i++){
            if(i<=1){  
                Velocity_Rules__c velocityRuleRecordSpecialty = new Velocity_Rules__c(Display_Name__c = 'UNITTEST'+i,
                                                                                      RecordTypeId = recordTypeSpecialty.Id,
                                                                                      Cluster__c = 'APJ', 
                                                                                      Specialty_Rule_Type__c = 'LA1');
                velocityRulesRecords.add(velocityRuleRecordSpecialty);
            }
            if(i==2){    
                Velocity_Rules__c velocityRuleRecordGroup = new Velocity_Rules__c(Display_Name__c = 'UNITTEST'+i,
                                                                                  RecordTypeId = recordTypeGroup.Id,
                                                                                  Cluster__c = 'EMEA 1B',
                                                                                  Specialty_Rule_Type__c = 'EMEA');
                velocityRulesRecords.add(velocityRuleRecordGroup);
            }
            if(i==3){
                Velocity_Rules__c velocityRuleRecordRollUp = new Velocity_Rules__c(Display_Name__c = 'UNITTEST'+i,
                                                                                   RecordTypeId = recordTypeRollUp.Id,
                                                                                   Cluster__c = 'LA1', 
                                                                                   Specialty_Rule_Type__c = 'APJ-M');
                velocityRulesRecords.add(velocityRuleRecordRollUp);
            }
            if(i==4){    
                Velocity_Rules__c velocityRuleRecordTier = new Velocity_Rules__c(Display_Name__c = 'UNITTEST'+i,
                                                                                 RecordTypeId = recordTypeTier.Id,
                                                                                 Cluster__c = 'NA',
                                                                                 Specialty_Rule_Type__c = 'NA');
                velocityRulesRecords.add(velocityRuleRecordTier);
            }
        }
        Database.Insert (velocityRulesRecords,false); 
            List<Velocity_Rule_Results__c> LstVRR = new List<Velocity_Rule_Results__c>();
                 
                 for(integer i=0; i<5;i++) {
        
            Velocity_Rule_Results__c velruleresult = new Velocity_Rule_Results__c (Speciality_RuleID__c =velocityRulesRecords[i].Id,AccountID__c = lstAccountToInsert[0].Id,CurrencyIsoCode = 'USD',Grouping__c= grouping.Id); 
            LstVRR.add(velruleresult);
       }
       //Insert LstVRR;
       Database.Insert (LstVRR,false);
       /* creation of Education Master record */
        Education_Master__c EducationMaster = new Education_Master__c(CurrencyIsoCode = 'USD');
        Insert EducationMaster;
       
       /* creation of Education record */ 
        Education__c education = new Education__c(Batch_Job_Operation__c = 'test',
                                              Education_Master__c = EducationMaster.Id,
                                              Partner_Grouping__c = grouping.Id); 
        Insert education;
        
        
        /* Creation of Education group record.*/   
         Education_Groups__c educationGroup = new Education_Groups__c (Education_Group_Name__c = 'UNITTESTEduGrp');
         Insert educationGroup;
      
        /* Creation of Education Education Group Mapping record.*/   
       // Education_EducationGroup_Mapping__c educationEducationGroupMapping = new Education_EducationGroup_Mapping__c (Education_Group__c = educationGroup.Id, Education__c = education.Id);
        //Insert educationEducationGroupMapping ;
        
        
        List<VelocityRules__c> lstDataValue = new List<VelocityRules__c>();
        VelocityRules__c dataValue = new VelocityRules__c();
        dataValue.Name ='GoalAttained';
        dataValue.RangeValue__c = 100;
        lstDataValue.add(dataValue);
        
        VelocityRules__c dataValue1 = new VelocityRules__c();
        dataValue1.Name ='RevenueRange';
        dataValue1.RangeValue__c =10;
        lstDataValue.add(dataValue1);       
        
        VelocityRules__c dataValue2 = new VelocityRules__c();
        dataValue2.Name ='RevenueDetails';
        dataValue2.SpecialityRules__c ='N/A';
        lstDataValue.add(dataValue2);
        
        VelocityRules__c dataValue3 = new VelocityRules__c();
        dataValue3.Name ='RevenueAchieved';
        dataValue3.SpecialityRules__c ='100%+';
        lstDataValue.add(dataValue3);
        try
        {
           Database.insert(lstDataValue, false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }
        
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        map<string,CustomSettingDataValueMap__c> mapCustomSetting = CustomSettingDataValueMap__c.getall();
        CustomSettingDataValueMap__c customSettingRecord = new CustomSettingDataValueMap__c();
        List<CustomSettingDataValueMap__c> customSettingsDataToUpdate = new List<CustomSettingDataValueMap__c>();
        if(!mapCustomSetting.isEmpty() && mapCustomSetting.containsKey('Batch Id')){
            customSettingRecord = mapCustomSetting.get('Batch Id');
            customSettingRecord.DateValue__c = 0000;
            //customSettingsDataToUpdate.add(customSettingRecord);
            update customSettingRecord;
        }
        else
        {
          customSettingRecord.name='Batch Id';
          customSettingRecord.DateValue__c = 0000 ;
          insert customSettingRecord;
        }
        
        
        list<Staging_data__c> lstStagingData = new list<Staging_data__c>();
        for(Integer i=1;i<=4;i++){
            Staging_data__c staging=new Staging_data__c();
            staging.Batch_Id__c=0000;
            staging.Object_Name__c='Revenue';
            if(Math.mod(i,2)==0)
            {
                staging.Text1__c=grouping.id;
            }
            else if(Math.mod(i,2)==1)
            {
                staging.Text1__c=grouping1.id;
            }
            staging.Text6__c='456.00';
            staging.Text7__c='542.22';
            staging.Text8__c='556.22';
            staging.Text9__c='789.25';
            staging.Text2__c='Advanced Consolidate';
            staging.Text3__c='Services';
            staging.Text4__c= string.valueOf(System.Now().yearGmt());
            staging.Text10__c=String.valueOf(i);
            lstStagingData.add(staging);
        }        
        insert lstStagingData;
        
        return lstAccountToInsert;
       }
     static testMethod void myUnitTest() {
       User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];    
          System.runAs(insertUser){
            PRM_VPP_JobDataHelper.createVPPCustomSettingData();
          }
      PRM_VPP_TEST_VelocityRuleResult_TC testClassObj= new PRM_VPP_TEST_VelocityRuleResult_TC();
      List<Account> lstAccountToInsert=testClassObj.createTestData();
      list<String>lstJobs = new list<String>();
        lstJobs.add('job1');
        lstJobs.add('job2');
        Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp');
        Insert grouping;
        
             List<Velocity_Rules__c> velocityRulesRecords = new List<Velocity_Rules__c>();
        RecordType recordTypeSpecialty = [Select r.Id From RecordType r 
                                          where SobjectType = 'Velocity_Rules__c' 
                                          and Name = 'Specialty Rule'];  
        RecordType recordTypeGroup = [Select r.Id From RecordType r 
                                      where SobjectType = 'Velocity_Rules__c' 
                                      and Name = 'Group Rule']; 
        RecordType recordTypeRollUp = [Select r.Id From RecordType r 
                                       where SobjectType = 'Velocity_Rules__c' 
                                       and Name = 'Roll Up Rule']; 
        RecordType recordTypeTier = [Select r.Id From RecordType r 
                                     where SobjectType = 'Velocity_Rules__c' 
                                     and Name = 'Tier Rule']; 
                                     
        for(integer i = 0; i<5; i++){
            if(i<=1){  
                Velocity_Rules__c velocityRuleRecordSpecialty = new Velocity_Rules__c(Display_Name__c = 'UNITTEST'+i,
                                                                                      RecordTypeId = recordTypeSpecialty.Id,
                                                                                      Cluster__c = 'APJ', 
                                                                                      Specialty_Rule_Type__c = 'LA1');
                velocityRulesRecords.add(velocityRuleRecordSpecialty);
            }
            if(i==2){    
                Velocity_Rules__c velocityRuleRecordGroup = new Velocity_Rules__c(Display_Name__c = 'UNITTEST'+i,
                                                                                  RecordTypeId = recordTypeGroup.Id,
                                                                                  Cluster__c = 'EMEA 1B',
                                                                                  Specialty_Rule_Type__c = 'EMEA');
                velocityRulesRecords.add(velocityRuleRecordGroup);
            }
            if(i==3){
                Velocity_Rules__c velocityRuleRecordRollUp = new Velocity_Rules__c(Display_Name__c = 'UNITTEST'+i,
                                                                                   RecordTypeId = recordTypeRollUp.Id,
                                                                                   Cluster__c = 'LA1', 
                                                                                   Specialty_Rule_Type__c = 'APJ-M');
                velocityRulesRecords.add(velocityRuleRecordRollUp);
            }
            if(i==4){    
                Velocity_Rules__c velocityRuleRecordTier = new Velocity_Rules__c(Display_Name__c = 'UNITTEST'+i,
                                                                                 RecordTypeId = recordTypeTier.Id,
                                                                                 Cluster__c = 'NA',
                                                                                 Specialty_Rule_Type__c = 'NA');
                velocityRulesRecords.add(velocityRuleRecordTier);
            }
        }
         Database.Insert (velocityRulesRecords,false);  
            List<Velocity_Rule_Results__c> LstVRR = new List<Velocity_Rule_Results__c>();
                 
                 for(integer i=0; i<5;i++) {
        
            Velocity_Rule_Results__c velruleresult = new Velocity_Rule_Results__c (Speciality_RuleID__c =velocityRulesRecords[i].Id,AccountID__c = lstAccountToInsert[0].Id,CurrencyIsoCode = 'USD',Grouping__c= grouping.Id); 
            LstVRR.add(velruleresult);
       }
       Database.Insert (LstVRR,false);
       Test.StartTest();
        
        /* Calling class PRM_VPP_TEST_VelocityRuleResult for account */
        PRM_VPP_TEST_VelocityRuleResult prmvpp = new PRM_VPP_TEST_VelocityRuleResult();
        prmvpp.strGroupingId =grouping.id;
        prmvpp.selectedJobs = lstJobs;
        prmvpp.runAllJob();
        prmvpp.groupId=grouping.id;
        prmvpp.velocityRuleResultId=LstVRR[0].id;
        prmvpp.accountId=lstAccountToInsert[0].id;
        prmvpp.velocityRuleId=velocityRulesRecords[0].id;
                         
        prmvpp.getJobOperations();
        prmvpp.SelectedJob = 'Delete Education and Education Group Mappings';
        prmvpp.runJobForAll();
        prmvpp.SelectedJob='Build Education and Education Group Mappings';
        prmvpp.runJobForAll();
        prmvpp.SelectedJob='RunAllJob';
        prmvpp.runJobForAll();
        prmvpp.getSearchCriteriaList();
        prmvpp.getSearchCriteria();
        prmvpp.setSearchCriteria('Account Id'); 
        prmvpp.inputstr = lstAccountToInsert[0].Id;
        prmvpp.runSelectedJob();
        prmvpp.setSearchCriteria('RollupforAccount');
        prmvpp.inputstr = lstAccountToInsert[0].Id;
        prmvpp.runSelectedJob();
        prmvpp.runProfiledAccountsJob();
        prmvpp.runAccountRollupJob();
        prmvpp.executeJobsNow();
        //prmvpp.runVelocityRuleJob();//
        prmvpp.runJobForALLPL();
        prmvpp.runPANLogicalJobForTheaters();
        prmvpp.scheduleVPPJobs('Americas');
        prmvpp.scheduleLogicalBlockJobs('Americas');
        //prmvpp.runJobForALLPANTheater();                       
        prmvpp.schedulePANandLogicalBlockJobs('Americas');
        prmvpp.runPANGAFJobForGAFRevenueAndRebate();
        prmvpp.getJobs();
        prmvpp.SelectedJob='Delete VelocityRuleResults';
        prmvpp.runJobForAll();
        prmvpp.getSelectedjobstoSchedule();        
        List<String> lstStrTheaters= new List<String>();
        lstStrTheaters.add('Americas');
        prmvpp.SelectedTheaters=lstStrTheaters;
        prmvpp.setForNextScheduledRun();
        //prmvpp.runAccountJob();
        prmvpp.runVelocityRuleResultJob();
        prmvpp.runGroupJob();
       // String DeleteEducationMappingQuery='select Id from Education_EducationGroup_Mapping__c where createddate <'+ new PRM_CommonUtils().getQueryFormattedDate(System.now());
       // id batchinstanceid = database.executeBatch(new PRM_VPP_DeleteRecordsJob(DeleteEducationMappingQuery),1);

        /* Calling class PRM_VPP_TEST_VelocityRuleResult for grouping     */  
        PRM_VPP_TEST_VelocityRuleResult prmvpp1 = new PRM_VPP_TEST_VelocityRuleResult();
        prmvpp1.getSearchCriteriaList();
        prmvpp1.getSearchCriteria();
        prmvpp1.setSearchCriteria('GroupId'); 
        prmvpp1.inputstr = lstAccountToInsert[0].Grouping__c; 
        prmvpp1.runSelectedJob();
        prmvpp1.runProfiledGroupsJob();
      
       Test.StopTest();
                   
    }
    
    static testMethod void myUnitTest1() {
         User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];    
          System.runAs(insertUser){
            PRM_VPP_JobDataHelper.createVPPCustomSettingData();
          }
        list<String>lstJobs = new list<String>();
        lstJobs.add('job1');
        lstJobs.add('job2'); 
          
        PRM_VPP_TEST_VelocityRuleResult_TC testClassObj1= new PRM_VPP_TEST_VelocityRuleResult_TC();
        List<Account> lstAccountToInsert=testClassObj1.createTestData();
       // Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp');
        Account_Groupings__c AccountGrouping= new Account_Groupings__c ();
        //AccountGrouping= [Select Id,Name,RecordTypeId,RecordType.DeveloperName,Active__c                   
                  // from Account_Groupings__c where Active__c = true limit 1];
        RecordType rectyp=[SELECT IsActive,Id, DeveloperName FROM RecordType where DeveloperName='Partner_Grouping_PAN_Theater' and IsActive=true limit 1];           
        AccountGrouping.Name='UNITTESTGrp';
        //AccountGrouping.RecordType.DeveloperName = 'Partner_Grouping_PAN_Theater';
        AccountGrouping.RecordTypeId=rectyp.Id;   
        Database.upsert(AccountGrouping, false);
        Test.StartTest();
        PRM_VPP_TEST_VelocityRuleResult prmvppObj = new PRM_VPP_TEST_VelocityRuleResult();   
        prmvppObj.strGroupingId = AccountGrouping.id;
        prmvppObj.SelectedJobs=lstJobs ;
        prmvppObj.SelectedJob='Evaluate Velocity Rules';
        prmvppObj.runJobForAll();
        prmvppObj.SelectedJob='Evaluate Rollup Rules';
        prmvppObj.runJobForAll();
        prmvppObj.SelectedJob='BuildVelocityRuleResults';
        prmvppObj.runJobForAll();
        prmvppObj.SelectedTheatersForImmidateRun = new String[]{'APJ', 'EMEA','Americas'} ;
        prmvppObj.runJobForTheaters();
        prmvppObj.getSearchCriteriaForRevenueList();
        prmvppObj.SearchCriteriaRevenue='Account ID';
        prmvppObj.inputRevenuestr=lstAccountToInsert[0].id;
        prmvppObj.runRevenueJobs();
        //Added by Krishna    
        prmvppObj.setJobsForNextScheduledRun();
        prmvppObj.setDeltaOption();
        prmvppobj.deleteCreateEvaluateVRRForPAN();
        prmvppobj.getSearchCriteriaForPANGAFList();
        
        //CustomSettingDataValueMap__c setJobsforNext = new CustomSettingDataValueMap__c();
        //setJobsforNext.name = 'ESBI_VPP_Scheduled_Jobs';        
        //setJobsforNext.DataValue__c ='';
        List<CustomSettingDataValueMap__c>setJobsforNext =CustomSettingDataValueMap__c.getall().values();
        database.insert(setJobsforNext,false);
        
        Test.StopTest();   
    }
    
    static testMethod void myUnitTest2() {
         User runninguser= [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];    
          System.runAs(runninguser){
            PRM_VPP_JobDataHelper.createVPPCustomSettingData();
          }
        PRM_VPP_TEST_VelocityRuleResult_TC testClassObj1= new PRM_VPP_TEST_VelocityRuleResult_TC();
        List<Account> lstAccountToInsert=testClassObj1.createTestData();       
        Test.StartTest();
        PRM_VPP_TEST_VelocityRuleResult prmvppObj = new PRM_VPP_TEST_VelocityRuleResult(); 
        prmvppObj.SelectedJob='Delete VelocityRuleResults';
        prmvppObj.inputProfiledAccountstr='ABACUS SYSTEMS & SOLUTIONS';
        prmvppObj.runJobForAll();
        
        prmvppObj.getJobPLOperations();
        prmvppObj.getTheaterJobOperations();
        prmvppObj.getSearchCriteriaForPartnerLevList();
        prmvppObj.getSearchCriteriaPL();
        prmvppObj.setSearchCriteriaPL('Grouping ID'); 
        prmvppObj.inputPLstr = lstAccountToInsert[0].Grouping__c;
        prmvppObj.runPatnerLevJobs();
        prmvppObj.inputPLstr = 'negative test for catch';
        prmvppObj.runPatnerLevJobs();
        prmvppObj.inputPLstr = lstAccountToInsert[1].Grouping__c;
        prmvppObj.runPatnerLevJobs();
        prmvppObj.inputPLstr = lstAccountToInsert[0].Id;
        prmvppObj.runPatnerLevJobs();
        prmvppObj.SelectedTheatersForImmidateRun = new String[]{'APJ', 'EMEA','Americas'} ;
            prmvppObj.getSearchCriteriaForRevenueList();
            prmvppObj.inputRevenuestr=lstAccountToInsert[0].id;
            prmvppObj.SearchCriteriaRevenue='negative test case';
            prmvppObj.runRevenueJobs();
            prmvppObj.runJobForALLRevenue();
            User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];
        System.runAs(insertUser)
        {
            
            prmvppObj.getSearchCriteriaForCRList();
            prmvppObj.getJobChampOperations();
            prmvppObj.inputProfiledAccountstr=lstAccountToInsert[0].id;
            prmvppObj.runChampionResourceJob();
            prmvppObj.runChampJobForALLAccount();
            prmvppObj.getSearchCriteriaFAList();
            prmvppObj.getFunctionalAreaOperationsList();
            prmvppObj.inputProfiledAccountFAstr=lstAccountToInsert[0].id;
            prmvppObj.runFunctionalAreaJob();
            prmvppObj.runFunctionalAreaJobForAllAccounts();
            //prmvppobj.runPANGAFJobForALLGAFRevenueAndRebate();
            
        }
    }
}