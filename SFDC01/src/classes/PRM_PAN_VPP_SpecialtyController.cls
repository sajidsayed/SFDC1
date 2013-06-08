/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req     DESCRIPTION                               
 |  ====            =========       ======     ===========  
 |  02.9.2012      Anand Sharma               Controller for the PRM_PAN_VPP_Specialty page.
 | 22/05/2013      Suresh D        WR#239600  Added the Isilon_Track_Specialty__c to the query in the method fetchVRResults method  
+=========================================================================================================================*/
public class PRM_PAN_VPP_SpecialtyController { 
    //Properties
    public ID AccountId ;
    public ID CurrentGroupingId ;
    public String TargetTier {get; set;}
    public String LogicalBlock {get; set;}
    public String Cluster {get; set;}
    public String ComplianceStatus {get; set;}
    public Account objAccount {get; set;}
    public String DeployedToStatus {get; set;}
    
    public Boolean isRevenueVisible {get; set;}
    public Boolean isRenderSpeciality {get; set;} 
    public Boolean isPartnerUser {get; set;}
    
    public List<PRM_PAN_VPP_PanLogicalDataHelper> lstPanContainer {get; set;}
    public List<PRM_PAN_VPP_PanLogicalDataHelper> lstPanContainerSingle  {get; set;}
    
    public List<String> setPanGroupingIds {get; set;} 
    
    Map<Id, Account_Groupings__c>   mapLogicalGrouping;
    Map<String, List<String>>   mapGroupingRequrementsForOrder;
    Map<String,Velocity_Rule_Results__c> mapTotalTierRecord = new Map<String, Velocity_Rule_Results__c>();
    Map<String,String> mapSpecilaityAndResults = New Map<String,String>();
    Map<String, List<String>> mapSpecilaitySubSpec = new Map<String, List<String>>();
    Map<String, Map<String , Map<String, Map<String, List<Velocity_Rule_Results__c>>>>> mapSpecSubSpecReqTierVRRSub = new Map<String,Map<String, Map<String, Map<String, List<Velocity_Rule_Results__c>>>>>();
    Map<String, String> mapSpecilaitySubSpecStatus = new Map<String, String>();
    Map<String, String> mapSpecilaitySpecStatus = new Map<String, String>();
    
    Id PanBlockRecTypeId;
    Id LogicalBlockRecTypeId;
    String currentTheater;
    List<String> lstSpecialty = new List<String>();
    public List<Velocity_Rule_Results__c> lstPanVRR = new List<Velocity_Rule_Results__c>();
    Map<String,String> fieldNamesMap = New Map<String,String>();
    
