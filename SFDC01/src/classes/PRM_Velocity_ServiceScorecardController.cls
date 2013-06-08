/*======================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 06/03/2012    Suman B                           This is used as controller Class for PRM_Velocity_Service_Scorecard.
 | 13/03/2012    Suman B                           Added method to save  Status (VS_Rule_Result_Status__c) changes  of the 
 |                                                 Service Scorecard in the VelocityRuleResults and profied Account.
 | 20/7/2012     Anirudh                  197468   Updated Code to set Visibility of Scorecard Tables for Distributor.
 | 18/09/2012    Jayaraju                 199687   Updated Code to set Deployment Status to 'Deployed' - UpdateDeploymentStatus() 
 | 26/09/2012    Anirudh                           Updated code to show error message if the Distributor user is trying to view the
 |                                                 scorecard of Distribution VAR in PAN/Logical Block Model.
 |15/10/2012    Satish                   202572    Updated code to display new section Velocity Service Assembly in scorecard.
 |03/03/2013    Altaf                    235810     Added line to set the default satus to deployed. ERFC March 03 2013                                
 +========================================================================================================*/
public class PRM_Velocity_ServiceScorecardController {

    public List<Velocity_Rule_Results__c> SpecialityList = new List<Velocity_Rule_Results__c>();        
    public List<Velocity_Rule_Results__c> ServiceRuleList1 {get;set;}    
    public List<Velocity_Rule_Results__c> ServiceRuleList2 {get;set;}    
    public List<Velocity_Rule_Results__c> ServiceRuleList3 {get;set;}    
    public List<Velocity_Rule_Results__c> ServiceRuleList4 {get;set;}
    public List<Velocity_Rule_Results__c> ServiceRuleList5 {get;set;}
    public List<Velocity_Rule_Results__c> ServiceRuleList6 {get;set;}  
    public List<ServiceDataContainer> lstDisplayData {get; Set;}
    public Account profiledAccount{get;set;}
    public String SpecialityStatus {get;set;}
    public Account AccountRecord  {get; set;}
    public Boolean isPartnerUser {get; set;}
    public Boolean isShowBotton {get; set;}
    //Added By Anil
    public Boolean isRenderSpeciality {get; set;}  
    //Added By Anirudh 
    public Boolean isRevenueVisible {get; set;} 
    public ID AccountId ;  
  
    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
    
    
/* @Method <PRM_VPP_VelocitySpecialities(): Constructor for the Class.>
   @param - <void>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/   
   public PRM_Velocity_ServiceScorecardController(){    
        lstDisplayData = new List<ServiceDataContainer>();        
        this.AccountId = ApexPages.currentPage().getParameters().get('id');
        CustomSettingDataValueMap__c profileDetails = DataValueMap.get('Service Scorecard profile');  
        CustomSettingDataValueMap__c theaterDetails = DataValueMap.get('Service Scorecard theater');        
        isPartnerUser = false;
        isShowBotton = false;
        isRenderSpeciality = true;  
        isRevenueVisible = true;
        boolean isPreferredDistributorUser = false;        
        string DistributorUserProfiles = DataValueMap.get('Distributor Partner Users').DataValue__c; 
        string NonAPJDistributorUserProfiles = DataValueMap.get('NonAPJ Distributor Users').DataValue__c;               
        // get profiled account Id from partner user contact 
        User currentUser = [Select u.ContactId, u.Contact.AccountId,contact.Account.PROFILED_ACCOUNT_FLAG__c,
                                contact.Account.Profiled_Account__c,u.Velocity_Access__c, u.Co_Op_Access__c,
                                contact.Account.Partner_Type__c,contact.Account.Account_Level__c 
                                from User u 
                                where id=:userinfo.getUserId()];                              
       
       if(profileDetails != Null) {
            string strProfileId = userinfo.getProfileId() ;                 
            strProfileId = strProfileId.substring(0,15);
            if(profileDetails.DataValue__c.contains(strProfileId) ) {
               isShowBotton = true;
            }
       }
        if(userinfo.getUserType() == 'PowerPartner'){ 
            if(DistributorUserProfiles.contains(userInfo.getProfileId())) {
              System.Debug('UserProfileId' +userinfo.getProfileId());
              isRevenueVisible = false;
           }
           if(AccountId != null && ((string)AccountId).startswith('001')){
              profiledAccount = [Select Id,Account_Level__c from Account where Id =:AccountId];
           }                   
            System.debug('currentUser Account Id-->'+currentUser.Contact.AccountId);
          
           //if account is profiled account then get that account id else take its profiled account Id 
               if(AccountId != null && AccountId !=currentUser.Contact.AccountId &&
                  AccountId != currentUser.Contact.Account.Profiled_Account__c && currentUser.Contact.Account.Account_Level__c != 'NONE'
                  && profiledAccount.Account_Level__c != 'COUNTRY' ){
                  ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, System.Label.Insufficient_Access_To_VPP_Scorecards);
                  ApexPages.addMessage(errorMessage);
                  isRenderSpeciality = false;
                  return; 
               }            
               if(AccountId != null && AccountId !=currentUser.Contact.AccountId){
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
        }
        
        profiledAccount = [Select Advanced_Consolidate_Specialty__c,Backup_and_Recovery_Speciality__c,
                           Consolidate_Specialty__c,Governance_and_Archive_Specialty__c,Cluster__c,Deployed_Velocity_Services__c,
                           a.Grouping__c, a.Master_Grouping__c, a.Profiled_Account__c,Specialty_Rule_Type__c,Partner_Type__c,
                           a.id, a.PROFILED_ACCOUNT_FLAG__c,a.Velocity_Solution_Provider_Tier__c ,Theater1__c
                           from Account a
                           where id=: this.AccountId];

       if(theaterDetails != Null) {
            if(!theaterDetails.DataValue__c.contains(profiledAccount.Theater1__c) ) {
              ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Velocity_Service_Error);
              ApexPages.addMessage(errorMessage);
              isRenderSpeciality = false;
              return;
            }
       }       
    
        if((profiledAccount.Velocity_Solution_Provider_Tier__c == null ) ) {
          ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.VSI_Tier_Error_Message);
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
      
        System.debug('isRevenueVisible'+isRevenueVisible);
        fetchSpecialityRuleResults(this.profiledAccount.Id);  
  }

/* @Method <fetchSpecialityRuleResults(): This method would fetch all Velocity_Rule_Results records
                                          associated to Profiled Account and put them to a List based on
                                          specialty type and set the compliance status and specialty status.>
   @param - <String AccountId: Profiled Account Id>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/   
    public void fetchSpecialityRuleResults(String AccountId){
        Map<String,Schema.RecordTypeInfo> recordTypes = Velocity_Rules__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        Id ServiceRuleRecTypeId = recordTypes.get('Services Rule').getRecordTypeId();
        System.debug('ServiceRuleRecTypeId-->'+ServiceRuleRecTypeId);
        Map<String,List<Velocity_Rule_Results__c>> subListContainerMap = new Map<String,List<Velocity_Rule_Results__c>>();
        
        Map<String,VelocityRules__c> Rule1 =  VelocityRules__c.getall();
        String ServiceRule1 = Rule1.get('ServiceRule1').SpecialityRules__c;
        String ServiceRule2 = Rule1.get('ServiceRule2').SpecialityRules__c;
        String ServiceRule3 = Rule1.get('ServiceRule3').SpecialityRules__c;
        String ServiceRule4 = Rule1.get('ServiceRule4').SpecialityRules__c;
        String ServiceRule5 = Rule1.get('ServiceRule5').SpecialityRules__c;
        String ServiceRule6 = Rule1.get('ServiceRule6').SpecialityRules__c;
        
        ServiceRuleList1 = new List<Velocity_Rule_Results__c>();
        ServiceRuleList2 = new List<Velocity_Rule_Results__c>();
        ServiceRuleList3 = new List<Velocity_Rule_Results__c>();
        ServiceRuleList4 = new List<Velocity_Rule_Results__c>();
        ServiceRuleList5 = new List<Velocity_Rule_Results__c>();
        ServiceRuleList6 = new List<Velocity_Rule_Results__c>(); 
                
        List<Velocity_Rule_Results__c> serviceResultRecords = [Select v.Account_Theater__c, v.AccountID__c,
                                                                 v.CurrencyIsoCode, v.Current__c, v.Grouping__c,
                                                                 v.Id, v.IsDeleted, v.Name, v.VS_Rule_Result_Status__c,
                                                                 v.VS_Rule_Result_Display_Name__c,v.VS_Rule_Result_Section__c,
                                                                 v.Rule_theater__c, v.Speciality_RuleID__c, 
                                                                 v.Speciality_RuleID__r.RecordTypeId, 
                                                                 v.Speciality_RuleID__r.Required__c, v.Status__c,
                                                                 v.Speciality_RuleID__r.Bucket__c,
                                                                 v.Speciality_RuleID__r.Name,
                                                                 v.Speciality_RuleID__r.Required_Type__c,
                                                                 v.Speciality_RuleID__r.Display_Name__c,
                                                                 v.Speciality_RuleID__r.Id,v.Speciality_RuleID__r.VS_Section__c,

                                                                 v.Speciality_RuleID__r.Sort__c,
                                                                 v.Speciality_RuleID__r.BR_Sub_category__c,
                                                                 v.Required_Value_Type__c,v.RequiredCount__c,
                                                                 v.SystemModstamp,v.Speciality_RuleID__r.Specilaity__c 
                                                                 from Velocity_Rule_Results__c v  
                                                                 where 
                                                                 v.Speciality_RuleID__r.RecordTypeId=:ServiceRuleRecTypeId 
                                                                 and AccountID__c=:AccountId 
                                                                 ORDER BY v.Speciality_RuleID__r.Sort__c];
                                        
        if(serviceResultRecords.size()>0){
            
            //Added by Jayaraju Nulakachandanam as part of Oct'12 Release,WR-199687
            List<Velocity_Rule_Results__c> finalServiceResult = new List<Velocity_Rule_Results__c>();
            finalServiceResult = UpdateDeploymentStatus(serviceResultRecords);
            
            //Added by Jayaraju Nulakachandanam as part of Oct'12 Release,WR-199687
            
            for(Velocity_Rule_Results__c velocityRuleResult: serviceResultRecords){
                if(velocityRuleResult.Speciality_RuleID__r.VS_Section__c ==ServiceRule1){
                    ServiceRuleList1.add(velocityRuleResult);
                }
                else if(velocityRuleResult.Speciality_RuleID__r.VS_Section__c ==ServiceRule2){
                    ServiceRuleList2.add(velocityRuleResult);
                }
                else if(velocityRuleResult.Speciality_RuleID__r.VS_Section__c ==ServiceRule3){
                    ServiceRuleList3.add(velocityRuleResult);
                }
                else if(velocityRuleResult.Speciality_RuleID__r.VS_Section__c ==ServiceRule4){
                    ServiceRuleList4.add(velocityRuleResult);
                }
                else if(velocityRuleResult.Speciality_RuleID__r.VS_Section__c ==ServiceRule5){
                    ServiceRuleList5.add(velocityRuleResult);
                }  
                 else if(velocityRuleResult.Speciality_RuleID__r.VS_Section__c ==ServiceRule6){
                    ServiceRuleList6.add(velocityRuleResult);
                }                                                          
            }                       
        }               
        ServiceDataContainer objData = new ServiceDataContainer();
        objData.ServiceName = System.Label.ServiceRule1;
        objData.lstVelocityRuleResult = ServiceRuleList1;
        objData.ServiceResourceLabel = true ;
        //objData.specialityComplianceStatus=System.Label.Yes;
        lstDisplayData.add(objData);
        
        objData = new ServiceDataContainer();
        objData.ServiceName = System.Label.ServiceRule2;
        objData.lstVelocityRuleResult = ServiceRuleList2;
        objData.ServiceResourceLabel = true ;
        lstDisplayData.add(objData);

        objData = new ServiceDataContainer();
        objData.ServiceName = System.Label.ServiceRule3;
        objData.lstVelocityRuleResult = ServiceRuleList3;
        lstDisplayData.add(objData);
        
        objData = new ServiceDataContainer();
        objData.ServiceName = System.Label.ServiceRule4;
        objData.lstVelocityRuleResult = ServiceRuleList4;
        lstDisplayData.add(objData);
        
        objData = new ServiceDataContainer();
        objData.ServiceName = System.Label.ServiceRule5;
        objData.lstVelocityRuleResult = ServiceRuleList5;
        lstDisplayData.add(objData);
            
        objData = new ServiceDataContainer();
        objData.ServiceName = System.Label.ServiceRule6;
        objData.lstVelocityRuleResult = ServiceRuleList6;
        lstDisplayData.add(objData);
            
        System.debug('lstDisplayData---' + lstDisplayData);
    }       
    


/* @Method <updateProfileAccount(): This method is used to update the VS_Rule_Result_Status__c of
                                    associated Profiled Account from UI.>
   @param - <void>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/     
    public void updateProfileAccount(){
        String strDeployedVelocityServices ='';
        List<Velocity_Rule_Results__c> lstVRResultUpdate = new List<Velocity_Rule_Results__c>();
        List<Account> lstAccount = new List<Account>();
        /**/try{
            
            for(ServiceDataContainer objSpecDataContainer :lstDisplayData){
                List<Velocity_Rule_Results__c> lstVRResult = objSpecDataContainer.lstVelocityRuleResult;
                for(Velocity_Rule_Results__c vRuleResult: lstVRResult){
                    if(vRuleResult.VS_Rule_Result_Status__c=='Deployed'){
                        System.debug('vRuleResult.VS_Rule_Result_Status__c---> +' + vRuleResult.VS_Rule_Result_Status__c);
                        System.debug('vRuleResult.Speciality_RuleID__r.VS_Section__c ---> +' + vRuleResult.Speciality_RuleID__r.VS_Section__c );
                        if((vRuleResult.Speciality_RuleID__r.VS_Section__c !=null && vRuleResult.Speciality_RuleID__r.VS_Section__c !='') &&
                            (vRuleResult.VS_Rule_Result_Display_Name__c != null && vRuleResult.VS_Rule_Result_Display_Name__c !='') ){                          
                            strDeployedVelocityServices = strDeployedVelocityServices + vRuleResult.Speciality_RuleID__r.VS_Section__c + ' ' + vRuleResult.VS_Rule_Result_Display_Name__c +'; ';
                            System.debug('strDeployedVelocityServices--->1 +' + strDeployedVelocityServices);                           
                        }                       
                    }
                    lstVRResultUpdate.add(vRuleResult);
                }
                
            }
            if(strDeployedVelocityServices.endsWith(';')){
                strDeployedVelocityServices = strDeployedVelocityServices.substring(0,strDeployedVelocityServices.length() -2);
            }
            profiledAccount.put('Deployed_Velocity_Services__c',strDeployedVelocityServices);
            System.debug('strDeployedVelocityServices---> +' + strDeployedVelocityServices);
            //lstAccount.add(profiledAccount);
            update profiledAccount;
            Database.Saveresult[] srVRR = DataBase.update(lstVRResultUpdate, false);
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
    
    //Wrapper class to hold Service details associated to each Velocity Service  
    public class ServiceDataContainer{
        //HOlds SpecialtyNames
        public String ServiceName {get; Set;}
        //HOlds Velocity_Rule_Results__c for each Velcoity Service 
        public List<Velocity_Rule_Results__c> lstVelocityRuleResult {get; set;}
        //HOlds ComplianceStatus for each specialty
        public String specialityComplianceStatus {get; set;}
        //HOlds emcSpecialityStatus for each specialty
        public String emcSpecialityStatus {get; set;}
        
        public boolean ServiceResourceLabel {get; Set;}                     
    }

/* @Method <UpdateDeploymentStatus(): This method is used to update the Deployment Status to 'Deployed' when a new Velocity Services record is created>
   Added By : Jayaraju Nulakachandanam
   Release : Oct'12 Release
   Requirement : WR-199687
*/

   public List<Velocity_Rule_Results__c> UpdateDeploymentStatus(List<Velocity_Rule_Results__c> VelocityStatus){
    
        lstDisplayData = new List<ServiceDataContainer>();
        date myDate = date.today();
        List<Velocity_Rule_Results__c> objvelocity = new List<Velocity_Rule_Results__c>();
        
            List<Services__c> ser = [select id,Partner_Account__c,name,Services_Program_Designation__c,Products__c,Partner_Deployment_End_Date__c  from Services__c where Partner_Account__c =:AccountId];
            Map<String,Services__c> serviceMap = new Map<String,Services__c>();
            string spd_product;
      try{
            for(Services__c objserv:ser){
                spd_product = objserv.Services_Program_Designation__c+'|'+objserv.Products__c;
                serviceMap.put(spd_product,objserv);
            }
            Services__c serv2;  
            for(Velocity_Rule_Results__c objres:VelocityStatus){ 
                         system.debug('Velocity Services Account '+objres.AccountID__c);
                         system.debug('Velocity Services Result Section '+objres.VS_Rule_Result_Section__c);
                         system.debug('Velocity Services Result Display Name '+objres.VS_Rule_Result_Display_Name__c);
            //List<Services__c> ser = [select id,Partner_Account__c,name,Services_Program_Designation__c,Products__c,Partner_Deployment_End_Date__c  from Services__c where Partner_Account__c =:objres.AccountID__c and Services_Program_Designation__c=:objres.VS_Rule_Result_Section__c and Products__c=:objres.VS_Rule_Result_Display_Name__c];
            system.debug('Velocity Services'+ser);
                objres.VS_Rule_Result_Status__c='Not Deployed';           
                string vsspd_product;
                vsspd_product = objres.VS_Rule_Result_Section__c+'|'+objres.VS_Rule_Result_Display_Name__c;
                serv2 = serviceMap.get(vsspd_product);
                if(serv2 != null){
                    if (serv2.Partner_Deployment_End_Date__c>=myDate){
                        objres.VS_Rule_Result_Status__c='Deployed';
                    }
                    else{
                        objres.VS_Rule_Result_Status__c='Not Deployed';
                    }
                }               
                
                objvelocity .add(objres);
            }
          
         }
        Catch(Exception ex){      
           ApexPages.addMessages(ex);
        } 
        system.debug('objvelocity objvelocity '+objvelocity);
        return objvelocity;
    }  //End of the method, UpdateDeploymentStatus()
     
    
}