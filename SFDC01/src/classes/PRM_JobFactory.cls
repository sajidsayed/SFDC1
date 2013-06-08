/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  
     05/08/2012    Prasad                       This class gives the jobs for processing 
     13-Sep-2012   Prasad                       Added delta for all VPP related jobs - PAN,PL,Funcational Area   
     05-Oct-2012   Prasad                       Changing sequence and adding Rollup rule evaluator in all level - country,LB and PAN
                                                as the job refres the values from account fields like specilities    
	Prasad - Added job for Service Score Cards  
	Prasad - Changed condition for Education-EducationGrouping Job   
	Anand -- Added Fixed for Calculation
 |	21-May-2013 	Sravanthi		WR212889	Added Required__c field and modified order by sequence in the query @ getVPPRuleEvaluaterJob
 | 22/05/2013      Suresh Dornadula WR#239600   Added the Isilon_Track_Specialty__c to the queries and respective methods              
 +=========================================================================================================================*/
  
 
public class PRM_JobFactory {
    
    String LastRan; 
    public Boolean ProcessDeltaOnly=false;
    public Boolean ProcessTheaterWise=true;   
    String Theater;
    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll(); 
    CustomSettingDataValueMap__c ESBI_VPP_Scheduled_Theaters = DataValueMap.get('ESBI_VPP_Scheduled_Theaters'); 
    CustomSettingDataValueMap__c IS_PL_Scheduled_Theaters = DataValueMap.get('IS_PL_Scheduled_Theaters');
    
    String wholeTheaterToProcess ='None';
    String wholeClusterToProcess ='None';
    String wholeTierToProcess ='None';
    String wholeSpecialityTypeToProcess ='None';
    
    public  PRM_JobFactory(){
        System.debug('ProcessDeltaOnly 1 '+ProcessDeltaOnly);
        String delta=DataValueMap.get('PRM_VPP_ProcessDeltaOnly').datavalue__c;
        if(delta=='Yes' || delta=='Y' ){
            ProcessDeltaOnly=true;
        }else{
            ProcessDeltaOnly=false;
        }
        CustomSettingDataValueMap__c lastrun =DataValueMap.get('PRM_VPP_Last_Job_Ran_on');
        LastRan =(lastrun.DataValue__c);
            
        lastrun.DataValue__c=new PRM_CommonUtils().getQueryFormattedDate(System.now());
        update lastrun;
        
        
        CustomSettingDataValueMap__c PRM_VPP_ProcessWholeTheater =DataValueMap.get('PRM_VPP_ProcessWholeTheater');
        wholeTheaterToProcess =(PRM_VPP_ProcessWholeTheater.DataValue__c);  
        
        System.debug('wholeTheaterToProcess '+wholeTheaterToProcess);
        PRM_VPP_ProcessWholeTheater.DataValue__c='None';
        update PRM_VPP_ProcessWholeTheater;
        
        CustomSettingDataValueMap__c PRM_VPP_ProcessWholeCluster =DataValueMap.get('PRM_VPP_ProcessWholeCluster');
        wholeClusterToProcess =(PRM_VPP_ProcessWholeCluster.DataValue__c);
        
        PRM_VPP_ProcessWholeCluster.DataValue__c='None';
        update PRM_VPP_ProcessWholeCluster;
        
        CustomSettingDataValueMap__c PRM_VPP_ProcessWholeTier =DataValueMap.get('PRM_VPP_ProcessWholeTier');
        wholeTierToProcess =(PRM_VPP_ProcessWholeTier.DataValue__c);        
        
        PRM_VPP_ProcessWholeTier.DataValue__c='None';
        update PRM_VPP_ProcessWholeTier;
        
        CustomSettingDataValueMap__c PRM_VPP_ProcessWholeSpecialityType =DataValueMap.get('PRM_VPP_ProcessWholeSpecialityType');
        wholeSpecialityTypeToProcess =(PRM_VPP_ProcessWholeSpecialityType.DataValue__c);        
        
        PRM_VPP_ProcessWholeSpecialityType.DataValue__c='None';
        update PRM_VPP_ProcessWholeSpecialityType;
      
        System.debug('ProcessDeltaOnly 2 '+ProcessDeltaOnly);
        
    }
    
