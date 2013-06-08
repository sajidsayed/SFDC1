/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 

 |  27 Feb 2012   Arif                              This class use to calculate the values of fields on GAF and VR.  
    02 May 2012   Arif                              Change the code according to change in calculation of Velocity Revenue
 |  25 May 2012   Arif                              Changes done for new process 
    02 Aug 2012   Ganesh                 196693     Reverted Multiple Theaters functionality of EMCBusinessRule
    13 Sep 2012   Arif                   PAN GAF    Replaced the GAF object with GAF Revenue & Rebate object and fields accordingly. 
 |  14 Sep 2012   Arif                   PAN GAF    Added two method to add PAN level GAF functionality 
    25 Sep 2012  Arif                               Commented code for PAN GAF  
 |  25 Sep 2012  Arif                               UnCommented code for PAN GAF 
    21 Mar 2013  Karunaker M			235602      Added Isilon Incentive and Target Product fields in the queries.
 +===========================================================================*/
public class PRM_RevenueGAFVROperations{
/*@Method <This method gets executed acutomatically when the batch job is started.>
    @param <Database.BatchableContext BC - Batchable context>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
*/
  public void calculateRevenueForAccount(List<Account> lstAccount){
      list<EMC_Business_Rules__c> lstEMCBusinessRule = new list<EMC_Business_Rules__c>();
      map<string,EMC_Business_Rules__c> mapBusinessRule = new map<string,EMC_Business_Rules__c>(); 
      map<string,map<string,EMC_Business_Rules__c>> mapBusinessRuleForVR = new map<string,map<string,EMC_Business_Rules__c>>();
      map<Id,map<string,map<string,map<Decimal,Revenue__c>>>> mapAccountIdRevenue = new map<Id,map<string,map<string,map<Decimal,Revenue__c>>>>();
      map<Id,set<string>> mapAccountIdYear = new  map<Id,set<string>>();
      list<Revenue__c> lstRevenueForBatchId = new list<Revenue__c>();
      set<string> setYear = new set<string>();
      list<Revenue__c> lstRevenue = new list<Revenue__c>();
      map<String,CustomSettingDataValueMap__c> mapCustomSetting = CustomSettingDataValueMap__c.getall();
      Id RecordType;
      if(mapCustomSetting.containsKey('Revenue Summary Rule')){
          if(mapCustomSetting.get('Revenue Summary Rule').DataValue__c != ''){
              RecordType = mapCustomSetting.get('Revenue Summary Rule').DataValue__c;
          }
      } 
      if(RecordType != null){
        lstEMCBusinessRule = [Select Name,Evaluation_Time_Period__c,RecordType.Id,Fields_to_Sum__c,Object_Name__c,Product_Type__c,Field_Name__c,Specility__c,Theater__c from EMC_Business_Rules__c
                            where RecordType.Id =:RecordType order by Theater__c];
      system.debug('lstEMCBusinessRule ---->' +lstEMCBusinessRule );
      }
      
      /*
      if(lstEMCBusinessRule.size()>0){ 
         for(EMC_Business_Rules__c objEMC: lstEMCBusinessRule){
         if(objEMC.Object_Name__c == 'GAF__c'){
                 mapBusinessRule.put(objEMC.Field_Name__c,objEMC);
         }else{
               if(mapBusinessRuleForVR.containsKey(objEMC.Field_Name__c)){
                  mapBusinessRuleForVR.get(objEMC.Field_Name__c).put(objEMC.Evaluation_Time_Period__c,objEMC);            
               }else{   
                 mapBusinessRuleForVR.put(objEMC.Field_Name__c,new map<string,EMC_Business_Rules__c>());
                 mapBusinessRuleForVR.get(objEMC.Field_Name__c).put(objEMC.Evaluation_Time_Period__c,objEMC);
               }
         }
         }
      }
      */
      
      //Added By Ganesh
       if(lstEMCBusinessRule.size()>0){ 
         for(EMC_Business_Rules__c objEMC: lstEMCBusinessRule){
                 if(objEMC.Object_Name__c == 'GAF_Revenue_Rebate__c'){
                        mapBusinessRule.put(objEMC.Field_Name__c+':'+objEMC.Theater__c,objEMC);
                   
                 }else{
                       if(mapBusinessRuleForVR.containsKey(objEMC.Field_Name__c+':'+objEMC.Theater__c)){
                          mapBusinessRuleForVR.get(objEMC.Field_Name__c+':'+objEMC.Theater__c).put(objEMC.Evaluation_Time_Period__c,objEMC);            
                       }else{   
                         mapBusinessRuleForVR.put(objEMC.Field_Name__c+':'+objEMC.Theater__c,new map<string,EMC_Business_Rules__c>());
                         mapBusinessRuleForVR.get(objEMC.Field_Name__c+':'+objEMC.Theater__c).put(objEMC.Evaluation_Time_Period__c,objEMC);
                       }
                }
             }
       }
      
      system.debug('mapBusinessRule---->' +mapBusinessRule);
      system.debug('mapBusinessRuleForVR---->' +mapBusinessRuleForVR);
      
      if(lstAccount.size()>0){
          if(mapCustomSetting.containsKey('Batch Id')){
              if(mapCustomSetting.get('Batch Id').DateValue__c != null){
                  lstRevenueForBatchId = [Select Account__c,Batch_Id__c,LastModifiedDate,Year__c from Revenue__c where Account__c in: lstAccount and Batch_Id__c =: mapCustomSetting.get('Batch Id').DateValue__c order by LastModifiedDate desc];  
              }
          }           
          if(mapCustomSetting.containsKey('Minutes') && lstRevenueForBatchId.size()>0){
              if(mapCustomSetting.get('Minutes').DateValue__c != null){
                  lstRevenue = [Select Grouping__c,Account__c,Q1_Growth_Revenue__c,Q1_Growth_Units__c,Q1_Total_Revenue__c,Q1_Total_Units__c,Q2_Growth_Revenue__c,Q2_Growth_Units__c,Q2_Total_Revenue__c,Q2_Total_Units__c, 
                                Q3_Growth_Revenue__c,Q3_Growth_Units__c,Q3_Total_Revenue__c,Q3_Total_Units__c,Q4_Growth_Revenue__c,Q4_Growth_Units__c,Q4_Total_Revenue__c,Q4_Total_Units__c,Speciality__c,Theater__c,
                                Unique_Combination__c,Year__c,Product_Type__c,Batch_Id__c,LastModifiedDate from Revenue__c where Account__c in: lstAccount and
                                (LastModifiedDate >= :lstRevenueForBatchId[0].LastModifiedDate.addMinutes(-integer.valueOf(string.valueOf(mapCustomSetting.get('Minutes').DateValue__c))) or Year__c = :System.Now().yearGmt() or Year__c = :System.Now().yearGmt()-1) ];
              }
          }
      }
      if(lstRevenueForBatchId.size()>0){
          for(Revenue__c objRev: lstRevenueForBatchId){
              if(objRev.Account__c != null &&  objRev.Year__c != null){       
                  if(mapAccountIdYear.containsKey(objRev.Account__c)){
                         if(mapAccountIdYear.get(objRev.Account__c).contains(string.valueof(objRev.Year__c))){
                         }else{
                               mapAccountIdYear.get(objRev.Account__c).add(string.valueof(objRev.Year__c));
                         }
                  }else{
                        mapAccountIdYear.put(objRev.Account__c,new set<string>());
                        mapAccountIdYear.get(objRev.Account__c).add(string.valueof(objRev.Year__c));
                 }
                 if(!setYear.contains(string.valueof(objRev.Year__c))){
                        setYear.add(string.valueof(objRev.Year__c));
                 }
              }
          }
      }        
      if(lstRevenue.size()>0){
         for(Revenue__c objRev: lstRevenue){             
             if(objRev.Account__c != null && objRev.Speciality__c != '' && objRev.Product_Type__c != '' && objRev.Year__c != null){ 
                 if(mapAccountIdRevenue.containsKey(objRev.Account__c)){
                      if(mapAccountIdRevenue.get(objRev.Account__c).containsKey(objRev.Speciality__c.toLowerCase().replaceAll(' ',''))){
                           if(mapAccountIdRevenue.get(objRev.Account__c).get(objRev.Speciality__c.toLowerCase().replaceAll(' ','')).containsKey(objRev.Product_Type__c.toLowerCase().replaceAll(' ',''))){
                             mapAccountIdRevenue.get(objRev.Account__c).get(objRev.Speciality__c.toLowerCase().replaceAll(' ','')).get(objRev.Product_Type__c.toLowerCase().replaceAll(' ','')).put(objRev.Year__c,objRev);
                           }else{
                             mapAccountIdRevenue.get(objRev.Account__c).get(objRev.Speciality__c.toLowerCase().replaceAll(' ','')).put(objRev.Product_Type__c.toLowerCase().replaceAll(' ',''),new map<Decimal,Revenue__c>());
                             mapAccountIdRevenue.get(objRev.Account__c).get(objRev.Speciality__c.toLowerCase().replaceAll(' ','')).get(objRev.Product_Type__c.toLowerCase().replaceAll(' ','')).put(objRev.Year__c,objRev);
                           }
                     }else{
                       mapAccountIdRevenue.get(objRev.Account__c).put(objRev.Speciality__c.toLowerCase().replaceAll(' ',''),new map<string,map<Decimal,Revenue__c>>()); 
                       mapAccountIdRevenue.get(objRev.Account__c).get(objRev.Speciality__c.toLowerCase().replaceAll(' ','')).put(objRev.Product_Type__c.toLowerCase().replaceAll(' ',''),new map<Decimal,Revenue__c>()); 
                       mapAccountIdRevenue.get(objRev.Account__c).get(objRev.Speciality__c.toLowerCase().replaceAll(' ','')).get(objRev.Product_Type__c.toLowerCase().replaceAll(' ','')).put(objRev.Year__c,objRev);
                     }              
                    }else{
                     mapAccountIdRevenue.put(objRev.Account__c,new map<string,map<string,map<Decimal,Revenue__c>>>()); 
                     mapAccountIdRevenue.get(objRev.Account__c).put(objRev.Speciality__c.toLowerCase().replaceAll(' ',''),new map<string,map<Decimal,Revenue__c>>()); 
                     mapAccountIdRevenue.get(objRev.Account__c).get(objRev.Speciality__c.toLowerCase().replaceAll(' ','')).put(objRev.Product_Type__c.toLowerCase().replaceAll(' ',''),new map<Decimal,Revenue__c>()); 
                     mapAccountIdRevenue.get(objRev.Account__c).get(objRev.Speciality__c.toLowerCase().replaceAll(' ','')).get(objRev.Product_Type__c.toLowerCase().replaceAll(' ','')).put(objRev.Year__c,objRev);
                    }
                
                 }
             }
      }      
      system.debug('mapAccountIdRevenue---->' +mapAccountIdRevenue);
      // GAF Fields Calculation and updation
       if(!mapAccountIdRevenue.isEmpty() && !mapBusinessRule.isEmpty() && !mapAccountIdYear.isEmpty() && setYear.size()>0){
          system.debug('mapAccountIdRevenue-------->' +mapAccountIdRevenue);
          system.debug('mapBusinessRule-------->' +mapBusinessRule);
          system.debug('mapAccountIdYear-------->' +mapAccountIdYear);
          calculateAndUpdateGAF(mapAccountIdRevenue,mapBusinessRule,mapAccountIdYear,setYear);
       }

      // Velocity Revenue Fields Calculation and updation
       if(!mapAccountIdRevenue.isEmpty() && !mapBusinessRuleForVR.isEmpty()){
          calculateAndUpdateVR(mapAccountIdRevenue,mapBusinessRuleForVR);
       }
    }
    
    
/*@Method <This method gets executed acutomatically when the batch job is started.>
    @param <Database.BatchableContext BC - Batchable context>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
*/
  
