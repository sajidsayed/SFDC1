/*============================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |16-July-2012    Prasad Kothawade                  To create Velocity rule results for PAN Theater model.   
                                                                                            
 +15/11/2012      vivek kodi              197607     To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.
 20/04/2013		Sravanthi Aitha				212889 	evaluatecurrentvalueonvrr method added to calculate number of specialities achieved at each  logical blck level.
 | 20/05/2013	 Sravanthi Aitha			212889 	Fixed the blanks values issue on the Actual Column of the scorecard.        
 +==========================================================================================================*/
public class PRM_PAN_VPP_RuleEvaluator {        
      
    PRM_PAN_VPP_VelocityRuleResultsUtils Pan_VPP_UtilsObject = new PRM_PAN_VPP_VelocityRuleResultsUtils();
    Map<String,PRM_PAN_VPP_Bucket_Container__c> PANVPPBucketContainer = PRM_PAN_VPP_Bucket_Container__c.getall();
    //212889
    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll(); 
    
    
    /* @evaluateLogicalBlockVelocityRules <PRM_PAN_VPP_RuleEvaluator(): This method get called from Rule evaluateor job.  This method fetches related results 
                                                                        for Logicalblock and rollups(sum up) at logical block level.>
       @param - List<Account_Groupings__c> LogicalBlocks - Logical block to evaluate
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>  
    
    public void evaluateLogicalBlockVelocityRules (List<Velocity_Rule_Results__c> lstVelocityRuleResulst){
        List<Id> lstLogicalBlockRuleIds = new List<Id>();    
        List<Id> lstLogicalBlockIds = new list<Id>();  
        List<Velocity_Rule_Results__c> lstCloudBuilderVelocityRuleResults = new List<Velocity_Rule_Results__c>();
        List<Id> lstAccountGroupingWithinLogicalBlock = new List<Id>(); 
        Map<Id,Velocity_Rule_Results__c> mapVRRofGroupingUnderLBlock;  
        Map<Id,Account_Groupings__c> mapLogicalBlock;
        List<Velocity_Rule_Results__c> lstVRRToUpdate = new List<Velocity_Rule_Results__c>();
        Map<Id,List<Velocity_Rule_Results__c>> mapVRRToEvaluateWithLBlockId = new Map<Id,List<Velocity_Rule_Results__c>>();
        Map<Id,List<Velocity_Rule_Results__c>> mapVRRWithGrouping = new Map<Id,List<Velocity_Rule_Results__c>>();
        Map<Id,List<Velocity_Rule_Results__c>> mapVRRwithRule = new Map<Id,List<Velocity_Rule_Results__c>>();
        Map<String,integer> mapLogicalBlockwithSumValue = new Map<String,integer>();
        //map<Id,String> mapLBlockWithRuleIdentifier = new map<Id,string>(); 
        map<Id,Boolean> mapLBlockWithComplianceStatus = new map<Id,Boolean>(); 
        set<string> setlBlockRuleTier = new set<string>(); 
        set<string> setlBlockRuleDisplayName = new set<string>();   
        set<string> setlBlockRuleCluster = new set<string>();   
        set<string> setlBlockRuleBucket= new set<string>();   
        set<string> setlBlockRuleSpecilaity= new set<string>();  
        set<string> setlBlockRuleSpecialtyRuleType= new set<string>();   
        set<string> setlBlockFieldName= new set<string>();
        set<string> setlocalRequirementSet= new set<string>();       
        
        
        for(Velocity_Rule_Results__c ruleResult :lstVelocityRuleResulst){
            List<Velocity_Rule_Results__c> lstVRRforLogicalBlock = mapVRRToEvaluateWithLBlockId.get(ruleResult.Grouping__c);
            if(lstVRRforLogicalBlock==null){
               lstVRRforLogicalBlock = new List<Velocity_Rule_Results__c>();    
            }
            if(ruleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule' && ruleResult.Speciality_RuleID__r.Evaluation_at__c=='Logical Block Grouping Level'
                && (ruleResult.Speciality_RuleID__r.Required_Type__c =='Number/Count' || ruleResult.Speciality_RuleID__r.Required_Type__c =='USD'
                    || ruleResult.Speciality_RuleID__r.Bucket__c == 'Revenue') ){
                if((ruleResult.Speciality_RuleID__r.Tier__c !=null && ruleResult.Speciality_RuleID__r.Bucket__c !=null && ruleResult.Speciality_RuleID__r.Cluster__c !=null &&
                    ruleResult.Speciality_RuleID__r.Display_Name__c != null) || (ruleResult.Speciality_RuleID__r.Local_Requirment_Set__c !=null)){
                    lstVRRforLogicalBlock.add(ruleResult);
                } 
            }
            else if(ruleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Specialty_Rule' && ruleResult.Speciality_RuleID__r.Evaluation_at__c=='Logical Block Grouping Level' &&
                    (ruleResult.Speciality_RuleID__r.Required_Type__c =='Number/Count' || ruleResult.Speciality_RuleID__r.Required_Type__c =='USD'
                     || ruleResult.Speciality_RuleID__r.Bucket__c == 'Revenue')){
                if(ruleResult.Speciality_RuleID__r.Specilaity__c !=null && ruleResult.Speciality_RuleID__r.Bucket__c !=null && ruleResult.Speciality_RuleID__r.Specialty_Rule_Type__c !=null   && ruleResult.Speciality_RuleID__r.Display_Name__c != null){
                    lstVRRforLogicalBlock.add(ruleResult); 
                }  
            } 
            else if((ruleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Field_Based_Rule_Type' || ( PANVPPBucketContainer.containskey(ruleResult.Speciality_RuleID__r.Bucket__c) && ruleResult.Speciality_RuleID__r.Required_Type__c=='Text')) ){
                lstCloudBuilderVelocityRuleResults.add(ruleResult);   
            }
            mapVRRToEvaluateWithLBlockId.put(ruleResult.Grouping__c,lstVRRforLogicalBlock);
            lstLogicalBlockIds.add(ruleResult.Grouping__c);
        }
        
        mapLogicalBlock = new map<Id,Account_Groupings__c>([Select Id,Compliance_Period_Requirments_Met__c,Local_Requirment_Set__c from Account_Groupings__c where Id in :lstLogicalBlockIds]);
        
        if(lstCloudBuilderVelocityRuleResults.size()>0){
            evaluateCloudBuilderLogicalBlockRules(lstCloudBuilderVelocityRuleResults);
        }
        
        //1)    Call  getGroupingsUnderLogicalBlock ()
        Map<Id,List<Account_Groupings__c>> mapGroupingUnderLogicalBlock = Pan_VPP_UtilsObject.getGroupingsUnderLogicalBlock(lstLogicalBlockIds);
        system.debug('mapGroupingUnderLogicalBlock--->' +mapGroupingUnderLogicalBlock);
        
        //2)    Call  getLogicalBlockLevelRules ()
       // Map<Id,List<Velocity_Rules__c>> mapLogicalBlockRules = Pan_VPP_UtilsObject.getLogicalBlockLevelRules(LogicalBlocks);
        
        for (Id logicalBlockId :mapVRRToEvaluateWithLBlockId.keyset()){
            //string logicalBlockRuleIdentifier; 
            for(Velocity_Rule_Results__c LbockVelocityRuleResult :mapVRRToEvaluateWithLBlockId.get(logicalBlockId)){
                if(LbockVelocityRuleResult.Speciality_RuleID__r.Tier__c!=null){
                    setlBlockRuleTier.add(LbockVelocityRuleResult.Speciality_RuleID__r.Tier__c);
                }
                if(LbockVelocityRuleResult.Speciality_RuleID__r.Display_Name__c!=null){
                    setlBlockRuleDisplayName.add(LbockVelocityRuleResult.Speciality_RuleID__r.Display_Name__c);
                }
                if(LbockVelocityRuleResult.Speciality_RuleID__r.Cluster__c!=null){
                    setlBlockRuleCluster.add(LbockVelocityRuleResult.Speciality_RuleID__r.Cluster__c);
                }
                if(LbockVelocityRuleResult.Speciality_RuleID__r.Bucket__c!=null){
                    setlBlockRuleBucket.add(LbockVelocityRuleResult.Speciality_RuleID__r.Bucket__c);
                }
                if(LbockVelocityRuleResult.Speciality_RuleID__r.Specilaity__c!=null){
                    setlBlockRuleSpecilaity.add(LbockVelocityRuleResult.Speciality_RuleID__r.Specilaity__c);
                }
                if(LbockVelocityRuleResult.Speciality_RuleID__r.Specialty_Rule_Type__c!=null){
                    setlBlockRuleSpecialtyRuleType.add(LbockVelocityRuleResult.Speciality_RuleID__r.Specialty_Rule_Type__c);
                }
                if(LbockVelocityRuleResult.Speciality_RuleID__r.Field_Name__c!=null){
                    setlBlockFieldName.add(LbockVelocityRuleResult.Speciality_RuleID__r.Field_Name__c);
                }
                if(LbockVelocityRuleResult.Speciality_RuleID__r.Local_Requirment_Set__c!=null){
                    setlocalRequirementSet.add(LbockVelocityRuleResult.Speciality_RuleID__r.Local_Requirment_Set__c);
                }                
            }            
        }
        System.Debug('setlocalRequirementSet--->'+setlocalRequirementSet);
        
        //3)    Using above two maps get VRRs for groupings under each logical block and sum it up.
        for(Id lBlockId :mapGroupingUnderLogicalBlock.keyset()){
            for(Account_Groupings__c lbockGrouping :mapGroupingUnderLogicalBlock.get(lBlockId)){
                lstAccountGroupingWithinLogicalBlock.add(lbockGrouping.Id);
            }
        }
        if(lstAccountGroupingWithinLogicalBlock.size()>0){
            mapVRRofGroupingUnderLBlock = new map<Id,Velocity_Rule_Results__c>([Select Id,Name,Grouping__c,Required_Value_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Required__c,
                                                                                AccountID__c,Current__c,Revenue_Amount__c,Speciality_RuleID__c,Speciality_RuleID__r.Tier__c,
                                                                                Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.Bucket__c,
                                                                                Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.RecordType.DeveloperName,
                                                                                Speciality_RuleID__r.Local_Requirment_Set__c
                                                                                from Velocity_Rule_Results__c                                                                               
                                                                                where Grouping__r.Logical_Block_Level_Grouping__c in :lstLogicalBlockIds                                                                              
                                                                                and Speciality_RuleID__r.Bucket__c in :setlBlockRuleBucket and                                                                                
                                                                                ( (Speciality_RuleID__r.Tier__c in :setlBlockRuleTier and Speciality_RuleID__r.Display_Name__c in :setlBlockRuleDisplayName) or
                                                                                  (Speciality_RuleID__r.Specilaity__c in :setlBlockRuleSpecilaity and Speciality_RuleID__r.Display_Name__c in :setlBlockRuleDisplayName) or
                                                                                  (Speciality_RuleID__r.Display_Name__c in :setlBlockRuleDisplayName and Speciality_RuleID__r.Local_Requirment_Set__c in :setlocalRequirementSet))]);
        }
        System.Debug('mapVRRofGroupingUnderLBlock--->' +mapVRRofGroupingUnderLBlock);
        
        if(mapVRRofGroupingUnderLBlock != null && mapVRRofGroupingUnderLBlock.size()>0){
           for(Velocity_Rule_Results__c velocityRuleResultObj :mapVRRofGroupingUnderLBlock.values()){               
               List<Velocity_Rule_Results__c> lstVRRforGrouping = mapVRRWithGrouping.get(velocityRuleResultObj.Grouping__c);
               if(lstVRRforGrouping==null){
                  lstVRRforGrouping = new list<Velocity_Rule_Results__c>();
               }
               lstVRRforGrouping.add(velocityRuleResultObj);
               mapVRRWithGrouping.put(velocityRuleResultObj.Grouping__c,lstVRRforGrouping);
               List<Velocity_Rule_Results__c> lstVelocityRuleResults = mapVRRwithRule.get(velocityRuleResultObj.Speciality_RuleID__c);
               if(lstVelocityRuleResults == null){
                  lstVelocityRuleResults = new List<Velocity_Rule_Results__c>();    
               }
               lstVelocityRuleResults.add(velocityRuleResultObj);
               mapVRRwithRule.put(velocityRuleResultObj.Speciality_RuleID__c,lstVelocityRuleResults);
           }    
        }
        System.Debug('mapVRRWithGrouping--->' +mapVRRWithGrouping);
        if(mapVRRWithGrouping.size()>0){
          for(Id LogicalBlockId :mapGroupingUnderLogicalBlock.keyset()){
              string RuleResultIdentifier;
              integer sumvalue; 
              for(Account_Groupings__c groupingObj :mapGroupingUnderLogicalBlock.get(LogicalBlockId)){
                if(mapVRRWithGrouping.containskey(groupingObj.Id)){
                  for(Velocity_Rule_Results__c velocityResult :mapVRRWithGrouping.get(groupingObj.Id)){
                      if(velocityResult.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule'){
                         RuleResultIdentifier = velocityResult.Speciality_RuleID__r.Tier__c+velocityResult.Speciality_RuleID__r.Bucket__c+velocityResult.Speciality_RuleID__r.Display_Name__c;
                      } 
                      if(velocityResult.Speciality_RuleID__r.RecordType.DeveloperName =='Specialty_Rule'){
                         RuleResultIdentifier = velocityResult.Speciality_RuleID__r.Specilaity__c+velocityResult.Speciality_RuleID__r.Bucket__c+velocityResult.Speciality_RuleID__r.Display_Name__c;
                      }                      
                      if(velocityResult.Speciality_RuleID__r.Local_Requirment_Set__c !=null ){
                         RuleResultIdentifier = velocityResult.Speciality_RuleID__r.Local_Requirment_Set__c+velocityResult.Speciality_RuleID__r.Display_Name__c+velocityResult.Speciality_RuleID__r.Bucket__c;
                      }              
                      sumvalue=mapLogicalBlockwithSumValue.get(LogicalBlockId+RuleResultIdentifier);
                      if(sumvalue==null){
                        sumvalue=0; 
                      }
                      if(velocityResult.Current__c != '' && velocityResult.Current__c != null){
                        if(velocityResult.Current__c.contains('$') && velocityResult.Current__c.contains(',')){
                            sumValue =    sumValue+ integer.valueof((velocityResult.Current__c.replace('$','')).replace(',',''));
                        }else if(velocityResult.Current__c.contains('$') && !velocityResult.Current__c.contains(',')){                               
                            sumValue =    sumValue+ integer.valueof(velocityResult.Current__c.replace('$',''));
                        } 
                        else if(!velocityResult.Current__c.contains('$') && velocityResult.Current__c.contains(',')){
                           sumValue =    sumValue+ integer.valueof(velocityResult.Current__c.replace(',',''));
                        }
                        else if(!velocityResult.Current__c.contains('$') && !velocityResult.Current__c.contains(',')){
                           sumValue =    sumValue+ integer.valueof(velocityResult.Current__c);
                        }
                      }
                      System.Debug('sumValue--->' +sumValue);
                      mapLogicalBlockwithSumValue.put(LogicalBlockId+RuleResultIdentifier,sumValue);
                  }               
                 
                }
                else{
                    sumValue = null;
                }
                
              }
               
          }
        }
        System.Debug('mapLogicalBlockwithSumValue---->' +mapLogicalBlockwithSumValue);
        //4)    Create Velocity Rule results for each Logical block and put sum up value on it.
        for(Id LblockGroupingId : mapVRRToEvaluateWithLBlockId.keyset()){
            boolean complianceStatus=true;
            string RuleResultIdentifier;
            for(Velocity_Rule_Results__c velocityRuleResult :mapVRRToEvaluateWithLBlockId.get(LblockGroupingId)){
               if(velocityRuleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule'){
                  RuleResultIdentifier = velocityRuleResult.Speciality_RuleID__r.Tier__c+velocityRuleResult.Speciality_RuleID__r.Bucket__c+velocityRuleResult.Speciality_RuleID__r.Display_Name__c;
                }   
               if(velocityRuleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Specialty_Rule'){
                 RuleResultIdentifier = velocityRuleResult.Speciality_RuleID__r.Specilaity__c+velocityRuleResult.Speciality_RuleID__r.Bucket__c+velocityRuleResult.Speciality_RuleID__r.Display_Name__c;
               }                
               if(velocityRuleResult.Speciality_RuleID__r.Local_Requirment_Set__c !=null && mapLogicalBlock.get(LblockGroupingId).Local_Requirment_Set__c !=null
                  && (velocityRuleResult.Speciality_RuleID__r.Local_Requirment_Set__c == mapLogicalBlock.get(LblockGroupingId).Local_Requirment_Set__c)){
                  RuleResultIdentifier = velocityRuleResult.Speciality_RuleID__r.Local_Requirment_Set__c+velocityRuleResult.Speciality_RuleID__r.Display_Name__c+velocityRuleResult.Speciality_RuleID__r.Bucket__c;
               }   
               if(mapLogicalBlockwithSumValue.get(LblockGroupingId+RuleResultIdentifier) !=null){
                  if(velocityRuleResult.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                    velocityRuleResult.Revenue_Amount__c = string.valueof(mapLogicalBlockwithSumValue.get(LblockGroupingId+RuleResultIdentifier)); 
                    List<String> args = new String[]{'0','number','$###,###,###.00'};                      
                    Decimal decRevenueAmmount = Decimal.valueOf(velocityRuleResult.Revenue_Amount__c);                 
                    String strrevenue = String.format(decRevenueAmmount.format(), args);  
                    velocityRuleResult.Current__c = '$' + strrevenue;                   
                  }else{                
                    velocityRuleResult.Current__c = string.valueof(mapLogicalBlockwithSumValue.get(LblockGroupingId+RuleResultIdentifier));
                  }
               }
               if(velocityRuleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule') {
                 if(complianceStatus && velocityRuleResult.Speciality_RuleID__r.Required__c != null && velocityRuleResult.Speciality_RuleID__r.Required__c != '' && velocityRuleResult.Speciality_RuleID__r.Required__c !='set by GAF'                  
                    && (velocityRuleResult.Speciality_RuleID__r.Required_Type__c =='Number/Count' || velocityRuleResult.Speciality_RuleID__r.Required_Type__c =='USD' || velocityRuleResult.Speciality_RuleID__r.Bucket__c == 'Revenue')){
                    if( integer.valueof(velocityRuleResult.Current__c.replace('$','').replace(',','')) < integer.valueof(velocityRuleResult.Speciality_RuleID__r.Required__c) ){
                        complianceStatus = false;
                    }
                 }
                  
               }
               lstVRRToUpdate.add(velocityRuleResult);
            }
            mapLBlockWithComplianceStatus.put(LblockGroupingId,complianceStatus);
        }
        System.Debug('lstVRRToUpdate--->' +lstVRRToUpdate);
        
        //5)    Update Velocity Rule Results for logical block
         if(lstVRRToUpdate.size()>0){ 
            update lstVRRToUpdate; 
         }
         
        //6) Check if all rules for each logical block has been satiesfied - status field should be achieved
            //if yes set "Compliance Period Requirements Met"  = true else set "Compliance Period Requirements Met"  = false
        if(mapLBlockWithComplianceStatus.size()>0){
           for(Id lBlockId :mapLBlockWithComplianceStatus.keyset()) {
               if(!mapLBlockWithComplianceStatus.get(lBlockId)){
                  mapLogicalBlock.get(lBlockId).Compliance_Period_Requirments_Met__c='Yes';
               }
               if(mapLBlockWithComplianceStatus.get(lBlockId)){
                  mapLogicalBlock.get(lBlockId).Compliance_Period_Requirments_Met__c='No';
               }
           }
        }
        update mapLogicalBlock.values();
    } */
    