    public  SequencialBatchJob getStagingTheaterJob(){
        // Job 1
        CustomSettingDataValueMap__c   seqeunceId = CustomSettingDataValueMap__c.getValues('ESBI_Int_Control_Flag_Sequence');
        Integer sequenceId =  Integer.valueOf(seqeunceId.DataValue__c);
        Integer batchId =  sequenceId -1 ;
  
        String stagingQuery = 'Select Id, Text1__c, Text2__c, Text3__c , Text4__c, Text5__c, Text6__c, Text7__c,'
                              + ' Text8__c, text9__c, Text10__c,Text12__c, Text11__c, Date1__c , Date2__c,Batch_Id__c,Text14__c from Staging_Data__c ' 
                              +  'where is_Header__c != true AND Object_Name__c =\'Education\' AND Text14__c= null  AND Batch_Id__c ='+ batchId ;
          
         System.debug('stagingQuery '+stagingQuery);                     
        //Here we are instantiating the batch class PRM_PopulateEducationMasterBatch to schedule.               
        PRM_ESBI_VPP_StagingDataOperator Job1 = new PRM_ESBI_VPP_StagingDataOperator(stagingQuery);          
          
        SequencialBatchJob job=new SequencialBatchJob('PRM_ESBI_VPP_StagingDataOperator', Job1,200);
        System.debug('Edu Master Job '+job);
        return job; 
       
   }   
    
    public  SequencialBatchJob getEducationMasterJob(){
        // Job 1
            CustomSettingDataValueMap__c   seqeunceId = CustomSettingDataValueMap__c.getValues('ESBI_Int_Control_Flag_Sequence');
            Integer sequenceId =  Integer.valueOf(seqeunceId.DataValue__c);
            Integer batchId =  sequenceId -1 ;
      
            string batchIdQuery = 'Select s.Date1__c, s.Date2__c, s.Id, s.Number1__c, s.Object_Name__c, s.Text1__c,'
                                  +' s.Text2__c, s.Text3__c, s.Text4__c, s.Text5__c , s.Text6__c,Text14__c  from Staging_Data__c s'
                                  + ' where s.Object_Name__c=\'Education Master\' AND Batch_Id__c ='+ batchid;
               
                System.debug('getEducationMasterJob '+batchIdQuery);                    
              //Here we are instantiating the batch class PRM_PopulateEducationMasterBatch to schedule.               
              PRM_PopulateEducationMasterBatch Job1 = new PRM_PopulateEducationMasterBatch(batchIdQuery);          
              
              SequencialBatchJob job=new SequencialBatchJob('PRM_PopulateEducationMasterBatch', Job1,200);
              System.debug('Edu Master Job '+job);
              return job; 
       
   } 
    
