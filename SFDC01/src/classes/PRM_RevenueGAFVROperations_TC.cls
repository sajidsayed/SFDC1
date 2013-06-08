/*===================================================================================================================================

History 

26th Mar  12  Kaustav Debnath     Added the code for GAF Revenue Batch functionality testing
5 April 2012  Arif                Restructured test class
3 Oct 2012    Arif                Changes to accomodate object from GAF to GAF Revenue & Rebate 
28 May 2013   Sravanthi				Increased the code coverage for PRM_PAN_VPP_Operations class.    
====================================================================================================================================*/
@isTest
public class PRM_RevenueGAFVROperations_TC{
    
    public static Map<String,Schema.RecordTypeInfo> recordTypes = Account_Groupings__c.sObjectType.getDescribe().getRecordTypeInfosByName();      
     //Method for Creation of Account Grouping  
    public static Account_Groupings__c createAccountGrouping(Account ProfiledAccount,Account_Groupings__c LogicalBlock){
        Account_Groupings__c accountGrouping = new Account_Groupings__c();
        accountGrouping.Name = 'Test Account Grouping';
        accountGrouping.Profiled_Account__c = ProfiledAccount.Id;
        accountGrouping.Active__c = true;
        accountGrouping.No_Master_Required__c = true;
        accountGrouping.Logical_Block_Level_Grouping__c = LogicalBlock.Id;
        accountGrouping.RecordTypeId = recordTypes.get('Partner Grouping').getRecordTypeId();
        insert accountGrouping;
        system.debug('AG IN Method------------>' +accountGrouping.ID__c);
        return accountGrouping;
    }
    public static Account_Groupings__c createLogicalBlock(Account_Groupings__c PAN){
        Account_Groupings__c LogicalBlock = new Account_Groupings__c();
        LogicalBlock.Name = 'Test Logical Block';
        LogicalBlock.RecordTypeId = recordTypes.get('Partner Grouping - Logical Block').getRecordTypeId();
        LogicalBlock.Active__c = true;
        LogicalBlock.Pan_Theater_Level_Grouping__c = PAN.Id;
        insert LogicalBlock;
        //system.debug('AG IN Method------------>' +accountGrouping.ID__c);
        return LogicalBlock;
    }
    public static Account_Groupings__c createPAN(){
        Account_Groupings__c PAN = new Account_Groupings__c();
        PAN.Name = 'Test PAN';
        PAN.Active__c = true;
        PAN.RecordTypeId = recordTypes.get('Partner Grouping - PAN Theater').getRecordTypeId();
        insert PAN;
       // system.debug('AG IN Method------------>' +accountGrouping.ID__c);
        return PAN;
    }

    //Method for Creation of Profiled Account
    public static Account createProfiledAccount(){
        list<Account> lstPartnerAccount = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        lstPartnerAccount[0].name = 'ACCOUNT FOR TEST';
        lstPartnerAccount[0].BillingCountry = 'Colombia'; 
        insert lstPartnerAccount;
        lstPartnerAccount[0].PROFILED_ACCOUNT_FLAG__c = true;
        lstPartnerAccount[0].Ispartner=true;
        update lstPartnerAccount;
        return lstPartnerAccount[0];
    }
    
    //Method for Creation of EMC Business Rule Record for GAF
    public static void createEMCBusinessRulesForGAF(Id recordtypeId){
        List<EMC_Business_Rules__c> lstEMCBusinessRules=new List<EMC_Business_Rules__c>();
        EMC_Business_Rules__c emcBR=new EMC_Business_Rules__c();
        emcBR.EVALUATION_TIME_PERIOD__C='1;2;3;4';
        emcBR.RECORDTYPEID=recordtypeId;
        emcBR.FIELDS_TO_SUM__C='Q1 Total Revenue - Current;Q4 Total Revenue - Previous';
        emcBR.OBJECT_NAME__C='GAF_Revenue_Rebate__c';
        emcBR.PRODUCT_TYPE__C='Services';
        emcBR.FIELD_NAME__C='Adv_Cnsld_Al_Ptr_Rev_Actl_Q1__c';
        emcBR.Theater__c='Americas';
        emcBR.SPECILITY__C='Advanced Consolidate';
        insert emcBR;   
    }
    
    //Method for Creation of EMC Business Rule Record for Velocity Revenue
    public static void createEMCBusinessRulesForVelocityRevenues(Id recordtypeId){
        List<EMC_Business_Rules__c> lstEMCBusinessRules=new List<EMC_Business_Rules__c>();      
        EMC_Business_Rules__c emcBR=new EMC_Business_Rules__c();
        for(Integer Counter=1;Counter<=4;Counter++){
            emcBR=new EMC_Business_Rules__c();
            emcBR.EVALUATION_TIME_PERIOD__C=String.valueOf(Counter);
            emcBR.RECORDTYPEID=recordtypeId;
            emcBR.FIELDS_TO_SUM__C='Q1 Total Revenue - Current;Q4 Total Revenue - Previous';
            emcBR.OBJECT_NAME__C='Velocity_Revenue__c';
            emcBR.PRODUCT_TYPE__C='Services';
            emcBR.FIELD_NAME__C='AC_Curr_Per_Rev_HW_SW__c';
            emcBR.Theater__c='Americas';
            emcBR.SPECILITY__C='Advanced Consolidate';
            lstEMCBusinessRules.add(emcBR);
        }
        insert lstEMCBusinessRules;          
    }
    
    //Method for creation of VelocityRevenue Record
    public static void createVelocityRevenues(Account ProfiledAccount){
        List<Velocity_Revenue__c> lstVelocityRevenues=new List<Velocity_Revenue__c>();
        Velocity_Revenue__c velocityRevenue=new Velocity_Revenue__c();
        velocityRevenue.Partner_Profiled_Account__c=ProfiledAccount.Id;
        velocityRevenue.Theater__c= 'Americas';
        insert velocityRevenue;
    }
    
