/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE            DEVELOPER                WR       DESCRIPTION                               
 |  ====            =========                ==       =========== 
 |  16-July-2012    Prasad Kothawade                  To create Velocity rule results for PAN Theater model.
 |                                                                                              
 +===========================================================================================================================*/


public class PRM_PAN_VPP_VelocityRuleResultsUtils { 
    
      /* @getGroupingsUnderLogicalBlock <PRM_PAN_VPP_VelocityRuleResultsUtils(): This method gets called in jobs to fetch groupings under logical block. >                                                  
       @param - List<Id> LogicalBlockIds  - List of Logical Block ids for which have to get country level groupings under it.
       @return Map<Id,List<Account_Groupings__c>> - Returns a Map of Logical block ids and their respective country level groupings under it.
       @throws exception - <No Exception>
    */
    public Map<Id,List<Account_Groupings__c>> getGroupingsUnderLogicalBlock(List<Id> LogicalBlockIds ){
        Map<Id,List<Account_Groupings__c>> LogicalBlockMap = new Map<Id,List<Account_Groupings__c>> ();
        list<Account_Groupings__c> lstGroupings = new list<Account_Groupings__c>();
        // fetch all groupings under given ids
        if(LogicalBlockIds.size()>0){
            lstGroupings = [Select Id,Logical_Block_Level_Grouping__c,Profiled_Account__c,Active__c from Account_Groupings__c where Logical_Block_Level_Grouping__c in :LogicalBlockIds and Active__c = true];
        }
        // Create Map from the query result set - Put related groupings under list in map
        if(lstGroupings.size()>0){
            for(Account_Groupings__c grouping: lstGroupings){
                if(LogicalBlockMap.containsKey(grouping.Logical_Block_Level_Grouping__c)){ 
                    LogicalBlockMap.get(grouping.Logical_Block_Level_Grouping__c).add(grouping);
                }else{
                    LogicalBlockMap.put(grouping.Logical_Block_Level_Grouping__c,new List<Account_Groupings__c>());
                    LogicalBlockMap.get(grouping.Logical_Block_Level_Grouping__c).add(grouping);
                }
            }
        }
        return LogicalBlockMap;
    }
    