    public List<SequencialBatchJob> getVPPJobs(String Theater,String level){
        System.debug('Called getVPPJobs '+ Theater + ' ' +level);
        
        List<SequencialBatchJob>Jobs = new List<SequencialBatchJob>(); 
        integer batchSize; 
       
       //Taking out this jov movd to education trigger
       // Run only if any educations masters are marked to process
		try{
            String ruleResultQuery = 'Select e.Batch_Job_Operation__c, e.Id,Education_Master__c '
                                       + 'from Education__c e ';
			if (Theater !='All'){                                   
                ruleResultQuery =ruleResultQuery + '  where Theater__c =\''+Theater+'\'';
			}                           
			// Datetime lastjobran=  datetime.valueOf(LastRan); 
			if(ProcessDeltaOnly){
                datetime lastjobran =  datetime.newInstance(Integer.valueOf(LastRan.substring(0,4)), Integer.valueOf(LastRan.substring(5,7)), Integer.valueOf(LastRan.substring(8,10)));
    
                Education_Master__c  edu =[SELECT Process_On_After__c, Id FROM Education_Master__c where Process_On_After__c >= :lastjobran limit 1];
                System.debug('edu :'+ edu );
               
                if(edu!=null){
                    ruleResultQuery =ruleResultQuery + ' and Education_Master__r.Process_On_After__c >='+LastRan;                     
                    
                }
            }
			
            System.debug('ruleResultQuery '+ruleResultQuery);
            PRM_VPP_EducationEduationMasterGroupJob job2= new PRM_VPP_EducationEduationMasterGroupJob(ruleResultQuery);
            //get batch size
            try{            
                batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_EducationEduMasterGroupJob').DataValue__c);
            }catch(Exception e){
                batchSize = 20;
            } 
            Jobs.add(new SequencialBatchJob('Build Education and Education Group Mappings '+Theater,Job2,200));                                        
            System.debug('Scheduled -Build Education and Education Group Mappings');
		}catch(Exception e){
            System.debug('No Education Master changed,removed or added on education groups.');
        
		}
       
     //==============================================================================================================
        
            String DeleteVelocityRuleResultsQuery='select Id from Velocity_Rule_Results__c where createddate <'
                                                + new PRM_CommonUtils().getQueryFormattedDate(System.now());
            
            System.debug('ProcessDeltaOnly 2 '+ProcessDeltaOnly);
             if (Theater !='All'){                                  
                DeleteVelocityRuleResultsQuery =DeleteVelocityRuleResultsQuery + ' and Account_Theater__c =\''+Theater+'\'';
            }
            
            if (ProcessDeltaOnly ){
                 
                 DeleteVelocityRuleResultsQuery = DeleteVelocityRuleResultsQuery + ' and '+ getDeltaClause( ' Grouping__r.Process_On_After__c ', ' Speciality_RuleID__r.Theater__c ', ' Speciality_RuleID__r.Cluster__c ', 'Speciality_RuleID__r.Tier__c ', ' Speciality_RuleID__r.Specialty_Rule_Type__c ');       
            }
            //level='All' Take as is no filter
            if( level=='Country' ){ 
                DeleteVelocityRuleResultsQuery = DeleteVelocityRuleResultsQuery + ' and Grouping__r.RecordType.DeveloperName= \'Partner_Grouping\' ';
            }else if(level=='Logical Block'){
                DeleteVelocityRuleResultsQuery =  DeleteVelocityRuleResultsQuery +  ' and Grouping__r.RecordType.DeveloperName= \'Partner_Grouping_Logical_Block\'';
            }else if(level=='PAN Theater'){
                DeleteVelocityRuleResultsQuery =  DeleteVelocityRuleResultsQuery + ' and Grouping__r.RecordType.DeveloperName= \'Partner_Grouping_PAN_Theater\'';
            }
            System.debug('DeleteVelocityRuleResultsQuery '+DeleteVelocityRuleResultsQuery);
            
            PRM_VPP_DeleteRecordsJob job3= new PRM_VPP_DeleteRecordsJob(DeleteVelocityRuleResultsQuery);
            Jobs.add(new SequencialBatchJob('Delete VelocityRuleResults '+Theater,Job3,200));  
        
     //==============================================================================================================
        
            if( level=='All' || level=='Country' ){ 
            String ruleResultQuery1 = 'Select Id, Grouping__c,Batch_Job_Operation__c,Specialty_Rule_Type__c,Cluster__c,Velocity_Solution_Provider_Tier__c, Grouping__r.Local_Requirment_Set__c,'
                                           +' Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c,Consolidate_Compliance_Status__c, '
                                           +' Governance_and_Archive_Compliance_Status__c,Velocity_Compliance_Status__c, Education_Data_Refresh_Date__c,Deployed_Velocity_Services__c ' 
                                           + ' from Account e where velocity_Solution_Provider_Tier__c!=\'\' and profiled_Account_flag__c=true and '
                                           +'  Grouping__c!=null ';
            if (Theater !='All'){                                  
                ruleResultQuery1 =ruleResultQuery1 +' and Theater1__c =\''+Theater+'\'';
            }
            
            if (ProcessDeltaOnly ){
                 ruleResultQuery1 = ruleResultQuery1 + ' and '+ getDeltaClause( ' Grouping__r.Process_On_After__c ', ' Theater1__c ', ' Cluster__c ', ' Velocity_Solution_Provider_Tier__c  ', ' Specialty_Rule_Type__c ');       
            }
            
            // Add condition to skip LB and PAN
            ruleResultQuery1 =ruleResultQuery1 + ' and (Grouping__r.Logical_Block_Level_Grouping__c = null or Grouping__r.Logical_Block_Level_Grouping__r.Target_Tier__c =\'\') and ';
            ruleResultQuery1 =ruleResultQuery1 + '  (Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c = null or Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Target_Tier__c =\'\' ) ';
            
            
            
            System.debug('ruleResultQuery1 '+ruleResultQuery1);
            PRM_VPP_VelocityRuleResultJob1 job4 = new PRM_VPP_VelocityRuleResultJob1(ruleResultQuery1);
            //get batch size
            try{            
                batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleResultJob1').DataValue__c);
            }catch(Exception e){
                batchSize = 20;
            } 
            Jobs.add(new SequencialBatchJob('BuildVelocityRuleResults '+Theater,Job4,batchSize)); 
     }
   //==============================================================================================================
   // Service Scorecards job
   if( level=='All' || level=='Country' ){ 
            String ruleResultQuery1 = 'Select Id, Grouping__c,Batch_Job_Operation__c,Specialty_Rule_Type__c,Cluster__c,Velocity_Solution_Provider_Tier__c, Grouping__r.Local_Requirment_Set__c,'
                                           +' Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c,Consolidate_Compliance_Status__c, '
                                           +' Governance_and_Archive_Compliance_Status__c,Velocity_Compliance_Status__c, Education_Data_Refresh_Date__c,Deployed_Velocity_Services__c ' 
                                           + ' from Account e where velocity_Solution_Provider_Tier__c!=\'\' and profiled_Account_flag__c=true and '
                                           +'  Grouping__c!=null ';
            if (Theater !='All'){                                  
                ruleResultQuery1 =ruleResultQuery1 +' and Theater1__c =\''+Theater+'\'';
            }
            
            if (ProcessDeltaOnly ){
                 ruleResultQuery1 = ruleResultQuery1 + ' and '+ getDeltaClause( ' Grouping__r.Process_On_After__c ', ' Theater1__c ', ' Cluster__c ', ' Velocity_Solution_Provider_Tier__c  ', ' Specialty_Rule_Type__c ');       
            }
            
            // For service rule - Apllicable for all accounts - PAN model is not applicable for service rules.                
            // Add condition to skip LB and PAN
            //ruleResultQuery1 =ruleResultQuery1 + ' and (Grouping__r.Logical_Block_Level_Grouping__c = null or Grouping__r.Logical_Block_Level_Grouping__r.Target_Tier__c =\'\') and ';
            //ruleResultQuery1 =ruleResultQuery1 + '  (Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c = null or Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Target_Tier__c =\'\' ) ';
            
            
            
            System.debug('ruleResultQuery1 '+ruleResultQuery1);
            PRM_VPP_VelocityRuleResultJob1 job4 = new PRM_VPP_VelocityRuleResultJob1(ruleResultQuery1);
            job4.EvaluateForServiceRule = true;
            //get batch size
            try{            
                batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleResultJob1').DataValue__c);
            }catch(Exception e){
                batchSize = 20;
            } 
            Jobs.add(new SequencialBatchJob('BuildVelocityRuleResults for Service Score cards '+Theater,Job4,batchSize)); 
     }
  //==============================================================================================================
        
        if(level=='All'){    
            Jobs.add( getPanVPPBuildVRRJobs(Theater,'Partner_Grouping_Logical_Block')); 
            Jobs.add( getPanVPPBuildVRRJobs(Theater,'Partner_Grouping_PAN_Theater'));  
            Jobs.add( getVPPRuleEvaluaterJob( Theater,'Partner_Grouping','All'));  // evaluate for LB and PAN as well
            
         // Adding the job rollup job evaluaton before PAN 
            Jobs.add( getRollupJob(Theater)); 

        Jobs.add( getVPPRuleEvaluaterJob( Theater,'Partner_Grouping_Logical_Block','Logical Block Grouping Level'));
            Jobs.add( getVPPRuleEvaluaterJob( Theater,'Partner_Grouping_PAN_Theater','PAN Theater Grouping Level'));   
        
        }else if(level=='Country'){
             Jobs.add(getVPPRuleEvaluaterJob( Theater,'Partner_Grouping','Country Grouping Level')); 
             Jobs.add( getRollupJob(Theater)); // Adding the job rollup job evaluaton before PAN   
        }else if(level=='Logical Block'){
            Jobs.add(getPanVPPBuildVRRJobs( Theater,'Partner_Grouping_Logical_Block'));
           
            // Adding the job rollup job evaluaton before PAN 
            Jobs.add( getRollupJob(Theater));  
              
            //Calculate Logical block rules at country level 
            Jobs.add(getVPPRuleEvaluaterJob( Theater,'Partner_Grouping','Logical Block Grouping Level'));   
            //Rollup at Logical block level
            Jobs.add(getVPPRuleEvaluaterJob(Theater,'Partner_Grouping_Logical_Block','Logical Block Grouping Level'));  
        
        }else if(level=='Pan Theater'){
            Jobs.add( getPanVPPBuildVRRJobs(Theater,'Partner_Grouping_PAN_Theater')); 
            
             // Adding the job rollup job evaluaton before PAN 
            Jobs.add( getRollupJob(Theater));  
           
            Jobs.add( getVPPRuleEvaluaterJob(Theater,'Partner_Grouping','PAN Theater Grouping Level')); 
            
            Jobs.add( getVPPRuleEvaluaterJob(Theater,'Partner_Grouping_PAN_Theater','PAN Theater Grouping Level'));
        }
      
      
    //==============================================================================================================    
    return Jobs;
        
    
    }
    public SequencialBatchJob getRollupJob(String Theater){
        String ruleResultQuery3 = 'Select a.PROFILED_ACCOUNT_FLAG__c, a.Name, Theater1__c, a.Id, a.Grouping__c,velocity_Solution_Provider_Tier__c, '
                                    +'Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c, '
                                    +'Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c, Deployed_Velocity_Services__c, '
                                    +'Velocity_Compliance_Status__c , Education_Data_Refresh_Date__c From Account a '
                                    +'where profiled_Account_flag__c=true and Grouping__c!=null ';
                               
            if (Theater !='All'){                                   
                ruleResultQuery3 =ruleResultQuery3 +'  and Theater1__c=\''+Theater+'\'';

            }
                
             if (ProcessDeltaOnly ){
                 ruleResultQuery3 = ruleResultQuery3 + ' and '+ getDeltaClause( ' Grouping__r.Process_On_After__c ', ' Theater1__c ', ' Cluster__c ', ' Velocity_Solution_Provider_Tier__c  ', ' Specialty_Rule_Type__c ');       
             }
            
            System.debug('ruleResultQuery3 '+ruleResultQuery3);  
            
            PRM_VPP_RollupRuleEvaluatorJob job6 = new PRM_VPP_RollupRuleEvaluatorJob(ruleResultQuery3);        
            //get batch size
            integer batchSize;  
            try{            
                batchSize  = Integer.valueOf(DataValueMap.get('RollupEvaluationBatchSize').DataValue__c);
            }catch(Exception e){
                batchSize = 20;
            } 
            return (new SequencialBatchJob('Evaluate Rollup Rules '+Theater,Job6,batchSize )); 
    }
    
