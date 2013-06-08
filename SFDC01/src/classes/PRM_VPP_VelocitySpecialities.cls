/*===============================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 07/12/2010    Karthik Shivprakash                 Initial Creation.This is used to fetch the speciality   
                                                     rules based on the profiled account
 |                                                   Id and speciality rule Id.
 | 22/01/2011    Ashwini Gowda                       Implemented Logic as per the latest Requirement.
 | 25/03/2011    Anil Sure                 2513      Have an account with tier popoulated, and both cluster and Specialty NOT populated -
 |                                                   Ensure you see the messages on both the scorecard and the specialties table
 | 03/06/2011    Anil Sure                 2973      Replaced the Custom Label value with String formatted 'Not Achieved'.
 | 30/09/2011    Suman B                             Modified the ComplianceStatus logic for 'Backup and Recovery' to set to Yes 
 |                                                   if anyone has met the criteria.
 | 20/7/2012     Arif                     197466     Cloud Builder
 | 20/7/2012     Anirudh                  197468     Updated Code to set Visibility of Speciality Tables for Distributor.
 | 16/08/2012    Anand Sharma                        updated to process country level rule only
 | 18/01/2013    Krishna Pydavula         209735     Added if condition for Speciality rules to hide the sections from the Velocity Tables based on custom settings.
 +===================================================================================================================*/
public class PRM_VPP_VelocitySpecialities {
         
