/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  21/01/2011    Suman B                           To Evaluate the VelocityRules for each VelocityRuleResult
 |  22/01/2011    Anand Sharma                      According to our latest logic.
 |  09/02/2011    Anand Sharma                      Added schedulable interfacse to schedule call
 |  06/09/2011    Suman B                 3735      Added condition check in the execute() schedulabe method for running jobs based on 
 |                                                  Account Theaters.
 |  13/09/2011    Suman B                 3735      Updated the execute() schedulable method to run for multiple Theaters.     
 |  16 Aug 2012   Arif                              Updated Class due to PAN Theater
    30 Aug 2012   Arif                              Updated query to include logical Requirement set for logic for grouping
    17/10/2012   Krishna Pydavula         197607   Added code snippet to send an email  
    15/11/2012   vivek kodi               197607    To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.
 +=======================================================================================================*/

global class PRM_VPP_VelocityRuleEvaluatorJob extends SequencialBatchJobScheduler{
    
    // Data members
    global final String Query;    

    /* constructor */
    global PRM_VPP_VelocityRuleEvaluatorJob(){ 
                             
        String ruleResultQuery = 'Select Revenue_Amount__c, Required_value_Type__c,v.Speciality_RuleID__c, v.Rule_theater__c, v.RequiredCount__c,Speciality_RuleID__r.RecordType.Name ,Speciality_RuleID__r.RecordType.DeveloperName,'
                               + 'v.Name, v.Grouping__c, v.Current__c, v.Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,'
                               + 'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Cluster__c, '
                               + 'Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c,Speciality_RuleID__r.Local_Requirment_Set__c, '
                               + 'Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,v.Grouping__r.RecordType.DeveloperName,'
                               + 'Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.Theater__c,'
                               + 'Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,'
                               + 'v.AccountID__c From Velocity_Rule_Results__c v where Grouping__r.RecordType.DeveloperName = \'Partner_Grouping\' ORDER BY v.Grouping__c' ;
        
        System.Debug('ruleResultQuery ###' + ruleResultQuery); 
        this.Query = ruleResultQuery ;

    }
    
    global PRM_VPP_VelocityRuleEvaluatorJob(String Query){                  
        System.Debug('ruleResultQuery ###' + Query);  
        this.Query = Query ;    
    }
   
    /*create batch of records which is passed to execute method for processing */
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
    
    /* List of passed VelocityRuleResult scope. */
    global override void execute(Database.BatchableContext BC, List<SObject> scope){
        List<Velocity_Rule_Results__c > listVelocityRuleResults = (List<Velocity_Rule_Results__c>) scope;
        string batchid = BC.getjobid();
        PRM_VPP_RuleEvaluator objRuleEvaluator = new PRM_VPP_RuleEvaluator(listVelocityRuleResults);
        //objRuleEvaluator.evaluateVelocityRule(listVelocityRuleResults);
         objRuleEvaluator.evaluateVelocityRulewitherrors(listVelocityRuleResults,batchid,emailerrors);
    }

  /*  global void finish(Database.BatchableContext BC){       
        //Schedule the next batch job to run for 1 minutes later:
        Datetime dt = System.now();
        dt = dt.addMinutes(1);
        String scheduleString='0';//0 seconds
        scheduleString+=' '+ dt.minute();
        scheduleString+=' '+ dt.hour();
        scheduleString+=' '+ dt.day();
        scheduleString+=' '+ dt.month();
        scheduleString+=' ?';
        scheduleString+=' '+ dt.year();     
        
        Id ScheduleBatchEducationEducMasterGroupId = System.schedule('Schedule PRM_VPP_RollupRuleEvaluatorJob Batch',scheduleString , new PRM_VPP_RollupRuleEvaluatorJob());

    } 
    
     */
    
    
    /* this method used to schedule class */
     //Execute batch class with default constructor from schedular
  /*  global void execute(SchedulableContext sc) {
       system.debug('Inside PRM_VPP_VelocityRuleEvaluatorJob : execute- SchedulableContext #####') ;                
        //Used to store the data mapping for the education master using the custom setting.
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        
        Integer batchSize = 10; // this will be overwritten in try block
        try {
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null) {
                System.abortJob(ct.Id);
            }
        } catch (Exception e) {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
        }
        
        try
        {            
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleEvaluatorJob').DataValue__c);
        }
        catch(Exception e)
        {
            batchSize = 10;
        }

        /** Added for execute batch based on Theater 
        CustomSettingDataValueMap__c jobObjectTheater      = DataValueMap.get('RunAllJobs_Theater');
        CustomSettingDataValueMap__c jobObjectEval_Theater = DataValueMap.get('RunAllJobsEval_Theater');
 
        if(jobObjectEval_Theater.DataValue__c == 'true' && jobObjectTheater.DataValue__c != Null && jobObjectTheater.DataValue__c != ''){
          system.debug('Inside execute PRM_VPP_VelocityRuleEvaluatorJob - Theater ####### '); 
          String theater = jobObjectTheater.DataValue__c ;
          system.debug('Theater ## '+ theater) ;
          String ruleResultQuery = 'Select Revenue_Amount__c, Required_value_Type__c,v.Speciality_RuleID__c, v.Rule_theater__c, v.RequiredCount__c,Speciality_RuleID__r.RecordType.Name ,Speciality_RuleID__r.RecordType.DeveloperName,'
                               + 'v.Name, v.Grouping__c, v.Current__c, v.Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c,'
                               + 'Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,Speciality_RuleID__r.Cluster__c, '
                               + 'Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c, '
                               + 'Speciality_RuleID__r.BR_Sub_category__c,Speciality_RuleID__r.Display_Name__c,'
                               + 'Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.Theater__c,'
                               + 'Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,'
                               + 'v.AccountID__c From Velocity_Rule_Results__c v  WHERE ' 
                               + 'v.Account_Theater__c IN ( '+ theater + ' )' + ' ORDER BY v.Grouping__c  ' ;
             
         database.executebatch(new PRM_VPP_VelocityRuleEvaluatorJob(ruleResultQuery), batchSize);                               
        }
        else {                
         database.executebatch(new PRM_VPP_VelocityRuleEvaluatorJob(), batchSize);
        }
   } */
}