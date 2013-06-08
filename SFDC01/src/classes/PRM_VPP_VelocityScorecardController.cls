/*=========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  03/01/2011    Anand Sharma                       
                                                   
 |  22-March-2011 Prasad K                 2585    Removed the logic of merge cell and added to controller.                                                
                                               
 |  23/03/2011    Anand Sharma                     Quick fix for EMEA SSCP Velocity Tier Type
                                                   Added check for EMEA SSCP fix on 23-Mar-2011 
                                                   
 |  25/03/2011    Anil Sure                2513    Have an account with tier popoulated, and both cluster and Specialty NOT populated -
                                                   Ensure you see the messages on both the scorecard and the specialties table 

 |  29/04/2011    Anand Sharma             2769     Fixed issue change value from "SSCP to Signature Solution Center" 
                                                    And "Signature Solution Center" to "SSCP" issue.    
 |                                                  Added condition into updateProfileAccount method at line #802 
                                                    if(AccountRecord.Velocity_Solution_Provider_Tier__c=='SSCP' && 
 |                                                     TiersName=='Signature Solution Center'){
                                                       AccountRecord.put('Velocity_Solution_Provider_Tier__c','SSCP'); 
 | 20/7/2012     Anirudh                  197468     Updated Code to set Visibility of Scorecard Tables for Distributor.   
 
 | 29/04/2011    Anand Sharma                       updated according revenue hide  
 | 16/08/2012    Anand Sharma                       updated to process country level rule only     
 | 16/04/2013    Krishna Pydavula       223956      Addded Merge logic for Affiliate Tier                                                                                                      
 +==========================================================================================================*/
public class PRM_VPP_VelocityScorecardController {
    
    /* Hold Properties */ 
    public String TiersName {get; set;}  
    public String ProcessingTierName {get; set;} 
    public String RequirementName {get; set;}
    public String ScorecardHelpText {get; set;}
    public List<PRM_BucketNameDataContainer> lstBucketNameData {get; set;}
    public List<Velocity_Rule_Results__c> SpecialityRulesResult {get; set;}
    public String ComplianceRequirementStatus {get; set;}
    public List<String> lstCustomTierValues {get; set;}    
    public ID profileAccountId;
    public Id SpecilalityRecordtypeId;
    public String ClusterValue;
    public Account AccountRecord  {get; set;}
    public String SignatureSSCP {get; set;}
    public Boolean isRenderScorecard {get; set;}
    public Boolean isPartnerUser {get; set;} 
    public Boolean isShowBotton {get; set;}
    public Boolean isRevenueVisible{get; set;}
    
    /* Hold Variables */
    Map<String,Map<String, Map<String, Velocity_Rule_Results__c>>> mapBucketDisplaynameTierValues = new Map<String,Map<String, Map<String, Velocity_Rule_Results__c>>>();
    Map<String,Velocity_Rule_Results__c> mapTotalTierRecord = new Map<String, Velocity_Rule_Results__c>();
    Map<String, List<Velocity_Rule_Results__c>> mapBucketVelocityProgram = new Map<String, List<Velocity_Rule_Results__c>>();
    Map<String, Velocity_Rule_Results__c> mapVelocityProgramTiers = new Map<String, Velocity_Rule_Results__c>();
    Map<String, List<Velocity_Rule_Results__c>> mapRevenueTiers = new Map<String, List<Velocity_Rule_Results__c>>();
    Map<String,CustomSettingDataValueMap__c> DataValueMap = new Map<String,CustomSettingDataValueMap__c>();
    Map<String,String> mapTierDetails = new Map<String,String>();
    List<String> lstCustomLabelTierValues = new List<String>();
    Decimal requiredCount=0;   
    String strTierNameDetails ='';
    set <String> TotalRevenueTierNameSet = new set <String>();
    //constructor
    public PRM_VPP_VelocityScorecardController (){
         //fetch custom setting values
        DataValueMap = CustomSettingDataValueMap__c.getAll(); 
        CustomSettingDataValueMap__c objDataValue = DataValueMap.get('PRMVPPEMEASignatureValue');
        CustomSettingDataValueMap__c objDistributorValue = DataValueMap.get('PRMVPPDistributorValue');
        string DistributorUserProfiles = DataValueMap.get('Distributor Partner Users').DataValue__c;
        string NonAPJDistributorUserProfiles = DataValueMap.get('NonAPJ Distributor Users').DataValue__c;
        
        // fetch account id 
        profileAccountId = ApexPages.currentPage().getParameters().get('id');
        System.debug('profileAccountId-->'+profileAccountId);
        
        //set isPartnerUser and ShowButton flag false.
        isPartnerUser = false;
        isShowBotton = false;
        isRevenueVisible = true;
        isRenderScorecard = true;
        ComplianceRequirementStatus = 'No';
        ScorecardHelpText = System.Label.PRM_Scorecard_HelpText;
        
        //initailize variables 
        lstBucketNameData = new List<PRM_BucketNameDataContainer>(); 
        lstCustomTierValues = new List<String>();
        boolean isPreferredDistributorUser = false;
        
        // get profiled account Id from partner user contact                    
        User currentUser = [Select u.ContactId, u.Contact.AccountId,contact.Account.PROFILED_ACCOUNT_FLAG__c,
                                contact.Account.Profiled_Account__c,u.Velocity_Access__c, u.Co_Op_Access__c,
                                contact.Account.Partner_Type__c 
                                from User u 
                                where id=:userinfo.getUserId()];                             
                                
            //Check for partner user, and set isPartnerUser and ShowButton flag as true
        if(userinfo.getUserType() == 'PowerPartner'){                   
           System.debug('currentUser Account Id-->'+currentUser.Contact.AccountId); 
           if(DistributorUserProfiles.contains(userInfo.getProfileId())) {
              System.Debug('UserProfileId' +userinfo.getProfileId());
              isRevenueVisible = false;
           }
           if(profileAccountId !=null && profileAccountId !=currentUser.Contact.AccountId){
             isPreferredDistributorUser = preferredDistributorCheck(profileAccountId,currentUser.Contact.AccountId);
           }
           
           //if account is profiled account then get that account id else take its profiled account Id
           if(!isPreferredDistributorUser &&  profileAccountId==null){
                if(currentUser.contact.Account.PROFILED_ACCOUNT_FLAG__c==true){  
                    this.profileAccountId = currentUser.Contact.AccountId ;
                }                   
                else{ 
                    this.profileAccountId = currentUser.Contact.Account.Profiled_Account__c;
                }
           }  
            isPartnerUser = true;  
        }else{
            //check for velocity access for user 
            if(currentUser.Velocity_Access__c){
                isShowBotton = true;
            }
        }
           
        //fetch record type id for Tier rule speciality
        Map<String,Schema.RecordTypeInfo> recordTypes = Velocity_Rules__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        specilalityRecordtypeId = recordTypes.get('Tier Rule').getRecordTypeId();
        System.debug('specilalityRecordtypeId-->'+specilalityRecordtypeId);
        
        
        
        if(objDataValue != null){
            SignatureSSCP = objDataValue.DataValue__c;
        }
        
        //fect account details
        AccountRecord = fetchAccount(profileAccountId);
        System.Debug('AccountRecord-->' +AccountRecord);

        // set clustor values 
        clusterValue = AccountRecord.Cluster__c;
        
        //Added by Anil
        //For Profiled Accounts that do not have a Cluster or Specialty Rule Type, 
        //Display a message when clicking on the scorecard, and specialties tables - Message TBD


        if(AccountRecord.Velocity_Solution_Provider_Tier__c==null || AccountRecord.Cluster__c==null){
              ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Velocity_Tier_Error_Message);
              ApexPages.addMessage(errorMessage);
              isRenderScorecard = false;
              return;
        }
        