    /* @getLogicalBlockLevelRules <PRM_PAN_VPP_VelocityRuleResultsUtils(): This method gets called in jobs to fetch rules applicable for given logical blocks. >                                                    
       @param - List<Account_Groupings__c> LogicalBlocks  - List of Logical Block ids for which have to get rules applicable for it.
       @return Map<Id,List<Velocity_Rules__c>> - Returns a Map of Logical block ids and their respective applicable rules.
       @throws exception - <No Exception>
    */
    public Map<Id,List<Velocity_Rules__c>> getLogicalBlockLevelRules(List<Account_Groupings__c> LogicalBlocks){
        Map<Id,List<Velocity_Rules__c>> LogicalBlockLevelRulesMap = new Map<Id,List<Velocity_Rules__c>> ();
       // set<string> setTier = new set<string>();
        set<string> setCluster = new set<string>();
        set<string> setLocalRequirement = new set<string>();
        set<string> setSpecialityType = new set<string>();
        list<Velocity_Rules__c> lstVelocityRules = new list<Velocity_Rules__c>();
        // Loop over LogicalBlocks create list of Tier, cluster and local requirment set. 
        if(LogicalBlocks.size()>0){
            for(Account_Groupings__c grouping: LogicalBlocks){
                //setTier.add(grouping.Target_Tier__c);
                if(grouping.cluster__c !=null){
                    setCluster.add(grouping.Cluster__c);
                }
                if(grouping.Local_Requirment_Set__c!=null){
                    setLocalRequirement.add(grouping.Local_Requirment_Set__c);
                }
                if(grouping.Speciality_Type__c!=null){
                    setSpecialityType.add(grouping.Speciality_Type__c); 
                }
            }
        }  
        // fetch all logical block level rules for above Tier, cluster, speciality Type,local requirment set and marked as evaluate at country level.
        if(setCluster.size()>0 || setLocalRequirement.size()>0 || setSpecialityType.size()>0){
            lstVelocityRules = [Select Id,Display_Name__c,Evaluation_at__c,Local_Requirment_Set__c,Field_Name__c,Cluster__c,RecordType.DeveloperName,AND_OR__c,Tier__c,Required__c,Bucket__c,
                                Specialty_Rule_Type__c,Required_Type__c,Sort__c,Is_Total_Revenue__c from Velocity_Rules__c
                                where (Cluster__c in: setCluster  or Specialty_Rule_Type__c in: setSpecialityType OR Local_Requirment_Set__c in: setLocalRequirement) 
                                and Evaluation_at__c = 'Logical Block Grouping Level'];
                                //and (RecordType.DeveloperName = 'Speciality_Rule_PAN_Theater_Logical_Block_Level' or RecordType.DeveloperName = 'Tier_Rule_PAN_Theater_Logical_Block_Level')];
        }
        System.debug('lstVelocityRules-->' +lstVelocityRules);
        // Create Map from the query result for each Logical block with it's applicable rules as per cluster, tier and local requirment set
        if(LogicalBlocks.size()>0 && lstVelocityRules.size()>0){
            for(Account_Groupings__c grouping: LogicalBlocks){
                list<Velocity_Rules__c> lstTempVelocityRule = new list<Velocity_Rules__c>();
                for(Velocity_Rules__c velocityRule: lstVelocityRules){
                    if(grouping.Cluster__c!=null && velocityRule.Cluster__c!=null && (grouping.Cluster__c == velocityRule.Cluster__c) && velocityRule.Local_Requirment_Set__c == null){
                        lstTempVelocityRule.add(velocityRule);
                    } 
                    else if(grouping.Local_Requirment_Set__c!=null && velocityRule.Local_Requirment_Set__c!=null &&(grouping.Local_Requirment_Set__c == velocityRule.Local_Requirment_Set__c)){
                        lstTempVelocityRule.add(velocityRule);
                    }
                    else if(grouping.Speciality_Type__c!=null && velocityRule.Specialty_Rule_Type__c!=null &&(grouping.Speciality_Type__c == velocityRule.Specialty_Rule_Type__c) && velocityRule.Local_Requirment_Set__c == null){
                        lstTempVelocityRule.add(velocityRule);
                    }  
                                      
                }
                LogicalBlockLevelRulesMap.put(grouping.Id,lstTempVelocityRule);
            }
        }
        
        return LogicalBlockLevelRulesMap;
    }
    
    /* @getGroupingsUnderPANLevel <PRM_PAN_VPP_VelocityRuleResultsUtils(): This method gets called in jobs to fetch groupings under PAN Theater level through logical blocks. >                                                 
       @param - List<Id> PANTheaterIds  - List of Logical Block ids for which have to get country level groupings under it.
       @return Map<Id,List<Account_Groupings__c>> - Returns a Map of Logical block ids and their respective country level groupings under it.
       @throws exception - <No Exception>
    */
    public Map<Id,List<Account_Groupings__c>>getGroupingsUnderPANLevel(List<Id> PANTheaterIds){
        Map<Id,List<Account_Groupings__c>> PANTheaterMap = new Map<Id,List<Account_Groupings__c>> ();
        set<Id> setLogicalBlockId = new set<Id>();
        list<Account_Groupings__c> lstGroupings = new list<Account_Groupings__c>();
        // fetch all logical block and groupings under logical blocks for given PAN Theater Ids
        if(PANTheaterIds.size()>0){
            lstGroupings = [Select Id,Logical_Block_Level_Grouping__c,Profiled_Account__c,Pan_Theater_Level_Grouping__c,Active__c from Account_Groupings__c where Pan_Theater_Level_Grouping__c in :PANTheaterIds and Active__c = true];
        }
        if(lstGroupings.size()>0){
            for(Account_Groupings__c grouping: lstGroupings){
                setLogicalBlockId.add(grouping.Id);
            }
        }
        if(setLogicalBlockId.size()>0){
            lstGroupings = new list<Account_Groupings__c>();
            lstGroupings = [Select Id,Logical_Block_Level_Grouping__c,Profiled_Account__c,Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c,Active__c from Account_Groupings__c where Logical_Block_Level_Grouping__c in :setLogicalBlockId and Active__c = true];
        }
        // Create Map from the query result set - Put related groupings under list in map
        if(lstGroupings.size()>0){
            for(Account_Groupings__c grouping: lstGroupings){
                if(PANTheaterMap.containsKey(grouping.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c)){
                    PANTheaterMap.get(grouping.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c).add(grouping);
                }else{
                    PANTheaterMap.put(grouping.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c,new  List<Account_Groupings__c>());
                    PANTheaterMap.get(grouping.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c).add(grouping);
                }
            }
        }
        return PANTheaterMap;
    }
    