     public void calculateAndUpdateGAF(map<Id,map<string,map<string,map<Decimal,Revenue__c>>>> mapAccountIdRevenue,map<string,EMC_Business_Rules__c> mapBusinessRule, map<Id,set<string>> mapAccountIdYear,set<string> setYear){
    // GAF Fields Calculation and updation
       list<GAF_Revenue_Rebate__c> lstGAF = new list<GAF_Revenue_Rebate__c>();
       list<GAF_Revenue_Rebate__c> lstGAFToUpdate = new list<GAF_Revenue_Rebate__c>();
       //map<Id,map<string,GAF__c>> mapAccountIdYearAndGAF = new map<Id,map<string,GAF__c>>();
       list<string> lstSpecility = new list<string>();
       list<string> lstProduct = new list<string>();
       list<string> lstFieldToSum = new list<string>();
       //Map<String, Schema.SObjectField> mapGAFFields = Schema.SObjectType.GAF_Revenue_Rebate__c.fields.getMap();
       map<String,CustomSettingDataValueMap__c> mapCustomSetting = CustomSettingDataValueMap__c.getall();
       if(!mapAccountIdRevenue.isEmpty()){
          lstGAF = [Select Id,Profiled_Account__c,GAF_Revenue_Rebate_Type__c,GAF_Year__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q4__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q3__c,
                    Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q2__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q1__c,Theater__c,
                    Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q4__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q3__c,
                    Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q2__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q1__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Q4__c,
                    Gvrn_Archv_Al_Ptr_Unt_Actl_Q3__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Q2__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Q1__c,
                    Gvrn_Archv_Al_Ptr_Rev_Actl_Q4__c,
                    Gvrn_Archv_Al_Ptr_Rev_Actl_Q3__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Q2__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Q1__c,
                    Gvr_Arv_Acl_Q4__c,Gvr_Arv_Acl_Q3__c,Gvr_Arv_Acl_Q2__c,Gvr_Arv_Actl_Q1__c,
                    Cnsld_Grwt_Ptr_Unt_Actl_Q4__c,Cnsld_Grwt_Ptr_Unt_Actl_Q3__c,
                    Cnsld_Grwt_Ptr_Unt_Actl_Q2__c,Cnsld_Grwt_Ptr_Unt_Actl_Q1__c,
                    Cnsld_Grwt_Ptr_Rev_Actl_Q4__c,Cnsld_Grwt_Ptr_Rev_Actl_Q3__c,Cnsld_Grwt_Ptr_Rev_Actl_Q2__c,
                    Cnsld_Grwt_Ptr_Rev_Actl_Q1__c,
                    Advcd_Cnsld_Actual_Q1__c,Advcd_Cnsld_Actual_Q2__c,Advcd_Cnsld_Actual_Q3__c,Advcd_Cnsld_Actual_Q4__c,
                    BRS_Cnsld_All_Ptr_Unit_Actl_Q1__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q2__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q3__c,
                    BRS_Cnsld_All_Ptr_Unit_Actl_Q4__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q1__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q2__c,
                    BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q3__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q4__c,
                    BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q1__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q2__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q3__c,
                    BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q4__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q1__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q2__c,
                    BRS_Cnsld_All_Ptr_Rev_Actl_Q3__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q4__c,
                    BRS_Actl_Q1__c,BRS_Actl_Q2__c,BRS_Actl_Q3__c,BRS_Actl_Q4__c,BRS_Al_Ptr_Rev_Actl_Q1__c,
                    BRS_Al_Ptr_Rev_Actl_Q2__c,BRS_Al_Ptr_Rev_Actl_Q3__c,BRS_Al_Ptr_Rev_Actl_Q4__c,
                    BRS_Al_Ptr_Unit_Actl_Q1__c,BRS_Al_Ptr_Unit_Actl_Q2__c,BRS_Al_Ptr_Unit_Actl_Q3__c,BRS_Al_Ptr_Unit_Actl_Q4__c,
                    BRS_Grwt_Ptr_Rev_Actl_Q1__c,BRS_Grwt_Ptr_Rev_Actl_Q2__c,BRS_Grwt_Ptr_Rev_Actl_Q3__c,
                    BRS_Grwt_Ptr_Rev_Actl_Q4__c,BRS_Grwt_Ptr_Unit_Actl_Q1__c,BRS_Grwt_Ptr_Unit_Actl_Q2__c,
                    BRS_Grwt_Ptr_Unit_Actl_Q3__c,BRS_Grwt_Ptr_Unit_Actl_Q4__c,Cnsld_Actl_Q1__c,
                    Cnsld_Actl_Q2__c,Cnsld_Actl_Q3__c,Cnsld_Actl_Q4__c,Cnsld_Al_Ptr_Rev_Actl_Q1__c,Cnsld_Al_Ptr_Rev_Actl_Q2__c,
                    Cnsld_Al_Ptr_Rev_Actl_Q3__c,Cnsld_Al_Ptr_Rev_Actl_Q4__c,Cnsld_Al_Ptr_Unit_Actl_Q1__c,Cnsld_Al_Ptr_Unit_Actl_Q2__c,
                    Cnsld_Al_Ptr_Unit_Actl_Q3__c,Cnsld_Al_Ptr_Unit_Actl_Q4__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q1__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q2__c,
                    Adv_Cnsld_Al_Ptr_Rev_Actl_Q3__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q4__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q1__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q2__c,
                    Adv_Cnsld_Al_Ptr_Unit_Actl_Q3__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q4__c,Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q1__c,Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q2__c,
                    Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q3__c,Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q4__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q1__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q2__c,
                    Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q3__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q4__c, 
					Isilon_Grwt_Ptr_Unts_Actl_Q1__c,Isilon_Grwt_Ptr_Unts_Actl_Q2__c,Isilon_Grwt_Ptr_Unts_Actl_Q3__c,Isilon_Grwt_Ptr_Unts_Actl_Q4__c,Isilon_Grwt_Ptr_Rev_Actl_Q1__c,Isilon_Grwt_Ptr_Rev_Actl_Q2__c,
					Isilon_Grwt_Ptr_Rev_Actl_Q3__c,Isilon_Grwt_Ptr_Rev_Actl_Q4__c,Isilon_Al_Ptr_Unt_Actl_Q1__c,Isilon_Al_Ptr_Unt_Actl_Q2__c,Isilon_Al_Ptr_Unt_Actl_Q3__c,Isilon_Al_Ptr_Unt_Actl_Q4__c,Isilon_Al_Ptr_Rev_Actl_Q1__c,Isilon_Al_Ptr_Rev_Actl_Q2__c,
					Isilon_Al_Ptr_Rev_Actl_Q3__c,Isilon_Al_Ptr_Rev_Actl_Q4__c,Isilon_Actl_Q1__c,Isilon_Acl_Q2__c,Isilon_Acl_Q3__c,Isilon_Acl_Q4__c,Isilon_Incentive_Actual_Q1__c,Isilon_Incentive_Actual_Q2__c,Isilon_Incentive_Actual_Q3__c,Isilon_Incentive_Actual_Q4__c,Isilon_Incentive_Actual_Total__c,
                    Isilon_Incentive_Rebate_Q1__c,Isilon_Incentive_Rebate_Q2__c,Isilon_Incentive_Rebate_Q3__c,Isilon_Incentive_Rebate_Q4__c,Isilon_Incentive_Rebate_Total__c,
                    Target_Products_Actual_Q1__c,Target_Products_Actual_Q2__c,Target_Products_Actual_Q3__c,Target_Products_Actual_Q4__c,Target_Products_Actual_Total__c,
                    Target_Products_Rebate_Q1__c,Target_Products_Rebate_Q2__c,Target_Products_Rebate_Q3__c,Target_Products_Rebate_Q4__c,Target_Products_Rebate_Total__c  from GAF_Revenue_Rebate__c 
                    where Profiled_Account__c in: mapAccountIdRevenue.keyset() and GAF_Year__c in: setYear]; 

          system.debug('lstGAF---->' +lstGAF);
          if(lstGAF.size()>0){
              for(GAF_Revenue_Rebate__c objGAF: lstGAF){
                  /* if(mapAccountIdYearAndGAF.containsKey(objGAF.Partner_Name__c)){
                     if(mapAccountIdYearAndGAF.get(objGAF.Partner_Name__c).containsKey(objGAF.Year__c)){
                        
                     }else{
                        mapAccountIdYearAndGAF.get(objGAF.Partner_Name__c).put(objGAF.Year__c,objGAF);
                     }
                 }else{
                    mapAccountIdYearAndGAF.put(objGAF.Partner_Name__c,new map<string,GAF__c>());
                    mapAccountIdYearAndGAF.get(objGAF.Partner_Name__c).put(objGAF.Year__c,objGAF);
                 } */
                 if(mapAccountIdYear.containsKey(objGAF.Profiled_Account__c)){
                     if(mapAccountIdYear.get(objGAF.Profiled_Account__c).size()>0){
                         if(mapAccountIdYear.get(objGAF.Profiled_Account__c).contains(objGAF.GAF_Year__c)){
                            lstGAFToUpdate.add(objGAF);
                         }
                     }
                 }

              }
          }

         /*  if(!mapAccountIdYearAndGAF.isEmpty() && !mapAccountIdYear.isEmpty()){
              for(Id accId: mapAccountIdYear.keyset()){
                 if(mapAccountIdYearAndGAF.containsKey(accId)){
                     if(!mapAccountIdYearAndGAF.get(accId).isEmpty()){
                         for(Decimal year: mapAccountIdYear.get(accId)){
                            if(mapAccountIdYearAndGAF.get(accId).containsKey(string.valueOf(year))){
                                lstGAFToUpdate.add(mapAccountIdYearAndGAF.get(accId).get(string.valueOf(year)));
                            }
                         }
                     }
                 }
              }
          }*/
          
          if(lstGAFToUpdate.size()>0){
          
             decimal total;
             for(GAF_Revenue_Rebate__c objGAF: lstGAFToUpdate){
                 
                //mapAccIdandGAF.put(objGAF.Partner_Name__c,objGAF);
                  for(string objEMCBR: mapBusinessRule.keyset()){
                       total = 0.0;                         
                   
                    //Added by Ganesh   
                   System.debug('SFDCDEV0*****objEMCBR********'+objEMCBR);   
                   System.debug('SFDCDEV2*****objGAF********'+objGAF);   
                   if(objEMCBR.split(':').size()>1 && objEMCBR.split(':')[1]!=''){
                   String EBRTheater =   objEMCBR.split(':')[1];                              
                   if(objGAF.Theater__c == EBRTheater)
                   {                     
                       if(mapBusinessRule.containsKey(objEMCBR)){
                           if(mapBusinessRule.get(objEMCBR).Specility__c != ''){
                                lstSpecility = (mapBusinessRule.get(objEMCBR).Specility__c + ';').split(';');
                           }
                           if(mapBusinessRule.get(objEMCBR).Product_Type__c != ''){
                                lstProduct = (mapBusinessRule.get(objEMCBR).Product_Type__c +';').split(';');
                           }
                           if(mapBusinessRule.get(objEMCBR).Fields_to_Sum__c != ''){
                                lstFieldToSum = (mapBusinessRule.get(objEMCBR).Fields_to_Sum__c +';').split(';');
                           }
                           if(lstSpecility.size()>0 && lstProduct.size()>0 && lstFieldToSum.size()>0){
                               for(string spec: lstSpecility){
                                   spec = spec.toLowerCase().replaceAll(' ','');
                                   for(string prod: lstProduct){
                                       prod = prod.toLowerCase().replaceAll(' ','');
                                       for(string field: lstFieldToSum){
                                           system.debug('SUBSTRING-------->' +mapCustomSetting.containsKey(field.trim().substring(0,field.trim().indexOf('-'))));
                                           system.debug('FIELDLABEL-------->' +field.trim().substring(0,field.trim().indexOf('-')));
                                           system.debug('FIELDLABELTRIMMED-------->' +field.trim());
                                           if(mapCustomSetting.containsKey(field.replaceAll(' ','').substring(0,field.replaceAll(' ','').indexOf('-')))){ 
                                               system.debug('spec---->' +spec);
                                               system.debug('prod' +prod);
                                               system.debug('field' +field);
                                               system.debug('field.substring---->' +field.substring(0,field.indexOf('-')-1));
                                               system.debug('mapAccountIdRevenue.get(objGAF.Profiled_Account__c)' +mapAccountIdRevenue.get(objGAF.Profiled_Account__c));
                                              // system.debug('mapAccountIdRevenue.get(objGAF.Partner_Name__c).get(spec)' +mapAccountIdRevenue.get(objGAF.Partner_Name__c).get(spec));
                                              // system.debug('mapAccountIdRevenue.get(objGAF.Partner_Name__c).get(spec).get(prod)' +mapAccountIdRevenue.get(objGAF.Partner_Name__c).get(spec).get(prod));
                                             //  system.debug('mapAccountIdRevenue.get(objGAF.Partner_Name__c).get(spec).get(prod).get(System.Now().yearGmt())' +mapAccountIdRevenue.get(objGAF.Partner_Name__c).get(spec).get(prod).get(System.Now().yearGmt()));
                                               if(mapAccountIdRevenue.get(objGAF.Profiled_Account__c)!= null){
                                                   if(mapAccountIdRevenue.get(objGAF.Profiled_Account__c).get(spec)!= null){ 
                                                          if(mapAccountIdRevenue.get(objGAF.Profiled_Account__c).get(spec).get(prod) != null){
                                                               if(mapAccountIdRevenue.get(objGAF.Profiled_Account__c).get(spec).get(prod).containskey(decimal.valueof(objGAF.GAF_Year__c))){  
                                                                   try{  
                                                                       string ValueToSum = string.valueof(mapAccountIdRevenue.get(objGAF.Profiled_Account__c).get(spec).get(prod).get(decimal.valueof(objGAF.GAF_Year__c)).get(mapCustomSetting.get(field.replaceAll(' ','').substring(0,field.replaceAll(' ','').indexOf('-'))).DataValue__c));
                                                                       if(ValueToSum != null && ValueToSum != ''){ 
                                                                           system.debug('total---->' +total );
                                                                           system.debug('ValueToSum---->' +ValueToSum);
                                                                           total = total + decimal.valueOf(ValueToSum);
                                                                       }  
                                                                   }catch(exception e){
                                                                   }    
                                                              }   
                                                          }
                                                  }                
                                              }   
                                           }      
                                       }
                                   }
                               }
                           }
                       }   
                       try{
                           objGAF.put(objEMCBR.split(':')[0],total);
                       }catch(exception e){
                      }  
                    } 
                  }   
                }
             }
         } 
      }
      if(lstGAFToUpdate.size()>0){
          system.debug('lstGAFToUpdate------------->' +lstGAFToUpdate);
          system.debug('lstGAFToUpdate size------------->' +lstGAFToUpdate.size());
          Database.SaveResult[] saveResult = Database.update(lstGAFToUpdate,false);
      }
    }
/*@Method <This method gets executed acutomatically when the batch job is started.>
    @param <Database.BatchableContext BC - Batchable context>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
*/
        // Velocity Revenue Fields Calculation and updation
    public void calculateAndUpdateVR(map<Id,map<string,map<string,map<Decimal,Revenue__c>>>> mapAccountIdRevenue, map<string,map<string,EMC_Business_Rules__c>> mapBusinessRuleForVR){
       list<Velocity_Revenue__c> lstVelocityRevenue = new list<Velocity_Revenue__c>();
       map<string,CustomSettingDataValueMap__c> mapCustomSettings = CustomSettingDataValueMap__c.getall();
       map<Id,Velocity_Revenue__c> mapProfiledAccAndVRForUpdate = new map<Id,Velocity_Revenue__c>();
       map<Id,Velocity_Revenue__c> mapProfiledAccAndVRForInsert = new map<Id,Velocity_Revenue__c>();
       map<Id, Account> mapAccountDetails = new map<Id, Account>();
       string Quater;
       
       if(!mapAccountIdRevenue.isEmpty()){
            if(mapAccountIdRevenue.keyset().size() >0){
                mapAccountDetails = new map<Id, Account>([Select Id, Name, Theater1__c from Account where id in: mapAccountIdRevenue.keyset()]);
            }   
          lstVelocityRevenue = [Select Id,Partner_Profiled_Account__c,Partner_Profiled_Account__r.theater1__c, Theater__c,AC_Curr_Per_Rev_HW_SW__c,AC_Curr_Per_Rev_SVS__c,AC_Prev_Per_Rev_HW_SW__c,AC_Prev_Per_Rev_SVS__c,BR_Curr_Per_Rev_HW_SW__c,BR_Curr_Per_Rev_SVS__c,
                                BR_Prev_Per_Rev_HW_SW__c,BR_Prev_Per_Rev_SVS__c,C_Curr_Per_Rev_HW_SW__c,C_Curr_Per_Rev_SVS__c,C_Prev_Per_Rev_HW_SW__c,C_Prev_Per_Rev_SVS__c,
                                GA_Curr_Per_Rev_HW_SW__c,GA_Curr_Per_Rev_SVS__c,GA_Prev_Per_Rev_HW_SW__c,GA_Prev_Per_Rev_SVS__c,Total_Product_Curr_Per_Rev_HW_SW__c,
                                Total_Product_Prev_Per_Rev_HW_SW__c,Total_Services_Curr_Per_Rev_SVS__c,Total_Services_Prev_Per_Rev_SVS__c
                                from Velocity_Revenue__c where Partner_Profiled_Account__c in: mapAccountIdRevenue.keyset()];
          if(lstVelocityRevenue.size()>0){
             for(Velocity_Revenue__c objVR: lstVelocityRevenue){
                objVR.Theater__c = objVR.Partner_Profiled_Account__r.theater1__c;
                mapProfiledAccAndVRForUpdate.put(objVR.Partner_Profiled_Account__c,objVR);
             }
          }
          for(Id id: mapAccountIdRevenue.keyset()){
             if(!mapProfiledAccAndVRForUpdate.containsKey(id)){
                if(mapAccountDetails.containsKey(id)){
                     mapProfiledAccAndVRForInsert.put(id,new Velocity_Revenue__c(Theater__c =mapAccountDetails.get(id).Theater1__c));
                }else{
                    mapProfiledAccAndVRForInsert.put(id,new Velocity_Revenue__c());
                }               
             }
          }
             FiscalYearSettings FiscalYear = [Select f.EndDate, f.Id, f.Name, f.StartDate, f.YearType from FiscalYearSettings f where f.Name=:string.valueOf(System.Now().YearGmt())];
              if(date.isLeapYear(System.Now().YearGMT())){
                  if(FiscalYear.StartDate <= System.Now().dateGMT() && System.Now().dateGMT() <= FiscalYear.StartDate.addDays(90)){
                      if(mapCustomSettings.containsKey('Q1')){
                          if(mapCustomSettings.get('Q1').DataValue__c != ''){
                               Quater = mapCustomSettings.get('Q1').DataValue__c;
                          }
                      }
                  }  
                  if(FiscalYear.StartDate.addDays(91) <= System.Now().dateGMT() && System.Now().dateGMT() <= FiscalYear.StartDate.addDays(181)){
                        if(mapCustomSettings.containsKey('Q2')){
                          if(mapCustomSettings.get('Q2').DataValue__c != ''){
                               Quater = mapCustomSettings.get('Q2').DataValue__c;
                          }
                      }
                  }
                  if(FiscalYear.StartDate.addDays(182) <= System.Now().dateGMT() && System.Now().dateGMT() <= FiscalYear.StartDate.addDays(273)){
                        if(mapCustomSettings.containsKey('Q3')){
                          if(mapCustomSettings.get('Q3').DataValue__c != ''){
                               Quater = mapCustomSettings.get('Q3').DataValue__c;
                          }
                      }
                  }
                  if(FiscalYear.StartDate.addDays(274) <= System.Now().dateGMT() && System.Now().dateGMT() <= FiscalYear.EndDate){
                        if(mapCustomSettings.containsKey('Q4')){
                          if(mapCustomSettings.get('Q4').DataValue__c != ''){
                               Quater = mapCustomSettings.get('Q4').DataValue__c;
                          }
                      }
                  }
               }else{
                  if(FiscalYear.StartDate <= System.Now().dateGMT() && System.Now().dateGMT() <= FiscalYear.StartDate.addDays(89)){
                        if(mapCustomSettings.containsKey('Q1')){
                          if(mapCustomSettings.get('Q1').DataValue__c != ''){
                               Quater = mapCustomSettings.get('Q1').DataValue__c;
                          }
                      }
                  }  
                  if(FiscalYear.StartDate.addDays(90) <= System.Now().dateGMT() && System.Now().dateGMT() <= FiscalYear.StartDate.addDays(180)){
                        if(mapCustomSettings.containsKey('Q2')){
                          if(mapCustomSettings.get('Q2').DataValue__c != ''){
                               Quater = mapCustomSettings.get('Q2').DataValue__c;
                          }
                      }
                  }
                  if(FiscalYear.StartDate.addDays(181) <= System.Now().dateGMT() && System.Now().dateGMT() <= FiscalYear.StartDate.addDays(272)){
                        if(mapCustomSettings.containsKey('Q3')){
                          if(mapCustomSettings.get('Q3').DataValue__c != ''){
                               Quater = mapCustomSettings.get('Q3').DataValue__c;
                          }
                      }
                  }
                  if(FiscalYear.StartDate.addDays(273) <= System.Now().dateGMT() && System.Now().dateGMT() <= FiscalYear.EndDate){
                        if(mapCustomSettings.containsKey('Q4')){
                          if(mapCustomSettings.get('Q4').DataValue__c != ''){
                               Quater = mapCustomSettings.get('Q4').DataValue__c;
                          }
                      }
                  }
               }  
               
               if(!mapProfiledAccAndVRForUpdate.isEmpty() && Quater != null && Quater != ''){
                   insertUpdateVR(mapAccountIdRevenue,mapBusinessRuleForVR,mapProfiledAccAndVRForUpdate,false,Quater);
               }

               if(!mapProfiledAccAndVRForInsert.isEmpty() && Quater != null && Quater != ''){
                   insertUpdateVR(mapAccountIdRevenue,mapBusinessRuleForVR,mapProfiledAccAndVRForInsert,true,Quater);
               }
            }       
     }