    public List<SequencialBatchJob> getEducationMatchingJobs(String Theater){
          List<SequencialBatchJob>Jobs = new List<SequencialBatchJob>(); 
        integer batchSize =1;
        
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        
        CustomSettingDataValueMap__c   seqeunceId = CustomSettingDataValueMap__c.getValues('ESBI_Int_Control_Flag_Sequence');
        Integer sequenceId =  Integer.valueOf(seqeunceId.DataValue__c);
        Integer batchId =  sequenceId -1 ;
          


        // Job 2
          //Used to store the data mapping for the education master using the custom setting.
                             
                List<Staging_Data__c> lstStagingData = new List<Staging_Data__c>();
                lstStagingData =[Select Id from Staging_Data__c Where Object_Name__c='Education' LIMIT 1];
                
                if(lstStagingData.size()>0 ){
                     try{            
                        batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_EducationBatchSize').DataValue__c);
                    }catch(Exception e){
                        batchSize = 5;
                    }
                    String stagingQuery = 'Select Id, Text1__c, Text2__c, Text3__c , Text4__c, Text5__c, Text6__c, Text7__c,'
                              + ' Text8__c, text9__c, Text10__c,Text12__c, Text11__c, Date1__c , Date2__c,Batch_Id__c,Text14__c from Staging_Data__c ' 
                              +  'where is_Header__c != true AND Object_Name__c =\'Education\'  AND Batch_Id__c ='+ batchId ;
                              
                    if (Theater !='All'){                                   
                        stagingQuery =stagingQuery +'  and Text14__c=\''+Theater+'\'';
                    }   
                   stagingQuery =stagingQuery +'order by Text4__c,Text1__c,Text3__c,Text2__c';  
                   
                   PRM_BatchCreateEducationFromStaging job2 = new PRM_BatchCreateEducationFromStaging(stagingQuery);
                   Jobs.add(new SequencialBatchJob('PRM_BatchCreateEducationFromStaging for '+theater ,job2,batchSize)); 
                       
                }


        // job 3  
        
                   try{            
                        batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_EducationDeleteBatchSize').DataValue__c);
                    }catch(Exception e){
                        batchSize = 20;
                    }
                
                        String ScheduleNowTime = String.valueOfGmt(DateTime.Now());
                        ScheduleNowTime  = ScheduleNowTime.replace(' ', 'T');
                        ScheduleNowTime = ScheduleNowTime +'.000Z';
        
                CustomSettingDataValueMap__c jobDeleteEducationTime = DataValueMap.get('EducationDeleteScheduleTime');
                String strSchedule =jobDeleteEducationTime.DataValue__c;
                String educationQuery = 'Select Id, Name from Education__c where  lastModifieddate < ' + ScheduleNowTime ;                                    
                
                if (Theater !='All'){                                   
                        educationQuery =educationQuery +'  and Theater__c=\''+Theater+'\'';
                }
                
                PRM_BatchDeleteEducation  job3= new PRM_BatchDeleteEducation(educationQuery);
                Jobs.add(new SequencialBatchJob('PRM_BatchDeleteEducation  for '+theater ,job3,batchSize));
        
        return Jobs; 
    
    }
    

