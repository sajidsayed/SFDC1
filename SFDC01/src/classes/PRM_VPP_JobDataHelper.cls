/*=====================================================================================================+
|  HISTORY  |                                                                           
|  DATE          DEVELOPER        WR                    DESCRIPTION                               
|  ====          =========        ==                    =========== 
|   21-Oct-2011   Suman B        Helper Class           This test class is used to Create Data for VPP Job
|                                                       Classes
|   10-11-2011    Suman B                               Added customsetting values for test data.
|   27 Dec 2011   Arif                                  Changed the profiled ids from 15 digit to 18 digit for 'PSC User'
|   03 Feb 2012   Kaustav                               Added code for adding partner leverage custom settings creation      
|   02 Apr 2012   Kaustav                               Added code for Revenue custom settings creation  
|   02 Apr 2012   Kaustav                               Added code for VSI Velocity Scorecard custom settings creation 
|   06 Apr 2012   Anil                                  Added GAF related Custom Setting Records
|   25 May 2012   Anil                                  Added Contact Record Type Records
|   2 Aug 2012    Arif                                  Added 'SpecialityRule5' in VelocityRules custom setting
|   3 Aug 2012    Anirudh                               Added 'Reassign Distributor Users' and 'Distributor Partner Users'  custom setting 
|   17 Aug 2012   Kaustav                               Added eBusiness custom setting records
|   05 Oct 2012   Kaustav                               Commented eBusiness custom setting records
|   28 Feb 2013   Krishna Pydavula  209736              Added GAF with Isilon custom setting records
+=====================================================================================================*/

public class PRM_VPP_JobDataHelper {