    public void insertUpdateVR(map<Id,map<string,map<string,map<Decimal,Revenue__c>>>> mapAccountIdRevenue,map<string,map<string,EMC_Business_Rules__c>> mapBusinessRuleForVR,map<Id,Velocity_Revenue__c> mapProfiledAcc,Boolean isInsert,string Quater){
        list<Velocity_Revenue__c> lstVelocityRevenue = new list<Velocity_Revenue__c>();
        decimal total;
        list<string> lstSpecility = new list<string>();
        list<string> lstProduct = new list<string>();
        list<string> lstFieldToSum = new list<string>();
        map<string,CustomSettingDataValueMap__c> mapCustomSettings = CustomSettingDataValueMap__c.getall();
        
          for(Id obj: mapProfiledAcc.keyset()){
            Velocity_Revenue__c velocityRev = mapProfiledAcc.get(obj);
            velocityRev.Partner_Profiled_Account__c = obj;
            for(string objEMCBR: mapBusinessRuleForVR.keyset()){
               total = 0.0;         
           
            //Added by Ganesh   
            System.debug('SFDCDEV1*****objEMCBR********'+objEMCBR);           
            System.debug('SFDCDEV2*****velocityRev********'+velocityRev); 
             if(mapBusinessRuleForVR.containsKey(objEMCBR)){
                   if(mapBusinessRuleForVR.get(objEMCBR) != null){
                       if(mapBusinessRuleForVR.get(objEMCBR).containsKey(Quater)){
                            System.debug('SFDCDEV3*****mapBusinessRuleForVR.get(objEMCBR).get(Quater)********'+mapBusinessRuleForVR.get(objEMCBR).get(Quater));
                              if(mapBusinessRuleForVR.get(objEMCBR).get(Quater) != null){
                                if(mapBusinessRuleForVR.get(objEMCBR).get(Quater).Theater__c != null){
                                   if(velocityRev.Theater__c.toUpperCase() == mapBusinessRuleForVR.get(objEMCBR).get(Quater).Theater__c.toUpperCase())
                                   {                     
                                        if(mapBusinessRuleForVR.get(objEMCBR).get(Quater).Specility__c != ''){
                                             lstSpecility = (mapBusinessRuleForVR.get(objEMCBR).get(Quater).Specility__c + ';').split(';');
                                        }
                                        if(mapBusinessRuleForVR.get(objEMCBR).get(Quater).Product_Type__c != ''){
                                             lstProduct = (mapBusinessRuleForVR.get(objEMCBR).get(Quater).Product_Type__c +';').split(';');
                                        }
                                        if(mapBusinessRuleForVR.get(objEMCBR).get(Quater).Fields_to_Sum__c != ''){
                                             lstFieldToSum = (mapBusinessRuleForVR.get(objEMCBR).get(Quater).Fields_to_Sum__c +';').split(';');
                                        }
                                        if(lstSpecility.size()>0 && lstProduct.size()>0 && lstFieldToSum.size()>0){
                                           for(string spec: lstSpecility){
                                               spec = spec.toLowerCase().replaceAll(' ','');
                                               for(string prod: lstProduct){ 
                                                    prod = prod.toLowerCase().replaceAll(' ','');
                                                    for(string field: lstFieldToSum){ 
                                                        if(mapCustomSettings.containsKey(field.replaceAll(' ','').substring(0,field.replaceAll(' ','').indexOf('-')))){
                                                            if(mapCustomSettings.containsKey('Current')){
                                                                if(mapCustomSettings.get('Current').DataValue__c != ''){
                                                                    if(field.indexOf(mapCustomSettings.get('Current').DataValue__c) != -1){
                                                                          system.debug('spec---->' +spec);
                                                                          system.debug('prod' +prod);
                                                                          system.debug('field' +field);
                                                                          system.debug('field.substring---->' +field.replaceAll(' ','').substring(0,field.replaceAll(' ','').indexOf('-')));
                                                                          // system.debug('mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c)' +mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c));
                                                                          //system.debug('mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c).get(spec)' +mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c).get(spec));
                                                                          //system.debug('mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c).get(spec).get(prod)' +mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c).get(spec).get(prod));
                                                                          //system.debug('mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c).get(spec).get(prod).get(System.Now().yearGmt())' +mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c).get(spec).get(prod).get(System.Now().yearGmt()));
                                                                          if(mapAccountIdRevenue.get(obj)!= null){
                                                                               if(mapAccountIdRevenue.get(obj).get(spec)!= null){ 
                                                                                    if(mapAccountIdRevenue.get(obj).get(spec).get(prod) != null){
                                                                                         if(mapAccountIdRevenue.get(obj).get(spec).get(prod).containsKey(System.Now().yearGmt())){ 
                                                                                             try{
                                                                                                 string ValueToSum = string.valueof(mapAccountIdRevenue.get(obj).get(spec).get(prod).get(System.Now().yearGmt()).get(mapCustomSettings.get(field.replaceAll(' ','').substring(0,field.replaceAll(' ','').indexOf('-'))).DataValue__c));
                                                                                                 if(ValueToSum != null && ValueToSum != ''){
                                                                                                     total = total + decimal.valueOf(ValueToSum);
                                                                                                 }
                                                                                              }catch(exception e){
                                                                                             }    
                                                                                         }
                                                                                     }
                                                                               }
                                                                          }                    
                                                                     }
                                                                }
                                                             } 
                                                             if(mapCustomSettings.containsKey('Previous')){
                                                                 if(mapCustomSettings.get('Previous').DataValue__c != ''){
                                                                     if(field.indexOf(mapCustomSettings.get('Previous').DataValue__c)!= -1){
                                                                          system.debug('spec1---->' +spec);
                                                                          system.debug('prod1' +prod);
                                                                          system.debug('field1' +field);
                                                                          //system.debug('field.substring1---->' +field.substring(0,field.indexOf('-')-1));
                                                                          // system.debug('mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c)1' +mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c));
                                                                          // system.debug('mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c).get(spec)1' +mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c).get(spec));
                                                                          // system.debug('mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c).get(spec).get(prod)1' +mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c).get(spec).get(prod));
                                                                          //system.debug('mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c).get(spec).get(prod).get(System.Now().yearGmt()-1)1' +mapAccountIdRevenue.get(objVR.Partner_Profiled_Account__c).get(spec).get(prod).get(System.Now().yearGmt()-1));
                                                                          if(mapAccountIdRevenue.get(obj)!= null){
                                                                                if(mapAccountIdRevenue.get(obj).get(spec)!= null){ 
                                                                                       if(mapAccountIdRevenue.get(obj).get(spec).get(prod) != null){
                                                                                            if(mapAccountIdRevenue.get(obj).get(spec).get(prod).containsKey(System.Now().yearGmt()-1)){
                                                                                                try{ 
                                                                                                   string ValueToSum = string.valueof(mapAccountIdRevenue.get(obj).get(spec).get(prod).get(System.Now().yearGmt()-1).get(mapCustomSettings.get(field.replaceAll(' ','').substring(0,field.replaceAll(' ','').indexOf('-'))).DataValue__c));
                                                                                                   if(ValueToSum != null){
                                                                                                       total = total + decimal.valueOf(ValueToSum);
                                                                                                   }
                                                                                                }catch(exception e){
                                                                                                }   
                                                                                            }
                                                                                       }
                                                                               }
                                                                          }                      
                                                                     }
                                                                 }
                                                             }
                                                         }
                                                     }
                                                 }
                                           }
                                        }             
                                          
                                       try{  
                                           velocityRev.put(objEMCBR.split(':')[0],total);
                                        }catch(exception e){
                                        }  
                                    }            
                                }
                           }
                       }
                   }
             }
           }
           lstVelocityRevenue.add(velocityRev);
        }
        if(lstVelocityRevenue.size()>0 && isInsert){
            Database.SaveResult[] saveResult = Database.insert(lstVelocityRevenue,false);
        }
        if(lstVelocityRevenue.size()>0 && !isInsert){
            Database.SaveResult[] saveResult1 = Database.update(lstVelocityRevenue,false);
        }
    }
    