    public List<SequencialBatchJob> getPartnerLevrageJobs(String Theater){
        List<SequencialBatchJob> SelectedPLJobs= new List<SequencialBatchJob> ();
            
        if(IS_PL_Scheduled_Theaters != null && IS_PL_Scheduled_Theaters.DataValue__c =='YES'){
            
            String query = 'select id,name,partner_se__c,accountid, Account.Profiled_Account__c,Account.PROFILED_ACCOUNT_FLAG__c,'
                            +' Account.Profiled_Account__r.rating_eligible__c, Account.Grouping__c, emc_pre_sales__c,account.rating_eligible__c'+
                            +',account_theater__c from contact'
                            +' where partner_se__c=true ';
              
              if (Theater !='All'){                                 
                        query =query +'  and account_theater__c=\''+Theater+'\'';
                }else{
                    query =query +' order by account_theater__c';
              }
               
            PartnerSEContactSummaryFieldsUpdateBatch contactBatch = new PartnerSEContactSummaryFieldsUpdateBatch(query);  
            SelectedPLJobs.add(new SequencialBatchJob('Partner Lev Contact Calculation: ' +Theater, contactBatch,200)); 
            
            String queryAccount ='select id,grouping__c,PROFILED_ACCOUNT_FLAG__c,Partner_Leverage_Factor_Average__c,'+
                                'Partner_Leverage_Factor_Total__c,name,theater1__c,velocity_Solution_Provider_Tier__c,'+
                                '(select contact.id,contact.Partner_Leverage_Factor__c from account.contacts where contact.partner_se__c=true)'+
                                ' from account where PROFILED_ACCOUNT_FLAG__c=true and rating_eligible__c=true  '; 
      
            if (Theater !='All'){                                   
                        queryAccount =queryAccount +'  and theater1__c=\''+Theater+'\'';
                }else{
                    queryAccount =queryAccount +' order by theater1__c';
              }                 
            AccountPartnerSEFieldsUpdateBatch accountBatch= new AccountPartnerSEFieldsUpdateBatch(queryAccount);
            SelectedPLJobs.add(new SequencialBatchJob('Partner Lev Account Rollup Calculation:' + Theater, accountBatch,200));
        }
        return SelectedPLJobs;
    }
    
/*  public List<SequencialBatchJob> getGAFJobs(){
    
    }*/
    