        // get tier names from custom setting and set values into map
        if(DataValueMap.containsKey('SequenceOfTiers')){
            objDataValue = DataValueMap.get('SequenceOfTiers');
            if(objDataValue != null){
                    String[] arrTierNames  = objDataValue.DataValue__c.split(',');
                    for(Integer i=0; i < arrTierNames.size(); i++){
                        mapTierDetails.put(arrTierNames[i], arrTierNames[i]);
                    }  
            }
        }
        System.debug('AccountRecord.Velocity_Solution_Provider_Tier__c ==>'+ AccountRecord.Velocity_Solution_Provider_Tier__c);
        //check account tiers, otherwise set default tier as affiliate
        if(AccountRecord.Velocity_Solution_Provider_Tier__c !=null && mapTierDetails.containsKey(AccountRecord.Velocity_Solution_Provider_Tier__c)){
            TiersName = AccountRecord.Velocity_Solution_Provider_Tier__c;                        
        }
        //Added check for EMEA SSCP fix on 23-Mar-2011
        else if(AccountRecord.Velocity_Solution_Provider_Tier__c == 'SSCP'){
            TiersName = 'Signature Solution Center';
        }
        else{
            TiersName = 'Affiliate';
        }
        
        //check for distributor account, if yes, then display error message.
        if(AccountRecord != null && DataValueMap.containsKey('PRMVPPDistributorValue')){
            if(AccountRecord.Partner_Type__c!= null){
                String[] arrPartnerType = AccountRecord.Partner_Type__c.split(';');
                if(isPartnerUser && currentUser.contact.Account.Partner_Type__c.contains('Distributor') 
                    && AccountRecord.Partner_Type__c.contains('Distribution VAR')
                    && (AccountRecord.Id != currentUser.contact.AccountId || (AccountRecord.Id != currentUser.contact.Account.Profiled_Account__c && currentUser.contact.Account.Profiled_Account__c !=null))
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
            
        
        //fetch all velocity rule results
        SpecialityRulesResult = processingQuery(); 
        
        //process velocity rule results       
        processingDataResult(SpecialityRulesResult);
        
        //isRevenueVisible= false;           
    }
    
    /* @Method <fetchAccount(): This method would fetch Account record details.>
       @param - <Account id as String> 
       @return <void> - <Account object>
       @throws exception - <No Exception>
    */
    private Account fetchAccount(String accountId){        
        Account accRecord = [Select Id, Name, Partner_Type__c, Velocity_Services_Implement__c, Solution_Center_Implemented__c,
                                    Velocity_Solution_Provider_Tier__c, Cluster__c,  Velocity_Compliance_Status__c
                             FROM Account Where id =: profileAccountId];
        return accRecord;                            
    }
    
    /* @Method <processingQuery(): This method would fetch all Velocity Rule result records details
                                    using account , cluster and tier_rule record type. and add into list.>
       @param - <Nothing>
       @return <void> - <List of Velocity Rule Result records>
       @throws exception - <No Exception>
    */
    private List<Velocity_Rule_Results__c> processingQuery(){
        List<Velocity_Rule_Results__c> SpecialityRuleResult ;     
        if(isRevenueVisible){     
            SpecialityRuleResult = [Select v.AccountID__c, v.AccountID__r.EMC_Speciality__c, v.Current__c, v.Speciality_RuleID__c, v.Speciality_RuleID__r.Bucket__c, 
                                                                 v.Speciality_RuleID__r.Display_Name__c, v.Speciality_RuleID__r.Required__c, 
                                                                 v.Speciality_RuleID__r.Specilaity__c,v.Speciality_RuleID__r.Is_Total_Revenue__c,v.Status__c,
                                                                 v.rule_theater__c,v.Speciality_RuleID__r.Tier__c ,v.Required_Value_Type__c,v.Is_Total_Revenue__c,
                                                                 v.RequiredCount__c,v.Speciality_RuleID__r.Sort__c
                                                                 
                                                           from Velocity_Rule_Results__c v
                                                           where Speciality_RuleID__r.RecordTypeId=: specilalityRecordtypeId
                                                            AND v.rule_theater__c =: clusterValue
                                                            AND v.AccountID__c=: AccountRecord.Id
                                                            AND v.Speciality_RuleID__r.Evaluation_at__c ='Country Grouping Level'
                                                            ORDER BY v.Speciality_RuleID__r.Sort__c asc
                                                            ];
        }else{
            SpecialityRuleResult = [Select v.AccountID__c, v.AccountID__r.EMC_Speciality__c, v.Current__c, v.Speciality_RuleID__c, v.Speciality_RuleID__r.Bucket__c, 
                                                                 v.Speciality_RuleID__r.Display_Name__c, v.Speciality_RuleID__r.Required__c, 
                                                                 v.Speciality_RuleID__r.Specilaity__c,v.Speciality_RuleID__r.Is_Total_Revenue__c,v.Status__c,
                                                                 v.rule_theater__c,v.Speciality_RuleID__r.Tier__c ,v.Required_Value_Type__c,v.Is_Total_Revenue__c,
                                                                 v.RequiredCount__c,v.Speciality_RuleID__r.Sort__c
                                                                 
                                                           from Velocity_Rule_Results__c v
                                                           where Speciality_RuleID__r.RecordTypeId=: specilalityRecordtypeId
                                                            AND v.rule_theater__c =: clusterValue
                                                            AND v.AccountID__c=: AccountRecord.Id
                                                            AND v.Speciality_RuleID__r.Bucket__c !='Revenue'
                                                            AND v.Speciality_RuleID__r.Evaluation_at__c ='Country Grouping Level'
                                                            ORDER BY v.Speciality_RuleID__r.Sort__c asc
                                                            ];
        }
        System.debug('SpecialityRules ==>'+ SpecialityRuleResult);          
        System.debug('SpecialityRules size ==>'+ SpecialityRuleResult.size());
        
        return SpecialityRuleResult;
    }
    
     /* @Method <populateData(): This method would call processingDataResult method.>
       @param - <Nothing>
       @return <void> - <null>
       @throws exception - <No Exception>
    */
    public PageReference populateData(){         
        processingDataResult(SpecialityRulesResult);            
        return null;
    }
    
    /* @Method <processingDataResult(): This method would call processingResult method.>
       @param - <Nothing>
       @return <void> 
       @throws exception - <No Exception>
    */
    private void processingDataResult(List<Velocity_Rule_Results__c> SpecialityRulesResult){
        strTierNameDetails = TiersName;
        /* */
        if(TiersName =='Signature Solution Center' || TiersName=='Distributor'){
            TiersName='Signature';  
        }
        processingResult(SpecialityRulesResult);
         
        ProcessingTierName =  TiersName;
        TiersName = strTierNameDetails; 
        
    }
    
    
    /* @Method <processingResult(): This method would call processingResult method.>
       @param - <List of Velocity rule result>
       @return <void> 
       @throws exception - <No Exception>
    */
    private void processingResult( List<Velocity_Rule_Results__c> SpecialityRulesResult){       
        
        System.debug('*************** TiersName Selected' + TiersName);
        //
        for(Velocity_Rule_Results__c objVRResult :SpecialityRulesResult){
            if(objVRResult.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                System.debug('*************** objVRResult' + objVRResult);
                 if((objVRResult.Is_Total_Revenue__c=='YES')){
                    if(!mapTotalTierRecord.containsKey(objVRResult.Speciality_RuleID__r.Tier__c)){
                        mapTotalTierRecord.put(objVRResult.Speciality_RuleID__r.Tier__c, objVRResult);
                        TotalRevenueTierNameSet.add(objVRResult.Speciality_RuleID__r.Tier__c);   
                    }                   
                 }          
            }
            if((objVRResult.Required_Value_Type__c=='USD' || objVRResult.Required_Value_Type__c =='Number/Count') &&  (objVRResult.Speciality_RuleID__r.Bucket__c =='Velocity Program')){   
                if(mapBucketVelocityProgram.containsKey(objVRResult.Speciality_RuleID__r.Tier__c)){             
                    mapBucketVelocityProgram.get(objVRResult.Speciality_RuleID__r.Tier__c).add(objVRResult);                                
                }else{
                    mapBucketVelocityProgram.put(objVRResult.Speciality_RuleID__r.Tier__c, new List<Velocity_Rule_Results__c>());
                    mapBucketVelocityProgram.get(objVRResult.Speciality_RuleID__r.Tier__c).add(objVRResult);
                }
            }                      
            if(objVRResult.Speciality_RuleID__r.Bucket__c == 'Velocity Program'){
                if(!mapVelocityProgramTiers.containsKey(objVRResult.Speciality_RuleID__r.Tier__c)){
                    mapVelocityProgramTiers.put(objVRResult.Speciality_RuleID__r.Tier__c, objVRResult);                 
                }   
            }
            if(objVRResult.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                if(mapRevenueTiers.containsKey(objVRResult.Speciality_RuleID__r.Tier__c)){              
                    mapRevenueTiers.get(objVRResult.Speciality_RuleID__r.Tier__c).add(objVRResult);                             
                }else{
                    mapRevenueTiers.put(objVRResult.Speciality_RuleID__r.Tier__c, new List<Velocity_Rule_Results__c>());
                    mapRevenueTiers.get(objVRResult.Speciality_RuleID__r.Tier__c).add(objVRResult);
                }   
            }                               
        } 
        System.debug('*************** mapTotalTierRecord' + mapTotalTierRecord);
        System.debug('*************** mapBucketVelocityProgram' + mapBucketVelocityProgram);
                    
        //create map bucket/displyname and tier order for fetched velocity rule result.
        mapBucketDisplaynameTierValues = createDataResultForProcessing(SpecialityRulesResult);
        System.debug('*************** mapBucketDisplaynameTierValues' + mapBucketDisplaynameTierValues);
        
        //Fetch all custom label values and add into list
        lstCustomTierValues = fetchTierNamesOrder();
        System.debug('*************** lstCustomTierValues' + lstCustomTierValues);
        
        //Fetch Requirement sequence from custom setting and add into list
        List<String> lstTierRequirementSequence = fetchTierRequirementSequeceOrder();
        System.debug('*************** lstTierRequirementSequence' + lstTierRequirementSequence);
        
        //Fetch Order of all Bucket' Discplay name using sort field of signature/SignatureSSCP
        Map<String, List<String>> mapBucketDisplayNameSequence = fetchBucketDisplayNameSequenceOrder();
        System.debug('*************** lstBucketDisplayNameSequence' + mapBucketDisplayNameSequence);
        
        //call method to populate result.
        lstBucketNameData = getDisplayResult(lstCustomTierValues, lstTierRequirementSequence, mapBucketDisplayNameSequence, mapBucketDisplaynameTierValues);       
        System.debug('*************** lstBucketNameData' + lstBucketNameData);
        
    }
    
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Affiliate','Affiliate'));
        options.add(new SelectOption('Affiliate Elite','Affiliate Elite')); 
        options.add(new SelectOption('Premier','Premier'));
        options.add(new SelectOption('Signature','Signature'));
        options.add(new SelectOption('Signature Solution Center','Signature Solution Center'));       
        options.add(new SelectOption('Distributor','Distributor'));
        return options;
    }
    
    public List<SelectOption> getComplianceRequirementStatusItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No'));       
        return options;
    }
    
