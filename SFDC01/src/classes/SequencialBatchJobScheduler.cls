/*===========================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |   
    21-Nov-2011    Prasad                           Sequential batch logic 
    17/10/2012  Krishna Pydavula          197607    Added code snippet to send an email
    15/11/2012     vivek kodi             197607    To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.
 +===========================================================================*/


global virtual class SequencialBatchJobScheduler implements Database.batchable<sObject>,Schedulable,Database.Stateful {
 
    global List <SequencialBatchJob> BatchJobsList = new List <SequencialBatchJob>();
    private integer index=-1;
    public string batchprocessid;   
    global List<EMCException> emailerrors = new List<EMCException>();
    
    /*global SquencialBatchJobScheduler( List <SequencialBatchJob> BatchJobsList){
        this.BatchJobsList=BatchJobsList;
    }
    global SquencialBatchJobScheduler(List <SequencialBatchJob> BatchJobsList,integer index){
        this.BatchJobsList=BatchJobsList;
        this.index=index;
    }*/
    global SequencialBatchJobScheduler(){  
        
    }
    global void addSequencialBatchjob(SequencialBatchJob job){
         BatchJobsList.add(job);
    }
    global SequencialBatchJob getNextSequencialBatchjob(){
        return index+1<BatchJobsList.size()? BatchJobsList.get(index+1):null;
    }
    global SequencialBatchJob getCurrentSequencialBatchjob(){
        return BatchJobsList.get(index);
    }
    global SequencialBatchJob getPreviousSequencialBatchjob(){
        return index<BatchJobsList.size()&& index>=0 ? BatchJobsList.get(index-1):null;
    }
    
    global virtual Database.QueryLocator start(Database.BatchableContext BC){
        return null;
    }
    global virtual void execute(Database.BatchableContext BC, List<sObject> scope){
            System.debug('Size =====> '+BatchJobsList.size());  
            System.debug('Executing =====> '+getCurrentSequencialBatchjob().getJobName());
    }

    global void finish(Database.BatchableContext BC){
                //code added for WR 197607 
               if(BC != null && BC.getJobId() !=null){
                batchprocessid=BC.getJobId();                       
                SendEmailNotificationToAllBatchjobs.EmailProcessor(batchprocessid,emailerrors);
                }  
             //End of code for  WR 197607
        SequencialBatchJob NextJob = getNextSequencialBatchjob();
        if(NextJob!=null){
            
            //Schedule the next batch job to run for 1 minutes later:
            Datetime dt = System.now();
            dt = dt.addMinutes(NextJob.getStartAfterMins());
            String scheduleString='0';//0 seconds
            scheduleString+=' '+ dt.minute();
            scheduleString+=' '+ dt.hour();
            scheduleString+=' '+ dt.day();
            scheduleString+=' '+ dt.month();
            scheduleString+=' ?';
            scheduleString+=' '+ dt.year();     
            
            NextJob.getBatchJob().BatchJobsList = this.BatchJobsList;
            NextJob.getBatchJob().index = this.index+1;
            Id SequentailJobId = System.schedule(NextJob.getJobName(),scheduleString , NextJob.getBatchJob());  
       
            }else{
                    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();     
                   CustomSettingDataValueMap__c PRMVPPJobRunning = DataValueMap.get('PRMVPPJobRunning');  
                   PRMVPPJobRunning.DataValue__c = 'false' ;
                   update PRMVPPJobRunning ;
            }   
    }
    
    
    global void execute(SchedulableContext sc) {
        try {
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null) {
                System.abortJob(ct.Id);
            }
        } catch (Exception e) {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
            Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();     
            CustomSettingDataValueMap__c PRMVPPJobRunning = DataValueMap.get('PRMVPPJobRunning');  
            PRMVPPJobRunning.DataValue__c = 'false' +  e.getMessage();
            update PRMVPPJobRunning ;
        } 
        
        SequencialBatchJob CurrentJob = getCurrentSequencialBatchjob();
        database.executebatch(CurrentJob.getBatchJob(),CurrentJob.getBatchSize());
        
        
    }
     public static void executeSequence(List <SequencialBatchJob> BatchJobsList){
        SequencialBatchJobScheduler sequence = new SequencialBatchJobScheduler();
        sequence.BatchJobsList=BatchJobsList;
        
        SequencialBatchJob NextJob = sequence.getNextSequencialBatchjob();
        if(NextJob!=null){
            
            //Schedule the next batch job to run for 1 minutes later:
            Datetime dt = System.now();
            dt = dt.addMinutes(NextJob.getStartAfterMins());
            String scheduleString='0';//0 seconds
            scheduleString+=' '+ dt.minute();
            scheduleString+=' '+ dt.hour();
            scheduleString+=' '+ dt.day();
            scheduleString+=' '+ dt.month();
            scheduleString+=' ?';
            scheduleString+=' '+ dt.year();     
            
            NextJob.getBatchJob().BatchJobsList = sequence.BatchJobsList;
            NextJob.getBatchJob().index = sequence.index+1;
            Id SequentailJobId = System.schedule(NextJob.getJobName(),scheduleString , NextJob.getBatchJob());  
        }   
    }
}