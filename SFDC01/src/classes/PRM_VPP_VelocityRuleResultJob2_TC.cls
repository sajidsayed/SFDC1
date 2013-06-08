/*=========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  02/08/2011    Shalabh Sharma                    To test the class PRM_VPP_VelocityRuleResultJob2
 |  06/12/2011    Anand Sharma                      Update test class according to new theater                          
 +=======================================================================================================*/
@isTest
private class PRM_VPP_VelocityRuleResultJob2_TC {
    
    static testMethod void myUnitTest() {
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];    
         System.runAs(insertUser){
           PRM_VPP_JobDataHelper.createVPPCustomSettingData();
         }
        
        String ruleResultQuery = 'Select v.AND_OR__c, v.BR_Sub_category__c, v.Bucket__c, v.Display_Name__c,  '
          +  ' v.Field_Name__c, v.Id, v.LastModifiedDate, v.Name, v.RecordTypeId, v.Required__c, '
          +  ' v.Required_Type__c, v.Specialty_Rule_Type__c,v.RecordType.DeveloperName, '
          +  ' v.Specilaity__c, v.Theater__c, v.Tier__c, v.Velocity_Rule_1__c, v.Velocity_Rule_2__c, '
          +  ' v.Group_Rule_3__c, v.Group_Rule_4__c, v.Group_Rule_5__c '
          +  ' from Velocity_Rules__c v limit 3' ;
          
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
        Insert velocityRulesRecords;        
        
        Test.StartTest();
        
        
        //String sch = '20 30 8 10 2 ?';
        //System.schedule('Job',sch, new PRM_VPP_VelocityRuleResultJob2());         
        
        PRM_VPP_VelocityRuleResultJob2 obj = new PRM_VPP_VelocityRuleResultJob2();
        PRM_VPP_VelocityRuleResultJob2 obj2 = new PRM_VPP_VelocityRuleResultJob2(ruleResultQuery);
        //ID batchprocessid1 = Database.executeBatch(obj2);
        
        //List<SequencialBatchJob>LstSeqJobs = new List<SequencialBatchJob>(); 
        //PRM_VPP_VelocityRuleResultJob2  job2= new PRM_VPP_VelocityRuleResultJob2(ruleResultQuery);       
        //LstSeqJobs.add(new SequencialBatchJob('PRM_VPP_VelocityRuleResultJob2' ,job2,20));       
        //SequencialBatchJobScheduler.executeSequence(LstSeqJobs); 
         
        
        Test.StopTest();             
    }
}