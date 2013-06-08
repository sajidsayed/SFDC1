/*=====================================================================================================+
|  HISTORY  |                                                                           
|  DATE          DEVELOPER        WR            DESCRIPTION                               
|  ====          =========        ==            =========== 
| 21-Feb-2011    Saravanan C    REQ# 1823      This Batch class is used to populate Tier1 and Tier2 fields 
|                                              on  the leads.  
| 04-Mar-2011    Prasad K		Defect#        The code was not populating T1 and T2 fields updated batch job query.   	 
+=====================================================================================================*/


global class PRM_PopPtnrBatch implements Database.Batchable<SObject>{

    public string batchName;
    Map<String,CustomSettingDataValueMap__c> getTimeInterval = CustomSettingDataValueMap__c.getall();
    
    global final string Query;
    
    global PRM_PopPtnrBatch(){
        batchName = 'Populate Partner on Lead Batch : ' + Datetime.now();
        system.debug(batchName + ' started ');
        this.Query ='SELECT id, ownerId, Reject_Lead__c, Accept_Lead__c,Tier_2_Partner__c, Partner__c, Previous_CAM_Email__c, CAM_Email__c, Channel__c,' 
                + ' Last_Inside_Sales_Owner__c, Last_EMC_Owner__c FROM Lead where (Partner__c = NULL AND Tier_2_Partner__c = NULL ) and (Reporting_Owner__r.ContactId<> null or owner.Name like \'Partner%\')';
    }
    
    global PRM_PopPtnrBatch(String strQuery){
        batchName = 'Populate Partner on Lead Batch : ' + Datetime.now();
        system.debug(batchName + ' started ');
        this.Query =strQuery;
    } 
            
    global Database.queryLocator start(Database.BatchableContext ctx){
         return Database.getQueryLocator(Query);              
                
    } // Start
     
    global void execute(Database.BatchableContext ctx, List<Sobject> scope){
        List<Lead> leads = (List<Lead>)scope;
        System.Debug('LeadstoProcess---->' +leads);
       PRM_PopulatePartnerOnLead pp = new PRM_PopulatePartnerOnLead();
       pp.populatePartneronLead(leads);
        
       List<Database.SaveResult> dsrs = Database.update(leads, true);
       if(dsrs.size()>0){
       	  PRM_PopulatePartnerOnLead.logFailedRecords(dsrs);
       }
    } // Execute
 
 global void finish(Database.BatchableContext ctx){ 
 
       system.debug('Batch ' + batchName + ' completed with following details');
       AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems FROM AsyncApexJob where Id =:ctx.getJobId()];
       system.debug('Id: ' + a.Id);
       system.debug('Status: '+ a.Status);
       system.debug('Number of Errors: ' + a.NumberOfErrors);
       system.debug('Job Items Processed: ' + a.JobItemsProcessed);
       system.debug('Total Job Items: ' + a.TotalJobItems);
       //Schedule the next batch job to run for 5 minutes later:
       Datetime dt = System.now();
       Integer timeInMin = Integer.valueof(getTimeInterval.get('PopulatePartneronLeadTimeInterval').DataValue__c);
       dt = dt.addMinutes(timeInMin);
       String scheduleString='0';//0 seconds
       scheduleString+=' '+ dt.minute();
       scheduleString+=' '+ dt.hour();
       scheduleString+=' '+ dt.day();
       scheduleString+=' '+ dt.month();
       scheduleString+=' ?';
       scheduleString+=' '+ dt.year();
       String jobName = 'Populate Partner on Lead Batch - ' + dt.format('MM-dd-yyyy-hh:');
  
       PRM_PopulatePartneronLeadScheduler nextBatchJob = new PRM_PopulatePartneronLeadScheduler();
       System.schedule(jobName,scheduleString,nextBatchJob);
 
 } // Finish
                 
}