    /* @getLogicalBlockLevelRules <PRM_PAN_VPP_VelocityRuleResultsUtils(): This method gets called in jobs to fetch rules applicable for given logical blocks. >                                                    
       @param - List<Account_Groupings__c> LogicalBlocks  - List of Logical Block ids for which have to get rules applicable for it.
       @return Map<Id,List<Velocity_Rules__c>> - Returns a Map of Logical block ids and their respective applicable rules.
       @throws exception - <No Exception>
    */
    public Map<Id,List<Velocity_Rules__c>> getPANLevelRules(List<Account_Groupings__c> PANTheaters){
        Map<Id,List<Velocity_Rules__c>> PANTheaterLevelRulesMap = new Map<Id,List<Velocity_Rules__c>> ();
        //set<string> setTier = new set<string>();
        set<string> setCluster = new set<string>();
        set<string> setSpecialityType = new set<string>();
        list<Velocity_Rules__c> lstVelocityRules = new list<Velocity_Rules__c>();
        // Loop over PANTheaters create list of Tier, cluster. 
         if(PANTheaters.size()>0){
            for(Account_Groupings__c grouping: PANTheaters){
                //setTier.add(grouping.Target_Tier__c);
                if(grouping.Cluster__c != null){
                    setCluster.add(grouping.Cluster__c);
                }
                if(grouping.Speciality_Type__c != null){
                    setSpecialityType.add(grouping.Speciality_Type__c);
                }
            }
         } 
        // fetch all PANTheaters level rules for above Tier, cluster, speciality Type and marked as evaluate at PAN Theater level.
         if(setSpecialityType.size()>0 || setCluster.size()>0){
            lstVelocityRules = [Select Id,Display_Name__c,Evaluation_at__c,Bucket__c,Field_Name__c,Specialty_Rule_Type__c,Cluster__c,AND_OR__c,Tier__c,Required__c,Required_Type__c,Sort__c,Is_Total_Revenue__c from Velocity_Rules__c
                                where (Cluster__c in: setCluster or Specialty_Rule_Type__c in: setSpecialityType or RecordType.DeveloperName ='Field_Based_Rule_Type') and Evaluation_at__c = 'PAN Theater Grouping Level'];
                                //and (RecordType.DeveloperName = 'Speciality_Rule_PAN_Theater_Logical_Block_Level' or RecordType.DeveloperName = 'Tier_Rule_PAN_Theater_Logical_Block_Level')];
         }
        
        // Create Map from the query result for each PAN Theater with it's applicable rules as per cluster, speciality Type, tier.
         if(PANTheaters.size()>0 && lstVelocityRules.size()>0){
            for(Account_Groupings__c grouping: PANTheaters){
                list<Velocity_Rules__c> lstTempVelocityRevenue = new list<Velocity_Rules__c>();
                for(Velocity_Rules__c velocityRevenue: lstVelocityRules){
                    if(grouping.Cluster__c == velocityRevenue.Cluster__c || 
                       grouping.Speciality_Type__c == velocityRevenue.Specialty_Rule_Type__c){
                            lstTempVelocityRevenue.add(velocityRevenue);
                    }
                }
                PANTheaterLevelRulesMap.put(grouping.Id,lstTempVelocityRevenue);
            }
        }
        System.Debug('PANTheaterLevelRulesMap--->' +PANTheaterLevelRulesMap);
        return PANTheaterLevelRulesMap;
    }
    