    public List<Velocity_Rule_Results__c> SpecialityList = new List<Velocity_Rule_Results__c>();        
    public List<Velocity_Rule_Results__c> SpecialityRulesList1 {get;set;}    
    public List<Velocity_Rule_Results__c> SpecialityRulesList2 {get;set;}    
    public List<Velocity_Rule_Results__c> SpecialityRulesList3 {get;set;}    
    public List<Velocity_Rule_Results__c> SpecialityRulesList4 {get;set;}
    public List<Velocity_Rule_Results__c> SpecialityRulesList5 {get;set;}
    public List<Velocity_Rule_Results__c> SpecialityRulesListAvamar {get;set;}
    public List<Velocity_Rule_Results__c> SpecialityRulesListNetworker {get;set;}
    public List<SpecialityDataContainer> lstDisplayData {get; Set;}  
    public Account profiledAccount{get;set;}
    public String SpecialityStatus {get;set;}
    public Account AccountRecord  {get; set;}
    public Boolean isPartnerUser {get; set;}
    public Boolean isShowBotton {get; set;}
    //Added By Anil
    public Boolean isRenderSpeciality {get; set;} 
    //Added By Anirudh 
     public Boolean isRevenueVisible {get; set;} 
    //Added By Anil  
    public Map<String,String> fieldNamesMap = New Map<String,String>();
    public String AccountId = '';    
    
/* @Method <PRM_VPP_VelocitySpecialities(): Constructor for the Class.>
   @param - <void>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/   
   public PRM_VPP_VelocitySpecialities(){
    
        lstDisplayData = new List<SpecialityDataContainer>();
        AccountId = ApexPages.currentPage().getParameters().get('id');
        isPartnerUser = false;
        isShowBotton = false;
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
       
       system.debug('current user details ' +currentuser);
            
        if(userinfo.getUserType() == 'PowerPartner'){                   
            System.debug('currentUser Account Id-->'+currentUser.Contact.AccountId); 
           //if account is profiled account then get that account id else take its profiled account Id
           if(DistributorUserProfiles.contains(userInfo.getProfileId())) {
              System.Debug('UserProfileId' +userinfo.getProfileId());
              isRevenueVisible = false;
           }
           if(AccountId !=currentUser.Contact.AccountId && AccountId!=null){
                 isPreferredDistributorUser = preferredDistributorCheck(AccountId,currentUser.Contact.AccountId);
           }
           if(!isPreferredDistributorUser && AccountId==null){
                if(currentUser.contact.Account.PROFILED_ACCOUNT_FLAG__c==true){  
                    this.AccountId = currentUser.Contact.AccountId ;
                }                   
                else{ 
                    this.AccountId = currentUser.Contact.Account.Profiled_Account__c;
                } 
           } 
            isPartnerUser = true;  
        }else{
                if(currentUser.Velocity_Access__c){
                        isShowBotton = true;
                }
        }
        
        profiledAccount = [Select Advanced_Consolidate_Specialty__c,Backup_and_Recovery_Speciality__c,
                           Consolidate_Specialty__c,Governance_and_Archive_Specialty__c,Cluster__c,Cloud_Builder_Practice__c,
                           a.Grouping__c, a.Master_Grouping__c, a.Profiled_Account__c,Specialty_Rule_Type__c,Cloud_Provider_Practice__c,
                           a.id, a.PROFILED_ACCOUNT_FLAG__c,a.Velocity_Solution_Provider_Tier__c,Partner_Type__c
                           from Account a
                           where id=:AccountId];
        system.debug('Profiled account details '+profiledAccount);
                             
        if(profiledAccount.Cluster__c==null || profiledAccount.Specialty_Rule_Type__c==null){
              ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Velocity_Speciality_Error);
              ApexPages.addMessage(errorMessage);
              isRenderSpeciality = false;
              return;
        }
        if(isPartnerUser && currentUser.contact.Account.Partner_Type__c.contains('Distributor') 
                    && profiledAccount.Partner_Type__c.contains('Distribution VAR')
                    && (profiledAccount.Id != currentUser.contact.AccountId || (profiledAccount.Id != currentUser.contact.Account.Profiled_Account__c && currentUser.contact.Account.Profiled_Account__c !=null))
                    && (!isPreferredDistributorUser || !NonAPJDistributorUserProfiles.contains(userInfo.getProfileId()))){
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, System.Label.Insufficient_Access_To_VPP_Scorecards);
                    ApexPages.addMessage(errorMessage);
                    isRenderSpeciality = false;
                    return;     
        }                                              
        fetchSpecialityRuleResults(this.profiledAccount.Id);  
        fieldNamesMap.put(System.Label.SpecialityRule1,'Consolidate_Specialty__c');
        fieldNamesMap.put(System.Label.SpecialityRule2,'Backup_and_Recovery_Speciality__c');
        fieldNamesMap.put(System.Label.SpecialityRule3,'Advanced_Consolidate_Specialty__c');
        fieldNamesMap.put(System.Label.SpecialityRule4,'Governance_and_Archive_Specialty__c');
        fieldNamesMap.put(System.Label.SpecialityRule6,'Cloud_Builder_Practice__c');
  }

/* @Method <fetchSpecialityRuleResults(): This method would fetch all Velocity_Rule_Results records
                                          associated to Profiled Account and put them to a List based on
                                          specialty type and set the compliance status and specialty status.>
   @param - <String AccountId: Profiled Account Id>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/   
    public void fetchSpecialityRuleResults(String AccountId){
        set<Id> setRecordTypeId = new set<Id>();
        Map<String,Schema.RecordTypeInfo> recordTypes = Velocity_Rules__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        Id SpeicalityRuleRecTypeId = recordTypes.get('Specialty Rule').getRecordTypeId();
        setRecordTypeId.add(SpeicalityRuleRecTypeId);
        SpeicalityRuleRecTypeId = recordTypes.get('Field Based Rule Type').getRecordTypeId(); 
        setRecordTypeId.add(SpeicalityRuleRecTypeId);
        System.debug('SpeicalityRuleRecTypeId-->'+SpeicalityRuleRecTypeId);
        Map<String,List<Velocity_Rule_Results__c>> subListContainerMap = new Map<String,List<Velocity_Rule_Results__c>>();
        
        Map<String,VelocityRules__c> Rule1 =  VelocityRules__c.getall();
        String SpecialityRule1 = Rule1.get('SpecialityRule1').SpecialityRules__c;
        String SpecialityRule2 = Rule1.get('SpecialityRule2').SpecialityRules__c;
        String SpecialityRule3 = Rule1.get('SpecialityRule3').SpecialityRules__c;
        String SpecialityRule4 = Rule1.get('SpecialityRule4').SpecialityRules__c;
        String SpecialityRule5 = Rule1.get('SpecialityRule5').SpecialityRules__c;
        
        SpecialityRulesList1 = new List<Velocity_Rule_Results__c>();
        SpecialityRulesList2 = new List<Velocity_Rule_Results__c>();
        SpecialityRulesList3 = new List<Velocity_Rule_Results__c>();
        SpecialityRulesList4 = new List<Velocity_Rule_Results__c>();
        SpecialityRulesList5 = new List<Velocity_Rule_Results__c>();
        SpecialityRulesListAvamar = new List<Velocity_Rule_Results__c>();
        SpecialityRulesListNetworker = new List<Velocity_Rule_Results__c>();
        List<Velocity_Rule_Results__c> specialityResultRecords = [Select v.Account_Theater__c, v.AccountID__c,
                                                                 v.CurrencyIsoCode, v.Current__c, v.Grouping__c,
                                                                 v.Id, v.IsDeleted, v.Name, 
                                                                 v.Rule_theater__c, v.Speciality_RuleID__c, 
                                                                 v.Speciality_RuleID__r.RecordTypeId, 
                                                                 v.Speciality_RuleID__r.Required__c, v.Status__c,
                                                                 v.Speciality_RuleID__r.Bucket__c,
                                                                 v.Speciality_RuleID__r.Name,
                                                                 v.Speciality_RuleID__r.Required_Type__c,
                                                                 v.Speciality_RuleID__r.Display_Name__c,
                                                                 v.Speciality_RuleID__r.Id,

                                                                 v.Speciality_RuleID__r.Sort__c,
                                                                 v.Speciality_RuleID__r.BR_Sub_category__c,
                                                                 v.Required_Value_Type__c,v.RequiredCount__c,
                                                                 v.SystemModstamp,v.Speciality_RuleID__r.Specilaity__c 
                                                                 from Velocity_Rule_Results__c v  
                                                                 where 
                                                                 v.Speciality_RuleID__r.RecordTypeId in :setRecordTypeId 
                                                                 and AccountID__c=:AccountId 
                                                                 AND v.Speciality_RuleID__r.Evaluation_at__c ='Country Grouping Level'
                                                                 ORDER BY v.Speciality_RuleID__r.Sort__c];
                                        
        if(specialityResultRecords.size()>0){
            system.debug('specialityResultRecords----------->' +specialityResultRecords);
            for(Velocity_Rule_Results__c velocityRuleResult: specialityResultRecords){
                if(velocityRuleResult.Speciality_RuleID__r.Specilaity__c==SpecialityRule1){
                    SpecialityRulesList1.add(velocityRuleResult);
                }
                else if(velocityRuleResult.Speciality_RuleID__r.Specilaity__c==SpecialityRule2){
                    SpecialityRulesList2.add(velocityRuleResult);
                }
                else if(velocityRuleResult.Speciality_RuleID__r.Specilaity__c==SpecialityRule3){
                    SpecialityRulesList3.add(velocityRuleResult);
                }
                else if(velocityRuleResult.Speciality_RuleID__r.Specilaity__c==SpecialityRule4){
                    SpecialityRulesList4.add(velocityRuleResult);
                }
                else{
                    SpecialityRulesList5.add(velocityRuleResult);
                }                                       
            }                       
        }  
        system.debug('SpecialityRulesList5----------->' +SpecialityRulesList5);             
        SpecialityDataContainer objData = new SpecialityDataContainer();
         if(!(SpecialityRule1.contains('None')))
        {
            objData.SpecialityName = System.Label.SpecialityRule1;
            objData.lstVelocityRuleResult = SpecialityRulesList1;
            objData.specialityComplianceStatus=System.Label.Yes;
            objData.emcSpecialityStatus = (String) profiledAccount.get('Consolidate_Specialty__c');
            for(Velocity_Rule_Results__c ruleResult: SpecialityRulesList1){
                //if(ruleResult.Status__c==System.Label.Not_Achieved){
                if(ruleResult.Status__c=='Not Achieved'){
                    objData.specialityComplianceStatus=System.Label.No;
                    break;
                }
            }
            lstDisplayData.add(objData);
        }
        if(!(SpecialityRule2.contains('None')))
          {
                objData = new SpecialityDataContainer();
                objData.SpecialityName = System.Label.SpecialityRule2; 
                Map<String,String> complianceStatusMap = new Map<String,String> ();              
                for(Velocity_Rule_Results__c subRuleResult: SpecialityRulesList2){
                    if(subRuleResult.Speciality_RuleID__r.BR_Sub_category__c!=null){
                        if(subListContainerMap.containsKey(subRuleResult.Speciality_RuleID__r.BR_Sub_category__c)){
                            subListContainerMap.get(subRuleResult.Speciality_RuleID__r.BR_Sub_category__c).add(subRuleResult);                  
                        }
                        else{
                            subListContainerMap.put(subRuleResult.Speciality_RuleID__r.BR_Sub_category__c, 
                            new List<Velocity_Rule_Results__c>());
                            subListContainerMap.get(subRuleResult.Speciality_RuleID__r.BR_Sub_category__c).add(subRuleResult);
                        }
                    }
                }
                if(subListContainerMap.size()>0){           
                    List<SpecialitySubDataContainer> subDataContainerList = new List<SpecialitySubDataContainer>();
                    for(String subCategory : subListContainerMap.keySet()){
                        SpecialitySubDataContainer subDataContainer = new SpecialitySubDataContainer();
                        subDataContainer.subCategoryName = subCategory;
                        subDataContainer.subSpecialityStatus = System.Label.Achieved;
                        subDataContainer.lstSubVelocityRuleResult = subListContainerMap.get(subCategory);
                        complianceStatusMap.put(subCategory,System.Label.Yes) ;
                        for(Velocity_Rule_Results__c subSpecialityStatus: subDataContainer.lstSubVelocityRuleResult){
                            /* Modified the condition for specialityComplianceStatus*/
                            if(subSpecialityStatus.Status__c=='Not Achieved'){
                                subDataContainer.subSpecialityStatus = System.Label.Not_Achieved;
                                complianceStatusMap.put(subCategory,System.Label.No) ;
                                break;
                            }
                        }
                        subDataContainerList.add(subDataContainer);
                    }
                    objData.lstSpecialitySubContainer = subDataContainerList;
                    objData.lstVelocityRuleResult = null;          
                }
                else{
                  objData.lstVelocityRuleResult = SpecialityRulesList2; 
                  objData.lstSpecialitySubContainer = null;
                }
         
                objData.specialityComplianceStatus=System.Label.Yes;
                objData.emcSpecialityStatus = (String) profiledAccount.get('Backup_and_Recovery_Speciality__c');
                for(Velocity_Rule_Results__c ruleResult: SpecialityRulesList2){
                        if(ruleResult.Status__c=='Not Achieved'){
                        objData.specialityComplianceStatus=System.Label.No;
                        break;
                    }
                } 
               /* for(String complianceStatus : complianceStatusMap.keyset()){
                        if(complianceStatusMap.get(complianceStatus) == System.Label.Yes ){
                           objData.specialityComplianceStatus=System.Label.Yes;   
                           break ;
                        }
                }*/
                 
                lstDisplayData.add(objData);
          }  
          if(!(SpecialityRule3.contains('None'))) 
            {
                objData = new SpecialityDataContainer();
                objData.SpecialityName = System.Label.SpecialityRule3;
                objData.lstVelocityRuleResult = SpecialityRulesList3;
                objData.specialityComplianceStatus=System.Label.Yes;
                objData.emcSpecialityStatus = (String)profiledAccount.get('Advanced_Consolidate_Specialty__c');
                for(Velocity_Rule_Results__c ruleResult: SpecialityRulesList3){
                         if(ruleResult.Status__c=='Not Achieved'){
                        objData.specialityComplianceStatus=System.Label.No;
                        break;
                    }
                }
                lstDisplayData.add(objData);
            } 
         if(!(SpecialityRule4.contains('None')))
            {   
                objData = new SpecialityDataContainer();
                objData.SpecialityName = System.Label.SpecialityRule4;
                objData.lstVelocityRuleResult = SpecialityRulesList4;
                objData.specialityComplianceStatus=System.Label.Yes;
                objData.emcSpecialityStatus = (String)profiledAccount.get('Governance_and_Archive_Specialty__c');
                for(Velocity_Rule_Results__c ruleResult: SpecialityRulesList4){
                         if(ruleResult.Status__c=='Not Achieved'){
                        objData.specialityComplianceStatus=System.Label.No;
                        break;
                    }
                }
                lstDisplayData.add(objData);        
                System.debug('lstDisplayData---> +' + lstDisplayData);
         }
         if(!(SpecialityRule5.contains('None')))  
            {
                objData = new SpecialityDataContainer();
                objData.SpecialityName = System.Label.SpecialityRule6;
                objData.lstVelocityRuleResult = SpecialityRulesList5;
                objData.specialityComplianceStatus=System.Label.Yes;
                objData.emcSpecialityStatus = (String)profiledAccount.get('Cloud_Builder_Practice__c');
                for(Velocity_Rule_Results__c ruleResult: SpecialityRulesList5){
                         if(ruleResult.Status__c=='Not Achieved'){
                        objData.specialityComplianceStatus=System.Label.No;
                        break;
                    }
                }
                lstDisplayData.add(objData); 
           }
    }       
    