    public List<PRM_BucketNameDataContainer> getTierScoreCard(){
        system.debug('$$$$$$$'+ lstBucketNameData+'$$$$$$$$');       
        return lstBucketNameData;
    }
    
    /* @Method <getTierScoreCardSingle(): This property is used to create single record  of PRM_BucketNameDataContainer class>
           @param - <None>
           @return - <List of String>
           @throws exception - <No Exception>
        */
    public List<PRM_BucketNameDataContainer> getTierScoreCardSingle(){
        List<PRM_BucketNameDataContainer> temp = new List<PRM_BucketNameDataContainer>();
        for(PRM_BucketNameDataContainer objBucket :lstBucketNameData){
            if(objBucket.BucketName == 'Velocity Program'){             
                temp.add(objBucket);   
                break;          
            }
        }        
        return temp;
    }
    
    
    /* @Method <fetchTierNamesOrder(): This method is used to create list of Tier name for sequence perticular 
        cluster from custom balbe and custom setting>
           @param - <None>
           @return - <List of String>
           @throws exception - <No Exception>
        */
    private List<String> fetchTierNamesOrder(){
        List<String> lstCustomTierValues = new List<String>();
        if(System.Label.PRM_Tier1_Name != 'NONE') lstCustomLabelTierValues.add(System.Label.PRM_Tier1_Name);
        if(System.Label.PRM_Tier2_Name != 'NONE') lstCustomLabelTierValues.add(System.Label.PRM_Tier2_Name);
        if(System.Label.PRM_Tier3_Name != 'NONE') lstCustomLabelTierValues.add(System.Label.PRM_Tier3_Name);
        if(System.Label.PRM_Tier4_Name != 'NONE') lstCustomLabelTierValues.add(System.Label.PRM_Tier4_Name);
        if(System.Label.PRM_Tier5_Name != 'NONE') lstCustomLabelTierValues.add(System.Label.PRM_Tier5_Name);
        
        CustomSettingDataValueMap__c objDataValue = DataValueMap.get('SequenceOfTiers');
        if(objDataValue != null){
            String strTierSequence = objDataValue.DataValue__c;
            if(strTierSequence != null){
                List<String> lstTierReqSequence = strTierSequence.split(',');
                for(String strSeq : lstTierReqSequence){
                    if(strSeq !=''){                            
                        lstCustomTierValues.add(strSeq);
                    }                   
                }               
            }           
        }
        System.debug('lstCustomSettingTierValues ----> ' + lstCustomLabelTierValues);
        System.debug('lstCustomTierValues ----> '+ lstCustomTierValues);
        
        return lstCustomTierValues;
    }    
     
