/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req     DESCRIPTION                               
 |  ====            =========       ======     ===========  
 |  02.9.2012      Anand Sharma               Controller for the PRM_PAN_VPP_Scorecard page.
 | 22/05/2013      Suresh D        WR#239600  Added the Isilon_Track_Specialty__c to the query in the method fetchVRResults method  
+=========================================================================================================================*/
public class PRM_PAN_VPP_ScorecardController {
    //Properties
    public ID AccountId ;
    public ID CurrentGroupingId ;
    public String TargetTier {get; set;}
    public String LogicalBlock {get; set;}
    public String Cluster {get; set;}
    public String ComplianceStatus {get; set;}
    public String DeployedToStatus {get; set;}
    public Account objAccount {get; set;}
    
    public Boolean isRevenueVisible{get; set;}
    public Boolean isRenderScorecard {get; set;}
    public Boolean isPartnerUser {get; set;}
    
    public List<PRM_PAN_VPP_PanLogicalDataHelper> lstPanContainer {get; set;}
    public List<PRM_PAN_VPP_PanLogicalDataHelper> lstPanContainerSingle  {get; set;}
    
    public List<PRM_PAN_VPP_PanLogicalDataHelper> lstLogicalContainer {get; set;}
    public List<PRM_PAN_VPP_PanLogicalDataHelper> lstLogicalContainerSingle  {get; set;}
    
    public List<PRM_PAN_VPP_PanLogicalDataHelper> lstLocalContainer {get; set;}
    public List<PRM_PAN_VPP_PanLogicalDataHelper> lstLocalContainerSingle  {get; set;}
    
    Map<Id, Account_Groupings__c>   mapLogicalGrouping = new Map<Id, Account_Groupings__c>();
    Map<Id, List<String>>   mapGroupingRequrementsForOrder;
    Map<String,Velocity_Rule_Results__c> mapTotalTierRecord = new Map<String, Velocity_Rule_Results__c>();
    Map<String, String> mapGroupingTireStatus = new Map<String, String>();
    List<String> lstCustomLabelTierValues = new List<String>();
    
    Id PanBlockRecTypeId;
    Id LogicalBlockRecTypeId;
    public String currentTheater{get; set;}
    List<String> lstTiers = new List<String>(); 
    List<String> lstLocalRequirements = new List<String>();
    List<String> lstGroupingRequirements = new List<String>();
    public List<Velocity_Rule_Results__c> lstPanVRR = new List<Velocity_Rule_Results__c>();
    public List<Velocity_Rule_Results__c> lstLocalVRR = new List<Velocity_Rule_Results__c>();
    public List<Velocity_Rule_Results__c> lstLogicalBlockVRR = new List<Velocity_Rule_Results__c>();
    
    Map<String,CustomSettingDataValueMap__c> DataValueMap = new Map<String,CustomSettingDataValueMap__c>();
    
    //Constructor
    public PRM_PAN_VPP_ScorecardController(){
        
        lstPanContainer = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
        lstPanContainerSingle = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
         
        lstLogicalContainer = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
        lstLogicalContainerSingle = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
        
        lstLocalContainer = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
        lstLocalContainerSingle = new List<PRM_PAN_VPP_PanLogicalDataHelper>();

        TargetTier ='';
        DeployedToStatus='';
        mapGroupingRequrementsForOrder = new Map<Id, List<String>>();
        
        this.AccountId = ApexPages.currentPage().getParameters().get('id');
        
        DataValueMap = CustomSettingDataValueMap__c.getAll(); 
        CustomSettingDataValueMap__c objDataValue = DataValueMap.get('PRMVPPEMEASignatureValue');
        CustomSettingDataValueMap__c objDistributorValue = DataValueMap.get('PRMVPPDistributorValue');
        string DistributorUserProfiles = DataValueMap.get('Distributor Partner Users').DataValue__c;
        string NonAPJDistributorUserProfiles = DataValueMap.get('NonAPJ Distributor Users').DataValue__c;
        
        isPartnerUser = false;
        isRevenueVisible = true;
        boolean isPreferredDistributorUser = false;
        isRenderScorecard = true;
        
        // get profiled account Id from partner user contact 
        User currentUser = [Select u.ContactId, u.Contact.AccountId,contact.Account.PROFILED_ACCOUNT_FLAG__c,
                                contact.Account.Profiled_Account__c,u.Velocity_Access__c, u.Co_Op_Access__c,
                                contact.Account.Partner_Type__c
                                from User u 
                                where id=:userinfo.getUserId()];
        
        if(userinfo.getUserType() == 'PowerPartner'){                   
           //System.debug('currentUser Account Id-->'+currentUser.Contact.AccountId); 
           if(DistributorUserProfiles.contains(userInfo.getProfileId())) {
              System.Debug('UserProfileId' +userinfo.getProfileId());
              isRevenueVisible = false;
           }
           if(this.AccountId !=null && this.AccountId !=currentUser.Contact.AccountId){
             isPreferredDistributorUser = preferredDistributorCheck(this.AccountId ,currentUser.Contact.AccountId);
           }
           
           //if account is profiled account then get that account id else take its profiled account Id
           if(!isPreferredDistributorUser &&  this.AccountId ==null){
                if(currentUser.contact.Account.PROFILED_ACCOUNT_FLAG__c==true){  
                    this.AccountId = currentUser.Contact.AccountId ;
                }                   
                else{ 
                    this.AccountId = currentUser.Contact.Account.Profiled_Account__c;
                }
           }
           isPartnerUser = true;  
 
        }
        
        fetchAccount(this.AccountId); 
        
        if(objAccount.Velocity_Solution_Provider_Tier__c==null || objAccount.Cluster__c==null){
              ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Velocity_Tier_Error_Message);
              ApexPages.addMessage(errorMessage);
              isRenderScorecard = false;
              return;
        }
        
