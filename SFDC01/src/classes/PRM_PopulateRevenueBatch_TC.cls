/*===================================================================================================================================

History 

26th Mar  12  Kaustav Debnath     Added the code for GAF Revenue Batch functionality testing

====================================================================================================================================*/

@isTest
public class PRM_PopulateRevenueBatch_TC{

     Static List<Account> acctLst = new List<Account>();
     //Static List<Account> acctLst1 = new List<Account>();
     
     Map<String,CustomSettingDataValueMap__c> DataValueMap1 = CustomSettingDataValueMap__c.getAll();
            
     //Method for Creation Of Account    
    public Account_Groupings__c fetchGrouping(Id idGrouping)
    {
        Account_Groupings__c gr=[select id,id__c from Account_Groupings__c where id=:idGrouping];
        return gr;
    }
    public List<Account> createAccount(){
       
       for(Integer acc=0 ; acc<3 ; acc++){
        System.debug('Inside Account Creation');     
        Account acctObj = new Account();
        acctObj.Name = 'testingtesting Partner Account_'+acc;
        acctObj.Partner_Type__c='Direct Reseller';
        acctObj.rating_eligible__c = true;
        acctObj.BillingCountry='Colombia';
        //acctObj.theater1__c='Americas';
        acctObj.Lead_Oppty_Enabled__c=true;
        acctObj.type='Partner';
        acctObj.Site_DUNS_Entity__c='test999999999';
        //acctObj.Ispartner=true;
        acctLst.add(acctObj);

       }
        insert acctLst;
        Set<Id> setAccountIds=new Set<Id>();
        for(Integer acc=0 ; acc<3 ; acc++){
            setAccountIds.add(acctLst[acc].id);
        }
        
        
        /*acctLst[0].Lead_Oppty_Enabled__c=true;
        acctLst[0].type='Partner';*/
        acctLst[0].PROFILED_ACCOUNT_FLAG__c=true;
        acctLst[1].PROFILED_ACCOUNT_FLAG__c=false;
        Account_Groupings__c gr=new Account_Groupings__c();
        gr.Profiled_Account__c=acctLst[0].id;
        gr.name='testing Grouping';
        gr.Account__c='test';
        insert gr;
        acctLst[0].grouping__c=gr.id;
        acctLst[2].grouping__c=gr.id;
        acctLst[0].Ispartner=true;
        acctLst[1].Ispartner=true;
        Database.update(acctLst);
        
        List<Account>  acctLst1=[select id,name,theater1__c,BillingCountry,grouping__c from account where id in :setAccountIds];
        System.debug('##### acctLst[0].theater1__c'+acctLst[0].theater1__c);
        System.debug('##### acctLst1'+acctLst1);
        
        
        System.debug('Account Created');
       return acctLst1;
    }

      
  
    public void createEMCBusinessRulesForRevenues(Id recordtypeId){
        List<EMC_Business_Rules__c> lstEMCBusinessRules=new List<EMC_Business_Rules__c>();
        List<EMC_Business_Rules__c> lstEMCBusinessRulesWithEducation=new List<EMC_Business_Rules__c>();
        EMC_BR_Education_Group_Record__c eduGroupRec=new EMC_BR_Education_Group_Record__c();
        /*for(Integer iCounter=0;iCounter<4;iCounter++)
        {*/
            EMC_Business_Rules__c emcBRObj=new EMC_Business_Rules__c();
            
                emcBRObj.EVALUATION_TIME_PERIOD__C='1;2;3;4';
                emcBRObj.Theater__c ='Americas';
                emcBRObj.RECORDTYPEID=recordtypeId;
                emcBRObj.FIELDS_TO_SUM__C='Q1 Total Revenue - Current;Q4 Total Revenue - Previous';
                emcBRObj.OBJECT_NAME__C='GAF__c';
                emcBRObj.PRODUCT_TYPE__C='Product_Type';
               emcBRObj.FIELD_NAME__C='Adv_Cnsld_Al_Ptr_Rev_Actl_Q1__c';
                emcBRObj.SPECILITY__C='Speciality';
                //lstEMCBusinessRules.add(emcBRObj);
        //}

          
        insert emcBRObj;
                
        //return lstEMCBusinessRulesWithEducation;
        
    }
    