    private SequencialBatchJob getVPPRuleEvaluaterJob(String Theater, String GroupingRecordTypeName, String RuleEvaluateType){
        String ruleResultQuery2 = 'Select Revenue_Amount__c, Required_value_Type__c,v.Speciality_RuleID__c, v.Rule_theater__c, '
                                            +'v.RequiredCount__c,Speciality_RuleID__r.Local_Requirment_Set__c,Grouping__r.RecordType.DeveloperName, '
                                            +'Speciality_RuleID__r.RecordType.DeveloperName, v.Name, v.Grouping__c, v.Current__c, '
                                            +'v.Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,Speciality_RuleID__r.Required__c, '
                                            +'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, '
                                            +'Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Group_Rule_3__c, '
                                            +'Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c, '
                                            +'Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.BR_Sub_category__c, '
                                            +'Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Required_Type__c, '
                                            +'Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,'
                                            +'Speciality_RuleID__r.Theater__c,Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Value__c, '
                                            +'Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.any_value_Acceptable__c,Speciality_RuleID__r.Is_Total_Revenue__c, '
                                            + 'VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c,Speciality_RuleID__r.Evaluation_at__c, '
                                            +'Speciality_RuleID__r.Name,v.AccountID__c From Velocity_Rule_Results__c v ' ;
        
        boolean whereflag=false;
        if(GroupingRecordTypeName!='All'){
            ruleResultQuery2 =ruleResultQuery2 +' where Grouping__r.RecordType.DeveloperName= \''+GroupingRecordTypeName+'\'';
            whereflag=true;
        }
        if(RuleEvaluateType!='All'){
            ruleResultQuery2 =ruleResultQuery2 +  (whereflag? ' and ' : ' where ') +' Speciality_RuleID__r.Evaluation_at__c= \''+RuleEvaluateType+'\'';
            whereflag=true;
        }
        if (Theater !='All'){                                   
            ruleResultQuery2 =ruleResultQuery2 + (whereflag? ' and ' : ' where ')  +' Account_Theater__c= \''+Theater+'\'';
            whereflag=true;
        }
         if (ProcessDeltaOnly ){
             ruleResultQuery2 = ruleResultQuery2 +  (whereflag? ' and ' : ' where ') + getDeltaClause( ' Grouping__r.Process_On_After__c ', ' Speciality_RuleID__r.Theater__c ', ' Speciality_RuleID__r.Cluster__c ', 'Speciality_RuleID__r.Tier__c ', ' Speciality_RuleID__r.Specialty_Rule_Type__c ');       
             whereflag=true;
        }             
        // Speciality_RuleID__r.RecordType.Developername has been included to make sure that specialty rules gets evalauted before tier rules.Wr212889
        ruleResultQuery2 =ruleResultQuery2 + ' ORDER BY Grouping__c,Speciality_RuleID__r.Evaluation_at__c,Speciality_RuleID__r.RecordType.Developername' ;
        System.debug('ruleResultQuery2 '+ruleResultQuery2);                                 
        
         //get batch size
        integer batchSize; 
        try{            
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleEvaluatorJob').DataValue__c);
        }catch(Exception e){
            batchSize = 20;
        } 
        
       SequencialBatchJob evaluatorjob;
        if (GroupingRecordTypeName == 'Partner_Grouping'){
            PRM_VPP_VelocityRuleEvaluatorJob job5 = new PRM_VPP_VelocityRuleEvaluatorJob(ruleResultQuery2);
            evaluatorjob=new SequencialBatchJob('Evaluate Velocity Rules Results for ' + Theater + ' ' +GroupingRecordTypeName, job5 ,batchSize);
        }else if (GroupingRecordTypeName == 'Partner_Grouping_Logical_Block' || GroupingRecordTypeName == 'Partner_Grouping_PAN_Theater'){
            PRM_PAN_VPP_VelocityRuleEvaluatorJob job5 = new PRM_PAN_VPP_VelocityRuleEvaluatorJob(ruleResultQuery2);
            evaluatorjob=new SequencialBatchJob('Evaluate Velocity Rules Results for ' + Theater + ' ' +GroupingRecordTypeName, job5 ,batchSize);
        }
       
         return evaluatorjob;
    }
    public SequencialBatchJob getPanVPPBuildVRRJobs(String Theater, String RecordTypeName){
         String ruleResultQuery1 = ' SELECT Account__c, Advanced_Consolidate_Specialty__c, Backup_and_Recovery_Specialty__c, Cluster__c, ' 
                  + ' Compliance_Period_Requirments_Met__c, Consolidate_Specialty__c, Deployed_To__c, Name, Governance_and_Archive_Specialty__c,Isilon_Track_Specialty__c,' 
                  + ' Local_Requirment_Set__c, Logical_Block_Level_Grouping__c, Pan_Theater_Level_Grouping__c, Speciality_Type__c, ' 
                  + ' Target_Tier__c, Theater2__c, Velocity_Specaility_Achieved__c, RecordTypeId,RecordType.DeveloperName FROM Account_Groupings__c ' 
                  + ' where RecordType.DeveloperName= \''+RecordTypeName +'\''                 ;
                  
                  if (Theater !='All'){                                  
                    ruleResultQuery1 =ruleResultQuery1 +' and Theater2__c =\''+Theater+'\'';
                  }
                  if (ProcessDeltaOnly ){
                     
                     ruleResultQuery1 = ruleResultQuery1 + ' and '+ getDeltaClause( ' Process_On_After__c ', ' Theater2__c ', ' Cluster__c ', 'Target_Tier__c ', 'Speciality_Type__c ');     
                  }
                System.debug('ruleResultQuery1 '+ruleResultQuery1);
                PRM_PAN_VPP_VelocityRuleResultJob1 job4LB = new PRM_PAN_VPP_VelocityRuleResultJob1(ruleResultQuery1);
                //get batch size
                integer batchSize; 
                try{            
                    batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleResultJob1').DataValue__c);
                }catch(Exception e){
                    batchSize = 20;
                } 
                return new SequencialBatchJob('Build Velocity Rules Results for ' + Theater + ' ' +RecordTypeName, job4LB ,batchSize);
    }
    