        //check for distributor account, if yes, then display error message.
        if(objAccount != null && DataValueMap.containsKey('PRMVPPDistributorValue')){
            if(objAccount.Partner_Type__c!= null){
                String[] arrPartnerType = objAccount.Partner_Type__c.split(';');
                if(isPartnerUser && currentUser.contact.Account.Partner_Type__c.contains('Distributor') 
                    && objAccount.Partner_Type__c.contains('Distribution VAR')
                    && (objAccount.Id != currentUser.contact.AccountId || (objAccount.Id != currentUser.contact.Account.Profiled_Account__c && currentUser.contact.Account.Profiled_Account__c !=null))
                    && (!isPreferredDistributorUser || !NonAPJDistributorUserProfiles.contains(userInfo.getProfileId()))){
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, System.Label.Insufficient_Access_To_VPP_Scorecards);
                    ApexPages.addMessage(errorMessage);
                    isRenderScorecard = false;
                    return;     
                    }
                for(Integer i=0; i < arrPartnerType.size(); i++){
                    String[] arrDistributorType = objDistributorValue.DataValue__c.split(',');
                    for(Integer j=0; j < arrDistributorType.size(); j++){
                        if(arrPartnerType[i] == arrDistributorType[j] ){
                            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, System.Label.PRM_VPP_Distributor_Error_Message);
                            ApexPages.addMessage(errorMessage);
                            isRenderScorecard = false;
                            return;
                        }
                    }       
                }
            }                                       
        }
        
        
        Map<String,Schema.RecordTypeInfo> recordTypes = Account_Groupings__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        PanBlockRecTypeId = recordTypes.get('Partner Grouping - PAN Theater').getRecordTypeId();
        LogicalBlockRecTypeId = recordTypes.get('Partner Grouping - Logical Block').getRecordTypeId();
        
        
        lstTiers = fetchTiers();
        currentTheater = getTheaterName();
        fetchVRResults();
        
        if(lstPanVRR.size() >0){
            Map<String , Map<String, Map<String, List<Velocity_Rule_Results__c>>>>  mapGroupReqTierPANVRR = processingDataResult(lstPanVRR);        
            lstPanContainer = getDisplayResult(mapGroupReqTierPANVRR);      
            lstPanContainerSingle = getSingleDisplayResult(mapGroupReqTierPANVRR);
        }
        
        if(lstLocalVRR.size() >0){
            Map<String , Map<String, Map<String, List<Velocity_Rule_Results__c>>>>  mapGroupReqTierLocalVRR = processingDataResult(lstLocalVRR);        
            System.debug('mapGroupReqTierLocalVRR :' + mapGroupReqTierLocalVRR);
            lstLocalContainer = getDisplayResultForLocal(mapGroupReqTierLocalVRR);
            System.debug('lstLocalContainer :' + lstLocalContainer);      
            lstLocalContainerSingle = getSingleDisplayResult(mapGroupReqTierLocalVRR);
        }
        
        if(lstLogicalBlockVRR.size() >0){
            Map<String , Map<String, Map<String, List<Velocity_Rule_Results__c>>>>  mapGroupReqTierLogicalBlockVRR = processingDataResult(lstLogicalBlockVRR);      
            lstLogicalContainer= getDisplayResult(mapGroupReqTierLogicalBlockVRR);      
            lstLogicalContainerSingle = getSingleDisplayResult(mapGroupReqTierLogicalBlockVRR);
        }
        /*
        if(objAccount.Account_Level__c =='LOGICAL'){
            TargetTier = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Target_Tier__c;
        }*/
        if(objAccount.Account_Level__c =='PAN'){
            DeployedToStatus = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Deployed_To__c;
            ComplianceStatus = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Compliance_Period_Requirments_Met__c;
        }
        System.debug('lstPanVRR :' + lstPanVRR);
        System.debug('lstLocalVRR :' + lstLocalVRR);        
        System.debug('lstLogicalBlockVRR :' + lstLogicalBlockVRR);
        
        System.debug('lstPanContainer Size :' + lstPanContainer.size());
        System.debug('lstPanContainer :' + lstPanContainer);
        
        System.debug('lstLocalContainer :' + lstLocalContainer);
        System.debug('lstLocalContainer Size :' + lstLocalContainer.size());
        
        System.debug('lstLogicalContainer :' + lstLogicalContainer);
        System.debug('lstLogicalContainer size:' + lstLogicalContainer.size());
        System.debug('lstLocalRequirements size:' + lstLocalRequirements);
               
    }
    private String getTheaterName(){
        Map<String,CustomSettingDataValueMap__c> DataValueMap =  CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c objDataValue = new CustomSettingDataValueMap__c();
        String strTheater;
        Set<String> setTiers = new Set<String>();
        // get tier names from custom setting and set values into map
        if(DataValueMap.containsKey('TartgetTierTheaters')){
            objDataValue = DataValueMap.get('TartgetTierTheaters');
            if(objDataValue != null){
                String[] arrTierNames  = objDataValue.DataValue__c.split(',');
                for(Integer i=0; i < arrTierNames.size(); i++){                    
                    setTiers.add(arrTierNames[i]);
                }  
            }           
        }
        if(setTiers.contains(this.objAccount.Theater1__c)){
            strTheater = System.label.Target_Tier;  
        }else{
            strTheater = System.label.Current_Tier;
        }
        return strTheater;
    }
    
    public Account fetchAccount(ID AccountId){
        this.objAccount = [Select Id, Name, Theater1__c, BillingCountry, Account_Level__c, Grouping__c, Grouping__r.Name ,
                                    Advanced_Consolidate_Specialty__c,Backup_and_Recovery_Speciality__c,
                                    Consolidate_Specialty__c,Governance_and_Archive_Specialty__c,Cluster__c,Cloud_Builder_Practice__c,
                                    Master_Grouping__c, Profiled_Account__c,Specialty_Rule_Type__c,Cloud_Provider_Practice__c,
                                    PROFILED_ACCOUNT_FLAG__c,Velocity_Solution_Provider_Tier__c,Partner_Type__c,
                                    Grouping__r.Logical_Block_Level_Grouping__c, 
                                    Grouping__r.Logical_Block_Level_Grouping__r.Name,
                                    Grouping__r.Logical_Block_Level_Grouping__r.Cluster__c,
                                    Grouping__r.Logical_Block_Level_Grouping__r.Deployed_To__c ,
                                    Grouping__r.Logical_Block_Level_Grouping__r.Target_Tier__c,
                                    Grouping__r.Logical_Block_Level_Grouping__r.Compliance_Period_Requirments_Met__c, 
                                    Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c, 
                                    Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Deployed_To__c ,
                                    Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Cluster__c ,
                                    Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Target_Tier__c,
                                    Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Compliance_Period_Requirments_Met__c
                                from Account 
                                where id =:accountId];
        return objAccount;                                
    }
    
    public List<String> fetchTiers(){
        Map<String,CustomSettingDataValueMap__c> DataValueMap =  CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c objDataValue = new CustomSettingDataValueMap__c();
        Map<String,String> mapTierDetails = new Map<String,String>();
        List<String> lstTiers = new List<String>();
        
        if(System.Label.PRM_Tier1_Name != 'NONE') lstCustomLabelTierValues.add(System.Label.PRM_Tier1_Name);
        if(System.Label.PRM_Tier2_Name != 'NONE') lstCustomLabelTierValues.add(System.Label.PRM_Tier2_Name);
        if(System.Label.PRM_Tier3_Name != 'NONE') lstCustomLabelTierValues.add(System.Label.PRM_Tier3_Name);
        if(System.Label.PRM_Tier4_Name != 'NONE') lstCustomLabelTierValues.add(System.Label.PRM_Tier4_Name);
        if(System.Label.PRM_Tier5_Name != 'NONE') lstCustomLabelTierValues.add(System.Label.PRM_Tier5_Name);
        
        // get tier names from custom setting and set values into map
        if(DataValueMap.containsKey('SequenceOfTiers')){
            objDataValue = DataValueMap.get('SequenceOfTiers');
            if(objDataValue != null){
                String[] arrTierNames  = objDataValue.DataValue__c.split(',');
                for(Integer i=0; i < arrTierNames.size(); i++){
                    mapTierDetails.put(arrTierNames[i], arrTierNames[i]);
                    lstTiers.add(arrTierNames[i]);
                }  
            }
        }
        System.debug('mapTierDetails ' + mapTierDetails.keySet());
        System.debug('lstTiers: ' +lstTiers);
        return lstTiers;
    }
    
    public void fetchVRResults(){ 
        Set<Id> setPanGroupingIds = new Set<Id>();
        Set<Id> setVRRGroupingIds = new Set<Id>(); 
        Set<String> setClusters = new Set<String>(); 
        Map<String, String> mapLocalRequirements = new map<String, String>();
        Set<String> setLocalRequirementsSpecilaity = new Set<String>(); 
        List<Velocity_Rule_Results__c> lstVRR = new List<Velocity_Rule_Results__c>();
        Map<String,Schema.RecordTypeInfo> recordTypes = Velocity_Rules__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        Id TierRecordtypeId = recordTypes.get('Tier Rule').getRecordTypeId();        
        if(objAccount != null){
            if(objAccount.Account_Level__c != null){
                if(objAccount.Account_Level__c =='PAN'){
                    CurrentGroupingId = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c;
                    setPanGroupingIds.add(objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c);
                    Cluster = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Cluster__c;
                    TargetTier = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Target_Tier__c;
                    LogicalBlock = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Name;
                    ComplianceStatus = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Compliance_Period_Requirments_Met__c;
                    System.debug('Grouping Id ' + objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c);
                    System.debug('Cluster ' + Cluster);
                    System.debug('TargetTier ' + TargetTier);
                    List<Account_Groupings__c> lstLogicalGrouping = new List<Account_Groupings__c>();             
                    lstLogicalGrouping = [Select Id, Name ,Cluster__c ,Advanced_Consolidate_Specialty__c, Backup_and_Recovery_Specialty__c,Consolidate_Specialty__c,
                                                            Governance_and_Archive_Specialty__c,Isilon_Track_Specialty__c,Compliance_Period_Requirments_Met__c,Target_Tier__c, Deployed_To__c,
                                                            Logical_Block_Level_Grouping__c, Speciality_Type__c, Local_Requirment_Set__c, Pan_Theater_Level_Grouping__c 
                                                    FROM Account_Groupings__c 
                                                    where Pan_Theater_Level_Grouping__c in:setPanGroupingIds 
                                                    OR Id in: setPanGroupingIds order by Name];
                    
                    for(Account_Groupings__c objGrouping :lstLogicalGrouping){
                        if(objGrouping.Local_Requirment_Set__c != null){
                            mapLocalRequirements.put(objGrouping.Id , objGrouping.Local_Requirment_Set__c);                            
                            lstLocalRequirements.add(objGrouping.Id);                       
                        } 
                        if(objGrouping.Cluster__c != null){
                            setClusters.add(objGrouping.Cluster__c);
                        }                         
                        lstGroupingRequirements.add(objGrouping.Id);
                        mapLogicalGrouping.put(objGrouping.Id, objGrouping);                                              
                    }
                    if(objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Cluster__c != null){
                        setClusters.add(Cluster);
                    }                    
                    setVRRGroupingIds.addAll(mapLogicalGrouping.KeySet());
                    
                    lstVRR = [Select Id, AccountID__c, Current__c, VS_Rule_Result_Display_Name__c, Grouping__c,Grouping__r.RecordTypeid,Is_Total_Revenue__c, RequiredCount__c, Required_Value_Type__c,
                                Revenue_Amount__c, Rule_theater__c, VS_Rule_Result_Section__c, Status__c, VS_Rule_Result_Status__c, Account_Theater__c, Speciality_RuleID__r.Local_Requirment_Set__c,
                                Speciality_RuleID__c, Speciality_RuleID__r.Specilaity__c, Speciality_RuleID__r.Specialty_Rule_Type__c, Speciality_RuleID__r.BR_Sub_category__c,
                                Speciality_RuleID__r.Display_Name__c, Speciality_RuleID__r.Sort__c,Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.Tier__c , 
                                Speciality_RuleID__r.recordTypeId , Speciality_RuleID__r.Evaluation_at__c
                                FROM Velocity_Rule_Results__c 
                                WHERE  //Speciality_RuleID__r.Tier__c = :TargetTier AND
                                Grouping__c in: setVRRGroupingIds AND
                                //Speciality_RuleID__r.Local_Requirment_Set__c in : mapLocalRequirements.values()
                                (
                                    (Speciality_RuleID__r.recordTypeId =: TierRecordtypeId 
                                        AND Speciality_RuleID__r.Cluster__c in : setClusters     
                                        AND (Speciality_RuleID__r.Evaluation_at__c ='Logical Block Grouping Level' OR Speciality_RuleID__r.Evaluation_at__c ='PAN Theater Grouping Level' )
                                    )
                                
                                    OR (Speciality_RuleID__r.Local_Requirment_Set__c in : mapLocalRequirements.values() )
                                
                                )
                                
                                order by Speciality_RuleID__r.Sort__c, Grouping__r.Name asc ];
                    System.Debug('TierRecordtypeId : ' + TierRecordtypeId);
                    System.Debug('Cluster : ' + Cluster);
                    System.Debug('setClusters : ' + setClusters);
                    System.Debug('setVRRGroupingIds : ' + setVRRGroupingIds);
                    System.Debug('mapLocalRequirements.KeySet() : ' + mapLocalRequirements.KeySet());
                    System.Debug('mapLocalRequirements.values() : ' + mapLocalRequirements.values());
                    System.Debug('lstVRR : ' + lstVRR);
                    //System.Debug('lstVRR Size: ' + lstVRR.size());
                }                
                
                if(lstVRR != null && lstVRR.size() >0){
                    for(Velocity_Rule_Results__c objVRR :lstVRR){
                        //Create VRR for Local Requirements
                        System.Debug('objVRR.Speciality_RuleID__r.Local_Requirment_Set__c : ' + objVRR.Speciality_RuleID__r.Local_Requirment_Set__c);
                        System.Debug('LogicalBlockRecTypeId : ' + LogicalBlockRecTypeId);
                        System.Debug('PanBlockRecTypeId : ' + PanBlockRecTypeId);
                        System.Debug('TierRecordtypeId : ' + TierRecordtypeId);
                        System.Debug('TargetTier : ' + TargetTier);
                        System.Debug('objVRR.Grouping__r.RecordTypeId : ' + objVRR.Grouping__r.RecordTypeId);
                        System.Debug('mapLocalRequirements.get(objVRR.Speciality_RuleID__r.Local_Requirment_Set__c): ' + mapLocalRequirements.get(objVRR.Speciality_RuleID__r.Local_Requirment_Set__c));
                        System.Debug('objVRR.Grouping__c : ' + objVRR.Grouping__c);
                            
                        //&& CurrentGroupingId == objVRR.Grouping__c                    
                        if(TargetTier != null  ){
                            if( ((objAccount.Account_Level__c =='PAN' && objVRR.Speciality_RuleID__r.Evaluation_at__c =='PAN Theater Grouping Level') 
                                || (objAccount.Account_Level__c =='LOGICAL' && objVRR.Speciality_RuleID__r.Evaluation_at__c =='Logical Block Grouping Level')) 
                                && CurrentGroupingId == objVRR.Grouping__c && objVRR.Rule_theater__c == Cluster
                                && objVRR.Speciality_RuleID__r.recordTypeId == TierRecordtypeId){
                                    System.Debug('Inside Pan : ');
                                    System.Debug('Inside Pan VRR: ' + objVRR);
                                    lstPanVRR.add(objVRR);
                            }
                            if(objAccount.Account_Level__c =='PAN' && objVRR.Speciality_RuleID__r.Local_Requirment_Set__c != null && objVRR.Grouping__r.RecordTypeId == LogicalBlockRecTypeId){
                                if(mapLocalRequirements.containsKey(objVRR.Grouping__c) 
                                    && mapLocalRequirements.get(objVRR.Grouping__c) == objVRR.Speciality_RuleID__r.Local_Requirment_Set__c){
                                    System.Debug('Inside Local : ');
                                    System.Debug('Inside Local objVRR: ' + objVRR);
                                    objVRR.Speciality_RuleID__r.Tier__c ='LocalRequirement';
                                    lstLocalVRR.add(objVRR);
                                }
                                    
                            }
                        }else if(TargetTier == null && objVRR.Speciality_RuleID__r.Evaluation_at__c =='Logical Block Grouping Level'
                            && objVRR.Grouping__r.RecordTypeId ==LogicalBlockRecTypeId && objVRR.Speciality_RuleID__r.recordTypeId == TierRecordtypeId){
                            System.Debug('Inside Logical : ');
                            System.Debug('Inside Logical VRR: ' + objVRR);
                            //ComplianceStatus = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Compliance_Period_Requirments_Met__c;
                            //DeployedToStatus = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Deployed_To__c;
                            lstLogicalBlockVRR.add(objVRR);
                        }                        
                        
                        if(objVRR.Status__c =='Not Achieved'){
                            if(!mapGroupingTireStatus.containsKey(objVRR.Grouping__c+objVRR.Speciality_RuleID__r.Tier__c)){
                                mapGroupingTireStatus.put(objVRR.Grouping__c+objVRR.Speciality_RuleID__r.Tier__c, objVRR.Status__c);                       
                            }
                        }
                    }
                }
                
            }
        }
        //return lstVRR;
    }
    
    private Map<String , Map<String, Map<String, List<Velocity_Rule_Results__c>>>> processingDataResult(List<Velocity_Rule_Results__c> lstVelocityRulesResult){
        Map<String , Map<String, Map<String, List<Velocity_Rule_Results__c>>>> mapGroupReqTierVRR = new Map<String, Map<String, Map<String, List<Velocity_Rule_Results__c>>>>();
        Map<String, Map<String, List<Velocity_Rule_Results__c>>> mapReqBlockVRR = new Map<String, Map<String, List<Velocity_Rule_Results__c>>>();
        Map<String, List<Velocity_Rule_Results__c>> mapBlockVRR = new Map<String, List<Velocity_Rule_Results__c>>();
        Map<String, Set<String>> mapGroupingRequrementsForOrderTemp = new Map<String, Set<String>>();
        
        if(lstVelocityRulesResult != null && lstVelocityRulesResult.size() >0){         
            for(Velocity_Rule_Results__c scoreObj: lstVelocityRulesResult) {
                if(mapGroupReqTierVRR.containsKey(scoreObj.Grouping__c)){
                    mapReqBlockVRR = mapGroupReqTierVRR.get(scoreObj.Grouping__c);
                }else{
                    mapGroupReqTierVRR.put(scoreObj.Grouping__c, new Map<String,Map<String, List<Velocity_Rule_Results__c>>>());
                    mapReqBlockVRR = mapGroupReqTierVRR.get(scoreObj.Grouping__c);
                }           
                if(mapReqBlockVRR.containsKey(scoreObj.Speciality_RuleID__r.Display_Name__c)){
                    mapBlockVRR = mapReqBlockVRR.get(scoreObj.Speciality_RuleID__r.Display_Name__c);                 
                }else{                              
                    mapReqBlockVRR.put(scoreObj.Speciality_RuleID__r.Display_Name__c, new Map<String, List<Velocity_Rule_Results__c>>());
                    mapBlockVRR = mapReqBlockVRR.get(scoreObj.Speciality_RuleID__r.Display_Name__c);
                }           
                if(!mapBlockVRR.containsKey(scoreObj.Speciality_RuleID__r.Tier__c)){                        
                    mapBlockVRR.put(scoreObj.Speciality_RuleID__r.Tier__c, new List<Velocity_Rule_Results__c>());
                    mapBlockVRR.get(scoreObj.Speciality_RuleID__r.Tier__c).add(scoreObj);
                }
                if(scoreObj.Speciality_RuleID__r.Sort__c != null && scoreObj.Speciality_RuleID__c != null && scoreObj.Speciality_RuleID__r.Display_Name__c != null){
                    if(mapGroupingRequrementsForOrder.containsKey(scoreObj.Grouping__c) && mapGroupingRequrementsForOrderTemp.containsKey(scoreObj.Grouping__c)){
                        if(!mapGroupingRequrementsForOrderTemp.get(scoreObj.Grouping__c).contains(scoreObj.Speciality_RuleID__r.Display_Name__c)){
                            mapGroupingRequrementsForOrder.get(scoreObj.Grouping__c).add(scoreObj.Speciality_RuleID__r.Display_Name__c); 
                            mapGroupingRequrementsForOrderTemp.get(scoreObj.Grouping__c).add(scoreObj.Speciality_RuleID__r.Display_Name__c); 
                        }                           
                    }else{                              
                        mapGroupingRequrementsForOrder.put(scoreObj.Grouping__c, new List<String>());
                        mapGroupingRequrementsForOrder.get(scoreObj.Grouping__c).add(scoreObj.Speciality_RuleID__r.Display_Name__c); 
                        mapGroupingRequrementsForOrderTemp.put(scoreObj.Grouping__c, new Set<String>());
                        mapGroupingRequrementsForOrderTemp.get(scoreObj.Grouping__c).add(scoreObj.Speciality_RuleID__r.Display_Name__c);                        
                    }
                }
                if((scoreObj.Is_Total_Revenue__c=='YES')){
                    if(!mapTotalTierRecord.containsKey(scoreObj.Grouping__c+scoreObj.Speciality_RuleID__r.Tier__c)){
                        mapTotalTierRecord.put(scoreObj.Grouping__c+scoreObj.Speciality_RuleID__r.Tier__c, scoreObj);                       
                    }                   
                } 
                             
            }
            System.Debug('mapGroupReqTierVRR : ' + mapGroupReqTierVRR); 
            System.Debug('mapGroupReqTierVRR Key Set : ' + mapGroupReqTierVRR.keySet());
        }
        
        return mapGroupReqTierVRR;
    }
    
    private List<PRM_PAN_VPP_PanLogicalDataHelper> getDisplayResult(Map<String , Map<String, Map<String, List<Velocity_Rule_Results__c>>>> mapGroupReqTierVRR){
        List<PRM_PAN_VPP_PanLogicalDataHelper> lstTempContainer = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
        PRM_PAN_VPP_PanLogicalDataHelper objPanLogicalDC = new PRM_PAN_VPP_PanLogicalDataHelper();
        List<PRM_PAN_VPP_RequirementDataContainer> lstRequirementResults = new List<PRM_PAN_VPP_RequirementDataContainer>();
        PRM_PAN_VPP_RequirementDataContainer objReqDC = new PRM_PAN_VPP_RequirementDataContainer();
        PRM_PAN_VPP_BlockResultDataContainer objBlock = new PRM_PAN_VPP_BlockResultDataContainer();
        PRM_PAN_VPP_BlockResultDataContainer objActualBlock = new PRM_PAN_VPP_BlockResultDataContainer();
        List<PRM_PAN_VPP_BlockResultDataContainer> lstBlockDC = new List<PRM_PAN_VPP_BlockResultDataContainer>();
        for(String strGrouping : lstGroupingRequirements){
        	if(mapLogicalGrouping != null && mapLogicalGrouping.ContainsKey(strGrouping) && mapLogicalGrouping.get(strGrouping).Cluster__c != null){
				if(mapGroupReqTierVRR.keySet().contains(strGrouping)){            	
					objPanLogicalDC = new PRM_PAN_VPP_PanLogicalDataHelper();
					System.Debug('strGrouping : ' + strGrouping);
					//System.Debug('mapReqBlockVRR : ' + mapReqBlockVRR);
					
					objPanLogicalDC.Level = mapLogicalGrouping.get(strGrouping).Name;
					objPanLogicalDC.CurrentTargetTier = mapLogicalGrouping.get(strGrouping).Target_Tier__c;         
					objPanLogicalDC.CurrentLogicalBlock  = LogicalBlock;
					objPanLogicalDC.CurrentTheater = currentTheater;
					lstRequirementResults = new List<PRM_PAN_VPP_RequirementDataContainer>();
					objReqDC = new PRM_PAN_VPP_RequirementDataContainer();					
					
					//for(String strReqObj : mapGroupReqTierVRR.get(strGrouping).KeySet()){
					for(String strReqObj : mapGroupingRequrementsForOrder.get(strGrouping)){
						if(mapGroupReqTierVRR.get(strGrouping).KeySet().contains(strReqObj)){
							objReqDC = new PRM_PAN_VPP_RequirementDataContainer();
							objReqDC.RequirementName  = strReqObj;
							
							objBlock = new PRM_PAN_VPP_BlockResultDataContainer();
							objActualBlock = new PRM_PAN_VPP_BlockResultDataContainer();
							lstBlockDC = new List<PRM_PAN_VPP_BlockResultDataContainer>();
							Integer iCount =0;
							for(String strTier : lstTiers){
								String strSSCPTier='';
								if(strTier=='Signature'){
									strSSCPTier = 'Signature / SSCP';
								}                           
								objBlock = new PRM_PAN_VPP_BlockResultDataContainer();
								String strTiernamevalue ='';
								if(lstCustomLabelTierValues!= null && lstCustomLabelTierValues.size()>0){
									strTiernamevalue = lstCustomLabelTierValues.get(iCount);
								}
								objBlock.BlockName = strTier;
								objBlock.BlockDisplayName = strTiernamevalue;
								objBlock.HeaderStatus = 'Achieved';
								if(mapGroupReqTierVRR.get(strGrouping).get(strReqObj).ContainsKey(strTier) || mapGroupReqTierVRR.get(strGrouping).get(strReqObj).ContainsKey(strSSCPTier)){
									if(mapGroupReqTierVRR.get(strGrouping).get(strReqObj).ContainsKey(strTier)){
										objBlock.Result = mapGroupReqTierVRR.get(strGrouping).get(strReqObj).get(strTier);
										objBlock.Status =objBlock.Result.get(0).Status__c;
									}
									if(mapGroupReqTierVRR.get(strGrouping).get(strReqObj).ContainsKey(strSSCPTier)){
										objBlock.Result = mapGroupReqTierVRR.get(strGrouping).get(strReqObj).get(strSSCPTier);
										objBlock.Status =objBlock.Result.get(0).Status__c;
										objBlock.BlockName = strSSCPTier;
										objBlock.BlockDisplayName = System.label.Pan_Signature_SSCP;
									}
								}else if(mapTotalTierRecord.containsKey(strGrouping+strTier)){
									List<Velocity_Rule_Results__c> lstVRRss = new List<Velocity_Rule_Results__c>();
									lstVRRss.add(mapTotalTierRecord.get(strGrouping+strTier));
									objBlock.Result = lstVRRss;
									objBlock.Status =lstVRRss.get(0).Status__c;
								}else if(mapTotalTierRecord.containsKey(strGrouping+strSSCPTier)){
									List<Velocity_Rule_Results__c> lstVRRss = new List<Velocity_Rule_Results__c>();
									lstVRRss.add(mapTotalTierRecord.get(strGrouping+strSSCPTier));
									objBlock.Result = lstVRRss;
									objBlock.Status =lstVRRss.get(0).Status__c;
								}else{
									List<Velocity_Rule_Results__c> lstVRRss = new List<Velocity_Rule_Results__c>();
									Velocity_Rule_Results__c objVRR = new Velocity_Rule_Results__c();
									objVRR.Current__c = '';                         
									lstVRRss.add(objVRR);
									objBlock.Status ='Not Achieved'; 
									objBlock.Result = lstVRRss;
								}
								objBlock.isVelocityResult = true;  
								if(mapGroupingTireStatus.containsKey(strGrouping+objBlock.BlockName)){
									objBlock.HeaderStatus = mapGroupingTireStatus.get(strGrouping+objBlock.BlockName) ;
								}                 
								lstBlockDC.add(objBlock);
								//if(objBlock.Result.get(0).Rule_Theater__c == mapLogicalGrouping.get(strGrouping).Cluster__c){
									if(objPanLogicalDC.CurrentTargetTier == strTier || objPanLogicalDC.CurrentTargetTier == strSSCPTier){
										List<Velocity_Rule_Results__c> lstVRRss = new List<Velocity_Rule_Results__c>();
										//Velocity_Rule_Results__c objVRR = new Velocity_Rule_Results__c();
										//objVRR.Current__c = objBlock.Result.get(0).Current__c;
										//objVRR.Speciality_RuleID__c = objBlock.Result.get(0).Speciality_RuleID__c;                                
										//lstVRRss.add(objVRR);
										lstVRRss = objBlock.Result;
										objActualBlock.Result = lstVRRss;
										objActualBlock.BlockName ='Actual'; 
										objActualBlock.BlockDisplayName = System.Label.Actual;
										objActualBlock.Status =objBlock.Status;                                 
										objActualBlock.isVelocityResult = true;
									}
								//}
								iCount++;
							}
							lstBlockDC.add(objActualBlock);
							objReqDC.BlockResult = lstBlockDC;
							lstRequirementResults.add(objReqDC);
						}
					}
					
					objPanLogicalDC.lstRequirementResults = lstRequirementResults;
					lstTempContainer.add(objPanLogicalDC);
				}
			}
        }
        
        System.debug('lstPanContainer ' + lstPanContainer);
        
        return lstTempContainer;
    }
    
    private List<PRM_PAN_VPP_PanLogicalDataHelper> getDisplayResultForLocal(Map<String , Map<String, Map<String, List<Velocity_Rule_Results__c>>>> mapGroupReqTierVRR){
        List<PRM_PAN_VPP_PanLogicalDataHelper> lstTempContainer = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
        PRM_PAN_VPP_PanLogicalDataHelper objPanLogicalDC = new PRM_PAN_VPP_PanLogicalDataHelper();
        List<PRM_PAN_VPP_RequirementDataContainer> lstRequirementResults = new List<PRM_PAN_VPP_RequirementDataContainer>();
        PRM_PAN_VPP_RequirementDataContainer objReqDC = new PRM_PAN_VPP_RequirementDataContainer();
        PRM_PAN_VPP_BlockResultDataContainer objBlock = new PRM_PAN_VPP_BlockResultDataContainer();
        PRM_PAN_VPP_BlockResultDataContainer objActualBlock = new PRM_PAN_VPP_BlockResultDataContainer();
        List<PRM_PAN_VPP_BlockResultDataContainer> lstBlockDC = new List<PRM_PAN_VPP_BlockResultDataContainer>();
        
        System.Debug('lstLocalRequirements : ' + lstLocalRequirements);
        
        for(String strGrouping : lstGroupingRequirements){
            if(mapGroupReqTierVRR.keySet().contains(strGrouping)){
                objPanLogicalDC = new PRM_PAN_VPP_PanLogicalDataHelper();
                System.Debug('strGrouping : ' + strGrouping);
                //System.Debug('mapReqBlockVRR : ' + mapReqBlockVRR);
                
                objPanLogicalDC.Level = mapLogicalGrouping.get(strGrouping).Name;
                //objPanLogicalDC.CurrentTargetTier = mapLogicalGrouping.get(strGrouping).Target_Tier__c;  
                objPanLogicalDC.CurrentLogicalBlock  = LogicalBlock;         
                objPanLogicalDC.CurrentTargetTier = TargetTier;     
                objPanLogicalDC.CurrentTheater = currentTheater;
                lstRequirementResults = new List<PRM_PAN_VPP_RequirementDataContainer>();
                objReqDC = new PRM_PAN_VPP_RequirementDataContainer();
                
                //for(String strReqObj : mapGroupReqTierVRR.get(strGrouping).KeySet()){
                for(String strReqObj : mapGroupingRequrementsForOrder.get(strGrouping)){
                    if(mapGroupReqTierVRR.get(strGrouping).KeySet().contains(strReqObj)){
                        objReqDC = new PRM_PAN_VPP_RequirementDataContainer();
                        objReqDC.RequirementName  = strReqObj;
                        
                        objBlock = new PRM_PAN_VPP_BlockResultDataContainer();
                        objActualBlock = new PRM_PAN_VPP_BlockResultDataContainer();
                        lstBlockDC = new List<PRM_PAN_VPP_BlockResultDataContainer>();
                        for(String strTier : mapGroupReqTierVRR.get(strGrouping).get(strReqObj).KeySet()){                        
                            objBlock = new PRM_PAN_VPP_BlockResultDataContainer();
                            objBlock.BlockName = 'Required';
                            objBlock.BlockDisplayName = System.Label.Required;
                            if(mapGroupReqTierVRR.get(strGrouping).get(strReqObj).ContainsKey(strTier)){
                                objBlock.Result = mapGroupReqTierVRR.get(strGrouping).get(strReqObj).get(strTier);
                                objBlock.Status =objBlock.Result.get(0).Status__c;
                            }else if(mapTotalTierRecord.containsKey(strGrouping+strTier)){
                                List<Velocity_Rule_Results__c> lstVRRss = new List<Velocity_Rule_Results__c>();
                                lstVRRss.add(mapTotalTierRecord.get(strGrouping+strTier));
                                objBlock.Result = lstVRRss;
                                objBlock.Status =objBlock.Result.get(0).Status__c;
                            }else{
                                List<Velocity_Rule_Results__c> lstVRRss = new List<Velocity_Rule_Results__c>();
                                Velocity_Rule_Results__c objVRR = new Velocity_Rule_Results__c();
                                objVRR.Current__c = '';                             
                                lstVRRss.add(objVRR);
                                objBlock.Result = lstVRRss;
                                objBlock.Status ='Not Achieved'; 
                            }
                            objBlock.isVelocityResult = true;
                            lstBlockDC.add(objBlock);
                            
                            List<Velocity_Rule_Results__c> lstVRRss = new List<Velocity_Rule_Results__c>();
                            lstVRRss = objBlock.Result;
                            objActualBlock.Result = lstVRRss;
                            objActualBlock.BlockName ='Actual'; 
                            objActualBlock.BlockDisplayName  =System.Label.Pan_Actual;
                            objActualBlock.Status =objBlock.Status;                             
                            objActualBlock.isVelocityResult = true;
                            
                            
                        }
                        lstBlockDC.add(objActualBlock);
                        objReqDC.BlockResult = lstBlockDC;
                        lstRequirementResults.add(objReqDC);
                    }
                }
                
                objPanLogicalDC.lstRequirementResults = lstRequirementResults;
                lstTempContainer.add(objPanLogicalDC);
            }
        
		}
            

        System.debug('lstPanContainer ' + lstPanContainer);
        
        return lstTempContainer;
    }
    
    private List<PRM_PAN_VPP_PanLogicalDataHelper> getSingleDisplayResult(Map<String , Map<String, Map<String, List<Velocity_Rule_Results__c>>>> mapGroupReqTierVRR){
        List<PRM_PAN_VPP_PanLogicalDataHelper> lstTempContainerSingle = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
        PRM_PAN_VPP_PanLogicalDataHelper objTemp = new PRM_PAN_VPP_PanLogicalDataHelper();
        List<PRM_PAN_VPP_RequirementDataContainer> lstTemp = new List<PRM_PAN_VPP_RequirementDataContainer>();
        PRM_PAN_VPP_RequirementDataContainer objRADTemp = new PRM_PAN_VPP_RequirementDataContainer();
        List<PRM_PAN_VPP_BlockResultDataContainer> lstTempBRC = new List<PRM_PAN_VPP_BlockResultDataContainer>();
        PRM_PAN_VPP_BlockResultDataContainer objtempBRC = new PRM_PAN_VPP_BlockResultDataContainer();
        if(lstPanContainer.size() >0){
            /**/
            for(PRM_PAN_VPP_PanLogicalDataHelper objSDC: lstPanContainer){
                objTemp = new PRM_PAN_VPP_PanLogicalDataHelper();
                lstTemp = new List<PRM_PAN_VPP_RequirementDataContainer>();
                objTemp.Level = objSDC.Level;
                objTemp.CurrentTargetTier = objSDC.CurrentTargetTier;
                objTemp.CurrentTheater = objSDC.CurrentTheater;
                if(objSDC.lstRequirementResults != null){                               
                    for(PRM_PAN_VPP_RequirementDataContainer objRAD:objSDC.lstRequirementResults){
                        objRADTemp = new PRM_PAN_VPP_RequirementDataContainer();
                        objRADTemp.RequirementName = objRAD.RequirementName;
                        lstTempBRC = new List<PRM_PAN_VPP_BlockResultDataContainer>();
                        if(objRAD.BlockResult != null){
                            for(PRM_PAN_VPP_BlockResultDataContainer objBRC: objRAD.BlockResult){
                                objtempBRC = new PRM_PAN_VPP_BlockResultDataContainer();
                                objtempBRC.BlockName = objBRC.BlockName;
                                objtempBRC.BlockDisplayName = objBRC.BlockDisplayName;
                                objtempBRC.HeaderStatus = objBRC.HeaderStatus;
                                objtempBRC.Result = objBRC.Result;
                                lstTempBRC.add(objtempBRC);                     
                            }
                        }
                        objRADTemp.BlockResult = lstTempBRC;
                        lstTemp.add(objRADTemp);
                        break;
                    }
                }
                objTemp.lstRequirementResults = lstTemp;
                lstTempContainerSingle.add(objTemp);
                break;
            }
            
        }
        return lstTempContainerSingle;
    }   
    
  /* @Method <preferredDistributorCheck(): This method is used to check if the logged in user
    preferred Distributor or not.>
       @param - <Id AcccountId,Id AssociatedAccountId>
       @return <booled> - <Returning True or false>
       @throws exception - <No Exception>
  */     
    public boolean preferredDistributorCheck(id AccountId,Id AssociatedAccountId){
        boolean isPreferredDisty=false;
        List<APPR_MTV__RecordAssociation__c> assRecord = new list<APPR_MTV__RecordAssociation__c>([Select Id,Name, APPR_MTV__Primary__c from APPR_MTV__RecordAssociation__c where APPR_MTV__Account__c =:AccountId 
                                                                                                   and APPR_MTV__Associated_Account__c =:AssociatedAccountId and APPR_MTV__Primary__c = true ]); 
        if(assRecord !=null && assRecord.size()>0){
           isPreferredDisty = true;
        }
        return isPreferredDisty;
    }
    
    /* @Method <cancelUpdates(): This method is used to update the Speciality status of
                             Profiled Account from UI.>
           @param - <void>
           @return <void> - <Not Returning anything>
           @throws exception - <No Exception>
        */     
    public pageReference cancelUpdates(){
        PageReference returnPage = new PageReference('/'+objAccount.Id);
        returnPage.setredirect(true);
        return returnPage;
    }
}