    public void createEMCBusinessRulesForVelocityRevenues(Id recordtypeId){
        List<EMC_Business_Rules__c> lstEMCBusinessRules=new List<EMC_Business_Rules__c>();
        
        EMC_BR_Education_Group_Record__c eduGroupRec=new EMC_BR_Education_Group_Record__c();
        for(Integer iCounter=0;iCounter<4;iCounter++)
        {
            EMC_Business_Rules__c emcBRObj=new EMC_Business_Rules__c();
            
                emcBRObj.EVALUATION_TIME_PERIOD__C=String.valueOf(iCounter+1);
                emcBRObj.RECORDTYPEID=recordtypeId;
                emcBRObj.FIELDS_TO_SUM__C='Q1 Total Revenue - Current;Q4 Total Revenue - Previous';
                emcBRObj.OBJECT_NAME__C='Velocity_Revenue__c';
                emcBRObj.Theater__c ='Americas';
                emcBRObj.PRODUCT_TYPE__C='Product_Type';
                emcBRObj.FIELD_NAME__C='AC_Curr_Per_Rev_HW_SW__c';
                emcBRObj.SPECILITY__C='Speciality';
                lstEMCBusinessRules.add(emcBRObj);
        }

          
        insert lstEMCBusinessRules;
                
                
    }
    
    public void createVelocityRevenues(Id AccountId){
        List<Velocity_Revenue__c> lstVelocityRevenues=new List<Velocity_Revenue__c>();
        Velocity_Revenue__c velocityRevenueObj=new Velocity_Revenue__c();
        
        velocityRevenueObj.Partner_Profiled_Account__c=AccountId;
        velocityRevenueObj.AC_Curr_Per_Rev_HW_SW__c=3454.45;
        
        insert velocityRevenueObj;
        
                
        //return lstEMCBusinessRulesWithEducation;
        
    }
    