    /* @Method <fetchTierRequirementSequeceOrder(): This method is used to create list for Tier for perticular cluster from custom setting>
           @param - <None>
           @return - <List of String>
           @throws exception - <No Exception>
        */  
    private List<String> fetchTierRequirementSequeceOrder(){
        List<String> lstTierRequirementSequence = new List<String>();        
        CustomSettingDataValueMap__c objDataValue = DataValueMap.get('TierRequirementSequenceFor'+clusterValue);
        if(objDataValue != null){
            String strTierSequence = objDataValue.DataValue__c;
            if(strTierSequence != null){
                List<String> lstTierReqSequence = strTierSequence.split(',');
                for(String strSeq : lstTierReqSequence){
                    if(strSeq !=''){
                        lstTierRequirementSequence.add(strSeq);
                    }                   
                }               
            }           
        } 
        return lstTierRequirementSequence;
    }
    
    /* @Method <fetchBucketDisplayNameSequenceOrder(): This method is used to create Map for data using velocity rule Result>
           @param - <List of Velocity Rule Result records>
           @return - <Map>
           @throws exception - <No Exception>
        */
    private Map<String, List<String>> fetchBucketDisplayNameSequenceOrder(){
        Map<String, List<String>> mapBucketDisplayNameSequence = new Map<String, List<String>>();
        Map<String, Set<String>> mapBucketDisplayNameSequenceForCheck = new Map<String, Set<String>>();
        for(Velocity_Rule_Results__c objVRResult :SpecialityRulesResult){
            if(((objVRResult.Speciality_RuleID__r.Sort__c != null) && (objVRResult.Is_Total_Revenue__c == 'NO')) && (objVRResult.Speciality_RuleID__r.Tier__c =='Signature' || objVRResult.Speciality_RuleID__r.Tier__c ==SignatureSSCP)){
                if(mapBucketDisplayNameSequence.containsKey(objVRResult.Speciality_RuleID__r.Bucket__c)){
                    if(!mapBucketDisplayNameSequenceForCheck.get(objVRResult.Speciality_RuleID__r.Bucket__c).contains(objVRResult.Speciality_RuleID__r.Display_Name__c)){
                        mapBucketDisplayNameSequence.get(objVRResult.Speciality_RuleID__r.Bucket__c).add(objVRResult.Speciality_RuleID__r.Display_Name__c);
                    }                   
                    mapBucketDisplayNameSequenceForCheck.get(objVRResult.Speciality_RuleID__r.Bucket__c).add(objVRResult.Speciality_RuleID__r.Display_Name__c);
                }else{
                    mapBucketDisplayNameSequence.put(objVRResult.Speciality_RuleID__r.Bucket__c, new List<String>());
                    mapBucketDisplayNameSequence.get(objVRResult.Speciality_RuleID__r.Bucket__c).add(objVRResult.Speciality_RuleID__r.Display_Name__c);
                    mapBucketDisplayNameSequenceForCheck.put(objVRResult.Speciality_RuleID__r.Bucket__c, new Set<String>());
                    mapBucketDisplayNameSequenceForCheck.get(objVRResult.Speciality_RuleID__r.Bucket__c).add(objVRResult.Speciality_RuleID__r.Display_Name__c);
                }               
            }       
        }
        for(Velocity_Rule_Results__c objVRResult :SpecialityRulesResult){
            if((objVRResult.Speciality_RuleID__r.Sort__c != null) && (objVRResult.Is_Total_Revenue__c == 'NO')){
                if(mapBucketDisplayNameSequence.containsKey(objVRResult.Speciality_RuleID__r.Bucket__c)){
                    if(!mapBucketDisplayNameSequenceForCheck.get(objVRResult.Speciality_RuleID__r.Bucket__c).contains(objVRResult.Speciality_RuleID__r.Display_Name__c)){
                        mapBucketDisplayNameSequence.get(objVRResult.Speciality_RuleID__r.Bucket__c).add(objVRResult.Speciality_RuleID__r.Display_Name__c);
                    }                   
                }else{
                    mapBucketDisplayNameSequence.put(objVRResult.Speciality_RuleID__r.Bucket__c, new List<String>());
                    mapBucketDisplayNameSequence.get(objVRResult.Speciality_RuleID__r.Bucket__c).add(objVRResult.Speciality_RuleID__r.Display_Name__c);
                }               
            }       
        }
        
        
        return mapBucketDisplayNameSequence;
    }
    
