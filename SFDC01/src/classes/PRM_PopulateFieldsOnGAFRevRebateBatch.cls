/*=====================================================================================================+

|  HISTORY  |                       

|  DATE          DEVELOPER               WR         DESCRIPTION                          

 
  ====          =========               ==         =========== 
  12 Sep 2012   Arif
  12 Oct 2012   Arif                             Added custom setting
  21 Mar 2013   karunaker M			  235602     Added Isilon Incentive and Targe Products fields in the query.   	
 +=====================================================================================================*/
global class PRM_PopulateFieldsOnGAFRevRebateBatch implements Database.batchable<sObject>,Schedulable{
  
  public string batchQuery = '';
  public PRM_PopulateFieldsOnGAFRevRebateBatch(){    
      batchQuery = 'SELECT Id,GAF_Revenue_Rebate_Type__c,Profiled_Account__c,Logical_Block__c,Pan_Theater__c,Country__c,GAF_Year__c,Partner_Type__c,Theater__c,Advcd_Cnsld_Actual_Q1__c,Advcd_Cnsld_Actual_Q2__c,Advcd_Cnsld_Actual_Q3__c,Advcd_Cnsld_Actual_Q4__c,Advcd_Cnsld_Actual_Tot__c,Advcd_Cnsld_Rebt_Q1__c,Advcd_Cnsld_Rebt_Q2__c,Advcd_Cnsld_Rebt_Q3__c,Advcd_Cnsld_Rebt_Q4__c,'+
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
                    'Isilon_Incentive_Actual_Q1__c,Isilon_Incentive_Actual_Q2__c,Isilon_Incentive_Actual_Q3__c,Isilon_Incentive_Actual_Q4__c,Isilon_Incentive_Actual_Total__c,'+
                    'Isilon_Incentive_Rebate_Q1__c,Isilon_Incentive_Rebate_Q2__c,Isilon_Incentive_Rebate_Q3__c,Isilon_Incentive_Rebate_Q4__c,Isilon_Incentive_Rebate_Total__c,'+
                    'Target_Products_Actual_Q1__c,Target_Products_Actual_Q2__c,Target_Products_Actual_Q3__c,Target_Products_Actual_Q4__c,Target_Products_Actual_Total__c,'+
                    'Target_Products_Rebate_Q1__c,Target_Products_Rebate_Q2__c,Target_Products_Rebate_Q3__c,Target_Products_Rebate_Q4__c,Target_Products_Rebate_Total__c'+
                    ' from GAF_Revenue_Rebate__c where (GAF_Revenue_Rebate_Type__c=\'Logical Block\' OR GAF_Revenue_Rebate_Type__c=\'Pan-Theater\' OR GAF_Revenue_Rebate_Type__c=\'Custom\') ORDER BY GAF_Revenue_Rebate_Type__c' ;
  }
  
  public PRM_PopulateFieldsOnGAFRevRebateBatch(string Query){
      this.batchQuery = Query;
  }    
   
  
/*@Method <This method gets executed acutomatically when the batch job is started.>
    @param <Database.BatchableContext BC - Batchable context>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
*/
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(batchQuery);
    }
     
/*@Method <This method gets executed acutomatically when the batch job is execution mode.>
    @param <Database.BatchableContext BC - Batchable context>
    @param <List<Sobject> scope - scope>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
*/
    global void execute(Database.BatchableContext BC, list<SObject> scope){
      list<GAF_Revenue_Rebate__c> lstGAFRevenueAndRebate = (list<GAF_Revenue_Rebate__c>)scope; 
      if(lstGAFRevenueAndRebate.size()>0){
          PRM_RevenueGAFVROperations obj = new PRM_RevenueGAFVROperations();
          obj.populateGAFForPANLBCustom(lstGAFRevenueAndRebate);
      }
    }
    
    global void execute(SchedulableContext sc) {
        PRM_PopulateFieldsOnGAFRevRebateBatch PopulateFieldsOnGAFRevRebateBatch = new PRM_PopulateFieldsOnGAFRevRebateBatch();
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll(); 
        Integer GafRevbatchSize = 10;
        try{            
            GafRevbatchSize = Integer.valueOf(DataValueMap.get('PRM_PopulateFieldsOnGAFRevRebateBatch').DataValue__c);
        }catch(Exception e){
            GafRevbatchSize = 10;
        }    
        database.executebatch(PopulateFieldsOnGAFRevRebateBatch,GafRevbatchSize);
    }
    
    global void finish(Database.BatchableContext BC){
    } 
}