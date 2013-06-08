/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  02/16/2011    Arif Sheikh                   Extension test class for the class PRM_VPP_TestClassUtility 
 |  10/11/2011    Suman B                           Calling createVPPCustomSettingData() in Test methods.                         
 +=======================================================================================================*/
@isTest

  private class PRM_VPP_TestClassUtilityExtension {
  
    static testMethod void myUnitTest() {
     User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
      /* Creation of Account Grouping record.*/
      Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp');
      Insert grouping;
      
    /* Creation of Account record.*/  
      Account accounts =  new Account (Name = 'UNITTESTAcc', Country_Local__c = 'Japan',cluster__C = 'APJ', Grouping__c = grouping.Id, Batch_Job_Operation__c = 'Clustor/Theather Updated', profiled_Account_flag__c=true);
      Insert accounts;
      
      List<Account> lstAccount = new List<Account>();
      lstAccount.add(accounts);
      
    /* Creation of Contact record.*/   
      Contact contact = new Contact (FirstName = 'UNIT', LastName = 'TESTCon', Account = accounts);
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
      Education__c education = new Education__c (Contact__c = contact.Id, Education_Master__c = eduMaster.Id, Batch_Job_Operation__c = 'Clustor/Theather Updated');
      Insert education;
    
    /* Creation of Education Education Group Mapping record.*/   
      Education_EducationGroup_Mapping__c educationEducationGroupMapping = new Education_EducationGroup_Mapping__c (Education_Group__c = educationGroup.Id, Education__c = education.Id);
      Insert educationEducationGroupMapping ;
      List<Education_EducationGroup_Mapping__c> lstEduedugroupmapping = new List<Education_EducationGroup_Mapping__c>();
      lstEduedugroupmapping.add(educationEducationGroupMapping);
      
    /* Creation of Velocity Rule Record.*/
      List<Velocity_Rules__c> velocityRulesRecords = new List<Velocity_Rules__c>();
        RecordType recordTypeSpecialty = [Select r.Id, r.DeveloperName From RecordType r 
                                          where SobjectType = 'Velocity_Rules__c' 
                                          and Name = 'Specialty Rule']; 
        System.debug('------->'+recordTypeSpecialty);                                   
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
                          velocityRuleRecordSpecialty.Bucket__c = 'Revenue';
   
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
        System.debug('---->'+velocityRulesRecords[0]);
      
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
         Velocity_Rule_Results__c velocityRuleResult = new Velocity_Rule_Results__c (AccountID__c = accounts.Id, Grouping__c = grouping.Id, Speciality_RuleID__c = velocityRulesRecords[0].Id);   
         lstVelocityRuleResult.add(velocityRuleResult); 
         
         Insert lstVelocityRuleResult;
         System.debug('---->'+velocityRuleResult.Speciality_RuleID__c);
               
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
        
        
        Test.StartTest();
        
         /* Calling batch class PRM_VPP_VelocityRuleResultJob1*/    
             id batchinstanceid2 = database.executeBatch(new PRM_VPP_VelocityRuleResultJob1(ruleResultQuery1));
             
         /* Calling batch class PRM_VPP_VelocityRuleEvaluatorJob*/    
             id batchinstanceid3 = database.executeBatch(new PRM_VPP_VelocityRuleEvaluatorJob(ruleResultQuery2));
             
         /* Calling batch class PRM_VPP_RollupRuleEvaluatorJob */           
            id batchinstanceid4 = database.executeBatch(new PRM_VPP_RollupRuleEvaluatorJob(ruleResultQuery3)); 
         
         /* Calling class PRM_VPP_RuleEvaluator */  
            //PRM_VPP_RuleEvaluator obj = new PRM_VPP_RuleEvaluator(lstVelocityRuleResult);
            PRM_VPP_RuleEvaluator obj1 = new PRM_VPP_RuleEvaluator(lstAccount);
            Set<Id> setId = obj1.evaluateGroupRule(velocityRulesRecords[0],lstVelocityRuleResult[0]); 
            Integer i = obj1.evaluateSpecialtyRule(velocityRulesRecords[0],lstVelocityRuleResult[0]);
             
             
        Test.StopTest();
        }
  }