    /* @Method <createDataResultForProcessing(): This method is used to create Map for data using velocity rule Result>
           @param - <List of Velocity Rule Result records>
           @return - <Map>
           @throws exception - <No Exception>
        */
    private Map<String, Map<String, Map<String, Velocity_Rule_Results__c>>> createDataResultForProcessing(List<Velocity_Rule_Results__c> SpecialityRulesResult){
        Map<String, Map<String, Map<String, Velocity_Rule_Results__c>>> mapTempBucketDisplaynameTierValues = new Map<String, Map<String, Map<String, Velocity_Rule_Results__c>>>();
        Map<String, Map<String, Velocity_Rule_Results__c>> mapTempDisplayData = new Map<String,Map<String,  Velocity_Rule_Results__c>>();
        Map<String,  Velocity_Rule_Results__c> mapTempDataTier = new Map<String, Velocity_Rule_Results__c>();
                
        for(Velocity_Rule_Results__c specialityObj: SpecialityRulesResult) {
            if(mapTempBucketDisplaynameTierValues.containsKey(specialityObj.Speciality_RuleID__r.Bucket__c)){
                mapTempDisplayData = mapTempBucketDisplaynameTierValues.get(specialityObj.Speciality_RuleID__r.Bucket__c);
            }else{
                mapTempBucketDisplaynameTierValues.put(specialityObj.Speciality_RuleID__r.Bucket__c, new Map<String,Map<String, Velocity_Rule_Results__c>>());
                mapTempDisplayData = mapTempBucketDisplaynameTierValues.get(specialityObj.Speciality_RuleID__r.Bucket__c);
            }           
            if(mapTempDisplayData.containsKey(specialityObj.Speciality_RuleID__r.Display_Name__c)){
                mapTempDataTier = mapTempDisplayData.get(specialityObj.Speciality_RuleID__r.Display_Name__c);                 
            }else{
                mapTempDisplayData.put(specialityObj.Speciality_RuleID__r.Display_Name__c, new Map<String, Velocity_Rule_Results__c>());
                mapTempDataTier = mapTempDisplayData.get(specialityObj.Speciality_RuleID__r.Display_Name__c);
            }           
            if(!mapTempDataTier.containsKey(specialityObj.Speciality_RuleID__r.tier__c)){                        
                mapTempDataTier.put(specialityObj.Speciality_RuleID__r.tier__c, specialityObj);
            }
        }
        
        return mapTempBucketDisplaynameTierValues;
    }
    
    
    /* @Method <getDisplayResult(): This method is used to create data to display on VF page>
           @param - <List of string, List of string, Map of bucketWithDisplayName>
           @return - <List of PRM_BucketNameDataContainer>
           @throws exception - <No Exception>
        */
    private List<PRM_BucketNameDataContainer> getDisplayResult(List<String> lstCustomTierValues, List<String> lstTierRequirementSequence , 
                                                            Map<String,List<String>> mapBucketDisplayNameSequence,
                                                            Map<String,Map<String, Map<String, Velocity_Rule_Results__c>>> mapBucketDisplaynameTierValues){
        
        List<PRM_BucketNameDataContainer> lstTempBucketNameData = new List<PRM_BucketNameDataContainer>();
        Boolean blnCompliance  = true;
        Boolean blnRevenueCompliance  = true;
        for(String strBucketnames : lstTierRequirementSequence){           
            PRM_BucketNameDataContainer objTempBuckData = new PRM_BucketNameDataContainer();
            objTempBuckData.BucketName = strBucketnames;
            if(mapBucketDisplaynameTierValues.containsKey(strBucketnames)){
                
                Map<String, Map<String,  Velocity_Rule_Results__c>> mapTempDisplayDataValues = mapBucketDisplaynameTierValues.get(strBucketnames);
                System.debug('*************** mapTempDisplayDataValues' + mapTempDisplayDataValues);
                
                List<PRM_DisplayNameDataContainer> lstDisplayName = new List<PRM_DisplayNameDataContainer>();
                Boolean checkforTotal = true;
                if(strBucketnames == 'Revenue'){
                    if(mapTotalTierRecord != null){                     
                        for(String strTierListName:  lstCustomTierValues){  
                            if(strTierListName =='Signature'){
                                if(!(mapTotalTierRecord.containsKey(strTierListName) || (mapTotalTierRecord.containsKey(SignatureSSCP)))){
                                    checkforTotal= false;      
                                    break;          
                                }
                            } else{
                                if(!mapTotalTierRecord.containsKey(strTierListName)){
                                    checkforTotal= false;      
                                    break;          
                                }
                            }                       
                            
                        }
                    }
                }
                System.debug('*************** checkforTotal' + checkforTotal);    
                if(!checkforTotal){  
                    List<String> lstBucketDisplayNameSequence = new List<String>();
                    if(mapBucketDisplayNameSequence.containsKey(strBucketnames)){
                        lstBucketDisplayNameSequence = mapBucketDisplayNameSequence.get(strBucketnames);
                    }  
                    integer rowno=0;                                             
                    for(String strDisplayName : lstBucketDisplayNameSequence){
                        System.debug('*************** strDisplayName revenue' + strDisplayName);
                        PRM_DisplayNameDataContainer objTempDisplayData = new PRM_DisplayNameDataContainer();
                        objTempDisplayData.DisplayName = strDisplayName;
                        System.debug('*************** strDisplayName revenue' + strDisplayName);
                         
                        Map<String, Velocity_Rule_Results__c> objTempData = mapTempDisplayDataValues.get(strDisplayName);
                                                
                        System.debug('*************** objTempData revenue' + objTempData);
                        List<PRM_TierNameValueContainer> lstTiername = new List<PRM_TierNameValueContainer>();
                        String TierActulaValue = '';
                        String TierValueType = '';
                        Boolean Totrevenue=false; //Added by Krishna for WR 223956
                                                                    
                        Integer iCount =0;
                        for(String strTierName : lstCustomTierValues){                                            
                            PRM_TierNameValueContainer objTierData = new PRM_TierNameValueContainer();
                            Velocity_Rule_Results__c vrrRecord = null;
                            String strTiernamevalue ='';
                            if(lstCustomLabelTierValues!= null && lstCustomLabelTierValues.size()>0){
                                strTiernamevalue = lstCustomLabelTierValues.get(iCount);
                            }
                            objTierData.TierName = strTierName;
                            objTierData.TierDisplayName =strTiernamevalue;
           
                            //Prasad K 2585 Removed the logic of merge cell and added to controller.  
                            objTierData.isTotalRevenue  = TotalRevenueTierNameSet.contains(strTierName);
                                                      
                            System.debug('***************Revenue strTierName' + strTierName);
                            if(objTempData != null ){
                                if(strTierName =='Signature'){
                                    if(objTempData.containsKey(strTierName)){
                                        vrrRecord = objTempData.get(strTierName);                                           
                                    }else if(objTempData.containsKey(SignatureSSCP)){
                                        vrrRecord = objTempData.get(SignatureSSCP);
                                    }                                       
                                }else{
                                    vrrRecord = objTempData.get(strTierName);
                                }
                            }
                            
                            if(vrrRecord != null){                                  
                                System.debug('***************Revenue vrrRecord' + vrrRecord);
                                if(vrrRecord != null){
                                    objTierData.TierValue  = vrrRecord.RequiredCount__c;
                                    objTierData.TierRuleResult = vrrRecord;
                                    TierValueType = vrrRecord.Required_Value_Type__c;
                                    objTierData.TierAchieved = vrrRecord.Status__c;
                                }
                                
                                if( strTierName == this.TiersName){
                                    if(vrrRecord != null){
                                        TierActulaValue = vrrRecord.Current__c; 
                                        Totrevenue=vrrRecord.Speciality_RuleID__r.Is_Total_Revenue__c;
                                        
                                    }                                   
                                    /*
                                    if((objTierData.TierAchieved != 'Achieved') && (blnCompliance) && (!((TierValueType =='Text') && (objTierData.TierValue=='n/a' || objTierData.TierValue =='Optional')) )){  
                                        blnCompliance = false;                                                                   
                                    }  
                                    */                          
                                }                                                           
                            }else{
                                if(mapTotalTierRecord != null){     
                                    if(strTierName =='Signature'){
                                        if(mapTotalTierRecord.containsKey(strTierName)){
                                            vrrRecord = mapTotalTierRecord.get(strTierName);                                            
                                        }else if(mapTotalTierRecord.containsKey(SignatureSSCP)){
                                            vrrRecord = mapTotalTierRecord.get(SignatureSSCP);
                                        }
                                    }else{
                                        vrrRecord = mapTotalTierRecord.get(strTierName);
                                    }   
                                    if(vrrRecord != null){
                                        objTierData.TierValue = vrrRecord.RequiredCount__c;
                                        objTierData.TierRuleResult = vrrRecord;
                                        objTierData.TierAchieved = vrrRecord.Status__c;
                                    }                   
                                    
                                    if( strTierName == this.TiersName){
                                        if(vrrRecord != null){
                                            TierActulaValue = vrrRecord.Current__c;    
                                            Totrevenue=vrrRecord.Speciality_RuleID__r.Is_Total_Revenue__c; 
                                                                           
                                        }
                                        /*
                                        if((objTierData.TierAchieved != 'Achieved') && (blnCompliance) && (!((TierValueType =='Text') && (objTierData.TierValue=='n/a' || objTierData.TierValue =='Optional')) )){  
                                            blnCompliance = false; 
                                            System.debug('***************blnCompliance2' + blnCompliance);
                                        }
                                        */ 
                                    }                               
                                    System.debug('***************Revenue TierActulaValue' + TierActulaValue); 
                                }   
                            }
                            //Prasad K 2585 Removed the logic of merge cell and added to controller. 
                            if(!(rowno>0 && objTierData.isTotalRevenue)){
                                lstTiername.add(objTierData);
                            }
                            System.debug('*************** inside lstTiername' + lstTiername);
                            iCount ++;
                        }
                        
                        PRM_TierNameValueContainer objTierData1 = new PRM_TierNameValueContainer();
                        objTierData1.TierName = 'Actual';
                        objTierData1.TierDisplayName = System.Label.Actual;
                        objTierData1.TierValue = TierActulaValue;
                       //Added by Krishna for WR 223956
                        if(Totrevenue==false && rowno>=0)
                        {
                            lstTiername.add(objTierData1);
                            objTierData1.isTotalRevenue=false;
                        }   
                        if(Totrevenue==true && rowno==0)
                        {
                            lstTiername.add(objTierData1);
                            objTierData1.isTotalRevenue=true;
                        }                  
                        System.debug('***************inside checkTier if true' + objTierData1);
                        System.debug('*************** after checkTier lstTiername' + lstTiername);                                                
                        objTempDisplayData.lstVelocityTierNameValueData = lstTiername;
                        System.debug('*************** after objTempDisplayData.lstVelocityTierNameValueData' + objTempDisplayData.lstVelocityTierNameValueData);
                        lstDisplayName.add(objTempDisplayData);
                        System.debug('*************** after lstDisplayName' + lstDisplayName);                        
                        rowno++;    
                    }
                    
                    // check for revenue compliance                        
                    blnRevenueCompliance = getComplianceStatusForRevenue(this.TiersName);
                    
                }else{
                    System.debug('*************** mapTempDisplayDataValues' + mapTempDisplayDataValues);
                    System.debug('*************** mapTempDisplayDataValues.keySet' + mapTempDisplayDataValues.keySet());
                    List<String> lstBucketDisplayNameSequence = new List<String>();
                    if(mapBucketDisplayNameSequence.containsKey(strBucketnames)){
                        lstBucketDisplayNameSequence = mapBucketDisplayNameSequence.get(strBucketnames);
                    } 
                    for(String strDisplayName : lstBucketDisplayNameSequence){
                    //for(String strDisplayName : mapTempDisplayDataValues.keySet()){
                    //for(String strDisplayName : setRevenueDisplayNames){
                        PRM_DisplayNameDataContainer objTempDisplayData = new PRM_DisplayNameDataContainer();
                        objTempDisplayData.DisplayName = strDisplayName;
                        System.debug('*************** strDisplayName' + strDisplayName);
                        Map<String, Velocity_Rule_Results__c> objTempData = mapTempDisplayDataValues.get(strDisplayName);
                        
                        System.debug('*************** objTempData' + objTempData);
                        List<PRM_TierNameValueContainer> lstTiername = new List<PRM_TierNameValueContainer>();
                        String TierActulaValue = '';
                        String TierValueType = '';
                        Integer iCount=0;
                        for(String strTierName : lstCustomTierValues){                  
                            Velocity_Rule_Results__c vrrRecord = null;
                            PRM_TierNameValueContainer objTierData = new PRM_TierNameValueContainer();
                            String strTiernamevalue ='';
                            if(lstCustomLabelTierValues!= null && lstCustomLabelTierValues.size()>0){
                                strTiernamevalue = lstCustomLabelTierValues.get(iCount);
                            }
                            
                            objTierData.TierDisplayName = strTiernamevalue;
                            objTierData.TierName = strTierName;
                            System.debug('*************** strTierName' + strTierName);
                            if(strBucketnames=='SSCP' && strTierNameDetails =='Signature Solution Center' && strTierName == 'Signature' ){
                                strTierName =SignatureSSCP;
                            } 
                            
                            if(objTempData != null){
                                if(strTierName =='Signature'){
                                    if(objTempData.containsKey(strTierName)){
                                        vrrRecord = objTempData.get(strTierName);                                           
                                    }else if(objTempData.containsKey(SignatureSSCP)){
                                        vrrRecord = objTempData.get(SignatureSSCP);
                                    }                                       
                                }else{
                                    vrrRecord = objTempData.get(strTierName);
                                }
                            }  
                                                       
                            if(vrrRecord != null){                              
                            
                                objTierData.TierValue  = vrrRecord.RequiredCount__c;
                                objTierData.TierRuleResult = vrrRecord;
                                TierValueType = vrrRecord.Required_Value_Type__c;
                                objTierData.TierAchieved = vrrRecord.Status__c;
                            
                                
                                if(( strTierName == this.TiersName) || (strTierName ==SignatureSSCP)){
                                    
                                    TierActulaValue = vrrRecord.Current__c;
                                  
                                    System.debug('***************blnCompliance2' + blnCompliance);
                                    System.debug('***************objTierData.TierAchieved' + objTierData.TierAchieved);
                                    System.debug('***************TierValueType' + TierValueType);
                                    System.debug('***************objTierData.TierValue' + objTierData.TierValue); 
                                    if((objTierData.TierAchieved != 'Achieved') && (blnCompliance) && (!((TierValueType =='Text') && (objTierData.TierValue=='n/a' || objTierData.TierValue =='Optional')) )){  
                                        blnCompliance = false; 
                                        System.debug('***************blnCompliance3' + blnCompliance);                                          
                                    } 
                                                                    
                                }                                                   
                            }else{
                                if(mapTotalTierRecord != null ){                                    
                                    if(strTierName =='Signature'){
                                        if(mapTotalTierRecord.containsKey(strTierName)){
                                            vrrRecord = mapTotalTierRecord.get(strTierName);                                            
                                        }else if(mapTotalTierRecord.containsKey(SignatureSSCP)){
                                            vrrRecord = mapTotalTierRecord.get(SignatureSSCP);
                                        }
                                    }else{
                                        vrrRecord = mapTotalTierRecord.get(strTierName);
                                    }   
                                    if(vrrRecord != null){
                                        objTierData.TierRuleResult = vrrRecord;
                                        TierActulaValue = vrrRecord.Current__c;
                                        objTierData.TierValue = vrrRecord.RequiredCount__c;
                                        TierValueType = vrrRecord.Required_Value_Type__c;
                                        objTierData.TierAchieved = vrrRecord.Status__c;
                                    }
                                    
                                    System.debug('***************blnCompliance3' + blnCompliance);
                                    System.debug('***************objTierData.TierAchieved' + objTierData.TierAchieved);
                                    System.debug('***************TierValueType' + TierValueType);
                                    System.debug('***************objTierData.TierValue' + objTierData.TierValue);
                                    if((objTierData.TierAchieved != 'Achieved') && (blnCompliance) && (!((TierValueType =='Text') && (objTierData.TierValue=='n/a' || objTierData.TierValue =='Optional') ))){  
                                        blnCompliance = false; 
                                        System.debug('***************blnCompliance4' + blnCompliance);
                                            
                                    } 
                                }
                            }                       
                                                       
                            System.debug('***************objTierData.TierValue' + objTierData.TierValue);
                            System.debug('***************Final TierActulaValue' + TierActulaValue);
                                                        
                            lstTiername.add(objTierData);
                            System.debug('*************** inside lstTiername' + lstTiername);
                            iCount ++;
                        }
                        
                        PRM_TierNameValueContainer objTierData1 = new PRM_TierNameValueContainer();
                        objTierData1.TierName = 'Actual';
                        objTierData1.TierDisplayName = System.Label.Actual;
                        
                        objTierData1.TierValue = TierActulaValue; 
                        lstTiername.add(objTierData1);
                        System.debug('***************inside checkTier if true' + objTierData1);
                                                
                        objTempDisplayData.lstVelocityTierNameValueData = lstTiername;
                        
                        lstDisplayName.add(objTempDisplayData);
                        System.debug('*************** after lstDisplayName' + lstDisplayName);
                    }
                }                   
                objTempBuckData.lstVelocityBucketNameValueData = lstDisplayName;        
                lstTempBucketNameData.add(objTempBuckData); 
                System.debug('*************** lstTempBucketNameData' + lstTempBucketNameData);
            }                    
        }
        System.debug('******************blnCompliance' + blnCompliance); 
        System.debug('******************blnRevenueCompliance' + blnRevenueCompliance); 
        if( !blnCompliance || !blnRevenueCompliance){
            ComplianceRequirementStatus = 'No';
        }else{
            ComplianceRequirementStatus = 'Yes';
        }
        //ComplianceRequirementStatus = '';//AccountRecord.Velocity_Compliance_Status__c;
        System.debug('*************** final output ComplianceRequirementStatus' + ComplianceRequirementStatus);
        System.debug('*************** final output lstTempBucketNameData' + lstTempBucketNameData);
        return lstTempBucketNameData;
    }
       
