/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  11/21/2012    Vivek kodi                        Unit Test for PRM_BatchDeleteEducation class |
 |  05/22/2012    Suresh Dornadula      239600      Added Isilon Track in the query of the method PRM_PAN_VPP_VelocityRuleResultJob1
 +=======================================================================================================*/

@isTest
public class PRM_ESBI_VPP_Batch_TC {    
  
     static testMethod void VPP_StagingDataOperator(){
            
            List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
            CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
            dataValueControlFlag.Name ='ESBI_Int_Control_Flag_Sequence';
            dataValueControlFlag.DataValue__c ='2';
            lstDataValue.add(dataValueControlFlag);
            try
            {
               Database.insert(lstDataValue, false);
            }catch(Exception e){
               System.debug('Check Obj Access'+e); 
            }
            
             CustomSettingDataValueMap__c   seqeunceId = CustomSettingDataValueMap__c.getValues('ESBI_Int_Control_Flag_Sequence');
               Integer sequenceId =  Integer.valueOf(seqeunceId.DataValue__c);
               Integer batchId =  sequenceId -1 ;   
                
            String stagingQuery = 'Select Id, Text1__c, Text2__c, Text3__c , Text4__c, Text5__c, Text6__c, Text7__c,'
                              + ' Text8__c, text9__c, Text10__c,Text12__c, Text11__c, Date1__c , Date2__c,Batch_Id__c,Text14__c from Staging_Data__c ' 
                              +  'where is_Header__c != true AND Object_Name__c =\'Education\' AND Text14__c= null  AND Batch_Id__c ='+batchId+' limit 1';
            
            System.test.startTest();
            PRM_ESBI_VPP_StagingDataOperator vppStage = new PRM_ESBI_VPP_StagingDataOperator(stagingQuery);
            id batchids = Database.executebatch(vppStage);
            System.test.stopTest();
        
     }
     
     static testMethod void PRM_PAN_VPP_VelocityRuleResultJob1(){
        
       // Account_Groupings__c PAN  = createPAN();
        String ruleResultQuery =  'SELECT Account__c, Advanced_Consolidate_Specialty__c, Backup_and_Recovery_Specialty__c, Cluster__c, '+
                                  ' Compliance_Period_Requirments_Met__c, Consolidate_Specialty__c, Deployed_To__c, Name,Active__c ' +
                                  ' Governance_and_Archive_Specialty__c, Isilon_Track_Specialty__c, Local_Requirment_Set__c, Logical_Block_Level_Grouping__c, '+ 
                                  ' Pan_Theater_Level_Grouping__c, Speciality_Type__c,RecordType.DeveloperName,Theater2__c, Target_Tier__c,Velocity_Specaility_Achieved__c, RecordTypeId '+
                                  ' FROM Account_Groupings__c where (RecordType.DeveloperName=\'Partner_Grouping_Logical_Block\''+
                                  ' OR RecordType.DeveloperName=\'Partner_Grouping_PAN_Theater\') AND Active__c = true limit 1 ';
              
              System.test.startTest();
               id  velocity = Database.executebatch( new PRM_PAN_VPP_VelocityRuleResultJob1(ruleResultQuery),200);
              System.test.stopTest();
     }
     
     static testMethod void PRM_PAN_VPP_VelocityRuleEvaluatorJob(){     
        
         String ruleResultQuery = 'Select Revenue_Amount__c, Required_value_Type__c,v.Speciality_RuleID__c, v.Rule_theater__c, v.RequiredCount__c,Speciality_RuleID__r.RecordType.Name ,Speciality_RuleID__r.RecordType.DeveloperName,'
                               + 'v.Name, v.Grouping__c, v.Current__c, v.Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,Speciality_RuleID__r.Value__c, '
                               + 'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.Any_Value_Acceptable__c, '
                               + 'Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c,Speciality_RuleID__r.Evaluation_at__c, '
                               + 'Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,v.Grouping__r.RecordType.DeveloperName,Speciality_RuleID__r.Required__c,Speciality_RuleID__r.Local_Requirment_Set__c, '
                               + 'Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.Theater__c,'
                               + 'Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,'
                               + 'v.AccountID__c From Velocity_Rule_Results__c v where Grouping__r.RecordType.DeveloperName = \'Partner_Grouping_PAN_Theater\' '
                               + 'OR Grouping__r.RecordType.DeveloperName = \'Partner_Grouping_Logical_Block\' limit 1' ;
        
         System.test.startTest(); 
           id batchids = Database.executebatch(new PRM_PAN_VPP_VelocityRuleEvaluatorJob(ruleResultQuery),200);
          System.test.stopTest();
     
     }
     static testMethod void PRM_PopulateEducationMasterBatch(){
       
         string batchQuery = 'Select s.Date1__c, s.Date2__c, s.Id, s.Number1__c, s.Object_Name__c, s.Text1__c,'
                                    +' s.Text2__c, s.Text3__c, s.Text4__c, s.Text5__c , s.Text6__c from Staging_Data__c s'
                                    + ' where s.Object_Name__c=\'Education Master\' limit 1';
                                    
          System.test.startTest();
           id populateid = Database.executebatch( new PRM_PopulateEducationMasterBatch(batchQuery),200);
          System.test.stopTest(); 
     }
     
     static testMethod void AccountPartnerSEFieldsUpdateBatch(){
     
         String queryAccount ='select id,grouping__c,PROFILED_ACCOUNT_FLAG__c,Partner_Leverage_Factor_Average__c,'+
                              'Partner_Leverage_Factor_Total__c,name,theater1__c,velocity_Solution_Provider_Tier__c,'+
                              '(select contact.id,contact.Partner_Leverage_Factor__c from account.contacts where contact.partner_se__c=true)'+
                              ' from account where PROFILED_ACCOUNT_FLAG__c=true and rating_eligible__c=true limit 1'; 
                              
              System.test.startTest();
               Database.executebatch(new AccountPartnerSEFieldsUpdateBatch(queryAccount),200);
              System.test.stopTest(); 
     
     }
     
     

}