   /* @evaluatePANTheaterVelocityRules <PRM_PAN_VPP_RuleEvaluator(): This method get called from Rule evaluateor job.  This method fetches related results 
                                                                        for PAN Theaters and rollups(sum up) at PAN Theaters level.>
       @param - List<Account_Groupings__c> PANTheaters - PAN Theaters to evaluate
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    
    public void evaluatePANTheaterVelocityRules  (List<Velocity_Rule_Results__c> lstVelocityRuleResult){
        List<Id> lstPanTheaterIds = new list<Id>();
        Map<Id,Account_Groupings__c> mapPANTheater;
        List<Velocity_Rule_Results__c> lstVRRToUpdate = new List<Velocity_Rule_Results__c>();
        List<Velocity_Rule_Results__c> lstCloudBuilderVelocityRuleResults = new List<Velocity_Rule_Results__c>();
        Map<Id,List<Velocity_Rule_Results__c>> mapVRRToEvaluateWithPANTheater = new Map<Id,List<Velocity_Rule_Results__c>>();
        List<Id> lstGroupingWithinPanTheater = new List<Id>();   
        Map<Id,Velocity_Rule_Results__c> mapVRRofGroupingUnderPANTheater;
        Map<Id,List<Velocity_Rule_Results__c>> mapVRRWithGrouping = new Map<Id,List<Velocity_Rule_Results__c>>();
        Map<Id,List<Velocity_Rule_Results__c>> mapVRRwithRule = new Map<Id,List<Velocity_Rule_Results__c>>();
        Map<String,integer> mapPanTheaterwithSumUpValue = new Map<String,integer>();
        map<Id,Boolean> mapLBlockWithComplianceStatus = new map<Id,Boolean>();
        set<string> setPANTheaterRuleTier = new set<string>();
        set<string> setPANTheaterRuleDisplayName = new set<string>();
        set<string> setPANTheaterRuleCluster = new set<string>();
        set<string> setPANTheaterRuleBucket= new set<string>();
        set<string> setPANTheaterSpecilaity= new set<string>();
        set<string> setPANTheaterSpecialtyRuleType= new set<string>();
        set<string> setPANTheaterFieldName= new set<string>();        
        map<Id,Boolean> mapPANTheaterWithComplianceStatus = new map<Id,Boolean>();
        
        for(Velocity_Rule_Results__c ruleResult :lstVelocityRuleResult){
            List<Velocity_Rule_Results__c> lstVRRforPANTheater = mapVRRToEvaluateWithPANTheater.get(ruleResult.Grouping__c);
            if(lstVRRforPANTheater==null){
               lstVRRforPANTheater = new List<Velocity_Rule_Results__c>();     
            }
            if(ruleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule' && ruleResult.Speciality_RuleID__r.Evaluation_at__c=='PAN Theater Grouping Level'
            && (ruleResult.Speciality_RuleID__r.Required_Type__c =='Number/Count' || ruleResult.Speciality_RuleID__r.Required_Type__c =='USD'
                || ruleResult.Speciality_RuleID__r.Bucket__c == 'Revenue')){
              if(ruleResult.Speciality_RuleID__r.Tier__c !=null && ruleResult.Speciality_RuleID__r.Bucket__c !=null && ruleResult.Speciality_RuleID__r.Cluster__c !=null &&
                 ruleResult.Speciality_RuleID__r.Display_Name__c != null){
                 lstVRRforPANTheater.add(ruleResult);
              } 
            }
            else if(ruleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Specialty_Rule' && ruleResult.Speciality_RuleID__r.Evaluation_at__c=='PAN Theater Grouping Level' && 
                    (ruleResult.Speciality_RuleID__r.Required_Type__c =='Number/Count' || ruleResult.Speciality_RuleID__r.Required_Type__c =='USD'
                     || ruleResult.Speciality_RuleID__r.Bucket__c == 'Revenue')){
              if(ruleResult.Speciality_RuleID__r.Specilaity__c !=null && ruleResult.Speciality_RuleID__r.Bucket__c !=null && ruleResult.Speciality_RuleID__r.Specialty_Rule_Type__c !=null   && ruleResult.Speciality_RuleID__r.Display_Name__c != null){
                 lstVRRforPANTheater.add(ruleResult);   
              }  
            }
            else if((ruleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Field_Based_Rule_Type' || ( PANVPPBucketContainer.containskey(ruleResult.Speciality_RuleID__r.Bucket__c))  && ruleResult.Speciality_RuleID__r.Required_Type__c=='Text')
                    && ruleResult.Speciality_RuleID__r.Evaluation_at__c=='PAN Theater Grouping Level'){               
                  lstCloudBuilderVelocityRuleResults.add(ruleResult);                
            }
            mapVRRToEvaluateWithPANTheater.put(ruleResult.Grouping__c,lstVRRforPANTheater);
            lstPanTheaterIds.add(ruleResult.Grouping__c);
        }
        if(lstCloudBuilderVelocityRuleResults.size()>0){
           evaluateCloudBuilderPANLevelRules(lstCloudBuilderVelocityRuleResults); 
        }
        System.Debug('mapVRRToEvaluateWithPANTheater--->' +mapVRRToEvaluateWithPANTheater);
        //1)    Call  getGroupingsUnderPANLevel()
        Map<Id,List<Account_Groupings__c>> mapGroupingUnderPanTheater = Pan_VPP_UtilsObject.getGroupingsUnderPANLevel(lstPanTheaterIds);
        System.Debug('mapGroupingUnderPanTheater--->' +mapGroupingUnderPanTheater);
        
        for (Id PANTheaterId :mapVRRToEvaluateWithPANTheater.keyset()){
            //string logicalBlockRuleIdentifier; 
            for(Velocity_Rule_Results__c PANTheaterVelocityRuleResult :mapVRRToEvaluateWithPANTheater.get(PANTheaterId)){
                if(PANTheaterVelocityRuleResult.Speciality_RuleID__r.Tier__c!=null){
                    setPANTheaterRuleTier.add(PANTheaterVelocityRuleResult.Speciality_RuleID__r.Tier__c);
                }
                if(PANTheaterVelocityRuleResult.Speciality_RuleID__r.Display_Name__c!=null){
                    setPANTheaterRuleDisplayName.add(PANTheaterVelocityRuleResult.Speciality_RuleID__r.Display_Name__c);
                }
                if(PANTheaterVelocityRuleResult.Speciality_RuleID__r.Cluster__c!=null){
                    setPANTheaterRuleCluster.add(PANTheaterVelocityRuleResult.Speciality_RuleID__r.Cluster__c);
                }
                if(PANTheaterVelocityRuleResult.Speciality_RuleID__r.Bucket__c!=null){
                    setPANTheaterRuleBucket.add(PANTheaterVelocityRuleResult.Speciality_RuleID__r.Bucket__c);
                }
                if(PANTheaterVelocityRuleResult.Speciality_RuleID__r.Specilaity__c!=null){
                    setPANTheaterSpecilaity.add(PANTheaterVelocityRuleResult.Speciality_RuleID__r.Specilaity__c);
                }
                if(PANTheaterVelocityRuleResult.Speciality_RuleID__r.Specialty_Rule_Type__c!=null){
                    setPANTheaterSpecialtyRuleType.add(PANTheaterVelocityRuleResult.Speciality_RuleID__r.Specialty_Rule_Type__c);
                }
                if(PANTheaterVelocityRuleResult.Speciality_RuleID__r.Field_Name__c!=null){
                    setPANTheaterFieldName.add(PANTheaterVelocityRuleResult.Speciality_RuleID__r.Field_Name__c);
                }                
            }
            
        }
        
        //3)    Using above two maps get VRRs for groupings under each PAN Theater and sum it up.
        for(Id panTheaterGroupingId :mapGroupingUnderPanTheater.keyset()){
            for(Account_Groupings__c groupingUnderPANTheater :mapGroupingUnderPanTheater.get(panTheaterGroupingId)){
                lstGroupingWithinPanTheater.add(groupingUnderPANTheater.Id);
            }
        }
        if(lstGroupingWithinPanTheater.size()>0){
            mapVRRofGroupingUnderPANTheater = new map<Id,Velocity_Rule_Results__c>([Select Id,Name,Grouping__c,Required_Value_Type__c,Speciality_RuleID__r.Field_Name__c,
                                                                                    AccountID__c,Current__c,Revenue_Amount__c,Speciality_RuleID__c,Speciality_RuleID__r.Tier__c,
                                                                                    Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.Bucket__c,
                                                                                    Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.RecordType.DeveloperName from 
                                                                                    Velocity_Rule_Results__c                                                                                
                                                                                   where Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c in :lstPanTheaterIds                                                                                
                                                                                and Speciality_RuleID__r.Bucket__c in :setPANTheaterRuleBucket and
                                                                                ( (Speciality_RuleID__r.Tier__c in :setPANTheaterRuleTier and Speciality_RuleID__r.Display_Name__c in :setPANTheaterRuleDisplayName) or 
                                                                                (Speciality_RuleID__r.Specilaity__c in :setPANTheaterSpecilaity  and Speciality_RuleID__r.Display_Name__c in :setPANTheaterRuleDisplayName)
                                                                                )]);
        }
        System.Debug('mapVRRofGroupingUnderPANTheater--->' +mapVRRofGroupingUnderPANTheater);
        if(mapVRRofGroupingUnderPANTheater!=null && mapVRRofGroupingUnderPANTheater.size()>0){
           for(Velocity_Rule_Results__c velocityRuleResultObj :mapVRRofGroupingUnderPANTheater.values()){               
               List<Velocity_Rule_Results__c> lstVRRforGrouping = mapVRRWithGrouping.get(velocityRuleResultObj.Grouping__c);
               if(lstVRRforGrouping==null){
                  lstVRRforGrouping = new list<Velocity_Rule_Results__c>();
               }
               lstVRRforGrouping.add(velocityRuleResultObj);
               mapVRRWithGrouping.put(velocityRuleResultObj.Grouping__c,lstVRRforGrouping);
               List<Velocity_Rule_Results__c> lstVelocityRuleResults = mapVRRwithRule.get(velocityRuleResultObj.Speciality_RuleID__c);
               if(lstVelocityRuleResults == null){
                  lstVelocityRuleResults = new List<Velocity_Rule_Results__c>();    
               }
               lstVelocityRuleResults.add(velocityRuleResultObj);
               mapVRRwithRule.put(velocityRuleResultObj.Speciality_RuleID__c,lstVelocityRuleResults);
           }    
        }
        
       if(mapVRRWithGrouping.size()>0){
          for(Id PANTheaterId :mapGroupingUnderPanTheater.keyset()){
              string RuleResultIdentifier;
              integer sumvalue; 
              for(Account_Groupings__c groupingUnderPANTheater :mapGroupingUnderPanTheater.get(PANTheaterId)){
                if(mapVRRWithGrouping.containskey(groupingUnderPANTheater.Id)){
                  for(Velocity_Rule_Results__c velocityResult :mapVRRWithGrouping.get(groupingUnderPANTheater.Id)){
                      if(velocityResult.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule'){
                         RuleResultIdentifier = velocityResult.Speciality_RuleID__r.Tier__c+velocityResult.Speciality_RuleID__r.Bucket__c+velocityResult.Speciality_RuleID__r.Display_Name__c;
                      } 
                      if(velocityResult.Speciality_RuleID__r.RecordType.DeveloperName =='Specialty_Rule'){
                         RuleResultIdentifier = velocityResult.Speciality_RuleID__r.Specilaity__c+velocityResult.Speciality_RuleID__r.Bucket__c+velocityResult.Speciality_RuleID__r.Display_Name__c;
                      }                                    
                      sumvalue=mapPanTheaterwithSumUpValue.get(PANTheaterId+RuleResultIdentifier);
                      if(sumvalue==null){
                        sumvalue=0; 
                      }
                      if(velocityResult.Current__c != '' && velocityResult.Current__c != null){
                        if(velocityResult.Current__c.contains('$') && velocityResult.Current__c.contains(',')){
                            sumValue =    sumValue+ integer.valueof((velocityResult.Current__c.replace('$','')).replace(',',''));
                        }else if(velocityResult.Current__c.contains('$') && !velocityResult.Current__c.contains(',')){                               
                            sumValue =    sumValue+ integer.valueof(velocityResult.Current__c.replace('$',''));
                        } 
                        else if(!velocityResult.Current__c.contains('$') && velocityResult.Current__c.contains(',')){
                           sumValue =    sumValue+ integer.valueof(velocityResult.Current__c.replace(',',''));
                        }
                        else if(!velocityResult.Current__c.contains('$') && !velocityResult.Current__c.contains(',')){
                           sumValue =    sumValue+ integer.valueof(velocityResult.Current__c);
                        }
                      }
                      System.Debug('sumValue--->' +sumValue);
                      mapPanTheaterwithSumUpValue.put(PANTheaterId+RuleResultIdentifier,sumValue);
                  }               
                 
                }
                else{
                    sumValue = null;
                }
                
              }
               
          }
        }
        
        //4)    Create Velocity Rule results for each PAN Theater and put sum up value on it. 
        for(Id PANTheaterGroupingId : mapVRRToEvaluateWithPANTheater.keyset()){
            boolean complianceStatus=true;
            string RuleResultIdentifier;
            for(Velocity_Rule_Results__c velocityRuleResult :mapVRRToEvaluateWithPANTheater.get(PANTheaterGroupingId)){
               if(velocityRuleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule'){
                  RuleResultIdentifier = velocityRuleResult.Speciality_RuleID__r.Tier__c+velocityRuleResult.Speciality_RuleID__r.Bucket__c+velocityRuleResult.Speciality_RuleID__r.Display_Name__c;
                }   
               if(velocityRuleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Specialty_Rule'){
                 RuleResultIdentifier = velocityRuleResult.Speciality_RuleID__r.Specilaity__c+velocityRuleResult.Speciality_RuleID__r.Bucket__c+velocityRuleResult.Speciality_RuleID__r.Display_Name__c;
               }                  
               if(mapPanTheaterwithSumUpValue.get(PANTheaterGroupingId+RuleResultIdentifier) !=null){
                  if(velocityRuleResult.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                    velocityRuleResult.Revenue_Amount__c = string.valueof(mapPanTheaterwithSumUpValue.get(PANTheaterGroupingId+RuleResultIdentifier)); 
                    List<String> args = new String[]{'0','number','$###,###,###.00'};                      
                    Decimal decRevenueAmmount = Decimal.valueOf(velocityRuleResult.Revenue_Amount__c);                 
                    String strrevenue = String.format(decRevenueAmmount.format(), args);  
                    velocityRuleResult.Current__c = '$' + strrevenue;                   
                  }else{                
                    velocityRuleResult.Current__c = string.valueof(mapPanTheaterwithSumUpValue.get(PANTheaterGroupingId+RuleResultIdentifier));
                  }
               }
               if(velocityRuleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule') {
                 if(complianceStatus && velocityRuleResult.Speciality_RuleID__r.Required__c != null && velocityRuleResult.Speciality_RuleID__r.Required__c != '' && velocityRuleResult.Speciality_RuleID__r.Required__c !='set by GAF'
                   && (velocityRuleResult.Speciality_RuleID__r.Required_Type__c =='Number/Count' || velocityRuleResult.Speciality_RuleID__r.Required_Type__c =='USD' || velocityRuleResult.Speciality_RuleID__r.Bucket__c == 'Revenue')){
                    if(integer.valueof(velocityRuleResult.Current__c.replace('$','').replace(',','')) < integer.valueof(velocityRuleResult.Speciality_RuleID__r.Required__c)){
                     complianceStatus = false;
                    }
                 }
                 
               }
               lstVRRToUpdate.add(velocityRuleResult);
            }
            mapPANTheaterWithComplianceStatus.put(PANTheaterGroupingId,complianceStatus);
        }
        System.Debug('InPANTheater-->' +lstVRRToUpdate);
        //5)    insert Velocity Rule Results for PAN Theaters
        if(lstVRRToUpdate.size()>0){
            update lstVRRToUpdate;
         }
         mapPANTheater = new map<Id,Account_Groupings__c>([Select Id,Compliance_Period_Requirments_Met__c from Account_Groupings__c where Id in :   mapPANTheaterWithComplianceStatus.keyset()]);
        //6) Check if all rules for each PAN Theater has been satiesfied - status field should be achieved 
            //if yes set "Compliance Period Requirements Met"  = true else set "Compliance Period Requirements Met"  = false
        if(mapPANTheaterWithComplianceStatus.size()>0){
           for(Id PANTheaterId :mapPANTheaterWithComplianceStatus.keyset()) {
               if(mapPANTheaterWithComplianceStatus.get(PANTheaterId)){
                  mapPANTheater.get(PANTheaterId).Compliance_Period_Requirments_Met__c='Yes';
               }
               if(!mapPANTheaterWithComplianceStatus.get(PANTheaterId)){
                  mapPANTheater.get(PANTheaterId).Compliance_Period_Requirments_Met__c='No';
               }
           }
        }
        update mapPANTheater.values();  
    } */
    //212889
    public Map<String,Integer> evaluatecurrentvalueonvrr(List<Velocity_Rule_Results__c> lstvrrs){
    	 Map<String,Integer> mapAchCount = new Map<String,Integer>();
    	 Map<String,Integer> mapNotAchCount = new Map<String,Integer>();
    	 Map<String,String> grpmap = new map<String,String>();
    	 Map<String,Integer> finalmap = new map<String,Integer>();
    	 String strkey;
    	 
	  	 for(Velocity_Rule_Results__c VelruleResult : lstvrrs){
    	 	if(VelruleResult.Speciality_RuleID__r.Specilaity__c !=null && VelruleResult.Speciality_RuleID__r.Required_Type__c =='Number/Count' ){
    	 		system.debug('Current__C value is ' + VelruleResult.current__c + '. and required__c value is ' +VelruleResult.RequiredCount__c);
    	 	String strGroupingKey = VelruleResult.Grouping__c;
    	 	strkey= strGroupingKey+VelruleResult.Speciality_RuleID__r.Specilaity__c;
    	 	Integer sumValue1 = mapAchCount.get(strKey);
    	 	Integer sumValue2 = mapNotAchCount.get(strKey);
    	 	if(sumValue1 ==null){
    	 		sumvalue1=0;
    	 		}
    	 	if(sumvalue2 ==null){
                sumvalue2=0; 
            }
            
            if(VelruleResult.Current__c >= VelruleResult.RequiredCount__c){
              	system.debug('in ach if '+VelruleResult.Status__c);
            	sumValue1 =    sumValue1+ 1;
                mapAchCount.put(strKey, sumValue1 );
            }
			else {
            	system.debug('in not ach if ++ '+VelruleResult.Status__c);
            	sumValue2 =    sumValue2+ 1;
				mapNotAchCount.put(strKey, sumValue2 );   
			}
			grpmap.put(strkey,strGroupingKey);
    	 	}
	  	 }

		for ( String str : grpmap.keyset()){
			Integer sum = finalmap.get(grpmap.get(str));
			if(sum == null){
					sum = 0;
			}
			if(!(mapNotAchCount.containskey(str) && mapNotAchCount.get(str)>0)){
				sum = sum+1;
			}
				
			finalmap.put(grpmap.get(str),sum);
		}
    	 system.debug('finalmap '+finalmap);
    	 return finalmap;
    }
    
    
    