      public void insertUpdateRevenue(list<Staging_Data__c> lstStaging){
       list<Revenue__c> lstRevenue = new list<Revenue__c>();
       set<string> setGroupingAutoNumber = new set<string>();
       map<string,Account_Groupings__c> mapGroupingAutoNumGrouping = new map<string,Account_Groupings__c>();
       list<Account_Groupings__c> lstAccountGrping  = new list<Account_Groupings__c>();
       map<string,CustomSettingDataValueMap__c> mapCustomSetting1 = CustomSettingDataValueMap__c.getall();
       map<string,Revenue__c> mapAccountRevenue = new map<string,Revenue__c>();
       Revenue__c revenue;
       for(Staging_Data__c obj: lstStaging){
           setGroupingAutoNumber.add(obj.Text1__c);     
       }
       system.debug('setGroupingAutoNumber ---->' +setGroupingAutoNumber );

       lstAccountGrping =  [Select Id,Id__c,Profiled_Account__c from Account_Groupings__c where Id__c in: setGroupingAutoNumber];
       
       if(lstAccountGrping.size()>0){
           for(Account_Groupings__c objGrouping: lstAccountGrping){
               mapGroupingAutoNumGrouping.put(objGrouping.Id__c,objGrouping);
           }
       }
        
       system.debug('mapGroupingAutoNumGrouping---->' +mapGroupingAutoNumGrouping);
       for(Staging_Data__c obj: lstStaging){
           if(mapGroupingAutoNumGrouping.containsKey(obj.Text1__c)){ 
               revenue = new Revenue__c();
               if(mapGroupingAutoNumGrouping.get(obj.Text1__c).Profiled_Account__c != null){
                   revenue.Account__c = mapGroupingAutoNumGrouping.get(obj.Text1__c).Profiled_Account__c;
               } 
               if(mapGroupingAutoNumGrouping.get(obj.Text1__c) != null){   
                   revenue.Grouping__c = mapGroupingAutoNumGrouping.get(obj.Text1__c).Id;
               }    
               revenue.Speciality__c = obj.Text2__c;
               revenue.Product_Type__c = obj.Text3__c;
               if(obj.Text4__c != null && obj.Text4__c != ''){
                   try{
                        revenue.Year__c = decimal.valueof(obj.Text4__c);
                   }catch(exception e){
                   }
               }    
               revenue.Theater__c = obj.Text5__c;
               revenue.Batch_Id__c = obj.Batch_Id__c;
               if(mapGroupingAutoNumGrouping.get(obj.Text1__c) != null && obj.Text2__c != null && obj.Text2__c != '' && obj.Text3__c != null && obj.Text3__c != '' && obj.Text4__c != null && obj.Text3__c != ''){ 
                    if(mapAccountRevenue.containsKey(mapGroupingAutoNumGrouping.get(obj.Text1__c).Id+obj.Text2__c.toLowerCase().replaceAll(' ','')+obj.Text3__c.toLowerCase().replaceAll(' ','')+obj.Text4__c)){
                        revenue = mapAccountRevenue.get(mapGroupingAutoNumGrouping.get(obj.Text1__c).Id+obj.Text2__c.toLowerCase().replaceAll(' ','')+obj.Text3__c.toLowerCase().replaceAll(' ','')+obj.Text4__c);
                    }
               }
               
              // for(integer i = 1; i<=4; i++){
              if(obj.Text10__c != null && obj.Text10__c != ''){
                   //string Quater = 'Q'+obj.Text10__c;
                  // if(mapCustomSetting1.containsKey(Quater)){
                   //    if(mapCustomSetting1.get(Quater).DataValue__c != '' && mapCustomSetting1.get(Quater).DataValue__c != null){
                           if(obj.Text7__c != null && obj.Text7__c != ''){
                                try{
                                    revenue.put('Q'+obj.Text10__c+'_Growth_Revenue__c',decimal.valueof(obj.Text7__c));
                                }catch(exception e){
                                }        
                           } 
                           if(obj.Text9__c != null && obj.Text9__c != ''){  
                                try{  
                                    revenue.put('Q'+obj.Text10__c+'_Growth_Units__c',decimal.valueof(obj.Text9__c));
                                }catch(exception e){
                                }    
                           }
                           if(obj.Text6__c != null && obj.Text6__c != ''){    
                                try{ 
                                    revenue.put('Q'+obj.Text10__c+'_Total_Revenue__c',decimal.valueof(obj.Text6__c));
                                }catch(exception e){
                                }    
                           }
                           if(obj.Text8__c != null && obj.Text8__c != ''){  
                                try{    
                                    revenue.put('Q'+obj.Text10__c+'_Total_Units__c',decimal.valueof(obj.Text8__c));
                                }catch(exception e){
                                }    
                           }  
                       // }      
                  // }
               }
              
            system.debug('revenue---------->' +revenue.Speciality__c);
            if(mapGroupingAutoNumGrouping.get(obj.Text1__c) != null && obj.Text2__c != null && obj.Text2__c != '' && obj.Text3__c != null && obj.Text3__c != '' && obj.Text4__c != null && obj.Text3__c != ''){
                revenue.Unique_Combination__c = mapGroupingAutoNumGrouping.get(obj.Text1__c).Id+obj.Text2__c.toLowerCase().replaceAll(' ','')+obj.Text3__c.toLowerCase().replaceAll(' ','')+obj.Text4__c;
                mapAccountRevenue.put(mapGroupingAutoNumGrouping.get(obj.Text1__c).Id+obj.Text2__c.toLowerCase().replaceAll(' ','')+obj.Text3__c.toLowerCase().replaceAll(' ','')+obj.Text4__c,revenue);
            }   
            
           //revenue.Unique_Combination__c = mapGroupingAutoNumGrouping.get(obj.Text1__c).Id+obj.Text2__c+obj.Text3__c+obj.Text4__c;
           //lstRevenue.add(revenue);
           }
           system.debug('lstRevenue---->' +lstRevenue);
       }
       if(mapAccountRevenue.size()>0){
          //Database.Upsert(lstRevenue,false);
          Schema.SObjectField fieldTransaction = Revenue__c.Fields.Unique_Combination__c;
          system.debug('mapAccountRevenue.values()---->' +mapAccountRevenue.values());
          Database.upsert (mapAccountRevenue.values(), fieldTransaction, false);
       }
       system.debug('lstRevenueAfterInsert---->' +lstRevenue);
   }
    public void populateGAFForPANLBCustom(list<GAF_Revenue_Rebate__c> lstGAFRevenueAndRebate){
        PRM_PAN_VPP_VelocityRuleResultsUtils PANVelocityRuleResultsUtils = new PRM_PAN_VPP_VelocityRuleResultsUtils ();
        list<Id> lstPANId = new list<Id>();
        list<Id> lstLBId = new list<Id>();
        set<Id> setCustomGAFRevAndRebateId = new set<Id>();
        map<Id,list<Account_Groupings__c>> mapPANIdOrLBIdAndRelatedGrouping = new map<Id,list<Account_Groupings__c>>();
        //map<Id,list<Account_Groupings__c>> mapLBIdAndRelatedGrouping = new map<Id,list<Account_Groupings__c>>();
        list<Id> lstAccountGroupingIdUnderPANOrLB = new list<Id>();
        list<GAF_Revenue_Rebate__c> lstGAFForGroupingUnderPANOrLB = new list<GAF_Revenue_Rebate__c>();
        map<Id,map<string,GAF_Revenue_Rebate__c>> mapGroupingIdAndMapYearAndGAF = new map<Id,map<string,GAF_Revenue_Rebate__c>>();
        list<GAF_Revenue_Rebate__c> lstGAFRevenueAndRebateToUpdate = new list<GAF_Revenue_Rebate__c>();
        //list<Id> lstAccountGroupingIdUnderLB = new list<Id>();
        map<Id,set<Id>> mapCustomGAFAndRelatedGroupingId = new map<Id,set<Id>>();
        list<EMC_Business_Rules__c> lstEMCBusinessRule = new list<EMC_Business_Rules__c>();
        set<string> setGAFFieldName = new set<string>();
        set<string> setYear = new set<string>();
        map<String,CustomSettingDataValueMap__c> mapCustomSetting = CustomSettingDataValueMap__c.getall();
        Id RecordType;
        if(mapCustomSetting.containsKey('Revenue Summary Rule')){
            if(mapCustomSetting.get('Revenue Summary Rule').DataValue__c != ''){
                RecordType = mapCustomSetting.get('Revenue Summary Rule').DataValue__c;
                 lstEMCBusinessRule = [Select Name,Evaluation_Time_Period__c,RecordType.Id,Fields_to_Sum__c,Object_Name__c,Product_Type__c,Field_Name__c,Specility__c,Theater__c from EMC_Business_Rules__c
                                       where RecordType.Id =:RecordType and Object_Name__c = 'GAF_Revenue_Rebate__c'];
            }
        }   
       
        if(lstEMCBusinessRule.size()>0){
            for(EMC_Business_Rules__c objEMC: lstEMCBusinessRule){
                setGAFFieldName.add(objEMC.Field_Name__c);   
            }
        }
        if(lstGAFRevenueAndRebate.size()>0){
            for(GAF_Revenue_Rebate__c gafRevenueAndRebate: lstGAFRevenueAndRebate){
                if(gafRevenueAndRebate.GAF_Revenue_Rebate_Type__c == 'Pan-Theater'){
                    lstPANId .add(gafRevenueAndRebate.Pan_Theater__c);
                }
                if(gafRevenueAndRebate.GAF_Revenue_Rebate_Type__c == 'Logical Block'){
                    lstLBId.add(gafRevenueAndRebate.Logical_Block__c);
                }
                if(gafRevenueAndRebate.GAF_Revenue_Rebate_Type__c == 'Custom'){
                    setCustomGAFRevAndRebateId.add(gafRevenueAndRebate.Id);
                }
                setYear.add(gafRevenueAndRebate.GAF_Year__c);
            }

            if(lstPANId.size()>0){
                mapPANIdOrLBIdAndRelatedGrouping = PANVelocityRuleResultsUtils.getGroupingsUnderPANLevel(lstPANId);
            }
            if(lstLBId.size()>0){
                mapPANIdOrLBIdAndRelatedGrouping.putAll(PANVelocityRuleResultsUtils.getGroupingsUnderLogicalBlock(lstLBId));
            }
            if(setCustomGAFRevAndRebateId.size()>0){
                mapCustomGAFAndRelatedGroupingId = getGroupingsUnderCustom(setCustomGAFRevAndRebateId);
            }
            if(!mapPANIdOrLBIdAndRelatedGrouping.isEmpty()){
                for(Id panOrLBId: mapPANIdOrLBIdAndRelatedGrouping.keyset()){
                    if(mapPANIdOrLBIdAndRelatedGrouping.get(panOrLBId).size()>0){
                        for(Account_Groupings__c grouping: mapPANIdOrLBIdAndRelatedGrouping.get(panOrLBId)){
                            lstAccountGroupingIdUnderPANOrLB.add(grouping.Id);
                        }
                    }
                }
            }
            if(!mapCustomGAFAndRelatedGroupingId.isEmpty()){
                for(Id customGAFId: mapCustomGAFAndRelatedGroupingId.keyset()){
                    if(mapCustomGAFAndRelatedGroupingId.get(customGAFId).size()>0){
                        for(Id groupingId: mapCustomGAFAndRelatedGroupingId.get(customGAFId)){
                            lstAccountGroupingIdUnderPANOrLB.add(groupingId);
                        }
                    }
                }
            }
            /*if(!mapLBIdAndRelatedGrouping.isEmpty()){
                for(Id lbId: mapLBIdAndRelatedGrouping.keyset()){
                    if(mapLBIdAndRelatedGrouping.get(lbId).size()>0){
                        for(Account_Groupings__c grouping: mapLBIdAndRelatedGrouping.get(panId)){
                            lstAccountGroupingIdUnderPANOrLB.add(grouping.Id);
                        }
                    }
                }
            }*/
            if(lstAccountGroupingIdUnderPANOrLB.size()>0 && setYear.size()>0){
                lstGAFForGroupingUnderPANOrLB = [Select Id,GAF_Revenue_Rebate_Type__c,Profiled_Account__c,Profiled_Account__r.Grouping__c,Logical_Block__c,Pan_Theater__c,Country__c,GAF_Year__c,Partner_Type__c,Theater__c,Advcd_Cnsld_Actual_Q1__c,Advcd_Cnsld_Actual_Q2__c,Advcd_Cnsld_Actual_Q3__c,Advcd_Cnsld_Actual_Q4__c,Advcd_Cnsld_Rebt_Q1__c,Advcd_Cnsld_Rebt_Q2__c,Advcd_Cnsld_Rebt_Q3__c,Advcd_Cnsld_Rebt_Q4__c,
                                                Adv_Cnsld_Al_Ptr_Rev_Actl_Q1__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q2__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q3__c,Adv_Cnsld_Al_Ptr_Rev_Actl_Q4__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q1__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q2__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q3__c,Adv_Cnsld_Al_Ptr_Unit_Actl_Q4__c,Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q1__c,Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q2__c,
                                                Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q3__c,Adv_Cnsld_Grwt_Ptr_Rev_Actl_Q4__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q1__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q2__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q3__c,Adv_Cnsld_Grwt_Ptr_Unt_Actl_Q4__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q1__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q2__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q3__c,BRS_Cnsld_All_Ptr_Rev_Rebt_Q4__c,
                                                BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q1__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q2__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q3__c,BRS_Cnsld_Grwt_Ptr_Unit_Rebt_Q4__c,BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q1__c,BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q2__c,BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q3__c,
                                                BRS_Cnsld_Grwt_Ptr_Rev_Rebt_Q4__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q1__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q2__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q3__c,BRS_Cnsld_All_Ptr_Unit_Actl_Q4__c,BRS_Cnsld_All_Ptr_Unit_Rebt_Q1__c,BRS_Cnsld_All_Ptr_Unit_Rebt_Q2__c,BRS_Cnsld_All_Ptr_Unit_Rebt_Q3__c,
                                                BRS_Cnsld_All_Ptr_Unit_Rebt_Q4__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q1__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q2__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q3__c,BRS_Cnsld_Grwt_Ptr_Rev_Actl_Q4__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q1__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q2__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q3__c,BRS_Cnsld_Grwt_Ptr_Unit_Actl_Q4__c,
                                                BRS_Cnsld_All_Ptr_Rev_Actl_Q1__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q2__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q3__c,BRS_Cnsld_All_Ptr_Rev_Actl_Q4__c,BRS_Cnsld_Grwt_Rev_Rebt_Q1__c,BRS_Cnsld_Grwt_Rev_Rebt_Q2__c,BRS_Cnsld_Grwt_Rev_Rebt_Q3__c,BRS_Cnsld_Grwt_Rev_Rebt_Q4__c,
                                                BRS_Cnsld_Grwt_Unit_Rebt_Q1__c,BRS_Cnsld_Grwt_Unit_Rebt_Q2__c,BRS_Cnsld_Grwt_Unit_Rebt_Q3__c,BRS_Cnsld_Grwt_Unit_Rebt_Q4__c,BRS_Actl_Q1__c,BRS_Actl_Q2__c,BRS_Actl_Q3__c,BRS_Actl_Q4__c,BRS_Al_Ptr_Rebt_Q1__c,BRS_Al_Ptr_Rebt_Q2__c,BRS_Al_Ptr_Rebt_Q3__c,BRS_Al_Ptr_Rebt_Q4__c,
                                                BRS_Al_Ptr_Rev_Actl_Q1__c,BRS_Al_Ptr_Rev_Actl_Q2__c,BRS_Al_Ptr_Rev_Actl_Q3__c,BRS_Al_Ptr_Rev_Actl_Q4__c,BRS_Al_Ptr_Rev_Rebt_Q1__c,BRS_Al_Ptr_Rev_Rebt_Q2__c,BRS_Al_Ptr_Rev_Rebt_Q3__c,BRS_Al_Ptr_Rev_Rebt_Q4__c,BRS_Al_Ptr_Unit_Actl_Q1__c,BRS_Al_Ptr_Unit_Actl_Q2__c,BRS_Al_Ptr_Unit_Actl_Q3__c,
                                                BRS_Al_Ptr_Unit_Actl_Q4__c,BRS_Al_Ptr_Unit_Rebt_Q1__c,BRS_Al_Ptr_Unit_Rebt_Q2__c,BRS_Al_Ptr_Unit_Rebt_Q3__c,BRS_Al_Ptr_Unit_Rebt_Q4__c,BRS_Grwt_Ptr_Rebt_Q1__c,BRS_Grwt_Ptr_Rebt_Q2__c,BRS_Grwt_Ptr_Rebt_Q3__c,BRS_Grwt_Ptr_Rebt_Q4__c,BRS_Grwt_Ptr_Rev_Actl_Q1__c,
                                                BRS_Grwt_Ptr_Rev_Actl_Q2__c,BRS_Grwt_Ptr_Rev_Actl_Q3__c,BRS_Grwt_Ptr_Rev_Actl_Q4__c,BRS_Grwt_Ptr_Unit_Actl_Q1__c,BRS_Grwt_Ptr_Unit_Actl_Q2__c,BRS_Grwt_Ptr_Unit_Actl_Q3__c,BRS_Grwt_Ptr_Unit_Actl_Q4__c,BRS_Rebt_Q1__c,BRS_Rebt_Q2__c,BRS_Rebt_Q3__c,BRS_Rebt_Q4__c,
                                                Cnsld_Actl_Q1__c,Cnsld_Actl_Q2__c,Cnsld_Actl_Q3__c,Cnsld_Actl_Q4__c,Cnsld_Al_Ptr_Rebt_Q1__c,Cnsld_Al_Ptr_Rebt_Q2__c,Cnsld_Al_Ptr_Rebt_Q3__c,Cnsld_Al_Ptr_Rebt_Q4__c,Cnsld_Al_Ptr_Rev_Actl_Q1__c,Cnsld_Al_Ptr_Rev_Actl_Q2__c,Cnsld_Al_Ptr_Rev_Actl_Q3__c,Cnsld_Al_Ptr_Rev_Actl_Q4__c,Cnsld_Al_Ptr_Unit_Actl_Q1__c,
                                                Cnsld_Al_Ptr_Unit_Actl_Q2__c,Cnsld_Al_Ptr_Unit_Actl_Q3__c,Cnsld_Al_Ptr_Unit_Actl_Q4__c,Cnsld_Al_Ptr_Unit_Rebt_Q1__c,Cnsld_Al_Ptr_Unit_Rebt_Q2__c,Cnsld_Al_Ptr_Unit_Rebt_Q3__c,Cnsld_Al_Ptr_Unit_Rebt_Q4__c,Cnsld_Al_Ptr_Rev_Rebt_Q1__c,Cnsld_All_Ptr_Rev_Rebt_Q2__c,Cnsld_All_Ptr_Rev_Rebt_Q3__c,
                                                Cnsld_All_Ptr_Rev_Rebt_Q4__c,Cnsld_Grwt_Ptr_Rebt_Q1__c,Cnsld_Grwt_Ptr_Rebt_Q2__c,Cnsld_Grwt_Ptr_Rebt_Q3__c,Cnsld_Grwt_Ptr_Rebt_Q4__c,Cnsld_Grwt_Ptr_Rev_Actl_Q1__c,Cnsld_Grwt_Ptr_Rev_Actl_Q2__c,Cnsld_Grwt_Ptr_Rev_Actl_Q3__c,Cnsld_Grwt_Ptr_Rev_Actl_Q4__c,
                                                Cnsld_Grwt_Ptr_Unt_Actl_Q1__c,Cnsld_Grwt_Ptr_Unt_Actl_Q2__c,Cnsld_Grwt_Ptr_Unt_Actl_Q3__c,Cnsld_Grwt_Ptr_Unt_Actl_Q4__c,Cnsld_Rebt_Q1__c,Cnsld_Rebt_Q2__c,Cnsld_Rebt_Q3__c,Cnsld_Rebt_Q4__c,Gvr_Arv_Actl_Q1__c,Gvr_Arv_Acl_Q2__c,Gvr_Arv_Acl_Q3__c,Gvr_Arv_Acl_Q4__c,
                                                Gvr_Arv_Al_Ptr_Rbt_Q1__c,Gvr_Arv_Al_Ptr_Rbt_Q2__c,Gvr_Arv_Al_Ptr_Rbt_Q3__c,Gvr_Arv_Al_Ptr_Rbt_Q4__c,Gvrn_Archv_Rebt_Q1__c,Gvrn_Archv_Rebt_Q2__c,Gvrn_Archv_Rebt_Q3__c,Gvrn_Archv_Rebt_Q4__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Q1__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Q2__c,
                                                Gvrn_Archv_Al_Ptr_Rev_Actl_Q3__c,Gvrn_Archv_Al_Ptr_Rev_Actl_Q4__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q1__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q2__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q3__c,Gvrn_Archv_All_Ptr_Rev_Rebt_Q4__c,Gvrn_Archv_Grwt_Ptr_Rebt_Q1__c,Gvrn_Archv_Grwt_Ptr_Rebt_Q2__c,Gvrn_Archv_Grwt_Ptr_Rebt_Q3__c,
                                                Gvrn_Archv_Grwt_Ptr_Rebt_Q4__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q1__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q2__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q3__c,Gvrn_Archv_All_Ptr_Unt_Rebt_Q4__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Q1__c,
                                                Gvrn_Archv_Al_Ptr_Unt_Actl_Q2__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Q3__c,Gvrn_Archv_Al_Ptr_Unt_Actl_Q4__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q1__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q2__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q3__c,Gvrn_Archv_Grwt_Ptr_Rev_Actl_Q4__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q1__c,
                                                Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q2__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q3__c,Gvrn_Archv_Grwt_Ptr_Unt_Actl_Q4__c,Isilon_Actl_Q1__c,Isilon_Acl_Q2__c,Isilon_Acl_Q3__c,Isilon_Acl_Q4__c,Isilon_Al_Ptr_Rbt_Q1__c,Isilon_Al_Ptr_Rbt_Q2__c,Isilon_Al_Ptr_Rbt_Q3__c,Isilon_Al_Ptr_Rbt_Q4__c,Isilon_Rebt_Q1__c,Isilon_Rebt_Q2__c,Isilon_Rebt_Q3__c,Isilon_Rebt_Q4__c,
												Isilon_Al_Ptr_Rev_Actl_Q1__c,Isilon_Al_Ptr_Rev_Actl_Q2__c,Isilon_Al_Ptr_Rev_Actl_Q3__c,Isilon_Al_Ptr_Rev_Actl_Q4__c,Isilon_Grwt_Ptr_Rebt_Q1__c,Isilon_Grwt_Ptr_Rebt_Q2__c,Isilon_Grwt_Ptr_Rebt_Q3__c,Isilon_Grwt_Ptr_Rebt_Q4__c,Isilon_All_Ptr_Unt_Rebt_Q1__c,Isilon_All_Ptr_Unt_Rebt_Q2__c,Isilon_All_Ptr_Unt_Rebt_Q3__c,Isilon_All_Ptr_Unt_Rebt_Q4__c,Isilon_Al_Ptr_Unt_Actl_Q1__c,Isilon_Al_Ptr_Unt_Actl_Q2__c,Isilon_Al_Ptr_Unt_Actl_Q3__c,Isilon_Al_Ptr_Unt_Actl_Q4__c,
												Isilon_Grwt_Ptr_Rev_Actl_Q1__c,Isilon_Grwt_Ptr_Rev_Actl_Q2__c,Isilon_Grwt_Ptr_Rev_Actl_Q3__c,Isilon_Grwt_Ptr_Rev_Actl_Q4__c,Isilon_Al_Ptr_Rev_Rebt_Q1__c,Isilon_Al_Ptr_Rev_Rebt_Q2__c,Isilon_Al_Ptr_Rev_Rebt_Q3__c,Isilon_Al_Ptr_Rev_Rebt_Q4__c,Isilon_Grwt_Ptr_Unts_Actl_Q1__c,Isilon_Grwt_Ptr_Unts_Actl_Q2__c,Isilon_Grwt_Ptr_Unts_Actl_Q3__c,Isilon_Grwt_Ptr_Unts_Actl_Q4__c,Isilon_Incentive_Actual_Q1__c,Isilon_Incentive_Actual_Q2__c,Isilon_Incentive_Actual_Q3__c,Isilon_Incentive_Actual_Q4__c,Isilon_Incentive_Actual_Total__c,
                    							Isilon_Incentive_Rebate_Q1__c,Isilon_Incentive_Rebate_Q2__c,Isilon_Incentive_Rebate_Q3__c,Isilon_Incentive_Rebate_Q4__c,Isilon_Incentive_Rebate_Total__c,
                   								Target_Products_Actual_Q1__c,Target_Products_Actual_Q2__c,Target_Products_Actual_Q3__c,Target_Products_Actual_Q4__c,Target_Products_Actual_Total__c,
                    							Target_Products_Rebate_Q1__c,Target_Products_Rebate_Q2__c,Target_Products_Rebate_Q3__c,Target_Products_Rebate_Q4__c,Target_Products_Rebate_Total__c from GAF_Revenue_Rebate__c 
                                                where Profiled_Account__r.Grouping__c in: lstAccountGroupingIdUnderPANOrLB and GAF_Year__c in: setYear];  
                                                //and LastModifiedDate >= :System.Now().addMinutes(-integer.valueOf(string.valueOf(mapCustomSetting.get('Time Duration to include GAFs').DateValue__c)))];
            }
            if(lstGAFForGroupingUnderPANOrLB.size()>0){
                for(GAF_Revenue_Rebate__c gafRevenueAndRebate: lstGAFForGroupingUnderPANOrLB){
                    if(mapGroupingIdAndMapYearAndGAF.containsKey(gafRevenueAndRebate.Profiled_Account__r.Grouping__c)){
                        mapGroupingIdAndMapYearAndGAF.get(gafRevenueAndRebate.Profiled_Account__r.Grouping__c).put(gafRevenueAndRebate.GAF_Year__c,gafRevenueAndRebate);            
                    }else{   
                        mapGroupingIdAndMapYearAndGAF.put(gafRevenueAndRebate.Profiled_Account__r.Grouping__c,new map<string,GAF_Revenue_Rebate__c>());
                        mapGroupingIdAndMapYearAndGAF.get(gafRevenueAndRebate.Profiled_Account__r.Grouping__c).put(gafRevenueAndRebate.GAF_Year__c,gafRevenueAndRebate);  
                    }
                }
            }
            if(setGAFFieldName.size()>0){
                for(GAF_Revenue_Rebate__c gafRevenueAndRebate: lstGAFRevenueAndRebate){
                    for(string fieldName: setGAFFieldName){
                        decimal totalValue = 0.0; 
                        if(gafRevenueAndRebate.GAF_Revenue_Rebate_Type__c == 'Pan-Theater'){
                            if(mapPANIdOrLBIdAndRelatedGrouping.containsKey(gafRevenueAndRebate.Pan_Theater__c)){
                                if(mapPANIdOrLBIdAndRelatedGrouping.get(gafRevenueAndRebate.Pan_Theater__c).size()>0){
                                    for(Account_Groupings__c grouping: mapPANIdOrLBIdAndRelatedGrouping.get(gafRevenueAndRebate.Pan_Theater__c)){
                                        if(mapGroupingIdAndMapYearAndGAF.containsKey(grouping.Id)){
                                            if(!mapGroupingIdAndMapYearAndGAF.get(grouping.Id).isEmpty()){
                                                if(mapGroupingIdAndMapYearAndGAF.get(grouping.Id).containsKey(gafRevenueAndRebate.GAF_Year__c)){
                                                    if(mapGroupingIdAndMapYearAndGAF.get(grouping.Id).get(gafRevenueAndRebate.GAF_Year__c).get(fieldName) != null){
                                                        totalValue = totalValue + decimal.valueOf(string.valueOf(mapGroupingIdAndMapYearAndGAF.get(grouping.Id).get(gafRevenueAndRebate.GAF_Year__c).get(fieldName)));
                                                    }    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            gafRevenueAndRebate.put(fieldName,totalValue);
                        }
                        if(gafRevenueAndRebate.GAF_Revenue_Rebate_Type__c == 'Logical Block'){
                            if(mapPANIdOrLBIdAndRelatedGrouping.containsKey(gafRevenueAndRebate.Logical_Block__c)){
                                if(mapPANIdOrLBIdAndRelatedGrouping.get(gafRevenueAndRebate.Logical_Block__c).size()>0){
                                    for(Account_Groupings__c grouping: mapPANIdOrLBIdAndRelatedGrouping.get(gafRevenueAndRebate.Logical_Block__c)){
                                        if(mapGroupingIdAndMapYearAndGAF.containsKey(grouping.Id)){
                                            if(!mapGroupingIdAndMapYearAndGAF.get(grouping.Id).isEmpty()){
                                                if(mapGroupingIdAndMapYearAndGAF.get(grouping.Id).containsKey(gafRevenueAndRebate.GAF_Year__c)){
                                                    if(mapGroupingIdAndMapYearAndGAF.get(grouping.Id).get(gafRevenueAndRebate.GAF_Year__c).get(fieldName) != null){
                                                        totalValue = totalValue + decimal.valueOf(string.valueOf(mapGroupingIdAndMapYearAndGAF.get(grouping.Id).get(gafRevenueAndRebate.GAF_Year__c).get(fieldName)));
                                                    }    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            gafRevenueAndRebate.put(fieldName,totalValue);
                        }
                        if(gafRevenueAndRebate.GAF_Revenue_Rebate_Type__c == 'Custom'){
                            if(mapCustomGAFAndRelatedGroupingId.containsKey(gafRevenueAndRebate.Id)){
                                if(mapCustomGAFAndRelatedGroupingId.get(gafRevenueAndRebate.Id).size()>0){
                                    for(Id groupingId: mapCustomGAFAndRelatedGroupingId.get(gafRevenueAndRebate.Id)){
                                        if(mapGroupingIdAndMapYearAndGAF.containsKey(groupingId)){
                                            if(!mapGroupingIdAndMapYearAndGAF.get(groupingId).isEmpty()){
                                                if(mapGroupingIdAndMapYearAndGAF.get(groupingId).containsKey(gafRevenueAndRebate.GAF_Year__c)){
                                                    if(mapGroupingIdAndMapYearAndGAF.get(groupingId).get(gafRevenueAndRebate.GAF_Year__c).get(fieldName) != null){
                                                        totalValue = totalValue + decimal.valueOf(string.valueOf(mapGroupingIdAndMapYearAndGAF.get(groupingId).get(gafRevenueAndRebate.GAF_Year__c).get(fieldName)));
                                                    }    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            gafRevenueAndRebate.put(fieldName,totalValue);
                        }
                    }
                    lstGAFRevenueAndRebateToUpdate.add(gafRevenueAndRebate);
                }
            }
            if(lstGAFRevenueAndRebateToUpdate.size()>0){
                Database.Update(lstGAFRevenueAndRebateToUpdate,false);
            }
            system.debug('--------lstGAFRevenueAndRebateToUpdate------------'+lstGAFRevenueAndRebateToUpdate);
        }
    }

     public Map<Id,set<Id>> getGroupingsUnderCustom(set<Id> customGAFRevAndRebateIds ){
        Map<Id,set<Id>> mapCustomGAFAndRelatedGroupingId = new Map<Id,set<Id>> ();
        list<Multi_Country_Revenue_Roll_Up__c> lstMultiCountryRevenueRollUp = new list<Multi_Country_Revenue_Roll_Up__c>();
        if(customGAFRevAndRebateIds.size()>0){
            lstMultiCountryRevenueRollUp = [Select Id,GAF_Revenue_Rebate__c,Profiled_Account__c,Profiled_Account__r.Grouping__c from Multi_Country_Revenue_Roll_Up__c
                                            where GAF_Revenue_Rebate__c in :customGAFRevAndRebateIds];
        }
        if(lstMultiCountryRevenueRollUp.size()>0){
            for(Multi_Country_Revenue_Roll_Up__c multiCountryRecord: lstMultiCountryRevenueRollUp){
                if(mapCustomGAFAndRelatedGroupingId.containsKey(multiCountryRecord.GAF_Revenue_Rebate__c)){
                    mapCustomGAFAndRelatedGroupingId.get(multiCountryRecord.GAF_Revenue_Rebate__c).add(multiCountryRecord.Profiled_Account__r.Grouping__c);
                }else{
                    mapCustomGAFAndRelatedGroupingId.put(multiCountryRecord.GAF_Revenue_Rebate__c,new set<Id>());
                    mapCustomGAFAndRelatedGroupingId.get(multiCountryRecord.GAF_Revenue_Rebate__c).add(multiCountryRecord.Profiled_Account__r.Grouping__c);
                }
            }
        }
            return mapCustomGAFAndRelatedGroupingId;
    }              
}