/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE            DEVELOPER                WR       DESCRIPTION                               
 |  ====            =========                ==       =========== 
 | 16-July-2012   Prasad Kothawade                    To create Velocity rule results for PAN Theater model.
   15/11/2012     vivek kodi               197607     To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.
 |                                                                                              
 +===========================================================================================================================*/
public class PRM_PAN_VPP_VelocityRuleResults { 

    
     
    /* @createLogicalBlockVelocityRuleResults <PRM_PAN_VPP_VelocityRuleResults(): This method gets called in jobs to create velocity rules results for given logical blocks. >                                                  
       @param - List<Account_Groupings__c> LogicalBlocks  - List of Logical Blocks for which have to create Velocity Rule results.
       @return <void> 
       @throws exception - <No Exception>
    */
    public List<Velocity_Rule_Results__c> createLogicalBlockVelocityRuleResults(List<Account_Groupings__c> LogicalBlocks){
        PRM_PAN_VPP_VelocityRuleResultsUtils PANVPPVRRUtils = new PRM_PAN_VPP_VelocityRuleResultsUtils();
        Map<Id,List<Account_Groupings__c>> mapLogicalBlockAndGrouping = new Map<Id,List<Account_Groupings__c>>();
        Map<Id,List<Velocity_Rules__c>> mapLogicalBlockAndLevelRules = new Map<Id,List<Velocity_Rules__c>> ();
        list<Velocity_Rule_Results__c> lstVelocityRuleResults = new list<Velocity_Rule_Results__c>();
        list<Velocity_Rule_Results__c> lstVelocityRuleResultsToEvaluate = new list<Velocity_Rule_Results__c>();
        list<Id> lstLogicalBlockIds = new list<Id>();
       
        /**/
        if(LogicalBlocks.size()>0){ 
            for(Account_Groupings__c grouping: LogicalBlocks){  
                lstLogicalBlockIds.add(grouping.Id);
            }   
        }
        //1)    Call getGroupingsonLogicalBlock()
        if(lstLogicalBlockIds.size()>0){
            mapLogicalBlockAndGrouping = PANVPPVRRUtils.getGroupingsUnderLogicalBlock(lstLogicalBlockIds);
        } 
        
       // 2)    Call  getLogicalBlockLevelRules() 
       if(LogicalBlocks.size()>0){
            mapLogicalBlockAndLevelRules = PANVPPVRRUtils.getLogicalBlockLevelRules(LogicalBlocks);
       }
              
       // 3)    Create Velocity Rule results for all groupings under Logical Block
       if(!mapLogicalBlockAndLevelRules.isEmpty()){
            for(Id logicalBlockId: mapLogicalBlockAndLevelRules.keyset()){
                if(mapLogicalBlockAndLevelRules.get(logicalBlockId).size()>0){
                    for(Velocity_Rules__c velocityRule: mapLogicalBlockAndLevelRules.get(logicalBlockId)){
                        /* */
                        if(mapLogicalBlockAndGrouping.containsKey(logicalBlockId)){
                            for(Account_Groupings__c objAccGroup : mapLogicalBlockAndGrouping.get(logicalBlockId)){
                                Velocity_Rule_Results__c velocityRuleResult = new Velocity_Rule_Results__c();
                                velocityRuleResult.Grouping__c = objAccGroup.Id;
                                velocityRuleResult.AccountID__c = objAccGroup.Profiled_Account__c;
                                velocityRuleResult.Speciality_RuleID__c = velocityRule.Id;
                                lstVelocityRuleResults.add(velocityRuleResult);
                            }
                        }
                                                
                        Velocity_Rule_Results__c velocityRuleResult = new Velocity_Rule_Results__c();
                        velocityRuleResult.Grouping__c = logicalBlockId;
                        velocityRuleResult.Speciality_RuleID__c = velocityRule.Id;
                        lstVelocityRuleResults.add(velocityRuleResult);                     
                    }
                }
            }
       }
       
       // 4) insert Velocity Rule Results
       if(lstVelocityRuleResults.size()>0){
            insert lstVelocityRuleResults;
       }
        lstVelocityRuleResultsToEvaluate = [Select Revenue_Amount__c,Status__c, Required_value_Type__c,Speciality_RuleID__c, Rule_theater__c, RequiredCount__c,
                                            Speciality_RuleID__r.RecordType.Name, Speciality_RuleID__r.RecordType.DeveloperName,Name, Grouping__c, Current__c, Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,Speciality_RuleID__r.Value__c,
                                            Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.Any_Value_Acceptable__c,
                                            Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c,Speciality_RuleID__r.Evaluation_at__c,
                                            Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,Grouping__r.RecordType.DeveloperName,Speciality_RuleID__r.Required__c,
                                            Speciality_RuleID__r.Local_Requirment_Set__c,Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,
                                            Speciality_RuleID__r.Theater__c,Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,
                                            AccountID__c From Velocity_Rule_Results__c v where id in :lstVelocityRuleResults];
        
        return lstVelocityRuleResultsToEvaluate;
    }
    public List<Velocity_Rule_Results__c> createLogicalBlockVelocityRuleResultswitherrors(List<Account_Groupings__c> LogicalBlocks,string Batchid, List<EMCException> emailerrors){
        PRM_PAN_VPP_VelocityRuleResultsUtils PANVPPVRRUtils = new PRM_PAN_VPP_VelocityRuleResultsUtils();
        Map<Id,List<Account_Groupings__c>> mapLogicalBlockAndGrouping = new Map<Id,List<Account_Groupings__c>>();
        Map<Id,List<Velocity_Rules__c>> mapLogicalBlockAndLevelRules = new Map<Id,List<Velocity_Rules__c>> ();
        list<Velocity_Rule_Results__c> lstVelocityRuleResults = new list<Velocity_Rule_Results__c>();
        list<Velocity_Rule_Results__c> lstVelocityRuleResultsToEvaluate = new list<Velocity_Rule_Results__c>();
        list<Id> lstLogicalBlockIds = new list<Id>();
        List <EMCException> errors = new List <EMCException>();
        /**/
        if(LogicalBlocks.size()>0){ 
            for(Account_Groupings__c grouping: LogicalBlocks){  
                lstLogicalBlockIds.add(grouping.Id);
            }   
        }
        //1)    Call getGroupingsonLogicalBlock()
        if(lstLogicalBlockIds.size()>0){
            mapLogicalBlockAndGrouping = PANVPPVRRUtils.getGroupingsUnderLogicalBlock(lstLogicalBlockIds);
        } 
        
       // 2)    Call  getLogicalBlockLevelRules() 
       if(LogicalBlocks.size()>0){
            mapLogicalBlockAndLevelRules = PANVPPVRRUtils.getLogicalBlockLevelRules(LogicalBlocks);
       }
              
       // 3)    Create Velocity Rule results for all groupings under Logical Block
       if(!mapLogicalBlockAndLevelRules.isEmpty()){
            for(Id logicalBlockId: mapLogicalBlockAndLevelRules.keyset()){
                if(mapLogicalBlockAndLevelRules.get(logicalBlockId).size()>0){
                    for(Velocity_Rules__c velocityRule: mapLogicalBlockAndLevelRules.get(logicalBlockId)){
                        /* */
                        if(mapLogicalBlockAndGrouping.containsKey(logicalBlockId)){
                            for(Account_Groupings__c objAccGroup : mapLogicalBlockAndGrouping.get(logicalBlockId)){
                                Velocity_Rule_Results__c velocityRuleResult = new Velocity_Rule_Results__c();
                                velocityRuleResult.Grouping__c = objAccGroup.Id;
                                velocityRuleResult.AccountID__c = objAccGroup.Profiled_Account__c;
                                velocityRuleResult.Speciality_RuleID__c = velocityRule.Id;
                                lstVelocityRuleResults.add(velocityRuleResult);
                            }
                        }
                                                
                        Velocity_Rule_Results__c velocityRuleResult = new Velocity_Rule_Results__c();
                        velocityRuleResult.Grouping__c = logicalBlockId;
                        velocityRuleResult.Speciality_RuleID__c = velocityRule.Id;
                        lstVelocityRuleResults.add(velocityRuleResult);                     
                    }
                }
            }
       }
       
       // 4) insert Velocity Rule Results
       if(lstVelocityRuleResults.size()>0){
            Database.SaveResult[] results = database.insert(lstVelocityRuleResults,false);
            
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
        lstVelocityRuleResultsToEvaluate = [Select Revenue_Amount__c,Status__c, Required_value_Type__c,Speciality_RuleID__c, Rule_theater__c, RequiredCount__c,
                                            Speciality_RuleID__r.RecordType.Name, Speciality_RuleID__r.RecordType.DeveloperName,Name, Grouping__c, Current__c, Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,Speciality_RuleID__r.Value__c,
                                            Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.Any_Value_Acceptable__c,
                                            Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c,Speciality_RuleID__r.Evaluation_at__c,
                                            Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,Grouping__r.RecordType.DeveloperName,Speciality_RuleID__r.Required__c,
                                            Speciality_RuleID__r.Local_Requirment_Set__c,Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,
                                            Speciality_RuleID__r.Theater__c,Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,
                                            AccountID__c From Velocity_Rule_Results__c v where id in :lstVelocityRuleResults];
        
        return lstVelocityRuleResultsToEvaluate;
    }
    /* @createPANLevelVelocityRuleResults <PRM_PAN_VPP_VelocityRuleResults(): This method gets called in jobs to create velocity rules results for given PAN Theaters. >                                                    
       @param - List<Account_Groupings__c> LogicalBlocks  - List of PAN Theaters for which have to create Velocity Rule results.
       @return <void> 
       @throws exception - <No Exception>
    */
    public List<Velocity_Rule_Results__c> createPANLevelVelocityRuleResults(List<Account_Groupings__c> PANTheaters){
        PRM_PAN_VPP_VelocityRuleResultsUtils PANVPPVRRUtils = new PRM_PAN_VPP_VelocityRuleResultsUtils();
        Map<Id,List<Account_Groupings__c>> mapPanAndGrouping = new Map<Id,List<Account_Groupings__c>>();
        Map<Id,List<Velocity_Rules__c>> mapPANAndLevelRules = new Map<Id,List<Velocity_Rules__c>> ();
        list<Velocity_Rule_Results__c> lstVelocityRuleResults = new list<Velocity_Rule_Results__c>();
        list<Velocity_Rule_Results__c> lstVelocityRuleResultsToEvaluate = new list<Velocity_Rule_Results__c>();
        list<Id> lstPanGroupIds = new list<Id>();
        //1)Call getGroupingsUnderPANLevel ()
        if(PANTheaters.size()>0){
            for(Account_Groupings__c grouping: PANTheaters){
                lstPanGroupIds.add(grouping.Id);
            }
        }
        
        if(lstPanGroupIds.size()>0){
            mapPanAndGrouping = PANVPPVRRUtils.getGroupingsUnderPANLevel(lstPanGroupIds);
        }
        
        //2)Call getPANLevelRules()
        if(PANTheaters.size()>0){
            mapPANAndLevelRules = PANVPPVRRUtils.getPANLevelRules(PANTheaters);
        }  
    
        //3)Create Velocity Rule results for all groupings under PAN Theater
         if(!mapPANAndLevelRules.isEmpty()){  
            for(Id PANId: mapPANAndLevelRules.keyset()){
                if(mapPANAndLevelRules.get(PANId).size()>0){
                    for(Velocity_Rules__c velocityRule: mapPANAndLevelRules.get(PANId)){ 
                        /* */
                        if(mapPanAndGrouping.containsKey(PANId)){
                            for(Account_Groupings__c objAccGroup : mapPanAndGrouping.get(PANId)){
                                Velocity_Rule_Results__c velocityRuleResult = new Velocity_Rule_Results__c();
                                velocityRuleResult.Grouping__c = objAccGroup.Id;
                                velocityRuleResult.AccountID__c = objAccGroup.Profiled_Account__c;
                                velocityRuleResult.Speciality_RuleID__c = velocityRule.Id;
                                lstVelocityRuleResults.add(velocityRuleResult);
                            }
                        }
                        
                        Velocity_Rule_Results__c velocityRuleResult = new Velocity_Rule_Results__c();
                        velocityRuleResult.Grouping__c = PANId;
                        velocityRuleResult.Speciality_RuleID__c = velocityRule.Id;
                        lstVelocityRuleResults.add(velocityRuleResult);
                    }
                }
            }
       }
    
        //4)insert Velocity Rule Results
        if(lstVelocityRuleResults.size()>0){
            insert lstVelocityRuleResults;
        }
        
        lstVelocityRuleResultsToEvaluate = [Select Revenue_Amount__c,Status__c, Required_value_Type__c,Speciality_RuleID__c, Rule_theater__c, RequiredCount__c,
                                            Speciality_RuleID__r.RecordType.Name, Speciality_RuleID__r.RecordType.DeveloperName,Name, Grouping__c, Current__c, Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,Speciality_RuleID__r.Value__c,
                                            Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.Any_Value_Acceptable__c,
                                            Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c,Speciality_RuleID__r.Evaluation_at__c,
                                            Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,Grouping__r.RecordType.DeveloperName,Speciality_RuleID__r.Required__c,
                                            Speciality_RuleID__r.Local_Requirment_Set__c,Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,
                                            Speciality_RuleID__r.Theater__c,Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,
                                            AccountID__c From Velocity_Rule_Results__c v where id in :lstVelocityRuleResults];
        return lstVelocityRuleResultsToEvaluate;
    }
     public List<Velocity_Rule_Results__c> createPANLevelVelocityRuleResultswitherrors(List<Account_Groupings__c> PANTheaters,string Batchid, List<EMCException> emailerrors){
        PRM_PAN_VPP_VelocityRuleResultsUtils PANVPPVRRUtils = new PRM_PAN_VPP_VelocityRuleResultsUtils();
        Map<Id,List<Account_Groupings__c>> mapPanAndGrouping = new Map<Id,List<Account_Groupings__c>>();
        Map<Id,List<Velocity_Rules__c>> mapPANAndLevelRules = new Map<Id,List<Velocity_Rules__c>> ();
        list<Velocity_Rule_Results__c> lstVelocityRuleResults = new list<Velocity_Rule_Results__c>();
        list<Velocity_Rule_Results__c> lstVelocityRuleResultsToEvaluate = new list<Velocity_Rule_Results__c>();
        list<Id> lstPanGroupIds = new list<Id>();
        List <EMCException> errors = new List <EMCException>();
        //1)Call getGroupingsUnderPANLevel ()
        if(PANTheaters.size()>0){
            for(Account_Groupings__c grouping: PANTheaters){
                lstPanGroupIds.add(grouping.Id);
            }
        }
        
        if(lstPanGroupIds.size()>0){
            mapPanAndGrouping = PANVPPVRRUtils.getGroupingsUnderPANLevel(lstPanGroupIds);
        }
        
        //2)Call getPANLevelRules()
        if(PANTheaters.size()>0){
            mapPANAndLevelRules = PANVPPVRRUtils.getPANLevelRules(PANTheaters);
        }  
    
        //3)Create Velocity Rule results for all groupings under PAN Theater
         if(!mapPANAndLevelRules.isEmpty()){  
            for(Id PANId: mapPANAndLevelRules.keyset()){
                if(mapPANAndLevelRules.get(PANId).size()>0){
                    for(Velocity_Rules__c velocityRule: mapPANAndLevelRules.get(PANId)){ 
                        /* */
                        if(mapPanAndGrouping.containsKey(PANId)){
                            for(Account_Groupings__c objAccGroup : mapPanAndGrouping.get(PANId)){
                                Velocity_Rule_Results__c velocityRuleResult = new Velocity_Rule_Results__c();
                                velocityRuleResult.Grouping__c = objAccGroup.Id;
                                velocityRuleResult.AccountID__c = objAccGroup.Profiled_Account__c;
                                velocityRuleResult.Speciality_RuleID__c = velocityRule.Id;
                                lstVelocityRuleResults.add(velocityRuleResult);
                            }
                        }
                        
                        Velocity_Rule_Results__c velocityRuleResult = new Velocity_Rule_Results__c();
                        velocityRuleResult.Grouping__c = PANId;
                        velocityRuleResult.Speciality_RuleID__c = velocityRule.Id;
                        lstVelocityRuleResults.add(velocityRuleResult);
                    }
                }
            }
       }
    
        //4)insert Velocity Rule Results
        if(lstVelocityRuleResults.size()>0){
           Database.SaveResult[] results =database.insert(lstVelocityRuleResults,false);            
            
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
        
        lstVelocityRuleResultsToEvaluate = [Select Revenue_Amount__c,Status__c, Required_value_Type__c,Speciality_RuleID__c, Rule_theater__c, RequiredCount__c,
                                            Speciality_RuleID__r.RecordType.Name, Speciality_RuleID__r.RecordType.DeveloperName,Name, Grouping__c, Current__c, Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,Speciality_RuleID__r.Value__c,
                                            Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.Any_Value_Acceptable__c,
                                            Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c,Speciality_RuleID__r.Evaluation_at__c,
                                            Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,Grouping__r.RecordType.DeveloperName,Speciality_RuleID__r.Required__c,
                                            Speciality_RuleID__r.Local_Requirment_Set__c,Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,
                                            Speciality_RuleID__r.Theater__c,Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,
                                            AccountID__c From Velocity_Rule_Results__c v where id in :lstVelocityRuleResults];
        return lstVelocityRuleResultsToEvaluate;
    }
}