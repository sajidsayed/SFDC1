/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  04/02/2011    Prasad Kothawade                  To create Velocity rule results
 |  09/02/2011    Anand Sharma                      Added schedulable interfacse to schedule call
                                                    And Schedule "PRM_VPP_VelocityRuleEvaluatorJob" batch in finished method
    16 Aug 2012   Arif                              Updated Class due to PAN Theater
    30 Aug 2012   Arif                              For change in existing VPP evaluation job.
 +=======================================================================================================*/

global class PRM_VPP_VelocityRuleResultJob2 implements Database.Batchable<sObject>, Schedulable {
    
    // Data members
    global final String Query;    
    List<String> Recordtypes = new String[]{'Services_Rule'} ;
    List<String> RecordtypesSpecialtyAndTier = new String[]{'Specialty_Rule','Tier_Rule','Field_Based_Rule_Type'} ;

    
    /* constructor */
    global PRM_VPP_VelocityRuleResultJob2(){ 
                             
        String ruleResultQuery = 'Select v.AND_OR__c, v.BR_Sub_category__c, v.Bucket__c, v.Display_Name__c,  '
          +  ' v.Field_Name__c, v.Id, v.LastModifiedDate, v.Name, v.RecordTypeId, v.Required__c,v.Cluster__c,Evaluation_at__c,'
          +  ' v.Required_Type__c, v.Required_Value_Text__c, v.Specialty_Rule_Type__c,v.RecordType.DeveloperName,v.Local_Requirment_Set__c '
          +  ' v.Specilaity__c, v.Theater__c,  v.Tier__c, v.Velocity_Rule_1__c, v.Velocity_Rule_2__c, '
          +  ' v.Group_Rule_3__c, v.Group_Rule_4__c, v.Group_Rule_5__c,v.Any_Value_Acceptable__c,v.Value__c '
          +  ' from Velocity_Rules__c v where (RecordType.DeveloperName IN :Recordtypes OR (RecordType.DeveloperName IN:RecordtypesSpecialtyAndTier AND Evaluation_at__c = \'Country Grouping Level\')) ' ;
      // need to add the last modified logic.  
        System.Debug('ruleResultQuery ###' + ruleResultQuery); 
        this.Query = ruleResultQuery ;
        
        
    }
    
    global PRM_VPP_VelocityRuleResultJob2(String Query){                  
        System.Debug('ruleResultQuery ###' + Query);  
        this.Query = Query ;    
    }
   
    /*create batch of records which is passed to execute method for processing */
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    } 
    
    /* List of passed Educations scope. */
    global void execute(Database.BatchableContext BC, List<SObject> scope){
       List<Velocity_Rules__c> listVelocityRules = (List<Velocity_Rules__c>) scope;
       List<Id> ruleIds = new List<ID>();
       for(Velocity_Rules__c vr:listVelocityRules ){
           ruleIds.add(vr.Id);
          
       }
       System.debug('listVelocityRules -->' +listVelocityRules);
       System.debug('ruleIds.size() -->' +ruleIds.size());
       // delete existing VRR
        PRM_VPP_VelocityRuleResultsUtils.deleteVelocityRuleResults(ruleIds );    
        
       // create new VRR
       new PRM_VPP_VelocityRuleResults(listVelocityRules).createVelocityRuleResults();
       
    }

    global void finish(Database.BatchableContext BC){       
        //Schedule the next batch job to run for 2 minutes later:
        Datetime dt = System.now();
        dt = dt.addMinutes(2);
        String scheduleString='0';//0 seconds
        scheduleString+=' '+ dt.minute();
        scheduleString+=' '+ dt.hour();
        scheduleString+=' '+ dt.day();
        scheduleString+=' '+ dt.month();
        scheduleString+=' ?';
        scheduleString+=' '+ dt.year();     
        System.debug('currently scheduled. time for VelocityRuleEvaluator  ' + scheduleString); 
                                    
        PRM_VPP_VelocityRuleEvaluatorJob  objSchedule= new PRM_VPP_VelocityRuleEvaluatorJob();
        Id ScheduleBatchEducationEducMasterGroupId = System.schedule('Schedule VelocityRuleEvaluator Batch',scheduleString , objSchedule);
    }  
   
    /* this method used to schedule class */
     //Execute batch class with default constructor from schedular
    global void execute(SchedulableContext sc) {
                
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
            batchSize  = Integer.valueOf(DataValueMap.get('PRM_VPP_VelocityRuleResultJob2').DataValue__c);
        }
        catch(Exception e)
        {
            batchSize = 10;
        }
                
        database.executebatch(new PRM_VPP_VelocityRuleResultJob2(), batchSize);
        
   } 
    
}