     /* @getLogicalBlockUnderPan <PRM_PAN_VPP_VelocityRuleResultsUtils(): This method gets called in jobs to fetch logical block under PAN. >                                                  
       @param - List<Id> LogicalBlockIds  - List of PAN ids for which have to get Logical Block under it.
       @return Map<Id,List<Account_Groupings__c>> - Returns a Map of PAN ids and their respective Logical block under it.
       @throws exception - <No Exception>
    */
    public Map<Id,List<Account_Groupings__c>> getLogicalBlockUnderPAN(List<Id> PANTheaterIds){
        Map<Id,List<Account_Groupings__c>> mapPANAndLogicalBlock = new Map<Id,List<Account_Groupings__c>> ();
        list<Account_Groupings__c> lstGroupings = new list<Account_Groupings__c>();
        // fetch all groupings under given ids
        if(PANTheaterIds.size()>0){
            lstGroupings = [Select Id,Target_Tier__c,Cluster__c,Local_Requirment_Set__c,Speciality_Type__c,Logical_Block_Level_Grouping__c,Pan_Theater_Level_Grouping__c,
            Active__c, Consolidate_Specialty__c, Advanced_Consolidate_Specialty__c, Backup_and_Recovery_Specialty__c, Governance_and_Archive_Specialty__c, 
            Cloud_Builder_Specialty__c, Cloud_Provider_Practice__c,Isilon_Track_Specialty__c,RecordType.DeveloperName from Account_Groupings__c 
            where Pan_Theater_Level_Grouping__c in :PANTheaterIds and Active__c = true];
        }
        // Create Map from the query result set - Put related groupings under list in map
        if(lstGroupings.size()>0){
            for(Account_Groupings__c grouping: lstGroupings){
                if(mapPANAndLogicalBlock.containsKey(grouping.Pan_Theater_Level_Grouping__c)){
                    mapPANAndLogicalBlock.get(grouping.Pan_Theater_Level_Grouping__c).add(grouping);
                }else{
                    mapPANAndLogicalBlock.put(grouping.Pan_Theater_Level_Grouping__c,new List<Account_Groupings__c>());
                    mapPANAndLogicalBlock.get(grouping.Pan_Theater_Level_Grouping__c).add(grouping);
                }
            }
        }
        return mapPANAndLogicalBlock;
    }
    /* @getProfiledAccountUnderLogicalBlock<PRM_PAN_VPP_VelocityRuleResultsUtils(): This method gets called in jobs to fetch Profiled Accounts under 
                                            Logical Block Level Grouping.>                                                  
       @param - List<Id> LogicalBlockIds  - List of Logical Block ids for which we have to get Profiled Accounts under it.
       @return Map<Id,List<Account>> - Returns a Map of Logical Block Ids and their respective Profiled Account under it.
       @throws exception - <No Exception>
   */
    public Map<Id,List<Account>> getProfiledAccountUnderLogicalBlock(List<Id> lstLogicalBlockIds){
        Map<Id,List<Account>> mapLogicalBlockWithProfiledAccount = new Map<Id,List<Account>> ();
        list<Account> lstAccount = new list<Account>();
        // fetch all groupings under given ids
        if(lstLogicalBlockIds.size()>0){
           string query1 = 'Select Id,Name,Grouping__c,Theater1__c,'
                          +'Velocity_Services_Implement__c,Solution_Center_Implemented__c,Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c,'
                          +'Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c,Velocity_Compliance_Status__c,Deployed_Velocity_Services__c,Grouping__r.Logical_Block_Level_Grouping__c,';
        string query2 = ' From Account Where Grouping__r.Logical_Block_Level_Grouping__c in:lstLogicalBlockIds and Profiled_Account_Flag__c =true ';
        string query = '';
        Schema.DescribeFieldResult fieldResult = Velocity_Rules__c.Field_Name__c.getDescribe();
        List<Schema.PicklistEntry> pickListValue= fieldResult.getPicklistValues();
        system.debug('pickListValue----->' +pickListValue);
        for( Schema.PicklistEntry value : pickListValue){
            if(query.length() < 9000){ 
                query = query + value.getLabel()+',';
            }
        } 
        query = query.substring(0,query.lastIndexOf(','));
        query = query1 + query + query2;
        lstAccount = Database.query(query); 
        }
        // Create Map from the query result set - Put related groupings under list in map
        if(lstAccount.size()>0){
            for(Account accountObj: lstAccount){
                if(mapLogicalBlockWithProfiledAccount.containsKey(accountObj.Grouping__r.Logical_Block_Level_Grouping__c)){
                    mapLogicalBlockWithProfiledAccount.get(accountObj.Grouping__r.Logical_Block_Level_Grouping__c).add(accountObj);
                }else{
                    mapLogicalBlockWithProfiledAccount.put(accountObj.Grouping__r.Logical_Block_Level_Grouping__c,new List<Account>());
                    mapLogicalBlockWithProfiledAccount.get(accountObj.Grouping__r.Logical_Block_Level_Grouping__c).add(accountObj);
                }
            }
        }
        return mapLogicalBlockWithProfiledAccount;
    }
    /* @getProfiledAccountUnderPANLevel<PRM_PAN_VPP_VelocityRuleResultsUtils(): This method gets called in jobs to fetch Profiled Accounts under 
                                                    PANTheater Grouping. >                                                  
       @param - List<Id> PANTheaterIds  - List of PAN ids for which we have to get Profiled Accounts under it.
       @return Map<Id,List<Account>> - Returns a Map of PAN ids and their respective ProfiledAccounts under it.
       @throws exception - <No Exception>
   */
    public Map<Id,List<Account>> getProfiledAccountUnderPANLevel(List<Id> lstPANTheaterIds){
        Map<Id,List<Account>> mapPANTheaterWithProfiledAccount = new Map<Id,List<Account>> ();
        list<Account> lstAccount = new list<Account>();
        // fetch all groupings under given ids
        if(lstPANTheaterIds.size()>0){
           string query1 = 'Select Id,Name,Grouping__c,Theater1__c,Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c,'
                          +'Velocity_Services_Implement__c,Solution_Center_Implemented__c,Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c,'
                          +'Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c,Velocity_Compliance_Status__c,Deployed_Velocity_Services__c,Grouping__r.Logical_Block_Level_Grouping__c,';
        string query2 = ' From Account Where Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c in:lstPANTheaterIds and Profiled_Account_Flag__c =true ';
        string query = '';
        Schema.DescribeFieldResult fieldResult = Velocity_Rules__c.Field_Name__c.getDescribe();
        List<Schema.PicklistEntry> pickListValue= fieldResult.getPicklistValues();
        system.debug('pickListValue----->' +pickListValue);
        for( Schema.PicklistEntry value : pickListValue){
            if(query.length() < 9000){ 
                query = query + value.getLabel()+',';
            }
        } 
        query = query.substring(0,query.lastIndexOf(','));
        query = query1 + query + query2;
        lstAccount = Database.query(query); 
        }
        // Create Map from the query result set - Put related groupings under list in map
        if(lstAccount.size()>0){
            for(Account accountObj: lstAccount){
                if(mapPANTheaterWithProfiledAccount.containsKey(accountObj.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c)){
                    mapPANTheaterWithProfiledAccount.get(accountObj.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c).add(accountObj);
                }else{
                    mapPANTheaterWithProfiledAccount.put(accountObj.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c,new List<Account>());
                    mapPANTheaterWithProfiledAccount.get(accountObj.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c).add(accountObj);
                }
            }
        }
        return mapPANTheaterWithProfiledAccount;
    }
}