    /* @Method <This method is to check the customsettingdata for VPP jobs.>
       @param void
       @return void>
    */  
    @future 
    public static void createVPPCustomSettingData(){
       //Custom setting creation -- DATAVALUE MAP 
       Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
       Map<String,PRM_PAN_VPP_Bucket_Container__c> PANVPPBucketContainer = PRM_PAN_VPP_Bucket_Container__c.getAll();
       List<CustomSettingDataValueMap__c> customSettingsData = new List<CustomSettingDataValueMap__c>();
       List<PRM_PAN_VPP_Bucket_Container__c> BucketContainerData = new List<PRM_PAN_VPP_Bucket_Container__c>();
       CustomSettingDataValueMap__c jobObjectDetails = DataValueMap.get('PRMVPPALLJobExecution');
       CustomSettingDataValueMap__c jobVelocityRuleCheckDetails = DataValueMap.get('PRMVPPDeleteJobExecutionVelocityRule');
       CustomSettingDataValueMap__c jobObjectTheater = DataValueMap.get('RunAllJobs_Theater');
       CustomSettingDataValueMap__c jobObjectEval_Theater = DataValueMap.get('RunAllJobsEval_Theater');
       CustomSettingDataValueMap__c PRMVPPJobRunning = DataValueMap.get('PRMVPPJobRunning');  
       CustomSettingDataValueMap__c EMEADistributionVARPartnerUser = DataValueMap.get('EMEA Distribution VAR Partner User');
       CustomSettingDataValueMap__c EMEADistributorSuperUser = DataValueMap.get('EMEA Distributor Super User');
       CustomSettingDataValueMap__c DealRegistration = DataValueMap.get('DealRegistration');
       CustomSettingDataValueMap__c SuperUser = DataValueMap.get('Super User');
       CustomSettingDataValueMap__c SuperUser1 = DataValueMap.get('Super User1');
       CustomSettingDataValueMap__c Myeducationreport = DataValueMap.get('My Education Report');
       CustomSettingDataValueMap__c bookedPartnerPerfRatingRecType = DataValueMap.get('Booked_Part_Perf_Rating_Opp_RecType');
       CustomSettingDataValueMap__c seSkillRatingEditRecType = DataValueMap.get('SE Skill & Sales Acumen Rating Edit');
       CustomSettingDataValueMap__c newBookedOppRecType = DataValueMap.get('New_Booked_Opportunity_Record_Type');
       CustomSettingDataValueMap__c userAttrSalesRoles1 = DataValueMap.get('User_attribute_Mapping_Sales_Role_1');
       CustomSettingDataValueMap__c userAttrSalesRoles2 = DataValueMap.get('User_attribute_Mapping_Sales_Role_2');
       CustomSettingDataValueMap__c seSkillRatingValidatedRecType = DataValueMap.get('SE_Skill_Sales_Acumen_Rating_Validated');
       CustomSettingDataValueMap__c partnerSESkillIsInsert = DataValueMap.get('PRM_PL_Is_Insert_Execute');
       CustomSettingDataValueMap__c partnerSESkillSalesFields = DataValueMap.get('PRM_PL_SE_Sales_Fields');
       CustomSettingDataValueMap__c partnerSESkillSkillsFields = DataValueMap.get('PRM_PL_SE_Skill_Fields');
       CustomSettingDataValueMap__c partnerSESkillTotalFields = DataValueMap.get('PRM_PL_Expertise_Total_Fields');
       CustomSettingDataValueMap__c partnerLeverageMaxScoreTarget = DataValueMap.get('PRM_PL_Max_Score_Target');
       CustomSettingDataValueMap__c customSettingAPI = DataValueMap.get('PRM_PL_API_User'); 
       
       CustomSettingDataValueMap__c Service_Scorecard_profile = DataValueMap.get('Service Scorecard profile'); 
       CustomSettingDataValueMap__c Service_Scorecard_theater = DataValueMap.get('Service Scorecard theater'); 
       CustomSettingDataValueMap__c TierRequirementSequenceForNA = DataValueMap.get('TierRequirementSequenceForNA'); 
       //GAF
       CustomSettingDataValueMap__c GAFAmerDirectAndVAR = DataValueMap.get('GAFAmerDirectAndVAR'); 
       CustomSettingDataValueMap__c GAFAmerDirectDistiApproved = DataValueMap.get('GAFAmerDirectDistiApproved'); 
       CustomSettingDataValueMap__c GAFAmerDistiApproved = DataValueMap.get('GAFAmerDistiApproved'); 
       CustomSettingDataValueMap__c GAFAmerDistributor = DataValueMap.get('GAFAmerDistributor'); 
       CustomSettingDataValueMap__c GAFEMEADirectAndVAR = DataValueMap.get('GAFEMEADirectAndVAR'); 
       CustomSettingDataValueMap__c GAFEMEADirectVARApproved = DataValueMap.get('GAFEMEADirectVARApproved'); 
       CustomSettingDataValueMap__c GAFEMEADistiApproved = DataValueMap.get('GAFEMEADistiApproved'); 
       CustomSettingDataValueMap__c GAFEMEADistributor = DataValueMap.get('GAFEMEADistributor'); 
       //GAF with Isilon    
       CustomSettingDataValueMap__c GAFEMEADirectVARApprovedOld = DataValueMap.get('GAFEMEADirectVARApprovedOld'); 
       CustomSettingDataValueMap__c GAFEMEADirectAndVAROld = DataValueMap.get('GAFEMEADirectAndVAROld'); 
       CustomSettingDataValueMap__c GAFAmerDirectDistiApprovedOld = DataValueMap.get('GAFAmerDirectDistiApprovedOld'); 
       CustomSettingDataValueMap__c GAFAmerDirectAndVAROld = DataValueMap.get('GAFAmerDirectAndVAROld'); 
       //Contact Functional Area
       CustomSettingDataValueMap__c FunctionalAreaRecordType = DataValueMap.get('PRM_FA_EMC_BR_Rec_Type'); 
       CustomSettingDataValueMap__c FunctionalAreaTheaterScheduled = DataValueMap.get('IS_FA_Scheduled_Theaters'); 
       //Added for VPP Scorecard controller
       CustomSettingDataValueMap__c PRMVPPEMEASignatureValue = DataValueMap.get('PRMVPPEMEASignatureValue');
       CustomSettingDataValueMap__c PRMVPPDistributorValue = DataValueMap.get('PRMVPPDistributorValue');
       CustomSettingDataValueMap__c SequenceOfTiers = DataValueMap.get('SequenceOfTiers');       
       //Contact Record Types
       CustomSettingDataValueMap__c PartnerSEVARRecordType = DataValueMap.get('Partner SE VAR Record Type');
       CustomSettingDataValueMap__c StandardContactRecordType = DataValueMap.get('Standard Contact Record Type');
       CustomSettingDataValueMap__c PartnerSEDistiDirResellRecType = DataValueMap.get('Partner SE Disti/Dir Resell Rec Type');
       CustomSettingDataValueMap__c PartnerContactRecordType = DataValueMap.get('Partner Contact Record Type');
       CustomSettingDataValueMap__c DistributionVARContactRecordType = DataValueMap.get('Distribution VAR Contact Record Type');
       CustomSettingDataValueMap__c APJPartnerUserProfiles= DataValueMap.get('APJPartnerUsers');
       CustomSettingDataValueMap__c ReassigningDistributorUsers= DataValueMap.get('Reassigning Distributor Users');
       CustomSettingDataValueMap__c ReassignDisVarUserExcludeValues= DataValueMap.get('ReassignDisVarUserExcludeValues');
       CustomSettingDataValueMap__c DistributorPartnerUsers= DataValueMap.get('Distributor Partner Users');
       CustomSettingDataValueMap__c NonAPJDistributorUsers= DataValueMap.get('NonAPJ Distributor Users'); 
       CustomSettingDataValueMap__c ESBI_VPP_Scheduled_Theaters = DataValueMap.get('ESBI_VPP_Scheduled_Theaters');
       CustomSettingDataValueMap__c ESBI_VPP_Scheduled_Jobs = DataValueMap.get('ESBI_VPP_Scheduled_Jobs');
       CustomSettingDataValueMap__c TartgetTierTheaters = DataValueMap.get('TartgetTierTheaters');
       CustomSettingDataValueMap__c PANSpecilities = DataValueMap.get('PANSpecilities');       
             
       List<RecordType> lstRecordType= [Select Id,Name,sobjecttype from recordType where sobjecttype in ('Partner_SE_Skill_Sales_Acumen_Rating__c','GAF__c','Contact')];
       List<Recordtype> lstRecType = new List<RecordType>();
       List<Recordtype> lstGAFRecType = new List<RecordType>();
       List<Recordtype> lstContactRecType = new List<RecordType>();
       for(RecordType recTypeObj :lstRecordType){
           if(recTypeObj.SobjectType=='Partner_SE_Skill_Sales_Acumen_Rating__c'){
              lstRecType.add(recTypeObj); 
           }
           if(recTypeObj.SobjectType=='GAF__c'){
              lstGAFRecType.add(recTypeObj);
           }    
           if(recTypeObj.SobjectType=='Contact'){
              lstContactRecType.add(recTypeObj);
           }
       }
       
       //List<Recordtype> lstRecType=[select id,name from recordtype where sobjecttype='Partner_SE_Skill_Sales_Acumen_Rating__c'];
      // List<Recordtype> lstGAFRecType=[Select id, name from recordtype where sobjecttype='GAF__c'];
       //List<Recordtype> lstContactRecType=[select id,name from recordtype where sobjecttype='Contact']; 
       String strSESkillEdit;
       String strSESkillValidated;
       for(Recordtype rec:lstRecType)
          {
            if(rec.name=='SE Skill & Sales Acumen Rating Edit')
            {
                strSESkillEdit=rec.id;
            }
            else if(rec.name=='SE Skill & Sales Acumen Rating Validated')
            {
                strSESkillValidated=rec.id;
            }
          }
      //Checking  Customsetting records.
        if(jobObjectDetails == null){
          jobObjectDetails = new CustomSettingDataValueMap__c(Name = 'PRMVPPALLJobExecution');
          jobObjectDetails.DataValue__c = 'true' ;
          customSettingsData.add(jobObjectDetails);
        }
        if(jobVelocityRuleCheckDetails == null){
          jobVelocityRuleCheckDetails = new CustomSettingDataValueMap__c(Name = 'PRMVPPDeleteJobExecutionVelocityRule');
          jobVelocityRuleCheckDetails.DataValue__c = 'true' ;
          customSettingsData.add(jobVelocityRuleCheckDetails);
        }
        if(PRMVPPJobRunning == null){
          PRMVPPJobRunning = new CustomSettingDataValueMap__c(Name = 'PRMVPPJobRunning');
          customSettingsData.add(PRMVPPJobRunning);
        }
        if(EMEADistributionVARPartnerUser == null){
          EMEADistributionVARPartnerUser = new CustomSettingDataValueMap__c(Name = 'EMEA Distribution VAR Partner User');
          EMEADistributionVARPartnerUser.DataValue__c  = 'EMEA Distribution VAR Partner User';
          customSettingsData.add(EMEADistributionVARPartnerUser);
        }
        if(EMEADistributorSuperUser == null){
          EMEADistributorSuperUser = new CustomSettingDataValueMap__c(Name = 'EMEA Distributor Super User');
          EMEADistributorSuperUser.DataValue__c  = 'EMEA Distributor Super User';
          customSettingsData.add(EMEADistributorSuperUser);
        }
        if(DealRegistration == null){
          DealRegistration = new CustomSettingDataValueMap__c(Name = 'DealRegistration');
          DealRegistration.DataValue__c  = '01270000000Q7MDAA0,01270000000Q7MSAA0,01270000000Q7MNAA0,01270000000Q7MIAA0';
          customSettingsData.add(DealRegistration);
        }
        if(SuperUser == null){
          SuperUser = new CustomSettingDataValueMap__c(Name = 'Super User');
          SuperUser.DataValue__c  = '00e70000001FhQLAA000e70000001Fh0TAAS00e70000001Fh0XAAS00e70000001Fh0mAAC00e70000001FhQVAA000e70000001FhQkAAK00e70000001FhPrAAK00e70000001FhQuAAK00e70000001FhQaAAK00e70000001FhQBAA000e70000001FhQ1AAK00e70000001Fbr1AAC00e70000001FbrBAAS';
          customSettingsData.add(SuperUser);
        }
         if(SuperUser1 == null){
          SuperUser1 = new CustomSettingDataValueMap__c(Name = 'Super User1');
          SuperUser1.DataValue__c  = '00e70000001FbrLAAS00e70000001FbrGAAS';
          customSettingsData.add(SuperUser1);
        }
        if(customSettingAPI == null){
          customSettingAPI = new CustomSettingDataValueMap__c(Name = 'PRM_PL_API_User');
          customSettingAPI.DataValue__c = '00570000001L8zrAAC' ;
          customSettingsData.add(customSettingAPI);
        }
               
        if(Service_Scorecard_profile == null){
          Service_Scorecard_profile = new CustomSettingDataValueMap__c(Name = 'Service Scorecard profile');
          Service_Scorecard_profile.DataValue__c = '00e70000001FhFN,00e70000000wBza,00e70000000wRaB,00e70000000wYhy,00e70000001FgoT,00e70000001FiPn,00e70000001FacU' ;
          customSettingsData.add(Service_Scorecard_profile);
        }
        if(Service_Scorecard_theater == null){
          Service_Scorecard_theater = new CustomSettingDataValueMap__c(Name = 'Service Scorecard theater');
          Service_Scorecard_theater.DataValue__c = 'Americas,EMEA' ;
          customSettingsData.add(Service_Scorecard_theater);
        }
        
        if(TierRequirementSequenceForNA == null){
          TierRequirementSequenceForNA = new CustomSettingDataValueMap__c(Name = 'TierRequirementSequenceForNA');
          TierRequirementSequenceForNA.DataValue__c = 'Velocity Program,Revenue,Training,VSI' ;
          customSettingsData.add(TierRequirementSequenceForNA);
        }
        //Contact Custom Setting Record for Record Types
        if(PartnerSEVARRecordType == null){
          PartnerSEVARRecordType = new CustomSettingDataValueMap__c(Name = 'Partner SE VAR Record Type');
          PartnerSEVARRecordType.DataValue__c = lstContactRecType[0].id ;
          customSettingsData.add(PartnerSEVARRecordType);
          }
          if(StandardContactRecordType == null){
          StandardContactRecordType = new CustomSettingDataValueMap__c(Name = 'Standard Contact Record Type');
          StandardContactRecordType.DataValue__c = lstContactRecType[0].id ;
          customSettingsData.add(StandardContactRecordType);
          }
          if(PartnerSEDistiDirResellRecType == null){
          PartnerSEDistiDirResellRecType = new CustomSettingDataValueMap__c(Name = 'Partner SE Disti/Dir Resell Rec Type');
          PartnerSEDistiDirResellRecType.DataValue__c = lstContactRecType[0].id ;
          customSettingsData.add(PartnerSEDistiDirResellRecType);
          }
          if(PartnerContactRecordType == null){
          PartnerContactRecordType = new CustomSettingDataValueMap__c(Name = 'Partner Contact Record Type');
          PartnerContactRecordType.DataValue__c = lstContactRecType[0].id ;
          customSettingsData.add(PartnerContactRecordType);
          }
          if(DistributionVARContactRecordType == null){
          DistributionVARContactRecordType = new CustomSettingDataValueMap__c(Name = 'Distribution VAR Contact Record Type');
          DistributionVARContactRecordType.DataValue__c = lstContactRecType[0].id ;
          customSettingsData.add(DistributionVARContactRecordType);
          }        
        // GAF Custom Setting Creation
         if(GAFAmerDirectAndVAR == null){
          GAFAmerDirectAndVAR = new CustomSettingDataValueMap__c(Name = 'GAFAmerDirectAndVAR');
          GAFAmerDirectAndVAR.DataValue__c = lstGAFRecType[0].id ;
          customSettingsData.add(GAFAmerDirectAndVAR);
        }
         if(GAFAmerDirectDistiApproved == null){
          GAFAmerDirectDistiApproved = new CustomSettingDataValueMap__c(Name = 'GAFAmerDirectDistiApproved');
          GAFAmerDirectDistiApproved.DataValue__c = lstGAFRecType[1].id ;
          customSettingsData.add(GAFAmerDirectDistiApproved);
        }
         if(GAFAmerDistiApproved == null){
          GAFAmerDistiApproved = new CustomSettingDataValueMap__c(Name = 'GAFAmerDistiApproved');
          GAFAmerDistiApproved.DataValue__c = lstGAFRecType[2].id ;
          customSettingsData.add(GAFAmerDistiApproved);
        }
         if(GAFAmerDistributor == null){
          GAFAmerDistributor = new CustomSettingDataValueMap__c(Name = 'GAFAmerDistributor');
          GAFAmerDistributor.DataValue__c = lstGAFRecType[3].id ;
          customSettingsData.add(GAFAmerDistributor);
        }
         if(GAFEMEADirectAndVAR == null){
          GAFEMEADirectAndVAR = new CustomSettingDataValueMap__c(Name = 'GAFEMEADirectAndVAR');
          GAFEMEADirectAndVAR.DataValue__c = lstGAFRecType[0].id ;
          customSettingsData.add(GAFEMEADirectAndVAR);
        }
         if(GAFEMEADirectVARApproved == null){
          GAFEMEADirectVARApproved = new CustomSettingDataValueMap__c(Name = 'GAFEMEADirectVARApproved');
          GAFEMEADirectVARApproved.DataValue__c = lstGAFRecType[0].id ;
          customSettingsData.add(GAFEMEADirectVARApproved);
        }
         if(GAFEMEADistiApproved == null){
          GAFEMEADistiApproved = new CustomSettingDataValueMap__c(Name = 'GAFEMEADistiApproved');
          GAFEMEADistiApproved.DataValue__c = lstGAFRecType[0].id ;
          customSettingsData.add(GAFEMEADistiApproved);
        }
         if(GAFEMEADistributor == null){
          GAFEMEADistributor = new CustomSettingDataValueMap__c(Name = 'GAFEMEADistributor');
          GAFEMEADistributor.DataValue__c = lstGAFRecType[0].id ;
          customSettingsData.add(GAFEMEADistributor);
        }
         //GAF with Isilon
        if(GAFEMEADirectVARApprovedOld == null){
          GAFEMEADirectVARApprovedOld = new CustomSettingDataValueMap__c(Name = 'GAFEMEADirectVARApprovedOld');
          GAFEMEADirectVARApprovedOld.DataValue__c = lstGAFRecType[0].id ;
          customSettingsData.add(GAFEMEADirectVARApprovedOld);
        }
        if(GAFEMEADirectAndVAROld == null){
          GAFEMEADirectAndVAROld = new CustomSettingDataValueMap__c(Name = 'GAFEMEADirectAndVAROld');
          GAFEMEADirectAndVAROld.DataValue__c = lstGAFRecType[0].id ;
          customSettingsData.add(GAFEMEADirectAndVAROld);
        }
        if(GAFAmerDirectDistiApprovedOld == null){
          GAFAmerDirectDistiApprovedOld = new CustomSettingDataValueMap__c(Name = 'GAFAmerDirectDistiApprovedOld');
          GAFAmerDirectDistiApprovedOld.DataValue__c = lstGAFRecType[0].id ;
          customSettingsData.add(GAFAmerDirectDistiApprovedOld);
        }
        if(GAFAmerDirectAndVAROld == null){
          GAFAmerDirectAndVAROld = new CustomSettingDataValueMap__c(Name = 'GAFAmerDirectAndVAROld');
          GAFAmerDirectAndVAROld.DataValue__c = lstGAFRecType[0].id ;
          customSettingsData.add(GAFAmerDirectAndVAROld);
        }
        // For VPP Standard Controller
        if(PRMVPPEMEASignatureValue == null){
          PRMVPPEMEASignatureValue = new CustomSettingDataValueMap__c(Name = 'PRMVPPEMEASignatureValue');
          PRMVPPEMEASignatureValue.DataValue__c = 'Signature / SSCP' ;
          customSettingsData.add(PRMVPPEMEASignatureValue);
        }
        if(PRMVPPDistributorValue == null){
          PRMVPPDistributorValue = new CustomSettingDataValueMap__c(Name = 'PRMVPPDistributorValue');
          PRMVPPDistributorValue.DataValue__c = 'Distributor' ;
          customSettingsData.add(PRMVPPDistributorValue);
        }
        if(SequenceOfTiers == null){
          SequenceOfTiers = new CustomSettingDataValueMap__c(Name = 'SequenceOfTiers');
          SequenceOfTiers.DataValue__c = 'Affiliate,Affiliate Elite,Premier,Signature' ;
          customSettingsData.add(SequenceOfTiers);
        }
        
        if(DataValueMap.get('Tier2 Partner Type')==null)
        {
            CustomSettingDataValueMap__c csTestData2=new CustomSettingDataValueMap__c();
            csTestData2.name='Tier2 Partner Type';    
            csTestData2.DataValue__c='Distribution VAR';
            csTestData2.DateValue__c=12;
            customSettingsData.add(csTestData2);
        }        
        if(DataValueMap.get('Direct Reseller Partner Type')==null)
        {
            CustomSettingDataValueMap__c csTestData3=new CustomSettingDataValueMap__c();
            csTestData3.name='Direct Reseller Partner Type';    
            csTestData3.DataValue__c='Direct Reseller';
            csTestData3.DateValue__c=12;
            customSettingsData.add(csTestData3);           
        }               
        if(DataValueMap.get('Distributor Partner Type')==null)
        {
            CustomSettingDataValueMap__c csTestData4=new CustomSettingDataValueMap__c();
            csTestData4.name='Distributor Partner Type';    
            csTestData4.DataValue__c='Distributor';
            csTestData4.DateValue__c=12;
            customSettingsData.add(csTestData4);            
        }        
        if(DataValueMap.get('DealregDistributorType')==null)
        {
            CustomSettingDataValueMap__c csTestData5=new CustomSettingDataValueMap__c();
            csTestData5.name='DealregDistributorType';    
            csTestData5.DataValue__c='Distributor';
            csTestData5.DateValue__c=12;
            customSettingsData.add(csTestData5);            
        }        
        if(DataValueMap.get('DealregDistributionVarType')==null)
        {
            CustomSettingDataValueMap__c csTestData6=new CustomSettingDataValueMap__c();
            csTestData6.name='DealregDistributionVarType';    
            csTestData6.DataValue__c='Distribution VAR';
            csTestData6.DateValue__c=12;
            customSettingsData.add(csTestData6);           
        }        
        if(DataValueMap.get('DealregDistributorResellerType')==null)
        {
            CustomSettingDataValueMap__c csTestData7=new CustomSettingDataValueMap__c();
            csTestData7.name='DealregDistributorResellerType';    
            csTestData7.DataValue__c='Direct Reseller';
            csTestData7.DateValue__c=12;
            customSettingsData.add(csTestData7);            
        }        
        if(DataValueMap.get('Admin Users')==null)
        {
            CustomSettingDataValueMap__c csTestData8=new CustomSettingDataValueMap__c();
            csTestData8.name='Admin Users';    
            csTestData8.DataValue__c='00e70000000wBza;00e70000000wRaB;00e70000000wYhy;00e70000001FgoT;';
            csTestData8.DateValue__c=12;
            customSettingsData.add(csTestData8);            
        }        
        if(DataValueMap.get('Dealreg Accessible Link')==null)
        {
            CustomSettingDataValueMap__c csTestData15=new CustomSettingDataValueMap__c();
            csTestData15.name='Dealreg Accessible Link';    
            csTestData15.DataValue__c='http://powerlink.emc.com/';
            csTestData15.DateValue__c=12;
            customSettingsData.add(csTestData15);            
        }
        
        if(DataValueMap.get('ProductAccountDefaultTier')==null)
        {
            CustomSettingDataValueMap__c csTestData16=new CustomSettingDataValueMap__c();
            csTestData16.name='ProductAccountDefaultTier';    
            csTestData16.DataValue__c='No Partner Tier';
            csTestData16.DateValue__c=12;
            customSettingsData.add(csTestData16);          
        }
        
        if(DataValueMap.get('SiteUserId')==null)
        {
            CustomSettingDataValueMap__c csTestData17=new CustomSettingDataValueMap__c();
            csTestData17.name='SiteUserId';    
            csTestData17.DataValue__c='00570000001ex5a';
            csTestData17.DateValue__c=12;
            customSettingsData.add(csTestData17);            
        }
        if(DataValueMap.get('DealregDirectRepRoleOrder')==null)
        {
            CustomSettingDataValueMap__c csTestData20=new CustomSettingDataValueMap__c();
            csTestData20.name='DealregDirectRepRoleOrder';    
            csTestData20.DataValue__c='SALES-SMB SALES REP;Sales-Commercial Sales Rep;Sales-Enterprise Farmer Rep;Sales-Enterprise Hunter Rep;Sales-Sales Rep';
            csTestData20.DateValue__c=12;
            customSettingsData.add(csTestData20);
           
        }
        
        if(DataValueMap.get('DealRegOpportunityStage')==null)
        {
            CustomSettingDataValueMap__c csTestData21=new CustomSettingDataValueMap__c();
            csTestData21.name='DealRegOpportunityStage';    
            csTestData21.DataValue__c='Booked';
            csTestData21.DateValue__c=12;
            customSettingsData.add(csTestData21);
        }
        if(DataValueMap.get('ESBI_Int_Control_Flag_Sequence')==null)
        {
            CustomSettingDataValueMap__c ESBIIntControlFlagSequence=new CustomSettingDataValueMap__c();
            ESBIIntControlFlagSequence.name='ESBI_Int_Control_Flag_Sequence';    
            ESBIIntControlFlagSequence.DataValue__c='86';
            customSettingsData.add(ESBIIntControlFlagSequence);
        }
        
        if(DataValueMap.get('ESBI_VPP_Scheduled_Theaters')==null)
        {
            CustomSettingDataValueMap__c ESBIVPPScheduledTheaters=new CustomSettingDataValueMap__c();
            ESBIVPPScheduledTheaters.name='ESBI_VPP_Scheduled_Theaters';    
            ESBIVPPScheduledTheaters.DataValue__c='APJ,EMEA,Americas';
            customSettingsData.add(ESBIVPPScheduledTheaters);
        }
        
        if(DataValueMap.get('EMEA Direct Reseller Partner User')==null)
        {
            CustomSettingDataValueMap__c EMEADirectResellerPartnerUser=new CustomSettingDataValueMap__c();
            EMEADirectResellerPartnerUser.name='EMEA Direct Reseller Partner User';
            EMEADirectResellerPartnerUser.DataValue__c  = 'EMEA Direct Reseller Partner User';
            customSettingsData.add(EMEADirectResellerPartnerUser);
        }
        if(DataValueMap.get('AccountShareSchedularTimeInterval')==null)
        {
            CustomSettingDataValueMap__c AccountShareSchedularTimeInterval=new CustomSettingDataValueMap__c();
            AccountShareSchedularTimeInterval.name='AccountShareSchedularTimeInterval';
            AccountShareSchedularTimeInterval.DataValue__c  = '1440';
            customSettingsData.add(AccountShareSchedularTimeInterval);
        }
        if(Myeducationreport==null)
        {
          Myeducationreport = new CustomSettingDataValueMap__c(Name = 'My Education Report');
            Myeducationreport.DataValue__c='00O70000002otpe';
            customSettingsData.add(Myeducationreport);            
        }
        if(DataValueMap.get('EducationQueueId')==null)
        {
            CustomSettingDataValueMap__c EducationQueueId=new CustomSettingDataValueMap__c();
            EducationQueueId.name='EducationQueueId';    
            EducationQueueId.DataValue__c='00G70000001lAEf';
            customSettingsData.add(EducationQueueId);
        }
         if(DataValueMap.get('dealRegSetOfRoles')==null)
        {
            CustomSettingDataValueMap__c dealRegSetOfRoles=new CustomSettingDataValueMap__c();
            dealRegSetOfRoles.Name='dealRegSetOfRoles';
            dealRegSetOfRoles.DataValue__c='Sales-Sales Rep;Sales-Commercial Sales Rep;CHANNEL-EXECUTION SALES REP;Sales-Partner Enterprise Rep;Sales-Inside Partner Terr Rep;Sales-Partner Territory Rep;Sales-Enterprise Farmer Rep;Sales-Enterprise Hunter Rep;BRS-Sales Rep';
            customSettingsData.add(dealRegSetOfRoles);
        }
          if(DataValueMap.get('RunAllJobsEval_Theater')==null)
        {
            CustomSettingDataValueMap__c RunAllJobsEvalTheater=new CustomSettingDataValueMap__c();
            RunAllJobsEvalTheater.name='RunAllJobsEval_Theater';    
            RunAllJobsEvalTheater.DataValue__c='false';
            customSettingsData.add(RunAllJobsEvalTheater);           
        }
        if(DataValueMap.get('RunAllJobs_Theater')==null)
        {
            CustomSettingDataValueMap__c RunAllJobsTheater=new CustomSettingDataValueMap__c();
            RunAllJobsTheater.name='RunAllJobs_Theater';    
            RunAllJobsTheater.DataValue__c='APJ';
            customSettingsData.add(RunAllJobsTheater);           
        }  
         if(DataValueMap.get('AmericasDistributorCAP')==null)
        {
        CustomSettingDataValueMap__c AmericasDistributorCAP = new CustomSettingDataValueMap__c();
        AmericasDistributorCAP.Name ='AmericasDistributorCAP';
        AmericasDistributorCAP.DataValue__c ='01270000000Q6UyAAK';
        customSettingsData.add(AmericasDistributorCAP);
        }
         if(DataValueMap.get('AmericasResellerCAP')==null)
        {
        CustomSettingDataValueMap__c AmericasResellerCAP = new CustomSettingDataValueMap__c();
        AmericasResellerCAP.Name ='AmericasResellerCAP';
        AmericasResellerCAP.DataValue__c ='01270000000Q6V0AAK';
        customSettingsData.add(AmericasResellerCAP);
        }
        if(DataValueMap.get('DealRegistrationPartnerVsDealStatus')==null)
        {
        CustomSettingDataValueMap__c DealRegistrationPartnerVsDealStatus = new CustomSettingDataValueMap__c();
        DealRegistrationPartnerVsDealStatus.Name ='DealRegistrationPartnerVsDealStatus';
        DealRegistrationPartnerVsDealStatus.DataValue__c ='Closed-Lost';
        customSettingsData.add(DealRegistrationPartnerVsDealStatus);
        }
        
         if(DataValueMap.get('APJDistributorCAP')==null)
        {
        CustomSettingDataValueMap__c APJDistributorCAP = new CustomSettingDataValueMap__c();
        APJDistributorCAP.Name ='APJDistributorCAP';
        APJDistributorCAP.DataValue__c ='01270000000Q6UuAAK';
        customSettingsData.add(APJDistributorCAP);
        }
         if(DataValueMap.get('APJResellerCAP')==null)
        {
        CustomSettingDataValueMap__c APJResellerCAP = new CustomSettingDataValueMap__c();
        APJResellerCAP.Name ='APJResellerCAP';
        APJResellerCAP.DataValue__c ='01270000000Q6UwAAK';
        customSettingsData.add(APJResellerCAP);
        }
         if(DataValueMap.get('EMEADistributorCAP')==null)
        {
        CustomSettingDataValueMap__c EMEADistributorCAP= new CustomSettingDataValueMap__c();
        EMEADistributorCAP.Name ='EMEADistributorCAP';
        EMEADistributorCAP.DataValue__c ='01270000000Q6V2AAK';
        customSettingsData.add(EMEADistributorCAP);
        }
         if(DataValueMap.get('EMEAResellerCAP')==null)
        {
        CustomSettingDataValueMap__c EMEAResellerCAP = new CustomSettingDataValueMap__c();
        EMEAResellerCAP.Name ='EMEAResellerCAP';
        EMEAResellerCAP.DataValue__c ='01270000000Q6V4AAK';
        customSettingsData.add(EMEAResellerCAP);
        }
         if(DataValueMap.get('AmericasObjective')==null)
        {
        CustomSettingDataValueMap__c AmericasObjective= new CustomSettingDataValueMap__c();
        AmericasObjective.Name ='AmericasObjective';
        AmericasObjective.DataValue__c ='01270000000Q6V8';
        customSettingsData.add(AmericasObjective);
        }
         if(DataValueMap.get('APJObjective')==null)
        {
        CustomSettingDataValueMap__c APJObjective = new CustomSettingDataValueMap__c();
        APJObjective.Name ='APJObjective';
        APJObjective.DataValue__c ='01270000000Q6V6';
        customSettingsData.add(APJObjective);
        }
         if(DataValueMap.get('EMEAObjective')==null)
        {
        CustomSettingDataValueMap__c EMEAObjective = new CustomSettingDataValueMap__c();
        EMEAObjective.Name ='EMEAObjective';
        EMEAObjective.DataValue__c ='01270000000Q6VA';
        customSettingsData.add(EMEAObjective);
        }
         if(DataValueMap.get('AmericasMarketing')==null)
        {
        CustomSettingDataValueMap__c AmericasMarketing = new CustomSettingDataValueMap__c();
        AmericasMarketing.Name ='AmericasMarketing';
        AmericasMarketing.DataValue__c ='00G70000001l9oX';
        customSettingsData.add(AmericasMarketing);
        }
         if(DataValueMap.get('APJMarketing')==null)
        {
        CustomSettingDataValueMap__c APJMarketing = new CustomSettingDataValueMap__c();
        APJMarketing.Name ='APJMarketing';
        APJMarketing.DataValue__c ='00G70000001l9oc';
        customSettingsData.add(APJMarketing);
        }
         if(DataValueMap.get('PRMVPPALLJobExecution')==null)
        {
        CustomSettingDataValueMap__c PRMVPPALLJobExecution = new CustomSettingDataValueMap__c();
        PRMVPPALLJobExecution.Name ='PRMVPPALLJobExecution';
        PRMVPPALLJobExecution.DataValue__c ='true';
        customSettingsData.add(PRMVPPALLJobExecution);
        }        
         if(DataValueMap.get('EMEAMarketing')==null)
        {
        CustomSettingDataValueMap__c EMEAMarketing = new CustomSettingDataValueMap__c();
        EMEAMarketing.Name ='EMEAMarketing';
        EMEAMarketing.DataValue__c ='00G70000001l9qO';
        customSettingsData.add(EMEAMarketing);
        }
         if(DataValueMap.get('AmericasDistributorCAPLocked')==null)
        {
        CustomSettingDataValueMap__c AmericasDistributorCAPLocked = new CustomSettingDataValueMap__c();
        AmericasDistributorCAPLocked.Name ='AmericasDistributorCAPLocked';
        AmericasDistributorCAPLocked.DataValue__c ='01270000000Q6UzAAK';
        customSettingsData.add(AmericasDistributorCAPLocked);
        }
         if(DataValueMap.get('AmericasObjectiveLocked')==null)
        {
        CustomSettingDataValueMap__c AmericasObjectiveLocked = new CustomSettingDataValueMap__c();
        AmericasObjectiveLocked.Name ='AmericasObjectiveLocked';
        AmericasObjectiveLocked.DataValue__c ='01270000000Q6V9';
        customSettingsData.add(AmericasObjectiveLocked);
        }
         if(DataValueMap.get('AmericasResellerCAPLocked')==null)
        {
        CustomSettingDataValueMap__c AmericasResellerCAPLocked = new CustomSettingDataValueMap__c();
        AmericasResellerCAPLocked.Name ='AmericasResellerCAPLocked';
        AmericasResellerCAPLocked.DataValue__c ='01270000000Q6V1AAK';
        customSettingsData.add(AmericasResellerCAPLocked);
        }
         if(DataValueMap.get('APJObjectiveLocked')==null)
        {
        CustomSettingDataValueMap__c APJObjectiveLocked = new CustomSettingDataValueMap__c();
        APJObjectiveLocked.Name ='APJObjectiveLocked';
        APJObjectiveLocked.DataValue__c ='01270000000Q6V7';
        customSettingsData.add(APJObjectiveLocked);
        }
         if(DataValueMap.get('APJDistributorCAPLocked')==null)
        {
        CustomSettingDataValueMap__c APJDistributorCAPLocked = new CustomSettingDataValueMap__c();
        APJDistributorCAPLocked.Name ='APJDistributorCAPLocked';
        APJDistributorCAPLocked.DataValue__c ='01270000000Q6UvAAK';
        customSettingsData.add(APJDistributorCAPLocked);
        }
         if(DataValueMap.get('APJResellerCAPLocked')==null)
        {
        CustomSettingDataValueMap__c APJResellerCAPLocked = new CustomSettingDataValueMap__c();
        APJResellerCAPLocked.Name ='APJResellerCAPLocked';
        APJResellerCAPLocked.DataValue__c ='01270000000Q6UxAAK';
        customSettingsData.add(APJResellerCAPLocked);
        }
         if(DataValueMap.get('EMEAObjectiveLocked')==null)
        {
        CustomSettingDataValueMap__c EMEAObjectiveLocked = new CustomSettingDataValueMap__c();
        EMEAObjectiveLocked.Name ='EMEAObjectiveLocked';
        EMEAObjectiveLocked.DataValue__c ='01270000000Q6VB';
        customSettingsData.add(EMEAObjectiveLocked);
        }
         if(DataValueMap.get('EMEADistributorCAPLocked')==null)
        {
        CustomSettingDataValueMap__c EMEADistributorCAPLocked = new CustomSettingDataValueMap__c();
        EMEADistributorCAPLocked.Name ='EMEADistributorCAPLocked';
        EMEADistributorCAPLocked.DataValue__c ='01270000000Q6V3AAK';
        customSettingsData.add(EMEADistributorCAPLocked);
        }
        if(DataValueMap.get('EMEAResellerCAPLocked')==null)
        {
        CustomSettingDataValueMap__c EMEAResellerCAPLocked = new CustomSettingDataValueMap__c();
        EMEAResellerCAPLocked.Name ='EMEAResellerCAPLocked';
        EMEAResellerCAPLocked.DataValue__c ='01270000000Q6V5AAK';
        customSettingsData.add(EMEAResellerCAPLocked);
        }
        if(DataValueMap.get('PSC User')==null)
        {
        CustomSettingDataValueMap__c PSCUser = new CustomSettingDataValueMap__c();
        PSCUser.Name ='PSC User';
        PSCUser.DataValue__c ='00e70000001FbTOAA0;00e70000001FbTYAA0;00e70000001FbTdAAK;00e70000001FbTTAA0';
        customSettingsData.add(PSCUser);
        }
        if(DataValueMap.get('PSC User Error MSG')==null)
        {
        CustomSettingDataValueMap__c PSCUserErrorMSG = new CustomSettingDataValueMap__c();
        PSCUserErrorMSG.Name ='PSC User Error MSG';
        PSCUserErrorMSG.DataValue__c ='You cannot Accept this Deal Registration.';
        customSettingsData.add(PSCUserErrorMSG);
        }
        if(DataValueMap.get('EMEA Distributor Partner User')==null)
        {
        CustomSettingDataValueMap__c EMEADistributorPartnerUser = new CustomSettingDataValueMap__c();
        EMEADistributorPartnerUser.Name ='EMEA Distributor Partner User';
        EMEADistributorPartnerUser.DataValue__c ='EMEA Distributor Partner User';
        customSettingsData.add(EMEADistributorPartnerUser);
        }
        if(DataValueMap.get('EducationDeleteScheduleTime')==null)
        {
        CustomSettingDataValueMap__c EducationDeleteScheduleTime = new CustomSettingDataValueMap__c();
        EducationDeleteScheduleTime.Name ='EducationDeleteScheduleTime';
        String todaydate=String.valueOfGmt(System.today());
        EducationDeleteScheduleTime.DataValue__c =todaydate;
        customSettingsData.add(EducationDeleteScheduleTime);
        }
         if(DataValueMap.get('March')==null)
        {
        CustomSettingDataValueMap__c March = new CustomSettingDataValueMap__c();
        March.Name ='March';
        March.DateValue__c =3;
        customSettingsData.add(March);
        }
        if(DataValueMap.get('June')==null)
        {
        CustomSettingDataValueMap__c June = new CustomSettingDataValueMap__c();
        June.Name ='June';
        June.DateValue__c =6;
        customSettingsData.add(June);
        }
        if(DataValueMap.get('September')==null)
        {
        CustomSettingDataValueMap__c September = new CustomSettingDataValueMap__c();
        September.Name ='September';
        September.DateValue__c =9;
        customSettingsData.add(September);
        }
        if(DataValueMap.get('December')==null)
        {
        CustomSettingDataValueMap__c December = new CustomSettingDataValueMap__c();
        December.Name ='December';
        December.DateValue__c=12;
        customSettingsData.add(December);
        }
        if(DataValueMap.get('Thirty')==null)
        {
        CustomSettingDataValueMap__c Thirty = new CustomSettingDataValueMap__c();
        Thirty.Name ='Thirty';
        Thirty.DateValue__c =30;
        customSettingsData.add(Thirty);
        }
        if(DataValueMap.get('ThirtyFirst')==null)
        {
        CustomSettingDataValueMap__c ThirtyFirst = new CustomSettingDataValueMap__c();
        ThirtyFirst.Name ='ThirtyFirst';
        ThirtyFirst.DateValue__c =31;
        customSettingsData.add(ThirtyFirst);
        }
        if(DataValueMap.get('System Administrator')==null)
        {
        CustomSettingDataValueMap__c SystemAdministrator = new CustomSettingDataValueMap__c();
        SystemAdministrator.Name ='System Administrator';
        SystemAdministrator.DataValue__c ='00e70000000wBza';
        customSettingsData.add(SystemAdministrator);
        }
         if(DataValueMap.get('Partner Type')==null)
        {
        CustomSettingDataValueMap__c PartnerType = new CustomSettingDataValueMap__c();
        PartnerType.Name ='Partner Type';
        PartnerType.DataValue__c ='Systems Integrator;ISV;OEM';
        customSettingsData.add(PartnerType);
        }
          if(DataValueMap.get('Standard Account Record Type')==null)
        {
        CustomSettingDataValueMap__c StandardAccountRecordType = new CustomSettingDataValueMap__c();
        StandardAccountRecordType.Name ='Standard Account Record Type';
        StandardAccountRecordType.DataValue__c ='012700000005Ili';
        customSettingsData.add(StandardAccountRecordType);
        }
        if(DataValueMap.get('AMERStrategy')==null)
        {
        CustomSettingDataValueMap__c AMERStrategy = new CustomSettingDataValueMap__c();
        AMERStrategy.Name ='AMERStrategy';
        AMERStrategy.DataValue__c ='01270000000Q87i';
        customSettingsData.add(AMERStrategy);
        }
        if(DataValueMap.get('EMEAStrategy')==null)
        {
        CustomSettingDataValueMap__c EMEAStrategy = new CustomSettingDataValueMap__c();
        EMEAStrategy.Name ='EMEAStrategy';
        EMEAStrategy.DataValue__c ='01270000000Q87s';
        customSettingsData.add(EMEAStrategy);
        }
        if(DataValueMap.get('APJStrategy')==null)
        {
        CustomSettingDataValueMap__c APJStrategy = new CustomSettingDataValueMap__c();
        APJStrategy.Name ='APJStrategy';
        APJStrategy.DataValue__c ='01270000000Q87n';
        customSettingsData.add(APJStrategy);
        }      
        
         if(DataValueMap.get('AMERStrategyLocked')==null)
        {
        CustomSettingDataValueMap__c AMERStrategyLocked = new CustomSettingDataValueMap__c();
        AMERStrategyLocked.Name ='AMERStrategyLocked';
        AMERStrategyLocked.DataValue__c ='01270000000Q87i';
        customSettingsData.add(AMERStrategyLocked);
        }
        if(DataValueMap.get('EMEAStrategyLocked')==null)
        {
        CustomSettingDataValueMap__c EMEAStrategyLocked = new CustomSettingDataValueMap__c();
        EMEAStrategyLocked.Name ='EMEAStrategyLocked';
        EMEAStrategyLocked.DataValue__c ='01270000000Q87s';
        customSettingsData.add(EMEAStrategyLocked);
        }
        if(DataValueMap.get('APJStrategyLocked')==null)
        {
        CustomSettingDataValueMap__c APJStrategyLocked = new CustomSettingDataValueMap__c();
        APJStrategyLocked.Name ='APJStrategyLocked';
        APJStrategyLocked.DataValue__c ='01270000000Q87n';
        customSettingsData.add(APJStrategyLocked);
        }  
                
        if(DataValueMap.get('EMEA') == null){
            CustomSettingDataValueMap__c EMEA= new CustomSettingDataValueMap__c();
            EMEA.Name ='EMEA';
            EMEA.DataValue__c ='00e70000001FbTT';
            customSettingsData.add(EMEA);
        }    
        if(DataValueMap.get('Americas') == null){
            CustomSettingDataValueMap__c Americas= new CustomSettingDataValueMap__c();
            Americas.Name ='Americas';
            Americas.DataValue__c ='00e70000001FbTO';
            customSettingsData.add(Americas);
        } 
        if(DataValueMap.get('APJ') == null){
            CustomSettingDataValueMap__c APJ= new CustomSettingDataValueMap__c();
            APJ.Name ='APJ';
            APJ.DataValue__c ='00e70000001FbTY,00e70000001FbTd';
            customSettingsData.add(APJ);
        }
        if(DataValueMap.get('PRM_PL_EMC_BR_PL_Rec_type') == null){
            CustomSettingDataValueMap__c PRM_PL_EMC_BR_PL_Rec_type= new CustomSettingDataValueMap__c();
            PRM_PL_EMC_BR_PL_Rec_type.Name ='PRM_PL_EMC_BR_PL_Rec_type';
            PRM_PL_EMC_BR_PL_Rec_type.DataValue__c ='012V0000000Cl6z';
            customSettingsData.add(PRM_PL_EMC_BR_PL_Rec_type);
        }
         if(DataValueMap.get('PRM_PL_Part_Perf_Email_Notify') == null){
            CustomSettingDataValueMap__c PRM_PL_Part_Perf_Email_Notify= new CustomSettingDataValueMap__c();
            PRM_PL_Part_Perf_Email_Notify.Name ='PRM_PL_Part_Perf_Email_Notify';
            PRM_PL_Part_Perf_Email_Notify.DataValue__c ='00XV0000000HvUw';
            customSettingsData.add(PRM_PL_Part_Perf_Email_Notify);
        }   
        if(bookedPartnerPerfRatingRecType == null){
          bookedPartnerPerfRatingRecType = new CustomSettingDataValueMap__c(Name = 'Booked_Part_Perf_Rating_Opp_RecType');
          bookedPartnerPerfRatingRecType.DataValue__c = '01270000000Q42jAAC' ;
          customSettingsData.add(bookedPartnerPerfRatingRecType);
        }
        if(seSkillRatingEditRecType == null){
          seSkillRatingEditRecType = new CustomSettingDataValueMap__c(Name = 'SE Skill & Sales Acumen Rating Edit');
          if(strSESkillEdit!=null)
          seSkillRatingEditRecType.DataValue__c = strSESkillEdit ;
          customSettingsData.add(seSkillRatingEditRecType);
        }
        
        if(newBookedOppRecType == null){
          newBookedOppRecType = new CustomSettingDataValueMap__c(Name = 'New_Booked_Opportunity_Record_Type');
          newBookedOppRecType.DataValue__c = '01270000000Q42jAAC' ;
          customSettingsData.add(newBookedOppRecType);
        }
        
        if(userAttrSalesRoles1 == null){
          userAttrSalesRoles1 = new CustomSettingDataValueMap__c(Name = 'User_attribute_Mapping_Sales_Role_1');
          userAttrSalesRoles1.DataValue__c = 'avamar district mgr,bura district mgr,commercial dm,commercial volume dm,district mgr,enterprise bura dm' ;
          customSettingsData.add(userAttrSalesRoles1);
        }
        
        if(userAttrSalesRoles2 == null){
          userAttrSalesRoles2 = new CustomSettingDataValueMap__c(Name = 'User_attribute_Mapping_Sales_Role_2');
          userAttrSalesRoles2.DataValue__c = 'enterprise dm,ts bura district mgr,ts district mgr,wysdm field rep,wysdm mgr' ;
          customSettingsData.add(userAttrSalesRoles2);
        }
        
        if(seSkillRatingValidatedRecType == null){
          seSkillRatingValidatedRecType = new CustomSettingDataValueMap__c(Name = 'SE_Skill_Sales_Acumen_Rating_Validated');
          if(strSESkillValidated!=null)
          seSkillRatingValidatedRecType.DataValue__c = strSESkillValidated;
          customSettingsData.add(seSkillRatingValidatedRecType);
        }
        if(partnerSESkillIsInsert == null){
          partnerSESkillIsInsert = new CustomSettingDataValueMap__c(Name = 'PRM_PL_Is_Insert_Execute');
          if(strSESkillValidated!=null)
          partnerSESkillIsInsert.DataValue__c = 'true';
          customSettingsData.add(partnerSESkillIsInsert);
        }
        
         if(partnerSESkillSalesFields == null){
          partnerSESkillSalesFields = new CustomSettingDataValueMap__c(Name = 'PRM_PL_SE_Sales_Fields');
          if(strSESkillValidated!=null)
          partnerSESkillSalesFields.DataValue__c = 'BRS_Avamar_Sales__c,BRS_Data_Domain_Sales__c,BRS_Networker_Sales__c,IP_Networking_Sales__c,Isilon_Sales__c,Replication_Sales__c,RSA_Security_Sales__c,Symmetrix_Sales__c,Unified_Sales__c,VCE_Sales__c,VMware_Sales__c';
          customSettingsData.add(partnerSESkillSalesFields);
        }
        if(partnerSESkillSkillsFields == null){
          partnerSESkillSkillsFields = new CustomSettingDataValueMap__c(Name = 'PRM_PL_SE_Skill_Fields');
          if(strSESkillValidated!=null)
          partnerSESkillSkillsFields.DataValue__c = 'BRS_Avamar_Skill__c,BRS_Data_Domain_Skill__c,BRS_Networker_Skill__c,IP_Networking_Skill__c,Isilon_Skill__c,Replication_Skill__c,RSA_Security_Skill__c,Symmetrix_Skill__c,Unified_Skill__c,VCE_Skill__c,VMware_Skill__c';
          customSettingsData.add(partnerSESkillSkillsFields);
        }
        if(partnerSESkillTotalFields == null){
          partnerSESkillTotalFields = new CustomSettingDataValueMap__c(Name = 'PRM_PL_Expertise_Total_Fields');
          if(partnerSESkillTotalFields!=null)
          partnerSESkillTotalFields.DataValue__c = 'Oracle_App_Competence__c,SAP_App_Competence__c,SQL_App_Competence__c,VCE_App_Competence__c,VMware_App_Competence__c';
          customSettingsData.add(partnerSESkillTotalFields);
        }
        if(partnerLeverageMaxScoreTarget == null){
          partnerLeverageMaxScoreTarget = new CustomSettingDataValueMap__c(Name = 'PRM_PL_Max_Score_Target');
          if(partnerLeverageMaxScoreTarget!=null)
          partnerLeverageMaxScoreTarget.DataValue__c = '10';
          customSettingsData.add(partnerLeverageMaxScoreTarget);
        }
        if(FunctionalAreaRecordType == null){
            CustomSettingDataValueMap__c PRM_FA_EMC_BR_Rec_Type = new CustomSettingDataValueMap__c();
            PRM_FA_EMC_BR_Rec_Type.Name ='PRM_FA_EMC_BR_Rec_Type';
            PRM_FA_EMC_BR_Rec_Type.DataValue__c ='01270000000Q8Yj';
            customSettingsData.add(PRM_FA_EMC_BR_Rec_Type);
       }
       if(FunctionalAreaTheaterScheduled == null){
            CustomSettingDataValueMap__c Functional_AreaTheater_Scheduled = new CustomSettingDataValueMap__c();
            Functional_AreaTheater_Scheduled.Name ='IS_FA_Scheduled_Theaters';
            Functional_AreaTheater_Scheduled.DataValue__c ='YES';
            customSettingsData.add(Functional_AreaTheater_Scheduled);
       }
       if(APJPartnerUserProfiles== null){
            CustomSettingDataValueMap__c APJ_PartnerUser_Profiles = new CustomSettingDataValueMap__c();
            APJ_PartnerUser_Profiles.Name ='APJPartnerUsers';
            APJ_PartnerUser_Profiles.DataValue__c ='00e70000001FhQGAA0;00e70000001FhPwAAK;00e70000001FhQLAA0;00e70000001FhQpAAK;00e70000001FhQuAAK;00e70000001FhQ6AAK;00e70000001FhQ1AAK;00e70000001FhQBAA0';
            customSettingsData.add(APJ_PartnerUser_Profiles);
       }
       if(ReassignDisVarUserExcludeValues== null){
            ReassignDisVarUserExcludeValues = new CustomSettingDataValueMap__c();
            ReassignDisVarUserExcludeValues.Name ='ReassignDisVarUserExcludeValues';
            ReassignDisVarUserExcludeValues.DataValue__c ='(\'Distributor\',\'Direct Reseller\')';
            customSettingsData.add(ReassignDisVarUserExcludeValues);
       }
       if(ReassigningDistributorUsers== null){
            ReassigningDistributorUsers = new CustomSettingDataValueMap__c();
            ReassigningDistributorUsers.Name ='Reassigning Distributor Users';
            ReassigningDistributorUsers.DataValue__c ='00e70000001FhQHAA0;00e70000001FhQaAAK;00e70000001FhQGAA0;00e70000001FhQLAA0;00e70000001FbqwAAC;00e70000001Fbr1AAC;00e70000001Fh0hAAC;00e70000001Fh0mAAC';
            customSettingsData.add(ReassigningDistributorUsers);
       } 
       if(DistributorPartnerUsers== null){
            DistributorPartnerUsers = new CustomSettingDataValueMap__c();
            DistributorPartnerUsers.Name ='Distributor Partner Users';
            DistributorPartnerUsers.DataValue__c ='00e70000001FhQHAA0;00e70000001FhQaAAK;00e70000001FhQGAA0;00e70000001FhQLAA0;00e70000001FbqwAAC;00e70000001Fbr1AAC;00e70000001Fh0hAAC;00e70000001Fh0mAAC';
            customSettingsData.add(DistributorPartnerUsers);
       }
       if(NonAPJDistributorUsers== null){
            NonAPJDistributorUsers = new CustomSettingDataValueMap__c();
            NonAPJDistributorUsers.Name ='NonAPJ Distributor Users';
            NonAPJDistributorUsers.DataValue__c ='00e70000001FhQHAA0;00e70000001FhQaAAK;00e70000001FbqwAAC;00e70000001Fbr1AAC;00e70000001Fh0hAAC;00e70000001Fh0mAAC';
            customSettingsData.add(NonAPJDistributorUsers);
       }
       if(ESBI_VPP_Scheduled_Theaters == null){
          ESBI_VPP_Scheduled_Theaters = new CustomSettingDataValueMap__c();
          ESBI_VPP_Scheduled_Theaters.Name = 'ESBI_VPP_Scheduled_Theaters';
          ESBI_VPP_Scheduled_Theaters.DataValue__c = 'APJ,EMEA,Americas';
          customSettingsData.add(ESBI_VPP_Scheduled_Theaters);
       }
       if(ESBI_VPP_Scheduled_Jobs == null){
          ESBI_VPP_Scheduled_Jobs = new CustomSettingDataValueMap__c();
          ESBI_VPP_Scheduled_Jobs.Name = 'ESBI_VPP_Scheduled_Jobs';
          ESBI_VPP_Scheduled_Jobs.DataValue__c = 'VPP - PAN Theater Level';
          customSettingsData.add(ESBI_VPP_Scheduled_Jobs);
       }
       if(TartgetTierTheaters == null){
          TartgetTierTheaters = new CustomSettingDataValueMap__c();
          TartgetTierTheaters.Name = 'TartgetTierTheaters';
          TartgetTierTheaters.DataValue__c = 'EMEA';
          customSettingsData.add(TartgetTierTheaters);
       }
       if(PANSpecilities == null){
          PANSpecilities = new CustomSettingDataValueMap__c();
          PANSpecilities.Name = 'PANSpecilities';
          PANSpecilities.DataValue__c = 'Consolidate,Advanced Consolidate,Backup and Recovery,Governance and Archive,Cloud Builder Practice';
          customSettingsData.add(PANSpecilities);
       }
       if(PANVPPBucketContainer.get('SSCP')==null){
          PRM_PAN_VPP_Bucket_Container__c SSCP = new PRM_PAN_VPP_Bucket_Container__c();
          SSCP.Name ='SSCP';
          SSCP.Field_API_Name__c ='Solution_Center_Implemented__c';
          BucketContainerData.add(SSCP);    
       }
       if(PANVPPBucketContainer.get('VSI')==null){
          PRM_PAN_VPP_Bucket_Container__c VSI = new PRM_PAN_VPP_Bucket_Container__c();
          VSI.Name ='VSI';
          VSI.Field_API_Name__c ='Velocity_Services_Implement__c';
          BucketContainerData.add(VSI); 
       }
        //Added code for Revenue Custom Settings creations
            CustomSettingDataValueMap__c batchId = DataValueMap.get('Batch Id');
            CustomSettingDataValueMap__c Revenue_Summary_Rule = DataValueMap.get('Revenue Summary Rule');
            CustomSettingDataValueMap__c Current = DataValueMap.get('Current');
            CustomSettingDataValueMap__c Previous = DataValueMap.get('Previous');
            Map<String,Schema.RecordTypeInfo> recordTypes = EMC_Business_Rules__c.sObjectType.getDescribe().getRecordTypeInfosByName();
            if(batchId == null){
              batchId = new CustomSettingDataValueMap__c(Name = 'Batch Id');
              batchId.DateValue__c = 0000 ;
              customSettingsData.add(batchId);
            }
            
            if(Revenue_Summary_Rule == null)
            {
                if(recordTypes!=null)
                {
                    Revenue_Summary_Rule = new CustomSettingDataValueMap__c(Name = 'Revenue Summary Rule');
                    Revenue_Summary_Rule.DataValue__c = recordTypes.get('Revenue Summary Rule').getRecordTypeId();
                    customSettingsData.add(Revenue_Summary_Rule);
                }
            }
            if(Current == null)
            {
                Current=new CustomSettingDataValueMap__c(Name = 'Current',DataValue__c='Current');
                customSettingsData.add(Current);
            }
            if(Previous == null)
            {
                Previous=new CustomSettingDataValueMap__c(Name = 'Previous',DataValue__c='Previous');
                customSettingsData.add(Previous);
            }
        for(Integer iQuarterCounter=1;iQuarterCounter<5;iQuarterCounter++)
        {
            CustomSettingDataValueMap__c Quarter = DataValueMap.get('Q'+iQuarterCounter);
            CustomSettingDataValueMap__c Quarter_Growth_Revenue = DataValueMap.get('Q'+iQuarterCounter+'GrowthRevenue');
            CustomSettingDataValueMap__c Quarter_Growth_Units = DataValueMap.get('Q'+iQuarterCounter+'GrowthUnits');
            CustomSettingDataValueMap__c Quarter_Total_Revenue = DataValueMap.get('Q'+iQuarterCounter+'TotalRevenue');
            CustomSettingDataValueMap__c Quarter_Total_Units = DataValueMap.get('Q'+iQuarterCounter+'TotalUnits');
            if(Quarter==null)
            {
                Quarter = new CustomSettingDataValueMap__c(Name = 'Q'+iQuarterCounter);
                Quarter.DataValue__c = String.valueOf(iQuarterCounter) ;
                customSettingsData.add(Quarter);
            }
            else if(Quarter_Growth_Revenue==null)
            {
                Quarter_Growth_Revenue = new CustomSettingDataValueMap__c(Name = 'Q'+iQuarterCounter+'GrowthRevenue');
                Quarter_Growth_Revenue.DataValue__c = 'Q'+iQuarterCounter+'_Growth_Revenue__c' ;
                customSettingsData.add(Quarter_Growth_Revenue);
            }
            else if(Quarter_Growth_Units==null)
            {
                Quarter_Growth_Units = new CustomSettingDataValueMap__c(Name = 'Q'+iQuarterCounter+'GrowthUnits');
                Quarter_Growth_Units.DataValue__c = 'Q'+iQuarterCounter+'_Growth_Units__c' ;
                customSettingsData.add(Quarter_Growth_Units);
            }
            else if(Quarter_Total_Revenue==null)
            {
                Quarter_Total_Revenue = new CustomSettingDataValueMap__c(Name = 'Q'+iQuarterCounter+'TotalRevenue');
                Quarter_Total_Revenue.DataValue__c = 'Q'+iQuarterCounter+'_Total_Revenue__c' ;
                customSettingsData.add(Quarter_Total_Revenue);
            }
            else if(Quarter_Total_Units==null)
            {
                Quarter_Total_Units = new CustomSettingDataValueMap__c(Name = 'Q'+iQuarterCounter+'TotalUnits');
                Quarter_Total_Units.DataValue__c = 'Q'+iQuarterCounter+'_Total_Units__c' ;
                customSettingsData.add(Quarter_Total_Units);
            }            
        }
        //End of Revenue Custom settings creation
        if(customSettingsData.size()>0){
           Database.insert(customSettingsData,false);
           //insert customSettingsData ;
           //system.debug('createVPPCustomSettingData --- customSettingsData ##### ' + customSettingsData );
        }   
        if(BucketContainerData.size()>0){
            Database.insert(BucketContainerData,false);
        }   
        
        //Custom setting creation -- DEAL REGISTRATION
        
       Map<String,DealRegistration_CustomSetting__c>  csDeasReg =  DealRegistration_CustomSetting__c.getall();      
       List<DealRegistration_CustomSetting__c> DealRegData = new List<DealRegistration_CustomSetting__c>();
       DealRegistration_CustomSetting__c DistributionVARSuperUsers = csDeasReg.get('DistributionVARSuperUsers');
       DealRegistration_CustomSetting__c DistributorPartnerUser = csDeasReg.get('Distributor Partner User');
       DealRegistration_CustomSetting__c DistributorSuperUser = csDeasReg.get('Distributor Super User');
       DealRegistration_CustomSetting__c DistributorUser = csDeasReg.get('DistributorUser');
       DealRegistration_CustomSetting__c Tier1PartnerUser = csDeasReg.get('Tier1 Partner User');  
       DealRegistration_CustomSetting__c Tier1SuperUser = csDeasReg.get('Tier1 Super User');
       DealRegistration_CustomSetting__c Tier2PartnerUser = csDeasReg.get('Tier2 Partner User');
       DealRegistration_CustomSetting__c Tier2SuperUser = csDeasReg.get('Tier2 Super User');
       DealRegistration_CustomSetting__c AmerExtensionRqstQueue = csDeasReg.get('AmerExtensionRqstQueue');
       DealRegistration_CustomSetting__c ApjExtensionRqstQueue = csDeasReg.get('ApjExtensionRqstQueue');
       DealRegistration_CustomSetting__c EmeaExtensionRqstQueue = csDeasReg.get('EmeaExtensionRqstQueue');
       DealRegistration_CustomSetting__c ExtensionDateofAmericaEmea = csDeasReg.get('Extension Date of America/Emea');
       DealRegistration_CustomSetting__c ExtensionDateofAmericaEmeaAPJ = csDeasReg.get('Extension Date of America/Emea/APJ');
       DealRegistration_CustomSetting__c ExtensionDateofAPJ = csDeasReg.get('Extension Date of APJ');
       DealRegistration_CustomSetting__c NonResellerPartnerUsers = csDeasReg.get('NonResellerPartnerUsers');

        if(ExtensionDateofAmericaEmea == null){
           ExtensionDateofAmericaEmea = new DealRegistration_CustomSetting__c(Name = 'Extension Date of America/Emea');
      ExtensionDateofAmericaEmea.Length_of_Extensions__c=30;
          DealRegData.add(ExtensionDateofAmericaEmea);
        }
        if(ExtensionDateofAmericaEmeaAPJ == null){
            ExtensionDateofAmericaEmeaAPJ = new DealRegistration_CustomSetting__c(Name = 'Extension Date of America/Emea/APJ');
            ExtensionDateofAmericaEmeaAPJ.Length_of_Extensions__c=60;
            DealRegData.add(ExtensionDateofAmericaEmeaAPJ);
        }
         if(ExtensionDateofAPJ == null){
           ExtensionDateofAPJ = new DealRegistration_CustomSetting__c(Name = 'Extension Date of APJ');
      ExtensionDateofAPJ.Length_of_Extensions__c=6;
          DealRegData.add(ExtensionDateofAPJ);
        }
        
       if(AmerExtensionRqstQueue == null){
           AmerExtensionRqstQueue = new DealRegistration_CustomSetting__c(Name = 'AmerExtensionRqstQueue');
      AmerExtensionRqstQueue.PSC_QueueId__c='00G70000001lWLH';
          DealRegData.add(AmerExtensionRqstQueue);
        }
        if(ApjExtensionRqstQueue == null){
           ApjExtensionRqstQueue = new DealRegistration_CustomSetting__c(Name = 'ApjExtensionRqstQueue');
          ApjExtensionRqstQueue.PSC_QueueId__c='00G70000001lWLM';
          DealRegData.add(ApjExtensionRqstQueue);
        }
        if(EmeaExtensionRqstQueue == null){
           EmeaExtensionRqstQueue = new DealRegistration_CustomSetting__c(Name = 'EmeaExtensionRqstQueue');
          EmeaExtensionRqstQueue.PSC_QueueId__c='00G70000001lWLR';
          DealRegData.add(EmeaExtensionRqstQueue);
        }
       if(DistributionVARSuperUsers == null){
           DistributionVARSuperUsers = new DealRegistration_CustomSetting__c(Name = 'DistributionVARSuperUsers');
          DistributionVARSuperUsers.Language__c='English';
          DistributionVARSuperUsers.LanguageCode__c='EN';
          DistributionVARSuperUsers.Length_of_Extensions__c=23;
          DistributionVARSuperUsers.ParnterProfileID__c='EmeaPSCDRQueue';
          DealRegData.add(DistributionVARSuperUsers);
        }
        if(DistributorPartnerUser == null){
          DistributorPartnerUser = new DealRegistration_CustomSetting__c(Name = 'Distributor Partner User');
          DistributorPartnerUser.Language__c='English';
          DistributorPartnerUser.LanguageCode__c='EN';
          DistributorPartnerUser.Length_of_Extensions__c=23;
          DistributorPartnerUser.ParnterProfileID__c='00e70000001FhQH;00e70000001FhQG;00e70000001Fbqw';
          DealRegData.add(DistributorPartnerUser);
        }
        if(DistributorSuperUser == null){
          DistributorSuperUser = new DealRegistration_CustomSetting__c(Name = 'Distributor Super User');
          DistributorSuperUser.Language__c='English';
          DistributorSuperUser.LanguageCode__c='EN';
          DistributorSuperUser.Length_of_Extensions__c=23;
          DistributorSuperUser.ParnterProfileID__c='00e70000001FhQa;00e70000001FhQL;00e70000001Fbr1';
          DealRegData.add(DistributorSuperUser);
        }        
        if(DistributorUser == null){
          DistributorUser = new DealRegistration_CustomSetting__c(Name = 'DistributorUser');
          DistributorUser.Language__c='English';
          DistributorUser.LanguageCode__c='EN';
          DistributorUser.Length_of_Extensions__c=23;
          DistributorUser.ParnterProfileID__c='not using for approval routing';
          DealRegData.add(DistributorUser);
        }
        if(NonResellerPartnerUsers == null){
          DistributorUser = new DealRegistration_CustomSetting__c(Name = 'NonResellerPartnerUsers');
          DistributorUser.Language__c='English';
          DistributorUser.LanguageCode__c='EN';
          DistributorUser.Length_of_Extensions__c=23;
          DistributorUser.ParnterProfileID__c='00e70000001Fbqm;00e70000001FbrB;00e70000001Fbqr;00e70000001FbrG;00e70000001Fbqw;00e70000001Fbr1;00e70000001Fbr6;00e70000001FbrL;00e70000001FbTT;00e70000001FacU;00e70000001Fgeb;00e70000000wBza;00e70000000wRaB;00e70000001FhRiAAK';
          DealRegData.add(DistributorUser);
        }
         if(Tier1PartnerUser == null){
          Tier1PartnerUser = new DealRegistration_CustomSetting__c(Name = 'Tier1 Partner User');
          Tier1PartnerUser.Language__c='English';
          Tier1PartnerUser.LanguageCode__c='EN';
          Tier1PartnerUser.Length_of_Extensions__c=23;
          Tier1PartnerUser.ParnterProfileID__c='00e70000001FhQQ;00e70000001FhPw;00e70000001Fbqm';
          DealRegData.add(Tier1PartnerUser);
        }
         if(Tier1SuperUser == null){
          Tier1SuperUser = new DealRegistration_CustomSetting__c(Name = 'Tier1 Super User');
          Tier1SuperUser.Language__c='English';
          Tier1SuperUser.LanguageCode__c='EN';
          Tier1SuperUser.Length_of_Extensions__c=23;
          Tier1SuperUser.ParnterProfileID__c='00e70000001FhQV;00e70000001FhQ1;00e70000001FbrB';
          DealRegData.add(Tier1SuperUser);
        }
         if(Tier2PartnerUser == null){
          Tier2PartnerUser = new DealRegistration_CustomSetting__c(Name = 'Tier2 Partner User');
          Tier2PartnerUser.Language__c='English';
          Tier2PartnerUser.LanguageCode__c='EN';
          Tier2PartnerUser.Length_of_Extensions__c=23;
          Tier2PartnerUser.ParnterProfileID__c='00e70000001FhQ6;00e70000001Fbqr;00e70000001FhPm';
          DealRegData.add(Tier2PartnerUser);
        }
         if(Tier2SuperUser == null){
          Tier2SuperUser = new DealRegistration_CustomSetting__c(Name = 'Tier2 Super User');
          Tier2SuperUser.Language__c='English';
          Tier2SuperUser.LanguageCode__c='EN';
          Tier2SuperUser.Length_of_Extensions__c=23;
          Tier2SuperUser.ParnterProfileID__c='00e70000001FhPr;00e70000001FhQB;00e70000001FbrG';
          DealRegData.add(Tier2SuperUser);
        }
        if(csDeasReg.get('EmeaPSCDRQueue')==null)
        {
            DealRegistration_CustomSetting__c csTestData=new DealRegistration_CustomSetting__c();
            csTestData.name='EmeaPSCDRQueue';
            csTestData.Language__c='English';
            csTestData.LanguageCode__c='EN';
            csTestData.Length_of_Extensions__c=23;
            csTestData.ParnterProfileID__c='EmeaPSCDRQueue';
            csTestData.PSC_QueueId__c='00G70000001lIsO';
            DealRegData.add(csTestData);            
        }        
        if(csDeasReg.get('AmerPSCDRQueue')==null)
        {
            DealRegistration_CustomSetting__c csTestData9=new DealRegistration_CustomSetting__c();
            csTestData9.name='AmerPSCDRQueue';
            csTestData9.Language__c='English';
            csTestData9.LanguageCode__c='EN';
            csTestData9.Length_of_Extensions__c=23;
            csTestData9.ParnterProfileID__c='AmerPSCDRQueue';
            csTestData9.PSC_QueueId__c='00G70000001lIsO';
            DealRegData.add(csTestData9);            
        }        
        if(csDeasReg.get('ApjPSCDRQueue')==null)
        {
            DealRegistration_CustomSetting__c csTestData10=new DealRegistration_CustomSetting__c();
            csTestData10.name='ApjPSCDRQueue';
            csTestData10.Language__c='English';
            csTestData10.LanguageCode__c='EN';
            csTestData10.Length_of_Extensions__c=23;
            csTestData10.ParnterProfileID__c='ApjPSCDRQueue';
            csTestData10.PSC_QueueId__c='00G70000001lIsO';
            DealRegData.add(csTestData10);            
        }        
        if(csDeasReg.get('NonResellerPartnerUsers')==null)
        {
            DealRegistration_CustomSetting__c csTestData13=new DealRegistration_CustomSetting__c();
            csTestData13.name='NonResellerPartnerUsers';
            csTestData13.Language__c='English';
            csTestData13.LanguageCode__c='EN';
            csTestData13.Length_of_Extensions__c=23;
            csTestData13.ParnterProfileID__c='NonResellerPartnerUsers';
            csTestData13.PSC_QueueId__c='00G70000001lIsO';
            DealRegData.add(csTestData13);            
        }       
        if(csDeasReg.get('DRRepsLimit')==null)
        {
            DealRegistration_CustomSetting__c csTestData14=new DealRegistration_CustomSetting__c();
            csTestData14.name='DRRepsLimit';
            csTestData14.Language__c='English';
            csTestData14.LanguageCode__c='EN';
            csTestData14.Length_of_Extensions__c=23;
            csTestData14.ParnterProfileID__c='DRRepsLimit';
            csTestData14.PSC_QueueId__c='00G70000001lIsO';
            DealRegData.add(csTestData14);
           
        }
        if(csDeasReg.get('Expriation Date of America/Emea')==null)
        {
          DealRegistration_CustomSetting__c ExpriationDateofAmericaEmea=new DealRegistration_CustomSetting__c();
          ExpriationDateofAmericaEmea.Name='Expriation Date of America/Emea';
          ExpriationDateofAmericaEmea.Length_of_Extensions__c=120;
          DealRegData.add(ExpriationDateofAmericaEmea);
        }
         if(csDeasReg.get('Expriation Date of APJ')==null)
         {
           DealRegistration_CustomSetting__c ExpriationDateofAPJ=new DealRegistration_CustomSetting__c();
          ExpriationDateofAPJ.Name='Expriation Date of APJ';
          ExpriationDateofAPJ.Length_of_Extensions__c=3;
          DealRegData.add(ExpriationDateofAPJ);
           
         }
        
         if(DealRegData.size()>0)
            {
              Database.insert(DealRegData,false);
            }
            
            
        Map<String,Deal_Reg_Approval_Date_Check__c>  approvalDates =  Deal_Reg_Approval_Date_Check__c.getall();      
        List<Deal_Reg_Approval_Date_Check__c> appDates = new List<Deal_Reg_Approval_Date_Check__c>();
        if(approvalDates.get('Deal Reg Approval Date')==null)
         {
          Deal_Reg_Approval_Date_Check__c approvalDt = new Deal_Reg_Approval_Date_Check__c();
          approvalDt.Name='Deal Reg Approval Date';
          approvalDt.Approval_Date__c = Date.valueOf('2013-01-01');
          appDates.add(approvalDt);
           
         } 
         if(appDates.size()>0)
            {
              Database.insert(appDates,false);
            }
            
       //Custom setting creation -- PROFILES
        
        Profiles__c ProfileCSdata= Profiles__c.getOrgDefaults();
        if(ProfileCSdata==null)
        {        
        Profiles__c ProfilesRecord=new Profiles__c (EMC_Grouping_Administrator__c= '00e70000001Fbra',System_Admin_API_Only__c='00e70000000wRaBAAU',System_Administrator__c='00e70000000wBza',EMC_Contract_and_Grouping_Administrator__c='00e70000001Fbrf');
        insert ProfilesRecord;
       }
         
        //Custom setting creation -- VELOCITY RULE
        
        Map<String,VelocityRules__c>  vruleDataValue =  VelocityRules__c.getall();
        List<VelocityRules__c> vrulerecords = new List<VelocityRules__c>();
        VelocityRules__c SpecialityRule1 = vruleDataValue.get('SpecialityRule1');
      VelocityRules__c SpecialityRule2 = vruleDataValue.get('SpecialityRule2');
      VelocityRules__c SpecialityRule3 = vruleDataValue.get('SpecialityRule3');
      VelocityRules__c SpecialityRule4 = vruleDataValue.get('SpecialityRule4');
      VelocityRules__c SpecialityRule5 = vruleDataValue.get('SpecialityRule5');
      
      VelocityRules__c ServiceRule1 = vruleDataValue.get('ServiceRule1');
      VelocityRules__c ServiceRule2 = vruleDataValue.get('ServiceRule2');
      VelocityRules__c ServiceRule3 = vruleDataValue.get('ServiceRule3');
      VelocityRules__c ServiceRule4 = vruleDataValue.get('ServiceRule4');
      VelocityRules__c ServiceRule5 = vruleDataValue.get('ServiceRule5');
      
        if(SpecialityRule1 == null){
           SpecialityRule1 = new VelocityRules__c(Name = 'SpecialityRule1');
           SpecialityRule1.SpecialityRules__c='Consolidate';
          vrulerecords.add(SpecialityRule1);
        }
        if(SpecialityRule2 == null){
           SpecialityRule2 = new VelocityRules__c(Name = 'SpecialityRule2');
           SpecialityRule2.SpecialityRules__c='Backup and Recovery';
          vrulerecords.add(SpecialityRule2);
        }
        if(SpecialityRule3 == null){
           SpecialityRule3 = new VelocityRules__c(Name = 'SpecialityRule3');
           SpecialityRule3.SpecialityRules__c='Advanced Consolidate';
          vrulerecords.add(SpecialityRule3);
        }
        if(SpecialityRule4 == null){
           SpecialityRule4 = new VelocityRules__c(Name = 'SpecialityRule4');
           SpecialityRule4.SpecialityRules__c='Governance and Archive';
          vrulerecords.add(SpecialityRule4);
        }
        
        if(SpecialityRule5 == null){
           SpecialityRule5 = new VelocityRules__c(Name = 'SpecialityRule5');
           SpecialityRule5.SpecialityRules__c='Cloud Builder';
          vrulerecords.add(SpecialityRule5);
        }
        
        if(ServiceRule1 == null){
           ServiceRule1 = new VelocityRules__c(Name = 'ServiceRule1');
           ServiceRule1.SpecialityRules__c='QSS Implement';
          vrulerecords.add(ServiceRule1);
        }
        if(ServiceRule2 == null){
           ServiceRule2 = new VelocityRules__c(Name = 'ServiceRule2');
           ServiceRule2.SpecialityRules__c='QSS Support';
          vrulerecords.add(ServiceRule2);
        }
        if(ServiceRule3 == null){
           ServiceRule3 = new VelocityRules__c(Name = 'ServiceRule3');
           ServiceRule3.SpecialityRules__c='VS Implement';
          vrulerecords.add(ServiceRule3);
        }
        if(ServiceRule4 == null){
           ServiceRule4 = new VelocityRules__c(Name = 'ServiceRule4');
           ServiceRule4.SpecialityRules__c='VS Support';
          vrulerecords.add(ServiceRule4);
        }
        if(ServiceRule5 == null){
           ServiceRule5 = new VelocityRules__c(Name = 'ServiceRule5');
           ServiceRule5.SpecialityRules__c='VS Manage';
          vrulerecords.add(ServiceRule5);
        }
        
        
        
        
        if(vrulerecords.size()>0)
          {
            Database.insert(vrulerecords,false);
          }
        
        //Custom setting creation -- VCESTATIC
        Map<String,VCEStatic__c>  vcedata =  VCEStatic__c.getall();
        List<VCEStatic__c> VCEDataValue = new List<VCEStatic__c>();
        VCEStatic__c taskRecType = new VCEStatic__c();
        taskRecType.Name ='VCETaskRecordType';
        taskRecType.Value__c ='01270000000Q5GcAAK';
        VCEDataValue.add(taskRecType);
        
        VCEStatic__c connUser = new VCEStatic__c();
        connUser.Name ='ConnectionUser';
        connUser.Value__c ='00570000001dwDWAAY';
        VCEDataValue.add(connUser);
        
        VCEStatic__c recType = new VCEStatic__c();
        recType.Name ='VCECaseRecordType';
        recType.Value__c ='01270000000Q5GXAA0';
        VCEDataValue.add(recType);
        
        VCEStatic__c connId = new VCEStatic__c();
        connId.Name ='ConnectionId';
        connId.Value__c ='04P70000000GmceEAC';
        VCEDataValue.add(connId);

         try
        {
           Database.insert(VCEDataValue, false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }
        
         //Custom setting creation -- Partner Onboarding
        List<Custom_Settings_Partner_OnBoarding__c> lstDataValue = new List<Custom_Settings_Partner_OnBoarding__c>();
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag.Name ='STEP1.0Americas';
        dataValueControlFlag.Description__c ='Step to decide the owner of POB record.';
        dataValueControlFlag.Owner__c='00G70000001lIsO';
        lstDataValue.add(dataValueControlFlag);

        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag1 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag1.Name ='STEP1.0APJ';
        dataValueControlFlag1.Description__c ='Step to decide the owner of POB';
        dataValueControlFlag1.Owner__c='00G70000001lIsO';
        lstDataValue.add(dataValueControlFlag1);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag2 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag2.Name ='STEP1.0EMEA';
        dataValueControlFlag2.Description__c ='Step to decide the owner of POB';
        dataValueControlFlag2.Owner__c='00G70000001lIsO';
        lstDataValue.add(dataValueControlFlag2);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag3 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag3.Name ='STEP2.0Americas';
        dataValueControlFlag3.Description__c ='Send a mail to CM and create a task for CM to accept/reject new Distributor VAR';
        dataValueControlFlag3.Owner__c='00G70000001lIsO';
        dataValueControlFlag3.Send_Email__c=True;
        dataValueControlFlag3.Template__c='00X70000001Rv6c';
        dataValueControlFlag3.Create_Task__c=True;
        dataValueControlFlag3.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag3.Task_Name__c='Step 1 - EMC Application Translation/Approval';
        lstDataValue.add(dataValueControlFlag3);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag4 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag4.Name ='STEP2.0APJ';
        dataValueControlFlag4.Description__c ='Send a mail to CM and create a task for CM to accept/reject new Distributor VAR';
        dataValueControlFlag4.Owner__c='00G70000001lIsO';
        dataValueControlFlag4.Send_Email__c=True;
        dataValueControlFlag4.Template__c='00X70000001Rv6c';
        dataValueControlFlag4.Create_Task__c=True;
        dataValueControlFlag4.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag4.Task_Name__c='Step 1 - EMC Application Translation/Approval';
        lstDataValue.add(dataValueControlFlag4);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag5 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag5.Name ='STEP2.0EMEA';
        dataValueControlFlag5.Description__c ='Send a mail to CM and create a task for CM to accept/reject new Distributor VAR';
        dataValueControlFlag5.Owner__c='00G70000001lIsO';
        dataValueControlFlag5.Send_Email__c=True;
        dataValueControlFlag5.Template__c='00X70000001Rv6c';
        dataValueControlFlag5.Create_Task__c=True;
        dataValueControlFlag5.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag5.Task_Name__c='Step 1 - EMC Application Translation/Approval';
        lstDataValue.add(dataValueControlFlag5);        
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag6 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag6.Name ='STEP3.0';
        dataValueControlFlag6.Description__c ='Send a mail to Distributor and create a task for Distributor to accept/reject new Distributor VAR';      
        dataValueControlFlag6.Send_Email__c=True;
        dataValueControlFlag6.Template__c='00X70000001Rv6c';
        dataValueControlFlag6.Create_Task__c=True;
        dataValueControlFlag6.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag6.Task_Name__c='Step 2a - Distributor Approval of Authorized Reseller';
        lstDataValue.add(dataValueControlFlag6);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag35 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag35.Name ='STEP3.1Americas';
        dataValueControlFlag35.Description__c ='Send a mail to CM and create a task for CM to identify accout for new Distributor VAR';     
        dataValueControlFlag35.Owner__c='00G70000001lIsO';
        dataValueControlFlag35.Send_Email__c=True;
        dataValueControlFlag35.Template__c='00X70000001Rv6c';
        dataValueControlFlag35.Create_Task__c=True;
        dataValueControlFlag35.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag35.Task_Name__c='Step 2b - Contract Manager Account Identification';
        lstDataValue.add(dataValueControlFlag35);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag7 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag7.Name ='STEP3.1APJ';
        dataValueControlFlag7.Description__c ='Send a mail to CM and create a task for CM to identify accout for new Distributor VAR';      
        dataValueControlFlag7.Owner__c='00G70000001lIsO';
        dataValueControlFlag7.Send_Email__c=True;
        dataValueControlFlag7.Template__c='00X70000001Rv6c';
        dataValueControlFlag7.Create_Task__c=True;
        dataValueControlFlag7.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag7.Task_Name__c='Step 2b - Contract Manager Account Identification';
        lstDataValue.add(dataValueControlFlag7);    
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag8 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag8.Name ='STEP3.1EMEA';
        dataValueControlFlag8.Description__c ='Send a mail to CM and create a task for CM to identify accout for new Distributor VAR';      
        dataValueControlFlag8.Owner__c='00G70000001lIsO';
        dataValueControlFlag8.Send_Email__c=True;
        dataValueControlFlag8.Template__c='00X70000001Rv6c';
        dataValueControlFlag8.Create_Task__c=True;
        dataValueControlFlag8.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag8.Task_Name__c='Step 2b - Contract Manager Account Identification';
        lstDataValue.add(dataValueControlFlag8);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag9 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag9.Name ='STEP4.0Americas';
        dataValueControlFlag9.Description__c ='Send a mail to Contract Manager if Distributor rejects the Distributor VAR';     
        dataValueControlFlag9.Owner__c='00G70000001lIsO';
        dataValueControlFlag9.Send_Email__c=True;
        dataValueControlFlag9.Template__c='00X70000001Rv6c';        
        lstDataValue.add(dataValueControlFlag9);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag33 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag33.Name ='STEP4.0APJ';
        dataValueControlFlag33.Description__c ='Send a mail to Contract Manager if Distributor rejects the Distributor VAR';        
        dataValueControlFlag33.Owner__c='00G70000001lIsO';
        dataValueControlFlag33.Send_Email__c=True;
        dataValueControlFlag33.Template__c='00X70000001Rv6c';       
        lstDataValue.add(dataValueControlFlag33);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag10 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag10.Name ='STEP4.0EMEA';
        dataValueControlFlag10.Description__c ='Send a mail to Contract Manager if Distributor rejects the Distributor VAR';        
        dataValueControlFlag10.Owner__c='00G70000001lIsO';
        dataValueControlFlag10.Send_Email__c=True;
        dataValueControlFlag10.Template__c='00X70000001Rv6c';       
        lstDataValue.add(dataValueControlFlag10);
        
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag11 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag11.Name ='STEP5.0Americas';
        dataValueControlFlag11.Description__c ='Send a mail to TRACK if CM doesnt found the account.';      
        dataValueControlFlag11.Owner__c='00G70000001lIsO';
        dataValueControlFlag11.Send_Email__c=True;
        dataValueControlFlag11.Template__c='00X70000001Rv6c';
        dataValueControlFlag11.Email__c ='sharma_shalabh2@emc.com';
        lstDataValue.add(dataValueControlFlag11);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag12 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag12.Name ='STEP5.0APJ';
        dataValueControlFlag12.Description__c ='Send a mail to TRACK if CM doesnt found the account.';      
        dataValueControlFlag12.Owner__c='00G70000001lIsO';
        dataValueControlFlag12.Send_Email__c=True;
        dataValueControlFlag12.Template__c='00X70000001Rv6c';
        dataValueControlFlag12.Email__c ='sobhanan.bindu@accenture.com';
        lstDataValue.add(dataValueControlFlag12);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag13 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag13.Name ='STEP5.0EMEA';
        dataValueControlFlag13.Description__c ='Send a mail to TRACK if CM doesnt found the account.';      
        dataValueControlFlag13.Owner__c='00G70000001lIsO';
        dataValueControlFlag13.Send_Email__c=True;
        dataValueControlFlag13.Template__c='00X70000001Rv6c';
        dataValueControlFlag13.Email__c ='sobhanan.bindu@accenture.com';
        lstDataValue.add(dataValueControlFlag13);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag14 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag14.Name ='STEP6.0Americas';
        dataValueControlFlag14.Description__c ='Send a mail to CXP admin for account setup';        
        dataValueControlFlag14.Owner__c='00G70000001lIsO';
        dataValueControlFlag14.Send_Email__c=True;
        dataValueControlFlag14.Template__c='00X70000001Rv6c';
        dataValueControlFlag14.Create_Task__c=True;
        dataValueControlFlag14.Email__c ='sharma_shalabh2@emc.com';
        dataValueControlFlag14.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag14.Task_Name__c='Step 3b - CXP Setup';
        lstDataValue.add(dataValueControlFlag14);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag15 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag15.Name ='STEP6.0APJ';
        dataValueControlFlag15.Description__c ='Send a mail to CXP admin for account setup';        
        dataValueControlFlag15.Owner__c='00G70000001lIsO';
        dataValueControlFlag15.Send_Email__c=True;
        dataValueControlFlag15.Template__c='00X70000001Rv6c';
        dataValueControlFlag15.Create_Task__c=True;
        dataValueControlFlag15.Email__c ='shreya.ravivarmaraj@accenture.com';
        dataValueControlFlag15.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag15.Task_Name__c='Step 3b - CXP Setup';
        lstDataValue.add(dataValueControlFlag15);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag16 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag16.Name ='STEP6.0EMEA';
        dataValueControlFlag16.Description__c ='Send a mail to CXP admin for account setup';        
        dataValueControlFlag16.Owner__c='00G70000001lIsO';
        dataValueControlFlag16.Send_Email__c=True;
        dataValueControlFlag16.Template__c='00X70000001Rv6c';
        dataValueControlFlag16.Create_Task__c=True;
        dataValueControlFlag16.Email__c ='sobhanan.bindu@accenture.com';
        dataValueControlFlag16.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag16.Task_Name__c='Step 3b - CXP Setup';
        lstDataValue.add(dataValueControlFlag16);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag17 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag17.Name ='STEP6.1Americas';
        dataValueControlFlag17.Description__c ='Send a mail to Powerlink admin for account setup';      
        dataValueControlFlag17.Owner__c='00G70000001lIsO';
        dataValueControlFlag17.Send_Email__c=True;
        dataValueControlFlag17.Template__c='00X70000001Rv6c';
        dataValueControlFlag17.Create_Task__c=True;
        dataValueControlFlag17.Email__c ='sharma_shalabh2@emc.com';
        dataValueControlFlag17.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag17.Task_Name__c='Step 3a - Powerlink Setup';
        lstDataValue.add(dataValueControlFlag17);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag18 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag18.Name ='STEP6.1APJ';
        dataValueControlFlag18.Description__c ='Send a mail to Powerlink admin for account setup';      
        dataValueControlFlag18.Owner__c='00G70000001lIsO';
        dataValueControlFlag18.Send_Email__c=True;
        dataValueControlFlag18.Template__c='00X70000001Rv6c';
        dataValueControlFlag18.Create_Task__c=True;
        dataValueControlFlag18.Email__c ='shreya.ravivarmaraj@accenture.com';
        dataValueControlFlag18.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag18.Task_Name__c='Step 3a - Powerlink Setup';
        lstDataValue.add(dataValueControlFlag18);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag19 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag19.Name ='STEP6.1EMEA';
        dataValueControlFlag19.Description__c ='Send a mail to Powerlink admin for account setup';      
        dataValueControlFlag19.Owner__c='00G70000001lIsO';
        dataValueControlFlag19.Send_Email__c=True;
        dataValueControlFlag19.Template__c='00X70000001Rv6c';
        dataValueControlFlag19.Create_Task__c=True;
        dataValueControlFlag19.Email__c ='shreya.ravivarmaraj@accenture.com';
        dataValueControlFlag19.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag19.Task_Name__c='Step 3a - Powerlink Setup';
        lstDataValue.add(dataValueControlFlag19);       
    
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag20 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag20.Name ='STEP6.2Americas';
        dataValueControlFlag20.Description__c ='Send a mail to Synergy admin for account setup';        
        dataValueControlFlag20.Owner__c='00G70000001lIsO';
        dataValueControlFlag20.Send_Email__c=True;
        dataValueControlFlag20.Template__c='00X70000001Rv6c';
        dataValueControlFlag20.Create_Task__c=True;
        dataValueControlFlag20.Email__c ='shreya.ravivarmaraj@accenture.com';
        dataValueControlFlag20.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag20.Task_Name__c='Step 3c - Synergy Setup';
        lstDataValue.add(dataValueControlFlag20);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag21 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag21.Name ='STEP6.2APJ';
        dataValueControlFlag21.Description__c ='Send a mail to Synergy admin for account setup';        
        dataValueControlFlag21.Owner__c='00G70000001lIsO';
        dataValueControlFlag21.Send_Email__c=True;
        dataValueControlFlag21.Template__c='00X70000001Rv6c';
        dataValueControlFlag21.Create_Task__c=True;
        dataValueControlFlag21.Email__c ='shreya.ravivarmaraj@accenture.com';
        dataValueControlFlag21.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag21.Task_Name__c='Step 3c - Synergy Setup';
        lstDataValue.add(dataValueControlFlag21);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag22 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag22.Name ='STEP6.2EMEA';
        dataValueControlFlag22.Description__c ='Send a mail to Synergy admin for account setup';        
        dataValueControlFlag22.Owner__c='00G70000001lIsO';
        dataValueControlFlag22.Send_Email__c=True;
        dataValueControlFlag22.Template__c='00X70000001Rv6c';
        dataValueControlFlag22.Create_Task__c=True;
        dataValueControlFlag22.Email__c ='shreya.ravivarmaraj@accenture.com';
        dataValueControlFlag22.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag22.Task_Name__c='Step 3c - Synergy Setup';
        lstDataValue.add(dataValueControlFlag22);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag23 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag23.Name ='STEP6.3Americas';
        dataValueControlFlag23.Description__c ='Send a mail to Grouping admin for grouping creation';       
        dataValueControlFlag23.Owner__c='00G70000001lIsO';
        dataValueControlFlag23.Send_Email__c=True;
        dataValueControlFlag23.Template__c='00X70000001Rv6c';
        dataValueControlFlag23.Create_Task__c=True;     
        dataValueControlFlag23.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag23.Task_Name__c='Step 3d - Grouping Setup';
        lstDataValue.add(dataValueControlFlag23);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag24 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag24.Name ='STEP6.3APJ';
        dataValueControlFlag24.Description__c ='Send a mail to Grouping admin for grouping creation';       
        dataValueControlFlag24.Owner__c='00G70000001lIsO';
        dataValueControlFlag24.Send_Email__c=True;
        dataValueControlFlag24.Template__c='00X70000001Rv6c';
        dataValueControlFlag24.Create_Task__c=True;     
        dataValueControlFlag24.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag24.Task_Name__c='Step 3d - Grouping Setup';
        lstDataValue.add(dataValueControlFlag24);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag25 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag25.Name ='STEP6.3EMEA';
        dataValueControlFlag25.Description__c ='Send a mail to Grouping admin for grouping creation';       
        dataValueControlFlag25.Owner__c='00G70000001lIsO';
        dataValueControlFlag25.Send_Email__c=True;
        dataValueControlFlag25.Template__c='00X70000001Rv6c';
        dataValueControlFlag25.Create_Task__c=True;     
        dataValueControlFlag25.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag25.Task_Name__c='Step 3d - Grouping Setup';
        lstDataValue.add(dataValueControlFlag25);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag26 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag26.Name ='STEP7.0Americas';
        dataValueControlFlag26.Description__c ='Create a task and send a mail for CM for profile updation and creation of association';     
        dataValueControlFlag26.Owner__c='00G70000001lIsO';
        dataValueControlFlag26.Send_Email__c=True;
        dataValueControlFlag26.Template__c='00X70000001Rv6c';
        dataValueControlFlag26.Create_Task__c=True;     
        dataValueControlFlag26.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag26.Task_Name__c='Step 4 - Update Profile and Create Associations';
        lstDataValue.add(dataValueControlFlag26);       
        
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag28 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag28.Name ='STEP7.0APJ';
        dataValueControlFlag28.Description__c ='Create a task and send a mail for CM for profile updation and creation of association';     
        dataValueControlFlag28.Owner__c='00G70000001lIsO';
        dataValueControlFlag28.Send_Email__c=True;
        dataValueControlFlag28.Template__c='00X70000001Rv6c';
        dataValueControlFlag28.Create_Task__c=True;     
        dataValueControlFlag28.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag28.Task_Name__c='Step 4 - Update Profile and Create Associations';
        lstDataValue.add(dataValueControlFlag28);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag29 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag29.Name ='STEP7.0EMEA';
        dataValueControlFlag29.Description__c ='Create a task and send a mail for CM for profile updation and creation of association';     
        dataValueControlFlag29.Owner__c='00G70000001lIsO';
        dataValueControlFlag29.Send_Email__c=True;
        dataValueControlFlag29.Template__c='00X70000001Rv6c';
        dataValueControlFlag29.Create_Task__c=True;     
        dataValueControlFlag29.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag29.Task_Name__c='Step 4 - Update Profile and Create Associations';
        lstDataValue.add(dataValueControlFlag29);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag30 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag30.Name ='STEP7.1Americas';
        dataValueControlFlag30.Description__c ='Create a task for CM for sending welcome emails.';      
        dataValueControlFlag30.Owner__c='00G70000001lIsO';      
        dataValueControlFlag30.Create_Task__c=True;     
        dataValueControlFlag30.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag30.Task_Name__c='Step 5 - Status of Welcome Emails/Legal Agreement';
        lstDataValue.add(dataValueControlFlag30);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag31 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag31.Name ='STEP7.1APJ';
        dataValueControlFlag31.Description__c ='Create a task for CM for sending welcome emails.';      
        dataValueControlFlag31.Owner__c='00G70000001lIsO';      
        dataValueControlFlag31.Create_Task__c=True;     
        dataValueControlFlag31.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag31.Task_Name__c='Step 5 - Status of Welcome Emails/Legal Agreement';
        lstDataValue.add(dataValueControlFlag31);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag32 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag32.Name ='STEP7.1EMEA';
        dataValueControlFlag32.Description__c ='Create a task for CM for sending welcome emails.';      
        dataValueControlFlag32.Owner__c='00G70000001lIsO';      
        dataValueControlFlag32.Create_Task__c=True;     
        dataValueControlFlag32.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag32.Task_Name__c='Step 5 - Status of Welcome Emails/Legal Agreement';
        lstDataValue.add(dataValueControlFlag32);        
       try
    {
     Database.insert(lstDataValue, false);
    }catch(Exception e){
     System.debug('Check Obj Access'+e);
    }
    
    // eBusiness custom setting creation
        Map<String,CustomSetting_eBusiness_SFDC_Integration__c> mapCustomSettingEBiz = CustomSetting_eBusiness_SFDC_Integration__c.getall();
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_msg_in_proc = (mapCustomSettingEBiz.get('Integration_Log_Status_IN_PROCESS'));           
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_msg_new = (mapCustomSettingEBiz.get('Integration_Log_Status_NEW'));           
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_msg_sync_completed = (mapCustomSettingEBiz.get('Integration_Log_Status_SYNC_COMPLETED'));           
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_sObject_Account = (mapCustomSettingEBiz.get('Integration_Log_sObject_Account'));           
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_sObject_Lead = (mapCustomSettingEBiz.get('Integration_Log_sObject_Lead'));
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Lead_Owner_Org = (mapCustomSettingEBiz.get('eBus_Lead_Owner_Org__c'));
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Lead_Status_New = (mapCustomSettingEBiz.get('eBus_Lead_Status_New'));
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Lead_Status_Accept = (mapCustomSettingEBiz.get('eBus_Lead_Status_Accepted'));
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Lead_Status_Reject = (mapCustomSettingEBiz.get('eBus_Lead_Status_Rejected'));
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Partner_Enabled = (mapCustomSettingEBiz.get('eBus_Partner_Enabled__c'));
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Lead_Source = (mapCustomSettingEBiz.get('Lead_Source'));
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_query_more = (mapCustomSettingEBiz.get('Integration_Log_Query_More'));
         
        List<CustomSetting_eBusiness_SFDC_Integration__c> lsteBusinessSFDCIntegration = new List<CustomSetting_eBusiness_SFDC_Integration__c>();
        if(eBus_Integration_Log_msg_in_proc==null)
        {
            eBus_Integration_Log_msg_in_proc = new CustomSetting_eBusiness_SFDC_Integration__c(); 
            eBus_Integration_Log_msg_in_proc.Id_Values__c='';
            eBus_Integration_Log_msg_in_proc.String_Values__c='IN_PROCESS';
            lsteBusinessSFDCIntegration.add(eBus_Integration_Log_msg_in_proc);          
        }
        if(eBus_Integration_Log_msg_new==null)
        {    
            eBus_Integration_Log_msg_new = new CustomSetting_eBusiness_SFDC_Integration__c(); 
            eBus_Integration_Log_msg_new.Id_Values__c='';
            eBus_Integration_Log_msg_new.String_Values__c='NEW';
            lsteBusinessSFDCIntegration.add(eBus_Integration_Log_msg_new);          
        }
        if(eBus_Integration_Log_msg_sync_completed==null)
        {    
            eBus_Integration_Log_msg_sync_completed = new CustomSetting_eBusiness_SFDC_Integration__c();
            eBus_Integration_Log_msg_sync_completed.Id_Values__c='';
            eBus_Integration_Log_msg_sync_completed.String_Values__c='SYNC_COMPLETED';
            lsteBusinessSFDCIntegration.add(eBus_Integration_Log_msg_sync_completed);           
        }
        if(eBus_Integration_Log_sObject_Account==null)
        {    
            eBus_Integration_Log_sObject_Account = new CustomSetting_eBusiness_SFDC_Integration__c();
            eBus_Integration_Log_sObject_Account.Id_Values__c='';
            eBus_Integration_Log_sObject_Account.String_Values__c='Account';
            lsteBusinessSFDCIntegration.add(eBus_Integration_Log_sObject_Account);          
        }
        if(eBus_Integration_Log_sObject_Lead==null)
        {    
            eBus_Integration_Log_sObject_Lead = new CustomSetting_eBusiness_SFDC_Integration__c();
            eBus_Integration_Log_sObject_Lead.Id_Values__c='';
            eBus_Integration_Log_sObject_Lead.String_Values__c='Lead';
            lsteBusinessSFDCIntegration.add(eBus_Integration_Log_sObject_Lead);         
        }
        if(eBus_Lead_Owner_Org==null)
        {    
            eBus_Lead_Owner_Org = new CustomSetting_eBusiness_SFDC_Integration__c();
            eBus_Lead_Owner_Org.Id_Values__c='';
            eBus_Lead_Owner_Org.String_Values__c='EMC';
            lsteBusinessSFDCIntegration.add(eBus_Lead_Owner_Org);           
        }
        if(eBus_Lead_Status_New==null)
        {
            eBus_Lead_Status_New = new CustomSetting_eBusiness_SFDC_Integration__c();
            eBus_Lead_Status_New.Id_Values__c='';
            eBus_Lead_Status_New.String_Values__c='NEW';
            lsteBusinessSFDCIntegration.add(eBus_Lead_Status_New);          
        }
        if(eBus_Lead_Status_Accept==null)
        {
            eBus_Lead_Status_Accept = new CustomSetting_eBusiness_SFDC_Integration__c();
            eBus_Lead_Status_Accept.Id_Values__c='';
            eBus_Lead_Status_Accept.String_Values__c='Accepted';
            lsteBusinessSFDCIntegration.add(eBus_Lead_Status_Accept);           
        }
        if(eBus_Lead_Status_Reject==null)
        {
            eBus_Lead_Status_Reject = new CustomSetting_eBusiness_SFDC_Integration__c();
            eBus_Lead_Status_Reject.Id_Values__c='';
            eBus_Lead_Status_Reject.String_Values__c='Rejected';
            lsteBusinessSFDCIntegration.add(eBus_Lead_Status_Reject);           
        }
        if(eBus_Partner_Enabled==null)
        {
            eBus_Partner_Enabled = new CustomSetting_eBusiness_SFDC_Integration__c();
            eBus_Partner_Enabled.Id_Values__c='';
            eBus_Partner_Enabled.String_Values__c='Finder';
            lsteBusinessSFDCIntegration.add(eBus_Partner_Enabled);          
        }
        if(eBus_Lead_Source==null)
        {
            eBus_Lead_Source = new CustomSetting_eBusiness_SFDC_Integration__c();
            eBus_Lead_Source.Id_Values__c='';
            eBus_Lead_Source.String_Values__c='eStore';
            lsteBusinessSFDCIntegration.add(eBus_Lead_Source);          
        }
        if(eBus_Integration_Log_query_more==null)
        {
            eBus_Integration_Log_query_more = new CustomSetting_eBusiness_SFDC_Integration__c();
            eBus_Integration_Log_query_more.Id_Values__c='';
            eBus_Integration_Log_query_more.String_Values__c='10';
            lsteBusinessSFDCIntegration.add(eBus_Integration_Log_query_more);           
        }
        
        try
        {
         Database.insert (lsteBusinessSFDCIntegration, false);  
        }catch(Exception e){
         System.debug('Check Obj Access'+e);
        }   
        
        /*End of eBusiness custom setting*/
    //Custom setting creation -- PartnerSESearch
    List<CustomSettingPartnerSESeach__c> lstCustSettPatnerSESearch = new List<CustomSettingPartnerSESeach__c>();
        CustomSettingPartnerSESeach__c objCustSettPartnerSESeach = new CustomSettingPartnerSESeach__c();
        objCustSettPartnerSESeach.Name ='BRS_Avamar_Skill__c';
        objCustSettPartnerSESeach.Competency__c ='Offerings Required (Check all that apply)';
        objCustSettPartnerSESeach.DisplayName__c ='BRS Avamar';
        objCustSettPartnerSESeach.FilterValue__c ='>= \'3\'';
        objCustSettPartnerSESeach.Order__c=1;
        objCustSettPartnerSESeach.Type__c ='Text';
        lstCustSettPatnerSESearch.add(objCustSettPartnerSESeach);
        
        CustomSettingPartnerSESeach__c objCustSettPartnerSESeach1 = new CustomSettingPartnerSESeach__c();
        objCustSettPartnerSESeach1.Name ='BRS_Data_Domain_Skill__c';
        objCustSettPartnerSESeach1.Competency__c ='Offerings Required (Check all that apply)';
        objCustSettPartnerSESeach1.DisplayName__c ='BRS Data Domain';
        objCustSettPartnerSESeach1.FilterValue__c ='>= \'3\'';
        objCustSettPartnerSESeach1.Order__c=2;
        objCustSettPartnerSESeach1.Type__c ='Text';
        lstCustSettPatnerSESearch.add(objCustSettPartnerSESeach1);
        try
        {
         Database.insert (lstCustSettPatnerSESearch, false);  
        }catch(Exception e){
         System.debug('Check Obj Access'+e);
        }        
            
    
    
      //Custom setting creation -- Partner_Onboarding_Email_Service_Id__c
       Partner_Onboarding_Email_Service_Id__c dataValueControlFlag36 = new Partner_Onboarding_Email_Service_Id__c();
        dataValueControlFlag36.Name='Email Id';
        dataValueControlFlag36.Email_Id__c ='updatepobtask@2dvepmu7e0rq47l6b1bjksqts.qdhotmas.q.apex.sandbox.salesforce.com';
        
        try
        {
         Database.insert(dataValueControlFlag36, false);
        }catch(Exception e){
         System.debug('Check Obj Access'+e);
        }
    
        List<CustomSettingCountryTheaterMapping__c> lstCountryTheater = new List<CustomSettingCountryTheaterMapping__c>();
        CustomSettingCountryTheaterMapping__c CScountrytheater = new CustomSettingCountryTheaterMapping__c();
        CScountrytheater.Name='Colombia';
        CScountrytheater.Cluster__c='LA2';
        CScountrytheater.CountryCode__c='CO';
        CScountrytheater.Theater__c='Americas';        
        lstCountryTheater.add(CScountrytheater);
    
        try
        {
         Database.insert(lstCountryTheater, false);
        }catch(Exception e){
         System.debug('Check Obj Access'+e);
        }
        
        
        //Custom setting creation -- PartnerUserGroups
        Map<String,User__c> PartnerUserGroupsMap = User__c.getall();
        List<User__c> lstPartnerUserGroups = new List<User__c>();
        if(PartnerUserGroupsMap.get('EMC Contract and Grouping Admin')==null)
        {
        User__c EMCContractandGroupingAdmin = new User__c();
        EMCContractandGroupingAdmin.Name='EMC Contract and Grouping Admin';
        EMCContractandGroupingAdmin.Group_Id__c='00G70000001ktHy';
        lstPartnerUserGroups.add(EMCContractandGroupingAdmin);        
        }
        if(PartnerUserGroupsMap.get('System Administrator')==null)
        {
        User__c SystemAdmin = new User__c();
        SystemAdmin.Name='System Administrator';
        SystemAdmin.Group_Id__c='00G70000001lYOX';
        lstPartnerUserGroups.add(SystemAdmin);        
        }
            
       try
    {
     Database.insert(lstPartnerUserGroups, false);
    }catch(Exception e){
     System.debug('Check Obj Access'+e);
    }       
         /*End of custom setting insertion*/
        
        //Test.stopTest();
    }      
}