    public SequencialBatchJob getFunctionalAreaJob(String Theater) {
       
       SequencialBatchJob job=null;
       CustomSettingDataValueMap__c IS_FA_Scheduled_Theaters = DataValueMap.get('IS_FA_Scheduled_Theaters');
        
       if(IS_FA_Scheduled_Theaters != null && IS_FA_Scheduled_Theaters.DataValue__c =='YES'){
            String funtionalareaquery = 'select id,name,Account_Theater__c,functional_Area__c,functional_Area1__c,accountid from ' 
                                          +'contact where Active__c = true and account.IsPartner=true ';
            
           if (Theater !='All'){                                  
                        funtionalareaquery =funtionalareaquery +'  and Account_Theater__c=\''+Theater+'\'';
           }else{
                    funtionalareaquery =funtionalareaquery +' order by Account_Theater__c';
           } 
           if (ProcessDeltaOnly &&  wholeTheaterToProcess.indexOf(Theater)==-1){                                   
                funtionalareaquery =funtionalareaquery + ' and account.Grouping__r.Process_On_After__c > '+LastRan;
           }
           
           PRM_Contact_Functional_Area_UpdateBatch functionalAreaBatch = new PRM_Contact_Functional_Area_UpdateBatch(funtionalareaquery );
           job=(new SequencialBatchJob('Evaluate Functional Area'+Theater,functionalAreaBatch,10));     
            
        }
        return job;
    } 
    
    
    
