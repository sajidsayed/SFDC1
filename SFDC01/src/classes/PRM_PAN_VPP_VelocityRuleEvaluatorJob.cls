/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |16-July-2012    Prasad Kothawade                  To create Velocity rule results for PAN Theater model.
 |                                                                                              
 +17/10/2012      Krishna Pydavula         197607   Added code snippet to send an email  
 15/11/2012       vivek kodi              197607      To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.        
 +=======================================================================================================*/


global class PRM_PAN_VPP_VelocityRuleEvaluatorJob extends SequencialBatchJobScheduler{
    
    // Data members
    global final String Query;
   

    /* @Constructor <PRM_PAN_VPP_VelocityRuleEvaluatorJob(): This constructor would be used for   
                                                settingup the default query for evaluation of job.>
       @param - <Not accepting anything>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */
    global PRM_PAN_VPP_VelocityRuleEvaluatorJob(){ 
                             
        String ruleResultQuery = 'Select Revenue_Amount__c, Required_value_Type__c,v.Speciality_RuleID__c, v.Rule_theater__c, v.RequiredCount__c,Speciality_RuleID__r.RecordType.Name ,Speciality_RuleID__r.RecordType.DeveloperName,'
                               + 'v.Name, v.Grouping__c, v.Current__c, v.Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,Speciality_RuleID__r.Value__c, '
                               + 'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Cluster__c,Speciality_RuleID__r.Any_Value_Acceptable__c, '
                               + 'Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c,Speciality_RuleID__r.Evaluation_at__c, '
                               + 'Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,v.Grouping__r.RecordType.DeveloperName,Speciality_RuleID__r.Required__c,Speciality_RuleID__r.Local_Requirment_Set__c, '
                               + 'Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.Theater__c,'
                               + 'Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,'
                               + 'v.AccountID__c From Velocity_Rule_Results__c v where Grouping__r.RecordType.DeveloperName = \'Partner_Grouping_PAN_Theater\' '
                               + 'OR Grouping__r.RecordType.DeveloperName = \'Partner_Grouping_Logical_Block\' ORDER BY v.Grouping__c' ;
        
        System.Debug('ruleResultQuery ###' + ruleResultQuery); 
        this.Query = ruleResultQuery ;

    }
    
    /* @Constructor <PRM_PAN_VPP_VelocityRuleEvaluatorJob(): This constructor would be used for   
                                                settingup the query for evaluation of job.>
       @param - <Not accepting anything>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */
    global PRM_PAN_VPP_VelocityRuleEvaluatorJob(String Query){                  
        System.Debug('ruleResultQuery ###' + Query);  
        this.Query = Query ;    
    }
   
     
    /* @QueryLocator <PRM_PAN_VPP_VelocityRuleEvaluatorJob(): This method executed by apex scheduler
                                                            overriddeen from SequencialBatchJobScheduler class.>
       @param - Database.BatchableContext BC
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */
    global override Database.QueryLocator start(Database.BatchableContext BC){
    	//code added for WR 197607
       if(BC != null && BC.getJobId() !=null){
        batchprocessid=BC.getJobId();
        List<EMCException> emailerrors = new List<EMCException>();
        SendEmailNotificationToAllBatchjobs.EmailProcessor(batchprocessid,emailerrors);
        }
         //End of code for  WR 197607 
        return Database.getQueryLocator(query);
    } 
    
      /* @execute <PRM_PAN_VPP_VelocityRuleResultJob1(): This method executed by apex scheduler
                                                    overriddeen from SequencialBatchJobScheduler class.
                                                    This method Checks if groupings of type Logical Block then calls  
                                                    evaluateLogicalBlockVelocityRuleResults(). If groupings of type PAN Theater then calls 
                                                    evaluatePANTheaterVelocityRuleResults()
                                                    >
                                                    
       @param - Database.BatchableContext BC,List<SObject> scope
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */
    global override void execute(Database.BatchableContext BC, List<SObject> scope){
        List<Velocity_Rule_Results__c > listPANTheaterVelocityRuleResults = new list<Velocity_Rule_Results__c>();
        List<Velocity_Rule_Results__c > listLogicalBlockVelocityRuleResults = new list<Velocity_Rule_Results__c>();
        List<Velocity_Rule_Results__c > listCountryGroupingVRR = new list<Velocity_Rule_Results__c>();        
        // 1) Check if groupings of type Logical Block then  add in list of Logical Blocks
        List<Velocity_Rule_Results__c > listVelocityRuleResults = (List<Velocity_Rule_Results__c>) scope;
         string Batchid =  BC.getjobid();    
       
        // 2)If groupings of type PAN Theater then   add in list of PAN Theaters
        for(Velocity_Rule_Results__c ruleResultObj:listVelocityRuleResults){
            if(ruleResultObj.Grouping__r.RecordType.DeveloperName=='Partner_Grouping_Logical_Block'){
                listLogicalBlockVelocityRuleResults.add(ruleResultObj);
            }
            if(ruleResultObj.Grouping__r.RecordType.DeveloperName=='Partner_Grouping'){
                listCountryGroupingVRR.add(ruleResultObj);
            }        
            if(ruleResultObj.Grouping__r.RecordType.DeveloperName=='Partner_Grouping_PAN_Theater'){
                listPANTheaterVelocityRuleResults.add(ruleResultObj);
            }            
        }
        //3) call evaluateVelocityRule()
        PRM_VPP_RuleEvaluator objVRRRuleEvaluator = new PRM_VPP_RuleEvaluator(listCountryGroupingVRR);
        if(listCountryGroupingVRR != null && listCountryGroupingVRR.size()>0){                          
            //objVRRRuleEvaluator.evaluateVelocityRule(listCountryGroupingVRR);
             objVRRRuleEvaluator.evaluateVelocityRulewitherrors(listCountryGroupingVRR,Batchid,emailerrors);                           
         }
        
        // 4)call evaluateLogicalBlockVelocityRuleResults()
        PRM_PAN_VPP_RuleEvaluator objRuleEvaluator = new PRM_PAN_VPP_RuleEvaluator();  
        if(listLogicalBlockVelocityRuleResults.size()>0){
           //objRuleEvaluator.evaluateLogicalBlockVelocityRulesUsingRule(listLogicalBlockVelocityRuleResults);
           objRuleEvaluator.evaluateLogicalBlockVelocityRulesUsingRulewitherrors(listLogicalBlockVelocityRuleResults,Batchid,emailerrors);
        }       
        
        // 5) call evaluatePANTheaterVelocityRuleResults()
        if(listPANTheaterVelocityRuleResults.size()>0){
          // objRuleEvaluator.evaluatePanVelocityRulesUsingRule(listPANTheaterVelocityRuleResults);
           objRuleEvaluator.evaluatePanVelocityRulesUsingRulewitherrors(listPANTheaterVelocityRuleResults,Batchid,emailerrors);
        }        
       
    }
}