    //Method for creation of GAF Record
    public static void createGAF(Account ProfiledAccount,Account_Groupings__c LogicalBlock,Account_Groupings__c PAN){
        List<GAF_Revenue_Rebate__c> lstGAF = new List<GAF_Revenue_Rebate__c>();
        GAF_Revenue_Rebate__c GAF = new GAF_Revenue_Rebate__c();
        for(integer i=0;i<5;i++){
            GAF = new GAF_Revenue_Rebate__c();
            if(i==0){
                GAF.Profiled_Account__c = ProfiledAccount.Id;
                GAF.GAF_Year__c=String.valueOf(System.Now().yearGmt());
                GAF.Partner_Type__c ='Distributor';
                GAF.GAF_Revenue_Rebate_Type__c = 'Country';
                GAF.Theater__c ='Americas';
                lstGAF.add(GAF);
            }
            if(i==1){
            	GAF.Profiled_Account__c = ProfiledAccount.Id;
            	GAF.RecordTypeId=recordTypes.get('Partner Grouping - Logical Block').getRecordTypeId();
                GAF.Logical_Block__c = LogicalBlock.Id;
                GAF.GAF_Year__c=String.valueOf(System.Now().yearGmt());
                GAF.Partner_Type__c ='Distributor';
                GAF.GAF_Revenue_Rebate_Type__c = 'Logical Block';
                GAF.Theater__c ='Americas';
                lstGAF.add(GAF);
            }
            if(i==2){
            	GAF.Profiled_Account__c = ProfiledAccount.Id;
            	GAF.RecordTypeId=recordTypes.get('Partner Grouping - Logical Block').getRecordTypeId();
                GAF.Pan_Theater__c = PAN.Id;
                GAF.GAF_Year__c=String.valueOf(System.Now().yearGmt());
                GAF.Partner_Type__c ='Distributor';
                GAF.GAF_Revenue_Rebate_Type__c = 'Pan-Theater';
                GAF.Theater__c ='Americas';
                lstGAF.add(GAF);
            }
            if(i==3){
                GAF.Profiled_Account__c = ProfiledAccount.Id;                
                GAF.GAF_Year__c=String.valueOf(System.Now().yearGmt());
                GAF.Partner_Type__c ='Distributor';
                GAF.GAF_Revenue_Rebate_Type__c = 'Custom';
                GAF.Theater__c ='Americas';
                lstGAF.add(GAF);
            }
        }
        database.insert(lstGAF,false);
    }

    //Method for creation of Staging Data
    public static void createStagingData(Id AccountId,string Year,string groupingId){
        list<Staging_data__c> lstStagingData = new list<Staging_data__c>();
        for(Integer i=1;i<=4;i++){
            Staging_data__c staging=new Staging_data__c();
            staging.Batch_Id__c=0000;
            staging.Object_Name__c='Revenue';
            staging.Text1__c=groupingId;
            staging.Text6__c='456.00';
            staging.Text7__c='542.22';
            staging.Text8__c='556.22';
            staging.Text9__c='789.25';
            staging.Text2__c='Advanced Consolidate';
            staging.Text3__c='Services';
            staging.Text4__c= Year;
            staging.Text10__c=String.valueOf(i);
            lstStagingData.add(staging);
        }        
        insert lstStagingData;
    }

    //Method for updating Custom Setting Value
    public static void updateCustomSetting(){
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c customSettingRecord = new CustomSettingDataValueMap__c();
        List<CustomSettingDataValueMap__c> customSettingsDataToUpdate = new List<CustomSettingDataValueMap__c>();
       
        if(!DataValueMap.isEmpty() && DataValueMap.containsKey('Batch Id')){
            customSettingRecord = DataValueMap.get('Batch Id');
            customSettingRecord.DateValue__c = 0000;
            customSettingsDataToUpdate.add(customSettingRecord);
        }
        update customSettingsDataToUpdate;
    }