    //Constructor
    public PRM_PAN_VPP_SpecialtyController(){
        
        lstPanContainer = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
        lstPanContainerSingle = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
        TargetTier ='';
        DeployedToStatus='';
        mapLogicalGrouping = new Map<Id, Account_Groupings__c>();
        mapGroupingRequrementsForOrder = new Map<String, List<String>>();  
        setPanGroupingIds = new List<String>();      
        this.AccountId = ApexPages.currentPage().getParameters().get('id');
        
        
        isPartnerUser = false;
        isRenderSpeciality = true;
        isRevenueVisible = true;
        boolean isPreferredDistributorUser = false;
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll(); 
        string DistributorUserProfiles = DataValueMap.get('Distributor Partner Users').DataValue__c; 
        string NonAPJDistributorUserProfiles = DataValueMap.get('NonAPJ Distributor Users').DataValue__c;  
        
        // get profiled account Id from partner user contact 
        User currentUser = [Select u.ContactId, u.Contact.AccountId,contact.Account.PROFILED_ACCOUNT_FLAG__c,
                                contact.Account.Profiled_Account__c,u.Velocity_Access__c, u.Co_Op_Access__c,
                                contact.Account.Partner_Type__c
                                from User u 
                                where id=:userinfo.getUserId()];
        
        if(userinfo.getUserType() == 'PowerPartner'){                   
            System.debug('currentUser Account Id-->'+currentUser.Contact.AccountId); 
           //if account is profiled account then get that account id else take its profiled account Id
           if(DistributorUserProfiles.contains(userInfo.getProfileId())) {
              System.Debug('UserProfileId' +userinfo.getProfileId());
              isRevenueVisible = false;
           }
           if(this.AccountId !=currentUser.Contact.AccountId && this.AccountId !=null){
                 isPreferredDistributorUser = preferredDistributorCheck(this.AccountId,currentUser.Contact.AccountId);
           }
           if(!isPreferredDistributorUser && this.AccountId==null){
                if(currentUser.contact.Account.PROFILED_ACCOUNT_FLAG__c==true){  
                    this.AccountId = currentUser.Contact.AccountId ;
                }                   
                else{ 
                    this.AccountId = currentUser.Contact.Account.Profiled_Account__c;
                } 
           }
           isPartnerUser = true;            
        }
        
        fieldNamesMap.put('Backup and Recovery','Backup_and_Recovery_Specialty__c');
        fieldNamesMap.put('Advanced Consolidate','Advanced_Consolidate_Specialty__c');
        fieldNamesMap.put('Governance and Archive','Governance_and_Archive_Specialty__c');
        fieldNamesMap.put('Consolidate','Consolidate_Specialty__c');
        fieldNamesMap.put('Cloud Builder Practice','Cloud_Builder_Specialty__c');
        
        
        Map<String,Schema.RecordTypeInfo> recordTypes = Account_Groupings__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        PanBlockRecTypeId = recordTypes.get('Partner Grouping - PAN Theater').getRecordTypeId();
        LogicalBlockRecTypeId = recordTypes.get('Partner Grouping - Logical Block').getRecordTypeId();
        
        fetchAccount(this.AccountId);
        
        if(objAccount.Cluster__c==null || objAccount.Specialty_Rule_Type__c==null){
              ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Velocity_Speciality_Error);
              ApexPages.addMessage(errorMessage);
              isRenderSpeciality = false;
              return;
        }
        if(isPartnerUser && currentUser.contact.Account.Partner_Type__c.contains('Distributor') 
                    && objAccount.Partner_Type__c.contains('Distribution VAR')
                    && (objAccount.Id != currentUser.contact.AccountId || (objAccount.Id != currentUser.contact.Account.Profiled_Account__c && currentUser.contact.Account.Profiled_Account__c !=null))
                    && (!isPreferredDistributorUser || !NonAPJDistributorUserProfiles.contains(userInfo.getProfileId()))){
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, System.Label.Insufficient_Access_To_VPP_Scorecards);
                    ApexPages.addMessage(errorMessage);
                    isRenderSpeciality = false;
                    return;     
        }
         
        lstSpecialty = fetchSpecialty();
        System.debug('lstSpecialty---:' + lstSpecialty);
        currentTheater = getTheaterName();
        fetchVRResults();
        
        if(lstPanVRR.size() >0){
            Map<String , Map<String, Map<String, List<Velocity_Rule_Results__c>>>>  mapGroupReqSpecialtyPANVRR = processingDataResult(lstPanVRR);        
            lstPanContainer = getDisplayResult(mapGroupReqSpecialtyPANVRR);      
            lstPanContainerSingle = getSingleDisplayResult(lstPanContainer);
        }
        if(objAccount.Account_Level__c =='LOGICAL'){
            //TargetTier = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Target_Tier__c;
        }
        
        if(objAccount.Account_Level__c =='PAN'){            
            DeployedToStatus = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Deployed_To__c;
            ComplianceStatus = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Compliance_Period_Requirments_Met__c;
        }
        System.debug('lstPanVRR :' + lstPanVRR);
        System.debug('lstPanContainer Size :' + lstPanContainer.size());
        System.debug('lstSpecialty-----:' + lstSpecialty);
        System.debug('lstPanContainer :' + lstPanContainer); 
        System.debug('lstPanContainerSingle :' + lstPanContainerSingle); 
        System.debug('setPanGroupingIds :' + setPanGroupingIds);
        System.debug('mapSpecilaitySubSpecStatus :' + mapSpecilaitySubSpecStatus);  
        System.debug('TargetTier ' + TargetTier); 
        System.debug('DeployedToStatus ' + DeployedToStatus); 
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
            strTheater ='Target Tier';  
        }else{
            strTheater ='Current Tier';
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
                                    Grouping__r.Logical_Block_Level_Grouping__r.Speciality_Type__c,
                                    Grouping__r.Logical_Block_Level_Grouping__r.Cluster__c,
                                    Grouping__r.Logical_Block_Level_Grouping__r.Deployed_To__c,
                                    Grouping__r.Logical_Block_Level_Grouping__r.Target_Tier__c,
                                    Grouping__r.Logical_Block_Level_Grouping__r.Compliance_Period_Requirments_Met__c, 
                                    Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c, 
                                    Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Cluster__c ,
                                    Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Deployed_To__c, 
                                    Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Speciality_Type__c ,
                                    Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Target_Tier__c,
                                    Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Compliance_Period_Requirments_Met__c
                                from Account 
                                where id =:accountId];
        return objAccount;                                
    }
    
    public List<String> fetchSpecialty(){
        Map<String,CustomSettingDataValueMap__c> DataValueMap =  CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c objDataValue = new CustomSettingDataValueMap__c();
        Map<String,String> mapTierDetails = new Map<String,String>();
        List<String> lstTiers = new List<String>();
        // get tier names from custom setting and set values into map
        if(DataValueMap.containsKey('PANSpecilities')){
            objDataValue = DataValueMap.get('PANSpecilities');
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
        
        Set<Id> setVRRGroupingIds = new Set<Id>();
        Set<Id> setRecordTypeIds = new Set<Id>();  
        Set<String> setSpecialty = new Set<String>();        
        List<Velocity_Rule_Results__c> lstVRR = new List<Velocity_Rule_Results__c>();
        Map<String,Schema.RecordTypeInfo> recordTypes = Velocity_Rules__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        Id SpecialtyRecordtypeId = recordTypes.get('Specialty Rule').getRecordTypeId(); 
        Id FieldRecordtypeId = recordTypes.get('Field Based Rule Type').getRecordTypeId();
        setRecordTypeIds.add(FieldRecordtypeId); 
        setRecordTypeIds.add(SpecialtyRecordtypeId); 
        System.Debug('Tier :'+ objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Target_Tier__c );
        if(objAccount != null){
            if(objAccount.Account_Level__c != null && objAccount.Account_Level__c =='PAN'){                
                if(objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Target_Tier__c != null){
                    CurrentGroupingId = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c;
                    setPanGroupingIds.add(objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c);
                    Cluster = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Cluster__c;
                    TargetTier = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Target_Tier__c;
                    LogicalBlock = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Name;
                    ComplianceStatus = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Compliance_Period_Requirments_Met__c;
                    
                    mapLogicalGrouping = new Map<Id, Account_Groupings__c>(
                                                    [Select Id, Name ,Cluster__c ,Cloud_Builder_Specialty__c ,Advanced_Consolidate_Specialty__c, Backup_and_Recovery_Specialty__c,Consolidate_Specialty__c,
                                                            Governance_and_Archive_Specialty__c,Isilon_Track_Specialty__c,Compliance_Period_Requirments_Met__c,Target_Tier__c,
                                                            Logical_Block_Level_Grouping__c, Speciality_Type__c, Local_Requirment_Set__c, 
                                                            Pan_Theater_Level_Grouping__c 
                                                    FROM Account_Groupings__c 
                                                    where Pan_Theater_Level_Grouping__c in:setPanGroupingIds OR Id =: objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c]);
                    //lstBlocks.add(objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c);
                    setSpecialty.add(objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Speciality_Type__c);
                    setVRRGroupingIds.addAll(mapLogicalGrouping.KeySet());
                    
                    lstVRR = [Select Id, AccountID__c, Current__c, Evaluation_at__c , VS_Rule_Result_Display_Name__c, Grouping__c,Grouping__r.RecordTypeid,Is_Total_Revenue__c, RequiredCount__c, Required_Value_Type__c,
                                Revenue_Amount__c, Rule_theater__c, VS_Rule_Result_Section__c, Status__c, VS_Rule_Result_Status__c, Account_Theater__c, Speciality_RuleID__r.Local_Requirment_Set__c,
                                Speciality_RuleID__c, Speciality_RuleID__r.Specilaity__c, Speciality_RuleID__r.Specialty_Rule_Type__c, Speciality_RuleID__r.BR_Sub_category__c,
                                Speciality_RuleID__r.Display_Name__c, Speciality_RuleID__r.Sort__c,Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.Tier__c , 
                                Speciality_RuleID__r.recordTypeId , Speciality_RuleID__r.Evaluation_at__c
                                FROM Velocity_Rule_Results__c 
                                WHERE  //Speciality_RuleID__r.Tier__c = :TargetTier AND
                                Grouping__c in: setPanGroupingIds AND
                                Speciality_RuleID__r.recordTypeId in: setRecordTypeIds 
                                AND Speciality_RuleID__r.Specialty_Rule_Type__c in : setSpecialty    
                                AND Speciality_RuleID__r.Evaluation_at__c ='PAN Theater Grouping Level'                                                            
                                order by Speciality_RuleID__r.Sort__c asc ];
                    setPanGroupingIds.clear();
                    setPanGroupingIds.add(objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c + 
                        objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Speciality_Type__c);            
                    System.Debug('lstVRR : ' + lstVRR);
                    System.Debug('lstVRR Size: ' + lstVRR.size());
                }else if(objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Target_Tier__c == null){
                    CurrentGroupingId = objAccount.Grouping__r.Logical_Block_Level_Grouping__c;
                    //setPanGroupingIds.add(objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c);
                    Cluster = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Cluster__c;
                    LogicalBlock = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Name;
                    DeployedToStatus = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Deployed_To__c;
                    ComplianceStatus = objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Compliance_Period_Requirments_Met__c;
                    System.debug('Grouping Id ' + objAccount.Grouping__r.Logical_Block_Level_Grouping__c);
                    System.debug('Cluster ' + Cluster);
                    System.debug('setPanGroupingIds ' + setPanGroupingIds);
                    System.debug('TargetTier ' + TargetTier); 
                    System.debug('DeployedToStatus ' + DeployedToStatus); 
                    List<Account_Groupings__c> lstLogicalGrouping = new List<Account_Groupings__c>();          
                    lstLogicalGrouping = [Select Id, Name , Cluster__c,Speciality_Type__c, Cloud_Builder_Specialty__c , Advanced_Consolidate_Specialty__c, Backup_and_Recovery_Specialty__c,Consolidate_Specialty__c,
                                                            Governance_and_Archive_Specialty__c,Isilon_Track_Specialty__c,Compliance_Period_Requirments_Met__c,Target_Tier__c,
                                                            Logical_Block_Level_Grouping__c, Local_Requirment_Set__c, Pan_Theater_Level_Grouping__c 
                                                    FROM Account_Groupings__c 
                                                    where Pan_Theater_Level_Grouping__c =:objAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c order by Name];
                    setPanGroupingIds.clear();
                    for(Account_Groupings__c objGrouping :lstLogicalGrouping){
                        if(objGrouping.Speciality_Type__c != null ){
                            setSpecialty.add(objGrouping.Speciality_Type__c);
                            setPanGroupingIds.add(objGrouping.Id + objGrouping.Speciality_Type__c);
                        } 
                        System.Debug('objGrouping name : ' + objGrouping.Name);
                        
                        mapLogicalGrouping.put(objGrouping.Id, objGrouping);
                    }
                    //setSpecialty.add(Cluster);
                    setVRRGroupingIds.addAll(mapLogicalGrouping.KeySet());
                    
                    lstVRR = [Select Id, AccountID__c, Current__c,Evaluation_at__c , VS_Rule_Result_Display_Name__c, Grouping__c,Grouping__r.RecordTypeid,Is_Total_Revenue__c, RequiredCount__c, Required_Value_Type__c,
                                Revenue_Amount__c, Rule_theater__c, VS_Rule_Result_Section__c, Status__c, VS_Rule_Result_Status__c, Account_Theater__c, Speciality_RuleID__r.Local_Requirment_Set__c,
                                Speciality_RuleID__c, Speciality_RuleID__r.Specilaity__c, Speciality_RuleID__r.Specialty_Rule_Type__c, Speciality_RuleID__r.BR_Sub_category__c,
                                Speciality_RuleID__r.Display_Name__c, Speciality_RuleID__r.Sort__c,Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.Tier__c , 
                                Speciality_RuleID__r.recordTypeId , Speciality_RuleID__r.Evaluation_at__c
                                FROM Velocity_Rule_Results__c 
                                WHERE 
                                Grouping__c in: setVRRGroupingIds 
                                AND Speciality_RuleID__r.recordTypeId in: setRecordTypeIds 
                                AND Speciality_RuleID__r.Specialty_Rule_Type__c in : setSpecialty    
                                AND Speciality_RuleID__r.Evaluation_at__c ='Logical Block Grouping Level'
                                   
                                order by Speciality_RuleID__r.Sort__c asc ];
                    System.Debug('Logical lstVRR : ' + lstVRR);
                    System.Debug('Logical lstVRR Size: ' + lstVRR.size());
                }
                if(lstVRR != null && lstVRR.size() >0){
                    lstPanVRR = lstVRR;                          
                }                
            }
        }
        //return lstVRR;
    }
    
    private Map<String , Map<String, Map<String, List<Velocity_Rule_Results__c>>>> processingDataResult(List<Velocity_Rule_Results__c> lstVelocityRulesResult){        
        Map<String , Map<String, Map<String, List<Velocity_Rule_Results__c>>>> mapSpecReqTierVRR = new Map<String, Map<String, Map<String, List<Velocity_Rule_Results__c>>>>();
        Map<String, Map<String, List<Velocity_Rule_Results__c>>> mapReqBlockVRR = new Map<String, Map<String, List<Velocity_Rule_Results__c>>>();
        Map<String, List<Velocity_Rule_Results__c>> mapBlockVRR = new Map<String, List<Velocity_Rule_Results__c>>();
        Map<String, Set<String>> mapGroupingRequrementsForOrderTemp = new Map<String, Set<String>>();
        
        
        Map<String , Map<String, Map<String, List<Velocity_Rule_Results__c>>>> mapSpecReqTierVRRSub = new Map<String, Map<String, Map<String, List<Velocity_Rule_Results__c>>>>();
        Map<String, Map<String, List<Velocity_Rule_Results__c>>> mapReqBlockVRRSub = new Map<String, Map<String, List<Velocity_Rule_Results__c>>>();
        Map<String, List<Velocity_Rule_Results__c>> mapBlockVRRSub = new Map<String, List<Velocity_Rule_Results__c>>();
        mapSpecSubSpecReqTierVRRSub.clear();
        if(lstVelocityRulesResult != null && lstVelocityRulesResult.size() >0){         
            for(Velocity_Rule_Results__c scoreObj: lstVelocityRulesResult) {
                System.Debug('scoreObj.Speciality_RuleID__r.Specilaity__c : ' + scoreObj.Speciality_RuleID__r.Specilaity__c);                
                if(mapSpecReqTierVRR.containsKey(scoreObj.Speciality_RuleID__r.Specilaity__c)){
                    mapReqBlockVRR = mapSpecReqTierVRR.get(scoreObj.Speciality_RuleID__r.Specilaity__c);
                }else{
                    mapSpecReqTierVRR.put(scoreObj.Speciality_RuleID__r.Specilaity__c, new Map<String,Map<String, List<Velocity_Rule_Results__c>>>());
                    mapReqBlockVRR = mapSpecReqTierVRR.get(scoreObj.Speciality_RuleID__r.Specilaity__c);
                }           
                if(mapReqBlockVRR.containsKey(scoreObj.Speciality_RuleID__r.Display_Name__c)){
                    mapBlockVRR = mapReqBlockVRR.get(scoreObj.Speciality_RuleID__r.Display_Name__c);                 
                }else{                              
                    mapReqBlockVRR.put(scoreObj.Speciality_RuleID__r.Display_Name__c, new Map<String, List<Velocity_Rule_Results__c>>());
                    mapBlockVRR = mapReqBlockVRR.get(scoreObj.Speciality_RuleID__r.Display_Name__c);
                }           
                if(!mapBlockVRR.containsKey(scoreObj.Grouping__c+ scoreObj.Speciality_RuleID__r.Specialty_Rule_Type__c)){                        
                    mapBlockVRR.put(scoreObj.Grouping__c +  scoreObj.Speciality_RuleID__r.Specialty_Rule_Type__c, new List<Velocity_Rule_Results__c>());
                    mapBlockVRR.get(scoreObj.Grouping__c + scoreObj.Speciality_RuleID__r.Specialty_Rule_Type__c).add(scoreObj);                    
                }
                if(scoreObj.Speciality_RuleID__r.BR_Sub_category__c!=null){
                    if(mapSpecSubSpecReqTierVRRSub.containsKey(scoreObj.Speciality_RuleID__r.Specilaity__c)){
                        mapSpecReqTierVRRSub = mapSpecSubSpecReqTierVRRSub.get(scoreObj.Speciality_RuleID__r.Specilaity__c);
                    }else{
                        mapSpecSubSpecReqTierVRRSub.put(scoreObj.Speciality_RuleID__r.Specilaity__c, new Map<String, Map<String,Map<String, List<Velocity_Rule_Results__c>>>>());
                        mapSpecReqTierVRRSub = mapSpecSubSpecReqTierVRRSub.get(scoreObj.Speciality_RuleID__r.Specilaity__c);
                    }
                    if(mapSpecReqTierVRRSub.containsKey( scoreObj.Speciality_RuleID__r.BR_Sub_category__c)){
                        mapReqBlockVRRSub = mapSpecReqTierVRRSub.get( scoreObj.Speciality_RuleID__r.BR_Sub_category__c);
                    }else{
                        mapSpecReqTierVRRSub.put( scoreObj.Speciality_RuleID__r.BR_Sub_category__c, new Map<String,Map<String, List<Velocity_Rule_Results__c>>>());
                        mapReqBlockVRRSub = mapSpecReqTierVRRSub.get(scoreObj.Speciality_RuleID__r.BR_Sub_category__c);
                    }           
                    if(mapReqBlockVRRSub.containsKey(scoreObj.Speciality_RuleID__r.Display_Name__c)){
                        mapBlockVRRSub = mapReqBlockVRRSub.get(scoreObj.Speciality_RuleID__r.Display_Name__c);                 
                    }else{                              
                        mapReqBlockVRRSub.put(scoreObj.Speciality_RuleID__r.Display_Name__c, new Map<String, List<Velocity_Rule_Results__c>>());
                        mapBlockVRRSub = mapReqBlockVRRSub.get(scoreObj.Speciality_RuleID__r.Display_Name__c);
                    }           
                    if(!mapBlockVRRSub.containsKey(scoreObj.Grouping__c+ scoreObj.Speciality_RuleID__r.Specialty_Rule_Type__c)){                        
                        mapBlockVRRSub.put(scoreObj.Grouping__c +  scoreObj.Speciality_RuleID__r.Specialty_Rule_Type__c, new List<Velocity_Rule_Results__c>());
                        mapBlockVRRSub.get(scoreObj.Grouping__c + scoreObj.Speciality_RuleID__r.Specialty_Rule_Type__c).add(scoreObj);                    
                    }
                    if(mapSpecilaitySubSpec.containsKey(scoreObj.Speciality_RuleID__r.Specilaity__c)){
                        mapSpecilaitySubSpec.get(scoreObj.Speciality_RuleID__r.Specilaity__c).add(scoreObj.Speciality_RuleID__r.BR_Sub_category__c);                 
                    }else{                              
                        mapSpecilaitySubSpec.put(scoreObj.Speciality_RuleID__r.Specilaity__c, new List<String>());
                        mapSpecilaitySubSpec.get(scoreObj.Speciality_RuleID__r.Specilaity__c).add(scoreObj.Speciality_RuleID__r.BR_Sub_category__c);
                    }
                    //Status Holders
                    if(scoreObj.Status__c =='Not Achieved'){
                        if(!mapSpecilaitySubSpecStatus.containsKey(scoreObj.Speciality_RuleID__r.Specilaity__c + scoreObj.Speciality_RuleID__r.BR_Sub_category__c+ scoreObj.Grouping__c)){
                            mapSpecilaitySubSpecStatus.put(scoreObj.Speciality_RuleID__r.Specilaity__c + scoreObj.Speciality_RuleID__r.BR_Sub_category__c + scoreObj.Grouping__c, scoreObj.Status__c);
                        }
                    }
                }  
                
                if(scoreObj.Speciality_RuleID__r.Sort__c != null && scoreObj.Speciality_RuleID__c != null && scoreObj.Speciality_RuleID__r.Display_Name__c != null){
                    
                    String strSpecialtyKey = scoreObj.Speciality_RuleID__r.Specilaity__c;
                    if(scoreObj.Speciality_RuleID__r.BR_Sub_category__c!=null){
                        strSpecialtyKey = scoreObj.Speciality_RuleID__r.Specilaity__c + scoreObj.Speciality_RuleID__r.BR_Sub_category__c;
                    }
                    if(mapGroupingRequrementsForOrder.containsKey(strSpecialtyKey ) && mapGroupingRequrementsForOrderTemp.containsKey(strSpecialtyKey)){
                        if(!mapGroupingRequrementsForOrderTemp.get(strSpecialtyKey).contains(scoreObj.Speciality_RuleID__r.Display_Name__c)){
                            mapGroupingRequrementsForOrder.get(strSpecialtyKey ).add(scoreObj.Speciality_RuleID__r.Display_Name__c); 
                            mapGroupingRequrementsForOrderTemp.get(strSpecialtyKey).add(scoreObj.Speciality_RuleID__r.Display_Name__c); 
                        }                           
                    }else{                              
                        mapGroupingRequrementsForOrder.put(strSpecialtyKey , new List<String>());
                        mapGroupingRequrementsForOrder.get(strSpecialtyKey ).add(scoreObj.Speciality_RuleID__r.Display_Name__c); 
                        mapGroupingRequrementsForOrderTemp.put(strSpecialtyKey , new Set<String>());
                        mapGroupingRequrementsForOrderTemp.get(strSpecialtyKey ).add(scoreObj.Speciality_RuleID__r.Display_Name__c);                        
                    }
                }
                if((!mapSpecilaityAndResults.containsKey(scoreObj.Grouping__c+scoreObj.Speciality_RuleID__r.Specilaity__c + scoreObj.Speciality_RuleID__r.Specialty_Rule_Type__c ))
                    && scoreObj.Status__c=='Not Achieved'){
                    mapSpecilaityAndResults.put(scoreObj.Grouping__c + scoreObj.Speciality_RuleID__r.Specilaity__c + scoreObj.Speciality_RuleID__r.Specialty_Rule_Type__c , scoreObj.Status__c);
                }
				if(scoreObj.Status__c=='Not Achieved'){
					if(!mapSpecilaitySpecStatus.containsKey(scoreObj.Speciality_RuleID__r.Specilaity__c + scoreObj.Grouping__c)){
                        mapSpecilaitySpecStatus.put(scoreObj.Speciality_RuleID__r.Specilaity__c + scoreObj.Grouping__c, scoreObj.Status__c);
					}
				}
            }
            System.Debug('mapSpecReqTierVRR : ' + mapSpecReqTierVRR); 
            System.Debug('mapSpecReqTierVRR Key Set : ' + mapSpecReqTierVRR.keySet()); 
			System.Debug('mapSpecilaitySpecStatus Key Set : ' + mapSpecilaitySpecStatus.keySet());			
			
                
        }        
        return mapSpecReqTierVRR;
    }
    
    public List<PRM_PAN_VPP_PanLogicalDataHelper> getDisplayResult(Map<String , Map<String, Map<String, List<Velocity_Rule_Results__c>>>> mapGroupReqTierVRR){
        List<PRM_PAN_VPP_PanLogicalDataHelper> lstTempContainer = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
        PRM_PAN_VPP_PanLogicalDataHelper objPanLogicalDC = new PRM_PAN_VPP_PanLogicalDataHelper();
        List<PRM_PAN_VPP_RequirementDataContainer> lstRequirementResults = new List<PRM_PAN_VPP_RequirementDataContainer>();
        PRM_PAN_VPP_RequirementDataContainer objReqDC = new PRM_PAN_VPP_RequirementDataContainer();
        PRM_PAN_VPP_BlockResultDataContainer objBlock = new PRM_PAN_VPP_BlockResultDataContainer();
        PRM_PAN_VPP_BlockResultDataContainer objActualBlock = new PRM_PAN_VPP_BlockResultDataContainer();
        List<PRM_PAN_VPP_BlockResultDataContainer> lstBlockDC = new List<PRM_PAN_VPP_BlockResultDataContainer>();
        List<PRM_PAN_VPP_BlockResultDataContainer> lstTempBlockDC = new List<PRM_PAN_VPP_BlockResultDataContainer>();
        
         for(String srtBlock : setPanGroupingIds){
            objBlock = new PRM_PAN_VPP_BlockResultDataContainer();  
            System.Debug('srtBlock : ' + srtBlock);            
            objBlock.BlockName = '';
            objBlock.isVelocityResult = false;
            lstTempBlockDC.add(objBlock);
         }
        //lstSpecialty = fetchSpecialty();
        System.Debug('lstSpecialtyOutside--> ' + lstSpecialty);
        System.Debug('mapGroupReqTierVRROutside--> ' + mapGroupReqTierVRR.keySet());
        for(String strSpecialty :  lstSpecialty){
            System.Debug('strSpecialty Outside: ' + strSpecialty);
            System.Debug('mapGroupReqTierVRR Outside: ' + mapGroupReqTierVRR.containsKey(strSpecialty));
            if(mapGroupReqTierVRR.containsKey(strSpecialty)){
                objPanLogicalDC = new PRM_PAN_VPP_PanLogicalDataHelper();              
                objPanLogicalDC.Level = strSpecialty;
                objPanLogicalDC.CurrentTargetTier = '';     
                objPanLogicalDC.CurrentLogicalBlock  = LogicalBlock;
                objPanLogicalDC.CurrentTheater = currentTheater;
                lstRequirementResults = new List<PRM_PAN_VPP_RequirementDataContainer>();
                System.Debug('strSpecialty : ' + strSpecialty);
                if(mapSpecSubSpecReqTierVRRSub.containsKey(strSpecialty)){                                          
                    for(String strSubSpec: mapSpecSubSpecReqTierVRRSub.get(strSpecialty).KeySet()){
                        objReqDC = new PRM_PAN_VPP_RequirementDataContainer();
                        objReqDC.IsHeader  = true;  
                        objReqDC.RequirementName =   strSubSpec;
                        objReqDC.BlockResult= lstTempBlockDC;                                             
                        lstBlockDC = new List<PRM_PAN_VPP_BlockResultDataContainer>(); 
                        lstRequirementResults.add(objReqDC);
                        for(String strReqObj : mapGroupingRequrementsForOrder.get(strSpecialty + strSubSpec)){
                            //for(String StrReqObj : mapSpecSubSpecReqTierVRRSub.get(strSpecialty).get(strSubSpec).keySet()){
                            if(mapSpecSubSpecReqTierVRRSub.get(strSpecialty).get(strSubSpec).keySet().contains(strReqObj)){
                                System.Debug('strReqObj : ' + strReqObj);
                                objReqDC = new PRM_PAN_VPP_RequirementDataContainer();
                                objReqDC.RequirementName  = strReqObj;  
                                objReqDC.IsHeader  = false;                          
                                lstBlockDC = new List<PRM_PAN_VPP_BlockResultDataContainer>();                              
                                                    
                                for(String srtBlock : setPanGroupingIds){
                                    objBlock = new PRM_PAN_VPP_BlockResultDataContainer();  
                                    System.Debug('srtBlock : ' + srtBlock);
                                    //for(String srtBlock : mapGroupReqTierVRR.get(strSpecialty).get(strReqObj).KeySet()){                          
                                    String strGrouping = srtBlock.substring(0,18);                  
                                    //objBlock.BlockName = mapLogicalGrouping.get(strGrouping).Name;
                                    objBlock.BlockName = srtBlock;
                                    objBlock.isVelocityResult = true; 
                                    System.Debug('strGrouping : ' + strGrouping);
                                    System.Debug('mapGroupReqTierVRR.get(strSpecialty).get(strReqObj). : ' + mapSpecSubSpecReqTierVRRSub.get(strSpecialty).get(strSubSpec).get(strReqObj).keySet());
                                    System.Debug('mapGroupReqTierVRR.get(strSpecialty).get(strReqObj).ContainsKey(srtBlock) : ' + mapSpecSubSpecReqTierVRRSub.get(strSpecialty).get(strSubSpec).get(strReqObj).ContainsKey(srtBlock));
                                    if(mapSpecSubSpecReqTierVRRSub.get(strSpecialty).get(strSubSpec).get(StrReqObj).ContainsKey(srtBlock)){
                                        objBlock.Result = mapSpecSubSpecReqTierVRRSub.get(strSpecialty).get(strSubSpec).get(strReqObj).get(srtBlock);
                                        System.Debug('objBlock.Result : ' + objBlock.Result.size());
                                        System.Debug('objBlock.Result : ' + objBlock.Result);
                                    }else{
                                        List<Velocity_Rule_Results__c> lstVRRss = new List<Velocity_Rule_Results__c>();
                                        Velocity_Rule_Results__c objVRR = new Velocity_Rule_Results__c();
                                        objVRR.Current__c = '';
                                        lstVRRss.add(objVRR);
                                        objBlock.Result = lstVRRss;
                                    }                 
                                    lstBlockDC.add(objBlock);                               
                                }                          
                                objReqDC.BlockResult = lstBlockDC;
                                lstRequirementResults.add(objReqDC);
                            }
                        }
                        /* */
                        // Acheive Status details
                        objReqDC = new PRM_PAN_VPP_RequirementDataContainer();
                        objReqDC.RequirementName = strSubSpec +' Status';
                        objReqDC.IsHeader  = false; 
                        lstBlockDC = new List<PRM_PAN_VPP_BlockResultDataContainer>();
                        
                        for(String srtBlock : setPanGroupingIds){                    
                            objBlock = new PRM_PAN_VPP_BlockResultDataContainer();
                            objBlock.Status ='Achieved';
                            //String strGrouping = srtBlock.split('||')[1];
                            String strGrouping = srtBlock.substring(0,18);  
                            objBlock.BlockName = mapLogicalGrouping.get(strGrouping).Name;
                            System.Debug('strGrouping : ' + strGrouping);                           
                            if(mapSpecilaitySubSpecStatus.ContainsKey(strSpecialty+strSubSpec+strGrouping)){
                                objBlock.Status = mapSpecilaitySubSpecStatus.get(strSpecialty+strSubSpec+strGrouping);
                            } 
                            
                            
                            List<Velocity_Rule_Results__c> lstVRRss = new List<Velocity_Rule_Results__c>();
                            Velocity_Rule_Results__c objVRR = new Velocity_Rule_Results__c();
                            objVRR.Current__c = '';
                            lstVRRss.add(objVRR);
                            objBlock.Result = lstVRRss;                                 
                            objBlock.isVelocityResult = false;
                            lstBlockDC.add(objBlock);                    
                        }
                        objReqDC.BlockResult = lstBlockDC;  
                        lstRequirementResults.add(objReqDC);
                        
                    }                   
                }else{
                    //for(String strReqObj : mapGroupReqTierVRR.get(strSpecialty).KeySet()){
                    for(String strReqObj : mapGroupingRequrementsForOrder.get(strSpecialty)){                 
                        if(mapGroupReqTierVRR.get(strSpecialty).KeySet().contains(strReqObj)){
                            System.Debug('strReqObj : ' + strReqObj);
                            objReqDC = new PRM_PAN_VPP_RequirementDataContainer();
                            objReqDC.RequirementName  = strReqObj;  
                            objReqDC.IsHeader  = false;                           
                            lstBlockDC = new List<PRM_PAN_VPP_BlockResultDataContainer>();                              
                                                
                            for(String srtBlock : setPanGroupingIds){
                                objBlock = new PRM_PAN_VPP_BlockResultDataContainer();  
                                System.Debug('srtBlock : ' + srtBlock);
                            //for(String srtBlock : mapGroupReqTierVRR.get(strSpecialty).get(strReqObj).KeySet()){                          
                                String strGrouping = srtBlock.substring(0,18);                  
                                //objBlock.BlockName = mapLogicalGrouping.get(strGrouping).Name;
                                objBlock.BlockName = srtBlock;
                                objBlock.isVelocityResult = true; 
                                System.Debug('strGrouping : ' + strGrouping);
                                System.Debug('mapGroupReqTierVRR.get(strSpecialty).get(strReqObj). : ' + mapGroupReqTierVRR.get(strSpecialty).get(strReqObj).keySet());
                                System.Debug('mapGroupReqTierVRR.get(strSpecialty).get(strReqObj).ContainsKey(srtBlock) : ' + mapGroupReqTierVRR.get(strSpecialty).get(strReqObj).ContainsKey(srtBlock));
                                if(mapGroupReqTierVRR.get(strSpecialty).get(strReqObj).ContainsKey(srtBlock)){
                                    objBlock.Result = mapGroupReqTierVRR.get(strSpecialty).get(strReqObj).get(srtBlock);
                                    System.Debug('objBlock.Result : ' + objBlock.Result.size());
                                    System.Debug('objBlock.Result : ' + objBlock.Result);
                                }else{
                                    List<Velocity_Rule_Results__c> lstVRRss = new List<Velocity_Rule_Results__c>();
                                    Velocity_Rule_Results__c objVRR = new Velocity_Rule_Results__c();
                                    objVRR.Current__c = '';
                                    lstVRRss.add(objVRR);
                                    objBlock.Result = lstVRRss;
                                }                 
                                lstBlockDC.add(objBlock);                               
                            }                          
                            objReqDC.BlockResult = lstBlockDC;
                            lstRequirementResults.add(objReqDC);
                        }
                    }
                    
                }
                
                
                // Deployment Status details
                objReqDC = new PRM_PAN_VPP_RequirementDataContainer();
                objReqDC.RequirementName = 'Deployment Status';
                objReqDC.IsHeader  = false; 
                lstBlockDC = new List<PRM_PAN_VPP_BlockResultDataContainer>();
                
                for(String srtBlock : setPanGroupingIds){                    
                    objBlock = new PRM_PAN_VPP_BlockResultDataContainer();
                    objBlock.Status ='Not Deployed';
                    //String strGrouping = srtBlock.split('||')[1];
                    String strGrouping = srtBlock.substring(0,18);  
                    objBlock.BlockName = mapLogicalGrouping.get(strGrouping).Name;
                    System.Debug('strGrouping : ' + strGrouping);
                    System.Debug('strGrouping : ' + fieldNamesMap.get(strGrouping));                                
                    System.Debug('ContainsKey : ' + fieldNamesMap.get(strSpecialty));
                    System.Debug('ContainsKey : ' + mapLogicalGrouping.get(strGrouping).get(fieldNamesMap.get(strSpecialty)));
                    if(mapLogicalGrouping.ContainsKey(strGrouping)){
                        objBlock.Status = (String) mapLogicalGrouping.get(strGrouping).get(fieldNamesMap.get(strSpecialty));
                    }   
                    
                    List<Velocity_Rule_Results__c> lstVRRss = new List<Velocity_Rule_Results__c>();
                    Velocity_Rule_Results__c objVRR = new Velocity_Rule_Results__c();
                    objVRR.Current__c = '';
                    lstVRRss.add(objVRR);
                    objBlock.Result = lstVRRss;                                 
                    objBlock.isVelocityResult = false;
                    lstBlockDC.add(objBlock);                    
                }
                objReqDC.BlockResult = lstBlockDC;  
                lstRequirementResults.add(objReqDC);
                
                objReqDC = new PRM_PAN_VPP_RequirementDataContainer();
                objReqDC.RequirementName = 'Reqs Met?';
                objReqDC.IsHeader  = false; 
                lstBlockDC = new List<PRM_PAN_VPP_BlockResultDataContainer>();
                // Compliance Met Status details
                for(String srtBlock : setPanGroupingIds){
                                        
                    objBlock = new PRM_PAN_VPP_BlockResultDataContainer();
                    objBlock.Status ='Yes';
                    String strGrouping = srtBlock.substring(0,18);
                    objBlock.BlockName = mapLogicalGrouping.get(strGrouping).Name;                          
                    System.Debug('ContainsKey : ' + fieldNamesMap.get(strSpecialty));
                    /*
                    if(mapLogicalGrouping.ContainsKey(strGrouping)){
                        objBlock.Status = (String) mapLogicalGrouping.get(strGrouping).Compliance_Period_Requirments_Met__c;
                    }
                    */
                    System.Debug('Reqs Met? mapLogicalGrouping.ContainsKey(strGrouping) : ' + mapLogicalGrouping.ContainsKey(strGrouping));
                    System.Debug('mapSpecilaitySpecStatus : ' + mapSpecilaitySpecStatus.keySet());
                    System.Debug('strSpecialty : ' + strSpecialty);
                    System.Debug('strGrouping : ' + strGrouping);
                    if(mapSpecilaitySpecStatus.containsKey(strSpecialty + strGrouping )){
                    	objBlock.Status = 'No';
                    }
                    
                    List<Velocity_Rule_Results__c> lstVRRss = new List<Velocity_Rule_Results__c>();
                    Velocity_Rule_Results__c objVRR = new Velocity_Rule_Results__c();
                    objVRR.Current__c = '';
                    lstVRRss.add(objVRR);
                    objBlock.Result = lstVRRss;
                    
                    objBlock.isVelocityResult = false;
                    lstBlockDC.add(objBlock);
                }                                                  
                                                                                         
                
                objReqDC.BlockResult = lstBlockDC;  
                lstRequirementResults.add(objReqDC);                         
                
                objPanLogicalDC.lstRequirementResults = lstRequirementResults;
                
                lstTempContainer.add(objPanLogicalDC);
            }
        }          
        return lstTempContainer;
    }    

    private List<PRM_PAN_VPP_PanLogicalDataHelper> getSingleDisplayResult(List<PRM_PAN_VPP_PanLogicalDataHelper> lstPanLogicalContainer){ 
        List<PRM_PAN_VPP_PanLogicalDataHelper> lstTempContainerSingle = new List<PRM_PAN_VPP_PanLogicalDataHelper>();
        PRM_PAN_VPP_PanLogicalDataHelper objTemp = new PRM_PAN_VPP_PanLogicalDataHelper();
        List<PRM_PAN_VPP_RequirementDataContainer> lstTemp = new List<PRM_PAN_VPP_RequirementDataContainer>();
        PRM_PAN_VPP_RequirementDataContainer objRADTemp = new PRM_PAN_VPP_RequirementDataContainer();
        List<PRM_PAN_VPP_BlockResultDataContainer> lstTempBRC = new List<PRM_PAN_VPP_BlockResultDataContainer>();
        PRM_PAN_VPP_BlockResultDataContainer objtempBRC = new PRM_PAN_VPP_BlockResultDataContainer();
        if(lstPanLogicalContainer.size() >0){
            
            for(PRM_PAN_VPP_PanLogicalDataHelper objSDC: lstPanLogicalContainer){
                objTemp = new PRM_PAN_VPP_PanLogicalDataHelper();
                lstTemp = new List<PRM_PAN_VPP_RequirementDataContainer>();
                objTemp.Level = objSDC.Level;
                objTemp.CurrentTargetTier = objSDC.CurrentTargetTier;
                objTemp.CurrentLogicalBlock = objSDC.CurrentLogicalBlock;
                objTemp.CurrentTheater = objSDC.CurrentTheater;
                if(objSDC.lstRequirementResults != null){                               
                    for(PRM_PAN_VPP_RequirementDataContainer objRAD:objSDC.lstRequirementResults){
                        objRADTemp = new PRM_PAN_VPP_RequirementDataContainer();
                        objRADTemp.RequirementName = objRAD.RequirementName;
                        lstTempBRC = new List<PRM_PAN_VPP_BlockResultDataContainer>();
                        //if(objRAD.BlockResult != null){
                            for(String objBRC: setPanGroupingIds){
                                objtempBRC = new PRM_PAN_VPP_BlockResultDataContainer();
                                String strGrouping = objBRC.substring(0,18);
                                objtempBRC.BlockName = mapLogicalGrouping.get(strGrouping).Name;                                
                                //objtempBRC.BlockName = 'Name';
                                
                                List<Velocity_Rule_Results__c> lstVRRss = new List<Velocity_Rule_Results__c>();
                                Velocity_Rule_Results__c objVRR = new Velocity_Rule_Results__c();
                                objVRR.Current__c = '';
                                lstVRRss.add(objVRR);
                                objtempBRC.Result = lstVRRss;
                                lstTempBRC.add(objtempBRC);                     
                            }
                        //}
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
    
    
    /* @Method <cancelUpdates(): This method is used to cancel the Speciality status updates of
                             associated Profiled Account from UI.>
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