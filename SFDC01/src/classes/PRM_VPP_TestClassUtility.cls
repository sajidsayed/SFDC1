/*=========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  02/09/2011    Shalabh Sharma                    To test all batch jobs
 |  28/03/2011    Anand Sharma                      Created custom setting value through test class  
                                                    Added method for velocity revenue trigger
 |  01-07-11      Anil                              Renamed Partner User profiles as per July Release.
 |  10/11/2011    Suman B                           Calling createVPPCustomSettingData() in myUnitTest
 |  01-12-2011    Anil                              Fixed MIXED_DML Exception
 |  06/12/2011	  Anand Sharma						Update test class according to new theater  
 +=======================================================================================================*/
@isTest
   
  
  private class PRM_VPP_TestClassUtility {
    static Education__c education ; 
     
    static testMethod void myUnitTest() {      
      User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];
      
        System.RunAS(insertUser){
          PRM_VPP_JobDataHelper.createVPPCustomSettingData() ;
        }
        
    /* Creation of Account Grouping record.*/
      Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp');
      Insert grouping;
      
    /* Creation of Account record.*/  
      Account accounts =  new Account (Name = 'UNITTESTAcc', Country_Local__c = 'Japan',cluster__C = 'APJ', Grouping__c = grouping.Id, Batch_Job_Operation__c = 'Clustor/Theather Updated', profiled_Account_flag__c=true);
      Insert accounts;
      accounts.IsPartner = true;
      update accounts;
      
           
      List<Account> lstAccount = new List<Account>();
      lstAccount.add(accounts);
      
    /* Creation of Contact record.*/   
      Contact contact = new Contact (FirstName = 'UNIT', LastName = 'TESTCon', Account = accounts, Partner_Contact2__c = true);
      Insert contact;
    
    /* Creation of Education group record.*/   
      Education_Groups__c educationGroup = new Education_Groups__c (Education_Group_Name__c = 'UNITTESTEduGrp');
      Insert educationGroup;
    
    /* Creation of Education Master record.*/   
      Education_Master__c eduMaster = new Education_Master__c();
      Insert eduMaster;
    
    /* Creation of Education Group Member record.*/   
      Education_Group_Member__c eduMasterRec = new Education_Group_Member__c (Education_Group__c = educationGroup.Id, Education_Master__c = eduMaster.Id);
      Insert eduMasterRec;
    
    /* Creation of Education record.*/   
      education = new Education__c (Contact__c = contact.Id, Education_Master__c = eduMaster.Id, Batch_Job_Operation__c = 'Clustor/Theather Updated');
      Insert education;
    
    /* Creation of Education Education Group Mapping record.*/   
      Education_EducationGroup_Mapping__c educationEducationGroupMapping = new Education_EducationGroup_Mapping__c (Education_Group__c = educationGroup.Id, Education__c = education.Id);
      Insert educationEducationGroupMapping ;
      
    /* Creation of Velocity Rule Record.*/
      List<Velocity_Rules__c> velocityRulesRecords = new List<Velocity_Rules__c>();
        RecordType recordTypeSpecialty = [Select r.Id From RecordType r 
                                          where SobjectType = 'Velocity_Rules__c' 
                                          and Name = 'Specialty Rule'];
        System.Debug('---->'+ recordTypeSpecialty.Id); 
        RecordType recordTypeGroup = [Select r.Id From RecordType r 
                                      where SobjectType = 'Velocity_Rules__c' 
                                      and Name = 'Group Rule']; 
        RecordType recordTypeRollUp = [Select r.Id From RecordType r 
                                       where SobjectType = 'Velocity_Rules__c' 
                                       and Name = 'Roll Up Rule']; 
        RecordType recordTypeTier = [Select r.Id From RecordType r 
                                     where SobjectType = 'Velocity_Rules__c' 
                                     and Name = 'Tier Rule']; 
        
                                 
       for(integer i = 0; i<=5; i++){
            if(i<=1){  
               
                          Velocity_Rules__c velocityRuleRecordSpecialty = new Velocity_Rules__c();
                          velocityRuleRecordSpecialty.Display_Name__c = 'UNITTEST'+i;
                          velocityRuleRecordSpecialty.RecordTypeId = recordTypeSpecialty.Id;
                          velocityRuleRecordSpecialty.Cluster__c = 'APJ';
                          velocityRuleRecordSpecialty.Specialty_Rule_Type__c = 'LA1';
                          velocityRuleRecordSpecialty.Sort__c = 1;
   
                          velocityRulesRecords.add(velocityRuleRecordSpecialty);
             
            }
            if(i==2||i==3){  
                          
                          Velocity_Rules__c velocityRuleRecordGroup = new Velocity_Rules__c();  
                          velocityRuleRecordGroup.Display_Name__c = 'UNITTEST'+i;
                          velocityRuleRecordGroup.RecordTypeId = recordTypeGroup.Id;
                          velocityRuleRecordGroup.Cluster__c = 'APJ';
                          velocityRuleRecordGroup.Specialty_Rule_Type__c = 'EMEA';
                
                          velocityRulesRecords.add(velocityRuleRecordGroup);
                
            }
            if(i==4){
            
                          Velocity_Rules__c velocityRuleRecordRollUp = new Velocity_Rules__c(); 
                          velocityRuleRecordRollUp.Display_Name__c = 'UNITTEST'+i;
                          velocityRuleRecordRollUp.RecordTypeId = recordTypeRollUp.Id;
                          velocityRuleRecordRollUp.Cluster__c = 'APJ';
                          velocityRuleRecordRollUp.Specialty_Rule_Type__c = 'APJ-M';
                          velocityRulesRecords.add(velocityRuleRecordRollUp);
                
           
            }
            if(i==5){    
            
                          Velocity_Rules__c velocityRuleRecordTier = new Velocity_Rules__c(); 
                          velocityRuleRecordTier.Display_Name__c = 'UNITTEST'+i;
                          velocityRuleRecordTier.RecordTypeId = recordTypeTier.Id;
                          velocityRuleRecordTier.Cluster__c = 'APJ';
                          velocityRuleRecordTier.Specialty_Rule_Type__c = 'NA';
                          velocityRulesRecords.add(velocityRuleRecordTier);
               
            }
        }
        Insert velocityRulesRecords;
      
      /* Creating list of velocity rule Ids.*/  
        List<Id> velocityRulesId = new list<Id>();
            for (Integer j=0; j<=5; j++) {
              velocityRulesId.add(velocityRulesRecords[j].Id);
             }
        
      /* Creation of Education Group record.*/
        
            Velocity_Rule_Member__c eduGroupRecord1 = new Velocity_Rule_Member__c (Group__c = educationGroup.Id, Speciality_Rule__c = velocityRulesRecords[0].Id);
            Insert eduGroupRecord1;
           
            Velocity_Rule_Member__c eduGroupRecord2 = new Velocity_Rule_Member__c (Group__c = educationGroup.Id, Speciality_Rule__c = velocityRulesRecords[2].Id);
            Insert eduGroupRecord2;
            
         
            Velocity_Rule_Member__c eduGroupRecord3 = new Velocity_Rule_Member__c (Group__c = educationGroup.Id, Speciality_Rule__c = velocityRulesRecords[4].Id);
            Insert eduGroupRecord3;
          
            Velocity_Rule_Member__c eduGroupRecord4 = new Velocity_Rule_Member__c (Group__c = educationGroup.Id, Speciality_Rule__c = velocityRulesRecords[5].Id);
            Insert eduGroupRecord4;
            
      /* Creating list of Velocity Rule Results.*/  
         List<Velocity_Rule_Results__c> lstVelocityRuleResult = new List<Velocity_Rule_Results__c>();    
         Velocity_Rule_Results__c velocityRuleResult = new Velocity_Rule_Results__c (AccountID__c = accounts.Id, Grouping__c = grouping.Id, Speciality_RuleID__c = velocityRulesRecords[1].Id);   
         lstVelocityRuleResult.add(velocityRuleResult); 
         
         Insert lstVelocityRuleResult;
         system.debug('------>lstVRR'+lstVelocityRuleResult);
         String ruleResultQuery = 'Select e.Batch_Job_Operation__c, e.Id, Education_Master__c from Education__c e where id=education.id';
                                  
         String ruleResultQuery1 = 'Select Id, Grouping__c,Batch_Job_Operation__c,Specialty_Rule_Type__c,Cluster__c from Account e where e.Name = \'UNITTESTAcc\''; 
        
         String ruleResultQuery2 = 'Select Revenue_Amount__c, Required_value_Type__c,v.Speciality_RuleID__c, v.Rule_theater__c, v.RequiredCount__c,Speciality_RuleID__r.RecordType.Name ,Speciality_RuleID__r.RecordType.DeveloperName,'
                                  + 'v.Name, v.Grouping__c, v.Current__c, v.Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,'
                                  + 'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,'
                                  + 'Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c, '
                                  + 'Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,'
                                  + 'Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.Theater__c,'
                                  + 'Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,'
                                  + 'v.AccountID__c From Velocity_Rule_Results__c v ORDER BY v.Grouping__c limit 200' ;
                                     
        
         String ruleResultQuery3 = 'Select a.PROFILED_ACCOUNT_FLAG__c, a.Name, Theater1__c, a.Id, a.Grouping__c From Account a '
                                  + 'where profiled_Account_flag__c=true and Grouping__c!=null and name = \'UNITTESTAcc\'' ;
        
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
        
                         
        Test.StartTest();
               
             String DeleteResultsQuery ='select Id from Education_EducationGroup_Mapping__c where createddate <'+ new PRM_CommonUtils().getQueryFormattedDate(System.now())+'limit 200';
         /* Calling batch class PRM_VPP_DeleteRecordsJob*/
             id batchinstanceid = database.executeBatch(new PRM_VPP_DeleteRecordsJob(DeleteResultsQuery));
             
         /* Calling batch class PRM_VPP_EducationEduationMasterGroupJob*/     
             id batchinstanceid1 = database.executeBatch(new PRM_VPP_EducationEduationMasterGroupJob(ruleResultQuery));
             
         /* Calling batch class PRM_VPP_VelocityRuleResultJob1    
             id batchinstanceid2 = database.executeBatch(new PRM_VPP_VelocityRuleResultJob1(ruleResultQuery1));
             
          Calling batch class PRM_VPP_VelocityRuleEvaluatorJob    
             id batchinstanceid3 = database.executeBatch(new PRM_VPP_VelocityRuleEvaluatorJob(ruleResultQuery2));
             
         Calling batch class PRM_VPP_RollupRuleEvaluatorJob            
            id batchinstanceid4 = database.executeBatch(new PRM_VPP_RollupRuleEvaluatorJob(ruleResultQuery3)); */
             
         /* Calling scheduler class PRM_VPP_VelocityRuleResultJob1*/     
            //String sch = '20 30 8 10 2 ?';
            //System.schedule('Job',sch, new PRM_VPP_VelocityRuleResultJob1());
            List<SequencialBatchJob>LstSeqJobs = new List<SequencialBatchJob>(); 
	        PRM_VPP_VelocityRuleResultJob1  job1= new PRM_VPP_VelocityRuleResultJob1();       
	        LstSeqJobs.add(new SequencialBatchJob('PRM_VPP_VelocityRuleResultJob1' ,job1,20));       
	        //SequencialBatchJobScheduler.executeSequence(LstSeqJobs);
                 
         /* Calling scheduler class PRM_VPP_RollupRuleEvaluatorJob*/     
            //System.schedule('Job1',sch, new PRM_VPP_RollupRuleEvaluatorJob());        	
	        PRM_VPP_RollupRuleEvaluatorJob  job2= new PRM_VPP_RollupRuleEvaluatorJob();       
	        LstSeqJobs.add(new SequencialBatchJob('PRM_VPP_RollupRuleEvaluatorJob' ,job2,20));       
	        SequencialBatchJobScheduler.executeSequence(LstSeqJobs);
        	
             PRM_VPP_VelocityRuleResults obj1 = new PRM_VPP_VelocityRuleResults(velocityRulesRecords);
             PRM_VPP_VelocityRuleResultsUtils.deleteVelocityRuleResults(velocityRulesId);
             PRM_VPP_VelocityRuleResultsUtils.deleteVelocityRuleResults(lstAccount);
         /* Calling class PRM_VPP_VelocitySpecialities*/
             Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
             String distributionVAR = data.get('EMEA Distribution VAR Partner User').DataValue__c ;
             //Added by Anil
             
                List<Account> lstAccounts=AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
                insert lstAccounts;
                for(Account acc : lstAccounts)
                {
                    acc.IsPartner=true;
                    acc.PROFILED_ACCOUNT_FLAG__c =true;
                    acc.Cluster__c='EMEA 1B';
                }
                update lstAccounts;
                Contact con = UserProfileTestClassDataHelper.createContact();
                insert con;
                con.AccountId=lstAccounts[0].Id;
                con.Email='test23@emc.com';
                update con;
                System.RunAS(insertUser){
                  User partner = new User(
                           Username='test1234'+Math.random()+'@emc.com.test',
                           TimeZoneSidKey='America/New_York',
                           LocaleSidKey='en_US',
                           FirstName='Direct',
                           LastName='Rep',
                           ProfileId = '00e70000001FhPm',
                           UserRoleId = null,
                           email='john@emc.com',
                           Alias='test',
                           EmailEncodingKey='ISO-8859-1',
                           LanguageLocaleKey='en_US',
                           Forecast_Group__c='Direct',
                           BU__c='NA',
                           Employee_Number__c='9323782818',
                           IsActive=true,
                           ContactId=con.Id
                                       
                      );
                insert partner;                
                partner.IsPortalEnabled=true;
                partner.isActive=True;
                update partner;
     
             System.runAs(partner){
             PRM_VPP_VelocitySpecialities obj2 = new PRM_VPP_VelocitySpecialities();
             obj2.updateProfileAccount();
             List<SelectOption> selOption = obj2.getEMCSpecialityStatusItems();
             PageReference returnPage = obj2.cancelUpdates();
         
             }
             }
         /* Calling controller PRM_VPP_VelocityComponentController */ 
             PRM_VPP_VelocityComponentController obj3 = new PRM_VPP_VelocityComponentController();
             List<Velocity_Rule_Results__c> lstVelRuleRes = obj3.getSpecialityList();
             
             obj3.setSpecialityList(lstVelocityRuleResult);
             
         /* Calling class PRM_VPP_RuleEvaluator */
             Velocity_Rules__c velocityRuleRecord = new Velocity_Rules__c();
                               velocityRuleRecord.Display_Name__c = 'UNITTESTtest';
                               velocityRuleRecord.RecordTypeId = recordTypeSpecialty.Id;
                               velocityRuleRecord.Cluster__c = 'APJ';
                               velocityRuleRecord.Specialty_Rule_Type__c = 'LA1';
                               velocityRuleRecord.Velocity_Rule_1__c = velocityRulesRecords[3].Id;
               PRM_VPP_RuleEvaluator obj5 = new PRM_VPP_RuleEvaluator(lstAccount); 
                
               String testString = obj5.isSSCP(accounts);    
               testString = obj5.isVSI(accounts);
               testString = obj5.isVelocityProgram(accounts);
               testString = obj5.isTraining(velocityRuleRecord,velocityRuleResult);
               testString = obj5.getRevenueRange(velocityRuleResult);
             Map<String,String> testMap = obj5.checkComplianceStatus(accounts,lstVelocityRuleResult);
            Test.StopTest();
        }
        
        static testMethod void myUnitTestForRevenue() {
            Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp');
            Insert grouping;
          
            /*Creation of Account record */ 
            Account account =  new Account (Name = 'UNITTESTVPP', cluster__C = 'APJ', Grouping__c = grouping.Id,PROFILED_ACCOUNT_FLAG__c = true);
            Insert account;
           
            Velocity_Revenue__c objRevenue = new Velocity_Revenue__c();
            objRevenue.Partner_Profiled_Account__c = account.Id;
            objRevenue.C_Curr_Per_Rev_HW_SW__c=200000;
            objRevenue.C_Curr_Per_Rev_SVS__c=0;
            objRevenue.C_Prev_Per_Rev_HW_SW__c=0;
            objRevenue.C_Prev_Per_Rev_SVS__c=0;
            insert objRevenue; 
            
            System.Debug('Anand objRevenue --->' + objRevenue);
        }
  }