    public static testMethod void testRevenueGAFVRCalculation() {
        user SysAdmin=[Select Id,Name,Profile.Name,isActive from user where Profile.Name like 'System Administrator' and isActive=true limit 1]; 
        Map<String,Schema.RecordTypeInfo> recordTypesEBR = EMC_Business_Rules__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        Account profiledAccount = createProfiledAccount();
        System.RunAs(SysAdmin){
            updateCustomSetting();
        } 
        Account_Groupings__c PAN = createPAN();
        Account_Groupings__c LogicalBlock = createLogicalBlock(PAN);
        Account_Groupings__c accountGrouping = createAccountGrouping(profiledAccount,LogicalBlock);
        accountGrouping = [Select Id,ID__c from Account_Groupings__c where Id = :accountGrouping.Id];
        createEMCBusinessRulesForGAF(recordTypesEBR.get('Revenue Summary Rule').getRecordTypeId());
        system.debug('accountGrouping================='+accountGrouping);
        createEMCBusinessRulesForVelocityRevenues(recordTypesEBR.get('Revenue Summary Rule').getRecordTypeId());
        createVelocityRevenues(profiledAccount);
        createGAF(profiledAccount,LogicalBlock,PAN);
         system.debug('AG IN TEST METHOD------------>' +accountGrouping.ID__c);
        createStagingData(profiledAccount.Id,string.valueOf(System.Now().yearGmt()),accountGrouping.ID__c);
        createStagingData(profiledAccount.Id,string.valueOf(System.Now().yearGmt()-1),accountGrouping.ID__c);
        
        PRM_PopulateRevenueBatch ExecuteRevenueBatch = new PRM_PopulateRevenueBatch ();
        ExecuteRevenueBatch.batchQuery ='select Batch_Id__c,Text1__c,Text2__c,Text3__c,Text4__c,Text5__c,Text6__c,Text7__c,Text8__c,Text9__c,Text10__c,Object_Name__c'+ 
                   ' from Staging_Data__c where Object_Name__c = \'Revenue\' and Batch_Id__c =0000';
        PRM_CalculateGAFandVelocityFieldsBatch GAFAndVRBatchObj=new PRM_CalculateGAFandVelocityFieldsBatch();
        GAFAndVRBatchObj.batchQuery = 'select Id,PROFILED_ACCOUNT_FLAG__c from account where PROFILED_ACCOUNT_FLAG__c = true and Name = \'ACCOUNT FOR TEST\'';
       
     /*   String Query = 'SELECT Id,GAF_Revenue_Rebate_Type__c,Profiled_Account__c,Logical_Block__c,Pan_Theater__c,Country__c,GAF_Year__c,Partner_Type__c,Theater__c,Advcd_Cnsld_Actual_Q1__c,Advcd_Cnsld_Actual_Q2__c,Advcd_Cnsld_Actual_Q3__c,Advcd_Cnsld_Actual_Q4__c,Advcd_Cnsld_Actual_Tot__c,Advcd_Cnsld_Rebt_Q1__c,Advcd_Cnsld_Rebt_Q2__c,Advcd_Cnsld_Rebt_Q3__c,Advcd_Cnsld_Rebt_Q4__c,'+
                    'Advcd_Cnsld_Rebt_Tot__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q1__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q2__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q3__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q4__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q1__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q2__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q3__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q4__c,Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q1__c,Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q2__c,'+
                    'Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q3__c,Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q4__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q1__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q2__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q3__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q4__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q1__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q2__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q3__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q4__c,'+
                    'BRS_Cnsld_All_Ptr_Rev_Rebt_Tot__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q1__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q2__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q3__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q4__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Tot__c,BRS_Cnsld_All_Ptr_Unit_Rebt_Tot__c,BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q1__c,BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q2__c,BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q3__c,'+
                    'BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q4__c,BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Tot__c,BRS_Cnsld_All_Ptr_Unit_Actl_Tot__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q1__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q2__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q3__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q4__c,BRS_Cnsld_All_Ptr_Unit_Rebt_Q1__c,BRS_Cnsld_All_Ptr_Unit_Rebt_Q2__c,BRS_Cnsld_All_Ptr_Unit_Rebt_Q3__c,'+
                    'BRS_Cnsld_All_Ptr_Unit_Rebt_Q4__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q1__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q2__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q3__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q4__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Tot__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q1__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q2__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q3__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q4__c,'+
                    'BRS_Cnsld_Grwt_Ptr_Unit_Actl_Tot__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q1__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q2__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q3__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q4__c,BRS_Cnsld_All_Ptr_Rev_Actl_Tot__c,BRS_Cnsld_Grwt_Rev_Rebt_Q1__c,BRS_Cnsld_Grwt_Rev_Rebt_Q2__c,BRS_Cnsld_Grwt_Rev_Rebt_Q3__c,BRS_Cnsld_Grwt_Rev_Rebt_Q4__c,BRS_Cnsld_Grwt_Rev_Rebt_Tot__c,'+
                    'BRS_Cnsld_Grwt_Unit_Rebt_Q1__c,BRS_Cnsld_Grwt_Unit_Rebt_Q2__c,BRS_Cnsld_Grwt_Unit_Rebt_Q3__c,BRS_Cnsld_Grwt_Unit_Rebt_Q4__c,BRS_Cnsld_Grwt_Unit_Rebt_Tot__c,BRS_Actl_Q1__c,BRS_Actl_Q2__c,BRS_Actl_Q3__c,BRS_Actl_Q4__c,BRS_Actl_Tot__c,BRS_Al_Ptr_Rebt_Q1__c,BRS_Al_Ptr_Rebt_Q2__c,BRS_Al_Ptr_Rebt_Q3__c,BRS_Al_Ptr_Rebt_Q4__c,BRS_Al_Ptr_Rebt_Tot__c,'+
                    'BRS_Al_Ptr_Rev_Actl_Q1__c,BRS_Al_Ptr_Rev_Actl_Q2__c,BRS_Al_Ptr_Rev_Actl_Q3__c,BRS_Al_Ptr_Rev_Actl_Q4__c,BRS_Al_Ptr_Rev_Actl_Tot__c,BRS_Al_Ptr_Rev_Rebt_Q1__c,BRS_Al_Ptr_Rev_Rebt_Q2__c,BRS_Al_Ptr_Rev_Rebt_Q3__c,BRS_Al_Ptr_Rev_Rebt_Q4__c,BRS_Al_Ptr_Rev_Rebt_Tot__c,BRS_Al_Ptr_Unit_Actl_Q1__c,BRS_Al_Ptr_Unit_Actl_Q2__c,BRS_Al_Ptr_Unit_Actl_Q3__c,'+
                    'BRS_Al_Ptr_Unit_Actl_Q4__c,BRS_Al_Ptr_Unit_Actl_Tot__c,BRS_Al_Ptr_Unit_Rebt_Q1__c,BRS_Al_Ptr_Unit_Rebt_Q2__c,BRS_Al_Ptr_Unit_Rebt_Q3__c,BRS_Al_Ptr_Unit_Rebt_Q4__c,BRS_Al_Ptr_Unit_Rebt_Tot__c,BRS_Grwt_Ptr_Rebt_Q1__c,BRS_Grwt_Ptr_Rebt_Q2__c,BRS_Grwt_Ptr_Rebt_Q3__c,BRS_Grwt_Ptr_Rebt_Q4__c,BRS_Grwt_Ptr_Rebt_Tot__c,BRS_Grwt_Ptr_Rev_Actl_Q1__c,'+
                    'BRS_Grwt_Ptr_Rev_Actl_Q2__c,BRS_Grwt_Ptr_Rev_Actl_Q3__c,BRS_Grwt_Ptr_Rev_Actl_Q4__c,BRS_Grwt_Ptr_Rev_Actl_Tot__c,BRS_Grwt_Ptr_Unit_Actl_Q1__c,BRS_Grwt_Ptr_Unit_Actl_Q2__c,BRS_Grwt_Ptr_Unit_Actl_Q3__c,BRS_Grwt_Ptr_Unit_Actl_Q4__c,BRS_Grwt_Ptr_Unit_Actl_Tot__c,BRS_Rebt_Q1__c,BRS_Rebt_Q2__c,BRS_Rebt_Q3__c,BRS_Rebt_Q4__c,BRS_Rebt_Tot__c,'+
                    'Cnsld_Actl_Q1__c,Cnsld_Actl_Q2__c,Cnsld_Actl_Q3__c,Cnsld_Actl_Q4__c,Cnsld_Actl_Tot__c,Cnsld_Al_Ptr_Rebt_Q1__c,Cnsld_Al_Ptr_Rebt_Q2__c,Cnsld_Al_Ptr_Rebt_Q3__c,Cnsld_Al_Ptr_Rebt_Q4__c,Cnsld_Al_Ptr_Rebt_Tot__c,Cnsld_Al_Ptr_Rev_Actl_Q1__c,Cnsld_Al_Ptr_Rev_Actl_Q2__c,Cnsld_Al_Ptr_Rev_Actl_Q3__c,Cnsld_Al_Ptr_Rev_Actl_Q4__c,Cnsld_Al_Ptr_Unit_Actl_Q1__c,'+
                    'Cnsld_Al_Ptr_Unit_Actl_Q2__c,Cnsld_Al_Ptr_Unit_Actl_Q3__c,Cnsld_Al_Ptr_Unit_Actl_Q4__c,Cnsld_Al_Ptr_Unit_Rebt_Q1__c,Cnsld_Al_Ptr_Unit_Rebt_Q2__c,Cnsld_Al_Ptr_Unit_Rebt_Q3__c,Cnsld_Al_Ptr_Unit_Rebt_Q4__c,Cnsld_Al_Ptr_Rev_Actl_Tot__c,Cnsld_Al_Ptr_Rev_Rebt_Q1__c,Cnsld_All_Ptr_Unt_Actl_Tot__c,Cnsld_All_Ptr_Rev_Rebt_Q2__c,Cnsld_All_Ptr_Rev_Rebt_Q3__c,'+
                    'Cnsld_All_Ptr_Rev_Rebt_Q4__c,Cnsld_All_Ptr_Rev_Rebt_Tot__c,Cnsld_All_Ptr_Unt_Rebt_Tot__c,Cnsld_Grwt_Ptr_Rebt_Q1__c,Cnsld_Grwt_Ptr_Rebt_Q2__c,Cnsld_Grwt_Ptr_Rebt_Q3__c,Cnsld_Grwt_Ptr_Rebt_Q4__c,Cnsld_Grwt_Ptr_Rebt_Tot__c,Cnsld_Grwt_Ptr_Rev_Actl_Q1__c,Cnsld_Grwt_Ptr_Rev_Actl_Q2__c,Cnsld_Grwt_Ptr_Rev_Actl_Q3__c,Cnsld_Grwt_Ptr_Rev_Actl_Q4__c,'+
                    'Cnsld_Grwt_Ptr_Rev_Actl_Tot__c,Cnsld_Grwt_Ptr_Unt_Actl_Q1__c,Cnsld_Grwt_Ptr_Unt_Actl_Q2__c,Cnsld_Grwt_Ptr_Unt_Actl_Q3__c,Cnsld_Grwt_Ptr_Unt_Actl_Q4__c,Cnsld_Rebt_Q1__c,Cnsld_Rebt_Q2__c,Cnsld_Rebt_Q3__c,Cnsld_Rebt_Q4__c,Cnsld_Rebt_Tot__c,Cnsld_Grwt_Ptr_Unt_Actl_Tot__c,Gvr_Arv_Actl_Q1__c,Gvr_Arv_Acl_Q2__c,Gvr_Arv_Acl_Q3__c,Gvr_Arv_Acl_Q4__c,'+
                    'Gvr_Arv_Acl_Tot__c,Gvr_Arv_Al_Ptr_Rbt_Q1__c,Gvr_Arv_Al_Ptr_Rbt_Q2__c,Gvr_Arv_Al_Ptr_Rbt_Q3__c,Gvr_Arv_Al_Ptr_Rbt_Q4__c,Gvrn_Archv_Rebt_Q1__c,Gvrn_Archv_Rebt_Q2__c,Gvrn_Archv_Rebt_Q3__c,Gvrn_Archv_Rebt_Q4__c,Gvrn_Archv_Rebt_Tot__c,Gvrn_Archv_All_Ptr_Rebt_Tot__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Q1__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Q2__c,'+
                    'Gvrn_Archv_Al_Ptr_Rev_Actl_Q3__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Q4__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Tot__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q1__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q2__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q3__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q4__c,Gvrn_Archv_Grwt_Ptr_Rebt_Q1__c,Gvrn_Archv_Grwt_Ptr_Rebt_Q2__c,Gvrn_Archv_Grwt_Ptr_Rebt_Q3__c,'+
                    'Gvrn_Archv_Grwt_Ptr_Rebt_Q4__c,Gvrn_Archv_Grwt_Ptr_Rebt_Tot__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Tot__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q1__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q2__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q3__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q4__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Tot__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Tot__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Q1__c,'+
                    'Gvrn_Archv_Al_Ptr_Unt_Actl_Q2__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Q3__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Q4__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q1__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q2__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q3__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q4__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Tot__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Tot__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q1__c,'+
                    'Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q2__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q3__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q4__c,'+
                    'Isilon_Acl_Tot__c,Isilon_Al_Ptr_Rbt_Q1__c,Isilon_Al_Ptr_Rbt_Q2__c,Isilon_Al_Ptr_Rbt_Q3__c,Isilon_Al_Ptr_Rbt_Q4__c,Isilon_Rebt_Q1__c,Isilon_Rebt_Q2__c,Isilon_Rebt_Q3__c,Isilon_Rebt_Q4__c,Isilon_Rebt_Tot__c,Isilon_Al_Ptr_Rbt_Tot__c,Isilon_Al_Ptr_Rev_Actl_Q1__c,Isilon_Al_Ptr_Rev_Actl_Q2__c,Isilon_Al_Ptr_Rev_Actl_Q3__c,Isilon_Al_Ptr_Rev_Actl_Q4__c,'+
                    'Isilon_Al_Ptr_Rev_Rbt_Tot__c,Isilon_Al_Ptr_Rev_Rebt_Q1__c,Isilon_Al_Ptr_Rev_Rebt_Q2__c,Isilon_Al_Ptr_Rev_Rebt_Q3__c,Isilon_Al_Ptr_Rev_Rebt_Q4__c,Isilon_Grwt_Ptr_Rebt_Q1__c,Isilon_Grwt_Ptr_Rebt_Q2__c,Isilon_Grwt_Ptr_Rebt_Q3__c,Isilon_Grwt_Ptr_Rebt_Q4__c,Isilon_Grwt_Ptrs_Rebt_Tot__c,Isilon_Al_Ptr_Unt_Actl_Tot__c,Isilon_Al_Ptr_Unt_Actl_Q1__c,'+
                    'Isilon_Al_Ptr_Unt_Actl_Q2__c,Isilon_Al_Ptr_Unt_Actl_Q3__c,Isilon_Al_Ptr_Unt_Actl_Q4__c,Isilon_All_Ptr_Unt_Rebt_Q1__c,Isilon_All_Ptr_Unt_Rebt_Q2__c,Isilon_All_Ptr_Unt_Rebt_Q3__c,Isilon_All_Ptr_Unt_Rebt_Q4__c,Isilon_All_Ptr_Unt_Rebt_Tot__c,Isilon_Al_Ptnr_Rev_Actual_Tot__c,Isilon_Grwt_Ptr_Rev_Actl_Q1__c,Isilon_Grwt_Ptr_Rev_Actl_Q2__c,'+
                    'Isilon_Grwt_Ptr_Rev_Actl_Q3__c,Isilon_Grwt_Ptr_Rev_Actl_Q4__c,Isilon_Grwt_Ptr_Rev_Actl_Tot__c,Isilon_Grwt_Ptr_Unt_Actl_Tot__c,Isilon_Grwt_Ptr_Unts_Actl_Q1__c,Isilon_Grwt_Ptr_Unts_Actl_Q2__c,Isilon_Grwt_Ptr_Unts_Actl_Q3__c,Isilon_Grwt_Ptr_Unts_Actl_Q4__c,'+
                    'Isilon_Incentive_Actual_Q1__c,Isilon_Incentive_Actual_Q2__c,Isilon_Incentive_Actual_Q3__c,Isilon_Incentive_Actual_Q4__c,Isilon_Incentive_Actual_Total__c,Isilon_Incentive_Rebate_Q1__c,Isilon_Incentive_Rebate_Q2__c,Isilon_Incentive_Rebate_Q3__c,Isilon_Incentive_Rebate_Q4__c,Isilon_Incentive_Rebate_Total__c,'+
                   	'Target_Products_Actual_Q1__c,Target_Products_Actual_Q2__c,Target_Products_Actual_Q3__c,Target_Products_Actual_Q4__c,Target_Products_Actual_Total__c,Target_Products_Rebate_Q1__c,Target_Products_Rebate_Q2__c,Target_Products_Rebate_Q3__c,Target_Products_Rebate_Q4__c,Target_Products_Rebate_Total__c'+
                    ' from GAF_Revenue_Rebate__c where (GAF_Revenue_Rebate_Type__c=\'Logical Block\' OR GAF_Revenue_Rebate_Type__c=\'Pan-Theater\' OR GAF_Revenue_Rebate_Type__c=\'Custom\') ORDER BY GAF_Revenue_Rebate_Type__c  limit 1';
           
      String Query = 'SELECT Id,GAF_Revenue_Rebate_Type__c,Profiled_Account__c,Logical_Block__c,Pan_Theater__c,Country__c,GAF_Year__c,Partner_Type__c,Theater__c,Advcd_Cnsld_Actual_Q1__c,Advcd_Cnsld_Actual_Q2__c,Advcd_Cnsld_Actual_Q3__c,Advcd_Cnsld_Actual_Q4__c,Advcd_Cnsld_Actual_Tot__c,Advcd_Cnsld_Rebt_Q1__c,Advcd_Cnsld_Rebt_Q2__c,Advcd_Cnsld_Rebt_Q3__c,Advcd_Cnsld_Rebt_Q4__c,'+
                    'Advcd_Cnsld_Rebt_Tot__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q1__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q2__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q3__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q4__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q1__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q2__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q3__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q4__c,Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q1__c,Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q2__c,'+
                    'Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q3__c,Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q4__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q1__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q2__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q3__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q4__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q1__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q2__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q3__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q4__c,'+
                    'BRS_Cnsld_All_Ptr_Rev_Rebt_Tot__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q1__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q2__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q3__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q4__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Tot__c,BRS_Cnsld_All_Ptr_Unit_Rebt_Tot__c,BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q1__c,BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q2__c,BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q3__c,'+
                    'BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q4__c,BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Tot__c,BRS_Cnsld_All_Ptr_Unit_Actl_Tot__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q1__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q2__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q3__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q4__c,BRS_Cnsld_All_Ptr_Unit_Rebt_Q1__c,BRS_Cnsld_All_Ptr_Unit_Rebt_Q2__c,BRS_Cnsld_All_Ptr_Unit_Rebt_Q3__c,'+
                    'BRS_Cnsld_All_Ptr_Unit_Rebt_Q4__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q1__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q2__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q3__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q4__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Tot__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q1__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q2__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q3__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q4__c,'+
                    'BRS_Cnsld_Grwt_Ptr_Unit_Actl_Tot__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q1__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q2__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q3__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q4__c,BRS_Cnsld_All_Ptr_Rev_Actl_Tot__c,BRS_Cnsld_Grwt_Rev_Rebt_Q1__c,BRS_Cnsld_Grwt_Rev_Rebt_Q2__c,BRS_Cnsld_Grwt_Rev_Rebt_Q3__c,BRS_Cnsld_Grwt_Rev_Rebt_Q4__c,BRS_Cnsld_Grwt_Rev_Rebt_Tot__c,'+
                    'BRS_Cnsld_Grwt_Unit_Rebt_Q1__c,BRS_Cnsld_Grwt_Unit_Rebt_Q2__c,BRS_Cnsld_Grwt_Unit_Rebt_Q3__c,BRS_Cnsld_Grwt_Unit_Rebt_Q4__c,BRS_Cnsld_Grwt_Unit_Rebt_Tot__c,BRS_Actl_Q1__c,BRS_Actl_Q2__c,BRS_Actl_Q3__c,BRS_Actl_Q4__c,BRS_Actl_Tot__c,BRS_Al_Ptr_Rebt_Q1__c,BRS_Al_Ptr_Rebt_Q2__c,BRS_Al_Ptr_Rebt_Q3__c,BRS_Al_Ptr_Rebt_Q4__c,BRS_Al_Ptr_Rebt_Tot__c,'+
                    'BRS_Al_Ptr_Rev_Actl_Q1__c,BRS_Al_Ptr_Rev_Actl_Q2__c,BRS_Al_Ptr_Rev_Actl_Q3__c,BRS_Al_Ptr_Rev_Actl_Q4__c,BRS_Al_Ptr_Rev_Actl_Tot__c,BRS_Al_Ptr_Rev_Rebt_Q1__c,BRS_Al_Ptr_Rev_Rebt_Q2__c,BRS_Al_Ptr_Rev_Rebt_Q3__c,BRS_Al_Ptr_Rev_Rebt_Q4__c,BRS_Al_Ptr_Rev_Rebt_Tot__c,BRS_Al_Ptr_Unit_Actl_Q1__c,BRS_Al_Ptr_Unit_Actl_Q2__c,BRS_Al_Ptr_Unit_Actl_Q3__c,'+
                    'BRS_Al_Ptr_Unit_Actl_Q4__c,BRS_Al_Ptr_Unit_Actl_Tot__c,BRS_Al_Ptr_Unit_Rebt_Q1__c,BRS_Al_Ptr_Unit_Rebt_Q2__c,BRS_Al_Ptr_Unit_Rebt_Q3__c,BRS_Al_Ptr_Unit_Rebt_Q4__c,BRS_Al_Ptr_Unit_Rebt_Tot__c,BRS_Grwt_Ptr_Rebt_Q1__c,BRS_Grwt_Ptr_Rebt_Q2__c,BRS_Grwt_Ptr_Rebt_Q3__c,BRS_Grwt_Ptr_Rebt_Q4__c,BRS_Grwt_Ptr_Rebt_Tot__c,BRS_Grwt_Ptr_Rev_Actl_Q1__c,'+
                    'BRS_Grwt_Ptr_Rev_Actl_Q2__c,BRS_Grwt_Ptr_Rev_Actl_Q3__c,BRS_Grwt_Ptr_Rev_Actl_Q4__c,BRS_Grwt_Ptr_Rev_Actl_Tot__c,BRS_Grwt_Ptr_Unit_Actl_Q1__c,BRS_Grwt_Ptr_Unit_Actl_Q2__c,BRS_Grwt_Ptr_Unit_Actl_Q3__c,BRS_Grwt_Ptr_Unit_Actl_Q4__c,BRS_Grwt_Ptr_Unit_Actl_Tot__c,BRS_Rebt_Q1__c,BRS_Rebt_Q2__c,BRS_Rebt_Q3__c,BRS_Rebt_Q4__c,BRS_Rebt_Tot__c,'+
                    'Cnsld_Actl_Q1__c,Cnsld_Actl_Q2__c,Cnsld_Actl_Q3__c,Cnsld_Actl_Q4__c,Cnsld_Actl_Tot__c,Cnsld_Al_Ptr_Rebt_Q1__c,Cnsld_Al_Ptr_Rebt_Q2__c,Cnsld_Al_Ptr_Rebt_Q3__c,Cnsld_Al_Ptr_Rebt_Q4__c,Cnsld_Al_Ptr_Rebt_Tot__c,Cnsld_Al_Ptr_Rev_Actl_Q1__c,Cnsld_Al_Ptr_Rev_Actl_Q2__c,Cnsld_Al_Ptr_Rev_Actl_Q3__c,Cnsld_Al_Ptr_Rev_Actl_Q4__c,Cnsld_Al_Ptr_Unit_Actl_Q1__c,'+
                    'Cnsld_Al_Ptr_Unit_Actl_Q2__c,Cnsld_Al_Ptr_Unit_Actl_Q3__c,Cnsld_Al_Ptr_Unit_Actl_Q4__c,Cnsld_Al_Ptr_Unit_Rebt_Q1__c,Cnsld_Al_Ptr_Unit_Rebt_Q2__c,Cnsld_Al_Ptr_Unit_Rebt_Q3__c,Cnsld_Al_Ptr_Unit_Rebt_Q4__c,Cnsld_Al_Ptr_Rev_Actl_Tot__c,Cnsld_Al_Ptr_Rev_Rebt_Q1__c,Cnsld_All_Ptr_Unt_Actl_Tot__c,Cnsld_All_Ptr_Rev_Rebt_Q2__c,Cnsld_All_Ptr_Rev_Rebt_Q3__c,'+
                    'Cnsld_All_Ptr_Rev_Rebt_Q4__c,Cnsld_All_Ptr_Rev_Rebt_Tot__c,Cnsld_All_Ptr_Unt_Rebt_Tot__c,Cnsld_Grwt_Ptr_Rebt_Q1__c,Cnsld_Grwt_Ptr_Rebt_Q2__c,Cnsld_Grwt_Ptr_Rebt_Q3__c,Cnsld_Grwt_Ptr_Rebt_Q4__c,Cnsld_Grwt_Ptr_Rebt_Tot__c,Cnsld_Grwt_Ptr_Rev_Actl_Q1__c,Cnsld_Grwt_Ptr_Rev_Actl_Q2__c,Cnsld_Grwt_Ptr_Rev_Actl_Q3__c,Cnsld_Grwt_Ptr_Rev_Actl_Q4__c,'+
                    'Cnsld_Grwt_Ptr_Rev_Actl_Tot__c,Cnsld_Grwt_Ptr_Unt_Actl_Q1__c,Cnsld_Grwt_Ptr_Unt_Actl_Q2__c,Cnsld_Grwt_Ptr_Unt_Actl_Q3__c,Cnsld_Grwt_Ptr_Unt_Actl_Q4__c,Cnsld_Rebt_Q1__c,Cnsld_Rebt_Q2__c,Cnsld_Rebt_Q3__c,Cnsld_Rebt_Q4__c,Cnsld_Rebt_Tot__c,Cnsld_Grwt_Ptr_Unt_Actl_Tot__c,Gvr_Arv_Actl_Q1__c,Gvr_Arv_Acl_Q2__c,Gvr_Arv_Acl_Q3__c,Gvr_Arv_Acl_Q4__c,'+
                    'Gvr_Arv_Acl_Tot__c,Gvr_Arv_Al_Ptr_Rbt_Q1__c,Gvr_Arv_Al_Ptr_Rbt_Q2__c,Gvr_Arv_Al_Ptr_Rbt_Q3__c,Gvr_Arv_Al_Ptr_Rbt_Q4__c,Gvrn_Archv_Rebt_Q1__c,Gvrn_Archv_Rebt_Q2__c,Gvrn_Archv_Rebt_Q3__c,Gvrn_Archv_Rebt_Q4__c,Gvrn_Archv_Rebt_Tot__c,Gvrn_Archv_All_Ptr_Rebt_Tot__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Q1__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Q2__c,'+
                    'Gvrn_Archv_Al_Ptr_Rev_Actl_Q3__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Q4__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Tot__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q1__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q2__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q3__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q4__c,Gvrn_Archv_Grwt_Ptr_Rebt_Q1__c,Gvrn_Archv_Grwt_Ptr_Rebt_Q2__c,Gvrn_Archv_Grwt_Ptr_Rebt_Q3__c,'+
                    'Gvrn_Archv_Grwt_Ptr_Rebt_Q4__c,Gvrn_Archv_Grwt_Ptr_Rebt_Tot__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Tot__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q1__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q2__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q3__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q4__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Tot__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Tot__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Q1__c,'+
                    'Gvrn_Archv_Al_Ptr_Unt_Actl_Q2__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Q3__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Q4__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q1__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q2__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q3__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q4__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Tot__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Tot__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q1__c,'+
                    'Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q2__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q3__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q4__c,Logical_Block__r.Name,Pan_Theater__r.Name,'+
                    'Isilon_Grwt_Ptr_Unts_Actl_Q1__c,Isilon_Grwt_Ptr_Unts_Actl_Q2__c,Isilon_Grwt_Ptr_Unts_Actl_Q3__c,Isilon_Grwt_Ptr_Unts_Actl_Q4__c,Isilon_Grwt_Ptr_Rev_Actl_Q1__c,Isilon_Grwt_Ptr_Rev_Actl_Q2__c,'+
                    'Isilon_Grwt_Ptr_Rev_Actl_Q3__c,Isilon_Grwt_Ptr_Rev_Actl_Q4__c,Isilon_Al_Ptr_Unt_Actl_Q1__c,Isilon_Al_Ptr_Unt_Actl_Q2__c,Isilon_Al_Ptr_Unt_Actl_Q3__c,Isilon_Al_Ptr_Unt_Actl_Q4__c,Isilon_Al_Ptr_Rev_Actl_Q1__c,Isilon_Al_Ptr_Rev_Actl_Q2__c,'+
                    'Isilon_Al_Ptr_Rev_Actl_Q3__c,Isilon_Al_Ptr_Rev_Actl_Q4__c,Isilon_Actl_Q1__c,Isilon_Acl_Q2__c,Isilon_Acl_Q3__c,Isilon_Acl_Q4__c'+
                    'from GAF_Revenue_Rebate__c  where (GAF_Revenue_Rebate_Type__c=\'Logical Block\' OR GAF_Revenue_Rebate_Type__c=\'Pan-Theater\') AND'+
                    '(Logical_Block__r.Name = \'Test Logical Block\' OR Pan_Theater__r.Name = \'Test PAN\') ORDER BY GAF_Revenue_Rebate_Type__c';
        */
        
         String Query = 'SELECT Id,GAF_Revenue_Rebate_Type__c,Profiled_Account__c,Logical_Block__c,Pan_Theater__c,Country__c,GAF_Year__c,Partner_Type__c,Theater__c'+
		' from GAF_Revenue_Rebate__c where (GAF_Revenue_Rebate_Type__c=\'Logical Block\' ) ORDER BY GAF_Revenue_Rebate_Type__c limit 10';
        
        PRM_PopulateFieldsOnGAFRevRebateBatch PopulateFieldsOnGAFRevRebateBatch = new PRM_PopulateFieldsOnGAFRevRebateBatch(Query);
        Test.startTest();
             ID batchprocessid = Database.executeBatch(ExecuteRevenueBatch);
             ID batchprocessid1 = Database.executeBatch(GAFAndVRBatchObj);
             ID batchprocessid2 = Database.executeBatch(PopulateFieldsOnGAFRevRebateBatch,10);
         
        /* PRM_RevenueGAFVROperations obj = new PRM_RevenueGAFVROperations();
          obj.insertUpdateRevenue(lstStagingData);
          obj.calculateRevenueForAccount(lstAccount);*/
         Test.stopTest();
    }
    