    /* @Method <cancelUpdates(): This method is used to update the Speciality status of
                             Profiled Account from UI.>
           @param - <void>
           @return <void> - <Not Returning anything>
           @throws exception - <No Exception>
        */     
    public pageReference cancelUpdates(){
        PageReference returnPage = new PageReference('/'+AccountRecord.Id);
        returnPage.setredirect(true);
        return returnPage;
    }
    
    /* @Method <updateProfileAccount(): This method is used to update the Speciality status of
                                        Profiled Account from UI.>
       @param - <void>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
        */     
    public void updateProfileAccount(){      
        try{ 
            // 29-Apr-2011 Anand Sharma     2769    
            if(TiersName=='Signature Solution Center'){
                AccountRecord.put('Velocity_Solution_Provider_Tier__c','SSCP'); 
            }else{
                AccountRecord.put('Velocity_Solution_Provider_Tier__c',TiersName);
            }   
            AccountRecord.put('Velocity_Compliance_Status__c',ComplianceRequirementStatus);            
       
            List<Account> lstAccount = new List<Account>();
            lstAccount.add(AccountRecord);
            Database.Saveresult[] sr = DataBase.update(lstAccount);
            
            System.debug( 'lstDisplayData--Updated Error sr-> +' + sr);
        }
        Catch(Exception ex){      
           ApexPages.addMessages(ex);
        }
    }  
    
    
        