   /* @evaluateCloudBuilderLogicalBlockRules< PRM_PAN_VPP_RuleEvaluator(): This method get called from PAN Rule evaluateor job. This method fetches profiled account and evaluate cloud
                                            builder ruleresults>
       @param - List<Account_Groupings__c> PANTheaters - PAN Theaters to evaluate
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
   */
    public void evaluateCloudBuilderLogicalBlockRules (List<Velocity_Rule_Results__c> lstlogicalBlockCloudBuilderVelocityRuleResult){
        List<Id> lstLogicalBlockIds = new list<Id>();
        List<Velocity_Rule_Results__c> lstVRRtoUpdate= new list<Velocity_Rule_Results__c>();
        boolean conditionSatisfied = true;
        string tierValue='';
        integer ruleSatisfactoryCounter = 0;
        Map<Id,List<Velocity_Rule_Results__c>> mapLblockwithVRR = new Map<Id,List<Velocity_Rule_Results__c>>();
        
        for(Velocity_Rule_Results__c lBlockVRR :lstlogicalBlockCloudBuilderVelocityRuleResult){
            lstLogicalBlockIds.add(lBlockVRR.Grouping__c);
            List<Velocity_Rule_Results__c> lstVRR = mapLblockwithVRR.get(lBlockVRR.Grouping__c);
            if(lstVRR==null){
                lstVRR = new List<Velocity_Rule_Results__c>();
            }
            lstVRR.add(lBlockVRR);
            mapLblockwithVRR.put(lBlockVRR.Grouping__c,lstVRR);
        }
        //1)    Call  getProfiledAccountUnderLogicalBlock()
        Map<Id,List<Account>> mapProfiledAccountUnderLogicalBlock = Pan_VPP_UtilsObject.getProfiledAccountUnderLogicalBlock(lstLogicalBlockIds);
        Map<String,Schema.SObjectField> mapAccountFields = Schema.SObjectType.Account.fields.getMap();
        Schema.DisplayType fieldType;
        list<string> lstfieldValues = new list<string>();
        set<string> fieldValues = new set<string>();
        list<string> requiredValues = new list<string>();
        for(Id logicalBlockId : mapLblockwithVRR.keyset()){
            
            for(Velocity_Rule_Results__c cloudBuilderVRR :mapLblockwithVRR.get(logicalBlockId)){
                tierValue = 'No';
                conditionSatisfied = true;
                ruleSatisfactoryCounter=0;
                if(mapProfiledAccountUnderLogicalBlock.get(logicalBlockId)!=null){
                    for(Account profiledAccount :mapProfiledAccountUnderLogicalBlock.get(logicalBlockId)){
                        system.debug('cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c--->' +cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c);
                        if(PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c)){
                            fieldType = mapAccountFields.get(PANVPPBucketContainer.get(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c).Field_API_Name__c).getDescribe().getType();  
                        }else { 
                             fieldType = mapAccountFields.get(cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c).getDescribe().getType();
                        }   
                        if(fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.PICKLIST || fieldType == Schema.DisplayType.MULTIPICKLIST
                            || fieldType == Schema.DisplayType.TEXTAREA){
                            fieldvalues.clear();
                           if(!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && profiledAccount.get(cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c) != null &&      profiledAccount.get(cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c) != ''){ 
                               lstfieldValues.clear();
                               lstfieldValues = ((profiledAccount.get(cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c))+';').split(';');                       
                               if(lstfieldValues.size()>0){
                                    for(string value: lstfieldValues){
                                        fieldValues.add(value.toLowerCase());
                                    }
                               }
                          }     
                        }
                        if(fieldType == Schema.DisplayType.DATETIME || fieldType == Schema.DisplayType.DATE || fieldType == Schema.DisplayType.DOUBLE
                            || fieldType == Schema.DisplayType.INTEGER || fieldType == Schema.DisplayType.ID){
                            fieldvalues.clear();
                           if(profiledAccount.get(cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c) != null && profiledAccount.get(cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c) != ''){
                               lstfieldValues.clear();  
                               lstfieldValues = (string.valueOf((profiledAccount.get(cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c)))+';').split(';');                        
                               if(lstfieldValues.size()>0){
                                    for(string value: lstfieldValues){
                                        fieldValues.add(value.toLowerCase());
                                    }
                               }
                          }
                        }
                        if(!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && cloudBuilderVRR.Speciality_RuleID__r.Value__c != null && cloudBuilderVRR.Speciality_RuleID__r.Value__c != ''){
                             requiredValues = (cloudBuilderVRR.Speciality_RuleID__r.Value__c +';').split(';');                       
                        } 
                        if(!cloudBuilderVRR.Speciality_RuleID__r.Any_Value_Acceptable__c){
                            if(cloudBuilderVRR.Speciality_RuleID__r.AND_OR__c != null && cloudBuilderVRR.Speciality_RuleID__r.AND_OR__c != '' 
                               && cloudBuilderVRR.Speciality_RuleID__r.AND_OR__c == 'AND' && conditionSatisfied){
                               if(!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && requiredValues.size()>0){
                                  for(string value: requiredValues){
                                        if(fieldValues.size()>0){
                                            if(fieldValues.contains(value.toLowerCase())){
                                            }else{
                                                conditionSatisfied = false;
                                                break;
                                            }
                                        }
                                        else{
                                            conditionSatisfied = false;
                                        }
                                    }
                               }
                               if(conditionsatisfied && PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && profiledAccount.get(PANVPPBucketContainer.get(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c).Field_API_Name__c)=='Yes'){
                                       tierValue= string.valueof(profiledAccount.get(PANVPPBucketContainer.get(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c).Field_API_Name__c));
                               }
                               else if(PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && profiledAccount.get(PANVPPBucketContainer.get(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c).Field_API_Name__c)!='Yes'){
                                       tierValue= 'No';
                                       conditionsatisfied=false;                                       
                               }
                               if(!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && conditionSatisfied){
                                  ruleSatisfactoryCounter = ruleSatisfactoryCounter+1;
                                }
                                else if (!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && !conditionSatisfied){
                                    ruleSatisfactoryCounter = 0;
                                }
                            }
                            if(cloudBuilderVRR.Speciality_RuleID__r.AND_OR__c != null && cloudBuilderVRR.Speciality_RuleID__r.AND_OR__c != '' 
                                && cloudBuilderVRR.Speciality_RuleID__r.AND_OR__c == 'OR'){
                                //ruleSatisfactoryCounter = 0;
                                if(!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && requiredValues.size()>0){
                                   for(string value: requiredValues){
                                       if(fieldValues.size()>0){
                                          if(fieldValues.contains(value.toLowerCase())){
                                             conditionSatisfied = true;
                                             ruleSatisfactoryCounter = ruleSatisfactoryCounter+1;
                                          }
                                          else{
                                            conditionSatisfied = false;
                                          }
                                        }   
                                   }
                                }
                                if(PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && profiledAccount.get(PANVPPBucketContainer.get(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c).Field_API_Name__c)=='Yes'){
                                       tierValue= string.valueof(profiledAccount.get(PANVPPBucketContainer.get(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c).Field_API_Name__c));
                                }
                            }
                            if(!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && conditionSatisfied){
                                  //ruleSatisfactoryCounter = ruleSatisfactoryCounter+1;
                            }
                            else if (!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && !conditionSatisfied){
                                ruleSatisfactoryCounter = 0;
                            }
                        }
                        else{
                             //ruleSatisfactoryCounter = 0;   
                            if(cloudBuilderVRR.Speciality_RuleID__r.Any_Value_Acceptable__c && !PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && fieldValues.size()>0 ){
                                conditionSatisfied = true; 
                                System.Debug('fieldValues--->>>' +fieldValues);
                                ruleSatisfactoryCounter = ruleSatisfactoryCounter+1;    
                            }
                            else if (!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c)){
                                conditionSatisfied = false;
                                //ruleSatisfactoryCounter = 0;
                            }
                        }
                    }
                    System.Debug('ruleSatisfactoryCounter>>>>>>>>>>' +ruleSatisfactoryCounter);
                }
                if(!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c)){
                   cloudBuilderVRR.Current__c= string.valueof(ruleSatisfactoryCounter);
                }
                if(PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c)){
                   cloudBuilderVRR.Current__c =  tierValue;     
                }
                lstVRRtoUpdate.add(cloudBuilderVRR);
            }
        }
        System.Debug('lstVRRtoUpdate--->' +lstVRRtoUpdate);
        update lstVRRtoUpdate;
    }
   /* @evaluateCloudBuilderPANLevelRules< PRM_PAN_VPP_RuleEvaluator(): This method get called from PAN Rule evaluateor job. This method fetches profiled account and evaluate cloud
                                            builder ruleresults for PanLevel Grouping>
       @param - List<Velocity_Rule_Results__c> ListofVeleocityRuleResultsforPAN
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
   */
    public void evaluateCloudBuilderPANLevelRules (List<Velocity_Rule_Results__c> lstPANLevelCloudBuilderVelocityRuleResult){
        List<Id> lstPANTheaterIds = new list<Id>();
        List<Velocity_Rule_Results__c> lstVRRtoUpdate= new list<Velocity_Rule_Results__c>();
        boolean conditionSatisfied = true;
        string tierValue='';
        Schema.DisplayType fieldType;
        integer ruleSatisfactoryCounter = 0;
        Map<Id,List<Velocity_Rule_Results__c>> mapPANTheaterwithVRR = new Map<Id,List<Velocity_Rule_Results__c>>();
        for(Velocity_Rule_Results__c PANTheaterVRR :lstPANLevelCloudBuilderVelocityRuleResult){
            lstPANTheaterIds.add(PANTheaterVRR.Grouping__c);
            List<Velocity_Rule_Results__c> lstVRR = mapPANTheaterwithVRR.get(PANTheaterVRR.Grouping__c);
            if(lstVRR==null){
                lstVRR = new List<Velocity_Rule_Results__c>();
            }
            lstVRR.add(PANTheaterVRR);
            mapPANTheaterwithVRR.put(PANTheaterVRR.Grouping__c,lstVRR);
        }
        //1)    Call  getProfiledAccountUnderPANLevel()
        Map<Id,List<Account>> mapProfiledAccountUnderPANTheater = Pan_VPP_UtilsObject.getProfiledAccountUnderPANLevel(lstPANTheaterIds);
        Map<String,Schema.SObjectField> mapAccountFields = Schema.SObjectType.Account.fields.getMap();
        list<string> lstfieldValues = new list<string>();
        set<string> fieldValues = new set<string>();
        list<string> requiredValues = new list<string>();
        for(Id PANTheaterId : mapPANTheaterwithVRR.keyset()){            
            for(Velocity_Rule_Results__c cloudBuilderVRR :mapPANTheaterwithVRR.get(PANTheaterId)){
                tierValue = 'No';
                conditionSatisfied = true;
                ruleSatisfactoryCounter=0;
                if(mapProfiledAccountUnderPANTheater.get(PANTheaterId)!=null){
                    for(Account profiledAccount :mapProfiledAccountUnderPANTheater.get(PANTheaterId)){
                        system.debug('cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c--->' +cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c);
                        if(PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c)){
                            fieldType = mapAccountFields.get(PANVPPBucketContainer.get(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c).Field_API_Name__c).getDescribe().getType();  
                        }else { 
                             fieldType = mapAccountFields.get(cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c).getDescribe().getType();
                        }
                        if(fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.PICKLIST || fieldType == Schema.DisplayType.MULTIPICKLIST
                            || fieldType == Schema.DisplayType.TEXTAREA){
                            fieldvalues.clear();
                           if(!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && profiledAccount.get(cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c)   != null && profiledAccount.get(cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c) != ''){ 
                               lstfieldValues.clear();
                               lstfieldValues = ((profiledAccount.get(cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c))+';').split(';'); 
                                                     
                               if(lstfieldValues.size()>0){
                                    for(string value: lstfieldValues){
                                        fieldValues.add(value.toLowerCase());
                                    }
                                    System.debug('fiedlValues----->>>>' +fieldValues);
                               }
                          }     
                        }
                        if(fieldType == Schema.DisplayType.DATETIME || fieldType == Schema.DisplayType.DATE || fieldType == Schema.DisplayType.DOUBLE
                            || fieldType == Schema.DisplayType.INTEGER || fieldType == Schema.DisplayType.ID){
                            fieldvalues.clear();  
                           if(profiledAccount.get(cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c) != null && profiledAccount.get(cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c) != ''){
                               lstfieldValues = (string.valueOf((profiledAccount.get(cloudBuilderVRR.Speciality_RuleID__r.Field_Name__c)))+';').split(';');
                                                     
                               if(lstfieldValues.size()>0){
                                    for(string value: lstfieldValues){
                                        fieldValues.add(value.toLowerCase());
                                    }
                               }
                          }
                        }
                        if(!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && cloudBuilderVRR.Speciality_RuleID__r.Value__c != null && cloudBuilderVRR.Speciality_RuleID__r.Value__c != ''){
                             requiredValues = (cloudBuilderVRR.Speciality_RuleID__r.Value__c +';').split(';');                       
                        } 
                        if(!cloudBuilderVRR.Speciality_RuleID__r.Any_Value_Acceptable__c){
                            if(cloudBuilderVRR.Speciality_RuleID__r.AND_OR__c != null && cloudBuilderVRR.Speciality_RuleID__r.AND_OR__c != '' 
                               && cloudBuilderVRR.Speciality_RuleID__r.AND_OR__c == 'AND' && conditionSatisfied){
                               if(requiredValues.size()>0){
                                  for(string value: requiredValues){
                                        if(fieldValues.size()>0){
                                            if(fieldValues.contains(value.toLowerCase())){
                                            }else{
                                                conditionSatisfied = false;
                                                break;
                                            }
                                        }
                                        else{
                                            conditionSatisfied = false;
                                        }
                                    }
                               }
                               if(conditionsatisfied && PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && profiledAccount.get(PANVPPBucketContainer.get(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c).Field_API_Name__c)=='Yes'){
                                       tierValue= string.valueof(profiledAccount.get(PANVPPBucketContainer.get(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c).Field_API_Name__c));
                               }
                               else if(PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && profiledAccount.get(PANVPPBucketContainer.get(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c).Field_API_Name__c)!='Yes'){
                                       tierValue= 'No';
                                       conditionsatisfied=false;                                       
                               }
                               if(!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && conditionSatisfied){
                                  ruleSatisfactoryCounter = ruleSatisfactoryCounter+1;
                                }
                                else if (!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && !conditionSatisfied){
                                    ruleSatisfactoryCounter = 0;
                                }
                            }
                            if(cloudBuilderVRR.Speciality_RuleID__r.AND_OR__c != null && cloudBuilderVRR.Speciality_RuleID__r.AND_OR__c != '' 
                                && (cloudBuilderVRR.Speciality_RuleID__r.AND_OR__c == 'OR' || cloudBuilderVRR.Speciality_RuleID__r.AND_OR__c == 'NA')){
                                    //ruleSatisfactoryCounter = 0;
                                if(!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && requiredValues.size()>0){                                    
                                   for(string value: requiredValues){
                                       if(fieldValues.size()>0){
                                          if(fieldValues.contains(value.toLowerCase())){
                                             conditionSatisfied = true;
                                             ruleSatisfactoryCounter = ruleSatisfactoryCounter+1;
                                          }
                                          else{
                                            conditionSatisfied = false;
                                          }
                                        }   
                                   }
                                }
                                if(PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && profiledAccount.get(PANVPPBucketContainer.get(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c).Field_API_Name__c)=='Yes'){
                                       tierValue= string.valueof(profiledAccount.get(PANVPPBucketContainer.get(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c).Field_API_Name__c));
                                }
                            }
                            if(!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && conditionSatisfied){
                                 // ruleSatisfactoryCounter = ruleSatisfactoryCounter+1;
                            }
                            else if (!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && !conditionSatisfied){
                                ruleSatisfactoryCounter = 0;
                            }
                        }
                        else{
                               
                              //ruleSatisfactoryCounter = 0;  
                            if(cloudBuilderVRR.Speciality_RuleID__r.Any_Value_Acceptable__c && !PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c) && fieldValues.size()>0 ){
                                conditionSatisfied = true; 
                                System.Debug('fieldValues---->>>>' +fieldValues);
                                ruleSatisfactoryCounter = ruleSatisfactoryCounter+1;  
                                  
                            }
                            else if (cloudBuilderVRR.Speciality_RuleID__r.Any_Value_Acceptable__c && !PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c)){
                                conditionSatisfied = false;
                            }
                        }
                    }
                }
                if(!PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c)){
                   cloudBuilderVRR.Current__c= string.valueof(ruleSatisfactoryCounter);
                }
                if(PANVPPBucketContainer.containskey(cloudBuilderVRR.Speciality_RuleID__r.Bucket__c)){
                   cloudBuilderVRR.Current__c =  tierValue;     
                }
                System.debug('tierValue->>>>>' +tierValue);
                lstVRRtoUpdate.add(cloudBuilderVRR);
            }
        }
        System.Debug('lstVRRtoUpdate--->' +lstVRRtoUpdate);
        update lstVRRtoUpdate;
    }
    
    public void evaluateLogicalBlockVelocityRulesUsingRule(List<Velocity_Rule_Results__c> lstVelocityRuleResulst){
    	
        List<String> lstLogicalBlockGroupingIds = new List<String> ();
        Set<String> setLogicalBlockRuleIds = new Set<String> ();
        Set<String> setLogicalBlockVRRIds = new Set<String> ();     
        Set<String> setGroupingIds = new Set<String> ();
        Database.SaveResult[] results;
        List <EMCException> errors = new List <EMCException>();
        Map<Id,List<Account_Groupings__c>> mapLogicalBlockAndGrouping = new Map<Id,List<Account_Groupings__c>>();       
        Map<Id,Velocity_Rule_Results__c> mapVRRofGroupingUnderLBlock = new Map<Id,Velocity_Rule_Results__c>();
        Map<String,Integer> mapLBlockRuleAndRollupCount = new Map<String,Integer>();
        Map<String,String> mapLBlockAndComplianceStatus = new Map<String,String>();
        List<Velocity_Rule_Results__c> lstCloudBuilderVelocityRuleResults = new List<Velocity_Rule_Results__c>();
        // List of Logical blocks related to Tier rule
         set<String> lstTRLogicalBlockGroupingIds = new set<String> ();
         Map<String,Integer> lbandsplcountmap = new Map<String,Integer>();
                       
        if(lstVelocityRuleResulst.size()>0){ 
            for(Velocity_Rule_Results__c objVRR: lstVelocityRuleResulst) {
            	if(objVRR.Grouping__c != null){
            		lstLogicalBlockGroupingIds.add(objVRR.Grouping__c);
            	}
            	if(objVRR.Speciality_RuleID__c != null){
                	setLogicalBlockRuleIds.add(objVRR.Speciality_RuleID__c);
            	}
            	if((objVRR.Speciality_RuleID__r.RecordType.DeveloperName =='Field_Based_Rule_Type' || ( PANVPPBucketContainer.containskey(objVRR.Speciality_RuleID__r.Bucket__c) && objVRR.Speciality_RuleID__r.Required_Type__c=='Text')) ){
                	lstCloudBuilderVelocityRuleResults.add(objVRR);   
            	}
            	setLogicalBlockVRRIds.add(objVRR.Id);
                // 212889 get LB of tier rules
                if(objVRR.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule') {
            		lstTRLogicalBlockGroupingIds.add(objVRR.Grouping__c);
            	}            
            	}
        } 
        
        //1)    Call getGroupingsonLogicalBlock()
        if(lstLogicalBlockGroupingIds.size()>0){
            mapLogicalBlockAndGrouping = Pan_VPP_UtilsObject.getGroupingsUnderLogicalBlock(lstLogicalBlockGroupingIds);
            if(mapLogicalBlockAndGrouping.size() >0){
                for(Id groupingId : mapLogicalBlockAndGrouping.KeySet()){
                    for(Account_Groupings__c objGrouping : mapLogicalBlockAndGrouping.get(groupingId)){
                        setGroupingIds.add(objGrouping.Id);                     
                    }
                } 
            }
        } 
       
       system.debug('setGroupingIds '+setGroupingIds+'  setLogicalBlockRuleIds'+setLogicalBlockRuleIds);
       
       // 2)    Fetch all Velocity Rule Results
        if(setGroupingIds.size()>0 && setLogicalBlockRuleIds.size() >0){
        
            mapVRRofGroupingUnderLBlock = new map<Id,Velocity_Rule_Results__c>([Select Id,Name,Grouping__c,Grouping__r.Logical_Block_Level_Grouping__c, Required_Value_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Required__c,
                                                                            AccountID__c,Current__c,Revenue_Amount__c,Speciality_RuleID__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Required_Type__c,
                                                                            Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.Bucket__c,Speciality_RuleID__r.Evaluation_at__c,
                                                                            Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.RecordType.DeveloperName,
                                                                            Speciality_RuleID__r.Local_Requirment_Set__c, Status__c
                                                                            from Velocity_Rule_Results__c                                                                               
                                                                            where Grouping__c in :setGroupingIds                                                                              
                                                                            and Speciality_RuleID__c in : setLogicalBlockRuleIds]);
        
            System.Debug('mapVRRofGroupingUnderLBlock--->' +mapVRRofGroupingUnderLBlock);
           
            
                	
     //3)    Using above two maps get VRRs for groupings under each logical block and sum it up.
            if(mapVRRofGroupingUnderLBlock != null && mapVRRofGroupingUnderLBlock.size()>0){
                for(Velocity_Rule_Results__c ruleResult :mapVRRofGroupingUnderLBlock.values()){                 
                    if( (ruleResult.Speciality_RuleID__r.Evaluation_at__c=='Logical Block Grouping Level' 
                        && ruleResult.Speciality_RuleID__r.RecordType.DeveloperName !='Field_Based_Rule_Type'
                        && (ruleResult.Speciality_RuleID__r.Required_Type__c =='Number/Count' || ruleResult.Speciality_RuleID__r.Required_Type__c =='USD')) 
                        || ( !PANVPPBucketContainer.containskey(ruleResult.Speciality_RuleID__r.Bucket__c) && ruleResult.Speciality_RuleID__r.Required_Type__c=='Text') ){
                            
                        //if((ruleResult.Speciality_RuleID__r.Tier__c !=null && ruleResult.Speciality_RuleID__r.Bucket__c !=null && (ruleResult.Speciality_RuleID__r.Cluster__c !=null || ruleResult.Speciality_RuleID__r.Specialty_Rule_Type__c !=null) &&
                        //  ruleResult.Speciality_RuleID__r.Display_Name__c != null) || (ruleResult.Speciality_RuleID__r.Local_Requirment_Set__c !=null)){
                            String strGroupingKey = ruleResult.Grouping__r.Logical_Block_Level_Grouping__c;
                            String  strRuleKey =  ruleResult.Speciality_RuleID__c;  
                            String strKey = strGroupingKey + strRuleKey;                                                    
                            
                            Integer sumValue = mapLBlockRuleAndRollupCount.get(strKey);
                            if(sumvalue==null){ 
                                sumvalue=0; 
                            }
                            if(ruleResult.Current__c != '' && ruleResult.Current__c != null){
                                if(ruleResult.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                                    if(ruleResult.Current__c.contains('$') && ruleResult.Current__c.contains(',')){
                                        sumValue =    sumValue+ decimal.valueof((ruleResult.Current__c.replace('$','')).replace(',','')).intValue();
                                    }else if(ruleResult.Current__c.contains('$') && !ruleResult.Current__c.contains(',')){                               
                                        sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c.replace('$','')).intValue();
                                    }else if(!ruleResult.Current__c.contains('$') && ruleResult.Current__c.contains(',')){
                                        sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c.replace(',','')).intValue();
                                    }else if(!ruleResult.Current__c.contains('$') && !ruleResult.Current__c.contains(',')){
                                        sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c).intValue();
                                    }
                                }else{
                                	sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c).intValue();
                                	
                                }
                            }                           
                            mapLBlockRuleAndRollupCount.put(strKey, sumValue );                                                     
                        //} 
                    }
                    
                    
                    if(ruleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule') {
                        if(ruleResult.Status__c == 'Not Achieved' ){
                            if(!mapLBlockAndComplianceStatus.containsKey(ruleResult.Grouping__r.Logical_Block_Level_Grouping__c)){
                                mapLBlockAndComplianceStatus.put(ruleResult.Grouping__r.Logical_Block_Level_Grouping__c, ruleResult.Status__c);
                            }
                        }
                    }
                }
            }
            List<Velocity_Rule_Results__c> lsttepmVRR = new List<Velocity_Rule_Results__c>();
            for(Velocity_Rule_Results__c objVRR: lstVelocityRuleResulst){
                if(objVRR.Grouping__c != null && objVRR.Speciality_RuleID__c != null){
                	system.debug('lb rule getting evaluated '+objVRR.id);
                    String strGroupingKey = objVRR.Grouping__c;
                    String  strRuleKey =  objVRR.Speciality_RuleID__c;  
                    String strKey = strGroupingKey + strRuleKey;
                    
                    if(mapLBlockRuleAndRollupCount.containsKey(strKey)){
                        if(objVRR.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                            objVRR.Revenue_Amount__c = string.valueof(mapLBlockRuleAndRollupCount.get(strKey)); 
                            List<String> args = new String[]{'0','number','$###,###,###.00'};                      
                            Decimal decRevenueAmmount = Decimal.valueOf(objVRR.Revenue_Amount__c);                 
                            String strrevenue = String.format(decRevenueAmmount.format(), args);  
                            objVRR.Current__c = '$' + strrevenue;
                        }else{
                        	objVRR.Current__c = string.valueof(mapLBlockRuleAndRollupCount.get(strKey));
                        }
                        lsttepmVRR.add(objVRR);
                    }
                }
            }
            
            if(lstCloudBuilderVelocityRuleResults.size()>0){
                evaluateCloudBuilderLogicalBlockRules(lstCloudBuilderVelocityRuleResults);
            }
            //5)    Update Velocity Rule Results for logical block
            System.Debug('lsttepmVRR--->' +lsttepmVRR);
            System.Debug('lsttepmVRR--->' +lsttepmVRR.size());
            results = database.update(lsttepmVRR,false);
            
            System.Debug('lstCloudBuilderVelocityRuleResults--->' +lstCloudBuilderVelocityRuleResults);
            System.Debug('lstCloudBuilderVelocityRuleResults--->' +lstCloudBuilderVelocityRuleResults.size());
            List<Velocity_Rule_Results__c> lstLogicalBlockVRR =[Select Id, Status__c, Grouping__c,Speciality_RuleID__r.RecordType.DeveloperName,Speciality_RuleID__r.Required_Type__c,
                                                                Speciality_RuleID__r.Tier__c,Grouping__r.RecordType.DeveloperName,Grouping__r.Target_Tier__c,Speciality_RuleID__r.Required__c
                                                                From Velocity_Rule_Results__c where id in :setLogicalBlockVRRIds and Speciality_RuleID__r.RecordType.DeveloperName !='Field_Based_Rule_Type'];
            if(lstLogicalBlockVRR != null && lstLogicalBlockVRR.size() >0){
                for(Velocity_Rule_Results__c ruleResult : lstLogicalBlockVRR){
                    if(ruleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule' && ruleResult.Grouping__r.RecordType.DeveloperName == 'Partner_Grouping_Logical_Block'
                       && ruleResult.Grouping__r.Target_Tier__c == ruleResult.Speciality_RuleID__r.Tier__c) {
                        if(ruleResult.Status__c == 'Not Achieved' && (!((ruleResult.Speciality_RuleID__r.Required_Type__c =='Text') && (ruleResult.Speciality_RuleID__r.Required__c =='n/a' || ruleResult.Speciality_RuleID__r.Required__c =='Optional') ))){
                            if(!mapLBlockAndComplianceStatus.containsKey(ruleResult.Grouping__c)){
                                mapLBlockAndComplianceStatus.put(ruleResult.Grouping__c, ruleResult.Status__c);
                            }
                        }
                    }
                }
            }
                
            Map<Id,Account_Groupings__c> mapLogicalBlock = new Map<Id,Account_Groupings__c>([Select Id,Compliance_Period_Requirments_Met__c,Local_Requirment_Set__c from Account_Groupings__c where Id in :lstLogicalBlockGroupingIds and Active__c =true]);
            for(Account_Groupings__c objLBGrouping : mapLogicalBlock.values() ){                        
                if(!mapLBlockAndComplianceStatus.containsKey(objLBGrouping.Id)){
                    mapLogicalBlock.get(objLBGrouping.Id).Compliance_Period_Requirments_Met__c='Yes';
                }
                if(mapLBlockAndComplianceStatus.containsKey(objLBGrouping.Id)){
                    mapLogicalBlock.get(objLBGrouping.Id).Compliance_Period_Requirments_Met__c='No';
                }
            }
            
            
            //6) Check if all rules for each logical block has been satiesfied - status field should be achieved
            //if yes set "Compliance Period Requirements Met"  = true else set "Compliance Period Requirements Met"  = false
            results = database.update(mapLogicalBlock.values(),false);   
            // 212889 Get all the specialty rules on the logical blocks assuming that the specialty rules are evalauted 
        // in previous batches.
         if(lstTRLogicalBlockGroupingIds.size()>0){
            List<Velocity_Rule_Results__c> lstLogicalBlockSplVRR =[Select Id, Status__c, Grouping__c,Speciality_RuleID__r.RecordType.DeveloperName,Speciality_RuleID__r.Required_Type__c,Current__c,RequiredCount__c,
                                                                Speciality_RuleID__r.Tier__c,Grouping__r.RecordType.DeveloperName,Grouping__r.Target_Tier__c,Speciality_RuleID__r.Required__c,Speciality_RuleID__r.Specilaity__c
                                                                From Velocity_Rule_Results__c where Grouping__c in :lstTRLogicalBlockGroupingIds and Speciality_RuleID__r.RecordType.DeveloperName ='Specialty_Rule'];
            lbandsplcountmap = evaluatecurrentvalueonvrr(lstLogicalBlockSplVRR);
            List<Velocity_Rule_Results__c> lsttoupdate = new List<Velocity_Rule_Results__c>();
            //212889 assuming that all the specialty rules are evaluated in previous batches and getting the current__c value
                        	// for tier rules from the  map lbandsplcountmap
            for(Velocity_Rule_Results__c objVRR: lstVelocityRuleResulst){
                if(objVRR.Grouping__c != null && objVRR.Speciality_RuleID__c != null){
                	String strGroupingKey = objVRR.Grouping__c;
                    if(DataValueMap.get('PRM_VPP_Velocity_Program_Bucket')!=null && 
                       objVRR.Speciality_RuleID__r.Bucket__c == DataValueMap.get('PRM_VPP_Velocity_Program_Bucket').DataValue__c){
                   		 objVRR.Current__c = string.valueof(lbandsplcountmap.get(strGroupingKey));
                    }
                    lsttoupdate.add(objVRR);
                } 
            }
            if(lsttoupdate.size()>0){
            	results = database.update(lsttoupdate,false);
            }
         }         
        }
    }
    
     public void evaluateLogicalBlockVelocityRulesUsingRulewitherrors(List<Velocity_Rule_Results__c> lstVelocityRuleResulst,string Batchid, List<EMCException> emailerrors){
        List<String> lstLogicalBlockGroupingIds = new List<String> ();        
        Set<String> setLogicalBlockRuleIds = new Set<String> ();
        Set<String> setLogicalBlockVRRIds = new Set<String> ();     
        Set<String> setGroupingIds = new Set<String> ();
        Database.SaveResult[] results;
        List <EMCException> errors = new List <EMCException>();
        Map<Id,List<Account_Groupings__c>> mapLogicalBlockAndGrouping = new Map<Id,List<Account_Groupings__c>>();       
        Map<Id,Velocity_Rule_Results__c> mapVRRofGroupingUnderLBlock = new Map<Id,Velocity_Rule_Results__c>();
        Map<String,Integer> mapLBlockRuleAndRollupCount = new Map<String,Integer>();
        Map<String,String> mapLBlockAndComplianceStatus = new Map<String,String>();
        List<Velocity_Rule_Results__c> lstCloudBuilderVelocityRuleResults = new List<Velocity_Rule_Results__c>();
        // List of Logical blocks related to Tier rule
         set<String> lstTRLogicalBlockGroupingIds = new set<String> ();
         Map<String,Integer> lbandsplcountmap = new Map<String,Integer>();
        if(lstVelocityRuleResulst.size()>0){ 
            for(Velocity_Rule_Results__c objVRR: lstVelocityRuleResulst){  
                if(objVRR.Grouping__c != null){
                    lstLogicalBlockGroupingIds.add(objVRR.Grouping__c);
                }
                if(objVRR.Speciality_RuleID__c != null){
                    setLogicalBlockRuleIds.add(objVRR.Speciality_RuleID__c);
                }
                if((objVRR.Speciality_RuleID__r.RecordType.DeveloperName =='Field_Based_Rule_Type' || ( PANVPPBucketContainer.containskey(objVRR.Speciality_RuleID__r.Bucket__c) && objVRR.Speciality_RuleID__r.Required_Type__c=='Text')) ){
                    lstCloudBuilderVelocityRuleResults.add(objVRR);   
                }
                setLogicalBlockVRRIds.add(objVRR.Id);
                // 212889 get LB of tier rules
                if(objVRR.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule') {
                	lstTRLogicalBlockGroupingIds.add(objVRR.Grouping__c);
            	} 
            }   
        } 
        // 212889 Get all the specialty rules on the logical blocks assuming that the specialty rules are evalauted 
        // in previous batches.
         if(lstTRLogicalBlockGroupingIds.size()>0){
         	system.debug('in if loop before calling evalautecurrent method '+lstTRLogicalBlockGroupingIds.size());
            List<Velocity_Rule_Results__c> lstLogicalBlockSplVRR =[Select Id, Status__c, Grouping__c,Speciality_RuleID__r.RecordType.DeveloperName,Speciality_RuleID__r.Required_Type__c,Current__c,RequiredCount__c,
                                                                Speciality_RuleID__r.Tier__c,Grouping__r.RecordType.DeveloperName,Grouping__r.Target_Tier__c,Speciality_RuleID__r.Required__c,Speciality_RuleID__r.Specilaity__c
                                                                From Velocity_Rule_Results__c where Grouping__c in :lstTRLogicalBlockGroupingIds and Speciality_RuleID__r.RecordType.DeveloperName ='Specialty_Rule'];
            lbandsplcountmap = evaluatecurrentvalueonvrr(lstLogicalBlockSplVRR);
         }
        //1)    Call getGroupingsonLogicalBlock()
        if(lstLogicalBlockGroupingIds.size()>0){
            mapLogicalBlockAndGrouping = Pan_VPP_UtilsObject.getGroupingsUnderLogicalBlock(lstLogicalBlockGroupingIds);
            if(mapLogicalBlockAndGrouping.size() >0){
                for(Id groupingId : mapLogicalBlockAndGrouping.KeySet()){
                    for(Account_Groupings__c objGrouping : mapLogicalBlockAndGrouping.get(groupingId)){
                        setGroupingIds.add(objGrouping.Id);                     
                    }
                } 
            }
        } 
        
        // 2)    Fetch all Velocity Rule Results
        if(setGroupingIds.size()>0 && setLogicalBlockRuleIds.size() >0){
        
            mapVRRofGroupingUnderLBlock = new map<Id,Velocity_Rule_Results__c>([Select Id,Name,Grouping__c,Grouping__r.Logical_Block_Level_Grouping__c, Required_Value_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Required__c,
                                                                            AccountID__c,Current__c,Revenue_Amount__c,Speciality_RuleID__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Required_Type__c,
                                                                            Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.Bucket__c,Speciality_RuleID__r.Evaluation_at__c,
                                                                            Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.RecordType.DeveloperName,
                                                                            Speciality_RuleID__r.Local_Requirment_Set__c, Status__c
                                                                            from Velocity_Rule_Results__c                                                                               
                                                                            where Grouping__c in :setGroupingIds                                                                              
                                                                            and Speciality_RuleID__c in : setLogicalBlockRuleIds]);
        
            System.Debug('mapVRRofGroupingUnderLBlock--->' +mapVRRofGroupingUnderLBlock);
           
            //3)    Using above two maps get VRRs for groupings under each logical block and sum it up.
            if(mapVRRofGroupingUnderLBlock != null && mapVRRofGroupingUnderLBlock.size()>0){
                for(Velocity_Rule_Results__c ruleResult :mapVRRofGroupingUnderLBlock.values()){                 
                    if( (ruleResult.Speciality_RuleID__r.Evaluation_at__c=='Logical Block Grouping Level' 
                        && ruleResult.Speciality_RuleID__r.RecordType.DeveloperName !='Field_Based_Rule_Type'
                        && (ruleResult.Speciality_RuleID__r.Required_Type__c =='Number/Count' || ruleResult.Speciality_RuleID__r.Required_Type__c =='USD')) 
                        || ( !PANVPPBucketContainer.containskey(ruleResult.Speciality_RuleID__r.Bucket__c) && ruleResult.Speciality_RuleID__r.Required_Type__c=='Text') ){
                            
                        //if((ruleResult.Speciality_RuleID__r.Tier__c !=null && ruleResult.Speciality_RuleID__r.Bucket__c !=null && (ruleResult.Speciality_RuleID__r.Cluster__c !=null || ruleResult.Speciality_RuleID__r.Specialty_Rule_Type__c !=null) &&
                        //  ruleResult.Speciality_RuleID__r.Display_Name__c != null) || (ruleResult.Speciality_RuleID__r.Local_Requirment_Set__c !=null)){
                            String strGroupingKey = ruleResult.Grouping__r.Logical_Block_Level_Grouping__c;
                            String  strRuleKey =  ruleResult.Speciality_RuleID__c;  
                            String strKey = strGroupingKey + strRuleKey;                                                    
                             
                            Integer sumValue = mapLBlockRuleAndRollupCount.get(strKey);
                            if(sumvalue==null){ 
                                sumvalue=0; 
                            }
                            if(ruleResult.Current__c != '' && ruleResult.Current__c != null){
                                if(ruleResult.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                                    if(ruleResult.Current__c.contains('$') && ruleResult.Current__c.contains(',')){
                                        sumValue =    sumValue+ decimal.valueof((ruleResult.Current__c.replace('$','')).replace(',','')).intValue();
                                    }else if(ruleResult.Current__c.contains('$') && !ruleResult.Current__c.contains(',')){                               
                                        sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c.replace('$','')).intValue();
                                    }else if(!ruleResult.Current__c.contains('$') && ruleResult.Current__c.contains(',')){
                                        sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c.replace(',','')).intValue();
                                    }else if(!ruleResult.Current__c.contains('$') && !ruleResult.Current__c.contains(',')){
                                        sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c).intValue();
                                    }
                                }else{                                	
                                   sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c).intValue();
                                }
                            }                           
                            mapLBlockRuleAndRollupCount.put(strKey, sumValue );                                                     
                        //} 
                    }
                    
                    
                    if(ruleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule') {
                        if(ruleResult.Status__c == 'Not Achieved' ){
                            if(!mapLBlockAndComplianceStatus.containsKey(ruleResult.Grouping__r.Logical_Block_Level_Grouping__c)){
                                mapLBlockAndComplianceStatus.put(ruleResult.Grouping__r.Logical_Block_Level_Grouping__c, ruleResult.Status__c);
                            }
                        }
                    }
                }
            }
            List<Velocity_Rule_Results__c> lsttepmVRR = new List<Velocity_Rule_Results__c>();
            for(Velocity_Rule_Results__c objVRR: lstVelocityRuleResulst){
            	system.debug('lb rule getting evaluated '+objVRR.id);
                if(objVRR.Grouping__c != null && objVRR.Speciality_RuleID__c != null){
                    String strGroupingKey = objVRR.Grouping__c;
                    String  strRuleKey =  objVRR.Speciality_RuleID__c;  
                    String strKey = strGroupingKey + strRuleKey;
                    
                    if(mapLBlockRuleAndRollupCount.containsKey(strKey)){
                        if(objVRR.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                            objVRR.Revenue_Amount__c = string.valueof(mapLBlockRuleAndRollupCount.get(strKey)); 
                            List<String> args = new String[]{'0','number','$###,###,###.00'};                      
                            Decimal decRevenueAmmount = Decimal.valueOf(objVRR.Revenue_Amount__c);                 
                            String strrevenue = String.format(decRevenueAmmount.format(), args);  
                            objVRR.Current__c = '$' + strrevenue;
                        }else{
                        	//212889 assuming that all the specialty rules are evaluated in previous batches and getting the current__c value
                        	// for tier rules from the  map lbandsplcountmap
                        	if(DataValueMap.get('PRM_VPP_Velocity_Program_Bucket')!=null && 
                        	objVRR.Speciality_RuleID__r.Bucket__c == DataValueMap.get('PRM_VPP_Velocity_Program_Bucket').DataValue__c){
                        		objVRR.Current__c = string.valueof(lbandsplcountmap.get(strGroupingKey));
                        	}else{
                        		objVRR.Current__c = string.valueof(mapLBlockRuleAndRollupCount.get(strKey));
                        	}
                        }
                        lsttepmVRR.add(objVRR);
                    }
                }
            }
            
            if(lstCloudBuilderVelocityRuleResults.size()>0){
                evaluateCloudBuilderLogicalBlockRules(lstCloudBuilderVelocityRuleResults);
            }
            
            //5)    Update Velocity Rule Results for logical block
            System.Debug('lsttepmVRR--->' +lsttepmVRR);
            System.Debug('lsttepmVRR--->' +lsttepmVRR.size());
            results = database.update(lsttepmVRR,false);
              
             /* HANDLING EXCEPTION LOG*/
		        for (Database.Saveresult sr : results) {
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
		       if (errors.size() > 0) { 
		            EMC_UTILITY.logErrors(errors);
		            emailerrors.addall(errors);
		            system.debug('emailerrorsemailerrors'+emailerrors);  
		        }	
            System.Debug('lstCloudBuilderVelocityRuleResults--->' +lstCloudBuilderVelocityRuleResults);
            System.Debug('lstCloudBuilderVelocityRuleResults--->' +lstCloudBuilderVelocityRuleResults.size());
            List<Velocity_Rule_Results__c> lstLogicalBlockVRR =[Select Id, Status__c, Grouping__c,Speciality_RuleID__r.RecordType.DeveloperName,Speciality_RuleID__r.Required_Type__c,
                                                                Speciality_RuleID__r.Tier__c,Grouping__r.RecordType.DeveloperName,Grouping__r.Target_Tier__c,Speciality_RuleID__r.Required__c
                                                                From Velocity_Rule_Results__c where id in :setLogicalBlockVRRIds and Speciality_RuleID__r.RecordType.DeveloperName !='Field_Based_Rule_Type'];
            if(lstLogicalBlockVRR != null && lstLogicalBlockVRR.size() >0){
                for(Velocity_Rule_Results__c ruleResult : lstLogicalBlockVRR){
                    if(ruleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule' && ruleResult.Grouping__r.RecordType.DeveloperName == 'Partner_Grouping_Logical_Block'
                       && ruleResult.Grouping__r.Target_Tier__c == ruleResult.Speciality_RuleID__r.Tier__c) {
                        if(ruleResult.Status__c == 'Not Achieved' && (!((ruleResult.Speciality_RuleID__r.Required_Type__c =='Text') && (ruleResult.Speciality_RuleID__r.Required__c =='n/a' || ruleResult.Speciality_RuleID__r.Required__c =='Optional') ))){
                            if(!mapLBlockAndComplianceStatus.containsKey(ruleResult.Grouping__c)){
                                mapLBlockAndComplianceStatus.put(ruleResult.Grouping__c, ruleResult.Status__c);
                            }
                        }
                    }
                }
            }
                
            Map<Id,Account_Groupings__c> mapLogicalBlock = new Map<Id,Account_Groupings__c>([Select Id,Compliance_Period_Requirments_Met__c,Local_Requirment_Set__c from Account_Groupings__c where Id in :lstLogicalBlockGroupingIds and Active__c =true]);
            for(Account_Groupings__c objLBGrouping : mapLogicalBlock.values() ){                        
                if(!mapLBlockAndComplianceStatus.containsKey(objLBGrouping.Id)){
                    mapLogicalBlock.get(objLBGrouping.Id).Compliance_Period_Requirments_Met__c='Yes';
                }
                if(mapLBlockAndComplianceStatus.containsKey(objLBGrouping.Id)){
                    mapLogicalBlock.get(objLBGrouping.Id).Compliance_Period_Requirments_Met__c='No';
                }
            }
            
            //6) Check if all rules for each logical block has been satiesfied - status field should be achieved
            //if yes set "Compliance Period Requirements Met"  = true else set "Compliance Period Requirements Met"  = false
            results = database.update(mapLogicalBlock.values(),false);
             /* HANDLING EXCEPTION LOG*/
		        for (Database.Saveresult sr : results) {
		            String dataErrs = '';
		            if (!sr.isSuccess()) {
		                // if the particular record did not get updated, we log the data error 
		                for (Database.Error err : sr.getErrors()) {
		                    dataErrs += err.getMessage();
		                }
		                System.debug('An exception occurred while attempting an update on ' + sr.getId());
		                System.debug('ERROR: ' + dataErrs);
		                errors.add(new EMCException(dataErrs, 'PRM_Contact_Functional_Area_UpdateBatch', new String [] {sr.getId()}));
		            }
		        }
		      // log any errors that occurred
		       if (errors.size() > 0) { 
		            EMC_UTILITY.logErrors(errors);  
		            emailerrors.addall(errors);
		            system.debug('emailerrorsemailerrors'+emailerrors); 
		        }	
        }
    }
    
    
    public void evaluatePanVelocityRulesUsingRule(List<Velocity_Rule_Results__c> lstVelocityRuleResulst){
        List<Id> setPanGroupingIds = new List<Id> ();
        Set<String> setPanRuleIds = new Set<String> ();
        Set<String> setPanAndRuleIds = new Set<String> ();
        Set<String> setPanVRRIds = new Set<String> ();
        Set<String> setGroupingIds = new Set<String> ();
        Map<Id,List<Account_Groupings__c>> mapPanAndGrouping = new Map<Id,List<Account_Groupings__c>>();        
        Map<Id,Velocity_Rule_Results__c> mapVRRofGroupingUnderPan = new Map<Id,Velocity_Rule_Results__c>();     
        Map<String,Integer> mapPanRuleAndRollupCount = new Map<String,Integer>();
        Map<String,String> mapPanAndComplianceStatus = new Map<String,String>();
        List<Velocity_Rule_Results__c> lstCloudBuilderVelocityRuleResults = new List<Velocity_Rule_Results__c>();
        // List of Logical blocks related to Tier rule
         set<String> lstTRLogicalBlockGroupingIds = new set<String> ();
         Map<String,Integer> lbandsplcountmap = new Map<String,Integer>();
        if(lstVelocityRuleResulst.size()>0){ 
            for(Velocity_Rule_Results__c objVRR: lstVelocityRuleResulst){  
                if(objVRR.Grouping__c != null){
                    setPanGroupingIds.add(objVRR.Grouping__c);
                }
                if(objVRR.Speciality_RuleID__c != null){
                    setPanRuleIds.add(objVRR.Speciality_RuleID__c);
                }
                if((objVRR.Speciality_RuleID__r.RecordType.DeveloperName =='Field_Based_Rule_Type' || ( PANVPPBucketContainer.containskey(objVRR.Speciality_RuleID__r.Bucket__c) && objVRR.Speciality_RuleID__r.Required_Type__c=='Text')) ){
                    lstCloudBuilderVelocityRuleResults.add(objVRR);   
                }   
                setPanVRRIds.add(objVRR.Id); 
                // 212889 get LB of tier rules
                if(objVRR.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule') {
            		lstTRLogicalBlockGroupingIds.add(objVRR.Grouping__c);
            	}                              
            }   
        }
        //1)    Call getGroupingsonLogicalBlock()
        if(setPanGroupingIds.size()>0){
            mapPanAndGrouping = Pan_VPP_UtilsObject.getGroupingsUnderPANLevel(setPanGroupingIds);
            if(mapPanAndGrouping.size() >0){
                for(Id groupingId : mapPanAndGrouping.KeySet()){
                    for(Account_Groupings__c objGrouping : mapPanAndGrouping.get(groupingId)){
                        setGroupingIds.add(objGrouping.Id);                     
                    }
                }
            }
        } 
         
        // 2)    Fetch all Velocity Rule Results
        if(setGroupingIds.size()>0 && setPanRuleIds.size() >0){
        
            mapVRRofGroupingUnderPan = new map<Id,Velocity_Rule_Results__c>([Select Id,Name,Grouping__c,Grouping__r.Logical_Block_Level_Grouping__c,Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c, 
                                                                            Required_Value_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Required__c,Speciality_RuleID__r.Evaluation_at__c,
                                                                            AccountID__c,Current__c,Revenue_Amount__c,Speciality_RuleID__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Required_Type__c,
                                                                            Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.Bucket__c,
                                                                            Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.RecordType.DeveloperName,
                                                                            Speciality_RuleID__r.Local_Requirment_Set__c, Status__c
                                                                            from Velocity_Rule_Results__c                                                                               
                                                                            where Grouping__c in :setGroupingIds                                                                              
                                                                            and Speciality_RuleID__c in : setPanRuleIds]);
        
            System.Debug('mapVRRofGroupingUnderPan--->' +mapVRRofGroupingUnderPan);
            System.Debug('mapVRRofGroupingUnderPan--->' +mapVRRofGroupingUnderPan.KeySet().size());
            
            //3)    Using above two maps get VRRs for groupings under each logical block and sum it up.
            if(mapVRRofGroupingUnderPan != null && mapVRRofGroupingUnderPan.size()>0){
                for(Velocity_Rule_Results__c ruleResult :mapVRRofGroupingUnderPan.values()){
                    System.Debug('ruleResult.Speciality_RuleID__r.Evaluation_at__c--->' +ruleResult.Speciality_RuleID__r.Evaluation_at__c);
                    System.Debug('ruleResult.Speciality_RuleID__r.Required_Type__c--->' +ruleResult.Speciality_RuleID__r.Required_Type__c);
                    System.Debug('ruleResult.Speciality_RuleID__r.Bucket__c--->' + ruleResult.Speciality_RuleID__r.Bucket__c);
                    System.Debug('ruleResult.Speciality_RuleID__r.Current__c--->' + ruleResult.Current__c);                 
                    if( (ruleResult.Speciality_RuleID__r.Evaluation_at__c=='PAN Theater Grouping Level' 
                        && ruleResult.Speciality_RuleID__r.RecordType.DeveloperName !='Field_Based_Rule_Type'
                        && (ruleResult.Speciality_RuleID__r.Required_Type__c =='Number/Count' || ruleResult.Speciality_RuleID__r.Required_Type__c =='USD')) 
                        || ( !PANVPPBucketContainer.containskey(ruleResult.Speciality_RuleID__r.Bucket__c) && ruleResult.Speciality_RuleID__r.Required_Type__c=='Text') ){
                        //if((ruleResult.Speciality_RuleID__r.Tier__c !=null && ruleResult.Speciality_RuleID__r.Bucket__c !=null && (ruleResult.Speciality_RuleID__r.Cluster__c !=null || ruleResult.Speciality_RuleID__r.Specialty_Rule_Type__c !=null) &&
                        //  ruleResult.Speciality_RuleID__r.Display_Name__c != null) || (ruleResult.Speciality_RuleID__r.Local_Requirment_Set__c !=null)){
                            
                            String strGroupingKey = ruleResult.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c;
                            String  strRuleKey =  ruleResult.Speciality_RuleID__c;  
                            String strKey = strGroupingKey + strRuleKey;    
                            
                            System.Debug('ruleResult.Grouping__c--->' +ruleResult.Grouping__c);
                            System.Debug('ruleResult.Speciality_RuleID__c--->' +ruleResult.Speciality_RuleID__c);                   
                            System.Debug('mapPanRuleAndRollupCount--->' +mapPanRuleAndRollupCount);
                                                                                    
                            Integer sumValue = mapPanRuleAndRollupCount.get(strKey);
                            if(sumvalue==null){
                                sumvalue=0; 
                            }
                            if(ruleResult.Current__c != '' && ruleResult.Current__c != null){
                                if(ruleResult.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                                    if(ruleResult.Current__c.contains('$') && ruleResult.Current__c.contains(',')){
                                        sumValue =    sumValue+ decimal.valueof((ruleResult.Current__c.replace('$','')).replace(',','')).intvalue();
                                    }else if(ruleResult.Current__c.contains('$') && !ruleResult.Current__c.contains(',')){                               
                                        sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c.replace('$','')).intValue();
                                    }else if(!ruleResult.Current__c.contains('$') && ruleResult.Current__c.contains(',')){
                                        sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c.replace(',','')).intValue();
                                    }else if(!ruleResult.Current__c.contains('$') && !ruleResult.Current__c.contains(',')){
                                        sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c).intValue();
                                    }
                                }else{                                	                             
                                	sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c).intValue();
                                }
                                
                            }   
                            System.Debug('sumValue--->' +sumValue); 
                            System.Debug('mapPanRuleAndRollupCount--->' +mapPanRuleAndRollupCount);                     
                            mapPanRuleAndRollupCount.put(strKey, sumValue );                                                        
                        //} 
                    }
                    //else if((ruleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Field_Based_Rule_Type' || ( PANVPPBucketContainer.containskey(ruleResult.Speciality_RuleID__r.Bucket__c) && ruleResult.Speciality_RuleID__r.Required_Type__c=='Text')) ){
                    //  lstCloudBuilderVelocityRuleResults.add(ruleResult);   
                    //}                 
                    
                }
            }
            List<Velocity_Rule_Results__c> lsttepmVRR = new List<Velocity_Rule_Results__c>();
            for(Velocity_Rule_Results__c objVRR: lstVelocityRuleResulst){
                System.Debug('objVRR--->' +objVRR);
                if(objVRR.Grouping__c != null && objVRR.Speciality_RuleID__c != null){
                    
                    String strGroupingKey = objVRR.Grouping__c;
                    String  strRuleKey =  objVRR.Speciality_RuleID__c;  
                    String strKey = strGroupingKey + strRuleKey;
                   
                    System.Debug('objVRR--->1' +objVRR);
                    System.Debug('objVRR.Grouping__c--->1' +objVRR.Grouping__c);
                    System.Debug('objVRR.Speciality_RuleID__c--->1' +objVRR.Speciality_RuleID__c);                  
                    System.Debug('mapPanRuleAndRollupCount--->1' +mapPanRuleAndRollupCount.size());
                    System.Debug('mapPanRuleAndRollupCount.containsKey(strKey)--->1' +mapPanRuleAndRollupCount.containsKey(strKey));
                    
                    if(mapPanRuleAndRollupCount.containsKey(strKey)){
                        if(objVRR.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                            objVRR.Revenue_Amount__c = string.valueof(mapPanRuleAndRollupCount.get(strKey)); 
                            List<String> args = new String[]{'0','number','$###,###,###.00'};                      
                            Decimal decRevenueAmmount = Decimal.valueOf(objVRR.Revenue_Amount__c);                 
                            String strrevenue = String.format(decRevenueAmmount.format(), args);  
                            objVRR.Current__c = '$' + strrevenue;
                        }else{
                        	objVRR.Current__c = string.valueof(mapPanRuleAndRollupCount.get(strKey));
                        }
                        lsttepmVRR.add(objVRR);
                    }
                }
            } 
            
            //5)    Update Velocity Rule Results for logical block
            System.Debug('lsttepmVRR--->' +lsttepmVRR);
            System.Debug('lsttepmVRR--->' +lsttepmVRR.size());
            update lsttepmVRR;
            
            System.Debug('lstCloudBuilderVelocityRuleResults--->' +lstCloudBuilderVelocityRuleResults);
            System.Debug('lstCloudBuilderVelocityRuleResults--->' +lstCloudBuilderVelocityRuleResults.size());
            
            if(lstCloudBuilderVelocityRuleResults.size()>0){
                evaluateCloudBuilderPANLevelRules(lstCloudBuilderVelocityRuleResults);
            }
        
            List<Velocity_Rule_Results__c> lstPanVRR =[Select Id, Status__c, Grouping__c, Speciality_RuleID__r.RecordType.DeveloperName,Speciality_RuleID__r.Required__c,
                                                       Speciality_RuleID__r.Tier__c,Grouping__r.RecordType.DeveloperName,Grouping__r.Target_Tier__c,Speciality_RuleID__r.Required_Type__c
                                                        From Velocity_Rule_Results__c where id in :setPanVRRIds and Speciality_RuleID__r.RecordType.DeveloperName !='Field_Based_Rule_Type' ];
            if(lstPanVRR != null && lstPanVRR.size() >0){
                for(Velocity_Rule_Results__c ruleResult : lstPanVRR){
                    if(ruleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule' && ruleResult.Grouping__r.RecordType.DeveloperName == 'Partner_Grouping_PAN_Theater'
                       && ruleResult.Grouping__r.Target_Tier__c == ruleResult.Speciality_RuleID__r.Tier__c) {
                        if(ruleResult.Status__c == 'Not Achieved' && (!((ruleResult.Speciality_RuleID__r.Required_Type__c =='Text') && (ruleResult.Speciality_RuleID__r.Required__c =='n/a' || ruleResult.Speciality_RuleID__r.Required__c =='Optional') )) ){
                            if(!mapPanAndComplianceStatus.containsKey(ruleResult.Grouping__c)){
                                mapPanAndComplianceStatus.put(ruleResult.Grouping__c, ruleResult.Status__c);
                            }
                        }
                    }
                }
            }
            
            Map<Id,Account_Groupings__c> mapLogicalBlock = new Map<Id,Account_Groupings__c>([Select Id,Compliance_Period_Requirments_Met__c,Local_Requirment_Set__c from Account_Groupings__c where Id in :setPanGroupingIds and Active__c =true]);
            for(Account_Groupings__c objPanGrouping : mapLogicalBlock.values() ){                       
                if(!mapPanAndComplianceStatus.containsKey(objPanGrouping.Id)){
                    mapLogicalBlock.get(objPanGrouping.Id).Compliance_Period_Requirments_Met__c='Yes';
                }
                if(mapPanAndComplianceStatus.containsKey(objPanGrouping.Id)){
                    mapLogicalBlock.get(objPanGrouping.Id).Compliance_Period_Requirments_Met__c='No';
                }
            }
            
            //6) Check if all rules for each logical block has been satiesfied - status field should be achieved
            //if yes set "Compliance Period Requirements Met"  = true else set "Compliance Period Requirements Met"  = false
            update mapLogicalBlock.values();
      // 212889 Get all the specialty rules on the pan blocks assuming that the specialty rules are evalauted 
        // in previous batches.
         if(lstTRLogicalBlockGroupingIds.size()>0){
            List<Velocity_Rule_Results__c> lstLogicalBlockSplVRR =[Select Id, Status__c, Grouping__c,Speciality_RuleID__r.RecordType.DeveloperName,Speciality_RuleID__r.Required_Type__c,Current__c,RequiredCount__c,
                                                                Speciality_RuleID__r.Tier__c,Grouping__r.RecordType.DeveloperName,Grouping__r.Target_Tier__c,Speciality_RuleID__r.Required__c,Speciality_RuleID__r.Specilaity__c
                                                                From Velocity_Rule_Results__c where Grouping__c in :lstTRLogicalBlockGroupingIds and Speciality_RuleID__r.RecordType.DeveloperName ='Specialty_Rule'];
            lbandsplcountmap = evaluatecurrentvalueonvrr(lstLogicalBlockSplVRR);
            List<Velocity_Rule_Results__c> lsttoupdate = new List<Velocity_Rule_Results__c>();
            //212889 assuming that all the specialty rules are evaluated in previous batches and getting the current__c value
                        	// for tier rules from the  map lbandsplcountmap
            for(Velocity_Rule_Results__c objVRR: lstVelocityRuleResulst){
                if(objVRR.Grouping__c != null && objVRR.Speciality_RuleID__c != null){
                	String strGroupingKey = objVRR.Grouping__c;
                    if(DataValueMap.get('PRM_VPP_Velocity_Program_Bucket')!=null && 
                       objVRR.Speciality_RuleID__r.Bucket__c == DataValueMap.get('PRM_VPP_Velocity_Program_Bucket').DataValue__c){
                   		 objVRR.Current__c = string.valueof(lbandsplcountmap.get(strGroupingKey));
                    }
                    lsttoupdate.add(objVRR);
                } 
            }
            if(lsttoupdate.size()>0){
            	update lsttoupdate;
            }
         }
        }
    }
    
     public void evaluatePanVelocityRulesUsingRulewitherrors(List<Velocity_Rule_Results__c> lstVelocityRuleResulst,string batchid,List<EMCException> emailerrors){
        List<Id> setPanGroupingIds = new List<Id> ();
        Set<String> setPanRuleIds = new Set<String> ();
        Set<String> setPanAndRuleIds = new Set<String> ();
        Set<String> setPanVRRIds = new Set<String> ();
        Set<String> setGroupingIds = new Set<String> ();
        List <EMCException> errors = new List <EMCException>();
        Map<Id,List<Account_Groupings__c>> mapPanAndGrouping = new Map<Id,List<Account_Groupings__c>>();        
        Map<Id,Velocity_Rule_Results__c> mapVRRofGroupingUnderPan = new Map<Id,Velocity_Rule_Results__c>();     
        Map<String,Integer> mapPanRuleAndRollupCount = new Map<String,Integer>();
        Map<String,String> mapPanAndComplianceStatus = new Map<String,String>();
        List<Velocity_Rule_Results__c> lstCloudBuilderVelocityRuleResults = new List<Velocity_Rule_Results__c>();
        // List of groupings related to Tier rule
         set<String> lstTRLogicalBlockGroupingIds = new set<String> ();
         Map<String,Integer> lbandsplcountmap = new Map<String,Integer>();
        if(lstVelocityRuleResulst.size()>0){ 
            for(Velocity_Rule_Results__c objVRR: lstVelocityRuleResulst){  
                if(objVRR.Grouping__c != null){
                    setPanGroupingIds.add(objVRR.Grouping__c);
                }
                if(objVRR.Speciality_RuleID__c != null){
                    setPanRuleIds.add(objVRR.Speciality_RuleID__c);
                }
                if((objVRR.Speciality_RuleID__r.RecordType.DeveloperName =='Field_Based_Rule_Type' || ( PANVPPBucketContainer.containskey(objVRR.Speciality_RuleID__r.Bucket__c) && objVRR.Speciality_RuleID__r.Required_Type__c=='Text')) ){
                    lstCloudBuilderVelocityRuleResults.add(objVRR);   
                }   
                setPanVRRIds.add(objVRR.Id);   
                // 212889 get grouping id of tier rules
                if(objVRR.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule') {
                	lstTRLogicalBlockGroupingIds.add(objVRR.Grouping__c);
            	}                          
            }   
        }
        // 212889 Get all the specialty rules on the logical blocks assuming that the specialty rules are evalauted
        // in previous batches.
         if(lstTRLogicalBlockGroupingIds.size()>0){
         	system.debug('in if loop before calling evalautecurrent method '+lstTRLogicalBlockGroupingIds.size());
            List<Velocity_Rule_Results__c> lstLogicalBlockSplVRR =[Select Id, Status__c, Grouping__c,Speciality_RuleID__r.RecordType.DeveloperName,Speciality_RuleID__r.Required_Type__c,Current__c,RequiredCount__c,
                                                                Speciality_RuleID__r.Tier__c,Grouping__r.RecordType.DeveloperName,Grouping__r.Target_Tier__c,Speciality_RuleID__r.Required__c,Speciality_RuleID__r.Specilaity__c
                                                                From Velocity_Rule_Results__c where Grouping__c in :lstTRLogicalBlockGroupingIds and Speciality_RuleID__r.RecordType.DeveloperName ='Specialty_Rule'];
            lbandsplcountmap = evaluatecurrentvalueonvrr(lstLogicalBlockSplVRR);
         }
        //1)    Call getGroupingsonLogicalBlock()
        if(setPanGroupingIds.size()>0){
            mapPanAndGrouping = Pan_VPP_UtilsObject.getGroupingsUnderPANLevel(setPanGroupingIds);
            if(mapPanAndGrouping.size() >0){
                for(Id groupingId : mapPanAndGrouping.KeySet()){
                    for(Account_Groupings__c objGrouping : mapPanAndGrouping.get(groupingId)){
                        setGroupingIds.add(objGrouping.Id);                     
                    }
                }
            }
        } 
         
        // 2)    Fetch all Velocity Rule Results
        if(setGroupingIds.size()>0 && setPanRuleIds.size() >0){
        
            mapVRRofGroupingUnderPan = new map<Id,Velocity_Rule_Results__c>([Select Id,Name,Grouping__c,Grouping__r.Logical_Block_Level_Grouping__c,Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c, 
                                                                            Required_Value_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Required__c,Speciality_RuleID__r.Evaluation_at__c,
                                                                            AccountID__c,Current__c,Revenue_Amount__c,Speciality_RuleID__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Required_Type__c,
                                                                            Speciality_RuleID__r.Display_Name__c,Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.Bucket__c,
                                                                            Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.RecordType.DeveloperName,
                                                                            Speciality_RuleID__r.Local_Requirment_Set__c, Status__c
                                                                            from Velocity_Rule_Results__c                                                                               
                                                                            where Grouping__c in :setGroupingIds                                                                              
                                                                            and Speciality_RuleID__c in : setPanRuleIds]);
        
            System.Debug('mapVRRofGroupingUnderPan--->' +mapVRRofGroupingUnderPan);
            System.Debug('mapVRRofGroupingUnderPan--->' +mapVRRofGroupingUnderPan.KeySet().size());
           
            //3)    Using above two maps get VRRs for groupings under each logical block and sum it up.
            if(mapVRRofGroupingUnderPan != null && mapVRRofGroupingUnderPan.size()>0){
                for(Velocity_Rule_Results__c ruleResult :mapVRRofGroupingUnderPan.values()){
                    System.Debug('ruleResult.Speciality_RuleID__r.Evaluation_at__c--->' +ruleResult.Speciality_RuleID__r.Evaluation_at__c);
                    System.Debug('ruleResult.Speciality_RuleID__r.Required_Type__c--->' +ruleResult.Speciality_RuleID__r.Required_Type__c);
                    System.Debug('ruleResult.Speciality_RuleID__r.Bucket__c--->' + ruleResult.Speciality_RuleID__r.Bucket__c);
                    System.Debug('ruleResult.Speciality_RuleID__r.Current__c--->' + ruleResult.Current__c);                 
                    if( (ruleResult.Speciality_RuleID__r.Evaluation_at__c=='PAN Theater Grouping Level' 
                        && ruleResult.Speciality_RuleID__r.RecordType.DeveloperName !='Field_Based_Rule_Type'
                        && (ruleResult.Speciality_RuleID__r.Required_Type__c =='Number/Count' || ruleResult.Speciality_RuleID__r.Required_Type__c =='USD')) 
                        || ( !PANVPPBucketContainer.containskey(ruleResult.Speciality_RuleID__r.Bucket__c) && ruleResult.Speciality_RuleID__r.Required_Type__c=='Text') ){
                        //if((ruleResult.Speciality_RuleID__r.Tier__c !=null && ruleResult.Speciality_RuleID__r.Bucket__c !=null && (ruleResult.Speciality_RuleID__r.Cluster__c !=null || ruleResult.Speciality_RuleID__r.Specialty_Rule_Type__c !=null) &&
                        //  ruleResult.Speciality_RuleID__r.Display_Name__c != null) || (ruleResult.Speciality_RuleID__r.Local_Requirment_Set__c !=null)){
                            
                            String strGroupingKey = ruleResult.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c;
                            String  strRuleKey =  ruleResult.Speciality_RuleID__c;  
                            String strKey = strGroupingKey + strRuleKey;    
                           
                            System.Debug('ruleResult.Grouping__c--->' +ruleResult.Grouping__c);
                            System.Debug('ruleResult.Speciality_RuleID__c--->' +ruleResult.Speciality_RuleID__c);                   
                            System.Debug('mapPanRuleAndRollupCount--->' +mapPanRuleAndRollupCount);
                                                                                    
                            Integer sumValue = mapPanRuleAndRollupCount.get(strKey);
                            if(sumvalue==null){
                                sumvalue=0; 
                            }
                            if(ruleResult.Current__c != '' && ruleResult.Current__c != null){
                                if(ruleResult.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                                    if(ruleResult.Current__c.contains('$') && ruleResult.Current__c.contains(',')){
                                        sumValue =    sumValue+ decimal.valueof((ruleResult.Current__c.replace('$','')).replace(',','')).intvalue();
                                    }else if(ruleResult.Current__c.contains('$') && !ruleResult.Current__c.contains(',')){                               
                                        sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c.replace('$','')).intValue();
                                    }else if(!ruleResult.Current__c.contains('$') && ruleResult.Current__c.contains(',')){
                                        sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c.replace(',','')).intValue();
                                    }else if(!ruleResult.Current__c.contains('$') && !ruleResult.Current__c.contains(',')){
                                        sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c).intValue();
                                    }
                                }else{
                                	sumValue =    sumValue+ decimal.valueof(ruleResult.Current__c).intValue();
                                }	
                            }    
                            
                            System.Debug('sumValue--->' +sumValue); 
                            System.Debug('mapPanRuleAndRollupCount--->' +mapPanRuleAndRollupCount);                     
                            mapPanRuleAndRollupCount.put(strKey, sumValue );                                                        
                        //} 
                    }
                    //else if((ruleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Field_Based_Rule_Type' || ( PANVPPBucketContainer.containskey(ruleResult.Speciality_RuleID__r.Bucket__c) && ruleResult.Speciality_RuleID__r.Required_Type__c=='Text')) ){
                    //  lstCloudBuilderVelocityRuleResults.add(ruleResult);   
                    //}                 
                    
                }
            }
            List<Velocity_Rule_Results__c> lsttepmVRR = new List<Velocity_Rule_Results__c>();
            for(Velocity_Rule_Results__c objVRR: lstVelocityRuleResulst){
                System.Debug('objVRR--->' +objVRR);
                if(objVRR.Grouping__c != null && objVRR.Speciality_RuleID__c != null){
                    
                    String strGroupingKey = objVRR.Grouping__c;
                    String  strRuleKey =  objVRR.Speciality_RuleID__c;  
                    String strKey = strGroupingKey + strRuleKey;
                    
                    System.Debug('objVRR--->1' +objVRR);
                    System.Debug('objVRR.Grouping__c--->1' +objVRR.Grouping__c);
                    System.Debug('objVRR.Speciality_RuleID__c--->1' +objVRR.Speciality_RuleID__c);                  
                    System.Debug('mapPanRuleAndRollupCount--->1' +mapPanRuleAndRollupCount.size());
                    System.Debug('mapPanRuleAndRollupCount.containsKey(strKey)--->1' +mapPanRuleAndRollupCount.containsKey(strKey));
                    
                    if(mapPanRuleAndRollupCount.containsKey(strKey)){
                        if(objVRR.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                            objVRR.Revenue_Amount__c = string.valueof(mapPanRuleAndRollupCount.get(strKey)); 
                            List<String> args = new String[]{'0','number','$###,###,###.00'};                      
                            Decimal decRevenueAmmount = Decimal.valueOf(objVRR.Revenue_Amount__c);                 
                            String strrevenue = String.format(decRevenueAmmount.format(), args);  
                            objVRR.Current__c = '$' + strrevenue;
                        }else{
                        	//212889 assuming that all the specialty rules are evaluated in previous batches and getting the current__c value
                        	// for tier rules from the  map lbandsplcountmap
                        	if(DataValueMap.get('PRM_VPP_Velocity_Program_Bucket')!=null && 
                        	objVRR.Speciality_RuleID__r.Bucket__c == DataValueMap.get('PRM_VPP_Velocity_Program_Bucket').DataValue__c){
                        		objVRR.Current__c = string.valueof(lbandsplcountmap.get(strGroupingKey));
                        	}else{
                        		objVRR.Current__c = string.valueof(mapPanRuleAndRollupCount.get(strKey));
                        	}
                        }
                        lsttepmVRR.add(objVRR);
                    }
                }
            } 
            
            //5)    Update Velocity Rule Results for logical block
            System.Debug('lsttepmVRR--->' +lsttepmVRR);
            System.Debug('lsttepmVRR--->' +lsttepmVRR.size());
            update lsttepmVRR;
            
            System.Debug('lstCloudBuilderVelocityRuleResults--->' +lstCloudBuilderVelocityRuleResults);
            System.Debug('lstCloudBuilderVelocityRuleResults--->' +lstCloudBuilderVelocityRuleResults.size());
            
            if(lstCloudBuilderVelocityRuleResults.size()>0){
                evaluateCloudBuilderPANLevelRules(lstCloudBuilderVelocityRuleResults);
            }
        
            List<Velocity_Rule_Results__c> lstPanVRR =[Select Id, Status__c, Grouping__c, Speciality_RuleID__r.RecordType.DeveloperName,Speciality_RuleID__r.Required__c,
                                                       Speciality_RuleID__r.Tier__c,Grouping__r.RecordType.DeveloperName,Grouping__r.Target_Tier__c,Speciality_RuleID__r.Required_Type__c
                                                        From Velocity_Rule_Results__c where id in :setPanVRRIds and Speciality_RuleID__r.RecordType.DeveloperName !='Field_Based_Rule_Type' ];
            if(lstPanVRR != null && lstPanVRR.size() >0){
                for(Velocity_Rule_Results__c ruleResult : lstPanVRR){
                    if(ruleResult.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule' && ruleResult.Grouping__r.RecordType.DeveloperName == 'Partner_Grouping_PAN_Theater'
                       && ruleResult.Grouping__r.Target_Tier__c == ruleResult.Speciality_RuleID__r.Tier__c) {
                        if(ruleResult.Status__c == 'Not Achieved' && (!((ruleResult.Speciality_RuleID__r.Required_Type__c =='Text') && (ruleResult.Speciality_RuleID__r.Required__c =='n/a' || ruleResult.Speciality_RuleID__r.Required__c =='Optional') )) ){
                            if(!mapPanAndComplianceStatus.containsKey(ruleResult.Grouping__c)){
                                mapPanAndComplianceStatus.put(ruleResult.Grouping__c, ruleResult.Status__c);
                            }
                        }
                    }
                }
            }
            
            Map<Id,Account_Groupings__c> mapLogicalBlock = new Map<Id,Account_Groupings__c>([Select Id,Compliance_Period_Requirments_Met__c,Local_Requirment_Set__c from Account_Groupings__c where Id in :setPanGroupingIds and Active__c =true]);
            for(Account_Groupings__c objPanGrouping : mapLogicalBlock.values() ){                       
                if(!mapPanAndComplianceStatus.containsKey(objPanGrouping.Id)){
                    mapLogicalBlock.get(objPanGrouping.Id).Compliance_Period_Requirments_Met__c='Yes';
                }
                if(mapPanAndComplianceStatus.containsKey(objPanGrouping.Id)){
                    mapLogicalBlock.get(objPanGrouping.Id).Compliance_Period_Requirments_Met__c='No';
                }
            }
            
            //6) Check if all rules for each logical block has been satiesfied - status field should be achieved
            //if yes set "Compliance Period Requirements Met"  = true else set "Compliance Period Requirements Met"  = false
            Database.SaveResult[] results = database.update(mapLogicalBlock.values(),false);
            
             /* HANDLING EXCEPTION LOG*/
		        for (Database.Saveresult sr : results) {
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
    }
            
}