    public static testMethod void testRevenueGAFVRCalculation2() {
        user SysAdmin=[Select Id,Name,Profile.Name,isActive from user where Profile.Name like 'System Administrator' and isActive=true limit 1]; 
        Map<String,Schema.RecordTypeInfo> recordTypesEBR = EMC_Business_Rules__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        Account profiledAccount = createProfiledAccount();
        System.RunAs(SysAdmin){
            updateCustomSetting();
        } 
        Account_Groupings__c PAN = createPAN();
        Account_Groupings__c LogicalBlock = createLogicalBlock(PAN);
        Account_Groupings__c accountGrouping = createAccountGrouping(profiledAccount,LogicalBlock);
        accountGrouping = [Select Id,ID__c from Account_Groupings__c where Id = :accountGrouping.Id];
        createEMCBusinessRulesForGAF(recordTypesEBR.get('Revenue Summary Rule').getRecordTypeId());
        createEMCBusinessRulesForVelocityRevenues(recordTypesEBR.get('Revenue Summary Rule').getRecordTypeId());
        createVelocityRevenues(profiledAccount);
        createGAF(profiledAccount,LogicalBlock,PAN);
         system.debug('AG IN TEST METHOD------------>' +accountGrouping.ID__c);
        createStagingData(profiledAccount.Id,string.valueOf(System.Now().yearGmt()),accountGrouping.ID__c);
        createStagingData(profiledAccount.Id,string.valueOf(System.Now().yearGmt()-1),accountGrouping.ID__c);
        
        PRM_PopulateRevenueBatch ExecuteRevenueBatch = new PRM_PopulateRevenueBatch ();
        ExecuteRevenueBatch.batchQuery ='select Batch_Id__c,Text1__c,Text2__c,Text3__c,Text4__c,Text5__c,Text6__c,Text7__c,Text8__c,Text9__c,Text10__c,Object_Name__c'+ 
                   ' from Staging_Data__c where Object_Name__c = \'Revenue\' and Batch_Id__c =0000';
        PRM_CalculateGAFandVelocityFieldsBatch GAFAndVRBatchObj=new PRM_CalculateGAFandVelocityFieldsBatch(); 
         GAFAndVRBatchObj.batchQuery = 'select Id,PROFILED_ACCOUNT_FLAG__c from account where PROFILED_ACCOUNT_FLAG__c = true and Name = \'ACCOUNT FOR TEST\'';
         String Query = 'SELECT Id,GAF_Revenue_Rebate_Type__c,Profiled_Account__c,Logical_Block__c,Pan_Theater__c,Country__c,GAF_Year__c,Partner_Type__c,Theater__c'+
		' from GAF_Revenue_Rebate__c where ( GAF_Revenue_Rebate_Type__c=\'Pan-Theater\')  limit 10';
	
        PRM_PopulateFieldsOnGAFRevRebateBatch PopulateFieldsOnGAFRevRebateBatch = new PRM_PopulateFieldsOnGAFRevRebateBatch(Query);
        Test.startTest();
             ID batchprocessid = Database.executeBatch(ExecuteRevenueBatch);
             ID batchprocessid1 = Database.executeBatch(GAFAndVRBatchObj);
             ID batchprocessid2 = Database.executeBatch(PopulateFieldsOnGAFRevRebateBatch,10);
         
        /* PRM_RevenueGAFVROperations obj = new PRM_RevenueGAFVROperations();
          obj.insertUpdateRevenue(lstStagingData);
          obj.calculateRevenueForAccount(lstAccount);*/
         Test.stopTest();
    }
  public static testMethod void testRevenueGAFVRCalculation3() {
        user SysAdmin=[Select Id,Name,Profile.Name,isActive from user where Profile.Name like 'System Administrator' and isActive=true limit 1]; 
        Map<String,Schema.RecordTypeInfo> recordTypesEBR = EMC_Business_Rules__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        Account profiledAccount = createProfiledAccount();
        System.RunAs(SysAdmin){
            updateCustomSetting();
        }        
        
        Account_Groupings__c PAN = createPAN();
        Account_Groupings__c LogicalBlock = createLogicalBlock(PAN);
        Account_Groupings__c accountGrouping = createAccountGrouping(profiledAccount,LogicalBlock);
        accountGrouping = [Select Id,ID__c from Account_Groupings__c where Id = :accountGrouping.Id];
        createEMCBusinessRulesForGAF(recordTypesEBR.get('Revenue Summary Rule').getRecordTypeId());
        createEMCBusinessRulesForVelocityRevenues(recordTypesEBR.get('Revenue Summary Rule').getRecordTypeId());
        createVelocityRevenues(profiledAccount);
        createGAF(profiledAccount,LogicalBlock,PAN);
         system.debug('AG IN TEST METHOD------------>' +accountGrouping.ID__c);
        createStagingData(profiledAccount.Id,string.valueOf(System.Now().yearGmt()),accountGrouping.ID__c);
        createStagingData(profiledAccount.Id,string.valueOf(System.Now().yearGmt()-1),accountGrouping.ID__c);
        
        PRM_PopulateRevenueBatch ExecuteRevenueBatch = new PRM_PopulateRevenueBatch ();
        ExecuteRevenueBatch.batchQuery ='select Batch_Id__c,Text1__c,Text2__c,Text3__c,Text4__c,Text5__c,Text6__c,Text7__c,Text8__c,Text9__c,Text10__c,Object_Name__c'+ 
                   ' from Staging_Data__c where Object_Name__c = \'Revenue\' and Batch_Id__c =0000';
        PRM_CalculateGAFandVelocityFieldsBatch GAFAndVRBatchObj=new PRM_CalculateGAFandVelocityFieldsBatch();
        GAFAndVRBatchObj.batchQuery = 'select Id,PROFILED_ACCOUNT_FLAG__c from account where PROFILED_ACCOUNT_FLAG__c = true and Name = \'ACCOUNT FOR TEST\'';
         String Query = 'SELECT Id,GAF_Revenue_Rebate_Type__c,Profiled_Account__c,Logical_Block__c,Pan_Theater__c,Country__c,GAF_Year__c,Partner_Type__c,Theater__c'+
		' from GAF_Revenue_Rebate__c where (  GAF_Revenue_Rebate_Type__c=\'Custom\') limit 10';       
        PRM_PopulateFieldsOnGAFRevRebateBatch PopulateFieldsOnGAFRevRebateBatch = new PRM_PopulateFieldsOnGAFRevRebateBatch(Query);
        Test.startTest();
             ID batchprocessid = Database.executeBatch(ExecuteRevenueBatch);
             ID batchprocessid1 = Database.executeBatch(GAFAndVRBatchObj);             
             ID batchprocessid2 = Database.executeBatch(PopulateFieldsOnGAFRevRebateBatch,10);
         
         /* PRM_RevenueGAFVROperations obj = new PRM_RevenueGAFVROperations();
           obj.insertUpdateRevenue(lstStagingData);
           obj.calculateRevenueForAccount(lstAccount); */
           Test.stopTest();
    }
    