/* @Method <getEMCSpecialityStatusItems(): This method would provide the select options to set
                                            the speciality status to Deployed or Not Deployed.>
   @param - <void>
   @return <List<SelectOption>> 
   @throws exception - <No Exception>
*/     
    public List<SelectOption> getEMCSpecialityStatusItems() {
        List<SelectOption> options = new List<SelectOption>();      
        options.add(new SelectOption('Deployed','Deployed'));
        options.add(new SelectOption('Not Deployed','Not Deployed'));        
        return options;
    }

/* @Method <updateProfileAccount(): This method is used to update the Speciality status of
                                    associated Profiled Account from UI.>
   @param - <void>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/     
    public void updateProfileAccount(){
        try{
            for(SpecialityDataContainer objSpecDataContainer :lstDisplayData){
                profiledAccount.put(fieldNamesMap.get(objSpecDataContainer.SpecialityName),objSpecDataContainer.emcSpecialityStatus);            
            }
            List<Account> lstAccount = new List<Account>();
            lstAccount.add(profiledAccount);
            Database.Saveresult[] sr = DataBase.update(lstAccount);
        }
        Catch(Exception ex){      
           ApexPages.addMessages(ex);
        }
    }  
    
/* @Method <cancelUpdates(): This method is used to cancel the Speciality status updates of
                             associated Profiled Account from UI.>
   @param - <void>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/     
    public pageReference cancelUpdates(){
        PageReference returnPage = new PageReference('/'+profiledAccount.Id);
        returnPage.setredirect(true);
        return returnPage;
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
    
    //Wrapper class to hold specialty details associated to each specialty  
    public class SpecialityDataContainer{
        //HOlds SpecialtyNames
        public String SpecialityName {get; Set;}
        //HOlds Velocity_Rule_Results__c for each specialty
        public List<Velocity_Rule_Results__c> lstVelocityRuleResult {get; set;}
        //HOlds ComplianceStatus for each specialty
        public String specialityComplianceStatus {get; set;}
        //HOlds emcSpecialityStatus for each specialty
        public String emcSpecialityStatus {get; set;}             
        public List<SpecialitySubDataContainer> lstSpecialitySubContainer {get; set;} 
    }
    
    //Wrapper class to hold sub-Specialty details associated to each specialty 
    public class SpecialitySubDataContainer{
        public List<Velocity_Rule_Results__c> lstSubVelocityRuleResult{get; set;}
        public String subCategoryName {get; set;}
        public String subSpecialityStatus {get; set;}    
    }
}