    public String getDeltaClause(String ProcessAfter, String Theater, String Cluster , String  TargetTier, String SpecialityType  ){
        
               
             String DeltaClause=' ( '+ ProcessAfter +' > '+LastRan;
             
             // Specialty Rule
             if( wholeSpecialityTypeToProcess!='None'){
                DeltaClause=DeltaClause + ' or '+ SpecialityType +' in ( '+ wholeSpecialityTypeToProcess +' ) ';
             }
             // Velocity Rule
             if( wholeClusterToProcess!='None'){
                DeltaClause=DeltaClause + ' or ( '+ Cluster +'  in ( '+ wholeClusterToProcess +' ) ';
                DeltaClause=DeltaClause + ' and '+ TargetTier +' in ( '+ wholeTierToProcess +' ) ) ';
                
             } 
             // Rollup Rule
             
              if( wholeTheaterToProcess!='None' ){
                    DeltaClause=DeltaClause + ' or ' + Theater + ' in ( '+ wholeTheaterToProcess +' ) ';
              }     
            // Service Rule
                if( wholeTierToProcess!='None'){
                        DeltaClause=DeltaClause + 'or '+ TargetTier +' in ( '+ wholeTierToProcess +' ) ';
                 } 
             
                DeltaClause=DeltaClause  +' ) ';  
    
             return DeltaClause;
    }
    public static void loglimits(String jobname){
        Batch_job_limits__c lmitrec= new Batch_job_limits__c();
        lmitrec.getCpuTime__c=Limits.getCpuTime ();
        lmitrec.getLimitCpuTime__c=Limits.getLimitCpuTime ();
        lmitrec.getDMLRows__c=Limits.getDMLRows();
        lmitrec.getLimitDMLRows__c=Limits.getLimitDMLRows();
        lmitrec.getDMLStatements__c=Limits.getDMLStatements ();
        lmitrec.getLimitDMLStatements__c=Limits.getLimitDMLStatements ();
        lmitrec.getEmailInvocations__c=Limits.getEmailInvocations ();
        lmitrec.getLimitEmailInvocations__c=Limits.getLimitEmailInvocations ();
        lmitrec.getHeapSize__c=Limits.getHeapSize ();
        lmitrec.getLimitHeapSize__c=Limits.getLimitHeapSize ();
        lmitrec.getQueries__c=Limits.getQueries ();
        lmitrec.getLimitQueries__c=Limits.getLimitQueries ();
        lmitrec.getQueryLocatorRows__c=Limits.getQueryLocatorRows ();
        lmitrec.getLimitQueryLocatorRows__c=Limits.getLimitQueryLocatorRows ();
        lmitrec.getQueryRows__c=Limits.getQueryRows();
        lmitrec.getLimitQueryRows__c=Limits.getLimitQueryRows ();
        lmitrec.getScriptStatements__c=Limits.getScriptStatements ();
        lmitrec.getLimitScriptStatements__c=Limits.getLimitScriptStatements ();
        lmitrec.getSoslQueries__c=Limits.getSoslQueries();
        lmitrec.getLimitSoslQueries__c=Limits.getLimitSoslQueries();
        lmitrec.Apex_Job_Name__c=jobname;
        insert lmitrec;
    }
    
}