    public static testMethod void testGrouping() {
    	
    	Account_Groupings__c PAN = createPAN();
    	Account_Groupings__c PAN1 = createPAN();
    	Account profiledAccount = createProfiledAccount();
        Account_Groupings__c LogicalBlock1 = createLogicalBlock(PAN);
        Account_Groupings__c LogicalBlock2 = createLogicalBlock(PAN);
        Account_Groupings__c accountGrouping1 = createAccountGrouping(profiledAccount,LogicalBlock1);
        Account_Groupings__c accountGrouping2 = createAccountGrouping(profiledAccount,LogicalBlock2);
        Map<id,Account_Groupings__c> oldm = new Map<id,Account_Groupings__c>();
        Map<id,Account_Groupings__c> newm = new Map<id,Account_Groupings__c>();
        oldm.put(PAN.id,PAN);
        PAN.Target_Tier__c = 'Premier';
        PAN.Cluster__c = 'NA1';
        PAN.Deployed_To__c = 'Premier';
        newm.put(PAN.id,PAN);
        PRM_PAN_VPP_Operations ppvp = new PRM_PAN_VPP_Operations();
        Test.startTest();
        ppvp.markGroupingToProcess(oldm,newm);// this method is not getting called from anywhere hence calling explicitly for improving the coverage
        update PAN;
        LogicalBlock1.Pan_Theater_Level_Grouping__c = PAN1.id;
        LogicalBlock1.Consolidate_Specialty__c = 'Deployed';
        LogicalBlock1.Advanced_Consolidate_Specialty__c = 'Deployed';
        update LogicalBlock1;
        LogicalBlock2.Pan_Theater_Level_Grouping__c = null;
        LogicalBlock2.Deployed_To__c = 'Signature';
        LogicalBlock2.Consolidate_Specialty__c = 'Deployed';
       // update LogicalBlock2;
        accountGrouping1.Logical_Block_Level_Grouping__c = LogicalBlock2.id;
        accountGrouping1.Consolidate_Specialty__c = 'Deployed';
        accountGrouping1.Advanced_Consolidate_Specialty__c = 'Deployed';
        update accountGrouping1;
        Test.stopTest();
    }  
  