    /**     * Method <getComplianceStatusForRevenue(): Method called to get revenue compliance status for tier>
        *   @param <String as Tier name> 
        *   @return <void> - <Boolean>
        *   @throws exception-<No exception >
     */
    public boolean getComplianceStatusForRevenue(String strTierName){       
        Boolean checkCompFlag = false;      
        if(mapVelocityProgramTiers.size() > 0 && mapRevenueTiers.size() > 0 && strTierName != null){
            //for(String strTiernames : mapVelocityProgramTiers.keySet()){          
            if(mapRevenueTiers.containskey(strTierName) && mapVelocityProgramTiers.containskey(strTierName)){
                System.debug('*********Contains Tier strTierName ' +strTierName);
                System.debug('*********Contains mapVelocityProgramTiers.get(strTierName).RequiredCount__c ' + mapVelocityProgramTiers.get(strTierName).RequiredCount__c);
                List<Velocity_Rule_Results__c> lstRevneueResult = mapRevenueTiers.get(strTierName); 
                System.debug('*********lstRevneueResult ' +lstRevneueResult);
                if((mapVelocityProgramTiers.get(strTierName).RequiredCount__c =='n/a') || (mapVelocityProgramTiers.get(strTierName).RequiredCount__c =='Optional')){
                        for(Velocity_Rule_Results__c objVRResult : lstRevneueResult){
                                                if(objVRResult.Status__c !='Achieved'){
                                                        checkCompFlag = false;
                                                        break;
                                                }else{
                                                        checkCompFlag = true;
                                                }
                                        }                    
                }else{
                    Integer intVelocityProgramValue = Integer.valueOf(mapVelocityProgramTiers.get(strTierName).RequiredCount__c);
                    System.debug('*********intVelocityProgramValue ' +intVelocityProgramValue);
                    Integer intCounter = 0;
                    if(lstRevneueResult != null){
                        System.debug('*********Check null  ' +lstRevneueResult);
                        for(Velocity_Rule_Results__c objVRResult : lstRevneueResult){
                            System.debug('*********Check null  ' +lstRevneueResult);
                            if(objVRResult.Status__c =='Achieved'){
                                intCounter ++;
                                System.debug('*********intCounter  ' +intCounter);
                                if(intCounter == intVelocityProgramValue ){
                                    System.debug('*********intCounter + intVelocityProgramValue  ' +intCounter + ' ' + intVelocityProgramValue);
                                    checkCompFlag = true;
                                    break;
                                }
                            }
                        }
                    }                       
                }                           
            }//}
        }
        System.debug('*********Check checkCompFlag  ' +checkCompFlag);
        return checkCompFlag;
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
    
    /************************* Helper Classes  **************************/  
     
    public class PRM_TierNameValueContainer {
        public String TierName {get; set;}
        public String TierDisplayName {get; set;}
        public String TierValue {get; set;}
        public String TierAchieved {get; set;}      
        public Velocity_Rule_Results__c TierRuleResult {get; set;}        
        
        // 22-March-2011 Prasad K     2585    Removed the logic of merge cell and added to controller.
        public boolean isTotalRevenue {get; set;}
   
    } 
    
    public class PRM_DisplayNameDataContainer {
        //hold name of program
        public String DisplayName {get; set;}
        
        //hold type of Velocity scorecard section
        public List<PRM_TierNameValueContainer> lstVelocityTierNameValueData {get; set;}
        
        public PRM_DisplayNameDataContainer(){
            lstVelocityTierNameValueData = new List<PRM_TierNameValueContainer>();
        }       
        public void setmapTierNameValueDataContainer (String tier, String required )
        {
            System.debug('*********tier required ' + required  +  '  +   ' + tier);
            PRM_TierNameValueContainer objTier = new PRM_TierNameValueContainer();
            objTier.TierName = tier;
            objTier.TierValue = required;
            System.debug('*********tier required ' + required  +  '  +   ' + tier);
            this.lstVelocityTierNameValueData.add(objTier);
        }
    }
    
    public class PRM_BucketNameDataContainer {
        //hold name of program
        public String BucketName {get; set;}
        
        //hold type of Velocity scorecard section
        public List<PRM_DisplayNameDataContainer> lstVelocityBucketNameValueData {get; set;}
        
        public PRM_BucketNameDataContainer(){
            lstVelocityBucketNameValueData = new List<PRM_DisplayNameDataContainer>();
        }       
        public void setmapBucketNameValueDataContainer (PRM_DisplayNameDataContainer objTier)
        {
            System.debug('*********tier required ' + objTier  );
            this.lstVelocityBucketNameValueData.add(objTier);
        }
    }
}