    public List<Id> createGAF(Id accountToCreateGAFId){
        List<GAF__c> lstGAFToInsert=new List<GAF__c>();
        List<Id> lstIdGAFCreated=new List<Id>();
        date dateToday = date.today();
        GAF__c gafObj=new GAF__C();
        gafObj.Partner_Name__c=accountToCreateGAFId;
        gafObj.Year__c=String.valueOf(dateToday.year());
        gafObj.GAF_Status__c='Draft';
        lstGAFToInsert.add(gafObj);
        GAF__c gafObj1=new GAF__C();
        gafObj1.Partner_Name__c=accountToCreateGAFId;
        gafObj1.Year__c=String.valueOf(dateToday.year()-1);
        gafObj1.GAF_Status__c='Draft';
        lstGAFToInsert.add(gafObj1);
        insert lstGAFToInsert;
        if(lstGAFToInsert.size()>0)
        {
            for(GAF__c gafObj2:lstGAFToInsert)
            {
                lstIdGAFCreated.add(gafObj2.id);
            }
        }
        return lstIdGAFCreated;
    }
    public static testMethod void test() {
        
        
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        PRM_PopulateRevenueBatch_TC testObj = new PRM_PopulateRevenueBatch_TC();
        user SysAdmin=[Select Id,Name,Profile.Name,isActive from user where Profile.Name like 'System Administrator' and isActive=true limit 1];        
        Recordtype recordTypeEMCBusinessRule=[select id,name from recordtype where sobjecttype='EMC_Business_Rules__c' and name='Revenue Summary Rule']; 
        List<CustomSettingDataValueMap__c> customSettingsData = new List<CustomSettingDataValueMap__c>();
        //testObj.createQuarterCustomSettings(testObj.DataValueMap1);
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        System.RunAs(SysAdmin)
        {
            CustomSettingDataValueMap__c batchId = testObj.DataValueMap1.get('Batch Id');
            CustomSettingDataValueMap__c Revenue_Summary_Rule = testObj.DataValueMap1.get('Revenue Summary Rule');
            CustomSettingDataValueMap__c Current = testObj.DataValueMap1.get('Current');
            CustomSettingDataValueMap__c Previous = testObj.DataValueMap1.get('Previous');
            if(batchId == null){
              batchId = new CustomSettingDataValueMap__c(Name = 'Batch Id');
              batchId.DateValue__c = 0000 ;
              customSettingsData.add(batchId);
            }
            else
            {
                batchId.DateValue__c = 0000 ;
                update batchId;
            }
            
            if(Revenue_Summary_Rule == null)
            {
                if(recordTypeEMCBusinessRule!=null)
                {
                    Revenue_Summary_Rule = new CustomSettingDataValueMap__c(Name = 'Revenue Summary Rule');
                    Revenue_Summary_Rule.DataValue__c = recordTypeEMCBusinessRule.id ;
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
            
        }
        insert customSettingsData;
        
        List<Account> lstAccount=testObj.createAccount(); 
        
        //Account lstAccount=testObj.createAccount();
        Account_Groupings__c groupingObj=testObj.fetchGrouping(lstAccount[0].grouping__c);
        testObj.createVelocityRevenues(lstAccount[0].id);
        testObj.createEMCBusinessRulesForRevenues(recordTypeEMCBusinessRule.id);
        testObj.createEMCBusinessRulesForVelocityRevenues(recordTypeEMCBusinessRule.id);
        List<Id> lstGAFIdCreated=testObj.createGAF(lstAccount[0].id);
        //FiscalYearSettings FiscalYear = [Select f.EndDate, f.Id, f.Name, f.StartDate, f.YearType from FiscalYearSettings f where f.Name=:string.valueOf(System.Now().YearGmt())];
        
        
        List<Staging_data__c> lstStagingData=new List<Staging_data__c>();
        date dateToday = date.today();
        for(Integer iCount=0;iCount<8;iCount++)
        {
            Staging_data__c stagingObj=new Staging_data__c();
            stagingObj.Batch_Id__c=0000;
            stagingObj.Object_Name__c='Revenue';
            stagingObj.Text1__c=groupingObj.ID__c;
            stagingObj.Text6__c='456.00';
            stagingObj.Text7__c='542.22';
            stagingObj.Text8__c='556.22';
            stagingObj.Text9__c='789.25';
            if(math.mod(iCount,8)==0)
            {
                stagingObj.Text2__c='Speciality';
                stagingObj.Text3__c='Product_Type';
                stagingObj.Text4__c=String.valueOf(dateToday.year());
            }
            else if(math.mod(iCount,8)==1)
            {
                stagingObj.Text2__c='negative test';
                stagingObj.Text3__c='Product_Type';
                stagingObj.Text4__c=String.valueOf(dateToday.year()-1);
            }
            else if(math.mod(iCount,8)==2)
            {
                stagingObj.Text2__c='Speciality';
                stagingObj.Text3__c='negative test';
                stagingObj.Text4__c=String.valueOf(dateToday.year());
            }
            else if(math.mod(iCount,8)==3)
            {
                stagingObj.Text2__c='negative test';
                stagingObj.Text3__c='negative test';
                stagingObj.Text4__c='negative test';
                stagingObj.Text6__c='negative test';
                stagingObj.Text7__c='negative test';
                stagingObj.Text8__c='negative test';
                stagingObj.Text9__c='negative test';
            }
            else if(math.mod(iCount,8)==4)
            {
                stagingObj.Text2__c='Speciality';
                stagingObj.Text3__c='Product_Type';
                stagingObj.Text4__c=String.valueOf(dateToday.year()-1);
            }
            else if(math.mod(iCount,8)==7)
            {
                stagingObj.Text2__c='Speciality';
                stagingObj.Text3__c='Product_Type';
                stagingObj.Text4__c=String.valueOf(dateToday.year()-1);
                stagingObj.Text6__c='213.00';
            }
            else
            {
                stagingObj.Text2__c='negative test';
                stagingObj.Text3__c='negative test';
                stagingObj.Text4__c='negative test';
                stagingObj.Text6__c='negative test';
                stagingObj.Text7__c='negative test';
                stagingObj.Text8__c='negative test';
                stagingObj.Text9__c='negative test';
            }
            stagingObj.Text5__c='Americas';
            
            stagingObj.Text10__c=String.valueOf(math.mod(iCount,4)+1);
            lstStagingData.add(stagingObj);
        }
        
        insert lstStagingData;
        String query='test';
        PRM_PopulateRevenueBatch ExecuteRevenueBatch = new PRM_PopulateRevenueBatch ();
        PRM_PopulateRevenueBatch ExecuteRevenueBatch1= new PRM_PopulateRevenueBatch(query);
        ExecuteRevenueBatch.batchQuery ='select Batch_Id__c,Text1__c,Text2__c,Text3__c,Text4__c,Text5__c,Text6__c,Text7__c,Text8__c,Text9__c,Text10__c,Object_Name__c'+ 
                   ' from Staging_Data__c where Object_Name__c = \'Revenue\' and Batch_Id__c =0000';
        PRM_CalculateGAFandVelocityFieldsBatch GAFAndVRBatchObj=new PRM_CalculateGAFandVelocityFieldsBatch();
        GAFAndVRBatchObj.batchQuery = 'select Id,PROFILED_ACCOUNT_FLAG__c from account where PROFILED_ACCOUNT_FLAG__c = true and name=\'testingtesting Partner Account_0\'';
        PRM_CalculateGAFandVelocityFieldsBatch GAFAndVRBatchObj1=new PRM_CalculateGAFandVelocityFieldsBatch('test query');
        Test.startTest();
        
             ID batchprocessid = Database.executeBatch(ExecuteRevenueBatch);
             ID batchprocessid1 = Database.executeBatch(GAFAndVRBatchObj);
         
         PRM_RevenueGAFVROperations obj = new PRM_RevenueGAFVROperations();
          obj.insertUpdateRevenue(lstStagingData);
          obj.calculateRevenueForAccount(lstAccount);
         
         List<GAF__c> lstGAFForTest=new List<GAF__c>();
         
        if(lstGAFIdCreated.size()>0)
        {
            lstGAFForTest=[Select Id,Adv_Cnsld_Al_Ptr_Rev_Actl_Q1__c,Year__c  from GAF__c
                    where id in :lstGAFIdCreated ];
        }
        System.debug('### lstGAFForTest=>'+lstGAFForTest);
        if(lstGAFForTest.size()>0)
        {
            for(GAF__c gafTestObj:lstGAFForTest)
            {
                if(gafTestObj.Year__c==String.valueOf(dateToday.year()-1))
                {
                    //System.assertEquals(gafTestObj.Adv_Cnsld_Al_Ptr_Rev_Actl_Q1__c,669.00,'The actual field calculated is not correct');
                }
                else if(gafTestObj.Year__c==String.valueOf(dateToday.year()))
                {
                    //System.assertEquals(gafTestObj.Adv_Cnsld_Al_Ptr_Rev_Actl_Q1__c,456.00,'The actual field calculated is not correct');
                }
            }
        }
        Test.stopTest();
    }
    
    public static testMethod void test_Schedular() {
        
        
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        PRM_PopulateRevenueBatch_TC testObj = new PRM_PopulateRevenueBatch_TC();
        user SysAdmin=[Select Id,Name,Profile.Name,isActive from user where Profile.Name like 'System Administrator' and isActive=true limit 1];        
        Recordtype recordTypeEMCBusinessRule=[select id,name from recordtype where sobjecttype='EMC_Business_Rules__c' and name='Revenue Summary Rule']; 
        List<CustomSettingDataValueMap__c> customSettingsData = new List<CustomSettingDataValueMap__c>();
        //testObj.createQuarterCustomSettings(testObj.DataValueMap1);
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        System.RunAs(SysAdmin)
        {
            CustomSettingDataValueMap__c batchId = testObj.DataValueMap1.get('Batch Id');
            CustomSettingDataValueMap__c Revenue_Summary_Rule = testObj.DataValueMap1.get('Revenue Summary Rule');
            CustomSettingDataValueMap__c Current = testObj.DataValueMap1.get('Current');
            CustomSettingDataValueMap__c Previous = testObj.DataValueMap1.get('Previous');
            if(batchId == null){
              batchId = new CustomSettingDataValueMap__c(Name = 'Batch Id');
              batchId.DateValue__c = 0000 ;
              customSettingsData.add(batchId);
            }
            else
            {
                batchId.DateValue__c = 0000 ;
                update batchId;
            }
            
            if(Revenue_Summary_Rule == null)
            {
                if(recordTypeEMCBusinessRule!=null)
                {
                    Revenue_Summary_Rule = new CustomSettingDataValueMap__c(Name = 'Revenue Summary Rule');
                    Revenue_Summary_Rule.DataValue__c = recordTypeEMCBusinessRule.id ;
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
            
        }
        insert customSettingsData;
        
        List<Account> lstAccount=testObj.createAccount(); 
        
        //Account lstAccount=testObj.createAccount();
        Account_Groupings__c groupingObj=testObj.fetchGrouping(lstAccount[0].grouping__c);
        testObj.createVelocityRevenues(lstAccount[0].id);
        testObj.createEMCBusinessRulesForRevenues(recordTypeEMCBusinessRule.id);
        testObj.createEMCBusinessRulesForVelocityRevenues(recordTypeEMCBusinessRule.id);
        List<Id> lstGAFIdCreated=testObj.createGAF(lstAccount[0].id);
        //FiscalYearSettings FiscalYear = [Select f.EndDate, f.Id, f.Name, f.StartDate, f.YearType from FiscalYearSettings f where f.Name=:string.valueOf(System.Now().YearGmt())];
        
        
        List<Staging_data__c> lstStagingData=new List<Staging_data__c>();
        date dateToday = date.today();
        for(Integer iCount=0;iCount<8;iCount++)
        {
            Staging_data__c stagingObj=new Staging_data__c();
            stagingObj.Batch_Id__c=0000;
            stagingObj.Object_Name__c='Revenue';
            stagingObj.Text1__c=groupingObj.ID__c;
            stagingObj.Text6__c='456.00';
            stagingObj.Text7__c='542.22';
            stagingObj.Text8__c='556.22';
            stagingObj.Text9__c='789.25';
            if(math.mod(iCount,8)==0)
            {
                stagingObj.Text2__c='Speciality';
                stagingObj.Text3__c='Product_Type';
                stagingObj.Text4__c=String.valueOf(dateToday.year());
            }
            else if(math.mod(iCount,8)==1)
            {
                stagingObj.Text2__c='negative test';
                stagingObj.Text3__c='Product_Type';
                stagingObj.Text4__c=String.valueOf(dateToday.year()-1);
            }
            else if(math.mod(iCount,8)==2)
            {
                stagingObj.Text2__c='Speciality';
                stagingObj.Text3__c='negative test';
                stagingObj.Text4__c=String.valueOf(dateToday.year());
            }
            else if(math.mod(iCount,8)==3)
            {
                stagingObj.Text2__c='negative test';
                stagingObj.Text3__c='negative test';
                stagingObj.Text4__c='negative test';
                stagingObj.Text6__c='negative test';
                stagingObj.Text7__c='negative test';
                stagingObj.Text8__c='negative test';
                stagingObj.Text9__c='negative test';
            }
            else if(math.mod(iCount,8)==4)
            {
                stagingObj.Text2__c='Speciality';
                stagingObj.Text3__c='Product_Type';
                stagingObj.Text4__c=String.valueOf(dateToday.year()-1);
            }
            else if(math.mod(iCount,8)==7)
            {
                stagingObj.Text2__c='Speciality';
                stagingObj.Text3__c='Product_Type';
                stagingObj.Text4__c=String.valueOf(dateToday.year()-1);
                stagingObj.Text6__c='213.00';
            }
            else
            {
                stagingObj.Text2__c='negative test';
                stagingObj.Text3__c='negative test';
                stagingObj.Text4__c='negative test';
                stagingObj.Text6__c='negative test';
                stagingObj.Text7__c='negative test';
                stagingObj.Text8__c='negative test';
                stagingObj.Text9__c='negative test';
            }
            stagingObj.Text5__c='Americas';
            
            stagingObj.Text10__c=String.valueOf(math.mod(iCount,4)+1);
            lstStagingData.add(stagingObj);
        }
        
        insert lstStagingData;
        
        PRM_PopulateRevenueBatch ExecuteRevenueBatch = new PRM_PopulateRevenueBatch ();
        ExecuteRevenueBatch.batchQuery ='select Batch_Id__c,Text1__c,Text2__c,Text3__c,Text4__c,Text5__c,Text6__c,Text7__c,Text8__c,Text9__c,Text10__c,Object_Name__c'+ 
                   ' from Staging_Data__c where Object_Name__c = \'Revenue\' and Batch_Id__c =0000';
        PRM_CalculateGAFandVelocityFieldsBatch GAFAndVRBatchObj=new PRM_CalculateGAFandVelocityFieldsBatch();
        GAFAndVRBatchObj.batchQuery = 'select Id,PROFILED_ACCOUNT_FLAG__c from account where PROFILED_ACCOUNT_FLAG__c = true and name=\'testingtesting Partner Account_0\'';
        Test.startTest();
        
            String strScheduleTime ='0 0 0 3 9 ? ';
            strScheduleTime = strScheduleTime + Datetime.now().addYears(1).year();
            String jobId = System.schedule('testBasicScheduledApex',strScheduleTime, new PRM_CalculateRevenueGAF_Scheduler());
         
         PRM_RevenueGAFVROperations obj = new PRM_RevenueGAFVROperations();
          obj.insertUpdateRevenue(lstStagingData);
          obj.calculateRevenueForAccount(lstAccount);
         
         List<GAF__c> lstGAFForTest=new List<GAF__c>();
         
        if(lstGAFIdCreated.size()>0)
        {
            lstGAFForTest=[Select Id,Adv_Cnsld_Al_Ptr_Rev_Actl_Q1__c,Year__c  from GAF__c
                    where id in :lstGAFIdCreated ];
        }
        System.debug('### lstGAFForTest=>'+lstGAFForTest);
        if(lstGAFForTest.size()>0)
        {
            for(GAF__c gafTestObj:lstGAFForTest)
            {
                if(gafTestObj.Year__c==String.valueOf(dateToday.year()-1))
                {
                    //System.assertEquals(gafTestObj.Adv_Cnsld_Al_Ptr_Rev_Actl_Q1__c,669.00,'The actual field calculated is not correct');
                }
                else if(gafTestObj.Year__c==String.valueOf(dateToday.year()))
                {
                    //System.assertEquals(gafTestObj.Adv_Cnsld_Al_Ptr_Rev_Actl_Q1__c,456.00,'The actual field calculated is not correct');
                }
            }
        }
        Test.stopTest();
    }
}