    public static testMethod void testdeletetriggeronGrouping() {
    	
    	Account_Groupings__c PAN = createPAN();
    	Account profiledAccount = createProfiledAccount();
        Account_Groupings__c LogicalBlock1 = createLogicalBlock(PAN);
        Account_Groupings__c LogicalBlock2 = createLogicalBlock(PAN);
        Account_Groupings__c accountGrouping1 = createAccountGrouping(profiledAccount,LogicalBlock1);
        Account_Groupings__c accountGrouping2 = createAccountGrouping(profiledAccount,LogicalBlock2);
        LogicalBlock1.Advanced_Consolidate_Specialty__c = 'Deployed';
        LogicalBlock1.Consolidate_Specialty__c='Deployed';
        LogicalBlock1.Backup_and_Recovery_Specialty__c='Deployed';
        LogicalBlock1.Governance_and_Archive_Specialty__c='Deployed';
        LogicalBlock2.Cloud_Builder_Specialty__c='Deployed';
        LogicalBlock2.Cloud_Provider_Practice__c ='Deployed';
        LogicalBlock2.Isilon_Track_Specialty__c ='Deployed';
        Test.startTest();
        update LogicalBlock1;
        update LogicalBlock2;
        delete accountGrouping2;
        delete LogicalBlock2;
        Test.stopTest();
    }
    }